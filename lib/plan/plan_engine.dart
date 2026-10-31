import 'dart:math' as math;

import '../util/dates.dart';
import 'knowledge.dart';
import 'load_curve.dart';
import 'plan_models.dart';

/// Builds a block of plan weeks from the athlete's goal, recent load, the
/// load curve and the training knowledge. Deterministic and free of I/O:
/// every number in a plan comes from here, never from the language model, so
/// a plan can be tested and explained.
class PlanEngine {
  PlanEngine(this.knowledge);

  final TrainingKnowledge knowledge;

  /// Most sessions placed on one day of a triathlon week.
  static const maxSessionsPerDay = 2;

  /// The limits a plan for [goal] is drawn within, or why there are none.
  /// [recentWeeklyLoads] are the completed weekly totals just before the
  /// plan, oldest first — `null` or too short means "not enough history"
  /// (unless the goal carries a baseline). [currentCtl] enables the CTL-ramp
  /// limit.
  ({CurveLimits? limits, PlanFailure? failure}) limitsFor({
    required Goal goal,
    required List<double>? recentWeeklyLoads,
    double? currentCtl,
    DateTime? today,
  }) {
    PlanFailure fail(PlanFailureKind kind, String message) =>
        PlanFailure(kind, message);

    final invalid = goal.validate(today: today ?? DateTime.now());
    if (invalid != null) {
      return (limits: null, failure: fail(PlanFailureKind.invalidGoal, invalid));
    }
    final profile = knowledge.goals[goal.targetType];
    if (profile == null) {
      return (
        limits: null,
        failure: fail(
          PlanFailureKind.invalidGoal,
          'Unknown goal "${goal.targetType}".',
        ),
      );
    }
    final rules = knowledge.rules;
    final baseline = _baseline(goal, recentWeeklyLoads, rules.minHistoryWeeks);
    if (baseline == null) {
      return (
        limits: null,
        failure: fail(
          PlanFailureKind.needsBaseline,
          'Less than ${rules.minHistoryWeeks} weeks of load history is '
          'cached. Enter a typical weekly load (TSS) or sync more history.',
        ),
      );
    }

    final entries = _weekEntries(goal, profile);
    if (entries == null) {
      return (limits: null, failure: _notEnoughDays(goal));
    }
    final ceilings = <String, double>{};
    for (final phase in const [buildPhase, recoveryPhase]) {
      try {
        ceilings[phase] = _loadForHours(goal, entries, phase);
      } on MissingTemplateException catch (error) {
        return (
          limits: null,
          failure: fail(PlanFailureKind.missingTemplate, error.toString()),
        );
      }
    }

    return (
      limits: CurveLimits(
        baseline: baseline,
        rampCap: goal.maxWeeklyIncrease ?? rules.maxWeeklyIncrease,
        maxCtlRamp: goal.maxCtlRamp ?? rules.maxCtlRamp,
        recoveryThreshold: rules.recoveryThreshold,
        ctl: currentCtl,
        hoursCeilings: ceilings,
      ),
      failure: null,
    );
  }

