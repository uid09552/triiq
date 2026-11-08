// Regression tests for the review findings #38–#44.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/agent/chat_model_factory.dart';
import 'package:triiq/agent/llm_settings.dart';
import 'package:triiq/agent/training_agent.dart';
import 'package:triiq/data/data_eraser.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/intervals_workout_service.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/data/pending_deletes.dart';
import 'package:triiq/data/planned_items.dart';
import 'package:triiq/data/privacy_settings.dart';
import 'package:triiq/data/repositories/events_repository.dart';
import 'package:triiq/data/repositories/plans_repository.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/plan/plan_changes.dart';
import 'package:triiq/screens/activities/planned_workout_actions.dart';
import 'package:triiq/screens/chat/chat_screen.dart';
import 'package:triiq/screens/statistics/statistics_screen.dart';
import 'package:triiq/widgets/osm_layers.dart';
import 'package:triiq/client/intervalls/intervalls_client.dart';

import 'privacy_test.dart' show FakeNotifications;

Widget _app(Widget home, {Locale locale = const Locale('en')}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: locale,
  home: home,
);

Future<void> _settle(WidgetTester tester, {int rounds = 10}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
}

class _Writer implements PlannedWorkoutWriter {
  final deleted = <String>[];

  @override
  Future<Event> createPlannedWorkout(PlannedWorkoutDraft draft) async =>
      Event(id: 900);

  @override
  Future<void> updatePlannedWorkoutDate(String eventId, DateTime date) async {}

