import 'dart:async';
import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart' as anthropic;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:langchain_core/chat_models.dart';
import 'package:langchain_core/language_models.dart';
import 'package:langchain_core/prompts.dart';
import 'package:ollama_dart/ollama_dart.dart' as ollama;
import 'package:openai_dart/openai_dart.dart' as openai;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/agent/chat_model_factory.dart';
import 'package:triiq/agent/failover_policy.dart';
import 'package:triiq/agent/llm_gateway.dart';
import 'package:triiq/agent/llm_settings.dart';
import 'package:triiq/agent/model_health.dart';
import 'package:triiq/agent/openai_connection.dart';
import 'package:triiq/agent/tools/training_data_tools.dart';
import 'package:triiq/agent/training_agent.dart';
import 'package:triiq/data/privacy_settings.dart';
import 'package:triiq/data/repositories/sync_state_repository.dart';
import 'package:triiq/l10n/app_localizations_en.dart';
import 'package:triiq/widgets/status_message.dart';

/// Answers each call with the next scripted outcome: a list of text chunks
/// (optionally followed by an error mid-stream), or an error at once.
class FakeModel extends BaseChatModel<FakeChatModelOptions> {
  FakeModel(this.script) : super(defaultOptions: const FakeChatModelOptions());

  final List<Object> script;
  final prompts = <List<ChatMessage>>[];
  int calls = 0;

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
    prompts.add(input.toChatMessages());
    final step = script[calls++ % script.length];
    if (step is _Partial) {
      for (final t in step.chunks) {
        yield _chunk(AIChatMessage.text(t));
      }
      throw step.error;
    }
    if (step is AIChatMessage) {
      yield _chunk(step);
      return;
    }
    if (step is String) {
      yield _chunk(AIChatMessage.text(step));
      return;
    }
    if (step is _Hang) {
      await Completer<void>().future;
    }
    throw step;
  }

  static ChatResult _chunk(AIChatMessage m) => ChatResult(
    id: 'fake',
    output: m,
    finishReason: FinishReason.unspecified,
    metadata: const {},
    usage: const LanguageModelUsage(),
    streaming: true,
  );

  @override
  Future<List<int>> tokenize(
    PromptValue promptValue, {
    FakeChatModelOptions? options,
  }) async => const [];
}

class _Partial {
  const _Partial(this.chunks, this.error);
  final List<String> chunks;
  final Object error;
}

