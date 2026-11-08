import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/client/intervalls/intervalls_client.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/intervals_session.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/data/repositories/events_repository.dart';
import 'package:triiq/data/repositories/sync_state_repository.dart';
import 'package:triiq/data/repositories/wellness_repository.dart';
import 'package:triiq/data/sync/sync_service.dart';
import 'package:triiq/data/sync/sync_settings.dart';

/// A client whose every request answers `[]` and is remembered by path.
IntervallsClient _recordingClient(List<String> paths) {
  final dio = Dio(BaseOptions(baseUrl: 'https://intervals.test'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        paths.add(options.path);
        handler.resolve(
          Response(requestOptions: options, statusCode: 200, data: const []),
        );
      },
    ),
  );
  return IntervallsClient(dio: dio, interceptors: const []);
}

void main() {
  group('SyncSettings calendar switches', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('both default to on', () async {
      final settings = SyncSettings.forTesting();
      await settings.load();

      expect(settings.sendPlanToIntervals, isTrue);
      expect(settings.copyIntervalsEvents, isTrue);
      expect(await SyncSettings.readCopyIntervalsEvents(), isTrue);
    });

    test('they persist', () async {
      await SyncSettings.forTesting().setCopyIntervalsEvents(false);
      await SyncSettings.forTesting().setSendPlanToIntervals(false);

      final again = SyncSettings.forTesting();
      await again.load();
      expect(again.copyIntervalsEvents, isFalse);
      expect(again.sendPlanToIntervals, isFalse);
      expect(await SyncSettings.readCopyIntervalsEvents(), isFalse);
    });
  });

  group('SyncService and copying events', () {
    late Directory dir;
    late AppDatabase database;
    late EventsRepository events;
    late SyncStateRepository syncState;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      dir = await Directory.systemTemp.createTemp('triiq_calendar_settings');
      database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
      events = EventsRepository(database: database);
      syncState = SyncStateRepository(database: database);
    });

    tearDown(() async {
      await database.close();
      await dir.delete(recursive: true);
    });

    SyncService service(List<String> paths, {required bool copy}) =>
        SyncService(
          session: IntervalsSession.forTesting(
            connected: true,
            client: _recordingClient(paths),
            athleteId: 'i1',
          ),
          wellnessRepository: WellnessRepository(database: database),
          activitiesRepository: ActivitiesRepository(database: database),
          eventsRepository: events,
          syncStateRepository: syncState,
          copyEvents: () async => copy,
        );

    LocalEvent cached() => LocalEvent(
      id: '7',
      date: '2026-10-14',
      category: 'WORKOUT',
      type: 'Ride',
      name: 'Created in Intervals.icu',
      description: null,
      plannedLoad: 80,
      plannedTime: 3600,
      plannedDistance: null,
      indoor: false,
      raw: const {},
      syncedAt: DateTime(2026, 10, 1),
    );

    test('copy off: no events request, cached events kept', () async {
      await events.replaceRange('2026-10-01', '2026-10-31', [cached()]);
      final paths = <String>[];

      final result = await service(
        paths,
        copy: false,
      ).syncRange(DateTime(2026, 10, 1), DateTime(2026, 10, 31));

      expect(paths.any((path) => path.contains('/events')), isFalse);
      expect(paths, hasLength(2), reason: 'wellness and activities only');
      expect(result.eventsCount, 0);
      expect(await events.getRange('2026-10-01', '2026-10-31'), hasLength(1));
      expect(await syncState.get('events'), isNull);
    });

    test('copy on: events are fetched and replace the range', () async {
      await events.replaceRange('2026-10-01', '2026-10-31', [cached()]);
      final paths = <String>[];

      await service(
        paths,
        copy: true,
      ).syncRange(DateTime(2026, 10, 1), DateTime(2026, 10, 31));

      expect(paths.where((path) => path.contains('/events')), hasLength(1));
      expect(await events.getRange('2026-10-01', '2026-10-31'), isEmpty);
      expect(await syncState.get('events'), isNotNull);
    });
  });
}
