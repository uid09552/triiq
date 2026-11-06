import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/evaluation/training_analytics.dart';

LocalActivity act(
  String date, {
  String type = 'Ride',
  int load = 50,
  int seconds = 3600,
  List<int> hrZones = const [3000, 600, 0, 0, 0],
  double? ef,
  double? decoupling,
}) => LocalActivity(
  id: '$type$date$load',
  date: date,
  type: type,
  name: null,
  movingTime: seconds,
  distance: null,
  trainingLoad: load,
  raw: {
    'icu_hr_zone_times': hrZones,
    'icu_efficiency_factor': ?ef,
    'decoupling': ?decoupling,
  },
  syncedAt: DateTime(2026, 11, 1),
);

void main() {
  test('loadSportOf folds variants into swim / ride / run', () {
    expect(loadSportOf('OpenWaterSwim'), LoadSport.swim);
    expect(loadSportOf('VirtualRide'), LoadSport.ride);
    expect(loadSportOf('TrailRun'), LoadSport.run);
    expect(loadSportOf('WeightTraining'), LoadSport.other);
    expect(loadSportOf(null), LoadSport.other);
  });

  group('sportFitness', () {
    test('per-sport CTL/ATL follow the exponential model and sum', () {
      final days = sportFitness(
        [
          act('2026-10-01', load: 100),
          act('2026-10-01', type: 'Run', load: 42),
        ],
        from: DateTime(2026, 10, 1),
        to: DateTime(2026, 10, 3),
      );
      expect(days, hasLength(3));
      expect(days.first.ctl[LoadSport.ride], closeTo(100 / 42, 1e-9));
      expect(days.first.atl[LoadSport.ride], closeTo(100 / 7, 1e-9));
      expect(days.first.ctl[LoadSport.run], closeTo(1, 1e-9));
      expect(days.first.ctl.containsKey(LoadSport.swim), isFalse);
      // Day 2 decays by (1 - 1/42).
      expect(
        days[1].ctl[LoadSport.ride],
        closeTo(100 / 42 * (1 - 1 / 42), 1e-9),
      );
      expect(days.first.totalCtl, closeTo(100 / 42 + 1, 1e-9));
    });

    test('history before the window warms the averages up', () {
      final warm = sportFitness(
        [
          for (var d = 1; d <= 20; d++)
            act('2026-09-${d.toString().padLeft(2, '0')}'),
        ],
        from: DateTime(2026, 10, 1),
        to: DateTime(2026, 10, 1),
      );
      expect(warm.single.ctl[LoadSport.ride], greaterThan(5));
    });
  });

  test('loadBySportPerBucket assigns load to its week', () {
    final starts = [DateTime(2026, 10, 5), DateTime(2026, 10, 12)];
    final out = loadBySportPerBucket(
      [
        act('2026-10-06', load: 60),
        act('2026-10-13', type: 'Swim', load: 30),
        act('2026-10-01', load: 99), // before first bucket
      ],
      starts,
      DateTime(2026, 10, 18),
    );
    expect(out[0], {LoadSport.ride: 60});
    expect(out[1], {LoadSport.swim: 30});
  });

  group('intensity distribution', () {
    test('classifies polarized, pyramidal, threshold, high', () {
      expect(
        classifyDistribution(8000, 500, 1500),
        DistributionModel.polarized,
      );
      expect(
        classifyDistribution(6000, 3000, 1000),
        DistributionModel.pyramidal,
      );
      expect(
        classifyDistribution(3000, 5000, 2000),
        DistributionModel.threshold,
      );
      expect(
        classifyDistribution(2000, 2000, 6000),
        DistributionModel.highIntensity,
      );
      expect(classifyDistribution(0, 0, 0), isNull);
    });

    test('polarization index', () {
      // f1 .8, f2 .05, f3 .15 -> log10(.8/.05*.15*100) = log10(240)
      expect(polarizationIndexOf(80, 5, 15), closeTo(2.380, 0.001));
      expect(polarizationIndexOf(100, 0, 0), isNull);
    });

    test('weekly buckets sum zone time and count sessions without zones', () {
      final noZones = LocalActivity(
        id: 'x',
        date: '2026-10-07',
        type: 'Ride',
        name: null,
        movingTime: 1800,
        distance: null,
        trainingLoad: 10,
        raw: const {},
        syncedAt: DateTime(2026, 11, 1),
      );
      final buckets = intensityBuckets(
        [
          act('2026-10-06', hrZones: [1000, 1000, 500, 300, 200]),
          noZones,
          act('2026-10-14'),
        ],
        from: DateTime(2026, 10, 5),
        to: DateTime(2026, 10, 18),
      );
      expect(buckets, hasLength(2));
      expect(buckets[0].low, 2000);
      expect(buckets[0].moderate, 800);
      expect(buckets[0].high, 200);
      expect(buckets[0].sessionsWithoutZones, 1);
      expect(buckets[0].model(minSeconds: 3000), DistributionModel.pyramidal);
      expect(buckets[0].model(), isNull); // under an hour of zone time
      expect(buckets[1].total, 3600);
    });

    test('monthly bucket starts', () {
      final s = bucketStarts(
        DateTime(2026, 8, 20),
        DateTime(2026, 10, 3),
        monthly: true,
      );
      expect(s, [DateTime(2026, 8), DateTime(2026, 9), DateTime(2026, 10)]);
    });
  });

  group('load safety', () {
    test('bands', () {
      expect(acwrRisk(1.0), RiskLevel.safe);
      expect(acwrRisk(1.4), RiskLevel.risky);
      expect(acwrRisk(1.6), RiskLevel.high);
      expect(rampRisk(4), RiskLevel.safe);
      expect(rampRisk(6), RiskLevel.risky);
      expect(rampRisk(9), RiskLevel.high);
      expect(monotonyRisk(1.2), RiskLevel.safe);
      expect(monotonyRisk(1.8), RiskLevel.risky);
      expect(monotonyRisk(2.5), RiskLevel.high);
    });

    test('steady load gives ACWR 1; a spike pushes it up', () {
      final steady = [
        for (var d = 0; d < 40; d++)
          act(isoOf(DateTime(2026, 9, 1).add(Duration(days: d))), load: 50),
      ];
      final flat = loadSafety(
        steady,
        from: DateTime(2026, 10, 10),
        to: DateTime(2026, 10, 10),
      );
      expect(flat.single.acwr, closeTo(1.0, 1e-9));
      // Constant load every day: no spread, monotony undefined.
      expect(flat.single.monotony, isNull);

      final spike = loadSafety(
        [...steady, act('2026-10-10', load: 400)],
        from: DateTime(2026, 10, 10),
        to: DateTime(2026, 10, 10),
      ).single;
      expect(spike.acwr, greaterThan(1.3));
    });

    test('monotony and strain over a week', () {
      // Loads 100,0,100,0,100,0,100 -> mean 400/7, sd known.
      final week = [
        for (var d = 0; d < 7; d += 2)
          act(isoOf(DateTime(2026, 10, 1 + d)), load: 100),
      ];
      final day = loadSafety(
        week,
        from: DateTime(2026, 10, 7),
        to: DateTime(2026, 10, 7),
      ).single;
      final mean = 400 / 7;
      final variance = (4 * (100 - mean) * (100 - mean) + 3 * mean * mean) / 7;
      expect(day.monotony, closeTo(mean / math.sqrt(variance), 1e-9));
      expect(day.strain, closeTo(400 * day.monotony!, 1e-9));
    });

    test('ramp rate uses provided CTL, falls back to computed', () {
      final days = loadSafety(
        [act('2026-10-01', load: 420)],
        from: DateTime(2026, 10, 9),
        to: DateTime(2026, 10, 9),
        ctlByDate: {'2026-10-09': 60, '2026-10-02': 52},
      );
      expect(days.single.rampRate, closeTo(8, 1e-9));
    });
  });

  group('aerobic', () {
    test('keeps only long steady non-swim sessions with EF or decoupling', () {
      final sessions = aerobicSessions([
        act('2026-10-01', ef: 1.5, decoupling: 3, seconds: 5400),
        act('2026-10-02', ef: 1.5, seconds: 1800), // too short
        act(
          '2026-10-03',
          ef: 1.5,
          seconds: 5400,
          hrZones: [100, 100, 3000, 2000, 200],
        ), // not steady
        act('2026-10-04', type: 'Swim', ef: 1.0, seconds: 5400),
        act('2026-10-05', seconds: 5400), // no EF/decoupling
        act('2026-10-06', type: 'Run', decoupling: 6.5, seconds: 4000),
      ]);
      expect(sessions.map((s) => s.date.day), [1, 6]);
      expect(sessions.last.sport, LoadSport.run);
      expect(sessions.last.efficiencyFactor, isNull);
    });

    test('decoupling bands', () {
      expect(decouplingRisk(3), RiskLevel.safe);
      expect(decouplingRisk(-4), RiskLevel.safe);
      expect(decouplingRisk(7), RiskLevel.risky);
      expect(decouplingRisk(12), RiskLevel.high);
    });

    test('linear trend', () {
      final dates = [
        for (var i = 0; i < 5; i++) DateTime(2026, 10, 1 + i * 10),
      ];
      final t = linearTrend(dates, [1.0, 1.1, null, 1.3, 1.4])!;
      expect(t.slopePerDay, closeTo(0.01, 1e-9));
      expect(t.slopePer30Days, closeTo(0.3, 1e-9));
      expect(t.at(dates.first), closeTo(1.0, 1e-9));
      expect(linearTrend(dates, [1.0, null, null, null, 1.2]), isNull);
    });
  });
}

String isoOf(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
