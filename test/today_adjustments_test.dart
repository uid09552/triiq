import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/agent/plan_proposals.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/planned_items.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/data/repositories/events_repository.dart';
import 'package:triiq/data/repositories/plans_repository.dart';
import 'package:triiq/data/repositories/wellness_repository.dart';
import 'package:triiq/evaluation/readiness_service.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/plan/adaptation_service.dart';
import 'package:triiq/plan/knowledge.dart';
import 'package:triiq/plan/plan_engine.dart';
import 'package:triiq/plan/plan_models.dart';
import 'package:triiq/plan/plan_service.dart';
import 'package:triiq/screens/today/today_screen.dart';

void main() {
  late Directory dir;
  late AppDatabase database;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dir = await Directory.systemTemp.createTemp('triiq_today_adjust');
    database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
    PlanProposals.instance.debugClear();
  });

  tearDown(() async {
    PlanProposals.instance.debugClear();
    await database.close();
    await dir.delete(recursive: true);
  });

  testWidgets('a missed session shows as a card on Today; Dismiss hides it', (
    tester,
  ) async {
    const goal = Goal(
      targetType: 'long_distance',
      weekdays: {2, 4, 6},
      weeklyHours: 6,
      baselineWeeklyLoad: 250,
      weeks: 2,
    );
    final plans = PlansRepository(database: database);
    final activities = ActivitiesRepository(database: database);
    final wellness = WellnessRepository(database: database);
    await tester.runAsync(() async {
      await GoalStore().save(goal);
      final draft =
          PlanEngine(
                TrainingKnowledge.parse(File('docs/okf.md').readAsStringSync()),
              )
              .generate(
                goal: goal,
                startDate: DateTime(2026, 11, 2),
                recentWeeklyLoads: null,
                today: DateTime(2026, 10, 31),
              )
              .plan!;
      await plans.save(draft.copyWith(status: PlanStatus.active));
    });
    // Wednesday: Tuesday's session was missed.
    DateTime clock() => DateTime(2026, 11, 4, 8);

    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: TodayScreen(
            wellnessRepository: wellness,
            activitiesRepository: activities,
            plannedItems: PlannedItemsRepository(
              events: EventsRepository(database: database),
              plans: plans,
              copyEvents: () async => true,
            ),
            adaptationService: AdaptationService(
              plans: plans,
              goals: GoalStore(),
              activities: activities,
              readiness: ReadinessService(wellness: wellness, clock: clock),
              planService: PlanService(plans: plans, activities: activities),
              clock: clock,
            ),
          ),
        ),
      ),
    );
    Future<void> settle() async {
      for (var i = 0; i < 20; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump();
      }
    }

    await settle();

    expect(find.text('Plan adjustments'), findsOneWidget);
    expect(find.textContaining('Missed on Tue'), findsOneWidget);

    await tester.tap(find.text('Dismiss'));
    await settle();

    expect(find.textContaining('Missed on Tue'), findsNothing);
  });
}
