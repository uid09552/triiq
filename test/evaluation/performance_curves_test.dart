import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/evaluation/performance_curves.dart';

/// A power response shaped like Intervals.icu's `power-curves.json`, with
/// a field the generated model doesn't know (it must be ignored).
Map<String, dynamic> _powerResponse() => {
  'list': [
    {
      'id': 's0',
      'start_date_local': '2026-01-01T00:00:00',
      'end_date_local': '2026-12-31T00:00:00',
      'secs': [5, 60, 300, 1200],
      'values': [880, 420, 312, 268],
      'activity_id': ['i1', 'i2', 'i3', 'i3'],
      'powerModels': [
        {'type': 'MS_2P', 'ftp': 262, 'criticalPower': 270, 'wPrime': 18400},
      ],
      'brand_new_field': true,
    },
    {
      'id': 's1',
      'secs': [5, 60, 300, 1200, 3600],
      'values': [905, 401, 298, 259, 236],
      'activity_id': ['o1', 'o2', 'o3', 'o4', 'o5'],
    },
    {'id': '42d', 'secs': <int>[], 'values': <int>[]},
  ],
  'activities': {
    'i3': {
      'id': 'i3',
      'start_date_local': '2026-10-12T07:00:00',
      'name': 'VO2',
    },
  },
};

