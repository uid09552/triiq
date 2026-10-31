import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:triiq/agent/tools/training_data_tools.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/data/models/local_wellness.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/data/repositories/events_repository.dart';
import 'package:triiq/data/repositories/plans_repository.dart';
import 'package:triiq/data/repositories/sync_state_repository.dart';
import 'package:triiq/data/repositories/wellness_repository.dart';

/// The agent's tools, exercised against a real (temporary) SQLite cache —
/// the tools' whole job is turning cached rows into JSON an LLM can reason
/// over, so stubbing the repositories away would test nothing.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late AppDatabase database;
  late WellnessRepository wellnessRepository;
  late ActivitiesRepository activitiesRepository;
  late EventsRepository eventsRepository;
  late SyncStateRepository syncStateRepository;
  late TrainingDataTools tools;

  /// Sunday, so the week bucket is 2026-08-24..2026-08-30.
  final now = DateTime(2026, 8, 30, 9);

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('triiq_agent_tools');
    database = AppDatabase.atPath(p.join(tempDir.path, 'triiq.db'));
    wellnessRepository = WellnessRepository(database: database);
    activitiesRepository = ActivitiesRepository(database: database);
    eventsRepository = EventsRepository(database: database);
    syncStateRepository = SyncStateRepository(database: database);
    tools = TrainingDataTools(
      wellnessRepository: wellnessRepository,
      activitiesRepository: activitiesRepository,
      eventsRepository: eventsRepository,
      plansRepository: PlansRepository(database: database),
      syncStateRepository: syncStateRepository,
      clock: () => now,
      loadTrainingGuidance: () async => _guidanceFixture,
    );
  });

  tearDown(() async {
    await database.close();
    await tempDir.delete(recursive: true);
  });

  Future<Map<String, dynamic>> call(
    String name, [
    Map<String, dynamic> args = const {},
  ]) async {
    final tool = tools.build().firstWhere((t) => t.name == name);
    final output = await tool.invoke(tool.getInputFromJson(args));
    return jsonDecode(output as String) as Map<String, dynamic>;
  }

  test('get_athlete_context reports the date, cache and thresholds', () async {
    await activitiesRepository.upsertAll([
      _activity(id: 'a1', date: '2026-06-01', sport: 'Ride', ftp: 240),
      _activity(id: 'a2', date: '2026-08-20', sport: 'Ride', ftp: 262),
      _activity(id: 'a3', date: '2026-08-21', sport: 'Run', lthr: 168),
    ]);
    await syncStateRepository.recordSync(
      'activities',
      oldest: '2026-01-01',
      newest: '2026-08-30',
    );

    final result = await call('get_athlete_context');

    expect(result['today'], '2026-08-30');
    expect(result['weekday'], 'Sunday');
    expect(result['cached_ranges'], {'activities': '2026-01-01 to 2026-08-30'});

    final thresholds = (result['thresholds'] as List)
        .cast<Map<String, dynamic>>();
    final ride = thresholds.firstWhere((t) => t['sport'] == 'Ride');
    // The newest Ride wins: thresholds move, and the stale 240 W would send
    // every zone calculation off.
    expect(ride['ftp'], 262);
    expect(ride['as_of'], '2026-08-20');
    expect(
      thresholds.firstWhere((t) => t['sport'] == 'Run')['lthr'],
      168,
    );
  });

  test('get_daily_metrics derives TSB and keeps the wellness fields', () async {
    await wellnessRepository.upsertAll([
      _wellness(date: '2026-08-29', ctl: 62.4, atl: 78.1, restingHr: 46),
      _wellness(date: '2026-08-30', ctl: 63.0, atl: 71.5, restingHr: 44),
    ]);

    final result = await call('get_daily_metrics', {
      'start_date': '2026-08-24',
      'end_date': '2026-08-30',
    });

    final days = (result['days'] as List).cast<Map<String, dynamic>>();
    expect(days, hasLength(2));
    expect(days.last['date'], '2026-08-30');
    expect(days.last['tsb'], closeTo(-8.5, 0.05));
    expect(days.last['resting_hr'], 44);
    expect(days.last['hrv'], 68);
    // Nulls are stripped rather than shipped as `"weight_kg": null`.
    expect(days.last.containsKey('weight_kg'), isFalse);
  });

  test('get_daily_metrics refuses a range longer than it will return',
      () async {
    final result = await call('get_daily_metrics', {
      'start_date': '2020-01-01',
      'end_date': '2026-08-30',
    });

    expect(result['error'], contains('shorter range'));
    expect(result.containsKey('days'), isFalse);
  });

  test('get_activities filters by sport and truncates newest-first', () async {
    await activitiesRepository.upsertAll([
      for (var day = 1; day <= 5; day++)
        _activity(
          id: 'ride$day',
          date: '2026-08-0$day',
          sport: 'Ride',
          load: day * 10,
        ),
      _activity(id: 'swim', date: '2026-08-03', sport: 'Swim', load: 30),
    ]);

    final result = await call('get_activities', {
      'start_date': '2026-08-01',
      'end_date': '2026-08-31',
      'sport': 'ride',
      'limit': 2,
    });

    expect(result['total_matching'], 5);
    expect(result['returned'], 2);
    expect(result['note'], contains('Truncated'));
    final activities = (result['activities'] as List)
        .cast<Map<String, dynamic>>();
    expect(activities.map((a) => a['id']), ['ride5', 'ride4']);
    expect(activities.first['training_load'], 50);
  });

  test('get_training_summary buckets by week with an intensity split',
      () async {
    await activitiesRepository.upsertAll([
      // Previous week.
      _activity(
        id: 'w1',
        date: '2026-08-19',
        sport: 'Ride',
        load: 80,
        movingTime: 3600,
        zoneSeconds: [1800, 1200, 300, 200, 100, 0, 0],
      ),
      // Current week: one ride with zone data, one run without.
      _activity(
        id: 'w2',
        date: '2026-08-25',
        sport: 'Ride',
        load: 120,
        movingTime: 7200,
        zoneSeconds: [4000, 2000, 600, 400, 200, 0, 0],
      ),
      _activity(
        id: 'w3',
        date: '2026-08-27',
        sport: 'Run',
        load: 60,
        movingTime: 2700,
      ),
    ]);
    await eventsRepository.replaceRange('2026-08-24', '2026-08-30', [
      _event(id: 'e1', date: '2026-08-25', plannedLoad: 130),
      _event(id: 'e2', date: '2026-08-26', category: 'NOTE', plannedLoad: 999),
    ]);
    await wellnessRepository.upsertAll([
      _wellness(date: '2026-08-24', ctl: 60, atl: 55),
      _wellness(date: '2026-08-30', ctl: 64, atl: 72),
    ]);

    final result = await call('get_training_summary', {
      'start_date': '2026-08-17',
      'end_date': '2026-08-30',
    });

    final buckets = (result['buckets'] as List).cast<Map<String, dynamic>>();
    expect(buckets.map((b) => b['start_date']), ['2026-08-17', '2026-08-24']);

    final thisWeek = buckets.last;
    expect(thisWeek['completed_load'], 180);
    // The NOTE is not training, so its load must not land in the plan.
    expect(thisWeek['planned_load'], 130);
    expect(thisWeek['sessions'], 2);
    expect(thisWeek['by_sport'], {
      'Ride': {
        'sessions': 1,
        'load': 120,
        'moving_time_s': 7200,
        'distance_m': 0,
      },
      'Run': {
        'sessions': 1,
        'load': 60,
        'moving_time_s': 2700,
        'distance_m': 0,
      },
    });

    final intensity = thisWeek['intensity_s'] as Map<String, dynamic>;
    expect(intensity['low'], 6000);
    expect(intensity['moderate'], 1000);
    expect(intensity['high'], 200);
    expect(intensity['low_percent'], 83);
    // The run had no zone times; the count says so rather than the split
    // quietly pretending the run never happened.
    expect(intensity['sessions_without_zone_data'], 1);

    expect(thisWeek['ctl_end'], 64);
    expect(thisWeek['tsb_end'], -8);
    expect(thisWeek['ctl_change'], 4);
    expect(result['totals'], containsPair('completed_load', 260));
  });

  test('get_training_summary flags a range with no zone data at all',
      () async {
    await activitiesRepository.upsertAll([
      _activity(id: 'manual', date: '2026-08-25', sport: 'Swim', load: 40),
    ]);

    final result = await call('get_training_summary', {
      'start_date': '2026-08-24',
      'end_date': '2026-08-30',
    });

    final bucket = (result['buckets'] as List).first as Map<String, dynamic>;
    expect(bucket.containsKey('intensity_s'), isFalse);
    expect(bucket['intensity_note'], contains('cannot be checked'));
  });

  test('get_training_guidance lists sections and returns the best match',
      () async {
    final listing = await call('get_training_guidance', {'topic': ''});
    expect(
      (listing['sections'] as List).cast<String>(),
      ['1. The 80/20 Principle', '2. Recovery Weeks'],
    );

    final match = await call('get_training_guidance', {
      'topic': 'recovery week',
    });
    final matches = (match['matches'] as List).cast<Map<String, dynamic>>();
    expect(matches.first['title'], '2. Recovery Weeks');
    expect(matches.first['text'], contains('reduced-load week'));
  });

  test('a malformed date comes back as a readable error, not an exception',
      () async {
    final result = await call('get_activities', {
      'start_date': 'last monday',
      'end_date': '2026-08-30',
    });

    expect(result['error'], contains('YYYY-MM-DD'));
  });

  test('sync_from_intervals refuses to run while disconnected', () async {
    final result = await call('sync_from_intervals', {
      'start_date': '2026-08-01',
      'end_date': '2026-08-30',
    });

    expect(result['error'], contains('Not connected'));
  });
}

