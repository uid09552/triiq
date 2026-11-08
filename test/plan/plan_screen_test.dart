import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/client/intervalls/intervalls_client.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/intervals_session.dart';
import 'package:triiq/data/intervals_workout_service.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/data/repositories/plans_repository.dart';
import 'package:triiq/data/repositories/sync_state_repository.dart';
import 'package:triiq/data/repositories/wellness_repository.dart';
import 'package:triiq/data/sync/sync_settings.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/plan/knowledge.dart';
import 'package:triiq/plan/plan_engine.dart';
import 'package:triiq/plan/plan_inputs.dart';
import 'package:triiq/plan/plan_models.dart';
import 'package:triiq/plan/plan_service.dart';
import 'package:triiq/plan/plan_writer.dart';
import 'package:triiq/screens/plan/goal_editor_screen.dart';
import 'package:triiq/screens/plan/plan_screen.dart';
import 'package:triiq/screens/today/train_now_screen.dart';
import 'package:triiq/util/dates.dart';
import 'package:triiq/widgets/main_navigation.dart';

class _RecordingWorkouts implements PlannedWorkoutWriter {
  final created = <PlannedWorkoutDraft>[];

  @override
  Future<Event> createPlannedWorkout(PlannedWorkoutDraft draft) async {
    created.add(draft);
    return Event(id: created.length);
  }

  @override
  Future<void> updatePlannedWorkoutDate(String eventId, DateTime date) async {}

