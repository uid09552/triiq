import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/client/intervalls/intervalls_client.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/intervals_session.dart';
import 'package:triiq/data/repositories/wellness_repository.dart';
import 'package:triiq/data/sync/auto_sync_service.dart';
import 'package:triiq/data/wellness_actions.dart';
import 'package:triiq/util/dates.dart';

void main() {
  late Directory dir;
  late AppDatabase database;
  late WellnessRepository wellness;

  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dir = await Directory.systemTemp.createTemp('triiq_wellness_actions');
    database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
    wellness = WellnessRepository(database: database);
  });

  tearDown(() async {
    await database.close();
    await dir.delete(recursive: true);
  });

  test('a connected call sends fatigue/soreness, caches the response, '
      'and notifies listeners', () async {
    final requests = <RequestOptions>[];
    final dio = Dio(BaseOptions(baseUrl: 'https://intervals.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'id': '2026-11-03',
                'ctl': 50.0,
                'atl': 40.0,
                'fatigue': 2,
                'soreness': 1,
              },
            ),
          );
        },
      ),
    );
    final session = IntervalsSession.forTesting(
      connected: true,
      client: IntervallsClient(dio: dio, interceptors: const []),
      athleteId: 'i42',
    );
    final actions = WellnessActions(session: session, wellness: wellness);
    var notified = false;
    void onChanged() => notified = true;
    AutoSyncService.instance.addListener(onChanged);
    addTearDown(() => AutoSyncService.instance.removeListener(onChanged));

    final result = await actions.setFeel(
      date: '2026-11-03',
      fatigue: 2,
      soreness: 1,
    );

    final request = requests.single;
    expect(request.method, 'PUT');
    expect(request.path, '/api/v1/athlete/i42/wellness/2026-11-03');
    final body = request.data is String
        ? request.data as String
        : request.data.toString();
    expect(body, contains('"fatigue":2'));
    expect(body, contains('"soreness":1'));

    expect(result.date, '2026-11-03');
    expect(result.raw['fatigue'], 2);
    expect(result.raw['soreness'], 1);
    final cached = await wellness.getByDate('2026-11-03');
    expect(cached!.raw['fatigue'], 2);
    expect(cached.raw['soreness'], 1);
    expect(notified, isTrue);
  });

  test('not connected: throws without touching the cache', () async {
    final session = IntervalsSession.forTesting(connected: false);
    final actions = WellnessActions(session: session, wellness: wellness);

    expect(
      () => actions.setFeel(
        date: isoDate(DateTime.now()),
        fatigue: 1,
        soreness: 1,
      ),
      throwsStateError,
    );
    expect(await wellness.getByDate(isoDate(DateTime.now())), isNull);
  });
}
