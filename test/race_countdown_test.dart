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
import 'package:triiq/plan/plan_models.dart';
import 'package:triiq/screens/plan/plan_labels.dart';
import 'package:triiq/screens/today/today_screen.dart';
import 'package:triiq/util/dates.dart';

void main() {
  late Directory dir;
  late AppDatabase database;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dir = await Directory.systemTemp.createTemp('triiq_race_countdown');
    database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
  });

  tearDown(() async {
    await database.close();
    await dir.delete(recursive: true);
  });

  Future<void> pumpToday(
    WidgetTester tester, {
    DateTime? event,
    bool activePlan = true,
  }) async {
    final plans = PlansRepository(database: database);
    await tester.runAsync(() async {
      await GoalStore().save(
        Goal(
          targetType: 'long_distance',
          weekdays: const {2, 4, 6},
          weeklyHours: 6,
          eventDate: event,
        ),
      );
      if (activePlan) {
        await plans.save(
          TrainingPlan(
            goalType: 'long_distance',
            sport: 'Run',
            startDate: startOfWeek(DateTime.now()),
            baselineLoad: 300,
            weeks: const [],
            status: PlanStatus.active,
          ),
        );
      }
    });

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
            goalStore: GoalStore(),
            plansRepository: plans,
          ),
        ),
      ),
    );
    for (var i = 0; i < 40; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }
  }

  final today = dateOnly(DateTime.now());

  testWidgets('a future event: Race in N days', (tester) async {
    await pumpToday(
      tester,
      event: DateTime(today.year, today.month, today.day + 23),
    );

    expect(find.text('Race in 23 days'), findsOneWidget);
  });

  testWidgets('on the day: race day', (tester) async {
    await pumpToday(tester, event: today);

    expect(find.text('Race day!'), findsOneWidget);
  });

  testWidgets('no event, or no active plan: no countdown', (tester) async {
    await pumpToday(tester);
    expect(find.byKey(const ValueKey('race-countdown')), findsNothing);
  });

  testWidgets('without an active plan the goal date alone shows nothing', (
    tester,
  ) async {
    await pumpToday(
      tester,
      event: DateTime(today.year, today.month, today.day + 10),
      activePlan: false,
    );
    expect(find.byKey(const ValueKey('race-countdown')), findsNothing);
  });

  testWidgets('taper and race week have their own labels in both languages', (
    tester,
  ) async {
    late AppLocalizations en;
    late AppLocalizations de;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            en = lookupAppLocalizations(const Locale('en'));
            de = lookupAppLocalizations(const Locale('de'));
            return const SizedBox();
          },
        ),
      ),
    );

    expect(phaseLabel(en, 'taper'), 'Taper');
    expect(phaseLabel(en, 'race'), 'Race week');
    expect(phaseLabel(de, 'race'), 'Wettkampfwoche');
    expect(en.planEventBeyondPlan(24), contains('16 weeks'));
  });
}
