import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/client/intervalls/intervalls_client.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/feel_prompt_store.dart';
import 'package:triiq/data/feel_settings.dart';
import 'package:triiq/data/intervals_session.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/models/local_wellness.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/data/repositories/events_repository.dart';
import 'package:triiq/data/repositories/plans_repository.dart';
import 'package:triiq/data/repositories/wellness_repository.dart';
import 'package:triiq/data/wellness_actions.dart';
import 'package:triiq/evaluation/activity_route.dart';
import 'package:triiq/evaluation/session_streams.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/data/planned_items.dart';
import 'package:triiq/plan/knowledge.dart';
import 'package:triiq/screens/activities/activity_detail_screen.dart';
import 'package:triiq/screens/insights/insights_card.dart';
import 'package:triiq/util/dates.dart';

void main() {
  late Directory dir;
  late AppDatabase database;
  late WellnessRepository wellness;
  late List<RequestOptions> requests;
  late WellnessActions actions;
  late FeelSettings feelSettings;
  late FeelPromptStore feelPromptStore;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dir = await Directory.systemTemp.createTemp('triiq_activity_detail_feel');
    database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
    wellness = WellnessRepository(database: database);

    requests = [];
    final dio = Dio(BaseOptions(baseUrl: 'https://intervals.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {'id': options.path.split('/').last},
            ),
          );
        },
      ),
    );
    actions = WellnessActions(
      session: IntervalsSession.forTesting(
        connected: true,
        client: IntervallsClient(dio: dio, interceptors: const []),
        athleteId: 'i42',
      ),
      wellness: wellness,
    );
    feelSettings = FeelSettings.forTesting();
    feelPromptStore = FeelPromptStore.forTesting();
  });

  tearDown(() async {
    IntervalsSession.instance.debugSetConnected(false);
    await database.close();
    await dir.delete(recursive: true);
  });

  LocalActivity activityOn(String date, {String id = 'a1'}) => LocalActivity(
    id: id,
    date: date,
    type: 'Run',
    name: 'Easy run',
    movingTime: 1800,
    distance: 5000,
    trainingLoad: 40,
    raw: {'id': id, 'start_date_local': '${date}T07:00:00'},
    syncedAt: DateTime.now(),
  );

  Future<void> open(
    WidgetTester tester,
    LocalActivity activity, {
    bool connected = true,
  }) async {
    IntervalsSession.instance.debugSetConnected(connected);
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: ActivityDetailScreen(
          activity: activity,
          wellness: wellness,
          wellnessActions: actions,
          feelSettings: feelSettings,
          feelPromptStore: feelPromptStore,
          streams: ActivityStreamsRepository(
            database: database,
            fetch: (_) async => const SessionStreams(series: {}, intervals: []),
          ),
          routes: ActivityRouteRepository(
            database: database,
            fetch: (_) async => const ActivityRoute([]),
          ),
          plannedItems: PlannedItemsRepository(
            events: EventsRepository(database: database),
            plans: PlansRepository(database: database),
            copyEvents: () async => true,
          ),
          insights: SessionInsightsLoader(
            activities: ActivitiesRepository(database: database),
            planned: PlannedItemsRepository(
              events: EventsRepository(database: database),
              plans: PlansRepository(database: database),
              copyEvents: () async => true,
            ),
            wellness: wellness,
            knowledge: KnowledgeRepository(
              loadAsset: () async => File('docs/okf.md').readAsStringSync(),
            ),
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

  /// Opens the app bar's overflow menu, where the feel action lives.
  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('activity-menu')));
    await tester.pumpAndSettle();
  }

  testWidgets('manual action works on an old activity, connected', (
    tester,
  ) async {
    final old = isoDate(DateTime.now().subtract(const Duration(days: 30)));
    await open(tester, activityOn(old));

    await openMenu(tester);
    expect(find.byKey(const ValueKey('feel-action')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('feel-action')));
    await tester.pumpAndSettle();

    expect(find.text('How did it feel?'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pump(const Duration(seconds: 1));
    for (var i = 0; i < 8; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 40)),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();

    expect(requests, hasLength(1));
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('manual action is disabled when not connected', (tester) async {
    final old = isoDate(DateTime.now().subtract(const Duration(days: 30)));
    await open(tester, activityOn(old), connected: false);

    await openMenu(tester);
    final item = tester.widget<PopupMenuItem<Object?>>(
      find.byKey(const ValueKey('feel-action')),
    );
    expect(item.enabled, isFalse);
  });

  testWidgets(
    'a recent, never-opened activity with nothing set auto-prompts once',
    (tester) async {
      final today = isoDate(DateTime.now());
      await open(tester, activityOn(today, id: 'new1'));

      expect(find.text('How did it feel?'), findsOneWidget);
      expect(feelPromptStore.hasPrompted('new1'), isTrue);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Reopening the same activity does not auto-prompt again.
      await tester.pumpWidget(const SizedBox());
      await open(tester, activityOn(today, id: 'new1'));
      expect(find.text('How did it feel?'), findsNothing);
    },
  );

  testWidgets('no auto-prompt when the day already has values', (tester) async {
    final today = isoDate(DateTime.now());
    await tester.runAsync(
      () => wellness.upsertAll([
        LocalWellness(
          date: today,
          ctl: null,
          atl: null,
          ctlLoad: null,
          atlLoad: null,
          rampRate: null,
          raw: {'id': today, 'fatigue': 2, 'soreness': 1},
          syncedAt: DateTime.now(),
        ),
      ]),
    );

    await open(tester, activityOn(today, id: 'new2'));

    expect(find.text('How did it feel?'), findsNothing);
  });

  testWidgets('no auto-prompt when the toggle is off', (tester) async {
    await feelSettings.setPromptOnNewActivity(false);
    final today = isoDate(DateTime.now());

    await open(tester, activityOn(today, id: 'new3'));

    expect(find.text('How did it feel?'), findsNothing);
    // The manual action still works regardless.
    await openMenu(tester);
    expect(find.byKey(const ValueKey('feel-action')), findsOneWidget);
  });

  testWidgets('no auto-prompt for an activity older than yesterday', (
    tester,
  ) async {
    final old = isoDate(DateTime.now().subtract(const Duration(days: 5)));

    await open(tester, activityOn(old, id: 'new4'));

    expect(find.text('How did it feel?'), findsNothing);
  });
}
