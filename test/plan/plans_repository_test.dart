import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/data/repositories/plans_repository.dart';
import 'package:triiq/plan/knowledge.dart';
import 'package:triiq/plan/plan_engine.dart';
import 'package:triiq/plan/plan_models.dart';

void main() {
  late Directory dir;
  late AppDatabase database;
  late PlansRepository repo;

  TrainingPlan makePlan() {
    final engine = PlanEngine(
      TrainingKnowledge.parse(File('docs/okf.md').readAsStringSync()),
    );
    return engine
        .generate(
          goal: const Goal(
            targetType: 'long_distance',
            weekdays: {1, 2, 4, 6},
            weeklyHours: 12,
            weeks: 4,
            loadFactors: [1, 1, 1.2, 0.8],
          ),
          startDate: DateTime(2026, 8, 31),
          recentWeeklyLoads: const [300, 300, 300, 300],
          currentCtl: 45,
          today: DateTime(2026, 8, 26),
        )
        .plan!;
  }

  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dir = await Directory.systemTemp.createTemp('triiq_plans_test');
    database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
    repo = PlansRepository(database: database);
  });

  tearDown(() async {
    await database.close();
    await dir.delete(recursive: true);
  });

  test('a saved plan reads back whole', () async {
    final saved = await repo.save(makePlan());
    final back = (await repo.getCurrent())!;

    expect(back.id, saved.id);
    expect(back.weeks.length, 4);
    expect(back.weeks[3].phase, 'recovery');
    expect(back.weeks[2].factor, 1.2);
    expect(back.weeks[2].warnings, saved.weeks[2].warnings);
    expect(back.weeks[2].warnings, isNotEmpty);
    expect(back.weeks[2].requestedLoad, saved.weeks[2].requestedLoad);
    expect(back.weeks[1].targetLoad, saved.weeks[1].targetLoad);
    expect(back.weeks[0].sessions.length, saved.weeks[0].sessions.length);
    expect(back.weeks[0].sessions.first.id, isNotNull);
    expect(back.weeks[0].sessions.first.description, contains('m '));
    expect(back.weeks[3].lowShare, closeTo(saved.weeks[3].lowShare!, 1e-9));
  });

  test('session event ids and status update in place', () async {
    final saved = await repo.save(makePlan());
    final first = saved.weeks[0].sessions.first;

    await repo.updateSession(
      first.copyWith(
        intervalsEventId: '123',
        calendarEventId: 'abc',
        status: PlanSessionStatus.created,
      ),
    );
    final back = (await repo.getById(saved.id!))!;
    final again = back.weeks[0].sessions.firstWhere((s) => s.id == first.id);

    expect(again.intervalsEventId, '123');
    expect(again.calendarEventId, 'abc');
    expect(again.status, PlanSessionStatus.created);
  });

  test('a removed plan is no longer current', () async {
    final saved = await repo.save(makePlan());
    await repo.setStatus(saved.id!, PlanStatus.removed);

    expect(await repo.getCurrent(), isNull);
  });

  test('upgrading a v2 database keeps its data and adds the plan tables',
      () async {
    final path = p.join(dir.path, 'old.db');
    final old = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (db, _) async {
          await db.execute('''
            CREATE TABLE activities (
              id TEXT PRIMARY KEY, date TEXT NOT NULL, type TEXT, name TEXT,
              moving_time INTEGER, distance REAL, training_load INTEGER,
              raw TEXT NOT NULL, synced_at INTEGER NOT NULL)
          ''');
          await db.insert('activities', {
            'id': 'a1',
            'date': '2026-08-20',
            'type': 'Run',
            'name': 'Old run',
            'raw': '{}',
            'synced_at': 1,
          });
        },
      ),
    );
    await old.close();

    final upgraded = AppDatabase.atPath(path);
    addTearDown(upgraded.close);
    final activities = await ActivitiesRepository(database: upgraded)
        .getByDate('2026-08-20');
    final plans = await PlansRepository(database: upgraded).save(makePlan());

    expect(activities.single.name, 'Old run');
    expect(plans.id, isNotNull);
  });

  test(
    'upgrading a v6 database keeps an existing plan session readable, '
    'defaulting its new columns',
    () async {
      final path = p.join(dir.path, 'v6.db');
      final old = await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 6,
          onCreate: (db, _) async {
            await db.execute('''
              CREATE TABLE plans (
                id INTEGER PRIMARY KEY AUTOINCREMENT, goal_type TEXT NOT NULL,
                sport TEXT NOT NULL, start_date TEXT NOT NULL,
                baseline_load REAL NOT NULL, status TEXT NOT NULL,
                meta TEXT NOT NULL, created_at INTEGER NOT NULL)
            ''');
            await db.execute('''
              CREATE TABLE plan_sessions (
                id INTEGER PRIMARY KEY AUTOINCREMENT, plan_id INTEGER NOT NULL,
                week_index INTEGER NOT NULL, date TEXT NOT NULL,
                slot TEXT NOT NULL, template_id TEXT NOT NULL,
                name TEXT NOT NULL, sport TEXT NOT NULL,
                minutes INTEGER NOT NULL, load INTEGER NOT NULL,
                low_minutes REAL NOT NULL, description TEXT NOT NULL,
                intervals_event_id TEXT, calendar_event_id TEXT,
                status TEXT NOT NULL)
            ''');
            final planId = await db.insert('plans', {
              'goal_type': 'long_distance',
              'sport': 'Run',
              'start_date': '2026-08-31',
              'baseline_load': 300.0,
              'status': 'draft',
              'meta': jsonEncode({
                'weeks': [
                  {
                    'index': 0,
                    'phase': 'build',
                    'startDate': '2026-08-31',
                    'targetLoad': 300.0,
                    'requestedLoad': 300.0,
                    'limit': 'none',
                    'lowIntensityTarget': 0.8,
                    'lowIntensityTolerance': 0.05,
                  },
                ],
              }),
              'created_at': 1,
            });
            await db.insert('plan_sessions', {
              'plan_id': planId,
              'week_index': 0,
              'date': '2026-08-31',
              'slot': 'z2',
              'template_id': 'long_distance.z2',
              'name': 'Z2 endurance',
              'sport': 'Run',
              'minutes': 50,
              'load': 42,
              'low_minutes': 50.0,
              'description': '- 10m 60%',
              'status': 'planned',
            });
          },
        ),
      );
      await old.close();

      final upgraded = AppDatabase.atPath(path);
      addTearDown(upgraded.close);
      final plan = await PlansRepository(database: upgraded).getCurrent();

      expect(await upgraded.database.then((db) => db.getVersion()), 7);
      final session = plan!.weeks.single.sessions.single;
      expect(session.name, 'Z2 endurance');
      expect(session.shortDescription, 'Z2 endurance · 50min');
      expect(session.techniqueFocus, isFalse);
    },
  );

  test('the goal is stored and read back', () async {
    SharedPreferences.setMockInitialValues({});
    final store = GoalStore();
    expect(await store.load(), isNull);

    await store.save(
      const Goal(
        targetType: 'long_distance',
        weekdays: {2, 4, 6},
        weeklyHours: 6,
        sport: 'Ride',
      ),
    );
    final back = (await store.load())!;

    expect(back.weeklyHours, 6);
    expect(back.sport, 'Ride');
    expect(back.weekdays, {2, 4, 6});
  });

  test('a plan saved before the load curve still loads', () async {
    final db = await database.database;
    final id = await db.insert('plans', {
      'goal_type': 'long_distance',
      'sport': 'Run',
      'start_date': '2026-08-31',
      'baseline_load': 300.0,
      'status': 'active',
      // The old meta: a bare list of weeks without factor or warnings.
      'meta':
          '[{"index":0,"phase":"build","startDate":"2026-08-31",'
          '"targetLoad":300,"requestedLoad":300,"limit":"none",'
          '"projectedCtlEnd":null,"lowIntensityTarget":0.8,'
          '"lowIntensityTolerance":0.05}]',
      'created_at': 0,
    });

    final back = (await repo.getById(id))!;

    expect(back.weeks, hasLength(1));
    expect(back.weeks[0].factor, 1.0);
    expect(back.weeks[0].warnings, isEmpty);
    expect(back.sportMix, isEmpty);
  });

  test('a triathlon plan keeps its sport mix and per-session sports', () async {
    final plan = PlanEngine(
      TrainingKnowledge.parse(File('docs/okf.md').readAsStringSync()),
    ).generate(
      goal: const Goal(
        targetType: 'long_distance',
        sport: Goal.triathlon,
        weekdays: {1, 2, 3, 4, 5, 6},
        weeklyHours: 12,
        weeks: 2,
        baselineWeeklyLoad: 350,
      ),
      startDate: DateTime(2026, 8, 31),
      recentWeeklyLoads: null,
      today: DateTime(2026, 8, 26),
    ).plan!;

    await repo.save(plan);
    final back = (await repo.getCurrent())!;

    expect(back.sport, Goal.triathlon);
    expect(back.sportMix, Goal.defaultSportMix);
    expect(back.sessions.map((s) => s.sport).toSet(), {'Swim', 'Ride', 'Run'});
  });

  test('replaceSessionContent swaps content, keeps plan, week and date',
      () async {
    final saved = await repo.save(makePlan());
    final before = saved.weeks[1].sessions.first;

    await repo.replaceSessionContent(
      before.id!,
      sport: 'Run',
      name: 'Easy run alternative',
      minutes: 45,
      load: 40,
      lowMinutes: 36,
      description: '- 45m 75% Pace',
      intervalsEventId: '777',
      status: PlanSessionStatus.created,
    );

    final after = (await repo.getSession(before.id!))!;
    expect(after.name, 'Easy run alternative');
    expect(after.sport, 'Run');
    expect(after.minutes, 45);
    expect(after.load, 40);
    expect(after.intervalsEventId, '777');
    expect(after.status, PlanSessionStatus.created);
    expect(after.weekIndex, before.weekIndex);
    expect(after.date, before.date);
    expect(after.slot, before.slot);
    final plan = (await repo.getCurrent())!;
    expect(plan.id, saved.id);
    expect(plan.sessions.length, saved.sessions.length);
  });

  test('week notes round-trip', () async {
    final plan = PlanEngine(
      TrainingKnowledge.parse(File('docs/okf.md').readAsStringSync()),
    ).generate(
      goal: const Goal(
        targetType: 'long_distance',
        weekdays: {2, 4, 6},
        weeklyHours: 20,
        baselineWeeklyLoad: 300,
        weeks: 2,
        longDays: {'Run': 2},
        intervalDays: {2},
      ),
      startDate: DateTime(2026, 8, 31),
      recentWeeklyLoads: null,
      today: DateTime(2026, 8, 26),
    ).plan!;
    expect(plan.weeks.first.notes, isNotEmpty);

    await repo.save(plan);
    final back = (await repo.getCurrent())!;

    expect(back.weeks.first.notes, plan.weeks.first.notes);
  });
}
