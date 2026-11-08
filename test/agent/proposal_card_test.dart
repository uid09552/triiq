import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/agent/plan_proposals.dart';
import 'package:triiq/client/intervalls/intervalls_client.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/intervals_workout_service.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/data/repositories/events_repository.dart';
import 'package:triiq/data/repositories/plans_repository.dart';
import 'package:triiq/data/repositories/sync_state_repository.dart';
import 'package:triiq/data/repositories/wellness_repository.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/plan/knowledge.dart';
import 'package:triiq/plan/load_curve.dart';
import 'package:triiq/plan/plan_actions.dart';
import 'package:triiq/plan/plan_inputs.dart';
import 'package:triiq/plan/plan_models.dart';
import 'package:triiq/plan/plan_service.dart';
import 'package:triiq/screens/chat/proposal_card.dart';

class _NoWorkouts implements PlannedWorkoutWriter {
  @override
  Future<Event> createPlannedWorkout(PlannedWorkoutDraft draft) async =>
      Event(id: 1);

  @override
  Future<void> updatePlannedWorkoutDate(String eventId, DateTime date) async {}

  @override
  Future<void> deletePlannedWorkout(String eventId) async {}
}

void main() {
  late Directory dir;
  late AppDatabase database;
  late PlanProposals proposals;
  late PlanActions actions;
  var fingerprint = 'v1';

  const goal = Goal(
    targetType: 'long_distance',
    weekdays: {2, 4, 6},
    weeklyHours: 10,
    baselineWeeklyLoad: 300,
    weeks: 4,
  );
  const limits = CurveLimits(
    baseline: 300,
    rampCap: 0.10,
    maxCtlRamp: 7,
    recoveryThreshold: 0.9,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dir = await Directory.systemTemp.createTemp('triiq_proposal_card');
    database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
    fingerprint = 'v1';
    proposals = PlanProposals(fingerprint: () async => fingerprint);
    actions = PlanActions(
      workouts: _NoWorkouts(),
      plans: PlansRepository(database: database),
      events: EventsRepository(database: database),
      goals: GoalStore(),
      sendEnabled: () => true,
      connected: () => false,
      resync: (_) async {},
      clock: () => DateTime(2026, 10, 31),
    );
  });

  tearDown(() async {
    await database.close();
    await dir.delete(recursive: true);
  });

  CurveProposal curve() => proposals.register(
    CurveProposal(
      summary: 'week 4 -> 355 TSS',
      fingerprint: 'v1',
      goal: goal.copyWith(loadFactors: [1, 1, 1, 0.81]),
      limits: limits,
      weeks: 4,
      changedWeeks: {3},
    ),
  );

  Future<void> pump(WidgetTester tester, PlanProposal proposal) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProposalCard(
              proposal: proposal,
              proposals: proposals,
              actions: actions,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> realWait(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 40)),
      );
      await tester.pump();
    }
  }

  testWidgets('apply saves the proposed graph into the goal', (tester) async {
    final p = curve();
    await pump(tester, p);

    expect(find.text('Load graph change'), findsOneWidget);
    expect(find.text('week 4 -> 355 TSS'), findsOneWidget);
    await tester.tap(find.text('Apply'));
    await realWait(tester);

    final saved = await tester.runAsync(GoalStore().load);
    expect(saved!.loadFactors, [1, 1, 1, 0.81]);
    expect(find.text('Applied'), findsOneWidget);
    expect(find.text('Apply'), findsNothing);
  });

  testWidgets('dismiss leaves the goal alone', (tester) async {
    final p = curve();
    await pump(tester, p);

    await tester.tap(find.text('Dismiss'));
    await realWait(tester);

    expect(await tester.runAsync(GoalStore().load), isNull);
    expect(find.text('Dismissed'), findsOneWidget);
  });

  testWidgets('a change since the proposal shows it is out of date', (
    tester,
  ) async {
    final p = curve();
    fingerprint = 'v2';
    await pump(tester, p);

    await tester.tap(find.text('Apply'));
    await realWait(tester);

    expect(find.textContaining('Out of date'), findsOneWidget);
    expect(await tester.runAsync(GoalStore().load), isNull);
  });

  testWidgets('a failed apply says why and offers retry', (tester) async {
    final p = proposals.register(
      SessionChangeProposal(
        summary: 'move Long endurance from Sat to Sun',
        fingerprint: 'v1',
        sessionId: 404,
        name: 'Long endurance',
        sport: 'Ride',
        from: DateTime(2026, 11, 7),
        to: DateTime(2026, 11, 8),
      ),
    );
    await pump(tester, p);

    expect(find.text('Move a session'), findsOneWidget);
    await tester.tap(find.text('Apply'));
    await realWait(tester);

    expect(
      find.text('Could not apply: That session is no longer in the plan.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('a plan proposal opens the preview; cancel keeps it pending', (
    tester,
  ) async {
    final service = PlanService(
      knowledge: KnowledgeRepository(
        loadAsset: () async => File('docs/okf.md').readAsStringSync(),
      ),
      inputs: PlanInputsLoader(
        activities: ActivitiesRepository(database: database),
        wellness: WellnessRepository(database: database),
        syncState: SyncStateRepository(database: database),
      ),
      plans: PlansRepository(database: database),
      activities: ActivitiesRepository(database: database),
    );
    final p = proposals.register(
      PlanDraftProposal(
        summary: 'take a 4-week Run plan',
        fingerprint: 'v1',
        goal: goal,
      ),
    );
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: ProposalCard(
            proposal: p,
            proposals: proposals,
            actions: actions,
            planService: service,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Apply'));
    for (
      var i = 0;
      i < 20 && find.text('Review your plan').evaluate().isEmpty;
      i++
    ) {
      await realWait(tester);
    }
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Review your plan'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pump(const Duration(seconds: 1));
    await realWait(tester);

    expect(p.state, ProposalState.pending);
    expect(
      await tester.runAsync(PlansRepository(database: database).getCurrent),
      isNull,
    );
  });
}
