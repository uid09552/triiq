import '../../plan/load_curve_controller.dart';
import '../../plan/plan_models.dart';
import '../../plan/plan_service.dart';
import '../../util/dates.dart';
import '../plan_proposals.dart';

/// The agent's view of the training plan and the proposals it may make on
/// it. Every number comes from the plan engine and the cache; nothing here
/// writes — a proposal only becomes a change when the athlete taps Apply.
class PlanAssistantTools {
  PlanAssistantTools({
    required this.service,
    PlanProposals? proposals,
    DateTime Function()? clock,
  }) : proposals = proposals ?? PlanProposals.instance,
       _clock = clock ?? DateTime.now;

  final PlanService service;
  final PlanProposals proposals;
  final DateTime Function() _clock;

  static const _notApplied =
      'Not applied. The athlete sees this as a card under your reply and '
      'decides with Apply or Dismiss — do not say it is done.';

  DateTime get _today => dateOnly(_clock());

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  String _day(DateTime d) => '${_weekdays[d.weekday - 1]} ${isoDate(d)}';

  // ------------------------------------------------------------- reading

  Future<Map<String, dynamic>> getTrainingPlan() async {
    final goal = await service.goals.load();
    final plan = await service.plans.getCurrent();
    final result = <String, dynamic>{
      'today': isoDate(_today),
      'goal': goal == null ? null : _goalJson(goal),
    };
    if (goal == null) {
      result['note'] =
          'No goal is saved. Ask the athlete for target, sport, training '
          'days and weekly hours; generate_training_plan can then build one.';
    } else {
      final curve = await service.curve(goal, today: _clock());
      final limits = curve.limits;
      if (limits == null) {
        result['load_graph_error'] = curve.failure?.message;
      } else {
        result['load_graph'] = _curveJson(
          LoadCurveController(
            limits: limits,
            weeks: curve.weeks,
            factors: goal.loadFactors,
          ),
        );
      }
    }
    result['plan'] = plan == null ? null : await _planJson(plan);
    return result;
  }

  Map<String, dynamic> _goalJson(Goal g) => {
    'target_type': g.targetType,
    'sport': g.sport,
    'weekdays': (g.weekdays.toList()..sort()),
    'weekly_hours': g.weeklyHours,
    'plan_weeks': g.planWeeks(PlanService.defaultStart(_clock())),
    if (g.eventDate != null) 'event_date': isoDate(g.eventDate!),
    if (_daysTo(g.eventDate) case final days?) 'days_to_event': days,
    if (g.eventDate != null)
      'phase_note':
          'A plan that ends in the event week tapers: "taper" weeks step the '
          'load down from the last build week and "race" is the event week '
          '(openers the day before, nothing from the event day on). '
          'get_training_guidance("taper") explains why.',
    if (g.isTriathlon) 'sport_mix_percent': g.sportMix,
    'hold_every_4th': g.holdEvery4th,
    'session_mix_percent': g.slotShares ?? 'goal type default',
    'preferences': {
      if (g.longDays.isNotEmpty)
        'long_session_days': {
          for (final e in g.longDays.entries) e.key: _weekdays[e.value - 1],
        },
      if (g.intervalDays.isNotEmpty)
        'interval_days': [for (final d in g.intervalDays) _weekdays[d - 1]],
      'max_sessions_per_day': g.effectiveMaxPerDay,
    },
    if (g.baselineWeeklyLoad != null)
      'baseline_weekly_load': g.baselineWeeklyLoad,
  };

  /// Days from today to [event], or `null` without one or once it is past.
  int? _daysTo(DateTime? event) {
    if (event == null) return null;
    final now = _clock();
    final days = DateTime.utc(
      event.year,
      event.month,
      event.day,
    ).difference(DateTime.utc(now.year, now.month, now.day)).inDays;
    return days < 0 ? null : days;
  }

  Map<String, dynamic> _curveJson(
    LoadCurveController c, {
    Set<int> changed = const {},
  }) {
    final targets = c.targets;
    final phases = c.phases;
    final flags = c.flags;
    final start = PlanService.defaultStart(_clock());
    return {
      'baseline_weekly_load': c.limits.baseline.round(),
      'max_weekly_increase_percent': (c.limits.rampCap * 100).round(),
      'hold_every_4th': c.limits.holdEvery > 0,
      'weeks': [
        for (var i = 0; i < c.weeks; i++)
          {
            'week': i + 1,
            'start_date': isoDate(
              DateTime(start.year, start.month, start.day + 7 * i),
            ),
            'proposed_tss': c.proposal[i].round(),
            'target_tss': targets[i].round(),
            'share_percent': (c.factors[i] * 100).round(),
            'allowed_tss': [
              c.bandFor(i).low.round(),
              c.bandFor(i).high.round(),
            ],
            'phase': phases[i],
            if (flags[i].isNotEmpty)
              'above_limits': [for (final l in flags[i]) l.name],
            if (c.proposalLimits[i] != WeekLimit.none)
              'proposal_held_by': c.proposalLimits[i].name,
            if (changed.contains(i)) 'changed': true,
          },
      ],
    };
  }