  PlanResult generate({
    required Goal goal,
    required DateTime startDate,
    required List<double>? recentWeeklyLoads,
    double? currentCtl,
    DateTime? today,
  }) {
    final found = limitsFor(
      goal: goal,
      recentWeeklyLoads: recentWeeklyLoads,
      currentCtl: currentCtl,
      today: today,
    );
    final limits = found.limits;
    if (limits == null) return PlanResult.failure(found.failure!);

    final profile = knowledge.goals[goal.targetType]!;
    final rules = knowledge.rules;
    final entries = _weekEntries(goal, profile)!;
    final monday = startOfWeek(startDate);
    final count = goal.planWeeks(monday);
    final proposal = proposeCurve(limits, count);
    final factors = goal.factorsFor(count);
    final targets = [
      for (var i = 0; i < count; i++) proposal.loads[i] * factors[i],
    ];
    final phases = phasesFor(limits, targets);
    final flags = flagWeeks(limits, targets, proposal: proposal.loads);

    final weeks = <PlanWeek>[];
    var ctl = currentCtl;
    for (var i = 0; i < count; i++) {
      final weekStart = monday.add(Duration(days: 7 * i));
      final List<PlanSession> sessions;
      try {
        final built = _buildSessions(
          goal: goal,
          entries: entries,
          phase: phases[i],
          weekIndex: i,
          weekStart: weekStart,
          weekLoad: targets[i],
        );
        if (built == null) return PlanResult.failure(_notEnoughDays(goal));
        sessions = built;
      } on MissingTemplateException catch (error) {
        return PlanResult.failure(
          PlanFailure(PlanFailureKind.missingTemplate, error.toString()),
        );
      }
      final built = sessions.fold<int>(0, (sum, s) => sum + s.load);

      double? ctlEnd;
      if (ctl != null) {
        ctlEnd = CurveLimits.nextCtl(ctl, built.toDouble());
        ctl = ctlEnd;
      }
      weeks.add(
        PlanWeek(
          index: i,
          phase: phases[i],
          startDate: weekStart,
          targetLoad: targets[i],
          requestedLoad: proposal.loads[i],
          limit: proposal.limits[i],
          factor: factors[i],
          warnings: flags[i],
          projectedCtlEnd: ctlEnd,
          sessions: sessions,
          lowIntensityTarget: rules.lowIntensityTarget,
          lowIntensityTolerance: rules.lowIntensityTolerance,
        ),
      );
    }

    return PlanResult.plan(
      TrainingPlan(
        goalType: goal.targetType,
        sport: goal.sport,
        startDate: monday,
        baselineLoad: limits.baseline,
        weeks: weeks,
        sportMix: goal.isTriathlon ? goal.sportMix : const {},
      ),
    );
  }

  PlanFailure _notEnoughDays(Goal goal) => PlanFailure(
    PlanFailureKind.notEnoughDays,
    '${goal.weekdays.length} training days cannot hold this week\'s '
    'sessions (at most $maxSessionsPerDay a day). Add a training day or set '
    'a sport to 0%.',
  );

  double? _baseline(Goal goal, List<double>? loads, int minWeeks) {
    final manual = goal.baselineWeeklyLoad;
    if (manual != null && manual > 0) return manual;
    if (loads == null || loads.length < minWeeks) return null;
    final recent = loads.sublist(loads.length - minWeeks);
    final mean = recent.fold<double>(0, (a, b) => a + b) / recent.length;
    return mean > 0 ? mean : null;
  }

  /// The sessions of one week as (sport, slot, fraction of week load), in
  /// placement order: long, intervals, Z2. `null` when the days can't hold
  /// the sessions a week must keep.
  List<_Entry>? _weekEntries(Goal goal, GoalProfile profile) {
    final shares = goal.sportShares;
    final days = goal.weekdays.length;
    final capacity = goal.isTriathlon ? days * maxSessionsPerDay : days;

    // Slot counts per sport; swim has no long session.
    final counts = <String, Map<SessionSlot, int>>{
      for (final sport in shares.keys)
        sport: {
          for (final e in profile.slots.entries)
            if (!(sport == 'Swim' && e.key == SessionSlot.long))
              e.key: sport == 'Swim' ? 1 : e.value.count,
        },
    };

    // Too many sessions: drop Z2 first, round robin over sports, but never a
    // sport's last session.
    int total() => counts.values.fold(
      0,
      (sum, c) => sum + c.values.fold(0, (a, b) => a + b),
    );
    final order = ['Run', 'Ride', 'Swim'];
    while (total() > capacity) {
      var dropped = false;
      for (final sport in order) {
        final c = counts[sport];
        if (c == null || (c[SessionSlot.z2] ?? 0) == 0) continue;
        final sessions = c.values.fold(0, (a, b) => a + b);
        if (sessions <= 1) continue;
        c[SessionSlot.z2] = c[SessionSlot.z2]! - 1;
        dropped = true;
        if (total() <= capacity) break;
      }
      if (!dropped) return null;
    }

    final entries = <_Entry>[];
    for (final slot in const [
      SessionSlot.long,
      SessionSlot.intervals,
      SessionSlot.z2,
    ]) {
      for (final sport in order.where(counts.containsKey)) {
        final c = counts[sport]!;
        final n = c[slot] ?? 0;
        if (n == 0) continue;
        // Renormalise slot shares over the slots this sport kept.
        final shareTotal = c.entries
            .where((e) => e.value > 0)
            .fold<double>(0, (sum, e) => sum + profile.slots[e.key]!.share);
        final fraction =
            shares[sport]! * profile.slots[slot]!.share / shareTotal / n;
        for (var k = 0; k < n; k++) {
          entries.add(_Entry(sport, slot, fraction));
        }
      }
    }
    return entries;
  }

