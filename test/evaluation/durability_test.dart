import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/evaluation/durability.dart';
import 'package:triiq/evaluation/performance_curves.dart';
import 'package:triiq/evaluation/session_streams.dart';
import 'package:triiq/evaluation/training_analytics.dart';
import 'package:triiq/util/dates.dart';

/// A ride at [watts] for [secs] seconds, then it drops to [lateWatts].
List<double> _ride(int secs, double watts) => List<double>.filled(secs, watts);

void main() {
  group('perSecond', () {
    test('places samples on their second and zero-fills gaps', () {
      final s = perSecond([0, 1, 2, 5], [100, 110, null, 150]);
      expect(s, [100, 110, 0, 0, 0, 150]);
    });
    test('empty in, empty out', () {
      expect(perSecond(const [], const []), isEmpty);
    });
  });

  group('bestMeanAfter', () {
    // 2 h at 200 W (1440 kJ), then 1 h at 150 W.
    final sec = [..._ride(7200, 200), ..._ride(3600, 150)];

    test('fresh: the best window anywhere', () {
      final v = bestMeanAfter(sec, [60, 3600]);
      expect(v[0], 200);
      expect(v[1], 200);
    });

    test('after 1000 kJ only later windows count', () {
      // 200 W * 5000 s = 1000 kJ, so efforts start at 5000 s or later.
      final v = bestMeanAfter(sec, [60, 3600], afterWork: 1000);
      expect(v[0], 200); // 5000..7200 is still at 200 W
      // The best hour starting at/after 5000 s is 5000..8600: mix of 200/150.
      expect(v[1], closeTo((2200 * 200 + 1400 * 150) / 3600, 1e-9));
    });

    test('after 1500 kJ only the easy tail remains', () {
      // 1440 kJ after 2 h; 1500 kJ is reached 60 kJ / 0.15 kW = 400 s later.
      final v = bestMeanAfter(sec, [60, 3600], afterWork: 1500);
      expect(v[0], 150);
      expect(v[1], isNull); // less than an hour is left
    });

    test('a session that never reaches the work level gives nothing', () {
      expect(bestMeanAfter(_ride(1800, 250), [60], afterWork: 1000), [null]);
    });
  });

  group('bestTimeAfter', () {
    // 12 km at 3 m/s (4000 s), then 6 km at 2.5 m/s.
    final speed = [..._ride(4000, 3), ..._ride(2400, 2.5)];

    test('fresh: the fastest time over each distance', () {
      final v = bestTimeAfter(speed, [1000, 5000]);
      expect(v[0], closeTo(1000 / 3, 1.0));
      expect(v[1], closeTo(5000 / 3, 1.0));
    });

    test('after 10 km the slower tail sets the time', () {
      final v = bestTimeAfter(speed, [1000], afterMetres: 10000);
      // 10 km is reached at 3333 s; the remaining 667 s at 3 m/s still holds
      // a 1 km split at 3 m/s.
      expect(v.single, closeTo(1000 / 3, 1.0));
      final late = bestTimeAfter(speed, [1000], afterMetres: 13000);
      expect(late.single, closeTo(1000 / 2.5, 1.0));
    });

    test('not enough running after the threshold gives nothing', () {
      expect(bestTimeAfter(speed, [1000], afterMetres: 30000), [null]);
    });
  });

  test('retained share: watts against watts, pace as fresh time over time', () {
    final power = DurabilityResult(
      sport: CurveSport.ride,
      metric: CurveMetric.power,
      points: const [60],
      fresh: const DurabilityLevel(label: '', workAfter: 0, values: [400]),
      fatigued: const [
        DurabilityLevel(label: '2000', workAfter: 2000, values: [340]),
      ],
      candidates: 1,
      analysed: 1,
      failed: 0,
      days: 90,
    );
    expect(power.retained(power.fatigued.first, 0), closeTo(0.85, 1e-9));

    final pace = DurabilityResult(
      sport: CurveSport.run,
      metric: CurveMetric.pace,
      points: const [1000],
      fresh: const DurabilityLevel(label: '', workAfter: 0, values: [240]),
      fatigued: const [
        DurabilityLevel(label: '20', workAfter: 20, values: [300]),
      ],
      candidates: 1,
      analysed: 1,
      failed: 0,
      days: 90,
    );
    expect(pace.retained(pace.fatigued.first, 0), closeTo(0.8, 1e-9));
  });

  test('candidates: rides by work, runs by distance, other sports never', () {
    LocalActivity act(
      String type, {
      double? joules,
      int secs = 3600,
      double dist = 0,
    }) => LocalActivity(
      id: type,
      date: '2026-10-01',
      type: type,
      name: null,
      movingTime: secs,
      distance: dist,
      trainingLoad: 50,
      raw: {'icu_joules': ?joules},
      syncedAt: DateTime(2026),
    );
    expect(
      isDurabilityCandidate(act('Ride', joules: 1.2e6), LoadSport.ride),
      isTrue,
    );
    expect(
      isDurabilityCandidate(act('Ride', joules: 8e5), LoadSport.ride),
      isFalse,
    );
    expect(
      isDurabilityCandidate(act('Ride', secs: 6000), LoadSport.ride),
      isTrue,
    );
    expect(
      isDurabilityCandidate(act('Run', dist: 12000), LoadSport.run),
      isTrue,
    );
    expect(
      isDurabilityCandidate(act('Run', dist: 8000), LoadSport.run),
      isFalse,
    );
    expect(
      isDurabilityCandidate(act('Swim', dist: 4000), LoadSport.ride),
      isFalse,
    );
  });

  test(
    'loader keeps the best per level across sessions, fresh from the curve',
    () async {
      final now = DateTime(2026, 11, 7);
      LocalActivity ride(String id, String date) => LocalActivity(
        id: id,
        date: date,
        type: 'Ride',
        name: id,
        movingTime: 14400,
        distance: 100000,
        trainingLoad: 200,
        raw: {'icu_joules': 2.5e6},
        syncedAt: now,
      );
      // Ride a: 3 h at 250 W. Ride b: 3 h at 220 W. Both pass 1000 kJ at 4000 s
      // (a) / 4545 s (b), 2000 kJ at 8000 s / 9090 s; 3000 kJ never.
      SessionStreams streams(double w) => SessionStreams(
        series: {
          'time': [for (var i = 0; i < 10800; i++) i.toDouble()],
          'watts': List<double?>.filled(10800, w),
        },
      );
      final db = ActivitiesRepository();
      await db.upsertAll([ride('a', '2026-10-20'), ride('b', '2026-10-25')]);

      final loader = DurabilityLoader(
        activities: db,
        streams: ActivityStreamsRepository(
          fetch: (id) async => streams(id == 'a' ? 250 : 220),
        ),
        curves: PerformanceCurvesRepository(
          fetch: (sport, metric) async => {
            'list': [
              {
                'id': 's0',
                'secs': [5, 60, 300, 1200, 3600],
                'values': [900, 500, 380, 310, 270],
              },
            ],
          },
        ),
        clock: () => now,
      );
      final progress = <int>[];
      final r = await loader.load(
        CurveSport.ride,
        90,
        onProgress: (done, total) => progress.add(done),
      );

      expect(r.candidates, 2);
      expect(r.analysed, 2);
      expect(r.fatigued[0].values[1], 250); // after 1000 kJ: the better ride
      expect(r.fatigued[1].values[1], 250); // after 2000 kJ
      expect(r.fatigued[2].hasData, isFalse); // nobody did 3000 kJ
      expect(r.fresh.values[1], 500); // from the season curve
      expect(r.retained(r.fatigued[0], 1), closeTo(0.5, 1e-9));
      expect(progress.first, 0);
      expect(progress.last, 2);
      expect(isoDate(now), '2026-11-07');
    },
  );
}
