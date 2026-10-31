import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/plan/knowledge.dart';
import 'package:triiq/plan/plan_engine.dart';
import 'package:triiq/plan/plan_models.dart';

void main() {
  final knowledge = TrainingKnowledge.parse(
    File('docs/okf.md').readAsStringSync(),
  );
  final engine = PlanEngine(knowledge);

  // Tue / Thu / Sat plus Sunday off.
  Goal goal({
    String type = 'long_distance',
    Set<int> days = const {2, 4, 6},
    double hours = 12,
    String sport = 'Run',
    double? baseline,
    double? maxIncrease,
    double? maxRamp,
    int? weeks,
    List<double> factors = const [],
    Map<String, int> mix = Goal.defaultSportMix,
  }) => Goal(
    targetType: type,
    weekdays: days,
    weeklyHours: hours,
    sport: sport,
    baselineWeeklyLoad: baseline,
    maxWeeklyIncrease: maxIncrease,
    maxCtlRamp: maxRamp,
    weeks: weeks,
    loadFactors: factors,
    sportMix: mix,
  );

  final monday = DateTime(2026, 8, 31);
  final today = DateTime(2026, 8, 26);
  const history = [300.0, 320.0, 280.0, 300.0];

  TrainingPlan plan(Goal g, {List<double>? loads = history, double? ctl}) {
    final result = engine.generate(
      goal: g,
      startDate: monday,
      recentWeeklyLoads: loads,
      currentCtl: ctl,
      today: today,
    );
    expect(result.failure?.message, isNull);
    return result.plan!;
  }

  group('block shape', () {
    test('defaults to eight build weeks starting on the Monday', () {
      final p = plan(goal());

      expect(p.weeks, hasLength(8));
      expect(p.weeks.every((w) => w.phase == 'build'), isTrue);
      expect(p.startDate, monday);
      expect(p.weeks[1].startDate, DateTime(2026, 9, 7));
    });

    test('the athlete picks the number of weeks', () {
      expect(plan(goal(weeks: 4)).weeks, hasLength(4));
      expect(plan(goal(weeks: 16, hours: 40)).weeks, hasLength(16));
    });

    test('an event date sets the default length', () {
      final p = plan(
        goal().copyWith(eventDate: DateTime(2026, 11, 9)),
      );
      expect(p.weeks, hasLength(10));
    });

    test('baseline is the mean of the last four weeks', () {
      final p = plan(goal(hours: 40));

      expect(p.baselineLoad, 300);
      expect(p.weeks[0].requestedLoad, closeTo(330, 0.01));
    });

    test('the proposal ramps 10% a week and holds every 4th week', () {
      final q =plan(goal(baseline: 300, hours: 40, weeks: 4), loads: null);
      expect(q.weeks.map((w) => w.requestedLoad.round()), [330, 363, 399, 399]);
      expect(q.weeks.every((w) => w.factor == 1.0), isTrue);
      expect(q.weeks.every((w) => w.warnings.isEmpty), isTrue);
    });

    test('eight weeks hold weeks 4 and 8; the hold can be turned off', () {
      final on = plan(goal(baseline: 300, hours: 60, weeks: 8), loads: null);
      expect(on.weeks.map((w) => w.requestedLoad.round()), [
        330, 363, 399, 399, 439, 483, 531, 531,
      ]);
      expect(on.weeks[3].phase, 'build', reason: 'a hold is not a recovery');

      final off = plan(
        goal(baseline: 300, hours: 60, weeks: 4).copyWith(holdEvery4th: false),
        loads: null,
      );
      expect(off.weeks.map((w) => w.requestedLoad.round()), [330, 363, 399, 439]);
    });

    test('every build week has the same session types', () {
      final p = plan(goal(days: {1, 2, 4, 6}));

      for (final week in p.weeks) {
        expect(week.sessions.map((s) => s.slot).toList()..sort(
          (a, b) => a.index.compareTo(b.index),
        ), [
          SessionSlot.z2,
          SessionSlot.z2,
          SessionSlot.intervals,
          SessionSlot.long,
        ]);
      }
    });

    test('the long session is the longest of every week (long distance)', () {
      final p = plan(goal(days: {1, 2, 4, 6}));

      for (final week in p.weeks) {
        final longest = week.sessions.reduce(
          (a, b) => a.minutes >= b.minutes ? a : b,
        );
        expect(longest.slot, SessionSlot.long, reason: 'week ${week.index}');
      }
    });
  });

  group('load curve', () {
    test('a factor scales the week and keeps the proposal', () {
      final p = plan(
        goal(baseline: 300, hours: 40, weeks: 4, factors: [1, 1, 1, 0.8]),
        loads: null,
      );

      expect(p.weeks[3].requestedLoad, closeTo(399.3, 0.01), reason: 'hold');
      expect(p.weeks[3].targetLoad, closeTo(399.3 * 0.8, 0.01));
      expect(p.weeks[3].factor, 0.8);
    });

    test('a manual dip becomes a recovery week with a shorter long session',
        () {
      final p = plan(
        goal(
          baseline: 300,
          hours: 40,
          weeks: 4,
          days: {1, 2, 4, 6},
          factors: [1, 1, 1.1, 0.8],
        ),
        loads: null,
      );
      int longMinutes(PlanWeek w) =>
          w.sessions.firstWhere((s) => s.slot == SessionSlot.long).minutes;

      expect(p.weeks.map((w) => w.phase), [
        'build',
        'build',
        'build',
        'recovery',
      ]);
      expect(
        p.weeks[3].sessions.firstWhere((s) => s.slot == SessionSlot.intervals)
            .templateId,
        'long_distance.intervals.recovery',
      );
      expect(longMinutes(p.weeks[3]), lessThan(longMinutes(p.weeks[2])));
    });

    test('raising a week above the ramp cap warns but keeps the target', () {
      final p = plan(
        goal(baseline: 300, hours: 40, weeks: 4, factors: [1, 1, 1.2]),
        loads: null,
      );

      expect(p.weeks[2].warnings, {WeekLimit.weeklyIncrease});
      expect(p.weeks[2].targetLoad, closeTo(399.3 * 1.2, 0.01));
      expect(p.weeks[1].warnings, isEmpty);
    });

    test('coming back after a recovery week is not a ramp jump', () {
      final p = plan(
        goal(baseline: 300, hours: 40, weeks: 4, factors: [1, 0.8, 1, 1]),
        loads: null,
      );

      expect(p.weeks[1].phase, 'recovery');
      // Week 3 back at its proposal is not a jump, though it is 21% over
      // week 1 (the proposal kept ramping during the dip).
      expect(p.weeks[2].warnings, isEmpty);
    });
  });

  group('goal mix', () {
    test('long distance has relatively longer long runs and less intervals '
        'than a short event with the same load', () {
      final long = plan(goal(days: {1, 2, 4, 6}, baseline: 250));
      final short = plan(
        goal(type: 'short_event', days: {1, 2, 4, 6}, baseline: 250),
      );
      int minutes(TrainingPlan p, SessionSlot slot) => p.weeks[0].sessions
          .where((s) => s.slot == slot)
          .fold(0, (a, s) => a + s.minutes);

      expect(
        minutes(long, SessionSlot.long),
        greaterThan(minutes(short, SessionSlot.long)),
      );
      expect(
        minutes(long, SessionSlot.intervals),
        lessThan(minutes(short, SessionSlot.intervals)),
      );
    });
  });

  group('history', () {
    test('too little history asks for a baseline instead of inventing one', () {
      final result = engine.generate(
        goal: goal(),
        startDate: monday,
        recentWeeklyLoads: const [300, 310],
        today: today,
      );

      expect(result.plan, isNull);
      expect(result.failure!.kind, PlanFailureKind.needsBaseline);
    });

    test('a manual baseline replaces missing history', () {
      final p = plan(goal(baseline: 250), loads: null);

      expect(p.baselineLoad, 250);
    });

    test('an all-zero history is not a baseline', () {
      final result = engine.generate(
        goal: goal(),
        startDate: monday,
        recentWeeklyLoads: const [0, 0, 0, 0],
        today: today,
      );

      expect(result.failure!.kind, PlanFailureKind.needsBaseline);
    });
  });

  group('limits', () {
    test('the CTL ramp cap holds the proposal down and says so', () {
      // CTL 40 and a 330-TSS week (~47/day) would gain about 1 CTL; a
      // limit of 0.1 must hold it back.
      final p = plan(goal(maxRamp: 0.1, hours: 40), ctl: 40);

      expect(p.weeks[0].limit, WeekLimit.ctlRamp);
      expect(p.weeks[0].targetLoad, lessThan(300));
      expect(p.weeks[0].projectedCtlEnd! - 40, lessThanOrEqualTo(0.1 + 0.3));
    });

    test('the hours budget holds later weeks at the budget', () {
      final p = plan(
        goal(hours: 5, days: {1, 2, 4, 6}).copyWith(holdEvery4th: false),
      );

      for (final week in p.weeks) {
        expect(week.totalMinutes / 60, lessThanOrEqualTo(5.5));
      }
      expect(p.weeks.last.limit, WeekLimit.hours);
      expect(
        p.weeks.last.requestedLoad,
        closeTo(p.weeks[p.weeks.length - 2].requestedLoad, 0.01),
      );
    });

    test('a steady ramp within budget reports no limit', () {
      final p = plan(goal(hours: 40, weeks: 4));

      expect(p.weeks.every((w) => w.limit == WeekLimit.none), isTrue);
    });
  });

  group('80/20', () {
    test('a standard week is within tolerance and not flagged', () {
      final p = plan(goal(days: {1, 2, 4, 6}));

      for (final week in p.weeks) {
        expect(week.outsideTolerance, isFalse, reason: 'week ${week.index}');
        expect(week.lowShare, closeTo(0.8, 0.1));
      }
    });

    test('a week with too much intensity is flagged', () {
      final week = plan(goal(days: {1, 2, 4, 6})).weeks[0];
      final hard = week.withSessions([
        for (final s in week.sessions)
          PlanSession(
            weekIndex: s.weekIndex,
            date: s.date,
            slot: s.slot,
            templateId: s.templateId,
            name: s.name,
            sport: s.sport,
            minutes: s.minutes,
            load: s.load,
            lowMinutes: s.minutes * 0.5,
            description: s.description,
          ),
      ]);

      expect(hard.lowShare, closeTo(0.5, 0.001));
      expect(hard.outsideTolerance, isTrue);
    });
  });

  group('days', () {
    test('three days: long on the last, intervals first, one session each', () {
      final week = plan(goal()).weeks[0]; // Tue, Thu, Sat

      expect(week.sessions.map((s) => s.slot), [
        SessionSlot.intervals,
        SessionSlot.z2,
        SessionSlot.long,
      ]);
      expect(week.sessions.map((s) => s.date.weekday), [2, 4, 6]);
    });

    test('hard days are not back to back when avoidable', () {
      final week = plan(goal(days: {1, 2, 3, 4, 5, 6, 7})).weeks[0];
      final long = week.sessions.firstWhere((s) => s.slot == SessionSlot.long);
      final intervals = week.sessions.firstWhere(
        (s) => s.slot == SessionSlot.intervals,
      );
      final gap = (long.date.weekday - intervals.date.weekday).abs();

      expect(gap > 1 && gap < 6, isTrue, reason: 'gap $gap');
    });

    test('sessions land on the chosen weekdays', () {
      final week = plan(goal(days: {1, 3, 5, 7})).weeks[1];

      for (final s in week.sessions) {
        expect({1, 3, 5, 7}, contains(s.date.weekday));
      }
      expect(week.sessions.map((s) => s.date).toSet().length, 4);
    });
  });

  group('steps', () {
    test('run sessions use pace targets in Intervals.icu syntax', () {
      final week = plan(goal(days: {1, 2, 4, 6})).weeks[0];
      final intervals = week.sessions.firstWhere(
        (s) => s.slot == SessionSlot.intervals,
      );

      expect(intervals.description, contains('- 15m 75% Pace'));
      expect(intervals.description, matches(RegExp(r'\d+x\n  - 8m 95% Pace')));
    });

    test('ride sessions use plain % of FTP', () {
      final week = plan(goal(sport: 'Ride', days: {1, 2, 4, 6})).weeks[0];

      for (final s in week.sessions) {
        expect(s.description, isNot(contains('Pace')));
        expect(s.description, contains('%'));
      }
    });

    test('minutes add up to what the steps describe', () {
      final week = plan(goal(days: {1, 2, 4, 6})).weeks[0];

      for (final s in week.sessions) {
        var total = 0;
        final lines = s.description.split('\n');
        var repeats = 1;
        var inRepeat = false;
        for (final line in lines) {
          final reps = RegExp(r'^(\d+)x$').firstMatch(line);
          if (reps != null) {
            repeats = int.parse(reps.group(1)!);
            inRepeat = true;
            continue;
          }
          final m = RegExp(r'^\s*- (\d+)m').firstMatch(line)!;
          final minutes = int.parse(m.group(1)!);
          if (line.startsWith('  ') && inRepeat) {
            total += minutes * repeats;
          } else {
            inRepeat = false;
            total += minutes;
          }
        }
        expect(total, s.minutes, reason: s.name);
      }
    });
  });

  group('validation', () {
    test('fewer than three days is rejected', () {
      final result = engine.generate(
        goal: goal(days: {2, 6}),
        startDate: monday,
        recentWeeklyLoads: history,
        today: today,
      );

      expect(result.failure!.kind, PlanFailureKind.invalidGoal);
    });

    test('a past event date is rejected', () {
      final result = engine.generate(
        goal: goal().copyWith(eventDate: DateTime(2026, 8, 1)),
        startDate: monday,
        recentWeeklyLoads: history,
        today: today,
      );

      expect(result.failure!.message, contains('past'));
    });

    test('an unknown goal names itself', () {
      final result = engine.generate(
        goal: goal(type: 'triathlon'),
        startDate: monday,
        recentWeeklyLoads: history,
        today: today,
      );

      expect(result.failure!.message, contains('triathlon'));
    });
  });

  test('goal survives a JSON round trip', () {
    final g = goal(baseline: 250, maxIncrease: 0.1).copyWith(
      eventDate: DateTime(2026, 11, 1),
    );

    final back = Goal.fromJson(g.toJson());

    expect(back.targetType, g.targetType);
    expect(back.weekdays, g.weekdays);
    expect(back.weeklyHours, g.weeklyHours);
    expect(back.baselineWeeklyLoad, 250);
    expect(back.maxWeeklyIncrease, 0.1);
    expect(back.eventDate, DateTime(2026, 11, 1));
  });

  test('new goal fields survive a JSON round trip', () {
    final g = goal(
      sport: Goal.triathlon,
      weeks: 12,
      factors: [1, 0.85, 1.2],
      mix: {'Swim': 10, 'Ride': 55, 'Run': 35},
    );

    final back = Goal.fromJson(g.toJson());

    expect(back.weeks, 12);
    expect(back.loadFactors, [1, 0.85, 1.2]);
    expect(back.sportMix, {'Swim': 10, 'Ride': 55, 'Run': 35});
  });

  test('a goal saved before the load curve loads with defaults', () {
    final back = Goal.fromJson({
      'targetType': 'long_distance',
      'weekdays': [2, 4, 6],
      'weeklyHours': 6,
      'sport': 'Run',
    });

    expect(back.weeks, isNull);
    expect(back.planWeeks(monday), Goal.defaultWeeks);
    expect(back.loadFactors, isEmpty);
    expect(back.sportMix, Goal.defaultSportMix);
    expect(back.validate(today: today), isNull);
  });

  group('goal validation', () {
    test('weeks outside 2-16 are rejected', () {
      expect(goal(weeks: 20).validate(today: today), contains('2 to 16'));
      expect(goal(weeks: 1).validate(today: today), isNotNull);
      expect(goal(weeks: 16).validate(today: today), isNull);
    });

    test('a triathlon mix must total 100% in 5% steps', () {
      expect(
        goal(
          sport: Goal.triathlon,
          mix: {'Swim': 20, 'Ride': 50, 'Run': 35},
        ).validate(today: today),
        contains('105%'),
      );
      expect(
        goal(
          sport: Goal.triathlon,
          mix: {'Swim': 12, 'Ride': 53, 'Run': 35},
        ).validate(today: today),
        contains('5%'),
      );
      expect(goal(sport: Goal.triathlon).validate(today: today), isNull);
    });

    test('a factor outside 80-120% is rejected', () {
      expect(goal(factors: [1.3]).validate(today: today), isNotNull);
    });
  });

  group('triathlon', () {
    Goal tri({
      Set<int> days = const {1, 2, 3, 4, 5, 6, 7},
      Map<String, int> mix = Goal.defaultSportMix,
      String type = 'long_distance',
    }) => goal(
      type: type,
      sport: Goal.triathlon,
      days: days,
      hours: 40,
      baseline: 400 / 1.1,
      weeks: 4,
      mix: mix,
    );

    test('splits the week load by the sport mix', () {
      final week = plan(tri(), loads: null).weeks[0];
      final bySport = week.loadBySport;
      final total = week.plannedLoad;

      expect(week.targetLoad, closeTo(400, 0.01));
      expect(bySport.keys.toSet(), {'Swim', 'Ride', 'Run'});
      expect(bySport['Swim']! / total, closeTo(0.15, 0.05));
      expect(bySport['Ride']! / total, closeTo(0.50, 0.05));
      expect(bySport['Run']! / total, closeTo(0.35, 0.05));
    });

    test('a sport at 0% gets no sessions', () {
      final p = plan(tri(mix: {'Swim': 0, 'Ride': 60, 'Run': 40}), loads: null);

      expect(p.sessions.where((s) => s.sport == 'Swim'), isEmpty);
    });

    test('swim uses swim templates and pace targets, no long swim', () {
      final p = plan(tri(), loads: null);
      final swims = p.weeks[0].sessions.where((s) => s.sport == 'Swim');

      expect(swims.map((s) => s.slot).toSet(), {
        SessionSlot.z2,
        SessionSlot.intervals,
      });
      for (final s in swims) {
        expect(s.templateId, contains('.swim.'));
        expect(s.description, contains('% Pace'));
      }
    });

    test('at most two a day and the long ride and run on different days', () {
      for (final days in [
        {1, 3, 6},
        {2, 4, 6, 7},
        {1, 2, 3, 4, 5},
        {1, 2, 3, 4, 5, 6, 7},
      ]) {
        final p = plan(tri(days: days), loads: null);
        for (final week in p.weeks) {
          final perDay = <int, int>{};
          for (final s in week.sessions) {
            expect(days, contains(s.date.weekday));
            perDay[s.date.weekday] = (perDay[s.date.weekday] ?? 0) + 1;
          }
          expect(perDay.values.every((n) => n <= 2), isTrue, reason: '$days');
          final longs = week.sessions
              .where((s) => s.slot == SessionSlot.long)
              .map((s) => s.date)
              .toList();
          expect(longs, hasLength(2));
          expect(longs.toSet(), hasLength(2), reason: '$days');
        }
      }
    });

    test('three days drop Z2 sessions before anything else', () {
      final week = plan(tri(days: {1, 3, 6}), loads: null).weeks[0];

      expect(week.sessions, hasLength(6));
      for (final sport in ['Ride', 'Run']) {
        final slots = week.sessions
            .where((s) => s.sport == sport)
            .map((s) => s.slot)
            .toSet();
        expect(slots, containsAll([SessionSlot.intervals, SessionSlot.long]));
      }
      expect(week.sessions.where((s) => s.sport == 'Swim'), isNotEmpty);
    });

    test('a missing swim template fails the whole plan', () {
      final noSwim = TrainingKnowledge(
        rules: knowledge.rules,
        goals: knowledge.goals,
        templates: [
          for (final t in knowledge.templates)
            if (!t.sports.contains('Swim')) t,
        ],
      );
      final result = PlanEngine(noSwim).generate(
        goal: tri(),
        startDate: monday,
        recentWeeklyLoads: null,
        today: today,
      );

      expect(result.plan, isNull);
      expect(result.failure!.kind, PlanFailureKind.missingTemplate);
      expect(result.failure!.message, contains('swim'));
    });
  });

  group('session mix', () {
    test('athlete shares drive each slot\'s load', () {
      final g = goal(
        baseline: 200 / 1.1,
        hours: 40,
        weeks: 2,
        days: {1, 2, 4, 6},
      ).copyWith(slotShares: {'z2': 20, 'intervals': 50, 'long': 30});
      final week = plan(g, loads: null).weeks[0];
      int load(SessionSlot slot) => week.sessions
          .where((s) => s.slot == slot)
          .fold(0, (a, s) => a + s.load);

      expect(week.targetLoad, closeTo(200, 0.01));
      final standard = plan(
        goal(baseline: 200 / 1.1, hours: 40, weeks: 2, days: {1, 2, 4, 6}),
        loads: null,
      ).weeks[0];
      final standardIntervals = standard.sessions
          .where((s) => s.slot == SessionSlot.intervals)
          .fold(0, (a, s) => a + s.load);
      // More intervals than the template's 30%, up to what its repeats allow.
      expect(load(SessionSlot.intervals), greaterThan(standardIntervals));
      expect(load(SessionSlot.z2), lessThan(standard.sessions
          .where((s) => s.slot == SessionSlot.z2)
          .fold<int>(0, (a, s) => a + s.load)));
      // More intensity means less easy time.
      expect(week.lowShare!, lessThan(standard.lowShare!));
    });

    test('a slot at 0% gets no sessions; swim keeps sessions on all-long', () {
      final run = plan(
        goal(hours: 40, weeks: 2).copyWith(
          slotShares: {'z2': 0, 'intervals': 40, 'long': 60},
        ),
      ).weeks[0];
      expect(run.sessions.where((s) => s.slot == SessionSlot.z2), isEmpty);

      final tri = plan(
        goal(
          sport: Goal.triathlon,
          days: {1, 2, 3, 4, 5, 6},
          hours: 40,
          weeks: 2,
          baseline: 400,
        ).copyWith(slotShares: {'z2': 0, 'intervals': 0, 'long': 100}),
        loads: null,
      ).weeks[0];
      expect(tri.sessions.where((s) => s.sport == 'Swim'), isNotEmpty);
    });

    test('without a custom mix nothing changes', () {
      final a = plan(goal(days: {1, 2, 4, 6}));
      final b = plan(goal(days: {1, 2, 4, 6}).copyWith(clearSlotShares: true));
      expect(
        a.sessions.map((s) => s.load).toList(),
        b.sessions.map((s) => s.load).toList(),
      );
    });
  });

  group('preferences', () {
    Goal tri(Set<int> days) => goal(
      sport: Goal.triathlon,
      days: days,
      hours: 40,
      weeks: 2,
      baseline: 400,
    );

    test('long ride Saturday, long run Sunday', () {
      final p = plan(
        tri({1, 2, 3, 4, 5, 6, 7}).copyWith(longDays: {'Ride': 6, 'Run': 7}),
        loads: null,
      );
      for (final week in p.weeks) {
        DateTime longOf(String sport) => week.sessions
            .firstWhere((s) => s.sport == sport && s.slot == SessionSlot.long)
            .date;
        expect(longOf('Ride').weekday, DateTime.saturday);
        expect(longOf('Run').weekday, DateTime.sunday);
        expect(week.notes, isEmpty);
      }
    });

    test('Tuesday intervals for a single sport', () {
      final p = plan(
        goal(days: {2, 4, 6}, hours: 40).copyWith(intervalDays: {2}),
      );
      for (final week in p.weeks) {
        final intervals = week.sessions.firstWhere(
          (s) => s.slot == SessionSlot.intervals,
        );
        expect(intervals.date.weekday, DateTime.tuesday);
        expect(
          week.sessions.map((s) => s.date.weekday).toSet(),
          hasLength(week.sessions.length),
          reason: 'still one session a day',
        );
      }
    });

    test('a preference the week can\'t meet becomes a note', () {
      // Intervals preferred on the long run's day: never on one day.
      final p = plan(
        goal(days: {2, 4, 6}, hours: 40).copyWith(
          longDays: {'Run': 2},
          intervalDays: {2},
        ),
      );
      final week = p.weeks.first;
      expect(
        week.sessions.firstWhere((s) => s.slot == SessionSlot.long).date.weekday,
        DateTime.tuesday,
      );
      expect(week.notes, contains(PlanEngine.noteIntervalDay));
    });

    test('one session a day for triathlon: fits 5 days, not 4', () {
      final five = plan(
        tri({1, 2, 3, 4, 6}).copyWith(maxSessionsPerDay: 1),
        loads: null,
      ).weeks.first;
      expect(
        five.sessions.map((s) => s.date.weekday).toSet(),
        hasLength(five.sessions.length),
      );

      final four = engine.generate(
        goal: tri({1, 2, 4, 6}).copyWith(maxSessionsPerDay: 1),
        startDate: monday,
        recentWeeklyLoads: null,
        today: today,
      );
      expect(four.failure!.kind, PlanFailureKind.notEnoughDays);
      expect(four.failure!.message, contains('at most 1 a day'));
    });
  });
}
