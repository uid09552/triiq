import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/evaluation/session_streams.dart';
import 'package:triiq/season/brick_analysis.dart';

LocalActivity act(
  String id,
  String type,
  String start,
  int seconds, {
  double? intensity,
}) => LocalActivity(
  id: id, date: start.substring(0, 10), type: type, name: id,
  movingTime: seconds, distance: null, trainingLoad: null,
  raw: {
    'start_date_local': start,
    'elapsed_time': seconds,
    if (intensity != null) 'icu_intensity': intensity,
  },
  syncedAt: DateTime(2026),
);

SessionStreams run({
  required double earlySpeed,
  double steady = 3.3,
  int settleAt = 0,
  double earlyHr = 150,
  double hr = 150,
}) {
  final time = <double?>[];
  final speed = <double?>[];
  final heart = <double?>[];
  for (var t = 0; t <= 1800; t += 5) {
    time.add(t.toDouble());
    // Linear ramp from earlySpeed to steady over [settleAt] seconds.
    final v = t >= settleAt || settleAt == 0
        ? (t < 600 && settleAt == 0 ? earlySpeed : steady)
        : earlySpeed + (steady - earlySpeed) * t / settleAt;
    speed.add(v);
    heart.add(t < 600 ? earlyHr : hr);
  }
  return SessionStreams(
    series: {'time': time, 'velocity_smooth': speed, 'heartrate': heart},
  );
}

void main() {
  final bike = act('b', 'Ride', '2026-05-10T08:00:00', 3600, intensity: 70);
  final runA = act('r', 'Run', '2026-05-10T09:04:00', 1800); // 4 min gap

  test('finds bike→run and swim→bike, not unrelated pairs', () {
    final swim = act('s', 'Swim', '2026-05-12T07:00:00', 1800);
    final ride = act('rd', 'VirtualRide', '2026-05-12T07:40:00', 3600); // 10 min
    final lateRun = act('l', 'Run', '2026-05-10T14:00:00', 1800);
    final bricks = findBricks([bike, runA, swim, ride, lateRun]);
    expect(bricks.map((b) => b.kind), [BrickKind.bikeRun, BrickKind.swimBike]);
    expect(brickFor(runA, [bike, runA])!.first.id, 'b');
    expect(brickFor(lateRun, [bike, lateRun]), isNull);
  });

  test('a fast-settling run is good, with a quick transition', () {
    final a = analyseBrick(
      findBricks([bike, runA]).single,
      run(earlySpeed: 3.2, settleAt: 0),
    );
    expect(a.transitionSeconds, 240);
    expect(a.verdict, BrickVerdict.good);
    expect(a.notes, containsAll([BrickNote.quickTransition, BrickNote.settledFast]));
    expect(a.settleSeconds, lessThanOrEqualTo(180));
  });

  test('a slow, costly start is rough and blames a hard bike', () {
    final hardBike = act('b', 'Ride', '2026-05-10T08:00:00', 3600, intensity: 92);
    final a = analyseBrick(
      findBricks([hardBike, runA]).single,
      run(earlySpeed: 2.5, settleAt: 600, earlyHr: 165),
    );
    expect(a.verdict, BrickVerdict.rough);
    expect(a.earlySpeedRatio, lessThan(0.9));
    expect(a.notes, containsAll([
      BrickNote.settledSlow, BrickNote.slowStart,
      BrickNote.highEarlyCost, BrickNote.hardFirstLeg,
    ]));
  });

  test('no stream: only the transition is judged', () {
    final slow = act('r', 'Run', '2026-05-10T09:20:00', 1800); // 20 min gap
    final a = analyseBrick(findBricks([bike, slow]).single, null);
    expect(a.verdict, BrickVerdict.unknown);
    expect(a.notes, containsAll([BrickNote.longTransition, BrickNote.noStream]));
  });

  test('medians of settle and transition', () {
    final good = analyseBrick(findBricks([bike, runA]).single, run(earlySpeed: 3.2));
    final m = medians([good, good]);
    expect(m.transition, 240);
    expect(m.settle, isNotNull);
  });
}