  /// The most load a week can carry in the goal's hours given its sessions.
  double _loadForHours(Goal goal, List<_Entry> entries, String phase) {
    // Time = sum(fraction / tssPerHour) * load, so the cap is linear.
    var hoursPerLoad = 0.0;
    for (final e in entries) {
      final t = knowledge.templateFor(
        goal.targetType,
        e.slot,
        phase,
        sport: e.sport,
      );
      hoursPerLoad += e.fraction / t.tssPerHour;
    }
    return hoursPerLoad > 0 ? goal.weeklyHours / hoursPerLoad : double.infinity;
  }

  List<PlanSession>? _buildSessions({
    required Goal goal,
    required List<_Entry> entries,
    required String phase,
    required int weekIndex,
    required DateTime weekStart,
    required double weekLoad,
  }) {
    final days = goal.isTriathlon
        ? _placeMultiSport(goal.weekdays, entries)
        : _chooseDays(goal.weekdays, [for (final e in entries) e.slot]);
    if (days == null) return null;

    final sessions = <PlanSession>[];
    for (var n = 0; n < entries.length; n++) {
      final entry = entries[n];
      final template = knowledge.templateFor(
        goal.targetType,
        entry.slot,
        phase,
        sport: entry.sport,
      );
      final load = weekLoad * entry.fraction;
      final targetMinutes = _roundTo5(load / template.tssPerHour * 60);
      final built = _renderSteps(template.steps, targetMinutes, entry.sport);
      final minutes = built.minutes;
      sessions.add(
        PlanSession(
          weekIndex: weekIndex,
          date: weekStart.add(Duration(days: days[n] - 1)),
          slot: entry.slot,
          templateId: template.id,
          name: template.name,
          sport: entry.sport,
          minutes: minutes,
          load: (minutes / 60 * template.tssPerHour).round(),
          lowMinutes: minutes * template.lowShare,
          description: built.description,
        ),
      );
    }
    sessions.sort((a, b) => a.date.compareTo(b.date));
    return sessions;
  }

  int _roundTo5(double minutes) => math.max(20, (minutes / 5).round() * 5);

  /// Assigns a weekday to each entry of [slots] (same order), one session
  /// a day. The long session takes the last chosen day, the interval session
  /// the day furthest from it so hard days aren't back to back, Z2 the rest.
  List<int> _chooseDays(Set<int> available, List<SessionSlot> slots) {
    final sorted = available.toList()..sort();
    final n = slots.length;
    final chosen = <int>[];
    if (sorted.length <= n) {
      chosen.addAll(sorted);
    } else {
      for (var i = 0; i < n; i++) {
        chosen.add(sorted[(i * (sorted.length - 1) / (n - 1)).round()]);
      }
    }

    final longDay = chosen.last;
    final remaining = chosen.sublist(0, chosen.length - 1);
    final intervalDay = remaining.isEmpty
        ? null
        : (remaining.toList()..sort((a, b) {
                final byDistance = _distance(b, longDay).compareTo(
                  _distance(a, longDay),
                );
                return byDistance != 0 ? byDistance : a.compareTo(b);
              }))
              .first;

    final z2Days = remaining.where((d) => d != intervalDay).toList();
    final result = <int>[];
    for (final slot in slots) {
      switch (slot) {
        case SessionSlot.long:
          result.add(longDay);
        case SessionSlot.intervals:
          result.add(intervalDay ?? longDay);
        case SessionSlot.z2:
          result.add(z2Days.isNotEmpty ? z2Days.removeAt(0) : longDay);
      }
    }
    return result;
  }

