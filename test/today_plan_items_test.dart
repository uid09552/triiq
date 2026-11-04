import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/planned_items.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/data/repositories/events_repository.dart';
import 'package:triiq/data/repositories/plans_repository.dart';
import 'package:triiq/data/repositories/wellness_repository.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/plan/knowledge.dart';
import 'package:triiq/plan/plan_engine.dart';
import 'package:triiq/plan/plan_models.dart';
import 'package:triiq/screens/today/today_screen.dart';
import 'package:triiq/screens/today/train_now_screen.dart';
import 'package:triiq/util/dates.dart';

void main() {
  late Directory dir;
  late AppDatabase database;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dir = await Directory.systemTemp.createTemp('triiq_today_plan');
    database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
  });

  tearDown(() async {
    await database.close();
    await dir.delete(recursive: true);
  });

  testWidgets('a local-only plan session counts on Today without a '
      'connection', (tester) async {
    final plans = PlansRepository(database: database);
    final monday = startOfWeek(DateTime.now());
    final draft = PlanEngine(
      TrainingKnowledge.parse(File('docs/okf.md').readAsStringSync()),
    ).generate(
      goal: const Goal(
        targetType: 'long_distance',
        weekdays: {1, 2, 3, 4, 5, 6, 7},
        weeklyHours: 8,
        baselineWeeklyLoad: 300,
        weeks: 2,
      ),
      startDate: monday,
      recentWeeklyLoads: null,
      today: monday,
    ).plan!;
    final saved = await tester.runAsync(
      () => plans.save(draft.copyWith(status: PlanStatus.active)),
    );
    final tomorrow = dateOnly(DateTime.now()).add(const Duration(days: 1));
    final tomorrows = saved!.sessions.where((s) => s.date == tomorrow);

    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: TodayScreen(
            wellnessRepository: WellnessRepository(database: database),
            activitiesRepository: ActivitiesRepository(database: database),
            plannedItems: PlannedItemsRepository(
              events: EventsRepository(database: database),
              plans: plans,
              copyEvents: () async => true,
            ),
          ),
        ),
      ),
    );
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }

    // The week's planned TSS is the plan's, shown without a connection.
    final weekPlanned = saved.weeks[0].plannedLoad;
    expect(
      find.textContaining('of $weekPlanned TSS this week'),
      findsOneWidget,
    );
    for (final s in tomorrows) {
      expect(find.text(s.name), findsWidgets, reason: 'tomorrow: ${s.name}');
    }
  });

  testWidgets('long-pressing "nothing planned" offers Train now for today',
      (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: TodayScreen(
            wellnessRepository: WellnessRepository(database: database),
            activitiesRepository: ActivitiesRepository(database: database),
            plannedItems: PlannedItemsRepository(
              events: EventsRepository(database: database),
              plans: PlansRepository(database: database),
              copyEvents: () async => true,
            ),
          ),
        ),
      ),
    );
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }

    final empty = find.byKey(const ValueKey('planned-empty'));
    expect(empty, findsWidgets); // today's and tomorrow's
    await tester.longPress(empty.first);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('day-propose')), findsOneWidget);
    expect(find.byKey(const ValueKey('day-delete')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('day-propose')));
    await tester.pumpAndSettle();
    expect(find.byType(TrainNowScreen), findsOneWidget);
  });
}
