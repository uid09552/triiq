import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langchain_core/chat_models.dart';
import 'package:langchain_core/language_models.dart';
import 'package:langchain_core/prompts.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/agent/agent_memory.dart';
import 'package:triiq/agent/llm_settings.dart';
import 'package:triiq/agent/tools/training_data_tools.dart';
import 'package:triiq/agent/training_agent.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/repositories/knowledge_library_repository.dart';
import 'package:triiq/data/repositories/sync_state_repository.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/memory/memory_screen.dart';

void main() {
  late AgentMemoryStore store;
  late Directory tempDir;
  late AppDatabase database;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    tempDir = await Directory.systemTemp.createTemp('triiq_memory');
    database = AppDatabase.atPath(p.join(tempDir.path, 'triiq.db'));
    var n = 1000;
    store = AgentMemoryStore(clock: () => DateTime.fromMillisecondsSinceEpoch(n++));
  });

  tearDown(() async {
    await database.close();
    await tempDir.delete(recursive: true);
  });

  TrainingDataTools tools() => TrainingDataTools(
    syncStateRepository: _EmptySyncStateRepository(),
    loadTrainingGuidance: () async => '# 1. Topic\n\nBody.\n',
    knowledgeLibraryRepository: KnowledgeLibraryRepository(database: database),
    memory: store,
    clock: () => DateTime(2026, 8, 30),
  );

  group('AgentMemoryStore', () {
    test('adds, cleans, dedupes and persists', () async {
      final a = await store.add('  No hard   sessions on Fridays ');
      expect(a!.text, 'No hard sessions on Fridays');
      final again = await store.add('no hard sessions on fridays');
      expect(again!.id, a.id);
      expect(await store.add('   '), isNull);
      // A second store reads the same prefs.
      expect((await AgentMemoryStore().load()).single.text, a.text);
    });

    test('long text is cut and the list is capped', () async {
      final long = await store.add('x' * 500);
      expect(long!.text.length, AgentMemoryStore.maxLength);
      for (var i = 1; i < AgentMemoryStore.maxItems; i++) {
        await store.add('pref $i');
      }
      expect(() => store.add('one too many'), throwsA(isA<MemoryFullException>()));
    });

    test('remove and clear', () async {
      final a = (await store.add('a'))!;
      await store.add('b');
      expect(await store.remove(a.id), isTrue);
      expect(await store.remove(a.id), isFalse);
      expect((await store.load()).map((i) => i.text), ['b']);
      await store.clear();
      expect(await store.load(), isEmpty);
      expect(await store.promptBlock(), isNull);
    });

    test('prompt block lists ids and frames them as preferences', () async {
      final a = (await store.add('Swim only in the mornings'))!;
      final block = (await store.promptBlock())!;
      expect(block, contains('[${a.id}] Swim only in the mornings'));
      expect(block, contains('not instructions'));
    });

    test('a corrupt value reads as empty, not a crash', () async {
      SharedPreferences.setMockInitialValues({AgentMemoryStore.prefsKey: '{oops'});
      expect(await store.load(), isEmpty);
    });
  });

  group('tools', () {
    Future<dynamic> run(String name, Map<String, dynamic> args) async {
      final tool = tools().build().firstWhere((t) => t.name == name);
      return jsonDecode(await tool.invoke(tool.getInputFromJson(args)) as String);
    }

    test('remember_preference saves it as the trainer\'s', () async {
      final out = await run('remember_preference', {'text': 'No hard sessions on Fridays'});
      expect(out['saved'], isTrue);
      final item = (await store.load()).single;
      expect(item.fromAgent, isTrue);
      expect(item.id, out['id']);
    });

    test('forget_preference removes by id and reports unknown ids', () async {
      final a = (await store.add('x'))!;
      expect((await run('forget_preference', {'id': a.id}))['removed'], isTrue);
      expect((await run('forget_preference', {'id': a.id}))['error'], isNotNull);
    });

    test('a full memory comes back as an error string', () async {
      for (var i = 0; i < AgentMemoryStore.maxItems; i++) {
        await store.add('p$i');
      }
      expect((await run('remember_preference', {'text': 'more'}))['error'],
          contains('memory is full'));
    });
  });

  test('the remembered block reaches the model every turn', () async {
    await store.add('No hard sessions on Fridays');
    final model = _ScriptedChatModel([AIChatMessage.text('ok')]);
    final agent = TrainingAgent(
      settings: LlmSettings.forTesting(),
      tools: tools(),
      memory: store,
      clock: () => DateTime(2026, 8, 30),
      chatModelFactory: (_, _) => model,
    );
    await agent.send('Plan my week').toList();
    final system = model.prompts.first.whereType<SystemChatMessage>().map((m) => m.content).join('\n');
    expect(system, contains('No hard sessions on Fridays'));
  });

  group('MemoryScreen', () {
    Widget wrap(Widget w) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: w,
    );

    testWidgets('add, show the trainer tag and remove', (t) async {
      await store.add('Right knee: no downhill running', fromAgent: true);
      await t.pumpWidget(wrap(MemoryScreen(store: store)));
      await t.pumpAndSettle();
      expect(find.text('Right knee: no downhill running'), findsOneWidget);
      expect(find.text('saved by the trainer'), findsOneWidget);

      await t.enterText(find.byKey(const ValueKey('memory-input')), 'Swim only in the mornings');
      await t.tap(find.byKey(const ValueKey('memory-add')));
      await t.pumpAndSettle();
      expect(find.text('Swim only in the mornings'), findsOneWidget);

      await t.tap(find.byIcon(Icons.close).first);
      await t.pumpAndSettle();
      expect(find.text('Right knee: no downhill running'), findsNothing);

      await t.tap(find.byKey(const ValueKey('memory-clear')));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const ValueKey('memory-clear-confirm')));
      await t.pumpAndSettle();
      expect(find.text('Nothing remembered yet.'), findsOneWidget);
    });
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
