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
import 'package:triiq/client/intervalls/intervalls_client.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/intervals_session.dart';
import 'package:triiq/data/intervals_workout_service.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/data/planned_items.dart';
import 'package:triiq/data/repositories/events_repository.dart';
import 'package:triiq/data/repositories/plans_repository.dart';
import 'package:triiq/data/repositories/sync_state_repository.dart';
import 'package:triiq/data/sync/sync_service.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/plan/knowledge.dart';
import 'package:triiq/plan/plan_actions.dart';
import 'package:triiq/plan/plan_changes.dart';
import 'package:triiq/plan/plan_models.dart';
import 'package:triiq/screens/today/train_now_screen.dart';
import 'package:triiq/util/dates.dart';

final _today = DateTime(2026, 11, 3);

PlanSession _session({
  required int id,
  required String name,
  required String sport,
  required SessionSlot slot,
  required int minutes,
  required int load,
  String description = '- 15m 75% Pace\n4x\n  - 8m 95% Pace\n  - 4m 70% Pace',
  String? eventId,
}) => PlanSession(
  id: id,
  weekIndex: 0,
  date: _today,
  slot: slot,
  templateId: 't',
  name: name,
  sport: sport,
  minutes: minutes,
  load: load,
  lowMinutes: minutes * 0.6,
  description: description,
  intervalsEventId: eventId,
  status: eventId == null
      ? PlanSessionStatus.planned
      : PlanSessionStatus.created,
);

TrainingPlan _plan(List<PlanSession> sessions) => TrainingPlan(
  goalType: 'long_distance',
  sport: 'Run',
  startDate: DateTime(2026, 11, 2),
  baselineLoad: 300,
  status: PlanStatus.active,
  weeks: [
    PlanWeek(
      index: 0,
      phase: 'build',
      startDate: DateTime(2026, 11, 2),
      targetLoad: 300,
      requestedLoad: 300,
      limit: WeekLimit.none,
      projectedCtlEnd: null,
      sessions: sessions,
      lowIntensityTarget: 0.8,
      lowIntensityTolerance: 0.05,
    ),
  ],
);

class _NoWorkouts implements PlannedWorkoutWriter {
  final created = <PlannedWorkoutDraft>[];

