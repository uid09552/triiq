@Tags(['live'])
library;

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/intervals_session.dart';
import 'package:triiq/data/intervals_workout_service.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/evaluation/insights.dart';
import 'package:triiq/evaluation/performance_curves.dart';
import 'package:triiq/data/repositories/events_repository.dart';
import 'package:triiq/data/repositories/sync_state_repository.dart';
import 'package:triiq/data/repositories/wellness_repository.dart';
import 'package:triiq/data/sync/sync_scope.dart';
import 'package:triiq/data/sync/sync_service.dart';

/// End-to-end check against the **live** Intervals.icu API: connect with a
/// real key, sync a date range, and prove the data landed in SQLite.
///
/// Skipped unless a key is supplied, so it never breaks an ordinary
/// `flutter test` run. The key is deliberately not stored in the repo:
///
/// ```
/// flutter test test/sync_live_test.dart --dart-define=INTERVALS_API_KEY=<key>
/// ```
const _apiKey = String.fromEnvironment('INTERVALS_API_KEY');

const _skip = _apiKey == ''
    ? 'Live suite: pass --dart-define=INTERVALS_API_KEY=<key> to run it.'
    : null;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late AppDatabase database;
  late WellnessRepository wellnessRepository;
  late ActivitiesRepository activitiesRepository;
  late EventsRepository eventsRepository;
  late SyncStateRepository syncStateRepository;
  late SyncService syncService;

  setUpAll(() {
    // The test binding installs an HttpOverrides that fails every request, to
    // keep unit tests off the network. This suite is explicitly about the
    // network, so drop it.
    HttpOverrides.global = null;

    // Stand in for the OS credential vault: no plugin implementation exists
    // in a test process, and this suite is not about credential storage.
    final vault = <String, String>{};
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async {
        final args = (call.arguments as Map).cast<String, dynamic>();
        return switch (call.method) {
          'read' => vault[args['key'] as String],
          'write' => vault[args['key'] as String] = args['value'] as String,
          'delete' => vault.remove(args['key'] as String),
          _ => null,
        };
      },
    );
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('triiq_sync_test');
    database = AppDatabase.atPath(p.join(tempDir.path, 'triiq.db'));
    wellnessRepository = WellnessRepository(database: database);
    activitiesRepository = ActivitiesRepository(database: database);
    eventsRepository = EventsRepository(database: database);
    syncStateRepository = SyncStateRepository(database: database);
    syncService = SyncService(
      wellnessRepository: wellnessRepository,
      activitiesRepository: activitiesRepository,
      eventsRepository: eventsRepository,
      syncStateRepository: syncStateRepository,
    );
  });

  tearDown(() async {
    await database.close();
    await tempDir.delete(recursive: true);
  });

  test('authenticates against the live API', skip: _skip, () async {
    await IntervalsSession.instance.connect(_apiKey);

    expect(IntervalsSession.instance.isConnected, isTrue);
    expect(IntervalsSession.instance.athleteId, isNotNull);
    // ignore: avoid_print
    print('athlete: ${IntervalsSession.instance.athleteId} '
        '(${IntervalsSession.instance.athleteName})');
  });

  test('syncs a real date range into SQLite', skip: _skip, () async {
    await IntervalsSession.instance.connect(_apiKey);

    final newest = DateTime.now();
    final oldest = newest.subtract(const Duration(days: 90));
    final result = await syncService.syncRange(oldest, newest);

    // ignore: avoid_print
    print('fetched ${result.wellnessCount} wellness, '
        '${result.activitiesCount} activities');
    expect(
      result.wellnessCount + result.activitiesCount,
      greaterThan(0),
      reason: 'the account returned no data at all for the last 90 days, so '
          'this run would not actually verify anything',
    );

    // The point of the exercise: read back out of SQLite, not out of the
    // in-memory result, so this fails if persistence is broken.
    final storedWellness = await wellnessRepository.getRange(
      _formatDate(oldest),
      _formatDate(newest),
    );
    final storedActivities = await activitiesRepository.getRange(
      _formatDate(oldest),
      _formatDate(newest),
    );
    expect(storedWellness, hasLength(result.wellnessCount));
    expect(storedActivities, hasLength(result.activitiesCount));

    // Rows must be usable, not just present: the columns promoted out of the
    // raw JSON have to survive the round-trip.
    for (final record in storedWellness) {
      expect(record.date, matches(r'^\d{4}-\d{2}-\d{2}$'));
      expect(record.raw, isNotEmpty);
    }
    for (final activity in storedActivities) {
      expect(activity.id, isNotEmpty);
      expect(activity.date, matches(r'^\d{4}-\d{2}-\d{2}$'));
      expect(activity.raw, isNotEmpty);
    }

    final state = await syncStateRepository.get('activities');
    expect(state, isNotNull);
    expect(state!.oldest, _formatDate(oldest));
    expect(state.newest, _formatDate(newest));
  });

  test('re-syncing the same range updates rather than duplicates',
      skip: _skip, () async {
    await IntervalsSession.instance.connect(_apiKey);

    final newest = DateTime.now();
    final oldest = newest.subtract(const Duration(days: 30));

    final first = await syncService.syncRange(oldest, newest);
    final second = await syncService.syncRange(oldest, newest);

    expect(second.activitiesCount, first.activitiesCount);
    final stored = await activitiesRepository.getRange(
      _formatDate(oldest),
      _formatDate(newest),
    );
    expect(stored, hasLength(first.activitiesCount));
    expect(
      stored.map((a) => a.id).toSet(),
      hasLength(stored.length),
      reason: 'primary key should have collapsed the second sync onto the '
          'same rows',
    );
  });

  test('full-history sync (the "Everything" button) completes', skip: _skip,
      () async {
    await IntervalsSession.instance.connect(_apiKey);

    final result = await syncService.syncScope(SyncScope.all);

    // ignore: avoid_print
    print('full history: ${result.wellnessCount} wellness, '
        '${result.activitiesCount} activities');
    expect(result.activitiesCount, greaterThan(0));

    final db = await database.database;
    final activityRows = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM activities'),
    );
    final wellnessRows = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM wellness'),
    );
    expect(activityRows, result.activitiesCount);
    expect(wellnessRows, result.wellnessCount);
  }, timeout: const Timeout(Duration(minutes: 5)));

  test('syncs the Today window: planned events land in SQLite', skip: _skip,
      () async {
    await IntervalsSession.instance.connect(_apiKey);

    final result = await syncService.syncTodayWindow();
    final (weekStart, weekEnd) = SyncService.todayWindow();

    // ignore: avoid_print
    print('today window ${_formatDate(weekStart)}..${_formatDate(weekEnd)}: '
        '${result.eventsCount} planned events, '
        '${result.activitiesCount} activities');

    final stored = await eventsRepository.getRange(
      _formatDate(weekStart),
      _formatDate(weekEnd),
    );
    expect(stored, hasLength(result.eventsCount));
    for (final event in stored) {
      expect(event.id, isNotEmpty);
      expect(event.date, matches(r'^\d{4}-\d{2}-\d{2}$'));
    }
  });

  test('re-syncing planned events drops entries deleted upstream',
      skip: _skip, () async {
    await IntervalsSession.instance.connect(_apiKey);

    final (weekStart, weekEnd) = SyncService.todayWindow();
    await syncService.syncTodayWindow();

    // A stale plan the server no longer knows about. The next sync must
    // clear it rather than leave a ghost session on the Today screen.
    final db = await database.database;
    await db.insert('events', {
      'id': 'stale-ghost-event',
      'date': _formatDate(weekStart),
      'category': 'WORKOUT',
      'type': 'Ride',
      'name': 'Deleted upstream',
      'description': null,
      'planned_load': 99,
      'planned_time': null,
      'planned_distance': null,
      'indoor': 0,
      'raw': '{}',
      'synced_at': DateTime.now().millisecondsSinceEpoch,
    });

    await syncService.syncTodayWindow();

    final stored = await eventsRepository.getRange(
      _formatDate(weekStart),
      _formatDate(weekEnd),
    );
    expect(stored.map((e) => e.id), isNot(contains('stale-ghost-event')));
  });

  test('moving a created workout keeps its steps', skip: _skip, () async {
    await IntervalsSession.instance.connect(_apiKey);
    final service = IntervalsWorkoutService();
    final day = DateTime.now().add(const Duration(days: 30));
    final moved = day.add(const Duration(days: 1));

    final created = await service.createPlannedWorkout(
      PlannedWorkoutDraft(
        name: 'TriIQ live test: move me',
        sport: 'Ride',
        description: '- 10m 55%\n- 20m 70%\n- 5m 50%',
        date: day,
        durationSeconds: 35 * 60,
      ),
    );
    final id = created.id!.toString();
    try {
      await service.updatePlannedWorkoutDate(id, moved);

      final client = IntervalsSession.instance.client!;
      final event = (await client.getVeranstaltungenApi().showEvent(
        id: IntervalsSession.instance.athleteId!,
        eventId: created.id!,
      )).data!;
      expect(event.startDateLocal, startsWith(_formatDate(moved)));
      expect(event.name, 'TriIQ live test: move me');
      expect(event.description, contains('20m 70%'));
    } finally {
      await service.deletePlannedWorkout(id);
    }
  });

  test('real icu_achievements parse into best efforts', skip: _skip,
      () async {
    await IntervalsSession.instance.connect(_apiKey);
    final now = DateTime.now();
    await syncService.syncRange(now.subtract(const Duration(days: 365)), now);
    final all = await activitiesRepository.getRange(
      _formatDate(now.subtract(const Duration(days: 365))),
      _formatDate(now),
    );
    final withAchievements = all.where(
      (a) => a.raw['icu_achievements'] is List &&
          (a.raw['icu_achievements'] as List).isNotEmpty,
    );
    if (withAchievements.isEmpty) {
      // ignore: avoid_print
      print('No activity with icu_achievements in the last year.');
      return;
    }
    final sample = withAchievements.first;
    // ignore: avoid_print
    print('icu_achievements of ${sample.id}: ${sample.raw['icu_achievements']}');
    expect(personalBests(sample.raw), isNotEmpty,
        reason: 'the parser should read the real payload');
  });

  test('performance curves fetch and parse for every sport and metric',
      skip: _skip, () async {
    await IntervalsSession.instance.connect(_apiKey);
    final repo = PerformanceCurvesRepository(
      database: database,
      newestActivity: (_) async => null,
    );
    for (final sport in CurveSport.values) {
      for (final metric in CurveMetric.values) {
        final curves = await repo.load(sport, metric, force: true);
        final s0 = curves.period('s0');
        // ignore: avoid_print
        print('${sport.name}/${metric.name}: '
            '${curves.periods.map((p) => '${p.id}=${p.points.length}').join(' ')}'
            ' model=${s0?.model?.toJson()}');
        // A sport the account never did may come back empty; what matters
        // is that the real payload fetches with our auth and parses.
        if (s0 != null && s0.points.length > 1) {
          expect(s0.points.first.x, lessThan(s0.points.last.x));
        }
      }
    }
  });

  test('wellness carries the keys daily readiness reads', skip: _skip,
      () async {
    await IntervalsSession.instance.connect(_apiKey);

    final newest = DateTime.now();
    final oldest = newest.subtract(const Duration(days: 60));
    await syncService.syncRange(oldest, newest);
    final records = await wellnessRepository.getRange(
      _formatDate(oldest),
      _formatDate(newest),
    );

    const keys = [
      'hrv',
      'restingHR',
      'sleepSecs',
      'readiness',
      'fatigue',
      'soreness',
    ];
    final counts = {
      for (final key in keys) key: records.where((r) => r.raw[key] != null).length,
    };
    // ignore: avoid_print
    print('wellness records: ${records.length}, non-null per key: $counts');

    expect(
      counts['hrv']! + counts['restingHR']! + counts['sleepSecs']!,
      greaterThan(0),
      reason: 'no HRV, resting HR or sleep in 60 days: either the account '
          'has no wearable data or the keys are named differently',
    );
    // Intervals.icu's subjective scores are 1 (good) .. 4 (bad); readiness
    // treats 4 as the worst level.
    for (final record in records) {
      for (final key in const ['fatigue', 'soreness']) {
        final value = record.raw[key];
        if (value != null) {
          expect(value, inInclusiveRange(1, 4), reason: '$key on ${record.date}');
        }
      }
    }
  });
}

String _formatDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';
