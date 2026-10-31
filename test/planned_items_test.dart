import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/data/planned_items.dart';
import 'package:triiq/data/repositories/events_repository.dart';
import 'package:triiq/data/repositories/plans_repository.dart';
import 'package:triiq/plan/knowledge.dart';
import 'package:triiq/plan/plan_engine.dart';
import 'package:triiq/plan/plan_models.dart';
import 'package:triiq/util/dates.dart';

void main() {
  late Directory dir;
  late AppDatabase database;
  late EventsRepository events;
  late PlansRepository plans;
  var copy = true;

  final monday = DateTime(2026, 11, 2);
  final weekEnd = isoDate(monday.add(const Duration(days: 6)));

  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dir = await Directory.systemTemp.createTemp('triiq_planned_items');
    database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
    events = EventsRepository(database: database);
    plans = PlansRepository(database: database);
    copy = true;
  });

  tearDown(() async {
    await database.close();
    await dir.delete(recursive: true);
  });

  PlannedItemsRepository repo() => PlannedItemsRepository(
    events: events,
    plans: plans,
    copyEvents: () async => copy,
  );

  Future<TrainingPlan> savePlan() {
    final draft = PlanEngine(
      TrainingKnowledge.parse(File('docs/okf.md').readAsStringSync()),
    ).generate(
      goal: const Goal(
        targetType: 'long_distance',
        weekdays: {2, 4, 6},
        weeklyHours: 6,
        baselineWeeklyLoad: 250,
        weeks: 2,
      ),
      startDate: monday,
      recentWeeklyLoads: null,
      today: DateTime(2026, 10, 31),
    ).plan!;
    return plans.save(draft.copyWith(status: PlanStatus.active));
  }

  LocalEvent event(String id, String date, {String name = 'Coach session'}) =>
      LocalEvent(
        id: id,
        date: date,
        category: 'WORKOUT',
        type: 'Ride',
        name: name,
        description: null,
        plannedLoad: 90,
        plannedTime: 3600,
        plannedDistance: null,
        indoor: false,
        raw: const {},
        syncedAt: DateTime(2026, 10, 31),
      );

  test('local-only plan sessions show as planned items', () async {
    final plan = await savePlan();

    final items = await repo().getRange(isoDate(monday), weekEnd);

    expect(items, hasLength(plan.weeks[0].sessions.length));
    expect(items.every((e) => e.isPlanSession && e.isTraining), isTrue);
    expect(items.every((e) => !e.planSessionSent), isTrue);
    final first = plan.weeks[0].sessions.first;
    expect(items.first.plannedLoad, first.load);
    expect(items.first.planSessionId, first.id);
  });

  test('a sent session shows once, as the synced event', () async {
    final plan = await savePlan();
    final sent = plan.weeks[0].sessions.first.copyWith(
      intervalsEventId: '501',
      status: PlanSessionStatus.created,
    );
    await plans.updateSession(sent);
    // Moved one day later in Intervals.icu.
    final moved = isoDate(sent.date.add(const Duration(days: 1)));
    await events.replaceRange(isoDate(monday), weekEnd, [
      event('501', moved, name: sent.name),
    ]);

    final items = await repo().getRange(isoDate(monday), weekEnd);

    expect(items.where((e) => e.name == sent.name && e.date == isoDate(sent.date)
        && e.isPlanSession), isEmpty);
    expect(items.where((e) => e.id == '501'), hasLength(1));
    expect(items.firstWhere((e) => e.id == '501').date, moved);
    expect(items, hasLength(plan.weeks[0].sessions.length));
  });

  test('copy off hides cached events but keeps them, plan stays', () async {
    final plan = await savePlan();
    await events.replaceRange(isoDate(monday), weekEnd, [
      event('900', isoDate(monday)),
    ]);
    copy = false;

    final items = await repo().getRange(isoDate(monday), weekEnd);

    expect(items.any((e) => e.id == '900'), isFalse);
    expect(items, hasLength(plan.weeks[0].sessions.length));
    expect(await events.getRange(isoDate(monday), weekEnd), hasLength(1));

    copy = true;
    expect(
      (await repo().getRange(isoDate(monday), weekEnd)).any((e) => e.id == '900'),
      isTrue,
    );
  });

  test('copy off shows a sent session from the plan', () async {
    final plan = await savePlan();
    final sent = plan.weeks[0].sessions.first.copyWith(
      intervalsEventId: '501',
      status: PlanSessionStatus.created,
    );
    await plans.updateSession(sent);
    await events.replaceRange(isoDate(monday), weekEnd, [
      event('501', isoDate(sent.date)),
    ]);
    copy = false;

    final items = await repo().getByDate(isoDate(sent.date));

    expect(items, hasLength(1));
    expect(items.single.isPlanSession, isTrue);
    expect(items.single.planSessionSent, isTrue);
  });
}