  Future<Map<String, dynamic>> _planJson(TrainingPlan plan) async {
    final actuals = await service.actualLoads(plan, today: _clock());
    return {
      'start_date': isoDate(plan.startDate),
      'sport': plan.sport,
      if (plan.sportMix.isNotEmpty) 'sport_mix_percent': plan.sportMix,
      'weeks': [
        for (final w in plan.weeks)
          {
            'week': w.index + 1,
            'start_date': isoDate(w.startDate),
            'phase': w.phase,
            'target_tss': w.targetLoad.round(),
            'planned_tss': w.plannedLoad,
            if (w.index < actuals.length && actuals[w.index] != null)
              'actual_tss': actuals[w.index],
            if (w.lowShare != null)
              'low_intensity_share': double.parse(
                w.lowShare!.toStringAsFixed(2),
              ),
            'sessions': [
              for (final s in w.sessions)
                {
                  'session_id': s.id,
                  'date': _day(s.date),
                  'sport': s.sport,
                  'slot': s.slot.name,
                  'name': s.name,
                  'minutes': s.minutes,
                  'tss': s.load,
                  'sent_to_intervals': s.status == PlanSessionStatus.created,
                  if (s.date.isBefore(_today)) 'past': true,
                },
            ],
          },
      ],
    };
  }

  // ------------------------------------------------------------ proposals

  /// Graph edits on top of the saved goal, returned as a proposal.
  Future<Map<String, dynamic>> proposeLoadCurve(
    Map<String, dynamic> args,
  ) async {
    final saved = await service.goals.load();
    if (saved == null) {
      return {'error': 'No goal is saved yet; there is no load graph to edit.'};
    }

    var base = saved;
    final changes = <String>[];
    final weeksArg = args['weeks'];
    if (weeksArg != null) {
      if (weeksArg is! num || weeksArg != weeksArg.roundToDouble()) {
        return {'error': 'weeks must be a whole number from 2 to 16.'};
      }
      base = base.copyWith(weeks: weeksArg.toInt());
      changes.add('${weeksArg.toInt()} weeks');
    }
    final mixArg = args['sport_mix'];
    if (mixArg != null) {
      if (mixArg is! Map || mixArg.values.any((v) => v is! num)) {
        return {
          'error':
              'sport_mix must map Swim, Ride and Run to whole percentages.',
        };
      }
      base = base.copyWith(
        sport: Goal.triathlon,
        sportMix: {
          for (final s in Goal.triathlonSports)
            s: ((mixArg[s] as num?) ?? 0).toInt(),
        },
      );
      changes.add('sport mix ${base.sportMix}');
    }
    final rampArg = args['ramp_percent'];
    if (rampArg != null) {
      if (rampArg is! num ||
          rampArg != rampArg.roundToDouble() ||
          rampArg < 0 ||
          rampArg > 15) {
        return {'error': 'ramp_percent must be a whole number from 0 to 15.'};
      }
      base = base.copyWith(maxWeeklyIncrease: rampArg / 100);
      changes.add('ramp +${rampArg.toInt()}% a week');
    }
    final holdArg = args['hold_every_4th'];
    if (holdArg != null) {
      if (holdArg is! bool) {
        return {'error': 'hold_every_4th must be true or false.'};
      }
      base = base.copyWith(holdEvery4th: holdArg);
      changes.add(holdArg ? 'hold every 4th week' : 'no hold weeks');
    }
    final reset = args['reset'] == true;
    final problem = base
        .copyWith(loadFactors: const [])
        .validate(today: _clock());
    if (problem != null) return {'error': problem};

    final curve = await service.curve(base, today: _clock());
    final limits = curve.limits;
    if (limits == null) {
      return {'error': curve.failure?.message ?? 'No load graph available.'};
    }
    final c = LoadCurveController(
      limits: limits,
      weeks: curve.weeks,
      factors: reset ? const [] : base.loadFactors,
    );
    final before = c.factors;
    if (reset) changes.add('reset to the proposal');

    // Explicit week values, then recovery weeks.
    final setWeeks = args['set_weeks'];
    if (setWeeks != null) {
      if (setWeeks is! List) {
        return {
          'error':
              'set_weeks must be a list like [{"week": 3, "tss": 420}] or '
              '[{"week": 3, "percent": 105}].',
        };
      }
      for (final entry in setWeeks) {
        if (entry is! Map || entry['week'] is! num) {
          return {'error': 'Each set_weeks entry needs a week number.'};
        }
        final week = (entry['week'] as num).toInt();
        if (week < 1 || week > c.weeks) {
          return {'error': 'week $week is outside the plan (1-${c.weeks}).'};
        }
        final i = week - 1;
        final tss = entry['tss'];
        final percent = entry['percent'];
        final double target;
        if (tss is num) {
          target = tss.toDouble();
        } else if (percent is num) {
          target = c.proposal[i] * percent / 100;
        } else {
          return {'error': 'week $week needs a "tss" or a "percent".'};
        }
        final band = c.bandFor(i);
        if (target < band.low - 2.5 || target > band.high + 2.5) {
          return {
            'error':
                'week $week allows ${band.low.round()}-${band.high.round()} '
                'TSS (80-120% of its proposed ${c.proposal[i].round()}); '
                '${target.round()} is outside that.',
          };
        }
        c.dragTss(i, target);
        changes.add('week $week -> ${c.targets[i].round()} TSS');
      }
    }
    final recovery = args['recovery_weeks'];
    if (recovery != null) {
      if (recovery is! List || recovery.any((w) => w is! num)) {
        return {'error': 'recovery_weeks must be a list of week numbers.'};
      }
      for (final w in recovery.cast<num>()) {
        final week = w.toInt();
        if (week < 1 || week > c.weeks) {
          return {'error': 'week $week is outside the plan (1-${c.weeks}).'};
        }
        c.dragTss(week - 1, c.bandFor(week - 1).low);
        changes.add('week $week -> ${c.targets[week - 1].round()} TSS');
      }
    }
    if (changes.isEmpty) {
      return {
        'error':
            'Nothing to change: pass set_weeks, recovery_weeks, weeks, '
            'sport_mix or reset.',
      };
    }

    final after = c.factors;
    final changed = {
      for (var i = 0; i < after.length; i++)
        if (i >= before.length || (after[i] - before[i]).abs() > 1e-9) i,
    };
    final goal = base.copyWith(loadFactors: after);
    final invalid = goal.validate(today: _clock());
    if (invalid != null) return {'error': invalid};

    final proposal = proposals.register(
      CurveProposal(
        summary: changes.join(', '),
        fingerprint: await proposals.fingerprint(),
        goal: goal,
        limits: limits,
        weeks: c.weeks,
        changedWeeks: changed,
      ),
    );
    return {
      'proposal_id': proposal.id,
      'summary': proposal.summary,
      'load_graph': _curveJson(c, changed: changed),
      'note': _notApplied,
    };
  }

