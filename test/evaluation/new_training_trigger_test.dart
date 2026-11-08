import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/data/planned_items.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/data/repositories/events_repository.dart';
import 'package:triiq/data/repositories/plans_repository.dart';
import 'package:triiq/data/repositories/wellness_repository.dart';
import 'package:triiq/evaluation/new_training.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/plan/knowledge.dart';
import 'package:triiq/screens/insights/insights_card.dart';
import 'package:triiq/screens/insights/new_training_trigger.dart';
import 'package:triiq/util/dates.dart';

void main() {
  late Directory dir;
  late AppDatabase database;
  late ActivitiesRepository activities;
  late EventsRepository events;
  late StreamController<void> openSync;
  var enabled = true;
  final now = DateTime.now();
  final today = isoDate(now);

  LocalActivity act(String id, String start, {int load = 60}) => LocalActivity(
    id: id,
    date: today,
    type: 'Ride',
    name: id,
    movingTime: 3600,
    distance: null,
    trainingLoad: load,
    raw: {'start_date_local': '${today}T$start'},
    syncedAt: now,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dir = await Directory.systemTemp.createTemp('triiq_trigger');
    database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
    activities = ActivitiesRepository(database: database);
    events = EventsRepository(database: database);
    openSync = StreamController<void>.broadcast();
    enabled = true;
  });

  tearDown(() async {
    await openSync.close();
    await database.close();
    await dir.delete(recursive: true);
  });

  Future<void> realWait(WidgetTester tester, [int rounds = 10]) async {
    for (var i = 0; i < rounds; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 40)),
      );
      await tester.pump();
    }
  }

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final planned = PlannedItemsRepository(
      events: events,
      plans: PlansRepository(database: database),
      copyEvents: () async => true,
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: NewTrainingTrigger(
          openSyncDone: openSync.stream,
          insights: NewTrainingInsights(activities: activities),
          enabled: () => enabled,
          plannedItems: planned,
          sessionInsights: SessionInsightsLoader(
            activities: activities,
            planned: planned,
            wellness: WellnessRepository(database: database),
            knowledge: KnowledgeRepository(
              loadAsset: () async => File('docs/okf.md').readAsStringSync(),
            ),
          ),
          child: const Scaffold(body: Text('home')),
        ),
      ),
    );
  }

  Future<void> fire(WidgetTester tester) async {
    openSync.add(null);
    await realWait(tester);
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('an unseen session pops up after the open sync, once', (
    tester,
  ) async {
    await tester.runAsync(
      () => activities.upsertAll([act('ride', '07:00:00')]),
    );
    await pump(tester);
    await realWait(tester, 3);
    expect(find.text('New training'), findsNothing, reason: 'not before sync');

    await fire(tester);
    expect(find.text('New training'), findsOneWidget);
    expect(find.text('ride'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('new-training-ok')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await realWait(tester);
    expect(find.text('New training'), findsNothing);
    final seen = await tester.runAsync(() => SeenSessionsStore().seenToday());
    expect(seen, {'ride'});

    await fire(tester);
    expect(find.text('New training'), findsNothing, reason: 'already seen');
  });

  testWidgets('two sessions: one page each with dots', (tester) async {
    await tester.runAsync(
      () => activities.upsertAll([
        act('swim', '06:30:00'),
        act('run', '18:00:00'),
      ]),
    );
    await pump(tester);
    await fire(tester);

    expect(find.byKey(const ValueKey('new-training-dots')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('new-training-run')),
      findsOneWidget,
      reason: 'newest first',
    );

    await tester.tap(find.byKey(const ValueKey('new-training-ok')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await realWait(tester);
    expect(await tester.runAsync(() => SeenSessionsStore().seenToday()), {
      'run',
      'swim',
    });
  });

  testWidgets('switched off, or nothing new: no sheet', (tester) async {
    await tester.runAsync(
      () => activities.upsertAll([act('ride', '07:00:00')]),
    );
    enabled = false;
    await pump(tester);
    await fire(tester);
    expect(find.text('New training'), findsNothing);
  });

  testWidgets('never over another screen', (tester) async {
    await tester.runAsync(
      () => activities.upsertAll([act('ride', '07:00:00')]),
    );
    await pump(tester);
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    nav.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('other')),
      ),
    );
    await tester.pumpAndSettle();

    await fire(tester);
    expect(find.text('New training'), findsNothing);
  });

  testWidgets('a hard day before planned intervals offers an alternative', (
    tester,
  ) async {
    await tester.runAsync(
      () => activities.upsertAll([act('big', '07:00:00', load: 220)]),
    );
    final tomorrow = isoDate(now.add(const Duration(days: 1)));
    await tester.runAsync(
      () => events.replaceRange(tomorrow, tomorrow, [
        LocalEvent(
          id: 'e1',
          date: tomorrow,
          category: 'WORKOUT',
          type: 'Ride',
          name: 'Threshold intervals',
          description: null,
          plannedLoad: 90,
          plannedTime: 3600,
          plannedDistance: null,
          indoor: false,
          raw: const {},
          syncedAt: now,
        ),
      ]),
    );
    await pump(tester);
    await fire(tester);
    await realWait(tester);

    expect(find.byKey(const ValueKey('insights-recovery')), findsOneWidget);
    expect(find.text('About 48 hours'), findsOneWidget);
    expect(find.byKey(const ValueKey('insights-alternative')), findsOneWidget);
  });
}
