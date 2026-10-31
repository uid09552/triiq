import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langchain_core/chat_models.dart';
import 'package:langchain_core/language_models.dart';
import 'package:langchain_core/prompts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/agent/chat_handoff.dart';
import 'package:triiq/agent/llm_settings.dart';
import 'package:triiq/agent/tools/training_data_tools.dart';
import 'package:triiq/agent/training_agent.dart';
import 'package:triiq/data/repositories/sync_state_repository.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/chat/chat_screen.dart';

void main() {
  test('an attached session goes to the system context, not the message',
      () async {
    final model = _ScriptedChatModel([AIChatMessage.text('It was cut short.')]);
    final agent = TrainingAgent(
      settings: LlmSettings.forTesting(),
      tools: TrainingDataTools(
        syncStateRepository: _EmptySyncState(),
        loadTrainingGuidance: () async => '# 1. Topic\n\nBody.\n',
        clock: () => DateTime(2026, 11, 3),
      ),
      clock: () => DateTime(2026, 11, 3),
      chatModelFactory: (_, _) => model,
    )..attachedContext = '{"verdict":"cutShort"}';

    await agent.send('Why?').toList();

    final prompt = model.prompts.single;
    final system = prompt.whereType<SystemChatMessage>().map((m) => m.content);
    expect(system.any((c) => c.contains('{"verdict":"cutShort"}')), isTrue);
    final human = prompt.whereType<HumanChatMessage>().single.contentAsString;
    expect(human, 'Why?');

    agent.reset();
    expect(agent.attachedContext, isNull);
  });

  testWidgets('Chat shows the topic as a chip, not a message', (tester) async {
    SharedPreferences.setMockInitialValues({});
    ChatHandoff.instance.open(
      const ChatTopic(title: 'Morning ride', context: '{"verdict":"cutShort"}'),
    );
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: Scaffold(body: ChatScreen()),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('chat-topic')), findsOneWidget);
    expect(find.text('About: Morning ride'), findsOneWidget);
    expect(find.textContaining('cutShort'), findsNothing);

    tester
        .widget<InputChip>(find.byKey(const ValueKey('chat-topic')))
        .onDeleted!();
    await tester.pump();
    expect(find.byKey(const ValueKey('chat-topic')), findsNothing);
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
