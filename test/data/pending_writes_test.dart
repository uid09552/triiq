import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/client/intervalls/intervalls_client.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/intervals_workout_service.dart';
import 'package:triiq/data/pending_writes.dart';
import 'package:triiq/data/repositories/events_repository.dart';
import 'package:triiq/data/repositories/plans_repository.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/plan/knowledge.dart' show SessionSlot;
import 'package:triiq/plan/plan_actions.dart';
import 'package:triiq/plan/plan_models.dart';

/// Upstream that can be switched offline; records what reached it.
class _Upstream implements PlannedWorkoutWriter {
  bool offline = false;
  int? rejectWith;
  final calls = <String>[];
  int nextId = 500;

  void _gate() {
    if (offline) {
      throw DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.connectionError,
      );
    }
    if (rejectWith != null) {
      throw DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(),
          statusCode: rejectWith,
        ),
      );
    }
  }

  @override
  Future<Event> createPlannedWorkout(PlannedWorkoutDraft d) async {
    _gate();
    calls.add('create ${d.name} ${d.date.toIso8601String().substring(0, 10)}');
    return Event(id: nextId++);
  }

  @override
  Future<void> deletePlannedWorkout(String id) async {
    _gate();
    calls.add('delete $id');
  }

  @override
  Future<void> updatePlannedWorkoutDate(String id, DateTime date) async {
    _gate();
    calls.add('move $id ${date.toIso8601String().substring(0, 10)}');
  }
}

