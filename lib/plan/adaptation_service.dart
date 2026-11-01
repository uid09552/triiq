import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../agent/plan_proposals.dart';
import '../data/repositories/activities_repository.dart';
import '../data/repositories/plans_repository.dart';
import '../evaluation/readiness.dart';
import '../evaluation/readiness_service.dart';
import '../util/dates.dart';
import 'plan_adaptation.dart';
import 'plan_models.dart';
import 'plan_service.dart';

/// Dismissed adaptation keys, kept across restarts so a dismissed
/// suggestion stays dismissed.
class DismissedAdaptations {
  static const _prefsKey = 'adaptation_dismissed_keys';

  Future<Set<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_prefsKey) ?? const []).toSet();
  }

  Future<void> add(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = (prefs.getStringList(_prefsKey) ?? const []).toSet()..add(key);
    await prefs.setStringList(_prefsKey, keys.toList()..sort());
  }

  /// Drops keys for situations that no longer exist (an old plan's
  /// sessions, weeks long gone), so the list doesn't grow forever.
  Future<void> keepOnly(Set<String> keys) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_prefsKey) ?? const [];
    final kept = stored.where(keys.contains).toList();
    if (kept.length != stored.length) {
      await prefs.setStringList(_prefsKey, kept);
    }
  }
}

/// Runs the adaptation rules over the saved plan and turns what they find
/// into proposals — the same [PlanProposals] the chat uses, keyed so Today
/// and the chat share one card per situation. Run after each sync and when
/// Today opens; never applies anything.
class AdaptationService {
  AdaptationService({
    PlansRepository? plans,
    GoalStore? goals,
    ActivitiesRepository? activities,
    ReadinessService? readiness,
    PlanService? planService,
    PlanProposals? proposals,
    DismissedAdaptations? dismissed,
    DateTime Function()? clock,
  }) : _plans = plans ?? PlansRepository(),
       _goals = goals ?? GoalStore(),
       _activities = activities ?? ActivitiesRepository(),
       _readiness = readiness ?? ReadinessService(),
       _planService = planService ?? PlanService(plans: plans, goals: goals),
       _proposals = proposals ?? PlanProposals.instance,
       _dismissed = dismissed ?? DismissedAdaptations(),
       _clock = clock ?? DateTime.now {
    _proposals.onKeyDismissed ??= (key) => _dismissed.add(key);
  }

  final PlansRepository _plans;
  final GoalStore _goals;
  final ActivitiesRepository _activities;
  final ReadinessService _readiness;
  final PlanService _planService;
  final PlanProposals _proposals;
  final DismissedAdaptations _dismissed;
  final DateTime Function() _clock;

  /// The live adaptation proposals for today, after registering new ones
  /// and retiring those whose situation is gone.
  Future<List<PlanProposal>> refresh() async {
    final plan = await _plans.getCurrent();
    final goal = await _goals.load();
    final today = dateOnly(_clock());
    final current = plan == null ? null : weekOf(plan, today);
    if (plan == null ||
        plan.status != PlanStatus.active ||
        goal == null ||
        current == null) {
      _proposals.retireAdaptations(const {});
      return const [];
    }

    final rules = (await _planService.knowledge.load()).rules;
    final activities = await _activities.getRange(
      isoDate(current.startDate.subtract(const Duration(days: 7))),
      isoDate(today),
    );
    Readiness? readiness;
    try {
      readiness = (await _readiness.load()).readiness;
    } catch (e) {
      debugPrint('AdaptationService: no readiness: $e');
    }

    final all = adaptPlan(
      plan: plan,
      goal: goal,
      activities: activities,
      today: today,
      rampCap: goal.maxWeeklyIncrease ?? rules.maxWeeklyIncrease,
      readiness: readiness,
    );
    await _dismissed.keepOnly({for (final a in all) a.key});
    final dismissed = await _dismissed.load();
    final live = [
      for (final a in all)
        if (!dismissed.contains(a.key)) a,
    ];

    final fingerprint = await _proposals.fingerprint();
    final result = <PlanProposal>[];
    for (final a in live) {
      final proposal = await _proposalFor(a, plan, goal, fingerprint, today);
      if (proposal != null) {
        result.add(_proposals.registerAdaptation(proposal));
      }
    }
    _proposals.retireAdaptations({for (final p in result) p.key!});
    return result;
  }

  Future<PlanProposal?> _proposalFor(
    Adaptation a,
    TrainingPlan plan,
    Goal goal,
    String fingerprint,
    DateTime today,
  ) async {
    switch (a) {
      case MissedSession(:final session, :final to):
        return SessionChangeProposal(
          summary: to == null
              ? 'let ${session.name} on ${_day(session.date)} go (missed)'
              : 'move missed ${session.name} from ${_day(session.date)} '
                    'to ${_day(to)}',
          fingerprint: fingerprint,
          sessionId: session.id!,
          name: session.name,
          sport: session.sport,
          from: session.date,
          to: to,
          missed: true,
          adaptation: a,
        );
      case WeekLoadOffTarget():
        final next = a.nextWeek.index;
        final factors = goal.factorsFor(
          plan.weeks.length > next ? plan.weeks.length : next + 1,
        );
        factors[next] = a.factor;
        final edited = goal.copyWith(loadFactors: factors);
        if (edited.validate(today: today) != null) return null;
        final curve = await _planService.curve(
          edited,
          start: plan.startDate,
          today: today,
        );
        final limits = curve.limits;
        if (limits == null) return null;
        return CurveProposal(
          summary:
              'week ${next + 1} -> ${a.newLoad.round()} TSS '
              '(week ${a.endedWeek.index + 1}: ${a.actual} of '
              '${a.target.round()} TSS done)',
          fingerprint: fingerprint,
          goal: edited,
          limits: limits,
          weeks: plan.weeks.length,
          changedWeeks: {next},
          adaptation: a,
        );
      case ReadinessConflict(:final session, :final swapWith, :final to):
        if (swapWith != null) {
          return SessionSwapProposal(
            summary:
                'swap ${session.name} (${_day(session.date)}) with '
                '${swapWith.name} (${_day(swapWith.date)}): readiness '
                '${a.level.name}',
            fingerprint: fingerprint,
            first: session,
            second: swapWith,
            adaptation: a,
          );
        }
        return SessionChangeProposal(
          summary: to == null
              ? 'remove ${session.name} today: readiness ${a.level.name}'
              : 'move ${session.name} to ${_day(to)}: readiness '
                    '${a.level.name}',
          fingerprint: fingerprint,
          sessionId: session.id!,
          name: session.name,
          sport: session.sport,
          from: session.date,
          to: to,
          adaptation: a,
        );
    }
  }

  static String _day(DateTime d) =>
      '${const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1]} '
      '${isoDate(d)}';
}