  @override
  Future<Event> createPlannedWorkout(PlannedWorkoutDraft draft) async {
    created.add(draft);
    return Event(id: 1);
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
  late _NoWorkouts workouts;
  var send = true;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LlmSettings.instance.load();
    await LlmSettings.instance.setProvider(LlmProvider.ollama);
    await LlmSettings.instance.setOllamaBaseUrl('http://localhost:11434');
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dir = await Directory.systemTemp.createTemp('triiq_train_now');
    database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
    plans = PlansRepository(database: database);
    workouts = _NoWorkouts();
    send = true;
  });

  tearDown(() async {
    await database.close();
    await dir.delete(recursive: true);
  });

  Future<void> realWait(WidgetTester tester, [int rounds = 8]) async {
    for (var i = 0; i < rounds; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 40)),
      );
      await tester.pump();
    }
  }

  Future<void> open(
    WidgetTester tester, {
    List<AIChatMessage> agentTurns = const [],
    bool connected = false,
  }) async {
    final model = _ScriptedChatModel(agentTurns);
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: TrainNowScreen(
          today: () => _today,
          plannedItems: PlannedItemsRepository(
            events: EventsRepository(database: database),
            plans: plans,
            copyEvents: () async => true,
          ),
          planActions: PlanActions(
            workouts: workouts,
            plans: plans,
            events: EventsRepository(database: database),
            sendEnabled: () => send,
            connected: () => connected,
            resync: (_) async {},
          ),
          workoutWriter: workouts,
          syncService: SyncService(session: IntervalsSession.forTesting()),
          agentFactory: () => TrainingAgent(
            settings: LlmSettings.forTesting(),
            tools: TrainingDataTools(
              syncStateRepository: _EmptySyncState(),
              loadTrainingGuidance: () async => '# 1. Topic\n\nBody.\n',
              clock: () => _today,
            ),
            clock: () => _today,
            chatModelFactory: (_, _) => model,
          ),
        ),
      ),
    );
    await realWait(tester);
  }

  Finder mainButton() => find.byKey(const ValueKey('train-now-main'));
  String mainLabel(WidgetTester tester) =>
      (tester.widget<Text>(
        find.descendant(of: mainButton(), matching: find.byType(Text)),
      )).data!;
  Set<Object?> selected<T>(WidgetTester tester, int index) =>
      (tester.widgetList(find.byWidgetPredicate((w) => w is SegmentedButton))
                  .elementAt(index)
              as dynamic)
          .selected as Set<Object?>;

  testWidgets('nothing planned: no cards, Propose training', (tester) async {
    await open(tester);

    expect(find.text('Planned today'), findsNothing);
    expect(mainLabel(tester), 'Propose training');
  });

  testWidgets('a plan session today: card with details, Find alternative, '
      'presets', (tester) async {
    await tester.runAsync(
      () => plans.save(
        _plan([
          _session(
            id: 1,
            name: 'Tempo-threshold intervals',
            sport: 'Run',
            slot: SessionSlot.intervals,
            minutes: 62,
            load: 78,
          ),
        ]),
      ),
    );

    await open(tester);

    expect(find.text('Planned today'), findsOneWidget);
    expect(find.text('Tempo-threshold intervals'), findsOneWidget);
    expect(find.textContaining('62 min · 78 TSS'), findsOneWidget);
    expect(find.text('TriIQ plan'), findsOneWidget);
    expect(find.textContaining('8m 95% Pace'), findsOneWidget);
    expect(mainLabel(tester), 'Find alternative');
    // Sport Run, 60 min (62 rounded to the 15-min grid), Intervals.
    expect(selected(tester, 0).single, 'Run');
    expect(find.text('Duration — 60 min'), findsOneWidget);
    expect(selected(tester, 1).single.toString(), contains('intervals'));
  });

  testWidgets('two sessions: pick one, presets follow, later edits stick',
      (tester) async {
    await tester.runAsync(
      () => plans.save(
        _plan([
          _session(
            id: 1,
            name: 'Aerobic swim',
            sport: 'Swim',
            slot: SessionSlot.z2,
            minutes: 45,
            load: 30,
          ),
          _session(
            id: 2,
            name: 'Long endurance',
            sport: 'Ride',
            slot: SessionSlot.long,
            minutes: 150,
            load: 145,
          ),
        ]),
      ),
    );
    await open(tester);

    expect(find.byKey(const ValueKey('planned-today-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('planned-today-1')), findsOneWidget);
    expect(selected(tester, 0).single, 'Swim');

    await tester.tap(find.byKey(const ValueKey('planned-today-1')));
    await tester.pump();
    expect(selected(tester, 0).single, 'Ride');
    expect(find.text('Duration — 150 min'), findsOneWidget);

    await tester.tap(find.text('Run'));
    await tester.pump();
    PlanChanges.instance.notify();
    await realWait(tester, 4);
    expect(selected(tester, 0).single, 'Run', reason: 'a reload keeps edits');
  });

  testWidgets('replace a local plan session with the alternative',
      (tester) async {
    await tester.runAsync(
      () => plans.save(
        _plan([
          _session(
            id: 1,
            name: 'Long endurance',
            sport: 'Ride',
            slot: SessionSlot.long,
            minutes: 150,
            load: 145,
          ),
        ]),
      ),
    );
    await open(
      tester,
      agentTurns: [
        AIChatMessage.text(
          '| Duration | Session |\n|---|---|\n| Run — 45m | Easy |\n\n'
          'About 40 TSS.',
        ),
        AIChatMessage.text(
          '{"name": "Easy run", "sport": "Run", "duration_minutes": 45, '
          '"load": 40, "description": "- 45m 75% Pace"}',
        ),
      ],
    );

    await tester.tap(mainButton());
    await realWait(tester);
    await tester.tap(find.text('Create in Intervals.icu'));
    await realWait(tester);
    await tester.pumpAndSettle();

    expect(find.text('Replace today\'s session'), findsOneWidget);
    expect(find.text('Replaces “Long endurance”'), findsOneWidget);
    await tester.tap(find.text('Create'));
    await realWait(tester);
    await tester.pumpAndSettle();

    final plan = await tester.runAsync(plans.getCurrent);
    final session = plan!.sessions.single;
    expect(session.name, 'Easy run');
    expect(session.sport, 'Run');
    expect(session.minutes, 45);
    expect(session.date, _today);
    expect(workouts.created, isEmpty);
    expect(find.text("Today's plan session changed in TriIQ"), findsOneWidget);
  });

  final runTurns = [
    AIChatMessage.text('| Duration | Session |\n|---|---|\n| Run — 45m | Easy |'),
    AIChatMessage.text(
      '{"name": "Easy run", "sport": "Run", "duration_minutes": 45, '
      '"load": 40, "description": "- 45m 75% Pace"}',
    ),
  ];
  Future<void> savePlanSession() => plans.save(
    _plan([
      _session(
        id: 1,
        name: 'Long endurance',
        sport: 'Ride',
        slot: SessionSlot.long,
        minutes: 150,
        load: 145,
      ),
    ]),
  );
  Future<void> toPreview(WidgetTester tester) async {
    await tester.tap(mainButton());
    await realWait(tester);
    await tester.tap(find.text('Create in Intervals.icu'));
    await realWait(tester);
    await tester.pumpAndSettle();
  }

  testWidgets('offline: Add alongside is not offered, Replace is',
      (tester) async {
    await tester.runAsync(savePlanSession);
    await open(tester, agentTurns: runTurns);
    await toPreview(tester);

    final mode = tester.widget<SegmentedButton<Object?>>(
      find.byKey(const ValueKey('create-mode')),
    );
    expect(mode.segments.last.enabled, isFalse);
    expect(mode.segments.first.enabled, isTrue);
  });

  testWidgets('add alongside leaves the planned session untouched',
      (tester) async {
    IntervalsSession.instance.debugSetConnected(true);
    addTearDown(() => IntervalsSession.instance.debugSetConnected(false));
    await tester.runAsync(savePlanSession);
    await open(tester, agentTurns: runTurns, connected: true);
    await toPreview(tester);

    await tester.tap(find.text('Add alongside'));
    await tester.pump();
    await tester.tap(find.text('Create'));
    await realWait(tester);
    await tester.pumpAndSettle();

    expect(workouts.created.single.name, 'Easy run');
    final plan = await tester.runAsync(plans.getCurrent);
    expect(plan!.sessions.single.name, 'Long endurance');
  });

  testWidgets('a sent session with sending off: refused, says why',
      (tester) async {
    send = false;
    await tester.runAsync(
      () => plans.save(
        _plan([
          _session(
            id: 1,
            name: 'Long endurance',
            sport: 'Ride',
            slot: SessionSlot.long,
            minutes: 150,
            load: 145,
            eventId: '300',
          ),
        ]),
      ),
    );
    await open(
      tester,
      agentTurns: [
        AIChatMessage.text('| Duration | Session |\n|---|---|\n| x | y |'),
        AIChatMessage.text(
          '{"name": "Easy run", "sport": "Run", "duration_minutes": 45, '
          '"description": "- 45m 75% Pace"}',
        ),
      ],
    );

    await tester.tap(mainButton());
    await realWait(tester);
    // Not connected and the session is in Intervals.icu: nothing to create.
    final create = tester.widget<ButtonStyleButton>(
      find.ancestor(
        of: find.text('Create in Intervals.icu'),
        matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
      ),
    );
    expect(create.onPressed, isNull);
    expect((await tester.runAsync(plans.getCurrent))!.sessions.single.name,
        'Long endurance');
  });

  test('the alternative prompt carries the reference session first', () {
    final ref = PlannedItemsRepository.toLocalEvent(
      _session(
        id: 1,
        name: 'Long endurance',
        sport: 'Ride',
        slot: SessionSlot.long,
        minutes: 90,
        load: 85,
        description: 'x' * 3000,
      ),
    );

    final prompt = TrainNowScreen.buildPrompt(
      intensityWord: 'a steady endurance',
      sport: 'Run',
      minutes: 30,
      reference: ref,
    );

    expect(prompt, startsWith('Today I have this session planned: Ride'));
    expect(prompt, contains('"Long endurance", 90 min, about 85 TSS'));
    expect(prompt, contains('alternative'));
    expect(prompt, contains('must last about 30 minutes'));
    expect(prompt, contains('Propose a steady endurance Run session lasting '
        'about 30 minutes'));
    expect('x'.allMatches(prompt).length, lessThan(1600));

    final fresh = TrainNowScreen.buildPrompt(
      intensityWord: 'a steady endurance',
      sport: 'Run',
      minutes: 30,
    );
    expect(fresh, startsWith('Propose a steady endurance Run session'));
  });

  test('an Intervals.icu event as reference', () {
    final event = LocalEvent(
      id: '5',
      date: isoDate(_today),
      category: 'WORKOUT',
      type: 'Swim',
      name: 'Coach swim',
      description: null,
      plannedLoad: null,
      plannedTime: 2700,
      plannedDistance: null,
      indoor: false,
      raw: const {},
      syncedAt: _today,
    );
    final prompt = TrainNowScreen.buildPrompt(
      intensityWord: 'an easy recovery',
      sport: 'Swim',
      minutes: 45,
      reference: event,
    );
    expect(prompt, contains('"Coach swim", 45 min, about unknown TSS'));
    expect(TrainingKnowledge.defaults.goals, isNotEmpty);
  });
}

/// Replays [turns] in order — the agent's reply, then the structured draft.
class _ScriptedChatModel extends BaseChatModel<FakeChatModelOptions> {
  _ScriptedChatModel(this.turns)
    : super(defaultOptions: const FakeChatModelOptions());

  final List<AIChatMessage> turns;
  int _index = 0;

  @override
  String get modelType => 'scripted';

  @override
  Future<ChatResult> invoke(
    final PromptValue input, {
    final FakeChatModelOptions? options,
  }) async => ChatResult(
    id: 's$_index',
    output: turns[_index++],
    finishReason: FinishReason.stop,
    metadata: const {},
    usage: const LanguageModelUsage(),
  );

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
