import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/data/planned_items.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/data/repositories/events_repository.dart';
import 'package:triiq/data/repositories/plans_repository.dart';
import 'package:triiq/data/repositories/wellness_repository.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/plan/knowledge.dart';
import 'package:triiq/plan/plan_models.dart';
import 'package:triiq/screens/activities/planned_workout_detail_screen.dart';
import 'package:triiq/screens/today/today_screen.dart';
import 'package:triiq/util/dates.dart';

/// Whether tapping the Today screen's planned-training cards offers
/// "Change Training" directly (a TriIQ plan session) or still opens the
/// full planned-workout detail screen first (a synced, non-plan event).
void main() {
  late Directory dir;
  late AppDatabase database;
  late PlansRepository plans;
  late EventsRepository events;
  late PlannedItemsRepository plannedItems;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dir = await Directory.systemTemp.createTemp('triiq_today_screen');
    database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
    plans = PlansRepository(database: database);
    events = EventsRepository(database: database);
    plannedItems = PlannedItemsRepository(
      events: events,
      plans: plans,
      copyEvents: () async => true,
    );
  });

  tearDown(() async {
    await database.close();
    await dir.delete(recursive: true);
  });

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

  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: TodayScreen(
          plannedItems: plannedItems,
          wellnessRepository: WellnessRepository(database: database),
          activitiesRepository: ActivitiesRepository(database: database),
        ),
      ),
    );
    await settle(tester);
  }

  TrainingPlan planWith(PlanSession session) => TrainingPlan(
    goalType: 'long_distance',
    sport: session.sport,
    startDate: dateOnly(session.date),
    baselineLoad: 300,
    status: PlanStatus.active,
    weeks: [
      PlanWeek(
        index: 0,
        phase: 'build',
        startDate: dateOnly(session.date),
        targetLoad: session.load.toDouble(),
        requestedLoad: session.load.toDouble(),
        limit: WeekLimit.none,
        projectedCtlEnd: null,
        sessions: [session],
        lowIntensityTarget: 0.8,
        lowIntensityTolerance: 0.05,
      ),
    ],
  );

  testWidgets(
    "a TriIQ plan session on Today's Training opens the sheet directly, "
    'with Change Training',
    (tester) async {
      final today = DateTime.now();
      await tester.runAsync(
        () => plans.save(
          planWith(
            PlanSession(
              weekIndex: 0,
              date: today,
              slot: SessionSlot.z2,
              templateId: 't',
              name: 'Easy spin',
              sport: 'Ride',
              minutes: 45,
              load: 30,
              lowMinutes: 45,
              description: '- 45m 65% FTP',
            ),
          ),
        ),
      );

      await open(tester);

      await tester.tap(find.text('Easy spin'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('change-training')), findsOneWidget);
      expect(find.byType(PlannedWorkoutDetailScreen), findsNothing);
    },
  );

  testWidgets(
    "a synced Intervals.icu event on Tomorrow's Training still opens the "
    'full detail screen',
    (tester) async {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final tomorrowIso = isoDate(tomorrow);
      await tester.runAsync(
        () => events.replaceRange(tomorrowIso, tomorrowIso, [
          LocalEvent(
            id: '501',
            date: tomorrowIso,
            category: 'WORKOUT',
            type: 'Swim',
            name: 'Coach swim',
            description: null,
            plannedLoad: 40,
            plannedTime: 2700,
            plannedDistance: null,
            indoor: false,
            raw: const {},
            syncedAt: DateTime.now(),
          ),
        ]),
      );

      await open(tester);

      await tester.tap(find.text('Coach swim'));
      await tester.pumpAndSettle();

      expect(find.byType(PlannedWorkoutDetailScreen), findsOneWidget);
      expect(find.byKey(const ValueKey('change-training')), findsNothing);

      // PlannedActualCard fetches activities for the day in a FutureBuilder;
      // let it resolve before the test ends so no timer is left pending.
      await settle(tester);
    },
  );
}