void main() {
  group('parsing', () {
    test('periods, points, model and activities', () {
      final curves = PerformanceCurves.fromJson(
        CurveSport.ride,
        CurveMetric.power,
        _powerResponse(),
      );

      expect(curves.periods.map((p) => p.id), ['s0', 's1', '42d']);
      final s0 = curves.period('s0')!;
      expect(s0.points, hasLength(4));
      expect(s0.at(300)!.value, 312);
      expect(s0.at(300)!.activityId, 'i3');
      expect(s0.model!.ftp, 262);
      expect(s0.model!.wPrime, 18400);
      expect(s0.start, '2026-01-01');
      expect(curves.activities['i3']!.date, '2026-10-12');
      expect(curves.period('42d')!.isEmpty, isTrue);
    });

    test('a key point the period has no effort for stays empty', () {
      final s0 = PerformanceCurves.fromJson(
        CurveSport.ride,
        CurveMetric.power,
        _powerResponse(),
      ).period('s0')!;

      expect(s0.at(3600), isNull, reason: 'no hour-long ride this season');
      expect(s0.at(1000), isNull, reason: 'never interpolated');
    });

    test('missing model and missing season', () {
      final json = _powerResponse();
      (json['list'] as List).removeAt(1);
      final curves = PerformanceCurves.fromJson(
        CurveSport.ride,
        CurveMetric.power,
        json,
      );
      expect(curves.period('s1'), isNull);
      expect(curves.period('42d')!.model, isNull);
    });

    test('curves without ids take the requested order', () {
      final curves = PerformanceCurves.fromJson(
        CurveSport.ride,
        CurveMetric.hr,
        {
          'list': [
            {
              'secs': [60],
              'values': [180],
            },
            {
              'secs': [60],
              'values': [176],
            },
          ],
        },
      );
      expect(curves.periods.map((p) => p.id), ['s0', 's1']);
    });

    test('pace curves are keyed by distance and plotted as speed', () {
      final curves = PerformanceCurves.fromJson(
        CurveSport.run,
        CurveMetric.pace,
        {
          'list': [
            {
              'id': 's0',
              'distance': [1000, 5000, 21100],
              'values': [210, 1150, 5400],
              'paceModels': [
                {'criticalSpeed': 4.2, 'dPrime': 180},
              ],
            },
          ],
        },
      );
      final s0 = curves.period('s0')!;
      expect(s0.at(21097.5)!.value, 5400, reason: 'within 1% rounding');
      expect(s0.model!.criticalSpeed, 4.2);
      expect(plotValue(CurveMetric.pace, s0.at(1000)!), closeTo(4.76, 0.01));
      expect(formatPace(1000 / 210, per: 1000), '3:30');
      expect(curves.keyPoints.first, 400);
    });

    test('malformed curves are dropped, not fatal', () {
      final curves = PerformanceCurves.fromJson(
        CurveSport.swim,
        CurveMetric.pace,
        {
          'list': [
            'nonsense',
            {
              'id': 's0',
              'distance': 'x',
              'values': [1],
            },
          ],
        },
      );
      expect(curves.isEmpty, isTrue);
    });
  });

  test('downsampling keeps the best value per log bucket', () {
    final points = [
      for (var s = 1; s <= 20000; s++) CurvePoint(s.toDouble(), 1000.0 / s),
    ];
    final thinned = downsampleLog(points, CurveMetric.power);
    expect(thinned.length, lessThanOrEqualTo(200));
    expect(thinned.first.x, 1);
    expect(thinned.first.value, 1000);
  });

  test('formatting', () {
    expect(formatCurveDuration(5), '5s');
    expect(formatCurveDuration(1200), '20m');
    expect(formatCurveDuration(5400), '1h30m');
    expect(formatCurveDistance(400), '400 m');
    expect(formatCurveDistance(21097.5), '21.1 km');
    expect(formatPace(100 / 95, per: 100), '1:35');
  });

  group('repository', () {
    late Directory dir;

    setUp(() async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      dir = await Directory.systemTemp.createTemp('triiq_curves');
    });

    tearDown(() => dir.delete(recursive: true));

    test('a v4 cache upgrades to v5 with an empty curves table', () async {
      final path = p.join(dir.path, 'triiq.db');
      final old = await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 4,
          onCreate: (db, _) => db.execute(
            'CREATE TABLE activities (id TEXT PRIMARY KEY, date TEXT)',
          ),
        ),
      );
      await old.close();

      final database = AppDatabase.atPath(path);
      final db = await database.database;
      expect(await db.getVersion(), 5);
      expect(await db.query('performance_curves'), isEmpty);
      await database.close();
    });

    test('fetched once, then cached until a newer activity arrives', () async {
      final database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
      addTearDown(database.close);
      var newest = 'a1';
      var fetches = 0;
      final repo = PerformanceCurvesRepository(
        database: database,
        newestActivity: (_) async => newest,
        fetch: (sport, metric) async {
          fetches++;
          return _powerResponse();
        },
      );

      expect(await repo.cached(CurveSport.ride, CurveMetric.power), isNull);
      final first = await repo.load(CurveSport.ride, CurveMetric.power);
      expect(first.period('s0')!.model!.ftp, 262);
      expect(fetches, 1);

      final again = await repo.load(CurveSport.ride, CurveMetric.power);
      expect(again.period('s0')!.points, hasLength(4));
      expect(fetches, 1, reason: 'second open makes no request');
      expect(await repo.isStale(CurveSport.ride, CurveMetric.power), isFalse);

      newest = 'a2';
      expect(await repo.isStale(CurveSport.ride, CurveMetric.power), isTrue);
      await repo.load(CurveSport.ride, CurveMetric.power);
      expect(fetches, 2, reason: 'a new ride makes the curves stale');
    });

    test('a failed fetch keeps the cached copy', () async {
      final database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
      addTearDown(database.close);
      var newest = 'a1';
      var fail = false;
      final repo = PerformanceCurvesRepository(
        database: database,
        newestActivity: (_) async => newest,
        fetch: (sport, metric) async {
          if (fail) throw const SocketException('offline');
          return _powerResponse();
        },
      );
      await repo.load(CurveSport.ride, CurveMetric.power);

      newest = 'a2';
      fail = true;
      await expectLater(
        repo.load(CurveSport.ride, CurveMetric.power),
        throwsA(isA<SocketException>()),
      );
      expect(await repo.cached(CurveSport.ride, CurveMetric.power), isNotNull);
    });

    test(
      'newest activity per sport family from the activities table',
      () async {
        final database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
        addTearDown(database.close);
        final db = await database.database;
        for (final (id, date, type) in [
          ('r1', '2026-10-01', 'Ride'),
          ('r2', '2026-10-05', 'VirtualRide'),
          ('n1', '2026-10-07', 'Run'),
        ]) {
          await db.insert('activities', {
            'id': id,
            'date': date,
            'type': type,
            'raw': '{}',
            'synced_at': 0,
          });
        }
        var fetches = 0;
        final repo = PerformanceCurvesRepository(
          database: database,
          fetch: (sport, metric) async {
            fetches++;
            return {'list': <Object>[]};
          },
        );
        await repo.load(CurveSport.ride, CurveMetric.power);
        final row = (await db.query('performance_curves')).single;
        expect(row['newest_activity_id'], 'r2');

        await db.insert('activities', {
          'id': 'n2',
          'date': '2026-10-09',
          'type': 'Run',
          'raw': '{}',
          'synced_at': 0,
        });
        await repo.load(CurveSport.ride, CurveMetric.power);
        expect(fetches, 1, reason: 'a new run does not stale ride curves');
      },
    );
  });
}
