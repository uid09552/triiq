import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/data/models/local_wellness.dart';
import 'package:triiq/evaluation/readiness.dart';
import 'package:triiq/evaluation/wellness_baseline.dart';
import 'package:triiq/evaluation/weekly_review.dart';
import 'package:triiq/evaluation/weekly_review_summary.dart';
import 'package:triiq/plan/plan_models.dart';
import 'package:triiq/util/dates.dart';

LocalActivity done(
  String id,
  String date, {
  String type = 'Run',
  int load = 60,
}) => LocalActivity(
  id: id,
  date: date,
  type: type,
  name: id,
  movingTime: 3600,
  distance: null,
  trainingLoad: load,
  raw: const {},
  syncedAt: DateTime(2026, 11, 8),
);

LocalEvent plan(
  String id,
  String date, {
  String type = 'Run',
  int load = 60,
  String? slot,
  String category = 'WORKOUT',
}) => LocalEvent(
  id: id,
  date: date,
  category: category,
  type: type,
  name: id,
  description: null,
  plannedLoad: load,
  plannedTime: 3600,
  plannedDistance: null,
  indoor: false,
  raw: {LocalEvent.planSlotKey: ?slot},
  syncedAt: DateTime(2026, 11, 1),
);

LocalWellness well(String date, double ctl, double atl, {num? hrv, num? rhr}) =>
    LocalWellness(
      date: date,
      ctl: ctl,
      atl: atl,
      ctlLoad: null,
      atlLoad: null,
      rampRate: null,
      raw: {'hrv': ?hrv, 'restingHR': ?rhr},
      syncedAt: DateTime(2026, 11, 8),
    );

PlanWeek week(DateTime start, String phase, double target) => PlanWeek(
  index: 0,
  phase: phase,
  startDate: start,
  targetLoad: target,
  requestedLoad: target,
  limit: WeekLimit.none,
  projectedCtlEnd: null,
  sessions: const [],
  lowIntensityTarget: 0.8,
  lowIntensityTolerance: 0.05,
);

Readiness rated(ReadinessLevel l) => Readiness(
  level: l,
  signals: const [],
  dataState: ReadinessDataState.complete,
);

