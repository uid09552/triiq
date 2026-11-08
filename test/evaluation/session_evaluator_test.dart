import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/evaluation/session_evaluator.dart';

LocalActivity activity({
  String id = 'a1',
  String date = '2026-11-03',
  String type = 'Ride',
  int minutes = 60,
  int? load = 50,
  List<int>? hrZones,
  double? decoupling,
}) => LocalActivity(
  id: id,
  date: date,
  type: type,
  name: 'Ride',
  movingTime: minutes * 60,
  distance: null,
  trainingLoad: load,
  raw: {'icu_hr_zone_times': ?hrZones, 'decoupling': ?decoupling},
  syncedAt: DateTime(2026, 11, 3),
);

LocalEvent planned({
  String id = 'e1',
  String date = '2026-11-03',
  String type = 'Ride',
  String name = 'Z2 endurance',
  int minutes = 60,
  int load = 50,
}) => LocalEvent(
  id: id,
  date: date,
  category: 'WORKOUT',
  type: type,
  name: name,
  description: null,
  plannedLoad: load,
  plannedTime: minutes * 60,
  plannedDistance: null,
  indoor: false,
  raw: const {},
  syncedAt: DateTime(2026, 11, 1),
);

void main() {
  const evaluator = SessionEvaluator();

  // 5 HR zones: low = Z1+Z2, moderate = Z3+Z4, high = Z5.
  List<int> zones(int low, int moderate, int high) => [
    low ~/ 2,
    low - low ~/ 2,
    moderate ~/ 2,
    moderate - moderate ~/ 2,
    high,
  ];

  test('an easy session that drifted is too hard, with its split', () {
    final e = evaluator.evaluate(
      activity(hrZones: zones(2400, 1200, 0)),
      planned: planned(),
    );

    expect(e.intent, SessionIntent.easy);
    expect(e.split!.moderateShare, closeTo(1 / 3, 1e-9));
    expect(e.verdict, Verdict.tooHard);
    final reason = e.reasons.whereType<TooIntenseReason>().single;
    expect(reason.hardShare, closeTo(1 / 3, 1e-9));
    expect(reason.limit, SessionEvaluator.easyHardShareLimit);
  });

  test('45 of 60 planned minutes is cut short', () {
    final e = evaluator.evaluate(
      activity(minutes: 45, hrZones: zones(2700, 0, 0)),
      planned: planned(),
    );

    expect(e.verdict, Verdict.cutShort);
    expect(e.plan!.minutesDelta, -15);
    final r = e.reasons.whereType<ShortReason>().single;
    expect((r.actualMinutes, r.plannedMinutes), (45, 60));
  });

  test('no zone data: no split, nothing estimated', () {
    final e = evaluator.evaluate(activity(), planned: planned());

    expect(e.split, isNull);
    expect(e.reasons.whereType<TooIntenseReason>(), isEmpty);
    expect(e.verdict, Verdict.onTarget, reason: 'duration and load match');
  });

  test('no plan: a split but no verdict', () {
    final e = evaluator.evaluate(activity(hrZones: zones(3000, 600, 0)));

    expect(e.plan, isNull);
    expect(e.verdict, isNull);
    expect(e.split, isNotNull);
  });

  test('an interval session ridden easy is too easy', () {
    final e = evaluator.evaluate(
      activity(load: 40, hrZones: zones(3550, 50, 0)),
      planned: planned(name: 'Threshold intervals', load: 80),
    );

    expect(e.intent, SessionIntent.hard);
    expect(e.verdict, Verdict.tooEasy);
    expect(e.reasons.whereType<NotIntenseReason>(), hasLength(1));
    expect(e.reasons.whereType<LoadReason>(), hasLength(1));
  });

  test('decoupling only on long, steady sessions', () {
    final long = evaluator.evaluate(
      activity(minutes: 120, hrZones: zones(6600, 600, 0), decoupling: 4.2),
    );
    final short = evaluator.evaluate(
      activity(minutes: 40, hrZones: zones(2400, 0, 0), decoupling: 4.2),
    );

    expect(long.decouplingAssessable, isTrue);
    expect(long.decouplingPercent, 4.2);
    expect(short.decouplingAssessable, isFalse);
    expect(short.decouplingPercent, isNull);
  });

  group('matching', () {
    test('none: different day or sport', () {
      final a = activity();
      expect(matchPlanned(a, [planned(date: '2026-11-04')]), isNull);
      expect(matchPlanned(a, [planned(type: 'Run')]), isNull);
    });

    test('one: a VirtualRide matches a planned Ride', () {
      final p = planned();
      expect(matchPlanned(activity(type: 'VirtualRide'), [p]), same(p));
    });

    test('several: nearest in duration, one-to-one', () {
      final short = planned(id: 's', minutes: 45);
      final long = planned(id: 'l', minutes: 150);
      final a90 = activity(id: 'a90', minutes: 140);
      final a50 = activity(id: 'a50', minutes: 50);

      expect(matchPlanned(a90, [short, long]), same(long));
      final all = matchAll([a50, a90], [short, long]);
      expect(all['a90'], same(long));
      expect(all['a50'], same(short));

      final greedy = matchAll([a90, activity(id: 'x', minutes: 140)], [long]);
      expect(greedy, hasLength(1), reason: 'a plan is used once');
    });
  });
}