class _Hang {
  const _Hang();
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

const _unreachable = openai.ConnectionException(message: 'refused');
const _overloaded = anthropic.ApiException(
  statusCode: 529,
  message: 'Overloaded',
);

LlmModelEntry _entry(
  String id, {
  LlmProvider provider = LlmProvider.ollama,
  bool enabled = true,
}) => LlmModelEntry(
  id: id,
  name: id,
  provider: provider,
  model: 'm-$id',
  baseUrl: provider == LlmProvider.ollama ? 'http://localhost:11434' : '',
  enabled: enabled,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('classifyLlmError + FailoverPolicy', () {
    const policy = FailoverPolicy();
    FailoverDecision decide(Object e) => policy.decide(classifyLlmError(e));

    final failsOver = <String, Object>{
      'openai connection': _unreachable,
      'openai timeout': const openai.RequestTimeoutException(message: 't'),
      'openai 429': const openai.RateLimitException(message: 'slow'),
      'openai 502': const openai.InternalServerException(
        message: 'x',
        statusCode: 502,
      ),
      'anthropic 529 overloaded': _overloaded,
      'anthropic 500': const anthropic.ApiException(
        statusCode: 500,
        message: 'x',
      ),
      'ollama 503': const ollama.ApiException(statusCode: 503, message: 'x'),
      'ollama 429': const ollama.ApiException(statusCode: 429, message: 'x'),
      '408': const ollama.ApiException(statusCode: 408, message: 'x'),
      'socket (DNS / unreachable)': const SocketException('Failed host lookup'),
      'http client': http.ClientException('Connection closed'),
      'our per-attempt timeout': TimeoutException('no chunk'),
    };
    final needsAttention = <String, Object>{
      'openai 401': const openai.AuthenticationException(message: 'bad key'),
      'anthropic 403': const anthropic.ApiException(
        statusCode: 403,
        message: 'forbidden',
      ),
      'ollama 404 model': const ollama.ApiException(
        statusCode: 404,
        message: "model 'x' not found",
      ),
      'tools rejected': const ollama.ApiException(
        statusCode: 400,
        message: 'x does not support tools',
      ),
      'entry not configured': const LlmNotConfiguredException('no key'),
    };
    final surfaces = <String, Object>{
      'context length': const openai.BadRequestException(
        message: "This model's maximum context length is 8192 tokens",
      ),
      'anthropic prompt too long': const anthropic.ApiException(
        statusCode: 400,
        message: 'prompt is too long: 210000 tokens',
      ),
      '413': const anthropic.ApiException(statusCode: 413, message: 'big'),
      'content policy': const openai.BadRequestException(
        message: 'flagged by our content_filter',
      ),
      'other 400': const openai.BadRequestException(message: 'bad json'),
      'cancelled': const openai.AbortedException(message: 'cancelled'),
      'our own bug': StateError('x'),
      'type error': ArgumentError('x'),
    };

    for (final e in failsOver.entries) {
      test('fails over: ${e.key}', () {
        final d = decide(e.value);
        expect(d.failover, isTrue);
        expect(d.needsAttention, isFalse);
      });
    }
    for (final e in needsAttention.entries) {
      test('fails over and flags the entry: ${e.key}', () {
        final d = decide(e.value);
        expect(d.failover, isTrue);
        expect(d.needsAttention, isTrue);
      });
    }
    for (final e in surfaces.entries) {
      test('surfaces, no failover: ${e.key}', () {
        expect(decide(e.value).failover, isFalse);
      });
    }

    test('kinds are named for the policy', () {
      expect(
        classifyLlmError(failsOver['anthropic 529 overloaded']!),
        LlmFailureKind.server,
      );
      expect(
        classifyLlmError(surfaces['context length']!),
        LlmFailureKind.contextTooLong,
      );
      expect(
        classifyLlmError(surfaces['content policy']!),
        LlmFailureKind.refused,
      );
    });
  });

  group('ModelHealth circuit breaker', () {
    test('cools an entry down after N consecutive failures', () {
      var now = DateTime(2026, 11, 14, 10);
      final health = ModelHealth(clock: () => now);
      health.recordFailure('a', LlmFailureKind.unreachable);
      expect(health.isCoolingDown('a'), isFalse);
      health.recordFailure('a', LlmFailureKind.unreachable);
      expect(health.isCoolingDown('a'), isTrue);
      expect(health.statusOf('a').coolingUntil, DateTime(2026, 11, 14, 10, 5));

      now = now.add(const Duration(minutes: 4, seconds: 59));
      expect(health.isCoolingDown('a'), isTrue);
      now = now.add(const Duration(seconds: 2));
      expect(health.isCoolingDown('a'), isFalse);
      // After the cooldown, one failure is not enough again.
      health.recordFailure('a', LlmFailureKind.unreachable);
      expect(health.isCoolingDown('a'), isFalse);
    });

    test('a success resets the count; a Test clears the cooldown', () {
      final health = ModelHealth(clock: () => DateTime(2026));
      health.recordFailure('a', LlmFailureKind.server);
      health.recordSuccess('a');
      health.recordFailure('a', LlmFailureKind.server);
      expect(health.isCoolingDown('a'), isFalse);
      health.recordFailure('a', LlmFailureKind.server);
      expect(health.isCoolingDown('a'), isTrue);
      health.clear('a');
      expect(health.isCoolingDown('a'), isFalse);
      expect(health.statusOf('a').isOk, isTrue);
    });
  });

  group('LlmGateway', () {
    late LlmSettings settings;
    late Map<String, FakeModel> models;
    late DateTime now;

    Future<void> setUpEntries(
      List<LlmModelEntry> entries,
      Map<String, List<Object>> scripts,
    ) async {
      now = DateTime(2026, 11, 14, 10);
      settings = LlmSettings.forTesting(clock: () => now);
      await settings.load();
      await settings.replaceEntries(entries);
      models = {for (final e in scripts.entries) e.key: FakeModel(e.value)};
    }

    LlmGateway gateway({Duration? firstChunk}) => LlmGateway(
      settings: settings,
      buildModel: (entry, _) => models[entry.id]!,
      firstChunkTimeout: firstChunk ?? const Duration(seconds: 90),
    );

    test('uses the first entry and stops at the first success', () async {
      await setUpEntries(
        [_entry('a'), _entry('b')],
        {
          'a': ['from a'],
          'b': ['from b'],
        },
      );
      final reply = await gateway().invoke([ChatMessage.humanText('hi')]);
      expect(reply.entry.id, 'a');
      expect(reply.message.contentAsString, 'from a');
      expect(models['b']!.calls, 0);
      expect(settings.health.statusOf('a').lastUsed, now);
    });

    test('tries entries in order until one answers', () async {
      await setUpEntries(
        [_entry('a'), _entry('b'), _entry('c')],
        {
          'a': [_unreachable],
          'b': [_overloaded],
          'c': ['from c'],
        },
      );
      final events = await gateway()
          .stream((_) => [ChatMessage.humanText('hi')])
          .toList();
      expect(events.whereType<LlmAttemptStarted>().map((e) => e.entry.id), [
        'a',
        'b',
        'c',
      ]);
      final switches = events.whereType<LlmFailedOver>().toList();
      expect(switches.map((e) => '${e.from.id}>${e.to.id}'), ['a>b', 'b>c']);
      expect(switches.first.kind, LlmFailureKind.unreachable);
      expect(models.values.map((m) => m.calls), [1, 1, 1]);
    });

    test('disabled entries are skipped', () async {
      await setUpEntries(
        [_entry('a', enabled: false), _entry('b')],
        {
          'a': ['from a'],
          'b': ['from b'],
        },
      );
      final reply = await gateway().invoke([ChatMessage.humanText('hi')]);
      expect(reply.entry.id, 'b');
      expect(models['a']!.calls, 0);
    });

    test('a non-failover error surfaces at once', () async {
      const tooLong = openai.BadRequestException(
        message: 'maximum context length exceeded',
      );
      await setUpEntries(
        [_entry('a'), _entry('b')],
        {
          'a': [tooLong],
          'b': ['from b'],
        },
      );
      await expectLater(
        gateway().invoke([ChatMessage.humanText('hi')]),
        throwsA(same(tooLong)),
      );
      expect(models['b']!.calls, 0);
    });

    test('with one model its own error surfaces, unchanged', () async {
      await setUpEntries(
        [_entry('a')],
        {
          'a': [_unreachable],
        },
      );
      await expectLater(
        gateway().invoke([ChatMessage.humanText('hi')]),
        throwsA(same(_unreachable)),
      );
    });

    test('all failing: one combined error naming each entry', () async {
      await setUpEntries(
        [_entry('a'), _entry('b', provider: LlmProvider.claude)],
        {
          'a': [_unreachable],
        },
      );
      // b is a Claude entry without a key: the real factory refuses it.
      final gw = LlmGateway(
        settings: settings,
        buildModel: (entry, tools) => entry.id == 'a'
            ? models['a']!
            : createChatModelFor(entry, apiKey: settings.keyFor(entry)),
      );
      Object? error;
      try {
        await gw.invoke([ChatMessage.humanText('hi')]);
      } catch (e) {
        error = e;
      }
      expect(error, isA<AllModelsFailedException>());
      final failures = (error! as AllModelsFailedException).failures;
      expect(failures.map((f) => f.entry.id), ['a', 'b']);
      expect(failures.map((f) => f.kind), [
        LlmFailureKind.unreachable,
        LlmFailureKind.notConfigured,
      ]);
      expect(settings.health.statusOf('b').needsAttention, isTrue);

      final text = describeAgentError(error, AppLocalizationsEn());
      expect(text, startsWith('No model answered.'));
      expect(text, contains('a: Can\'t reach the AI server'));
      expect(text, contains('b: The model is not fully set up'));
    });

    test('a dead entry cools down and goes to the back of the line', () async {
      await setUpEntries(
        [_entry('a'), _entry('b')],
        {
          'a': [_unreachable],
          'b': ['from b'],
        },
      );
      final gw = gateway();
      await gw.invoke([ChatMessage.humanText('1')]);
      await gw.invoke([ChatMessage.humanText('2')]);
      expect(models['a']!.calls, 2);
      expect(settings.health.isCoolingDown('a'), isTrue);

      // Now b is asked first, a not at all.
      final reply = await gw.invoke([ChatMessage.humanText('3')]);
      expect(reply.entry.id, 'b');
      expect(models['a']!.calls, 2);
      expect(gw.candidates().map((e) => e.id), ['b', 'a']);

      // After the cooldown a is first again.
      now = now.add(const Duration(minutes: 6));
      expect(gw.candidates().map((e) => e.id), ['a', 'b']);
    });

    test('a server that never answers costs one bounded wait', () async {
      await setUpEntries(
        [_entry('a'), _entry('b')],
        {
          'a': [const _Hang()],
          'b': ['from b'],
        },
      );
      final reply = await gateway(
        firstChunk: const Duration(milliseconds: 50),
      ).invoke([ChatMessage.humanText('hi')]);
      expect(reply.entry.id, 'b');
      expect(
        settings.health.statusOf('a').lastFailure,
        LlmFailureKind.unreachable,
      );
    });

    test('an entry without consent is skipped, nothing is sent', () async {
      final privacy = PrivacySettings.forTesting();
      await privacy.setAiConsent(true, hosts: [LlmModelEntry.claudeHost]);
      settings = LlmSettings.forTesting(requireConsent: true, privacy: privacy);
      await settings.load();
      await settings.replaceEntries([
        const LlmModelEntry(
          id: 'cloud',
          provider: LlmProvider.openai,
          model: 'gpt',
          baseUrl: 'https://llm.example.com/v1',
        ),
        _entry('local'),
      ]);
      models = {
        'cloud': FakeModel(['from cloud']),
        'local': FakeModel(['from local']),
      };
      final reply = await gateway().invoke([ChatMessage.humanText('hi')]);
      expect(reply.entry.id, 'local');
      expect(models['cloud']!.calls, 0);
      expect(settings.isConfigured, isTrue);
      expect(settings.needsConsent, isTrue);
      expect(settings.blockedByConsent, isFalse);
    });
  });

  group('TrainingAgent failover', () {
    late LlmSettings settings;

    TrainingAgent agentWith(Map<String, FakeModel> models) => TrainingAgent(
      settings: settings,
      tools: TrainingDataTools(
        syncStateRepository: _EmptySyncStateRepository(),
        loadTrainingGuidance: () async => '# 1. Topic\n\nBody.\n',
        clock: () => DateTime(2026, 8, 30),
      ),
      clock: () => DateTime(2026, 8, 30),
      chatModelFactory: (entry, _) => models[entry.id]!,
    );

    setUp(() async {
      settings = LlmSettings.forTesting();
      await settings.load();
      await settings.replaceEntries([
        _entry('a'),
        const LlmModelEntry(
          id: 'b',
          name: 'LM Studio',
          provider: LlmProvider.openai,
          model: 'qwen',
          baseUrl: 'http://localhost:1234/v1',
        ),
      ]);
    });

    test(
      'a failure mid-stream discards the partial text and switches',
      () async {
        final a = FakeModel([
          const _Partial(['Your CTL is'], _unreachable),
        ]);
        final b = FakeModel(['Your CTL is 62.']);
        final agent = agentWith({'a': a, 'b': b});

        final events = await agent.send('How fit am I?').toList();

        final switched = events.whereType<AgentModelSwitched>().single;
        expect(switched.from.id, 'a');
        expect(switched.to.id, 'b');
        expect(switched.reason, LlmFailureKind.unreachable);
        expect(switched.discardedText, isTrue);

        final buffer = AgentReplyBuffer();
        events.forEach(buffer.apply);
        expect(buffer.text, 'Your CTL is 62.');
        expect(buffer.answeredBy?.id, 'b');

        // The same history went to b, and only b's answer was kept.
        expect(
          b.prompts.single.whereType<HumanChatMessage>().single.contentAsString,
          a.prompts.single.whereType<HumanChatMessage>().single.contentAsString,
        );
        final ai = agent.history.whereType<AIChatMessage>().toList();
        expect(ai.single.contentAsString, 'Your CTL is 62.');
        // The runtime context names the model that is actually asked.
        expect(
          b.prompts.single.whereType<SystemChatMessage>().elementAt(1).content,
          contains('openai / qwen'),
        );
      },
    );

    test(
      'mid-turn: after a tool round, a failed entry is not asked again',
      () async {
        final a = FakeModel([
          AIChatMessage.text(
            '',
            toolCalls: const [
              AIChatMessageToolCall(
                id: 'call-1',
                name: 'get_training_guidance',
                argumentsRaw: '{"topic":"topic"}',
                arguments: {'topic': 'topic'},
              ),
            ],
          ),
          _unreachable,
        ]);
        final b = FakeModel(['Here it is.']);
        final agent = agentWith({'a': a, 'b': b});

        final events = await agent.send('What does my reference say?').toList();
        expect(events.whereType<AgentToolFinished>().single.failed, isFalse);
        expect(events.whereType<AgentModelSwitched>(), hasLength(1));
        // b got the tool result a asked for.
        expect(b.prompts.single.whereType<ToolChatMessage>(), hasLength(1));
        expect(a.calls, 2);
        expect(b.calls, 1);
      },
    );
  });
}