  static int _distance(int a, int b) {
    final diff = (a - b).abs();
    return math.min(diff, 7 - diff);
  }

  /// Places a triathlon week, [entries] in their order (long, intervals,
  /// Z2): at most [maxSessionsPerDay] a day, the long sessions on different
  /// days, hard sessions spread out, one sport per day where possible.
  /// Greedy and deterministic; `null` when a session finds no day.
  List<int>? _placeMultiSport(Set<int> available, List<_Entry> entries) {
    final days = available.toList()..sort();
    final placed = <int, List<_Entry>>{for (final d in days) d: []};
    final result = <int>[];
    for (final entry in entries) {
      int? best;
      var bestCost = double.infinity;
      for (final day in days) {
        final there = placed[day]!;
        if (there.length >= maxSessionsPerDay) continue;
        if (entry.slot == SessionSlot.long &&
            there.any((e) => e.slot == SessionSlot.long)) {
          continue;
        }
        var cost = 10.0 * there.length;
        if (there.any((e) => e.sport == entry.sport)) cost += 1000;
        if (entry.isHard) {
          cost += 50.0 * there.where((e) => e.isHard).length;
          for (final other in days) {
            if (other != day && _distance(other, day) == 1) {
              cost += 5.0 * placed[other]!.where((e) => e.isHard).length;
            }
          }
        }
        if (entry.slot == SessionSlot.long && day < DateTime.saturday) {
          cost += 3;
        }
        if (cost < bestCost) {
          bestCost = cost;
          best = day;
        }
      }
      if (best == null) return null;
      placed[best]!.add(entry);
      result.add(best);
    }
    return result;
  }

  /// Turns a template's structure into Intervals.icu step syntax for
  /// [targetMinutes], returning the text and the minutes it adds up to.
  ({String description, int minutes}) _renderSteps(
    List<StepSpec> steps,
    int targetMinutes,
    String sport,
  ) {
    final suffix = sport == 'Run' || sport == 'Swim' ? ' Pace' : '';
    String pct(Intensity i) => '${i.forSport(sport).round()}%$suffix';

    final fixedMinutes = steps
        .whereType<FixedStep>()
        .fold<int>(0, (sum, s) => sum + s.effort.minutes);
    final hasFill = steps.any((s) => s is FillStep);

    // Repeats claim time first; a fill step takes what is left.
    var repeatCount = 0;
    final repeat = steps.whereType<RepeatStep>().firstOrNull;
    if (repeat != null) {
      final pair = repeat.work.minutes + repeat.rest.minutes;
      repeatCount = hasFill
          ? repeat.min
          : ((targetMinutes - fixedMinutes) / pair).floor().clamp(
              repeat.min,
              repeat.max,
            );
    }
    final repeatMinutes = repeat == null
        ? 0
        : repeatCount * (repeat.work.minutes + repeat.rest.minutes);
    final fillMinutes = hasFill
        ? math.max(5, targetMinutes - fixedMinutes - repeatMinutes)
        : 0;

    final lines = <String>[];
    for (final step in steps) {
      switch (step) {
        case FixedStep():
          lines.add('- ${step.effort.minutes}m ${pct(step.effort.intensity)}');
        case FillStep():
          lines.add('- ${fillMinutes}m ${pct(step.intensity)}');
        case RepeatStep():
          lines
            ..add('${repeatCount}x')
            ..add('  - ${step.work.minutes}m ${pct(step.work.intensity)}')
            ..add('  - ${step.rest.minutes}m ${pct(step.rest.intensity)}');
      }
    }
    return (
      description: lines.join('\n'),
      minutes: fixedMinutes + repeatMinutes + fillMinutes,
    );
  }
}

/// One session of a week before it has a day: its sport, slot and the
/// fraction of the week's load it carries.
class _Entry {
  const _Entry(this.sport, this.slot, this.fraction);

  final String sport;
  final SessionSlot slot;
  final double fraction;

  bool get isHard => slot != SessionSlot.z2;
}
