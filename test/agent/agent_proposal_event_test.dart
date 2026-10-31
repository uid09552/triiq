import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:langchain_core/chat_models.dart';
import 'package:langchain_core/language_models.dart';
import 'package:langchain_core/prompts.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/agent/llm_settings.dart';
import 'package:triiq/agent/plan_proposals.dart';
import 'package:triiq/agent/tools/training_data_tools.dart';
import 'package:triiq/agent/training_agent.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/data/repositories/events_repository.dart';
import 'package:triiq/data/repositories/plans_repository.dart';
import 'package:triiq/data/repositories/sync_state_repository.dart';
import 'package:triiq/data/repositories/wellness_repository.dart';
import 'package:triiq/plan/knowledge.dart';
import 'package:triiq/plan/plan_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late AppDatabase database;
  late PlanProposals proposals;
  late _ScriptedChatModel model;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dir = await Directory.systemTemp.createTemp('triiq_agent_proposal');
    database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
    final plans = PlansRepository(database: database);
    proposals = PlanProposals(
      fingerprint: () => PlanProposals.defaultFingerprint(plans: plans),
    );
    await GoalStore().save(
      const Goal(
        targetType: 'long_distance',
        weekdays: {2, 4, 6},
        weeklyHours: 10,
        baselineWeeklyLoad: 300,
        weeks: 6,
      ),
    );
  });

  tearDown(() async {
    await database.close();
    await dir.delete(recursive: true);
  });

  TrainingAgent agent(List<AIChatMessage> turns) {
    model = _ScriptedChatModel(turns);
    final now = DateTime(2026, 10, 31, 9);
    return TrainingAgent(
      settings: LlmSettings.forTesting(),
      proposals: proposals,
      tools: TrainingDataTools(
        wellnessRepository: WellnessRepository(database: database),
        activitiesRepository: ActivitiesRepository(database: database),
        eventsRepository: EventsRepository(database: database),
        plansRepository: PlansRepository(database: database),
        syncStateRepository: SyncStateRepository(database: database),
        clock: () => now,
        loadTrainingGuidance: () async => '# Doc\n\ntext',
        knowledgeRepository: KnowledgeRepository(
          loadAsset: () async => File('docs/okf.md').readAsStringSync(),
        ),
        proposals: proposals,
      ),
      clock: () => now,
      chatModelFactory: (_, _) => model,
    );
  }

  test('a proposing tool makes the agent emit the proposal', () async {
    final a = agent([
      AIChatMessage.text(
        '',
        toolCalls: const [
          AIChatMessageToolCall(
            id: 'c1',
            name: 'propose_load_curve',
            argumentsRaw: '{"recovery_weeks":[4]}',
            arguments: {
              'recovery_weeks': [4],
            },
          ),
        ],
      ),
      AIChatMessage.text('I proposed making week 4 a recovery week.'),
    ]);

    final events = await a.send('Make week 4 a recovery week').toList();

    final proposal = events.whereType<AgentProposal>().single.proposal;
    expect(proposal, isA<CurveProposal>());
    expect(proposal.state, ProposalState.pending);
    // Emitted after the tool finished, before the closing text.
    final order = events.map((e) => e.runtimeType).toList();
    expect(
      order.indexOf(AgentProposal),
      greaterThan(order.indexOf(AgentToolFinished)),
    );
  });

  test('what the athlete did with it reaches the next turn', () async {
    final a = agent([
      AIChatMessage.text(
        '',
        toolCalls: const [
          AIChatMessageToolCall(
            id: 'c1',
            name: 'propose_load_curve',
            argumentsRaw: '{"recovery_weeks":[4]}',
            arguments: {
              'recovery_weeks': [4],
            },
          ),
        ],
      ),
      AIChatMessage.text('Proposed.'),
      AIChatMessage.text('Understood, keeping the curve as it was.'),
    ]);
    final first = await a.send('Make week 4 a recovery week').toList();
    final id = first.whereType<AgentProposal>().single.proposal.id;

    proposals.dismiss(id);
    await a.send('ok').toList();

    final lastHuman = model.prompts.last
        .whereType<HumanChatMessage>()
        .last
        .contentAsString;
    expect(lastHuman, contains('Proposal $id'));
    expect(lastHuman, contains('dismissed'));
    expect(lastHuman, endsWith('ok'));
    expect(proposals.takeOutcomes(), isEmpty, reason: 'reported once');
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
