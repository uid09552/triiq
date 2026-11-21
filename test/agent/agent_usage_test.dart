import 'package:flutter_test/flutter_test.dart';
import 'package:langchain_core/chat_models.dart';
import 'package:langchain_core/language_models.dart';
import 'package:langchain_core/prompts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/agent/llm_settings.dart';
import 'package:triiq/agent/tools/training_data_tools.dart';
import 'package:triiq/agent/training_agent.dart';
import 'package:triiq/data/repositories/sync_state_repository.dart';

/// A model that answers each call with the next list of streamed chunks.
class _Model extends BaseChatModel<FakeChatModelOptions> {
  _Model(this.calls) : super(defaultOptions: const FakeChatModelOptions());

  final List<List<ChatResult>> calls;
  var _next = 0;

  @override
  String get modelType => 'fake';

  @override
  Future<ChatResult> invoke(
    PromptValue input, {
    FakeChatModelOptions? options,
  }) => throw UnimplementedError();

  @override
  Stream<ChatResult> stream(
    PromptValue input, {
    FakeChatModelOptions? options,
  }) async* {
    for (final chunk in calls[_next++ % calls.length]) {
      yield chunk;
    }
  }

  @override
  Future<List<int>> tokenize(
    PromptValue promptValue, {
    FakeChatModelOptions? options,
  }) async => const [];
}

ChatResult _chunk(AIChatMessage m, {int? input, int? output}) => ChatResult(
  id: 'x',
  output: m,
  finishReason: FinishReason.unspecified,
  metadata: const {},
  usage: LanguageModelUsage(promptTokens: input, responseTokens: output),
  streaming: true,
);

class _NoSyncState implements SyncStateRepository {
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  TrainingAgent agent(_Model model) => TrainingAgent(
    settings: LlmSettings.forTesting(),
    tools: TrainingDataTools(
      syncStateRepository: _NoSyncState(),
      loadTrainingGuidance: () async => '# 1. Topic\n\nBody.\n',
      clock: () => DateTime(2026, 11, 20),
    ),
    clock: () => DateTime(2026, 11, 20),
    chatModelFactory: (_, _) => model,
  );

  test('a turn reports its tokens; tool rounds add up', () async {
    final model = _Model([
      [
        _chunk(
          AIChatMessage.text(
            '',
            toolCalls: const [
              AIChatMessageToolCall(
                id: 'c1',
                name: 'get_athlete_context',
                argumentsRaw: '{}',
                arguments: {},
              ),
            ],
          ),
          input: 100,
          output: 20,
        ),
      ],
      [_chunk(AIChatMessage.text('Done.'), input: 150, output: 30)],
    ]);
    final events = await agent(model).send('hi').toList();
    final usage = events.whereType<AgentUsage>().single.usage;
    expect(usage.inputTokens, 250);
    expect(usage.outputTokens, 50);
    expect(usage.local, isFalse);
  });

  test('cumulative counts inside one call are not added twice', () async {
    // Anthropic: input and a first output count at the start, the final
    // output count at the end.
    final model = _Model([
      [
        _chunk(AIChatMessage.text(''), input: 100, output: 1),
        _chunk(AIChatMessage.text('Hello'), output: null),
        _chunk(AIChatMessage.text(' there'), output: 18),
      ],
    ]);
    final events = await agent(model).send('hi').toList();
    final usage = events.whereType<AgentUsage>().single.usage;
    expect(usage.inputTokens, 100);
    expect(usage.outputTokens, 18);
  });

  test('a provider that reports no usage emits nothing', () async {
    final model = _Model([
      [_chunk(AIChatMessage.text('Hello'))],
    ]);
    final events = await agent(model).send('hi').toList();
    expect(events.whereType<AgentUsage>(), isEmpty);
  });
}
