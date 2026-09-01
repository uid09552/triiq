import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/agent/llm_settings.dart';

/// Which store each setting lands in matters: the Claude key is a secret
/// and must go to the OS vault, everything else is an ordinary preference.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, String> vault;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // Stand in for the OS credential vault; there's no plugin in a test
    // process, and SecureKeyStore swallows the resulting failures.
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

  test('defaults to Claude and is unconfigured until a key is stored',
      () async {
    final settings = LlmSettings.forTesting();
    await settings.load();

    expect(settings.provider, LlmProvider.claude);
    expect(settings.claudeModel, LlmSettings.defaultClaudeModel);
    expect(settings.isConfigured, isFalse);
  });

  test('Ollama defaults to the cloud host and needs a key, like Claude',
      () async {
    final settings = LlmSettings.forTesting();
    await settings.load();
    await settings.setProvider(LlmProvider.ollama);

    expect(settings.ollamaBaseUrl, LlmSettings.defaultOllamaBaseUrl);
    expect(settings.isOllamaCloud, isTrue);
    expect(settings.isConfigured, isFalse);
    expect(settings.activeModel, LlmSettings.defaultOllamaModel);

    await settings.setOllamaApiKey('ollama-cloud-test');
    expect(settings.isConfigured, isTrue);
  });

  test('a local/self-hosted Ollama server needs no credential', () async {
    final settings = LlmSettings.forTesting();
    await settings.load();
    await settings.setProvider(LlmProvider.ollama);
    await settings.setOllamaBaseUrl('http://localhost:11434');

    expect(settings.isOllamaCloud, isFalse);
    expect(settings.isConfigured, isTrue);
  });

  test('provider and model survive a restart, the key goes to the vault',
      () async {
    final settings = LlmSettings.forTesting();
    await settings.load();
    await settings.setProvider(LlmProvider.ollama);
    await settings.setOllamaBaseUrl('http://nas.local:11434');
    await settings.setOllamaModel('qwen3');
    await settings.setClaudeApiKey('sk-ant-test');
    await settings.setOllamaApiKey('ollama-secret-test');

    // Nothing secret in plain preferences.
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), isNot(contains(anyOf(contains('key')))));
    expect(vault.values, containsAll(['sk-ant-test', 'ollama-secret-test']));

    final reloaded = LlmSettings.forTesting();
    await reloaded.load();

    expect(reloaded.provider, LlmProvider.ollama);
    expect(reloaded.ollamaBaseUrl, 'http://nas.local:11434');
    expect(reloaded.ollamaModel, 'qwen3');
    expect(reloaded.claudeApiKey, 'sk-ant-test');
    expect(reloaded.ollamaApiKey, 'ollama-secret-test');
  });

  test('clearing the key removes it from the vault', () async {
    final settings = LlmSettings.forTesting();
    await settings.load();
    await settings.setClaudeApiKey('sk-ant-test');
    await settings.setClaudeApiKey('');

    expect(settings.hasClaudeApiKey, isFalse);
    expect(vault, isEmpty);
  });

  test('a blank model name falls back to the default rather than an empty '
      'request', () async {
    final settings = LlmSettings.forTesting();
    await settings.load();
    await settings.setClaudeModel('claude-opus-5');
    await settings.setClaudeModel('   ');

    expect(settings.claudeModel, LlmSettings.defaultClaudeModel);
  });
}
