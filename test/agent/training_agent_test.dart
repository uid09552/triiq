import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:langchain_core/chat_models.dart';
import 'package:langchain_core/language_models.dart';
import 'package:langchain_core/prompts.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/agent/llm_settings.dart';
import 'package:triiq/agent/system_prompt.dart';
import 'package:triiq/agent/tools/training_data_tools.dart';
import 'package:triiq/agent/training_agent.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/repositories/knowledge_library_repository.dart';
import 'package:triiq/data/repositories/sync_state_repository.dart';

/// The tool-calling loop, driven by a scripted model so the assertions are
/// about *our* orchestration — the tool actually runs, its result is fed
/// back in the shape both providers expect, and the UI sees the right
/// events — rather than about Claude's or Ollama's behaviour.
void main() {
  late _ScriptedChatModel model;
  late TrainingAgent agent;
  late Directory tempDir;
  late AppDatabase database;

  // get_training_guidance now also reads the knowledge library (empty here,
  // same as "nothing imported"); give it a throwaway temp database rather
  // than the default AppDatabase.instance, which would otherwise touch a
  // real triiq.db in this process's working directory.
  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    tempDir = await Directory.systemTemp.createTemp('triiq_training_agent');
    database = AppDatabase.atPath(p.join(tempDir.path, 'triiq.db'));
  });

  tearDown(() async {
    await database.close();
    await tempDir.delete(recursive: true);
  });

  TrainingAgent buildAgent(List<AIChatMessage> turns) {
    model = _ScriptedChatModel(turns);
    return TrainingAgent(
      settings: LlmSettings.forTesting(),
      tools: TrainingDataTools(
        syncStateRepository: _EmptySyncStateRepository(),
        loadTrainingGuidance: () async => '# 1. Topic\n\nBody.\n',
        knowledgeLibraryRepository: KnowledgeLibraryRepository(
          database: database,
        ),
        clock: () => DateTime(2026, 8, 30),
      ),
      clock: () => DateTime(2026, 8, 30),
      chatModelFactory: (_, _) => model,
    );
  }

  test(
    'runs a requested tool and feeds the result back to the model',
    () async {
      agent = buildAgent([
        AIChatMessage.text(
          'Let me look that up.',
          toolCalls: const [
            AIChatMessageToolCall(
              id: 'call-1',
              name: 'get_training_guidance',
              argumentsRaw: '{"topic":"topic"}',
              arguments: {'topic': 'topic'},
            ),
          ],
        ),
        AIChatMessage.text('Here is the answer.'),
      ]);

      final events = await agent.send('What does my reference say?').toList();

      expect(
        events.whereType<AgentTextDelta>().map((e) => e.text).join(),
        'Let me look that up.Here is the answer.',
      );
      expect(
        events.whereType<AgentToolStarted>().single.name,
        'get_training_guidance',
      );
      expect(events.whereType<AgentToolFinished>().single.failed, isFalse);

      // Second turn: system prompt + context, then human, assistant, tool.
      final secondPrompt = model.prompts[1];
      expect(secondPrompt.whereType<SystemChatMessage>(), hasLength(2));
      final toolResult = secondPrompt.whereType<ToolChatMessage>().single;
      expect(toolResult.toolCallId, 'call-1');
      expect(toolResult.content, contains('Body.'));
    },
  );

  test(
    'a bad tool argument comes back as data the model can recover from',
    () async {
      agent = buildAgent([
        AIChatMessage.text(
          '',
          toolCalls: const [
            AIChatMessageToolCall(
              id: 'call-1',
              name: 'get_activities',
              argumentsRaw: '{"start_date":"whenever"}',
              arguments: {'start_date': 'whenever'},
            ),
          ],
        ),
        AIChatMessage.text('I need a proper date.'),
      ]);

      final events = await agent.send('Show me my rides').toList();

      expect(events.whereType<AgentToolFinished>().single.failed, isFalse);
      final toolResult = model.prompts[1]
          .whereType<ToolChatMessage>()
          .single
          .content;
      expect(toolResult, contains('YYYY-MM-DD'));
      expect(
        events.whereType<AgentTextDelta>().map((e) => e.text).join(),
        'I need a proper date.',
      );
    },
  );

  test('an unknown tool name is answered rather than thrown', () async {
    agent = buildAgent([
      AIChatMessage.text(
        '',
        toolCalls: const [
          AIChatMessageToolCall(
            id: 'call-1',
            name: 'get_power_curve',
            argumentsRaw: '{}',
            arguments: {},
          ),
        ],
      ),
      AIChatMessage.text('That is not something I can look up.'),
    ]);

    final events = await agent.send('Power curve?').toList();

    expect(events.whereType<AgentToolFinished>().single.failed, isTrue);
    expect(
      model.prompts[1].whereType<ToolChatMessage>().single.content,
      contains('no tool called'),
    );
  });

  test(
    'stops after maxIterations rather than looping on the same call',
    () async {
      final loopingTurn = AIChatMessage.text(
        '',
        toolCalls: const [
          AIChatMessageToolCall(
            id: 'call-1',
            name: 'get_athlete_context',
            argumentsRaw: '{}',
            arguments: {},
          ),
        ],
      );
      agent = buildAgent(
        List.filled(TrainingAgent.maxIterations + 2, loopingTurn),
      );

      final events = await agent.send('Loop forever').toList();

      expect(model.prompts, hasLength(TrainingAgent.maxIterations));
      expect(
        events.whereType<AgentTextDelta>().last.text,
        contains('ran out of steps'),
      );
    },
  );

  test('the runtime context tells the model today and the cache state', () {
    final context = buildRuntimeContext(
      now: DateTime(2026, 8, 30),
      intervalsConnected: false,
      athleteName: 'Alex',
      athleteId: 'i123',
      cachedRanges: const {'activities': '2026-01-01 to 2026-08-30'},
      provider: LlmProvider.ollama,
      model: 'llama3.2',
    );

    expect(context, contains('Today: 2026-08-30 (Sunday)'));
    expect(context, contains('Alex (id i123)'));
    expect(context, contains('not connected'));
    expect(context, contains('activities: 2026-01-01 to 2026-08-30'));
    // Local models get the extra hand-holding; Claude does not need it.
    expect(context, contains('local model'));
  });
}

/// A chat model that replays [turns] and records every prompt it was given.
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
      id: 'scripted-${prompts.length}',
      output: turns[_index++],
      finishReason: FinishReason.stop,
      metadata: const {},
      usage: const LanguageModelUsage(),
    );
  }

  /// Splits the turn into two chunks so the agent's streaming concat is
  /// exercised the way a real provider would exercise it.
  @override
  Stream<ChatResult> stream(
    final PromptValue input, {
    final FakeChatModelOptions? options,
  }) async* {
    prompts.add(input.toChatMessages());
    final turn = turns[_index++];
    for (final block in turn.content) {
      yield ChatResult(
        id: 'scripted-${prompts.length}',
        output: AIChatMessage(content: [block]),
        finishReason: FinishReason.unspecified,
        metadata: const {},
        usage: const LanguageModelUsage(),
        streaming: true,
      );
    }
  }

  @override
  Future<List<int>> tokenize(
    final PromptValue promptValue, {
    final FakeChatModelOptions? options,
  }) async => const [];
}

/// Stands in for the sync-state table so the agent's context block can be
/// built without a database.
class _EmptySyncStateRepository implements SyncStateRepository {
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