const _guidanceFixture = '''
# 1. The 80/20 Principle

Roughly 80% of training time is spent at low intensity.

# 2. Recovery Weeks

A reduced-load week lets accumulated fatigue clear.
''';

LocalActivity _activity({
  required String id,
  required String date,
  required String sport,
  int? load,
  int? movingTime,
  int? ftp,
  int? lthr,
  List<int>? zoneSeconds,
}) => LocalActivity(
  id: id,
  date: date,
  type: sport,
  name: '$sport $date',
  movingTime: movingTime,
  distance: 0,
  trainingLoad: load,
  raw: {
    'id': id,
    'type': sport,
    'icu_ftp': ?ftp,
    'lthr': ?lthr,
    if (zoneSeconds != null)
      'icu_zone_times': [
        for (final (index, secs) in zoneSeconds.indexed)
          {'id': 'Z${index + 1}', 'secs': secs},
      ],
  },
  syncedAt: DateTime(2026, 8, 30),
);

LocalWellness _wellness({
  required String date,
  double? ctl,
  double? atl,
  int? restingHr,
}) => LocalWellness(
  date: date,
  ctl: ctl,
  atl: atl,
  ctlLoad: null,
  atlLoad: null,
  rampRate: null,
  raw: {
    'id': date,
    'ctl': ctl,
    'atl': atl,
    'restingHR': ?restingHr,
    'hrv': 68.0,
  },
  syncedAt: DateTime(2026, 8, 30),
);

LocalEvent _event({
  required String id,
  required String date,
  String category = 'WORKOUT',
  int? plannedLoad,
}) => LocalEvent(
  id: id,
  date: date,
  category: category,
  type: 'Ride',
  name: 'Planned $date',
  description: null,
  plannedLoad: plannedLoad,
  plannedTime: null,
  plannedDistance: null,
  indoor: false,
  raw: {'id': id},
  syncedAt: DateTime(2026, 8, 30),
);
