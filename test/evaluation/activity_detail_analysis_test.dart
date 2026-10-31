import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/agent/chat_handoff.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/data/planned_items.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/data/repositories/events_repository.dart';
import 'package:triiq/data/repositories/plans_repository.dart';
import 'package:triiq/evaluation/session_streams.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/activities/activity_detail_screen.dart';
import 'package:triiq/screens/activities/planned_workout_detail_screen.dart';
import 'package:triiq/widgets/main_navigation.dart';

void main() {
  late Directory dir;
  late AppDatabase database;
  late EventsRepository events;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dir = await Directory.systemTemp.createTemp('triiq_detail_analysis');
    database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
    events = EventsRepository(database: database);
    MainNavigation.instance.debugReset();
    ChatHandoff.instance.take();
  });

  tearDown(() async {
    await database.close();
    await dir.delete(recursive: true);
  });

  // 45 minutes, 5 HR zones: 2400 s low, 300 s moderate, 0 high.
  final ride = LocalActivity(
    id: 'i42',
    date: '2026-11-03',
    type: 'Ride',
    name: 'Morning ride',
    movingTime: 45 * 60,
    distance: 30000,
    trainingLoad: 40,
    raw: const {
      'id': 'i42',
      'icu_hr_zone_times': [1200, 1200, 150, 150, 0],
    },
    syncedAt: DateTime(2026, 11, 3),
  );

  LocalEvent planned() => LocalEvent(
    id: '77',
    date: '2026-11-03',
    category: 'WORKOUT',
    type: 'Ride',
    name: 'Z2 endurance',
    description: null,
    plannedLoad: 55,
    plannedTime: 3600,
    plannedDistance: null,
    indoor: false,
    raw: const {},
    syncedAt: DateTime(2026, 11, 1),
  );

  Future<void> pump(
    WidgetTester tester, {
    required StreamsFetcher fetch,
  }) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: ActivityDetailScreen(
          activity: ride,
          streams: ActivityStreamsRepository(database: database, fetch: fetch),
          plannedItems: PlannedItemsRepository(
            events: events,
            plans: PlansRepository(database: database),
            copyEvents: () async => true,
          ),
        ),
      ),
    );
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 40)),
      );
      await tester.pump();
    }
  }

  SessionStreams streams() => SessionStreams(
    series: {
      'time': [for (var i = 0; i < 2700; i++) i.toDouble()],
      'watts': [for (var i = 0; i < 2700; i++) 180],
      'heartrate': [for (var i = 0; i < 2700; i++) 135],
    },
    intervals: const [
      SessionInterval(
        start: 600,
        end: 900,
        type: 'WORK',
        movingTime: 300,
        averageWatts: 260,
        averageHeartrate: 158,
      ),
    ],
  );

  testWidgets('streams, intervals and a verdict against the plan',
      (tester) async {
    await tester.runAsync(
      () => events.replaceRange('2026-11-03', '2026-11-03', [planned()]),
    );
    await pump(tester, fetch: (_) async => streams());

    expect(find.text('Over time'), findsOneWidget);
    expect(find.byKey(const ValueKey('stream-watts')), findsOneWidget);
    expect(find.byKey(const ValueKey('interval-0')), findsOneWidget);
    expect(find.textContaining('260 W'), findsOneWidget);

    // 45 of 60 planned minutes.
    expect(find.text('Cut short'), findsOneWidget);
    expect(find.textContaining('45 of 60 planned minutes'), findsOneWidget);
    expect(find.text('45 of 60 min (-15)'), findsOneWidget);
    expect(find.text('40 of 55 TSS (-15)'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('split-text'))).data,
      'Low 89% · Moderate 11% · High 0%',
    );
  });

  testWidgets('no plan, no streams: says so instead of guessing',
      (tester) async {
    await pump(
      tester,
      fetch: (_) async => const SessionStreams(series: {'time': []}),
    );

    expect(find.text('No planned session to compare with.'), findsOneWidget);
    expect(find.textContaining('no time-series data'), findsOneWidget);
  });

  testWidgets('a failed fetch shows retry, and retry loads', (tester) async {
    var calls = 0;
    await pump(
      tester,
      fetch: (_) async {
        calls++;
        if (calls == 1) throw StateError('offline');
        return streams();
      },
    );

    expect(find.textContaining('Could not load the time series'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 40)),
      );
      await tester.pump();
    }
    expect(find.byKey(const ValueKey('stream-watts')), findsOneWidget);
  });

  testWidgets('Ask the trainer hands the session to Chat', (tester) async {
    await tester.runAsync(
      () => events.replaceRange('2026-11-03', '2026-11-03', [planned()]),
    );
    await pump(tester, fetch: (_) async => streams());

    await tester.ensureVisible(find.byKey(const ValueKey('ask-trainer')));
    await tester.tap(find.byKey(const ValueKey('ask-trainer')));
    await tester.pump();

    expect(MainNavigation.instance.requestedTab, MainNavigation.chatTab);
    final topic = ChatHandoff.instance.take()!;
    expect(topic.title, 'Morning ride');
    expect(topic.context, contains('"verdict":"cutShort"'));
    expect(topic.context, contains('"Z2 endurance"'));
  });

  testWidgets('the planned session shows what was done against it',
      (tester) async {
    final activities = ActivitiesRepository(database: database);
    await tester.runAsync(() => activities.upsertAll([ride]));
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: PlannedWorkoutDetailScreen(
          event: planned(),
          activities: activities,
        ),
      ),
    );
    for (var i = 0; i < 8; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 40)),
      );
      await tester.pump();
    }

    expect(find.byKey(const ValueKey('planned-actual')), findsOneWidget);
    expect(find.text('Done: Morning ride'), findsOneWidget);
    expect(find.text('45 of 60 min (-15)'), findsOneWidget);
    expect(find.text('40 of 55 TSS (-15)'), findsOneWidget);
  });
}
