import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langchain_anthropic/langchain_anthropic.dart';
import 'package:langchain_core/tools.dart';
import 'package:langchain_ollama/langchain_ollama.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:openai_dart/openai_dart.dart'
    show
        AuthenticationException,
        BadRequestException,
        ConnectionException,
        InternalServerException,
        NotFoundException,
        RateLimitException;
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/agent/chat_model_factory.dart';
import 'package:triiq/agent/llm_settings.dart';
import 'package:triiq/agent/openai_connection.dart';
import 'package:triiq/agent/system_prompt.dart';
import 'package:triiq/data/backup/backup_service.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/privacy_settings.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/l10n/app_localizations_en.dart';
import 'package:triiq/screens/settings/ai_consent.dart';
import 'package:triiq/screens/settings/settings_screen.dart';
import 'package:triiq/widgets/status_message.dart';

/// Answers every request with a canned response and records what was asked.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.respond);

  final ResponseBody Function(RequestOptions options) respond;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object body, [int status = 200]) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

Dio _dio(_FakeAdapter adapter) => Dio()..httpClientAdapter = adapter;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, String> vault;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    vault = {};
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (call) async {
            final args = (call.arguments as Map).cast<String, dynamic>();
            return switch (call.method) {
              'read' => vault[args['key'] as String],
              'write' => vault[args['key'] as String] = args['value'] as String,
              'delete' => vault.remove(args['key'] as String),
              _ => null,
            };
          },
        );
  });

  group('settings', () {
    test(
      'existing users keep their provider; the new fields have defaults',
      () async {
        final settings = LlmSettings.forTesting();
        await settings.load();

        expect(settings.provider, LlmProvider.claude);
        expect(settings.openAiBaseUrl, 'https://api.openai.com/v1');
        expect(settings.openAiModel, LlmSettings.defaultOpenAiModel);
        expect(settings.hasOpenAiApiKey, isFalse);
      },
    );

    test(
      'URL, model and provider persist; the key goes to the vault only',
      () async {
        final settings = LlmSettings.forTesting();
        await settings.load();
        await settings.setProvider(LlmProvider.openai);
        await settings.setOpenAiBaseUrl('http://192.168.1.20:1234/v1');
        await settings.setOpenAiModel('qwen2.5-14b-instruct');
        await settings.setOpenAiApiKey('sk-openai-secret');

        final prefs = await SharedPreferences.getInstance();
        // One entry in the model list carries provider, URL and model.
        expect(prefs.getKeys(), contains(LlmSettings.modelsPref));
        final stored = LlmModelEntry.decodeList(
          prefs.getString(LlmSettings.modelsPref)!,
        );
        expect(stored.single.provider, LlmProvider.openai);
        expect(stored.single.baseUrl, 'http://192.168.1.20:1234/v1');
        expect(stored.single.model, 'qwen2.5-14b-instruct');
        // The secret is nowhere in plain preferences, under any key.
        for (final key in prefs.getKeys()) {
          expect('${prefs.get(key)}', isNot(contains('sk-openai-secret')));
        }
        expect(vault['openai_api_key'], 'sk-openai-secret');

        final reloaded = LlmSettings.forTesting();
        await reloaded.load();
        expect(reloaded.provider, LlmProvider.openai);
        expect(reloaded.openAiBaseUrl, 'http://192.168.1.20:1234/v1');
        expect(reloaded.openAiModel, 'qwen2.5-14b-instruct');
        expect(reloaded.openAiApiKey, 'sk-openai-secret');
        expect(reloaded.activeModel, 'qwen2.5-14b-instruct');

        await reloaded.setOpenAiApiKey('');
        expect(vault, isEmpty);
        expect(reloaded.hasOpenAiApiKey, isFalse);
      },
    );

    test(
      'a key is optional; the URL must pass the https-or-local rule',
      () async {
        final settings = LlmSettings.forTesting();
        await settings.load();
        await settings.setProvider(LlmProvider.openai);
        expect(settings.isConfigured, isTrue); // default URL + model, no key

        await settings.setOpenAiBaseUrl('http://api.example.com/v1');
        expect(settings.isConfigured, isFalse);

        await settings.setOpenAiBaseUrl('http://localhost:1234/v1');
        expect(settings.isConfigured, isTrue);
        expect(settings.isOpenAiLocal, isTrue);
      },
    );

    test('resetInMemory returns to the defaults without keys', () async {
      final settings = LlmSettings.forTesting();
      await settings.load();
      await settings.setOpenAiModel('x');
      await settings.setOpenAiApiKey('k');
      settings.resetInMemory();
      expect(settings.openAiModel, LlmSettings.defaultOpenAiModel);
      expect(settings.openAiApiKey, isNull);
    });
  });

  group('createChatModel builds the right model per provider', () {
    final tool = ToolSpec(
      name: 'ping',
      description: 'ping',
      inputJsonSchema: const {'type': 'object', 'properties': {}},
    );

    test('Claude, Ollama and OpenAI-compatible, without any network', () async {
      final settings = LlmSettings.forTesting();
      await settings.load();

      await settings.setClaudeApiKey('sk-ant-test');
      expect(createChatModel(settings), isA<ChatAnthropic>());

      await settings.setProvider(LlmProvider.ollama);
      await settings.setOllamaBaseUrl('http://localhost:11434');
      expect(createChatModel(settings), isA<ChatOllama>());

      await settings.setProvider(LlmProvider.openai);
      final model = createChatModel(settings, tools: [tool]);
      expect(model, isA<ChatOpenAI>());
      final options = (model as ChatOpenAI).defaultOptions;
      expect(options.model, LlmSettings.defaultOpenAiModel);
      expect(options.temperature, 0.2);
      expect(options.tools, hasLength(1));
    });

    test('works without a key for a local server', () async {
      final settings = LlmSettings.forTesting();
      await settings.load();
      await settings.setProvider(LlmProvider.openai);
      await settings.setOpenAiBaseUrl('http://localhost:1234/v1/');
      await settings.setOpenAiModel('llama-3.1-8b');
      expect(createChatModel(settings), isA<ChatOpenAI>());
    });

    test('refuses plain http to a public host', () async {
      final settings = LlmSettings.forTesting();
      await settings.load();
      await settings.setProvider(LlmProvider.openai);
      await settings.setOpenAiBaseUrl('http://api.example.com/v1');
      expect(
        () => createChatModel(settings),
        throwsA(
          isA<LlmNotConfiguredException>().having(
            (e) => e.message,
            'message',
            contains('api.example.com'),
          ),
        ),
      );
    });

    test('leaves temperature unset for reasoning models', () async {
      final settings = LlmSettings.forTesting();
      await settings.load();
      await settings.setProvider(LlmProvider.openai);
      for (final name in ['o3-mini', 'gpt-5', 'openai/gpt-5-mini']) {
        await settings.setOpenAiModel(name);
        final options =
            (createChatModel(settings) as ChatOpenAI).defaultOptions;
        expect(options.temperature, isNull, reason: name);
      }
      await settings.setOpenAiModel('gpt-4o');
      expect(
        (createChatModel(settings) as ChatOpenAI).defaultOptions.temperature,
        0.2,
      );
    });
  });

  group('base URL validation', () {
    test('https is fine for any host', () {
      for (final url in [
        'https://api.openai.com/v1',
        'https://openrouter.ai/api/v1',
        'https://8.8.8.8/v1',
        'https://localhost:1234/v1',
      ]) {
        expect(checkOpenAiBaseUrl(url), isNull, reason: url);
      }
    });

    test('http is fine for localhost, LAN and private addresses', () {
      for (final url in [
        'http://localhost:1234/v1',
        'http://127.0.0.1:8000/v1',
        'http://[::1]:8000/v1',
        'http://192.168.1.5:8080/v1',
        'http://10.0.0.7/v1',
        'http://172.16.0.1/v1',
        'http://172.31.255.254/v1',
        'http://nas.local:1234/v1',
        'http://mybox:1234/v1',
      ]) {
        expect(checkOpenAiBaseUrl(url), isNull, reason: url);
        expect(isLocalServerUrl(url), isTrue, reason: url);
      }
    });

    test('http to a public host is rejected', () {
      for (final url in [
        'http://api.openai.com/v1',
        'http://8.8.8.8/v1',
        'http://172.15.0.1/v1',
        'http://172.32.0.1/v1',
        'http://192.169.1.1/v1',
        'http://11.0.0.1/v1',
        'http://localhost.evil.example/v1',
      ]) {
        expect(
          checkOpenAiBaseUrl(url),
          OpenAiUrlProblem.httpPublicHost,
          reason: url,
        );
      }
    });

    test('other malformed input is named', () {
      expect(checkOpenAiBaseUrl(''), OpenAiUrlProblem.empty);
      expect(checkOpenAiBaseUrl('   '), OpenAiUrlProblem.empty);
      expect(checkOpenAiBaseUrl('localhost:1234/v1'), OpenAiUrlProblem.invalid);
      expect(checkOpenAiBaseUrl('not a url'), OpenAiUrlProblem.invalid);
      expect(checkOpenAiBaseUrl('ftp://host/v1'), OpenAiUrlProblem.badScheme);
      expect(
        checkOpenAiBaseUrl('https://me:pw@host/v1'),
        OpenAiUrlProblem.credentialsInUrl,
      );
    });

    test('public addresses count as a third party', () {
      expect(isLocalServerUrl('https://api.openai.com/v1'), isFalse);
      expect(isLocalServerUrl('https://8.8.8.8/v1'), isFalse);
    });
  });

  group('model list', () {
    test('parses the OpenAI /models shape, sorted and de-duplicated', () {
      expect(
        parseOpenAiModelList({
          'object': 'list',
          'data': [
            {'id': 'gpt-4o', 'object': 'model'},
            {'id': 'gpt-4o-mini'},
            {'id': 'gpt-4o'},
            {'object': 'model'},
          ],
        }),
        ['gpt-4o', 'gpt-4o-mini'],
      );
    });

    test('tolerates other servers and an empty list', () {
      expect(
        parseOpenAiModelList({
          'models': [
            {'name': 'b'},
            'a',
          ],
        }),
        ['a', 'b'],
      );
      expect(parseOpenAiModelList({'data': []}), isEmpty);
      expect(parseOpenAiModelList('{"data":[{"id":"x"}]}'), ['x']);
    });

    test('a body that is not a model list is an invalid response', () {
      expect(
        () => parseOpenAiModelList('<html>nope</html>'),
        throwsA(
          isA<OpenAiConnectionException>().having(
            (e) => e.kind,
            'kind',
            LlmFailureKind.invalidResponse,
          ),
        ),
      );
    });

    test('GETs {base}/models with the key as a Bearer token', () async {
      final adapter = _FakeAdapter(
        (_) => _json({
          'data': [
            {'id': 'm2'},
            {'id': 'm1'},
          ],
        }),
      );
      final models = await fetchOpenAiModels(
        baseUrl: 'https://llm.example.com/v1/',
        apiKey: ' sk-test ',
        dio: _dio(adapter),
      );
      expect(models, ['m1', 'm2']);
      expect(
        adapter.requests.single.uri.toString(),
        'https://llm.example.com/v1/models',
      );
      expect(
        adapter.requests.single.headers['Authorization'],
        'Bearer sk-test',
      );
    });

    test('sends no Authorization header without a key', () async {
      final adapter = _FakeAdapter((_) => _json({'data': []}));
      await fetchOpenAiModels(
        baseUrl: 'http://localhost:1234/v1',
        dio: _dio(adapter),
      );
      expect(
        adapter.requests.single.headers.containsKey('Authorization'),
        isFalse,
      );
    });

    test('an invalid URL fails before anything is sent', () async {
      final adapter = _FakeAdapter((_) => _json({'data': []}));
      await expectLater(
        fetchOpenAiModels(
          baseUrl: 'http://api.example.com/v1',
          apiKey: 'sk-test',
          dio: _dio(adapter),
        ),
        throwsA(isA<OpenAiConnectionException>()),
      );
      expect(adapter.requests, isEmpty);
    });
  });

  group('connection test errors', () {
    Future<OpenAiConnectionException> failWith(int status) async {
      final adapter = _FakeAdapter((_) => _json({'error': 'x'}, status));
      try {
        await fetchOpenAiModels(
          baseUrl: 'https://llm.example.com/v1',
          apiKey: 'sk-secret',
          dio: _dio(adapter),
        );
      } on OpenAiConnectionException catch (e) {
        return e;
      }
      fail('expected an OpenAiConnectionException for $status');
    }

    test('401/403/404/429/5xx map to what the athlete can fix', () async {
      expect((await failWith(401)).kind, LlmFailureKind.unauthorized);
      expect((await failWith(403)).kind, LlmFailureKind.unauthorized);
      expect((await failWith(404)).kind, LlmFailureKind.notFound);
      expect((await failWith(429)).kind, LlmFailureKind.rateLimited);
      expect((await failWith(500)).kind, LlmFailureKind.server);
      expect((await failWith(503)).kind, LlmFailureKind.server);
    });

    test('the key never appears in an error message', () async {
      for (final status in [401, 404, 500]) {
        expect((await failWith(status)).toString(), isNot(contains('secret')));
      }
    });

    test('an unreachable server is "unreachable"', () async {
      final adapter = _FakeAdapter((options) {
        throw DioException.connectionError(
          requestOptions: options,
          reason: 'refused',
        );
      });
      await expectLater(
        fetchOpenAiModels(baseUrl: 'http://localhost:1/v1', dio: _dio(adapter)),
        throwsA(
          isA<OpenAiConnectionException>().having(
            (e) => e.kind,
            'kind',
            LlmFailureKind.unreachable,
          ),
        ),
      );
    });

    test('runtime errors from the provider are classified the same way', () {
      expect(
        classifyLlmError(const AuthenticationException(message: 'bad key')),
        LlmFailureKind.unauthorized,
      );
      expect(
        classifyLlmError(const NotFoundException(message: 'no such model')),
        LlmFailureKind.notFound,
      );
      expect(
        classifyLlmError(const RateLimitException(message: 'slow down')),
        LlmFailureKind.rateLimited,
      );
      expect(
        classifyLlmError(
          const InternalServerException(message: 'boom', statusCode: 502),
        ),
        LlmFailureKind.server,
      );
      expect(
        classifyLlmError(const ConnectionException(message: 'refused')),
        LlmFailureKind.unreachable,
      );
      expect(
        classifyLlmError(
          const BadRequestException(
            message: "Model does not support tools: 'tools' is not supported",
          ),
        ),
        LlmFailureKind.toolsRejected,
      );
      // An unrelated 400 is the request's own fault (no failover);
      // errors that are not LLM failures at all are left alone.
      expect(
        classifyLlmError(const BadRequestException(message: 'bad json')),
        LlmFailureKind.badRequest,
      );
      expect(classifyLlmError(StateError('x')), isNull);
    });

    test('describeError reads sensibly for this provider', () {
      final l10n = AppLocalizationsEn();
      final auth = describeError(
        const AuthenticationException(message: 'bad key'),
        l10n,
      );
      expect(auth.title, contains('AI server'));
      expect(auth.reason, contains('API key'));
      expect(auth.title, isNot(contains('Intervals')));

      expect(
        describeError(const NotFoundException(message: 'x'), l10n).reason,
        allOf(contains('base URL'), contains('model')),
      );
      expect(
        describeError(const RateLimitException(message: 'x'), l10n).title,
        contains('slow down'),
      );
      expect(
        describeError(
          const InternalServerException(message: 'x', statusCode: 500),
          l10n,
        ).title,
        contains('trouble'),
      );
      expect(
        describeError(
          const BadRequestException(message: 'tools are not supported'),
          l10n,
        ).reason,
        contains('tool'),
      );
      // Intervals.icu errors keep their own wording.
      expect(
        describeError(
          DioException(
            requestOptions: RequestOptions(),
            response: Response(
              requestOptions: RequestOptions(),
              statusCode: 401,
            ),
          ),
          l10n,
        ).title,
        contains('Intervals.icu'),
      );
    });
  });

  group('local-model hints in the system prompt', () {
    String context(LlmProvider provider, {bool local = false}) =>
        buildRuntimeContext(
          now: DateTime(2026, 8, 30),
          intervalsConnected: true,
          cachedRanges: const {},
          provider: provider,
          model: 'm',
          localModel: local,
        );

    test('apply to OpenAI-compatible only on a local/private URL', () {
      expect(
        context(LlmProvider.openai, local: true),
        contains('running on a local model'),
      );
      expect(
        context(LlmProvider.openai),
        isNot(contains('running on a local model')),
      );
      expect(
        context(LlmProvider.claude, local: true),
        isNot(contains('running on a local model')),
      );
      expect(context(LlmProvider.ollama), contains('running on a local model'));
    });
  });

  group('consent wording', () {
    final l10n = AppLocalizationsEn();

    test('names the configured host; local vs third party', () async {
      final settings = LlmSettings.forTesting();
      await settings.load();
      await settings.setProvider(LlmProvider.openai);

      await settings.setOpenAiBaseUrl('https://llm.example.com/v1');
      expect(
        aiProviderName(l10n, settings),
        'llm.example.com (an OpenAI-compatible service)',
      );
      expect(aiProviderIsLocal(settings), isFalse);

      await settings.setOpenAiBaseUrl('http://192.168.1.5:8080/v1');
      expect(
        aiProviderName(l10n, settings),
        'your local model server (192.168.1.5)',
      );
      expect(aiProviderIsLocal(settings), isTrue);
    });

    Future<void> openDialog(WidgetTester tester, LlmSettings settings) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => askAiConsent(
                context,
                settings: settings,
                privacy: PrivacySettings.forTesting(),
              ),
              child: const Text('ask'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('ask'));
      await tester.pumpAndSettle();
    }

    testWidgets('a hosted server is described as a third party', (
      tester,
    ) async {
      final settings = LlmSettings.forTesting();
      await settings.setProvider(LlmProvider.openai);
      await settings.setOpenAiBaseUrl('https://llm.example.com/v1');
      await openDialog(tester, settings);

      final body = find.textContaining('llm.example.com');
      expect(body, findsOneWidget);
      expect(find.textContaining('outside the EU/EEA'), findsOneWidget);
      expect(find.textContaining('stays with you'), findsNothing);
    });

    testWidgets('localhost / a private IP gets the local wording', (
      tester,
    ) async {
      final settings = LlmSettings.forTesting();
      await settings.setProvider(LlmProvider.openai);
      await settings.setOpenAiBaseUrl('http://localhost:1234/v1');
      await openDialog(tester, settings);

      expect(find.textContaining('your local model server'), findsOneWidget);
      expect(find.textContaining('stays with you'), findsOneWidget);
      expect(find.textContaining('outside the EU/EEA'), findsNothing);
    });
  });

  group('backup', () {
    late Directory dir;
    late AppDatabase database;

    setUp(() async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      dir = await Directory.systemTemp.createTemp('triiq_openai_backup');
      database = AppDatabase.atPath(p.join(dir.path, 'a.db'));
    });

    tearDown(() async {
      await database.close();
      await dir.delete(recursive: true);
    });

    test('URL and model travel in the model list, the key does not', () async {
      final settings = LlmSettings.forTesting();
      await settings.load();
      await settings.setProvider(LlmProvider.openai);
      await settings.setOpenAiBaseUrl('https://llm.example.com/v1');
      await settings.setOpenAiModel('gpt-4o');
      await settings.setOpenAiApiKey('sk-openai-secret');

      final service = BackupService(database: database);
      final json = jsonDecode(service.encode(await service.export()));
      final exported = json['settings'] as Map;
      expect(exported.keys, contains(LlmSettings.modelsPref));
      expect(exported.keys, isNot(contains('llm.provider')));
      final models = jsonDecode(
        exported[LlmSettings.modelsPref]['v'] as String,
      );
      expect(models, [
        {
          'provider': 'openai',
          'model': 'gpt-4o',
          'base_url': 'https://llm.example.com/v1',
          'enabled': true,
        },
      ]);
      expect(jsonEncode(json), isNot(contains('sk-openai-secret')));
      expect(jsonEncode(json), isNot(contains('openai_api_key')));
      expect(BackupService.excludedPref('llm.ollama_base_url'), isTrue);
    });

    test('import restores the list, but never an unsafe URL', () async {
      final service = BackupService(database: database);
      final json = jsonDecode(service.encode(await service.export()));

      Future<List<LlmModelEntry>> restoreWith(String url) async {
        SharedPreferences.setMockInitialValues({});
        (json['settings'] as Map)[LlmSettings.modelsPref] = {
          't': 's',
          'v': jsonEncode([
            {'provider': 'openai', 'model': 'restored-model', 'base_url': url},
            {'provider': 'claude', 'model': 'claude-sonnet-5'},
          ]),
        };
        await service.restore(json);
        final prefs = await SharedPreferences.getInstance();
        return LlmModelEntry.decodeList(
          prefs.getString(LlmSettings.modelsPref)!,
        );
      }

      var restored = await restoreWith('https://llm.example.com/v1');
      expect(restored.map((e) => e.provider), [
        LlmProvider.openai,
        LlmProvider.claude,
      ]);
      expect(restored.first.baseUrl, 'https://llm.example.com/v1');
      expect(restored.first.model, 'restored-model');
      // No vault reference is taken from a file.
      expect(restored.every((e) => !e.legacyKey), isTrue);

      restored = await restoreWith('http://evil.example.com/v1');
      expect(restored.map((e) => e.provider), [LlmProvider.claude]);
      restored = await restoreWith('https://me:pw@evil.example.com/v1');
      expect(restored.map((e) => e.provider), [LlmProvider.claude]);
    });
  });

  group('settings screen', () {
    Future<void> pump(WidgetTester tester) async {
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.runAsync(LlmSettings.instance.load);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsGroupScreen(group: SettingsGroup.ai),
        ),
      );
      await tester.pump();
    }

    /// Settings → AI trainer, then the primary entry's editor.
    Future<void> openEditor(WidgetTester tester) async {
      await pump(tester);
      await tester.tap(find.byIcon(Icons.edit_outlined).first);
      await tester.pumpAndSettle();
    }

    const urlField = ValueKey('openai-url');
    const keyField = ValueKey('openai-key');
    const modelField = ValueKey('openai-model');
    const loadModels = ValueKey('openai-load-models');

    testWidgets('OpenAI-compatible fields show only for that provider', (
      tester,
    ) async {
      await LlmSettings.instance.setProvider(LlmProvider.claude);
      await openEditor(tester);
      expect(find.byKey(urlField), findsNothing);
      expect(find.text('OpenAI-compatible'), findsOneWidget); // the segment

      await tester.tap(find.text('OpenAI-compatible'));
      await tester.pumpAndSettle();
      expect(find.byKey(urlField), findsOneWidget);
      expect(find.byKey(keyField), findsOneWidget);
      expect(find.byKey(modelField), findsOneWidget);
      expect(find.byKey(loadModels), findsOneWidget);
      expect(find.text('Claude API key'), findsNothing);
      expect(find.text('Ollama server URL'), findsNothing);

      await tester.tap(find.text('Ollama'));
      await tester.pumpAndSettle();
      expect(find.byKey(urlField), findsNothing);
      expect(find.text('Ollama server URL'), findsOneWidget);
    });

    testWidgets('http:// to a public host is rejected with a reason', (
      tester,
    ) async {
      await LlmSettings.instance.setProvider(LlmProvider.openai);
      await openEditor(tester);

      await tester.enterText(find.byKey(urlField), 'http://api.example.com/v1');
      await tester.pump();
      expect(
        find.textContaining('only allowed for a server on your own network'),
        findsOneWidget,
      );

      await tester.enterText(find.byKey(urlField), 'http://192.168.1.5/v1');
      await tester.pump();
      expect(find.textContaining('only allowed for a server'), findsNothing);
      // A LAN http server is allowed, with the plain-text warning.
      expect(find.textContaining('Unencrypted (http)'), findsOneWidget);
      expect(find.textContaining('nothing leaves it'), findsOneWidget);
    });
  });
}