  @override
  Future<void> deletePlannedWorkout(String eventId) async =>
      deleted.add(eventId);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('#38 AI consent is enforced where requests are made', () {
    setUp(() async {
      await LlmSettings.instance.load();
      await LlmSettings.instance.setProvider(LlmProvider.ollama);
      await LlmSettings.instance.setOllamaBaseUrl('http://localhost:11434');
      await PrivacySettings.instance.setAiConsent(false);
    });
    tearDown(() => PrivacySettings.instance.setAiConsent(false));

    test('no chat model is built without consent', () async {
      expect(
        () => createChatModel(LlmSettings.instance),
        throwsA(isA<AiConsentRequiredException>()),
      );
      await PrivacySettings.instance.setAiConsent(true);
      expect(createChatModel(LlmSettings.instance), isNotNull);
    });

    test('the agent refuses before building or sending anything', () async {
      var built = false;
      final agent = TrainingAgent(
        settings: LlmSettings.instance,
        chatModelFactory: (settings, tools) {
          built = true;
          throw StateError('must not be reached');
        },
      );
      await expectLater(
        agent.send('how was my week?'),
        emitsError(isA<AiConsentRequiredException>()),
      );
      expect(built, isFalse);
    });

    testWidgets('the chat input and send button are off without consent', (
      tester,
    ) async {
      await tester.pumpWidget(_app(const Scaffold(body: ChatScreen())));
      await tester.pump();
      final input = tester.widget<TextField>(
        find.byKey(const ValueKey('chat-input')),
      );
      final send = tester.widget<IconButton>(
        find.byKey(const ValueKey('chat-send')),
      );
      expect(input.enabled, isFalse);
      expect(send.onPressed, isNull);
      expect(find.byKey(const ValueKey('ai-consent-card')), findsOneWidget);

      await tester.runAsync(() => PrivacySettings.instance.setAiConsent(true));
      await tester.pump();
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('chat-input')))
            .enabled,
        isTrue,
      );
    });
  });

  group('#39/#40 delete all data', () {
    late Directory dir;
    late AppDatabase database;

    setUp(() async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      dir = await Directory.systemTemp.createTemp('triiq_erase');
      database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
    });
    tearDown(() async {
      await database.close();
      await dir.delete(recursive: true);
    });

    test(
      'also clears notifications, the widget, backup copies and reloads',
      () async {
        final temp = await Directory(p.join(dir.path, 'tmp')).create();
        final backup = File(
          p.join(temp.path, 'triiq-backup-20261107-1200.json'),
        )..writeAsStringSync('{}');
        final other = File(p.join(temp.path, 'something-else.json'))
          ..writeAsStringSync('{}');
        final notifications = FakeNotifications();
        var widgetCleared = 0;
        var reloaded = 0;
        final llm = LlmSettings.forTesting();
        await llm.setProvider(LlmProvider.ollama);
        await llm.setOllamaModel('custom');

        await DataEraser(
          database: database,
          llm: llm,
          privacy: PrivacySettings.forTesting(),
          notifications: notifications,
          clearHomeWidget: () async => widgetCleared++,
          tempDirectory: () async => temp,
          reloaders: [() async => reloaded++, () async => reloaded++],
        ).eraseAll();

        expect(notifications.briefingCancelled, 1);
        expect(notifications.reminderCancelled, 1);
        expect(widgetCleared, 1);
        expect(backup.existsSync(), isFalse);
        expect(other.existsSync(), isTrue); // not ours
        expect(reloaded, 2);
        // A fresh install in memory, not the old provider written back later.
        expect(llm.provider, LlmProvider.claude);
        expect(llm.ollamaModel, LlmSettings.defaultOllamaModel);
      },
    );

    test('the database file keeps no free pages after erasing', () async {
      final events = EventsRepository(database: database);
      await events.replaceRange('2026-11-01', '2026-11-30', [
        for (var d = 1; d <= 28; d++)
          LocalEvent(
            id: '$d',
            date: '2026-11-${d.toString().padLeft(2, '0')}',
            category: 'WORKOUT',
            type: 'Ride',
            name: 'x' * 500,
            description: 'y' * 2000,
            plannedLoad: 1,
            plannedTime: 1,
            plannedDistance: null,
            indoor: false,
            raw: const {},
            syncedAt: DateTime(2026),
          ),
      ]);
      await database.eraseAll();
      final db = await database.database;
      final free = await db.rawQuery('PRAGMA freelist_count');
      expect(free.first.values.first, 0);
    });
  });

  group('#41 the undo window writes nothing app-wide', () {
    late Directory dir;
    late AppDatabase database;

    setUp(() async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      dir = await Directory.systemTemp.createTemp('triiq_undo41');
      database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
    });
    tearDown(() async {
      PendingDeletes.instance.restore('501');
      await database.close();
      await dir.delete(recursive: true);
    });

    LocalEvent event() => LocalEvent(
      id: '501',
      date: '2026-11-09',
      category: 'WORKOUT',
      type: 'Ride',
      name: 'Coach ride',
      description: '',
      plannedLoad: 60,
      plannedTime: 3600,
      plannedDistance: null,
      indoor: false,
      raw: const {},
      syncedAt: DateTime(2026),
    );

    testWidgets('plan-change listeners hear nothing until the real delete', (
      tester,
    ) async {
      final events = EventsRepository(database: database);
      await tester.runAsync(
        () => events.replaceRange('2026-11-09', '2026-11-09', [event()]),
      );
      var planChanges = 0;
      void count() => planChanges++;
      PlanChanges.instance.addListener(count);
      addTearDown(() => PlanChanges.instance.removeListener(count));
      final hidden = PendingDeletes.forTesting();
      var hiddenNotices = 0;
      hidden.addListener(() => hiddenNotices++);

      await tester.pumpWidget(
        _app(
          Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => deletePlannedWorkoutWithUndo(
                  context,
                  event(),
                  workoutService: _Writer(),
                  eventsRepository: events,
                  plansRepository: PlansRepository(database: database),
                  pendingDeletes: hidden,
                ),
                child: const Text('delete'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('delete'));
      await tester.pump();
      expect(hiddenNotices, 1); // the on-screen lists react
      expect(planChanges, 0); // the widget and the briefing do not

      for (var i = 0; i < 9; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await _settle(tester);
      expect(planChanges, 1); // only once it really happened
    });

    test(
      'what leaves the app still counts a session inside its window',
      () async {
        final events = EventsRepository(database: database);
        await events.replaceRange('2026-11-09', '2026-11-09', [event()]);
        PendingDeletes.instance.hide('501');
        final screens = PlannedItemsRepository(
          events: events,
          plans: PlansRepository(database: database),
          copyEvents: () async => true,
        );
        final outside = PlannedItemsRepository(
          events: events,
          plans: PlansRepository(database: database),
          copyEvents: () async => true,
          hidePendingDeletes: false,
        );
        expect(await screens.getByDate('2026-11-09'), isEmpty);
        expect(await outside.getByDate('2026-11-09'), hasLength(1));
      },
    );
  });

  group('#43 map tiles only with the choice loaded and allowed', () {
    test('not loaded yet means no tiles', () async {
      final privacy = PrivacySettings.forTesting();
      expect(mapTilesAllowed(privacy), isFalse);
      await privacy.load();
      expect(mapTilesAllowed(privacy), isTrue);
      await privacy.setMapTiles(false);
      expect(mapTilesAllowed(privacy), isFalse);
      await privacy.setMapTiles(true);
      expect(mapTilesAllowed(privacy, showTiles: false), isFalse);
    });

    testWidgets('the tile layer follows the switch while on screen', (
      tester,
    ) async {
      final privacy = PrivacySettings.forTesting();
      await tester.pumpWidget(
        _app(Scaffold(body: OsmTileLayer(privacy: privacy))),
      );
      expect(find.byKey(const ValueKey('osm-tiles')), findsNothing);
      // Switched off before it loads: it must never appear.
      await tester.runAsync(() async {
        await privacy.load();
        await privacy.setMapTiles(false);
      });
      await tester.pump();
      expect(find.byKey(const ValueKey('osm-tiles')), findsNothing);
    });
  });

  testWidgets('#44 Statistics fits a narrow phone in German', (tester) async {
    await tester.binding.setSurfaceSize(const Size(300, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _app(
        const Scaffold(body: StatisticsScreen()),
        locale: const Locale('de'),
      ),
    );
    await _settle(tester);
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('sync-status')), findsOneWidget);
  });
}
