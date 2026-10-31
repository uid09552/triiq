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
import 'package:triiq/data/repositories/plans_repository.dart';
import 'package:triiq/data/sync/sync_settings.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/plan/knowledge.dart';
import 'package:triiq/plan/plan_engine.dart';
import 'package:triiq/plan/plan_models.dart';
import 'package:triiq/plan/plan_service.dart';
import 'package:triiq/plan/plan_writer.dart';
import 'package:triiq/screens/settings/calendar_settings_section.dart';
import 'package:triiq/util/dates.dart';

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
  late Directory dir;
  late AppDatabase database;
  late PlansRepository plans;
  late _RecordingWorkouts workouts;
  late PlanService service;
  late SyncSettings settings;
  final synced = <(DateTime, DateTime)>[];

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dir = await Directory.systemTemp.createTemp('triiq_calendar_section');
    database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
    plans = PlansRepository(database: database);
    workouts = _RecordingWorkouts();
    service = PlanService(
      plans: plans,
      writer: PlanWriter(
        workouts: workouts,
        plans: plans,
        afterWrite: (_, _) async {},
      ),
    );
    settings = SyncSettings.forTesting();
    synced.clear();
  });

  tearDown(() async {
    await database.close();
    await dir.delete(recursive: true);
  });

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: CalendarSettingsSection(
            settings: settings,
            planService: service,
            session: IntervalsSession.forTesting(connected: true),
            syncRange: (a, b) async => synced.add((a, b)),
          ),
        ),
      ),
    );
  }

  Future<void> realWait(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }
  }

  testWidgets('copy back on syncs the current month', (tester) async {
    await settings.setCopyIntervalsEvents(false);
    await pump(tester);

    await tester.tap(find.byKey(const ValueKey('calendar-copy-events')));
    await tester.pump();

    expect(settings.copyIntervalsEvents, isTrue);
    expect(synced, hasLength(1));
    final now = DateTime.now();
    expect(synced.single.$1, DateTime(now.year, now.month, 1));
  });

  testWidgets('copy off just stores it', (tester) async {
    await pump(tester);

    await tester.tap(find.byKey(const ValueKey('calendar-copy-events')));
    await tester.pump();

    expect(settings.copyIntervalsEvents, isFalse);
    expect(synced, isEmpty);
  });

  testWidgets('send back on offers to send only upcoming local sessions',
      (tester) async {
    // Two weeks starting last Monday: some sessions are already past.
    final knowledge = TrainingKnowledge.parse(
      File('docs/okf.md').readAsStringSync(),
    );
    final start = startOfWeek(DateTime.now()).subtract(const Duration(days: 7));
    final draft = PlanEngine(knowledge)
        .generate(
          goal: const Goal(
            targetType: 'long_distance',
            weekdays: {1, 2, 3, 4, 5, 6, 7},
            weeklyHours: 8,
            baselineWeeklyLoad: 300,
            weeks: 2,
          ),
          startDate: start,
          recentWeeklyLoads: null,
          today: start,
        )
        .plan!;
    final saved = await tester.runAsync(() => service.take(draft));
    final today = dateOnly(DateTime.now());
    final upcoming = saved!.sessions
        .where((s) => !s.date.isBefore(today))
        .length;
    expect(upcoming, lessThan(saved.sessions.length));

    await settings.setSendPlanToIntervals(false);
    await pump(tester);
    await tester.tap(find.byKey(const ValueKey('calendar-send-plan')));
    await realWait(tester);
    await tester.pumpAndSettle();

    expect(find.text('Send your plan now?'), findsOneWidget);
    await tester.tap(find.byType(FilledButton));
    await realWait(tester);
    await tester.pumpAndSettle();

    expect(settings.sendPlanToIntervals, isTrue);
    expect(workouts.created, hasLength(upcoming));
    expect(
      workouts.created.every((d) => !d.date.isBefore(today)),
      isTrue,
    );
  });
}
