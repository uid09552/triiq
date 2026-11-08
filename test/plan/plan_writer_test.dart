import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/client/intervalls/intervalls_client.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/intervals_workout_service.dart';
import 'package:triiq/data/repositories/plans_repository.dart';
import 'package:triiq/plan/knowledge.dart';
import 'package:triiq/plan/plan_engine.dart';
import 'package:triiq/plan/plan_models.dart';
import 'package:triiq/plan/plan_writer.dart';

class _FakeWorkouts implements PlannedWorkoutWriter {
  final created = <PlannedWorkoutDraft>[];
  final deleted = <String>[];
  final failOnDates = <DateTime>{};
  final missingUpstream = <String>{};
  var _nextId = 100;

  @override
  Future<Event> createPlannedWorkout(PlannedWorkoutDraft draft) async {
    if (failOnDates.contains(draft.date)) throw StateError('boom');
    created.add(draft);
    return Event(id: _nextId++);
  }

  @override
  Future<void> updatePlannedWorkoutDate(String eventId, DateTime date) async {}

  @override
  Future<void> deletePlannedWorkout(String eventId) async {
    if (missingUpstream.contains(eventId)) {
      throw DioException(
        requestOptions: RequestOptions(path: '/'),
        response: Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 404,
        ),
      );
    }
    deleted.add(eventId);
  }
}

void main() {
  late Directory dir;
  late AppDatabase database;
  late PlansRepository repo;
  late _FakeWorkouts workouts;
  late PlanWriter writer;
  late List<(DateTime, DateTime)> refreshes;

  Future<TrainingPlan> savedPlan() async {
    final plan =
        PlanEngine(
              TrainingKnowledge.parse(File('docs/okf.md').readAsStringSync()),
            )
            .generate(
              goal: const Goal(
                targetType: 'long_distance',
                weekdays: {1, 2, 4, 6},
                weeklyHours: 12,
              ),
              startDate: DateTime(2026, 8, 31),
              recentWeeklyLoads: const [300, 300, 300, 300],
              today: DateTime(2026, 8, 26),
            )
            .plan!;
    return repo.save(plan);
  }

  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dir = await Directory.systemTemp.createTemp('triiq_writer_test');
    database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
    repo = PlansRepository(database: database);
    workouts = _FakeWorkouts();
    refreshes = [];
    writer = PlanWriter(
      workouts: workouts,
      plans: repo,
      afterWrite: (a, b) async => refreshes.add((a, b)),
    );
  });

  tearDown(() async {
    await database.close();
    await dir.delete(recursive: true);
  });

  test('creates every session on its own date, tagged with the plan', () async {
    final plan = await savedPlan();

    final report = await writer.write(plan);

    expect(report.allCreated, isTrue);
    expect(workouts.created.length, plan.sessions.length);
    expect(
      workouts.created.map((d) => d.date).toSet(),
      plan.sessions.map((s) => s.date).toSet(),
    );
    expect(
      workouts.created.every((d) => d.tags!.single == 'triiq-plan-${plan.id}'),
      isTrue,
    );
    expect(refreshes.single.$1, plan.startDate);

    final stored = (await repo.getById(plan.id!))!;
    expect(stored.status, PlanStatus.active);
    expect(
      stored.sessions.every((s) => s.status == PlanSessionStatus.created),
      isTrue,
    );
    expect(stored.sessions.every((s) => s.intervalsEventId != null), isTrue);
  });

  test('a failed session is reported and only it is retried', () async {
    final plan = await savedPlan();
    final bad = plan.weeks[1].sessions.first;
    workouts.failOnDates.add(bad.date);

    final first = await writer.write(plan);

    expect(first.failed.single.session.date, bad.date);
    expect(first.created.length, plan.sessions.length - 1);
    expect((await repo.getById(plan.id!))!.status, PlanStatus.draft);

    workouts.failOnDates.clear();
    workouts.created.clear();
    final retryPlan = (await repo.getById(plan.id!))!;
    final second = await writer.write(retryPlan);

    expect(second.allCreated, isTrue);
    expect(workouts.created.single.date, bad.date);
    expect((await repo.getById(plan.id!))!.status, PlanStatus.active);
  });

  test('removing from a date deletes only later sessions upstream', () async {
    final plan = await savedPlan();
    await writer.write(plan);
    final written = (await repo.getById(plan.id!))!;
    final cutoff = written.weeks[2].startDate;

    final removed = await writer.removeFrom(written, cutoff);

    final remaining = (await repo.getById(plan.id!))!.sessions.toList();
    final later = written.sessions.where((s) => !s.date.isBefore(cutoff));
    expect(removed, later.length);
    expect(
      workouts.deleted.toSet(),
      later.map((s) => s.intervalsEventId).toSet(),
    );
    expect(remaining.every((s) => s.date.isBefore(cutoff)), isTrue);
    expect(remaining, isNotEmpty);
  });

  test(
    'a session already deleted upstream does not stop the removal',
    () async {
      final plan = await savedPlan();
      await writer.write(plan);
      final written = (await repo.getById(plan.id!))!;
      workouts.missingUpstream.add(written.sessions.last.intervalsEventId!);

      final removed = await writer.removeFrom(written, written.startDate);

      expect(removed, written.sessions.length - 1);
      expect((await repo.getById(plan.id!))!.sessions, isEmpty);
    },
  );

  test('a failed re-sync does not undo a successful write', () async {
    final plan = await savedPlan();
    final failing = PlanWriter(
      workouts: workouts,
      plans: repo,
      afterWrite: (_, _) async => throw StateError('offline'),
    );

    final report = await failing.write(plan);

    expect(report.allCreated, isTrue);
  });
}
