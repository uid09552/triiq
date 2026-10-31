import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/evaluation/new_training.dart';

LocalActivity act(String id, String date, String start) => LocalActivity(
  id: id,
  date: date,
  type: 'Run',
  name: id,
  movingTime: 1800,
  distance: null,
  trainingLoad: 30,
  raw: {'start_date_local': start},
  syncedAt: DateTime(2026, 11, 3),
);

void main() {
  late Directory dir;
  late AppDatabase database;
  late ActivitiesRepository activities;
  var now = DateTime(2026, 11, 3, 19);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dir = await Directory.systemTemp.createTemp('triiq_new_training');
    database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
    activities = ActivitiesRepository(database: database);
    now = DateTime(2026, 11, 3, 19);
    await activities.upsertAll([
      act('yesterday', '2026-11-02', '2026-11-02T07:00:00'),
      act('swim', '2026-11-03', '2026-11-03T06:30:00'),
      act('run', '2026-11-03', '2026-11-03T17:45:00'),
    ]);
  });

  tearDown(() async {
    await database.close();
    await dir.delete(recursive: true);
  });

  NewTrainingInsights insights() =>
      NewTrainingInsights(activities: activities, clock: () => now);

  test('today only, newest first; yesterday never', () async {
    final fresh = await insights().unseenToday();
    expect(fresh.map((a) => a.id), ['run', 'swim']);
  });

  test('seen survives a restart', () async {
    await insights().seen.markSeen(['run']);

    // A new store instance reads what the first one wrote.
    final again = await insights().unseenToday();
    expect(again.map((a) => a.id), ['swim']);
  });

  test('a new day forgets the old ids', () async {
    await insights().seen.markSeen(['run', 'swim']);
    expect(await insights().unseenToday(), isEmpty);

    now = DateTime(2026, 11, 4, 8);
    expect(await insights().seen.seenToday(), isEmpty);
    expect(await insights().unseenToday(), isEmpty, reason: 'nothing today');
  });
}
