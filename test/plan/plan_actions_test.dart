import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/client/intervalls/intervalls_client.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/intervals_workout_service.dart';
import 'package:triiq/data/pending_writes.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/data/planned_items.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/data/repositories/events_repository.dart';
import 'package:triiq/data/repositories/plans_repository.dart';
import 'package:triiq/plan/knowledge.dart';
import 'package:triiq/plan/plan_actions.dart';
import 'package:triiq/plan/plan_engine.dart';
import 'package:triiq/plan/plan_models.dart';
import 'package:triiq/util/dates.dart';

class _FakeWorkouts implements PlannedWorkoutWriter {
  final created = <PlannedWorkoutDraft>[];
  final deleted = <String>[];
  bool failCreate = false;
  bool failMove = false;

  /// Fail only the n-th date change (1-based), for the swap rollback.
  int? failMoveNumber;
  int _moves = 0;
  final moved = <(String, DateTime)>[];
  Object? deleteError;

  @override
  Future<Event> createPlannedWorkout(PlannedWorkoutDraft draft) async {
    if (failCreate) throw StateError('create failed');
    created.add(draft);
    return Event(id: 900 + created.length);
  }

  @override
  Future<void> updatePlannedWorkoutDate(String eventId, DateTime date) async {
    if (failMove || ++_moves == failMoveNumber) {
      throw StateError('move failed');
    }
    moved.add((eventId, date));
  }

  @override
  Future<void> deletePlannedWorkout(String eventId) async {
    final error = deleteError;
    if (error != null) throw error;
    deleted.add(eventId);
  }
}

