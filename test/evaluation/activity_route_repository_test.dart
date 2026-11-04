import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/evaluation/activity_route.dart';

void main() {
  late Directory dir;
  late AppDatabase database;

  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dir = await Directory.systemTemp.createTemp('triiq_route');
    database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
  });

  tearDown(() async {
    await database.close();
    await dir.delete(recursive: true);
  });

  test('fetched once, then served from SQLite — also an empty track', () async {
    var fetches = 0;
    final repo = ActivityRouteRepository(
      database: database,
      fetch: (id) async {
        fetches++;
        return id == 'gps'
            ? ActivityRoute([for (var i = 0; i < 5; i++) RoutePoint(48.0 + i, 11.0)])
            : const ActivityRoute([]);
      },
    );
    expect((await repo.load('gps')).points, hasLength(5));
    expect((await repo.load('gps')).points, hasLength(5));
    expect((await repo.load('indoor')).isEmpty, isTrue);
    expect((await repo.load('indoor')).isEmpty, isTrue);
    expect(fetches, 2);
    expect(await repo.cached('never'), isNull);
  });
}
