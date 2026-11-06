import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/evaluation/activity_route.dart';
import 'package:triiq/evaluation/compare.dart';
import 'package:triiq/evaluation/session_streams.dart';

/// [n] one-second samples at constant [mps] and [hr].
SessionStreams steady(int n, double mps, double hr, {bool distance = true}) =>
    SessionStreams(
      series: {
        'time': [for (var i = 0; i < n; i++) i.toDouble()],
        if (distance) 'distance': [for (var i = 0; i < n; i++) i * mps],
        'heartrate': List<double?>.filled(n, hr),
        'velocity_smooth': List<double?>.filled(n, mps),
      },
    );

LocalActivity act(
  String id,
  String date, {
  String type = 'Run',
  int seconds = 3600,
  double distance = 10000,
  int load = 60,
  Map<String, dynamic> raw = const {},
}) => LocalActivity(
  id: id,
  date: date,
  type: type,
  name: id,
  movingTime: seconds,
  distance: distance,
  trainingLoad: load,
  raw: raw,
  syncedAt: DateTime(2026, 11, 1),
);

void main() {
  test('only runs and rides are comparable', () {
    expect(isComparable(act('a', '2026-10-01', type: 'TrailRun')), isTrue);
    expect(isComparable(act('a', '2026-10-01', type: 'VirtualRide')), isTrue);
    expect(isComparable(act('a', '2026-10-01', type: 'Swim')), isFalse);
    expect(
      isComparable(act('a', '2026-10-01', type: 'WeightTraining')),
      isFalse,
    );
  });

  group('axis and resampling', () {
    test('axisValues is non-decreasing and absent without the stream', () {
      final s = SessionStreams(
        series: {
          'time': [0, 1, 2, 3],
          'distance': [0, 5, 4, null],
        },
      );
      expect(axisValues(s, CompareAxis.distance), [0, 5, 5, 5]);
      expect(
        axisValues(steady(10, 3, 140, distance: false), CompareAxis.distance),
        isNull,
      );
    });

    test('a faster activity reaches a distance sooner; shorter one stops', () {
      final fast = steady(100, 4, 150); // 396 m
      final slow = steady(100, 2, 140); // 198 m
      final grid = axisGrid(396, count: 5); // 0,99,198,297,396
      final f = resampleMetric(fast, 'heartrate', CompareAxis.distance, grid);
      final sl = resampleMetric(slow, 'heartrate', CompareAxis.distance, grid);
      expect(f.every((v) => v != null), isTrue);
      expect(f.first, closeTo(150, 1e-9));
      expect(sl[2], closeTo(140, 1e-9));
      expect(sl[3], isNull);
      expect(sl[4], isNull);
    });

    test('time axis interpolates between samples', () {
      final s = SessionStreams(
        series: {
          'time': [0, 10],
          'altitude': [100, 200],
        },
      );
      final v = resampleMetric(s, 'altitude', CompareAxis.time, [0, 5, 10]);
      expect(v, [100, 150, 200]);
    });

    test('timeAtX and xAtTime are inverse and null past the end', () {
      final s = steady(101, 3, 140); // 300 m in 100 s
      expect(timeAtX(s, CompareAxis.distance, 150), closeTo(50, 1e-9));
      expect(xAtTime(s, CompareAxis.distance, 50), closeTo(150, 1e-9));
      expect(timeAtX(s, CompareAxis.distance, 301), isNull);
      expect(timeAtX(s, CompareAxis.time, 42), 42);
      expect(xAtTime(s, CompareAxis.time, 42), 42);
    });
  });

  group('tracker on the map', () {
    final route = ActivityRoute(
      const [
        RoutePoint(48.0, 11.0),
        RoutePoint(48.001, 11.0),
        RoutePoint(48.002, 11.0),
      ],
      times: const [0, 50, 100],
    );
    final streams = steady(101, 3, 140);

    test('chart position gives the point on the course', () {
      final p = routePointAtX(route, streams, CompareAxis.distance, 150)!;
      expect(p.lat, 48.001);
      expect(routePointAtX(route, streams, CompareAxis.distance, 999), isNull);
    });

    test('a map tap gives the chart position', () {
      final x = xAtNearestPoint(
        route,
        streams,
        CompareAxis.distance,
        48.0019,
        11.0,
      );
      expect(x, closeTo(300, 1e-6)); // nearest fix is the last: 100 s * 3 m/s
      final far = xAtNearestPoint(
        route,
        streams,
        CompareAxis.distance,
        50,
        11,
        maxMetres: 100,
      );
      expect(far, isNull);
    });

    test('routeMetres is roughly right', () {
      expect(
        routeMetres(const RoutePoint(48, 11), const RoutePoint(48.001, 11)),
        closeTo(111.2, 1),
      );
    });
  });

  group('block stats', () {
    test('sums, time-weights and averages', () {
      final s = blockStats([
        act(
          'a',
          '2026-10-01',
          seconds: 3600,
          distance: 10000,
          load: 50,
          raw: {
            'average_heartrate': 140,
            'total_elevation_gain': 100,
            'icu_efficiency_factor': 1.2,
            'icu_hr_zone_times': [3000, 600, 0, 0, 0],
          },
        ),
        act(
          'b',
          '2026-10-02',
          seconds: 1800,
          distance: 6000,
          load: 30,
          raw: {
            'average_heartrate': 160,
            'total_elevation_gain': 50,
            'icu_efficiency_factor': 1.4,
          },
        ),
      ]);
      expect(s.count, 2);
      expect(s.seconds, 5400);
      expect(s.distance, 16000);
      expect(s.elevation, 150);
      expect(s.load, 80);
      expect(s.avgHeartrate, closeTo((140 * 3600 + 160 * 1800) / 5400, 1e-9));
      expect(s.avgSpeed, closeTo(16000 / 5400, 1e-9));
      expect(s.efficiencyFactor, closeTo(1.3, 1e-9));
      expect(s.avgWatts, isNull);
      expect(s.split!.low, 3600);
      expect(blockStats(const []).isEmpty, isTrue);
    });

    test('relativeChange', () {
      expect(relativeChange(100, 110), closeTo(0.1, 1e-9));
      expect(relativeChange(0, 5), isNull);
      expect(relativeChange(null, 5), isNull);
    });
  });

  group('block pair', () {
    final pair = BlockPair(end: DateTime(2026, 10, 28), days: 7);

    test('current and previous blocks are adjacent and equal length', () {
      expect(pair.currentStart, DateTime(2026, 10, 22));
      expect(pair.previousEnd, DateTime(2026, 10, 21));
      expect(pair.previousStart, DateTime(2026, 10, 15));
      expect(pair.inCurrent('2026-10-22'), isTrue);
      expect(pair.inCurrent('2026-10-21'), isFalse);
      expect(pair.inPrevious('2026-10-21'), isTrue);
      expect(pair.inPrevious('2026-10-14'), isFalse);
    });

    test('cumulative by day stops at the end date', () {
      final acts = [
        act('a', '2026-10-22', distance: 5000),
        act('b', '2026-10-24', distance: 7000),
      ];
      final cum = cumulativeByDay(
        acts,
        pair.currentStart,
        7,
        (a) => (a.distance ?? 0) / 1000,
        end: DateTime(2026, 10, 25),
      );
      expect(cum, [5, 5, 12, 12, null, null, null]);
    });

    test('ofSport keeps one family', () {
      final all = [
        act('a', '2026-10-01'),
        act('b', '2026-10-01', type: 'Ride'),
      ];
      expect(ofSport(all, 'ride').single.id, 'b');
    });
  });
}
