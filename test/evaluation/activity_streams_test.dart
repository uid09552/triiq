import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/evaluation/session_streams.dart';

void main() {
  late Directory dir;

  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dir = await Directory.systemTemp.createTemp('triiq_streams');
  });

  tearDown(() => dir.delete(recursive: true));

  test('a v3 cache upgrades to v4 with an empty streams table', () async {
    final path = p.join(dir.path, 'triiq.db');
    final old = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 3,
        onCreate: (db, _) async {
          await db.execute(
            'CREATE TABLE activities (id TEXT PRIMARY KEY, date TEXT)',
          );
          await db.insert('activities', {'id': 'a1', 'date': '2026-11-01'});
        },
      ),
    );
    await old.close();

    final database = AppDatabase.atPath(path);
    final db = await database.database;

    expect(await db.getVersion(), 4);
    expect(await db.query('activity_streams'), isEmpty);
    expect(await db.query('activities'), hasLength(1), reason: 'kept');
    await database.close();
  });

  test('streams are fetched once, then read from the cache', () async {
    final database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
    var fetches = 0;
    final repo = ActivityStreamsRepository(
      database: database,
      fetch: (id) async {
        fetches++;
        return SessionStreams(
          series: {
            'time': [0, 1, 2],
            'watts': [150, 210, null],
            'heartrate': [120, 130, 140],
          },
          intervals: const [
            SessionInterval(start: 1, end: 2, type: 'WORK', averageWatts: 210),
          ],
        );
      },
    );

    final first = await repo.load('i1');
    final second = await repo.load('i1');

    expect(fetches, 1);
    expect(second.series['watts'], [150, 210, null]);
    expect(second.intervals.single.averageWatts, 210);
    expect(first.drawable.toSet(), {'watts', 'heartrate'});
    await database.close();
  });

  test('an activity without streams is empty, not an error', () {
    const none = SessionStreams(series: {'time': []});
    expect(none.isEmpty, isTrue);
  });
}
