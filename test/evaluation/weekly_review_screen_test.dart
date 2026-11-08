import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langchain_core/chat_models.dart';
import 'package:langchain_core/language_models.dart';
import 'package:langchain_core/prompts.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/agent/llm_settings.dart';
import 'package:triiq/agent/tools/training_data_tools.dart';
import 'package:triiq/agent/training_agent.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/data/planned_items.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/data/repositories/events_repository.dart';
import 'package:triiq/data/repositories/plans_repository.dart';
import 'package:triiq/data/repositories/sync_state_repository.dart';
import 'package:triiq/data/repositories/wellness_repository.dart';
import 'package:triiq/evaluation/weekly_review.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/statistics/weekly_review_screen.dart';

void main() {
  late Directory dir;
  late AppDatabase database;
  late WeeklyReviewLoader loader;
  final monday = DateTime(2026, 11, 2);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dir = await Directory.systemTemp.createTemp('triiq_weekly_review');
    database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
    final activities = ActivitiesRepository(database: database);
    final events = EventsRepository(database: database);
    await activities.upsertAll([
      LocalActivity(
        id: 'a1',
        date: '2026-11-03',
        type: 'Run',
        name: 'Easy run',
        movingTime: 3600,
        distance: null,
        trainingLoad: 50,
        raw: const {
          'icu_hr_zone_times': [1000, 1000, 800, 800, 0],
        },
        syncedAt: DateTime(2026, 11, 3),
      ),
    ]);
    LocalEvent plan(String id, String date) => LocalEvent(
      id: id,
      date: date,
      category: 'WORKOUT',
      type: 'Run',
      name: id,
      description: null,
      plannedLoad: 50,
      plannedTime: 3600,
      plannedDistance: null,
      indoor: false,
      raw: const {},
      syncedAt: DateTime(2026, 11, 1),
    );
    await events.replaceRange('2026-11-02', '2026-11-08', [
      plan('Easy', '2026-11-03'),
      plan('Long run', '2026-11-07'),
    ]);
    loader = WeeklyReviewLoader(
      activities: activities,
      planned: PlannedItemsRepository(
        events: events,
        plans: PlansRepository(database: database),
        copyEvents: () async => true,
      ),
      wellness: WellnessRepository(database: database),
    );
  });

  tearDown(() async {
    await database.close();
    await dir.delete(recursive: true);
  });

  Future<void> pump(
    WidgetTester tester, {
    required LlmSettings settings,
    TrainingAgent Function()? agent,
  }) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: WeeklyReviewScreen(
          loader: loader,
          settings: settings,
          agentFactory: agent,
          initialWeek: monday,
        ),
      ),
    );
    for (var i = 0; i < 12; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 40)),
      );
      await tester.pump();
    }
  }

  testWidgets('figures from the cache; no provider means no note', (
    tester,
  ) async {
    await pump(tester, settings: LlmSettings.forTesting());

    expect(
      tester.widget<Text>(find.byKey(const ValueKey('weekly-compliance'))).data,
      '50% done (1 of 2 planned sessions)',
    );
    expect(find.text('✗ missed: Long run'), findsOneWidget);
    expect(find.byKey(const ValueKey('weekly-8020-flag')), findsOneWidget);
    expect(
      find.text('Not enough earlier weeks cached to compare.'),
      findsOneWidget,
    );
    expect(find.text('Next week'), findsNothing);
  });

  testWidgets('with a provider the labelled note appears', (tester) async {
    final settings = LlmSettings.forTesting();
    await settings.setProvider(LlmProvider.ollama);
    await settings.setOllamaBaseUrl('http://localhost:11434');
    final model = _ScriptedChatModel([
      AIChatMessage.text('- Do the long run you missed.'),
    ]);

    await pump(
      tester,
      settings: settings,
      agent: () => TrainingAgent(
        settings: LlmSettings.forTesting(),
        tools: TrainingDataTools(
          syncStateRepository: _EmptySyncState(),
          loadTrainingGuidance: () async => '# 1. Topic\n\nBody.\n',
          clock: () => monday,
        ),
        clock: () => monday,
        chatModelFactory: (_, _) => model,
      ),
    );

    expect(find.text('Next week'), findsOneWidget);
    expect(find.textContaining('an inference'), findsOneWidget);
    // Rendered as markdown: a bullet, not the raw "- " source.
    expect(find.byKey(const ValueKey('weekly-note')), findsOneWidget);
    expect(find.text('Do the long run you missed.'), findsOneWidget);
    expect(find.textContaining('- Do'), findsNothing);
    final system = model.prompts.single
        .whereType<SystemChatMessage>()
        .map((m) => m.content)
        .join();
    expect(system, contains('"missed_sessions"'));
  });
}

class _ScriptedChatModel extends BaseChatModel<FakeChatModelOptions> {
  _ScriptedChatModel(this.turns)
    : super(defaultOptions: const FakeChatModelOptions());

  final List<AIChatMessage> turns;
  final prompts = <List<ChatMessage>>[];
  int _index = 0;

  @override
  String get modelType => 'scripted';

  @override
  Future<ChatResult> invoke(
    final PromptValue input, {
    final FakeChatModelOptions? options,
  }) async {
    prompts.add(input.toChatMessages());
    return ChatResult(
      id: 's$_index',
      output: turns[_index++],
      finishReason: FinishReason.stop,
      metadata: const {},
      usage: const LanguageModelUsage(),
    );
  }

  @override
  Stream<ChatResult> stream(
    final PromptValue input, {
    final FakeChatModelOptions? options,
  }) async* {
    yield await invoke(input, options: options);
  }

  @override
  Future<List<int>> tokenize(
    final PromptValue promptValue, {
    final FakeChatModelOptions? options,
  }) async => const [];
}

class _EmptySyncState implements SyncStateRepository {
  @override
  Future<({DateTime lastSyncedAt, String newest, String oldest})?> get(
    String scope,
  ) async => null;

  @override
  Future<void> recordSync(
    String scope, {
    required String oldest,
    required String newest,
  }) async {}
}