void main() {
  final monday = DateTime(2026, 11, 2);
  String d(int offset) =>
      isoDate(DateTime(monday.year, monday.month, monday.day + offset));

  WeeklyReview review(
    List<LocalActivity> activities,
    List<LocalEvent> planned, [
    List<LocalWellness> wellness = const [],
  ]) => buildWeeklyReview(
    weekStart: monday,
    activities: activities,
    planned: planned,
    wellness: wellness,
    previousWeekLoads: const [],
  );

  test('full week: load vs plan target, sports, key session, ramp, readiness, '
      'next week', () {
    final activities = [
      done('a1', d(0), load: 80),
      done('a2', d(2), type: 'Ride', load: 150),
      done('a3', d(5), load: 120),
    ];
    final planned = [
      plan('Easy', d(0), load: 70),
      plan('Long ride', d(2), type: 'Ride', load: 160, slot: 'long'),
      plan('Intervals', d(4), load: 90, slot: 'intervals'),
      plan('Long run', d(5), load: 130),
    ];
    // CTL flat for four weeks, then +9 in the reviewed week.
    final wellness = [
      for (var w = 5; w >= 1; w--)
        well(
          isoDate(DateTime(monday.year, monday.month, monday.day - 7 * w + 6)),
          50,
          50,
        ),
      well(d(6), 59, 70),
    ];
    final s = buildWeeklyReviewSummary(
      review: review(activities, planned, wellness),
      asOf: DateTime(2026, 11, 8, 19),
      activities: activities.length,
      sportSeconds: const {'run': 7200, 'cycle': 3600},
      sportTargets: const {'run': 4 * 3600, 'swim': 3600},
      planWeek: week(monday, 'build', 450),
      nextPlanWeek: week(DateTime(2026, 11, 9), 'recovery', 300),
      nextPlanned: [
        plan('Easy', '2026-11-10', load: 40),
        plan('Tempo', '2026-11-11', load: 80, slot: 'intervals'),
        plan('Long', '2026-11-14', load: 100, slot: 'long'),
        plan('City 10k', '2026-11-15', category: 'RACE_B'),
      ],
      readiness: [
        rated(ReadinessLevel.ready),
        rated(ReadinessLevel.ready),
        rated(ReadinessLevel.caution),
        rated(ReadinessLevel.backOff),
        Readiness(
          level: ReadinessLevel.ready,
          signals: const [],
          dataState: ReadinessDataState.waitingForToday,
        ),
      ],
      wellness: wellness,
    );
    expect(s.hasData, isTrue);
    expect(s.load, 350);
    expect(s.targetLoad, 450);
    expect(s.phase, 'build');
    expect(s.sports.map((p) => p.sport), ['swim', 'run']);
    expect(s.sports.last.seconds, 7200);
    expect(s.plannedSessions, 4);
    expect(s.completedSessions, 3);
    expect(s.missedSessions, 1);
    // Interval and long slots outrank unslotted sessions; among them the
    // most load wins.
    expect(s.keySession!.name, 'Long ride');
    expect(s.keySession!.hit, isTrue);
    expect(s.ctlChange, 9);
    expect(s.formEnd, -11);
    expect(s.usualCtlChange, 0);
    expect(s.rampHigh, isTrue);
    expect((s.readyDays, s.cautionDays, s.backOffDays), (2, 1, 1));
    expect(s.next.targetLoad, 300);
    expect(s.next.phase, 'recovery');
    expect(s.next.keySessions.map((k) => k.name), ['Tempo', 'Long']);
    expect(s.next.events.single.name, 'City 10k');
    final json = s.toJson();
    expect(json['ramp_above_usual'], isTrue);
    expect(json['next_week']['races'], hasLength(1));
  });

  test('partial week: later sessions are not missed yet', () {
    final planned = [
      plan('Mon', d(0)),
      plan('Thu', d(3), slot: 'intervals'),
      plan('Sat', d(5)),
    ];
    final s = buildWeeklyReviewSummary(
      review: review([done('a1', d(0))], planned),
      asOf: DateTime(2026, 11, 4, 12), // Wednesday
      activities: 1,
      sportSeconds: const {},
    );
    expect(s.completedSessions, 1);
    expect(s.missedSessions, 0);
    expect(s.keySession!.name, 'Thu');
    expect(s.keySession!.hit, isFalse);
  });

  test('no plan: target is the planned total, or null without one', () {
    final s = buildWeeklyReviewSummary(
      review: review([done('a1', d(1), load: 70)], const []),
      asOf: DateTime(2026, 11, 8, 19),
      activities: 1,
      sportSeconds: const {},
    );
    expect(s.hasData, isTrue);
    expect(s.targetLoad, isNull);
    expect(s.keySession, isNull);
    expect(s.next.isEmpty, isTrue);
    expect(s.toJson().containsKey('next_week'), isFalse);

    final planned = buildWeeklyReviewSummary(
      review: review(const [], [plan('Run', d(1), load: 55)]),
      asOf: DateTime(2026, 11, 8, 19),
      activities: 0,
      sportSeconds: const {},
    );
    expect(planned.targetLoad, 55);
  });

  test('no data: nothing to send', () {
    final s = buildWeeklyReviewSummary(
      review: review(const [], const []),
      asOf: DateTime(2026, 11, 8, 19),
      activities: 0,
      sportSeconds: const {},
    );
    expect(s.hasData, isFalse);
    expect(s.rampHigh, isFalse);
  });

  test('HRV and resting HR direction against the baseline', () {
    final records = [
      for (var i = 40; i >= 1; i--)
        well(
          isoDate(DateTime(monday.year, monday.month, monday.day - i)),
          50,
          50,
          hrv: 60 + (i.isEven ? 2 : -2),
          rhr: 50,
        ),
      for (var i = 0; i < 7; i++) well(d(i), 50, 50, hrv: 75, rhr: 50),
    ];
    expect(
      signalTrend(records, WellnessSignal.hrv, monday, DateTime(2026, 11, 8)),
      TrendDirection.up,
    );
    expect(
      signalTrend(
        records,
        WellnessSignal.restingHr,
        monday,
        DateTime(2026, 11, 8),
      ),
      TrendDirection.stable,
    );
  });
}