  /// Registers a plan built from [goal] as a proposal; returns its id.
  Future<String> registerPlanDraft(Goal goal, String summary) async {
    final curve = await service.curve(goal, today: _clock());
    final proposal = proposals.register(
      PlanDraftProposal(
        summary: summary,
        fingerprint: await proposals.fingerprint(),
        goal: goal,
        limits: curve.limits,
        weeks: curve.weeks,
      ),
    );
    return proposal.id;
  }

  /// Move or remove one session of the current plan, as a proposal.
  Future<Map<String, dynamic>> proposeSessionChange(
    Map<String, dynamic> args,
  ) async {
    final id = args['session_id'];
    final action = args['action'];
    if (id is! num) {
      return {'error': 'session_id is required (from get_training_plan).'};
    }
    if (action != 'move' && action != 'remove') {
      return {'error': 'action must be "move" or "remove".'};
    }
    final plan = await service.plans.getCurrent();
    PlanSession? session;
    for (final s in plan?.sessions ?? const <PlanSession>[]) {
      if (s.id == id.toInt()) session = s;
    }
    if (plan == null || session == null) {
      return {'error': 'There is no session $id in the current plan.'};
    }
    if (session.date.isBefore(_today)) {
      return {'error': '${session.name} on ${_day(session.date)} is past.'};
    }

    DateTime? to;
    if (action == 'move') {
      final parsed = DateTime.tryParse('${args['date'] ?? ''}');
      if (parsed == null) {
        return {'error': 'A move needs "date" as YYYY-MM-DD.'};
      }
      to = dateOnly(parsed);
      final end = plan.startDate.add(Duration(days: 7 * plan.weeks.length));
      if (to.isBefore(_today)) {
        return {'error': '${isoDate(to)} is in the past.'};
      }
      if (to.isBefore(plan.startDate) || !to.isBefore(end)) {
        return {
          'error':
              '${isoDate(to)} is outside the plan '
              '(${isoDate(plan.startDate)} to '
              '${isoDate(end.subtract(const Duration(days: 1)))}).',
        };
      }
      if (to == session.date) {
        return {'error': 'The session is already on ${_day(to)}.'};
      }
    }

    final summary = to == null
        ? 'remove ${session.name} on ${_day(session.date)}'
        : 'move ${session.name} from ${_day(session.date)} to ${_day(to)}';
    final proposal = proposals.register(
      SessionChangeProposal(
        summary: summary,
        fingerprint: await proposals.fingerprint(),
        sessionId: session.id!,
        name: session.name,
        sport: session.sport,
        from: session.date,
        to: to,
      ),
    );
    return {
      'proposal_id': proposal.id,
      'summary': summary,
      if (session.status == PlanSessionStatus.created)
        'note_intervals':
            'This session is in Intervals.icu; applying changes it there '
            'too, which needs a connection and Send plan to Intervals.icu on.',
      'note': _notApplied,
    };
  }
}
