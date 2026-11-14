import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langchain_core/chat_models.dart';
import 'package:langchain_core/language_models.dart';
import 'package:langchain_core/prompts.dart';
import 'package:openai_dart/openai_dart.dart' as openai;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/agent/llm_settings.dart';
import 'package:triiq/agent/openai_connection.dart' show LlmFailureKind;
import 'package:triiq/agent/tools/training_data_tools.dart';
import 'package:triiq/agent/training_agent.dart';
import 'package:triiq/data/repositories/sync_state_repository.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/chat/chat_screen.dart';
import 'package:triiq/screens/settings/llm_models_section.dart';

Widget _app(Widget body, {double textScale = 1}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: Scaffold(body: body),
);

LlmModelEntry _local(String id, {bool enabled = true}) => LlmModelEntry(
  id: id,
  name: id.toUpperCase(),
  provider: LlmProvider.ollama,
  model: 'model-$id',
  baseUrl: 'http://localhost:11434',
  enabled: enabled,
);

void main() {
  late LlmSettings settings;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settings = LlmSettings.forTesting();
    await settings.load();
    await settings.replaceEntries([_local('a'), _local('b'), _local('c')]);
  });

  Future<void> pumpSection(
    WidgetTester tester, {
    Size size = const Size(420, 2400),
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _app(
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: LlmModelsSection(settings: settings),
        ),
        textScale: textScale,
      ),
    );
    await tester.pumpAndSettle();
  }

  List<String> order() => settings.entries.map((e) => e.id).toList();

  testWidgets('lists the models in priority order with their status', (
    tester,
  ) async {
    await settings.setEntryEnabled('c', false);
    settings.health.recordFailure('b', LlmFailureKind.server);
    await pumpSection(tester);
    expect(find.text('1. A'), findsOneWidget);
    expect(find.text('2. B'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.textContaining('Last call failed'), findsOneWidget);
    expect(find.text('Off'), findsOneWidget);
  });

  testWidgets('Up / Down move an entry and the order persists', (tester) async {
    await pumpSection(tester);
    await tester.tap(find.byKey(const ValueKey('llm-model-down-a')));
    await tester.pumpAndSettle();
    expect(order(), ['b', 'a', 'c']);
    await tester.tap(find.byKey(const ValueKey('llm-model-up-c')));
    await tester.pumpAndSettle();
    expect(order(), ['b', 'c', 'a']);
    // The first cannot go up, the last cannot go down.
    expect(
      tester
          .widget<IconButton>(find.byKey(const ValueKey('llm-model-up-b')))
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<IconButton>(find.byKey(const ValueKey('llm-model-down-a')))
          .onPressed,
      isNull,
    );

    final reloaded = LlmSettings.forTesting();
    await tester.runAsync(reloaded.load);
    expect(reloaded.entries.map((e) => e.id), ['b', 'c', 'a']);
  });

  testWidgets('a screen reader can move an entry with custom actions', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpSection(tester);
    var node = tester.getSemantics(
      find.bySemanticsLabel(RegExp('^Model 2 of 3: B')),
    );
    // The row's move actions sit on its reorderable container.
    while ((node.getSemanticsData().customSemanticsActionIds ?? const [])
        .isEmpty) {
      node = node.parent!;
    }
    final ids = node.getSemanticsData().customSemanticsActionIds!;
    final labels = [
      for (final id in ids) CustomSemanticsAction.getAction(id)!.label,
    ];
    expect(labels, containsAll(['Move up', 'Move down']));

    final up = ids.firstWhere(
      (id) => CustomSemanticsAction.getAction(id)!.label == 'Move up',
    );
    node.owner!.performAction(node.id, SemanticsAction.customAction, up);
    await tester.pumpAndSettle();
    expect(order(), ['b', 'a', 'c']);
    handle.dispose();
  });

  testWidgets('drag the handle to reorder', (tester) async {
    await pumpSection(tester);
    final handle = find.byIcon(Icons.drag_indicator).first;
    final gesture = await tester.startGesture(tester.getCenter(handle));
    await tester.pump(const Duration(milliseconds: 100));
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(0, 40));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();
    expect(order().first, isNot('a'));
    expect(order(), containsAll(['a', 'b', 'c']));
  });

  testWidgets('the switch turns an entry off and on', (tester) async {
    await pumpSection(tester);
    await tester.tap(find.byKey(const ValueKey('llm-model-enabled-b')));
    await tester.pumpAndSettle();
    expect(settings.entryById('b')!.enabled, isFalse);
    expect(find.text('Off'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('llm-model-enabled-b')));
    await tester.pumpAndSettle();
    expect(settings.entryById('b')!.enabled, isTrue);
  });

  testWidgets('delete asks first', (tester) async {
    await pumpSection(tester);
    await tester.tap(find.byKey(const ValueKey('llm-model-delete-b')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Remove "B"'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(order(), ['a', 'b', 'c']);

    await tester.tap(find.byKey(const ValueKey('llm-model-delete-b')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('llm-model-delete-confirm')));
    await tester.pumpAndSettle();
    expect(order(), ['a', 'c']);
    expect(find.text('2. C'), findsOneWidget);
  });

  testWidgets('Add model: provider chips, fields, saved at the end', (
    tester,
  ) async {
    await pumpSection(tester);
    await tester.tap(find.byKey(const ValueKey('llm-add-model')));
    await tester.pumpAndSettle();
    expect(find.text('Add model'), findsWidgets);
    // Claude by default: its key field, not a server URL.
    expect(find.byKey(const ValueKey('claude-key')), findsOneWidget);
    expect(find.byKey(const ValueKey('openai-url')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('llm-provider-openai')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('model-name')),
      'LM Studio local',
    );
    await tester.enterText(
      find.byKey(const ValueKey('openai-url')),
      'http://localhost:1234/v1',
    );
    await tester.enterText(find.byKey(const ValueKey('openai-model')), 'qwen');
    await tester.pump();
    await tester.ensureVisible(find.byKey(const ValueKey('model-save')));
    await tester.tap(find.byKey(const ValueKey('model-save')));
    await tester.pumpAndSettle();

    final added = settings.entries.last;
    expect(settings.entries, hasLength(4));
    expect(added.label, 'LM Studio local');
    expect(added.provider, LlmProvider.openai);
    expect(added.baseUrl, 'http://localhost:1234/v1');
    expect(added.model, 'qwen');
    expect(find.text('4. LM Studio local'), findsOneWidget);
  });

  testWidgets('the editor refuses a public http:// URL', (tester) async {
    await pumpSection(tester);
    await tester.tap(find.byKey(const ValueKey('llm-add-model')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('llm-provider-openai')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('openai-url')),
      'http://api.example.com/v1',
    );
    await tester.pump();
    await tester.ensureVisible(find.byKey(const ValueKey('model-save')));
    await tester.tap(find.byKey(const ValueKey('model-save')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('model-save-error')), findsOneWidget);
    expect(settings.entries, hasLength(3));
  });

  testWidgets('usable at 360 dp with 2x text', (tester) async {
    await pumpSection(tester, size: const Size(360, 3000), textScale: 2);
    expect(tester.takeException(), isNull);
    expect(find.text('1. A'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('llm-add-model')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  group('chat', () {
    testWidgets('shows the switch note and which model answered', (
      tester,
    ) async {
      await tester.runAsync(
        () => settings.replaceEntries([
          const LlmModelEntry(
            id: 'claude',
            name: 'Claude Sonnet',
            provider: LlmProvider.claude,
            model: 'claude-sonnet-5',
          ),
          const LlmModelEntry(
            id: 'ollama',
            name: 'Ollama gpt-oss',
            provider: LlmProvider.ollama,
            model: 'gpt-oss:120b',
            baseUrl: 'http://localhost:11434',
          ),
        ]),
      );
      final models = {
        'claude': _FailingModel('Half a sent'),
        'ollama': _TextModel('All of the answer.'),
      };
      TrainingAgent agent() => TrainingAgent(
        settings: settings,
        tools: TrainingDataTools(
          syncStateRepository: _EmptySyncStateRepository(),
          clock: () => DateTime(2026, 8, 30),
        ),
        clock: () => DateTime(2026, 8, 30),
        chatModelFactory: (entry, _) => models[entry.id]!,
      );
      tester.view.physicalSize = const Size(420, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(ChatScreen(agentFactory: agent)));
      await tester.enterText(find.byKey(const ValueKey('chat-input')), 'Hi');
      await tester.tap(find.byKey(const ValueKey('chat-send')));
      for (var i = 0; i < 10; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump();
      }

      expect(find.byKey(const ValueKey('chat-model-switched')), findsOneWidget);
      expect(
        find.textContaining('Switched to Ollama gpt-oss — Claude Sonnet'),
        findsOneWidget,
      );
      expect(find.textContaining("Can't reach the AI server"), findsOneWidget);
      // The failed attempt's half sentence is gone, not duplicated.
      expect(find.textContaining('Half a sent'), findsNothing);
      expect(find.textContaining('All of the answer.'), findsOneWidget);
      expect(find.byKey(const ValueKey('chat-answered-by')), findsOneWidget);
      expect(
        find.bySemanticsLabel('Answered by Ollama gpt-oss'),
        findsOneWidget,
      );
      handle.dispose();
    });
  });
}

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

ChatResult _chunk(String text) => ChatResult(
  id: 'x',
  output: AIChatMessage.text(text),
  finishReason: FinishReason.unspecified,
  metadata: const {},
  usage: const LanguageModelUsage(),
  streaming: true,
);

abstract class _Model extends BaseChatModel<FakeChatModelOptions> {
  _Model() : super(defaultOptions: const FakeChatModelOptions());

  @override
  String get modelType => 'test';

  @override
  Future<ChatResult> invoke(
    PromptValue input, {
    FakeChatModelOptions? options,
  }) => throw UnimplementedError();

  @override
  Future<List<int>> tokenize(
    PromptValue promptValue, {
    FakeChatModelOptions? options,
  }) async => const [];
}

/// Streams [partial], then drops the connection.
class _FailingModel extends _Model {
  _FailingModel(this.partial);

  final String partial;

  @override
  Stream<ChatResult> stream(
    PromptValue input, {
    FakeChatModelOptions? options,
  }) async* {
    yield _chunk(partial);
    throw const openai.ConnectionException(message: 'connection reset');
  }
}

class _TextModel extends _Model {
  _TextModel(this.text);

  final String text;

  @override
  Stream<ChatResult> stream(
    PromptValue input, {
    FakeChatModelOptions? options,
  }) async* {
    yield _chunk(text);
  }
}
