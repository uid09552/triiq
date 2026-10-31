import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/data/models/local_wellness.dart';
import 'package:triiq/evaluation/weekly_review.dart';

LocalActivity done(
  String id,
  String date, {
  String type = 'Run',
  int minutes = 60,
  int load = 60,
  List<int>? hrZones,
}) => LocalActivity(
  id: id,
  date: date,
  type: type,
  name: id,
  movingTime: minutes * 60,
  distance: null,
  trainingLoad: load,
  raw: {'icu_hr_zone_times': ?hrZones},
  syncedAt: DateTime(2026, 11, 8),
);

LocalEvent plan(
  String id,
  String date, {
  String type = 'Run',
  int minutes = 60,
  int load = 60,
}) => LocalEvent(
  id: id,
  date: date,
  category: 'WORKOUT',
  type: type,
  name: id,
  description: null,
  plannedLoad: load,
  plannedTime: minutes * 60,
  plannedDistance: null,
  indoor: false,
  raw: const {},
  syncedAt: DateTime(2026, 11, 1),
);

LocalWellness wellness(String date, double ctl, double atl) => LocalWellness(
  date: date,
  ctl: ctl,
  atl: atl,
  ctlLoad: null,
  atlLoad: null,
  rampRate: null,
  raw: const {},
  syncedAt: DateTime(2026, 11, 8),
);

void main() {
  final monday = DateTime(2026, 11, 2);

  test('a missed session lowers compliance', () {
    final r = buildWeeklyReview(
      weekStart: monday,
      activities: [done('a1', '2026-11-03'), done('a2', '2026-11-05')],
      planned: [
        plan('p1', '2026-11-03'),
        plan('p2', '2026-11-05'),
        plan('p3', '2026-11-07'),
        plan('p4', '2026-11-08'),
      ],
      wellness: const [],
      previousWeekLoads: const [],
    );

    expect(r.days, hasLength(7));
    expect(r.plannedSessions, 4);
    expect(r.completedPlanned, 2);
    expect(r.missedSessions, 2);
    expect(r.compliance, 0.5);
    expect(r.days[5].missed.single.id, 'p3');
    expect(r.load, 120);
    expect(r.plannedLoad, 240);
  });

  test('too much moderate time is flagged; missing zones are counted', () {
    final r = buildWeeklyReview(
      weekStart: monday,
      activities: [
        // 5 HR zones: low = Z1+Z2, moderate = Z3+Z4.
        done('a1', '2026-11-03', hrZones: [1000, 1000, 800, 800, 0]),
        done('a2', '2026-11-04', hrZones: [1500, 1500, 300, 300, 0]),
        done('a3', '2026-11-05'),
      ],
      planned: const [],
      wellness: const [],
      previousWeekLoads: const [],
    );

    expect(r.split!.lowShare, closeTo(5000 / 7200, 1e-9));
    expect(r.outside8020, isTrue, reason: '69% easy is below 80% - 5%');
    expect(r.sessionsWithoutZones, 1);
    expect(r.compliance, isNull, reason: 'nothing planned');
  });

  test('load against recent weeks, and the fitness change', () {
    final r = buildWeeklyReview(
      weekStart: monday,
      activities: [done('a1', '2026-11-03', load: 400)],
      planned: const [],
      wellness: [
        wellness('2026-11-01', 50, 55),
        wellness('2026-11-08', 53, 60),
      ],
      previousWeekLoads: const [300, 320, 280, 300],
    );

    expect(r.recentAverageLoad, 300);
    expect(r.loadVsRecent, closeTo(1 / 3, 1e-9));
    expect(r.ctlChange, 3);
    expect(r.atlChange, 5);
    expect(r.formEnd, -7);
  });
}
