import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/client/intervalls/intervalls_client.dart';
import 'package:triiq/evaluation/performance_curves.dart';
import 'package:triiq/evaluation/threshold_suggestions.dart';

void main() {
  final now = DateTime(2026, 8, 30);

  PerformanceCurves curves({
    required CurveSport sport,
    required CurveMetric metric,
    CurvePeriod? season,
    CurvePeriod? recent,
    Map<String, CurveActivity> activities = const {},
  }) => PerformanceCurves(
    sport: sport,
    metric: metric,
    periods: [?season, ?recent],
    activities: activities,
  );

  CurveActivity activityDaysAgo(String id, int days) => CurveActivity(
    id: id,
    date: now.subtract(Duration(days: days)).toIso8601String().substring(0, 10),
  );

  group('rideFtpSuggestions', () {
    test('increase: season model fit beats settings by >=3%', () {
      final result = rideFtpSuggestions(
        settings: SportSettings(ftp: 252),
        curves: curves(
          sport: CurveSport.ride,
          metric: CurveMetric.power,
          season: const CurvePeriod(
            id: 's0',
            points: [],
            model: CurveModel(ftp: 262),
          ),
        ),
        now: now,
      );

      expect(result, hasLength(1));
      expect(result.single.direction, ThresholdDirection.up);
      expect(result.single.candidateValue, 262);
    });

    test('small gap under 3% is not suggested', () {
      final result = rideFtpSuggestions(
        settings: SportSettings(ftp: 252),
        curves: curves(
          sport: CurveSport.ride,
          metric: CurveMetric.power,
          season: const CurvePeriod(
            id: 's0',
            points: [],
            model: CurveModel(ftp: 256),
          ),
        ),
        now: now,
      );

      expect(result, isEmpty);
    });

    test('no recent hard efforts: season below settings but 42d has no fit '
        '-> no decrease', () {
      final result = rideFtpSuggestions(
        settings: SportSettings(ftp: 252),
        curves: curves(
          sport: CurveSport.ride,
          metric: CurveMetric.power,
          season: const CurvePeriod(
            id: 's0',
            points: [],
            model: CurveModel(ftp: 240),
          ),
          recent: const CurvePeriod(id: '42d', points: []),
        ),
        now: now,
      );

      expect(result, isEmpty);
    });

    test('decrease: 42d model fit at least 5% below settings', () {
      final result = rideFtpSuggestions(
        settings: SportSettings(ftp: 252),
        curves: curves(
          sport: CurveSport.ride,
          metric: CurveMetric.power,
          recent: const CurvePeriod(
            id: '42d',
            points: [],
            model: CurveModel(ftp: 230),
          ),
        ),
        now: now,
      );

      expect(result, hasLength(1));
      expect(result.single.direction, ThresholdDirection.down);
      expect(result.single.candidateValue, 230);
    });

    test('dismissal suppresses a candidate that has not moved 3% further', () {
      final result = rideFtpSuggestions(
        settings: SportSettings(ftp: 252),
        curves: curves(
          sport: CurveSport.ride,
          metric: CurveMetric.power,
          season: const CurvePeriod(
            id: 's0',
            points: [],
            model: CurveModel(ftp: 263),
          ),
        ),
        now: now,
        upDismissal: ThresholdDismissal(
          candidateValue: 262,
          at: now.subtract(const Duration(days: 7)),
        ),
      );

      expect(result, isEmpty);
    });

    test('dismissed then exceeded by a further 3% shows a new suggestion', () {
      final result = rideFtpSuggestions(
        settings: SportSettings(ftp: 252),
        curves: curves(
          sport: CurveSport.ride,
          metric: CurveMetric.power,
          season: const CurvePeriod(
            id: 's0',
            points: [],
            model: CurveModel(ftp: 271),
          ),
        ),
        now: now,
        upDismissal: ThresholdDismissal(
          candidateValue: 262,
          at: now.subtract(const Duration(days: 7)),
        ),
      );

      expect(result, hasLength(1));
      expect(result.single.candidateValue, 271);
    });

    test('a dismissal older than 30 days no longer suppresses', () {
      final result = rideFtpSuggestions(
        settings: SportSettings(ftp: 252),
        curves: curves(
          sport: CurveSport.ride,
          metric: CurveMetric.power,
          season: const CurvePeriod(
            id: 's0',
            points: [],
            model: CurveModel(ftp: 262),
          ),
        ),
        now: now,
        upDismissal: ThresholdDismissal(
          candidateValue: 262,
          at: now.subtract(const Duration(days: 31)),
        ),
      );

      expect(result, hasLength(1));
    });

    test('no settings or no curves returns nothing', () {
      expect(
        rideFtpSuggestions(settings: null, curves: null, now: now),
        isEmpty,
      );
    });
  });

  group('runThresholdPaceSuggestions', () {
    test('uses the ~60-minute effort directly when present', () {
      final result = runThresholdPaceSuggestions(
        settings: SportSettings(thresholdPace: 4.0),
        curves: curves(
          sport: CurveSport.run,
          metric: CurveMetric.pace,
          season: CurvePeriod(
            id: 's0',
            points: [const CurvePoint(15000, 3600, 'a1')],
          ),
          activities: {'a1': activityDaysAgo('a1', 10)},
        ),
        now: now,
      );

      expect(result, hasLength(1));
      expect(result.single.basisKind, ThresholdBasisKind.runSeason60Min);
      expect(result.single.candidateValue, closeTo(15000 / 3600, 0.001));
    });

    test('falls back to the ~40-minute effort scaled by 1.02', () {
      final result = runThresholdPaceSuggestions(
        settings: SportSettings(thresholdPace: 4.0),
        curves: curves(
          sport: CurveSport.run,
          metric: CurveMetric.pace,
          season: CurvePeriod(
            id: 's0',
            points: [const CurvePoint(10500, 2400, 'a1')],
          ),
          activities: {'a1': activityDaysAgo('a1', 10)},
        ),
        now: now,
      );

      expect(result, hasLength(1));
      expect(
        result.single.basisKind,
        ThresholdBasisKind.runSeason40MinHeuristic,
      );
      final expectedSpeed = (10500 / 2400) / 1.02;
      expect(result.single.candidateValue, closeTo(expectedSpeed, 0.001));
    });

    test('efforts older than 90 days are not used as a candidate', () {
      final result = runThresholdPaceSuggestions(
        settings: SportSettings(thresholdPace: 4.0),
        curves: curves(
          sport: CurveSport.run,
          metric: CurveMetric.pace,
          season: CurvePeriod(
            id: 's0',
            points: [const CurvePoint(15000, 3600, 'old')],
          ),
          activities: {'old': activityDaysAgo('old', 95)},
        ),
        now: now,
      );

      expect(result, isEmpty);
    });
  });

  group('swimCssSuggestions', () {
    test('CSS from 400m/200m bests: 6:00 and 2:50 -> 1:35 per 100m', () {
      final result = swimCssSuggestions(
        settings: SportSettings(thresholdPace: 0.9),
        curves: curves(
          sport: CurveSport.swim,
          metric: CurveMetric.pace,
          season: CurvePeriod(
            id: 's0',
            points: const [
              CurvePoint(400, 360, 'a400'),
              CurvePoint(200, 170, 'a200'),
            ],
          ),
          activities: {
            'a400': activityDaysAgo('a400', 5),
            'a200': activityDaysAgo('a200', 5),
          },
        ),
        now: now,
      );

      expect(result, hasLength(1));
      // 95 s / 100 m -> speed 100/95 m/s.
      expect(result.single.candidateValue, closeTo(100 / 95, 0.0001));
      expect(result.single.effortActivityIds, containsAll(['a400', 'a200']));
    });

    test('missing one of the two bests derives nothing', () {
      final result = swimCssSuggestions(
        settings: SportSettings(thresholdPace: 0.9),
        curves: curves(
          sport: CurveSport.swim,
          metric: CurveMetric.pace,
          season: CurvePeriod(
            id: 's0',
            points: const [CurvePoint(400, 360, 'a400')],
          ),
          activities: {'a400': activityDaysAgo('a400', 5)},
        ),
        now: now,
      );

      expect(result, isEmpty);
    });
  });

  group('evaluateThresholdSuggestions', () {
    test('combines all three sports', () {
      final result = evaluateThresholdSuggestions(
        rideSettings: SportSettings(ftp: 252),
        ridePowerCurves: curves(
          sport: CurveSport.ride,
          metric: CurveMetric.power,
          season: const CurvePeriod(
            id: 's0',
            points: [],
            model: CurveModel(ftp: 262),
          ),
        ),
        runSettings: null,
        runPaceCurves: null,
        swimSettings: null,
        swimPaceCurves: null,
        now: now,
      );

      expect(result, hasLength(1));
      expect(result.single.sport, CurveSport.ride);
    });
  });
}