void main() {
  late Directory dir;
  late AppDatabase database;
  late PlansRepository plans;
  late EventsRepository events;
  late _FakeWorkouts workouts;
  late PendingWritesService queue;
  var send = true;
  var connected = true;
  final resynced = <DateTime>[];

  final day = DateTime(2026, 11, 3);

  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dir = await Directory.systemTemp.createTemp('triiq_plan_actions');
    database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
    plans = PlansRepository(database: database);
    events = EventsRepository(database: database);
    workouts = _FakeWorkouts();
    queue = PendingWritesService(
      athleteId: () async => 'i1',
      connectedAthleteId: () => 'i1',
      repository: PendingWritesRepository(database: database),
      writer: workouts,
      plans: plans,
      events: events,
    );
    send = true;
    connected = true;
    resynced.clear();
  });

  tearDown(() async {
    await database.close();
    await dir.delete(recursive: true);
  });

  PlanActions actions() => PlanActions(
    workouts: workouts,
    plans: plans,
    events: events,
    sendEnabled: () => send,
    connected: () => connected,
    queue: queue,
    resync: (d) async => resynced.add(d),
    goals: GoalStore(),
    clock: () => DateTime(2026, 11, 2, 9),
  );

  Future<PlanSession> planSession({String? eventId}) async {
    final draft =
        PlanEngine(
              TrainingKnowledge.parse(File('docs/okf.md').readAsStringSync()),
            )
            .generate(
              goal: const Goal(
                targetType: 'long_distance',
                weekdays: {2, 4, 6},
                weeklyHours: 6,
                baselineWeeklyLoad: 250,
                weeks: 2,
              ),
              startDate: DateTime(2026, 11, 2),
              recentWeeklyLoads: null,
              today: DateTime(2026, 10, 31),
            )
            .plan!;
    final saved = await plans.save(draft.copyWith(status: PlanStatus.active));
    var session = saved.sessions.firstWhere((s) => s.date == day);
    if (eventId != null) {
      session = session.copyWith(
        intervalsEventId: eventId,
        status: PlanSessionStatus.created,
      );
      await plans.updateSession(session);
    }
    return session;
  }

  PlannedWorkoutDraft alternative({int? load = 40}) => PlannedWorkoutDraft(
    name: 'Easy run',
    sport: 'Run',
    description: '- 45m 75% Pace',
    date: day,
    durationSeconds: 45 * 60,
    load: load,
  );

  LocalEvent intervalsEvent() => LocalEvent(
    id: '501',
    date: isoDate(day),
    category: 'WORKOUT',
    type: 'Ride',
    name: 'Coach ride',
    description: '- 60m 65%',
    plannedLoad: 60,
    plannedTime: 3600,
    plannedDistance: null,
    indoor: false,
    raw: const {},
    syncedAt: day,
  );

  group('a TriIQ plan session', () {
    test('only in TriIQ: changed locally, nothing upstream', () async {
      final session = await planSession();

      final outcome = await actions().replaceSession(
        PlannedItemsRepository.toLocalEvent(session),
        alternative(),
      );

      expect(outcome, ReplaceOutcome.replacedLocally);
      expect(workouts.created, isEmpty);
      final after = (await plans.getSession(session.id!))!;
      expect(after.name, 'Easy run');
      expect(after.sport, 'Run');
      expect(after.minutes, 45);
      expect(after.load, 40);
      expect(after.date, session.date);
      expect(after.weekIndex, session.weekIndex);
      expect(after.intervalsEventId, isNull);
    });

    test(
      'sent: new event created, old deleted, session points to new',
      () async {
        final session = await planSession(eventId: '300');

        final outcome = await actions().replaceSession(
          PlannedItemsRepository.toLocalEvent(session),
          alternative(),
        );

        expect(outcome, ReplaceOutcome.replaced);
        expect(workouts.created.single.date, session.date);
        expect(workouts.created.single.tags!.single, startsWith('triiq-plan-'));
        expect(workouts.deleted, ['300']);
        final after = (await plans.getSession(session.id!))!;
        expect(after.intervalsEventId, '901');
        expect(after.status, PlanSessionStatus.created);
        expect(resynced, [session.date]);
      },
    );

    test('sent but sending off: refused, nothing changes', () async {
      final session = await planSession(eventId: '300');
      send = false;

      await expectLater(
        actions().replaceSession(
          PlannedItemsRepository.toLocalEvent(session),
          alternative(),
        ),
        throwsA(
          isA<ReplaceRefusedException>().having(
            (e) => e.reason,
            'reason',
            ReplaceRefusal.sentButCannotSend,
          ),
        ),
      );
      expect(workouts.created, isEmpty);
      expect((await plans.getSession(session.id!))!.name, session.name);
    });

    test('sent, create fails: local plan unchanged', () async {
      final session = await planSession(eventId: '300');
      workouts.failCreate = true;

      await expectLater(
        actions().replaceSession(
          PlannedItemsRepository.toLocalEvent(session),
          alternative(),
        ),
        throwsStateError,
      );
      final after = (await plans.getSession(session.id!))!;
      expect(after.name, session.name);
      expect(after.intervalsEventId, '300');
    });

    test(
      'sent, delete fails: both exist, session points to the new one',
      () async {
        final session = await planSession(eventId: '300');
        workouts.deleteError = DioException(
          requestOptions: RequestOptions(path: '/events/300'),
          response: Response(
            requestOptions: RequestOptions(path: '/events/300'),
            statusCode: 500,
          ),
        );

        final outcome = await actions().replaceSession(
          PlannedItemsRepository.toLocalEvent(session),
          alternative(),
        );

        expect(outcome, ReplaceOutcome.bothExist);
        expect((await plans.getSession(session.id!))!.intervalsEventId, '901');
      },
    );

    test(
      'no TSS in the draft: keeps the old TSS and says it is estimated',
      () async {
        final session = await planSession();

        await actions().replaceSession(
          PlannedItemsRepository.toLocalEvent(session),
          alternative(load: null),
        );

        final after = (await plans.getSession(session.id!))!;
        expect(after.load, session.load);
        expect(after.description, contains(PlanActions.estimatedNote));
      },
    );
  });

  group('an Intervals.icu event', () {
    test(
      'new workout created, old deleted upstream and from the cache',
      () async {
        await events.replaceRange(isoDate(day), isoDate(day), [
          intervalsEvent(),
        ]);

        final outcome = await actions().replaceSession(
          intervalsEvent(),
          alternative(),
        );

        expect(outcome, ReplaceOutcome.replaced);
        expect(workouts.created.single.name, 'Easy run');
        expect(workouts.deleted, ['501']);
        expect(await events.getByDate(isoDate(day)), isEmpty);
      },
    );

    test('delete fails: both exist, cached event kept', () async {
      await events.replaceRange(isoDate(day), isoDate(day), [intervalsEvent()]);
      workouts.deleteError = StateError('offline');

      final outcome = await actions().replaceSession(
        intervalsEvent(),
        alternative(),
      );

      expect(outcome, ReplaceOutcome.bothExist);
      expect(await events.getByDate(isoDate(day)), hasLength(1));
    });

    test('not connected: shown as a placeholder, replace queued', () async {
      connected = false;
      await events.upsert(intervalsEvent());

      final outcome = await actions().replaceSession(
        intervalsEvent(),
        alternative(),
      );

      expect(outcome, ReplaceOutcome.queued);
      expect(workouts.created, isEmpty);
      final shown = await events.getByDate(isoDate(day));
      expect(shown.single.name, 'Easy run');
      expect(shown.single.id, startsWith('pending:'));
      expect(await queue.pendingDeleteIds(), {'501'});

      // Back online: the new workout is created, the old one deleted, the
      // placeholder dropped.
      connected = true;
      expect(await queue.flush(), 1);
      expect(workouts.created.single.name, 'Easy run');
      expect(workouts.deleted, ['501']);
      expect(await events.getByDate(isoDate(day)), isEmpty);
    });

    test('offline with no known account: refused, nothing changes locally',
        () async {
      final session = await planSession(eventId: '300');
      connected = false;
      final noAccount = PlanActions(
        workouts: workouts,
        plans: plans,
        events: events,
        sendEnabled: () => send,
        connected: () => connected,
        queue: PendingWritesService(
          athleteId: () async => null,
          connectedAthleteId: () => null,
          repository: PendingWritesRepository(database: database),
          writer: workouts,
          plans: plans,
          events: events,
        ),
        resync: (_) async {},
        goals: GoalStore(),
        clock: () => DateTime(2026, 11, 2, 9),
      );
      await expectLater(
        noAccount.replaceSession(
          PlannedItemsRepository.toLocalEvent(session),
          alternative(),
        ),
        throwsA(isA<ReplaceRefusedException>()),
      );
      final after = (await plans.getSession(session.id!))!;
      expect(after.name, session.name);
      expect(after.intervalsEventId, '300');
    });

    test('a sent plan session replaced offline shows the new content at once',
        () async {
      final session = await planSession(eventId: '300');
      await events.upsert(
        LocalEvent(
          id: '300', date: isoDate(day), category: 'WORKOUT', type: 'Run',
          name: 'old', description: '', plannedLoad: 50, plannedTime: 3600,
          plannedDistance: null, indoor: false, raw: const {}, syncedAt: day,
        ),
      );
      connected = false;

      final outcome = await actions().replaceSession(
        PlannedItemsRepository.toLocalEvent(session),
        alternative(),
      );

      expect(outcome, ReplaceOutcome.queued);
      final local = (await plans.getSession(session.id!))!;
      expect(local.name, 'Easy run');
      expect(local.intervalsEventId, isNull);
      expect(await events.getByDate(isoDate(day)), isEmpty); // old one hidden
      expect(queue.pending, 1);

      connected = true;
      await queue.flush();
      final after = (await plans.getSession(session.id!))!;
      expect(after.intervalsEventId, '901');
      expect(after.status, PlanSessionStatus.created);
      expect(workouts.deleted, ['300']);
    });

    test('a failed delete after the create does not create twice', () async {
      final session = await planSession(eventId: '300');
      connected = false;
      await actions().replaceSession(
        PlannedItemsRepository.toLocalEvent(session),
        alternative(),
      );
      connected = true;
      workouts.deleteError = StateError('boom');
      await queue.flush();
      expect(workouts.created, hasLength(1));
      workouts.deleteError = null;
      await queue.flush();
      expect(workouts.created, hasLength(1)); // not re-created
      expect(workouts.deleted, ['300']);
      expect(queue.pending, 0);
    });
  });

  group('moving and removing', () {
    test('a local session moves within the plan, nothing upstream', () async {
      final session = await planSession();
      final target = DateTime(2026, 11, 5);

      await actions().moveSession(session.id!, target);

      expect((await plans.getSession(session.id!))!.date, target);
      expect(workouts.moved, isEmpty);
    });

    test('a sent session moves upstream first', () async {
      final session = await planSession(eventId: '300');
      final target = DateTime(2026, 11, 8);

      await actions().moveSession(session.id!, target);

      expect(workouts.moved.single, ('300', target));
      expect((await plans.getSession(session.id!))!.date, target);
      expect(resynced, isNotEmpty);
    });

    test('upstream failure leaves the local date', () async {
      final session = await planSession(eventId: '300');
      workouts.failMove = true;

      await expectLater(
        actions().moveSession(session.id!, DateTime(2026, 11, 8)),
        throwsStateError,
      );
      expect((await plans.getSession(session.id!))!.date, session.date);
    });

    test(
      'past target, past session and dates outside the plan are refused',
      () async {
        final session = await planSession();
        Matcher refused(ReplaceRefusal r) => throwsA(
          isA<ReplaceRefusedException>().having((e) => e.reason, 'reason', r),
        );

        expect(
          actions().moveSession(session.id!, DateTime(2026, 11, 1)),
          refused(ReplaceRefusal.past),
        );
        expect(
          actions().moveSession(session.id!, DateTime(2026, 12, 1)),
          refused(ReplaceRefusal.outsidePlan),
        );
        final pastSession = (await plans.getCurrent())!.sessions.first;
        final late = PlanActions(
          workouts: workouts,
          plans: plans,
          events: events,
          sendEnabled: () => send,
          connected: () => connected,
          resync: (_) async {},
          clock: () => DateTime(2026, 11, 20),
        );
        await expectLater(
          late.removeSession(pastSession.id!),
          refused(ReplaceRefusal.past),
        );
        expect(await plans.getSession(pastSession.id!), isNotNull);
      },
    );

    test('remove a sent session: deleted upstream and from the plan', () async {
      final session = await planSession(eventId: '300');

      await actions().removeSession(session.id!);

      expect(workouts.deleted, ['300']);
      expect(await plans.getSession(session.id!), isNull);
    });

    test('remove with a failing upstream delete keeps the session', () async {
      final session = await planSession(eventId: '300');
      workouts.deleteError = DioException(
        requestOptions: RequestOptions(path: '/events/300'),
        response: Response(
          requestOptions: RequestOptions(path: '/events/300'),
          statusCode: 500,
        ),
      );

      await expectLater(
        actions().removeSession(session.id!),
        throwsA(isA<DioException>()),
      );
      expect(await plans.getSession(session.id!), isNotNull);
    });

    test(
      'a sent session with sending off cannot be moved or removed',
      () async {
        final session = await planSession(eventId: '300');
        send = false;

        await expectLater(
          actions().removeSession(session.id!),
          throwsA(isA<ReplaceRefusedException>()),
        );
        expect(await plans.getSession(session.id!), isNotNull);
      },
    );
  });

  group('swapping', () {
    Future<(PlanSession, PlanSession)> twoSent() async {
      final a = await planSession(eventId: '300');
      var b = (await plans.getCurrent())!.sessions.firstWhere(
        (s) => s.date == DateTime(2026, 11, 5),
      );
      b = b.copyWith(
        intervalsEventId: '301',
        status: PlanSessionStatus.created,
      );
      await plans.updateSession(b);
      return (a, b);
    }

    test('swaps the two dates, upstream too', () async {
      final (a, b) = await twoSent();

      await actions().swapSessions(a.id!, b.id!);

      expect((await plans.getSession(a.id!))!.date, b.date);
      expect((await plans.getSession(b.id!))!.date, a.date);
      expect(workouts.moved, [('300', b.date), ('301', a.date)]);
    });

    test('second move fails: the first is moved back', () async {
      final (a, b) = await twoSent();
      workouts.failMoveNumber = 2;

      await expectLater(actions().swapSessions(a.id!, b.id!), throwsStateError);

      expect((await plans.getSession(a.id!))!.date, a.date);
      expect((await plans.getSession(b.id!))!.date, b.date);
      expect(workouts.moved.last, ('300', a.date));
    });
  });

  group('missed sessions', () {
    // Wednesday 4 Nov: Tuesday's session is in the past.
    PlanActions wednesday() => PlanActions(
      workouts: workouts,
      plans: plans,
      events: events,
      activities: ActivitiesRepository(database: database),
      sendEnabled: () => send,
      connected: () => connected,
      resync: (_) async {},
      clock: () => DateTime(2026, 11, 4, 9),
    );
    Matcher refused(ReplaceRefusal r) => throwsA(
      isA<ReplaceRefusedException>().having((e) => e.reason, 'reason', r),
    );

    test('a missed session moves later in its week', () async {
      final session = await planSession();

      await wednesday().moveSession(
        session.id!,
        DateTime(2026, 11, 6),
        missed: true,
      );

      expect(
        (await plans.getSession(session.id!))!.date,
        DateTime(2026, 11, 6),
      );
    });

    test('without missed, a past session is still refused', () async {
      final session = await planSession();

      await expectLater(
        wednesday().moveSession(session.id!, DateTime(2026, 11, 6)),
        refused(ReplaceRefusal.past),
      );
    });

    test('done after all: refused even with missed', () async {
      final session = await planSession();
      await ActivitiesRepository(database: database).upsertAll([
        LocalActivity(
          id: 'r1',
          date: '2026-11-03',
          type: 'Run',
          name: 'Run',
          movingTime: 3000,
          distance: null,
          trainingLoad: 50,
          raw: const {},
          syncedAt: DateTime(2026),
        ),
      ]);

      await expectLater(
        wednesday().moveSession(
          session.id!,
          DateTime(2026, 11, 6),
          missed: true,
        ),
        refused(ReplaceRefusal.past),
      );
    });

    test('a missed session cannot move into next week', () async {
      final session = await planSession();

      await expectLater(
        wednesday().moveSession(
          session.id!,
          DateTime(2026, 11, 10),
          missed: true,
        ),
        refused(ReplaceRefusal.outsidePlan),
      );
    });

    test('letting a missed sent session go removes it upstream', () async {
      final session = await planSession(eventId: '300');

      await wednesday().removeSession(session.id!, missed: true);

      expect(workouts.deleted, ['300']);
      expect(await plans.getSession(session.id!), isNull);
    });
  });

  group('goal edits', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('a valid graph edit is saved', () async {
      const goal = Goal(
        targetType: 'long_distance',
        weekdays: {2, 4, 6},
        weeklyHours: 6,
        loadFactors: [1, 0.82],
      );

      await actions().applyGoal(goal);

      expect((await GoalStore().load())!.loadFactors, [1, 0.82]);
    });

    test('an invalid one is refused with the reason', () async {
      await expectLater(
        actions().applyGoal(
          const Goal(
            targetType: 'long_distance',
            weekdays: {2, 4, 6},
            weeklyHours: 6,
            weeks: 30,
          ),
        ),
        throwsA(
          isA<ReplaceRefusedException>()
              .having((e) => e.reason, 'reason', ReplaceRefusal.invalid)
              .having((e) => e.detail, 'detail', contains('2 to 16')),
        ),
      );
      expect(await GoalStore().load(), isNull);
    });
  });
}