void main() {
  late Directory dir;
  late AppDatabase database;
  late _Upstream upstream;
  late PendingWritesService service;
  late QueuedWorkoutWriter writer;
  late PlansRepository plans;

  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dir = await Directory.systemTemp.createTemp('triiq_queue');
    database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
    upstream = _Upstream();
    plans = PlansRepository(database: database);
    service = PendingWritesService(
      athleteId: () async => 'i1',
      connectedAthleteId: () => 'i1',
      repository: PendingWritesRepository(database: database),
      writer: upstream,
      plans: plans,
      events: EventsRepository(database: database),
    );
    writer = QueuedWorkoutWriter(
      inner: upstream,
      queue: service,
      queueCreates: true,
    );
  });

  tearDown(() async {
    await database.close();
    await dir.delete(recursive: true);
  });

  test('online writes go straight through and queue nothing', () async {
    await writer.deletePlannedWorkout('1');
    await writer.updatePlannedWorkoutDate('2', DateTime(2026, 5, 3));
    expect(upstream.calls, ['delete 1', 'move 2 2026-05-03']);
    expect(service.pending, 0);
  });

  test('offline delete and move are queued, then replayed in order', () async {
    upstream.offline = true;
    await writer.deletePlannedWorkout('1'); // no throw
    await writer.updatePlannedWorkoutDate('2', DateTime(2026, 5, 3));
    expect(service.pending, 2);
    expect(await service.flush(), 0); // still offline: nothing lost
    expect(service.pending, 2);

    upstream.offline = false;
    expect(await service.flush(), 2);
    expect(upstream.calls, ['delete 1', 'move 2 2026-05-03']);
    expect(service.pending, 0);
  });

  test('a queued delete is hidden from sync until it is sent', () async {
    upstream.offline = true;
    await writer.deletePlannedWorkout('77');
    expect(await service.pendingDeleteIds(), {'77'});
    upstream.offline = false;
    await service.flush();
    expect(await service.pendingDeleteIds(), isEmpty);
  });

  test(
    'a server rejection is not queued by the writer and is rethrown',
    () async {
      upstream.rejectWith = 403;
      await expectLater(
        writer.deletePlannedWorkout('1'),
        throwsA(isA<DioException>()),
      );
      expect(service.pending, 0);
    },
  );

  test(
    'a write the server keeps rejecting is parked as failed, then retried',
    () async {
      upstream.offline = true;
      await writer.deletePlannedWorkout('1');
      upstream.offline = false;
      upstream.rejectWith = 400;
      await service.flush();
      expect(service.pending, 0);
      expect(service.failed, 1);
      upstream.rejectWith = null;
      await service.retryFailed();
      expect(service.failed, 0);
      expect(upstream.calls, ['delete 1']);
      // And a failed one can be discarded.
      upstream.rejectWith = 400;
      upstream.offline = true;
      await writer.deletePlannedWorkout('9');
      upstream.offline = false;
      await service.flush();
      await service.discardFailed();
      expect(service.failed, 0);
    },
  );

  test('already gone upstream (404) counts as sent', () async {
    upstream.offline = true;
    await writer.deletePlannedWorkout('1');
    upstream.offline = false;
    upstream.rejectWith = 404;
    expect(await service.flush(), 1);
    expect(service.failed, 0);
  });

  test(
    'offline create is queued, throws QueuedOffline, and links the session later',
    () async {
      final planId = (await plans.save(_plan())).id!;
      final stored = (await plans.getById(planId))!.sessions.single;
      final draft = PlannedWorkoutDraft(
        name: stored.name,
        sport: stored.sport,
        description: stored.description,
        date: stored.date,
        durationSeconds: stored.minutes * 60,
        load: stored.load,
        tags: ['triiq-plan-$planId'],
        externalId: 'triiq-plan-$planId-${stored.id}',
      );
      upstream.offline = true;
      await expectLater(
        writer.createPlannedWorkout(draft),
        throwsA(isA<QueuedOfflineException>()),
      );
      expect(service.pending, 1);

      // The athlete moved the session while offline: the send uses the new date.
      await plans.updateSession(stored.copyWith(date: DateTime(2026, 6, 9)));
      upstream.offline = false;
      expect(await service.flush(), 1);
      expect(upstream.calls, ['create ${stored.name} 2026-06-09']);
      final after = (await plans.getById(planId))!.sessions.single;
      expect(after.intervalsEventId, '500');
      expect(after.status, PlanSessionStatus.created);
    },
  );

  test('a queued create for a session deleted meanwhile is dropped', () async {
    final planId = (await plans.save(_plan())).id!;
    final stored = (await plans.getById(planId))!.sessions.single;
    upstream.offline = true;
    try {
      await writer.createPlannedWorkout(
        PlannedWorkoutDraft(
          name: 'x',
          sport: 'Run',
          description: 'd',
          date: stored.date,
          externalId: 'triiq-plan-$planId-${stored.id}',
        ),
      );
    } on QueuedOfflineException {
      // expected
    }
    await plans.deleteSession(stored.id!);
    upstream.offline = false;
    expect(await service.flush(), 1);
    expect(upstream.calls, isEmpty);
  });

  test(
    'creates are not queued unless asked, so callers see the error',
    () async {
      final plain = QueuedWorkoutWriter(inner: upstream, queue: service);
      upstream.offline = true;
      await expectLater(
        plain.createPlannedWorkout(
          PlannedWorkoutDraft(
            name: 'x',
            sport: 'Run',
            description: '',
            date: DateTime(2026),
          ),
        ),
        throwsA(isA<DioException>()),
      );
      expect(service.pending, 0);
    },
  );

  group('PlanActions offline', () {
    Future<(PlanActions, int)> sent() async {
      final planId = (await plans.save(_plan())).id!;
      final stored = (await plans.getById(planId))!.sessions.single;
      await plans.updateSession(
        stored.copyWith(
          intervalsEventId: '900',
          status: PlanSessionStatus.created,
        ),
      );
      await plans.setStatus(planId, PlanStatus.active);
      final actions = PlanActions(
        workouts: writer,
        plans: plans,
        events: EventsRepository(database: database),
        activities: ActivitiesRepository(database: database),
        sendEnabled: () => true,
        connected: () => true,
        resync: (_) async {},
        clock: () => DateTime(2026, 6, 1),
      );
      return (actions, stored.id!);
    }

    test(
      'moving a sent session offline changes it locally and queues the move',
      () async {
        final (actions, id) = await sent();
        upstream.offline = true;
        await actions.moveSession(id, DateTime(2026, 6, 4));
        expect((await plans.getSession(id))!.date, DateTime(2026, 6, 4));
        expect(service.pending, 1);
        upstream.offline = false;
        await service.flush();
        expect(upstream.calls, ['move 900 2026-06-04']);
      },
    );

    test(
      'removing a sent session offline drops it locally and queues the delete',
      () async {
        final (actions, id) = await sent();
        upstream.offline = true;
        await actions.removeSession(id);
        expect(await plans.getSession(id), isNull);
        expect(await service.pendingDeleteIds(), {'900'});
        upstream.offline = false;
        await service.flush();
        expect(upstream.calls, ['delete 900']);
      },
    );
  });

  group('writes belong to an account', () {
    PendingWritesService withAccount({
      required Future<String?> Function() athlete,
      required String? Function() connected,
    }) => PendingWritesService(
      athleteId: athlete,
      connectedAthleteId: connected,
      repository: PendingWritesRepository(database: database),
      writer: upstream,
      plans: plans,
      events: EventsRepository(database: database),
    );

    test(
      'with no known account nothing is queued and the error surfaces',
      () async {
        final none = withAccount(
          athlete: () async => null,
          connected: () => null,
        );
        final w = QueuedWorkoutWriter(inner: upstream, queue: none);
        upstream.offline = true;
        await expectLater(
          w.deletePlannedWorkout('1'),
          throwsA(isA<DioException>()),
        );
        await expectLater(
          w.updatePlannedWorkoutDate('1', DateTime(2026, 5, 3)),
          throwsA(isA<DioException>()),
        );
        expect(none.pending, 0);
        expect(await none.canQueue(), isFalse);
      },
    );

    test('a write made in another account is dropped, never sent', () async {
      var connected = 'i1';
      final svc = withAccount(
        athlete: () async => connected,
        connected: () => connected,
      );
      final w = QueuedWorkoutWriter(inner: upstream, queue: svc);
      upstream.offline = true;
      await w.deletePlannedWorkout('77'); // queued for i1
      upstream.offline = false;
      connected = 'i2'; // the athlete switched accounts
      expect(await svc.flush(), 0);
      expect(upstream.calls, isEmpty);
      expect(svc.pending, 0);
    });

    test('clearAll (on disconnect) drops everything waiting', () async {
      upstream.offline = true;
      await writer.deletePlannedWorkout('1');
      await writer.updatePlannedWorkoutDate('2', DateTime(2026, 5, 3));
      expect(service.pending, 2);
      await service.clearAll();
      expect(service.pending, 0);
      upstream.offline = false;
      expect(await service.flush(), 0);
      expect(upstream.calls, isEmpty);
    });
  });

  test('isOfflineError', () {
    expect(
      isOfflineError(StateError('Not connected to Intervals.icu.')),
      isTrue,
    );
    expect(isOfflineError(StateError('other')), isFalse);
    expect(isOfflineError(const SocketException('x')), isTrue);
    expect(
      isOfflineError(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.connectionTimeout,
        ),
      ),
      isTrue,
    );
    expect(
      isOfflineError(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
        ),
      ),
      isFalse,
    );
  });
}

TrainingPlan _plan() => TrainingPlan(
  goalType: 'x',
  sport: 'Run',
  startDate: DateTime(2026, 6, 1),
  baselineLoad: 300,
  weeks: [
    PlanWeek(
      index: 0,
      phase: 'base',
      startDate: DateTime(2026, 6, 1),
      targetLoad: 300,
      requestedLoad: 300,
      limit: WeekLimit.none,
      projectedCtlEnd: 40,
      lowIntensityTarget: 0.8,
      lowIntensityTolerance: 0.1,
      sessions: [
        PlanSession(
          weekIndex: 0,
          date: DateTime(2026, 6, 2),
          slot: SessionSlot.z2,
          templateId: 't',
          name: 'Easy run',
          sport: 'Run',
          minutes: 45,
          load: 40,
          lowMinutes: 45,
          description: '- 45m Z2',
        ),
      ],
    ),
  ],
);
