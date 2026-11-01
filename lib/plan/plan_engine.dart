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

  /// The default most sessions on one day of a triathlon week (the goal can
  /// lower it).
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
    DateTime? start,
  }) {
    PlanFailure fail(PlanFailureKind kind, String message) =>
        PlanFailure(kind, message);

    final now = today ?? DateTime.now();
    final monday = start == null ? Goal.defaultStart(now) : startOfWeek(start);
    final invalid = goal.validate(today: now, start: monday);
    if (invalid != null) {
      return (
        limits: null,
        failure: fail(PlanFailureKind.invalidGoal, invalid),
      );
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
        holdEvery: goal.holdEvery4th ? rules.holdEveryWeeks : 0,
        ctl: currentCtl,
        hoursCeilings: ceilings,
        taperFactors: goal.endsAtEvent(monday)
            ? rules.taper[goal.targetType] ?? const []
            : const [],
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
      start: startDate,
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
      final weekStart = _plusDays(monday, 7 * i);
      final List<PlanSession> sessions;
      final List<String> notes;
      try {
        final built = _buildSessions(
          goal: goal,
          profile: profile,
          entries: entries,
          phase: phases[i],
          weekIndex: i,
          weekStart: weekStart,
          weekLoad: targets[i],
        );
        if (built == null) return PlanResult.failure(_notEnoughDays(goal));
        sessions = built.sessions;
        notes = built.notes;
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
          notes: notes,
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
    'sessions (at most ${goal.effectiveMaxPerDay} a day). Add a training day, '
    'allow more sessions a day or set '
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
    final capacity = days * goal.effectiveMaxPerDay;

    // The athlete's session mix when set, the goal type's template otherwise.
    final custom = goal.slotShares;
    double slotShare(SessionSlot s) =>
        custom == null ? profile.slots[s]!.share : (custom[s.name] ?? 0) / 100;

    // Slot counts per sport; swim has no long session.
    final counts = <String, Map<SessionSlot, int>>{
      for (final sport in shares.keys)
        sport: {
          for (final e in profile.slots.entries)
            if (!(sport == 'Swim' && e.key == SessionSlot.long) &&
                slotShare(e.key) > 0)
              e.key: sport == 'Swim' ? 1 : e.value.count,
        },
    };

    // A mix that leaves a sport nothing (e.g. all long, for swim) falls back
    // to the template's slots for that sport rather than dropping its load.
    final fallback = <String>{};
    for (final sport in counts.keys) {
      if (counts[sport]!.isNotEmpty) continue;
      fallback.add(sport);
      counts[sport] = {
        for (final e in profile.slots.entries)
          if (!(sport == 'Swim' && e.key == SessionSlot.long))
            e.key: sport == 'Swim' ? 1 : e.value.count,
      };
    }
    double shareFor(String sport, SessionSlot s) =>
        fallback.contains(sport) ? profile.slots[s]!.share : slotShare(s);

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
            .fold<double>(0, (sum, e) => sum + shareFor(sport, e.key));
        final fraction =
            shares[sport]! * shareFor(sport, slot) / shareTotal / n;
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

  ({List<PlanSession> sessions, List<String> notes})? _buildSessions({
    required Goal goal,
    required GoalProfile profile,
    required List<_Entry> entries,
    required String phase,
    required int weekIndex,
    required DateTime weekStart,
    required double weekLoad,
  }) {
    // Taper and race week share the taper templates.
    final templatePhase = isTaperPhase(phase) ? taperPhase : phase;
    var weekGoal = goal;
    var weekEntries = entries;
    int? openersDay;
    final event = goal.eventDate;
    if (phase == racePhase && event != null) {
      final race = _raceWeek(goal, profile, entries, weekStart, event);
      weekGoal = race.goal;
      weekEntries = race.entries;
      openersDay = race.openersDay;
    }
    if (isTaperPhase(phase)) {
      weekEntries = _scaleShares(goal, weekEntries, templatePhase);
    }

    final sessions = <PlanSession>[];
    var notes = const <String>[];
    if (weekEntries.isNotEmpty) {
      final placement = _place(weekGoal, weekEntries);
      final days = placement.days;
      if (days == null) return null;
      notes = placement.notes;
      _addSessions(
        sessions: sessions,
        goal: goal,
        entries: weekEntries,
        days: days,
        phase: templatePhase,
        weekIndex: weekIndex,
        weekStart: weekStart,
        weekLoad: weekLoad,
      );
    }
    if (openersDay != null) {
      final sport = goal.isTriathlon ? 'Run' : goal.sport;
      final template = knowledge.templateFor(
        goal.targetType,
        SessionSlot.intervals,
        'openers',
        sport: sport,
      );
      final built = _renderSteps(template.steps, openersMinutes, sport);
      sessions.add(
        PlanSession(
          weekIndex: weekIndex,
          date: _plusDays(weekStart, openersDay - 1),
          slot: SessionSlot.intervals,
          templateId: template.id,
          name: template.name,
          sport: sport,
          minutes: built.minutes,
          load: (built.minutes / 60 * template.tssPerHour).round(),
          lowMinutes: built.minutes * template.lowShare,
          description: built.description,
        ),
      );
    }
    sessions.sort((a, b) => a.date.compareTo(b.date));
    return (sessions: sessions, notes: notes);
  }

  /// How long the openers the day before an event are meant to be.
  static const openersMinutes = 25;

  /// The event week: no session on the event day or after it, the day
  /// before kept for openers when it is a training day, and the sessions
  /// that still fit on the days left (Z2 dropped first).
  ({Goal goal, List<_Entry> entries, int? openersDay}) _raceWeek(
    Goal goal,
    GoalProfile profile,
    List<_Entry> entries,
    DateTime weekStart,
    DateTime event,
  ) {
    final eventDay =
        DateTime.utc(event.year, event.month, event.day)
            .difference(
              DateTime.utc(weekStart.year, weekStart.month, weekStart.day),
            )
            .inDays +
        1;
    final before = eventDay - 1;
    final openers = before >= 1 && goal.weekdays.contains(before)
        ? before
        : null;
    final available = {
      for (final d in goal.weekdays)
        if (d < eventDay && d != openers) d,
    };
    final weekGoal = goal.copyWith(weekdays: available);
    if (available.isEmpty) {
      return (goal: weekGoal, entries: const [], openersDay: openers);
    }
    final capacity = available.length * goal.effectiveMaxPerDay;
    final fitted =
        _weekEntries(weekGoal, profile) ?? _keepFittest(entries, capacity);
    return (goal: weekGoal, entries: fitted, openersDay: openers);
  }

  /// [entries] cut to [capacity]: intervals first, then Z2, then long, in
  /// the original placement order.
  static List<_Entry> _keepFittest(List<_Entry> entries, int capacity) {
    const priority = [SessionSlot.intervals, SessionSlot.z2, SessionSlot.long];
    final keep = <_Entry>{};
    for (final slot in priority) {
      for (final e in entries.where((e) => e.slot == slot)) {
        if (keep.length < capacity) keep.add(e);
      }
    }
    return [
      for (final e in entries)
        if (keep.contains(e)) e,
    ];
  }

  /// Taper weeks scale each slot's share by its template's `shareScale`,
  /// then renormalise per sport so the sport keeps its share of the week.
  List<_Entry> _scaleShares(Goal goal, List<_Entry> entries, String phase) {
    double scale(_Entry e) => knowledge
        .templateFor(goal.targetType, e.slot, phase, sport: e.sport)
        .shareScale;
    final plain = <String, double>{};
    final scaled = <String, double>{};
    for (final e in entries) {
      plain[e.sport] = (plain[e.sport] ?? 0) + e.fraction;
      scaled[e.sport] = (scaled[e.sport] ?? 0) + e.fraction * scale(e);
    }
    return [
      for (final e in entries)
        _Entry(
          e.sport,
          e.slot,
          scaled[e.sport]! <= 0
              ? e.fraction
              : e.fraction * scale(e) * plain[e.sport]! / scaled[e.sport]!,
        ),
    ];
  }

  void _addSessions({
    required List<PlanSession> sessions,
    required Goal goal,
    required List<_Entry> entries,
    required List<int> days,
    required String phase,
    required int weekIndex,
    required DateTime weekStart,
    required double weekLoad,
  }) {
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
          date: _plusDays(weekStart, days[n] - 1),
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
  }

  /// [day] plus [days] calendar days at midnight — not 24-hour steps, which
  /// land on 23:00 of the day before once a clock change is in between.
  static DateTime _plusDays(DateTime day, int days) =>
      DateTime(day.year, day.month, day.day + days);

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
    } else if (n == 1) {
      chosen.add(sorted.last);
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
                final byDistance = _distance(
                  b,
                  longDay,
                ).compareTo(_distance(a, longDay));
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

  /// Where each of [entries] goes, and which of the athlete's preferences
  /// the week couldn't honour (as [PlanWeek.notes] codes). A single-sport
  /// goal with no preferences keeps the original spread-out placement, so
  /// existing plans don't move; everything else is placed by cost.
  ({List<int>? days, List<String> notes}) _place(
    Goal goal,
    List<_Entry> entries,
  ) {
    final hasPreferences =
        goal.longDays.isNotEmpty ||
        goal.intervalDays.isNotEmpty ||
        goal.maxSessionsPerDay != null;
    if (!goal.isTriathlon && !hasPreferences) {
      return (
        days: _chooseDays(goal.weekdays, [for (final e in entries) e.slot]),
        notes: const [],
      );
    }
    final days = _placeByCost(goal, entries);
    if (days == null) return (days: null, notes: const []);

    final notes = <String>[];
    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      final wanted = goal.longDays[e.sport];
      if (e.slot == SessionSlot.long && wanted != null && days[i] != wanted) {
        notes.add('$noteLongDay:${e.sport}');
      }
    }
    final intervalIndexes = [
      for (var i = 0; i < entries.length; i++)
        if (entries[i].slot == SessionSlot.intervals) i,
    ];
    if (goal.intervalDays.isNotEmpty &&
        intervalIndexes.isNotEmpty &&
        !intervalIndexes.any((i) => goal.intervalDays.contains(days[i]))) {
      notes.add(noteIntervalDay);
    }
    return (days: days, notes: notes);
  }

  /// [PlanWeek.notes] codes: a long-session day (`longDay:<sport>`) or the
  /// interval days that the week couldn't honour.
  static const noteLongDay = 'longDay';
  static const noteIntervalDay = 'intervalDay';

  /// Places [entries] in their order (long, intervals, Z2): at most the
  /// goal's sessions per day, long sessions on different days, a sport's
  /// intervals and long session never on one day, preferred days first,
  /// hard sessions spread out, one sport per day where possible. Greedy and
  /// deterministic; `null` when a session finds no day.
  List<int>? _placeByCost(Goal goal, List<_Entry> entries) {
    final days = goal.weekdays.toList()..sort();
    final perDay = goal.effectiveMaxPerDay;
    final placed = <int, List<_Entry>>{for (final d in days) d: []};
    final result = <int>[];
    for (final entry in entries) {
      int? best;
      var bestCost = double.infinity;
      for (final day in days) {
        final there = placed[day]!;
        if (there.length >= perDay) continue;
        if (entry.slot == SessionSlot.long &&
            there.any((e) => e.slot == SessionSlot.long)) {
          continue;
        }
        if (entry.isHard &&
            there.any((e) => e.sport == entry.sport && e.isHard)) {
          continue;
        }
        var cost = 10.0 * there.length;
        if (there.any((e) => e.sport == entry.sport)) cost += 1000;
        if (entry.slot == SessionSlot.long &&
            goal.longDays[entry.sport] == day) {
          cost -= 200;
        }
        if (entry.slot == SessionSlot.intervals &&
            goal.intervalDays.contains(day)) {
          cost -= 100;
        }
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

    final fixedMinutes = steps.whereType<FixedStep>().fold<int>(
      0,
      (sum, s) => sum + s.effort.minutes,
    );
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