  @override
  Future<void> deletePlannedWorkout(String eventId) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late AppDatabase database;
  late PlansRepository plans;
  late _RecordingWorkouts workouts;
  late PlanService service;
  late TrainingKnowledge knowledge;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dir = await Directory.systemTemp.createTemp('triiq_plan_screen');
    database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
    plans = PlansRepository(database: database);
    workouts = _RecordingWorkouts();
    knowledge = TrainingKnowledge.parse(File('docs/okf.md').readAsStringSync());
    service = PlanService(
      knowledge: KnowledgeRepository(
        loadAsset: () async => File('docs/okf.md').readAsStringSync(),
      ),
      inputs: PlanInputsLoader(
        activities: ActivitiesRepository(database: database),
        wellness: WellnessRepository(database: database),
        syncState: SyncStateRepository(database: database),
      ),
      activities: ActivitiesRepository(database: database),
      plans: plans,
      writer: PlanWriter(
        workouts: workouts,
        plans: plans,
        afterWrite: (_, _) async {},
      ),
    );
  });

  tearDown(() async {
    IntervalsSession.instance.debugSetConnected(false);
    await database.close();
    await dir.delete(recursive: true);
  });

  /// sqflite_ffi does real isolate I/O, which FakeAsync never completes:
  /// let real time pass until the screen has finished loading.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 40; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
      if (find.byType(CircularProgressIndicator).evaluate().isEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> ioWait(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 40)),
      );
      await tester.pump();
    }
  }

  Future<void> open(
    WidgetTester tester, {
    Widget? home,
    SyncSettings? settings,
  }) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: home ?? PlanScreen(service: service, settings: settings),
      ),
    );
    await settle(tester);
  }

  const runGoal = Goal(
    targetType: 'long_distance',
    weekdays: {2, 4, 6},
    weeklyHours: 6,
    baselineWeeklyLoad: 250,
    weeks: 4,
  );

  testWidgets('with no goal it invites the athlete to set one', (tester) async {
    await open(tester);

    expect(find.text('Set goal'), findsOneWidget);
    expect(find.textContaining('Set a goal'), findsOneWidget);
    expect(find.text('Generate plan'), findsOneWidget);
    expect(find.text('Weekly load'), findsNothing);
  });

  testWidgets('shows the current block with the current week highlighted', (
    tester,
  ) async {
    final monday = startOfWeek(DateTime.now());
    final plan = PlanEngine(knowledge)
        .generate(
          goal: const Goal(
            targetType: 'long_distance',
            weekdays: {1, 2, 4, 6},
            weeklyHours: 12,
            baselineWeeklyLoad: 300,
            weeks: 4,
            loadFactors: [1, 1, 1.1, 0.8],
          ),
          startDate: monday,
          recentWeeklyLoads: null,
          today: DateTime.now(),
        )
        .plan!;
    await tester.runAsync(() => plans.save(plan));

    await open(tester);

    expect(find.text('Week 1 · Build'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Week 4 · Recovery'), 400);
    expect(find.text('Week 4 · Recovery'), findsOneWidget);
    expect(find.text('This week'), findsOneWidget);
    expect(find.text('Regenerate'), findsOneWidget);
    expect(find.text('110% of proposal'), findsOneWidget);
  });

  testWidgets('a goal shows the load graph; a drag is saved into the goal', (
    tester,
  ) async {
    await tester.runAsync(() => service.goals.save(runGoal));
    await open(tester);

    expect(find.text('Weekly load'), findsOneWidget);
    expect(
      find.textContaining('from 250 TSS, up to +10% a week'),
      findsOneWidget,
    );

    // Drag week 2 (proposed 302.5 TSS) down by about 40 TSS.
    final column = find.byKey(const ValueKey('load-week-1'));
    final gesture = await tester.startGesture(tester.getCenter(column));
    for (var i = 0; i < 6; i++) {
      await gesture.moveBy(const Offset(0, 30 / 6));
      await tester.pump();
    }
    await gesture.up();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );

    final saved = await tester.runAsync(service.goals.load);
    final week2 = saved!.loadFactors[1] * 302.5;
    expect(saved.loadFactors[0], 1.0);
    expect(week2, lessThan(302.5));
    expect(week2 % 5, anyOf(closeTo(0, 1e-6), closeTo(5, 1e-6)));
  });

  testWidgets('cancelling the preview creates nothing', (tester) async {
    IntervalsSession.instance.debugSetConnected(true);
    await tester.runAsync(() => service.goals.save(runGoal));
    await open(tester);

    await tester.tap(find.text('Generate plan'));
    await settle(tester);
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Review your plan'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pump(const Duration(seconds: 1));

    expect(workouts.created, isEmpty);
    expect(await tester.runAsync(plans.getCurrent), isNull);
  });

  Future<void> takePlan(WidgetTester tester, SyncSettings settings) async {
    await open(tester, settings: settings);
    await tester.tap(find.text('Generate plan'));
    await settle(tester);
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Take as plan'));
    for (var i = 0; i < 4; i++) {
      await settle(tester);
    }
  }

  testWidgets('take as plan with sending on: saved, Calendar opened, sent', (
    tester,
  ) async {
    IntervalsSession.instance.debugSetConnected(true);
    MainNavigation.instance.debugReset();
    await tester.runAsync(
      () => service.goals.save(runGoal.copyWith(loadFactors: [1, 1, 1, 0.8])),
    );

    await takePlan(tester, SyncSettings.forTesting());
    // Sending runs in the background after the screen moved on.
    for (var i = 0; i < 60 && find.byType(SnackBar).evaluate().isEmpty; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Three days x four weeks.
    expect(workouts.created.length, 12);
    final saved = await tester.runAsync(plans.getCurrent);
    expect(saved!.status, PlanStatus.active);
    expect(saved.weeks[3].factor, 0.8);
    expect(saved.weeks[3].phase, 'recovery');
    expect(MainNavigation.instance.requestedTab, MainNavigation.calendarTab);
    expect(MainNavigation.instance.calendarFocus!.date, saved.startDate);
    expect(find.text('12 sessions created'), findsOneWidget);
  });

  testWidgets('take as plan with sending off keeps the plan local', (
    tester,
  ) async {
    IntervalsSession.instance.debugSetConnected(true);
    MainNavigation.instance.debugReset();
    await tester.runAsync(() => service.goals.save(runGoal));
    final settings = SyncSettings.forTesting();
    await tester.runAsync(() => settings.setSendPlanToIntervals(false));

    await takePlan(tester, settings);

    expect(workouts.created, isEmpty);
    final saved = await tester.runAsync(plans.getCurrent);
    expect(saved!.sessions, hasLength(12));
    expect(saved.sessions.every((s) => s.intervalsEventId == null), isTrue);
    expect(MainNavigation.instance.calendarFocus!.date, saved.startDate);
    expect(find.text('Plan saved in TriIQ.'), findsOneWidget);
  });

  testWidgets('a plan can be taken without an Intervals.icu connection', (
    tester,
  ) async {
    MainNavigation.instance.debugReset();
    await tester.runAsync(() => service.goals.save(runGoal));

    await takePlan(tester, SyncSettings.forTesting());

    expect(workouts.created, isEmpty);
    expect(await tester.runAsync(plans.getCurrent), isNotNull);
    expect(
      find.textContaining('Connect Intervals.icu to send it'),
      findsOneWidget,
    );
  });

  testWidgets('a week-grid session offers Change Training into Train Now', (
    tester,
  ) async {
    final monday = startOfWeek(DateTime.now());
    final plan = PlanEngine(knowledge)
        .generate(
          goal: const Goal(
            targetType: 'long_distance',
            weekdays: {1, 2, 4, 6},
            weeklyHours: 12,
            baselineWeeklyLoad: 300,
            weeks: 4,
            loadFactors: [1, 1, 1.1, 0.8],
          ),
          startDate: monday,
          recentWeeklyLoads: null,
          today: DateTime.now(),
        )
        .plan!;
    await tester.runAsync(() => plans.save(plan));
    final saved = (await tester.runAsync(plans.getCurrent))!;

    await open(tester);

    final first = saved.weeks[0].sessions.first;
    await tester.tap(
      find.bySemanticsLabel(RegExp('^${first.sport}, ${first.name}, ')).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('change-training')));
    await tester.pump();
    await tester.pump();

    final screen = tester.widget<TrainNowScreen>(find.byType(TrainNowScreen));
    expect(screen.initialEventId, 'plan:${first.id}');
  });

  // Also opened for a session in a week other than the current one — the
  // Plan screen's week grid does not restrict Change Training to "this week".
  testWidgets('Change Training is offered for a future week too', (
    tester,
  ) async {
    final monday = startOfWeek(DateTime.now());
    final plan = PlanEngine(knowledge)
        .generate(
          goal: const Goal(
            targetType: 'long_distance',
            weekdays: {1, 2, 4, 6},
            weeklyHours: 12,
            baselineWeeklyLoad: 300,
            weeks: 4,
            loadFactors: [1, 1, 1.1, 0.8],
          ),
          startDate: monday,
          recentWeeklyLoads: null,
          today: DateTime.now(),
        )
        .plan!;
    await tester.runAsync(() => plans.save(plan));

    await open(tester);

    final later = plan.weeks[3].sessions.first;
    await tester.scrollUntilVisible(
      find.bySemanticsLabel(RegExp('^${later.sport}, ${later.name}, ')).first,
      400,
    );
    await tester.tap(
      find.bySemanticsLabel(RegExp('^${later.sport}, ${later.name}, ')).first,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('change-training')), findsOneWidget);
  });

  testWidgets('a triathlon plan shows sport tiles and load per sport', (
    tester,
  ) async {
    final monday = startOfWeek(DateTime.now());
    final plan = PlanEngine(knowledge)
        .generate(
          goal: const Goal(
            targetType: 'long_distance',
            sport: Goal.triathlon,
            weekdays: {1, 2, 3, 4, 5, 6},
            weeklyHours: 14,
            baselineWeeklyLoad: 400,
            weeks: 2,
          ),
          startDate: monday,
          recentWeeklyLoads: null,
          today: DateTime.now(),
        )
        .plan!;
    await tester.runAsync(() => plans.save(plan));

    await open(tester);

    final week = plan.weeks[0];
    for (final sport in ['Swim', 'Ride', 'Run']) {
      expect(
        find.text('$sport ${week.loadBySport[sport]}'),
        findsOneWidget,
        reason: sport,
      );
    }
    // One tile per session, labelled for screen readers.
    final first = week.sessions.first;
    expect(
      find.bySemanticsLabel(RegExp('^${first.sport}, ${first.name}, ')),
      findsWidgets,
    );
    expect(find.byIcon(Icons.pool_outlined), findsWidgets);
  });

  testWidgets('goal editor: a triathlon mix that is not 100% blocks save', (
    tester,
  ) async {
    Goal? popped;
    await open(
      tester,
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            popped = await Navigator.of(context).push<Goal>(
              MaterialPageRoute(
                builder: (_) => GoalEditorScreen(knowledge: knowledge),
              ),
            );
          },
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Triathlon'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('goal-mix-total'))).data,
      'Total 100%',
    );

    // Swim slider to the far right: 100% swim, total 185%.
    await tester.drag(
      find.byKey(const ValueKey('goal-mix-Swim')),
      const Offset(600, 0),
    );
    await tester.pumpAndSettle();
    expect(find.text('Total 185%'), findsOneWidget);

    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.textContaining('adds up to 185%'), findsOneWidget);
    expect(popped, isNull);
  });

  testWidgets('ramp slider and hold switch reshape the proposal and save', (
    tester,
  ) async {
    await tester.runAsync(
      () =>
          service.goals.save(runGoal.copyWith(weeks: 4, loadFactors: [1, 0.9])),
    );
    await open(tester);

    final slider = tester.widget<Slider>(
      find.byKey(const ValueKey('curve-ramp')),
    );
    expect(slider.value, 10);
    expect(find.text('Weekly increase: 10%'), findsOneWidget);

    slider.onChanged!(5);
    slider.onChangeEnd!(5);
    await ioWait(tester);
    await settle(tester);

    expect(find.text('Weekly increase: 5%'), findsOneWidget);
    final saved = await tester.runAsync(service.goals.load);
    expect(saved!.maxWeeklyIncrease, closeTo(0.05, 1e-9));
    // The dragged week keeps its share of the new proposal.
    expect(saved.loadFactors[1], 0.9);
    final semantics = tester.getSemantics(
      find.byKey(const ValueKey('load-week-1')),
    );
    // 250 x 1.05^2 = 275.6, at 90% = 248.
    expect(semantics.getSemanticsData().value, '248 TSS');

    // Hold on by default: week 4 = week 3; off: it ramps.
    String week(int i) => tester
        .getSemantics(find.byKey(ValueKey('load-week-$i')))
        .getSemanticsData()
        .value;
    expect(week(3), week(2));
    await tester.tap(find.byKey(const ValueKey('curve-hold')));
    await ioWait(tester);
    await settle(tester);
    expect(week(3), isNot(week(2)));
    expect((await tester.runAsync(service.goals.load))!.holdEvery4th, isFalse);
  });

  testWidgets('a week that missed a preference says so', (tester) async {
    final monday = startOfWeek(DateTime.now());
    final plan = PlanEngine(knowledge)
        .generate(
          goal: const Goal(
            targetType: 'long_distance',
            weekdays: {2, 4, 6},
            weeklyHours: 20,
            baselineWeeklyLoad: 300,
            weeks: 2,
            longDays: {'Run': 2},
            intervalDays: {2},
          ),
          startDate: monday,
          recentWeeklyLoads: null,
          today: DateTime.now(),
        )
        .plan!;
    await tester.runAsync(() => plans.save(plan));

    await open(tester);

    expect(
      find.text("The intervals couldn't go on a preferred interval day."),
      findsWidgets,
    );
  });
}
