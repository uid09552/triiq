import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/agent/llm_settings.dart';
import 'package:triiq/data/privacy_settings.dart';
import 'package:triiq/l10n/app_localizations_en.dart';
import 'package:triiq/screens/settings/ai_consent.dart';

/// The model list: migration from the single-model app, list editing and
/// its persistence, keys per entry, consent per host, and restore safety.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, String> vault;

  void mockVault(Map<String, String> initial) {
    vault = {...initial};
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
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockVault({});
  });

  Future<List<LlmModelEntry>> storedEntries() async {
    final prefs = await SharedPreferences.getInstance();
    return LlmModelEntry.decodeList(prefs.getString(LlmSettings.modelsPref)!);
  }

  group('migration from a single-model install', () {
    test('Claude: provider, model and key carry over, no key copied', () async {
      SharedPreferences.setMockInitialValues({
        'llm.provider': 'claude',
        'llm.claude_model': 'claude-opus-5',
      });
      mockVault({'claude_api_key': 'sk-ant-old'});
      final settings = LlmSettings.forTesting();
      await settings.load();

      final entry = settings.entries.single;
      expect(entry.provider, LlmProvider.claude);
      expect(entry.model, 'claude-opus-5');
      expect(entry.legacyKey, isTrue);
      expect(settings.keyFor(entry), 'sk-ant-old');
      expect(settings.isConfigured, isTrue);
      // The vault is untouched: the key stays under its old name.
      expect(vault, {'claude_api_key': 'sk-ant-old'});
      expect(await storedEntries(), settings.entries);
    });

    test('Ollama: URL, model and the cloud key carry over', () async {
      SharedPreferences.setMockInitialValues({
        'llm.provider': 'ollama',
        'llm.ollama_base_url': 'https://ollama.com',
        'llm.ollama_model': 'gpt-oss:20b',
      });
      mockVault({'ollama_api_key': 'ol-key', 'claude_api_key': 'unused'});
      final settings = LlmSettings.forTesting();
      await settings.load();

      final entry = settings.entries.single;
      expect(entry.provider, LlmProvider.ollama);
      expect(entry.baseUrl, 'https://ollama.com');
      expect(entry.model, 'gpt-oss:20b');
      expect(settings.keyFor(entry), 'ol-key');
      expect(settings.isConfigured, isTrue);
      // The single-model API reads what it read before.
      expect(settings.provider, LlmProvider.ollama);
      expect(settings.ollamaApiKey, 'ol-key');
      expect(settings.claudeApiKey, 'unused');
    });

    test('OpenAI-compatible: URL, model and optional key carry over', () async {
      SharedPreferences.setMockInitialValues({
        'llm.provider': 'openai',
        'llm.openai_base_url': 'http://192.168.1.5:1234/v1',
        'llm.openai_model': 'qwen2.5',
      });
      mockVault({'openai_api_key': 'sk-local'});
      final settings = LlmSettings.forTesting();
      await settings.load();

      final entry = settings.entries.single;
      expect(entry.provider, LlmProvider.openai);
      expect(entry.baseUrl, 'http://192.168.1.5:1234/v1');
      expect(entry.model, 'qwen2.5');
      expect(entry.isLocal, isTrue);
      expect(settings.keyFor(entry), 'sk-local');
      expect(settings.activeModel, 'qwen2.5');
    });

    test('a fresh install gets the old default: Claude, no key', () async {
      final settings = LlmSettings.forTesting();
      await settings.load();
      expect(settings.entries.single.provider, LlmProvider.claude);
      expect(settings.entries.single.model, LlmSettings.defaultClaudeModel);
      expect(settings.isConfigured, isFalse);
    });

    test('runs once: an edited list is not migrated again', () async {
      SharedPreferences.setMockInitialValues({'llm.provider': 'ollama'});
      final first = LlmSettings.forTesting();
      await first.load();
      await first.addEntry(
        LlmModelEntry.create(LlmProvider.claude, id: 'c2'),
        apiKey: 'sk-2',
      );
      await first.removeEntry(first.entries.first.id);

      // Old prefs are still there; a restart must not resurrect them.
      final again = LlmSettings.forTesting();
      await again.load();
      expect(again.entries.map((e) => e.id), ['c2']);
      final third = LlmSettings.forTesting();
      await third.load();
      expect(third.entries, again.entries);
    });

    test('an existing consent is kept for the migrated host only', () async {
      SharedPreferences.setMockInitialValues({
        'llm.provider': 'claude',
        'privacy.ai_consent_at': '2026-01-01T00:00:00.000',
      });
      mockVault({'claude_api_key': 'sk-ant-old'});
      final privacy = PrivacySettings.forTesting();
      final settings = LlmSettings.forTesting(
        requireConsent: true,
        privacy: privacy,
      );
      await settings.load();
      await privacy.load();

      expect(privacy.aiConsentHosts, {LlmModelEntry.claudeHost});
      expect(settings.isConfigured, isTrue);
      expect(settings.needsConsent, isFalse);

      // A new third-party host is not covered by that consent.
      await settings.addEntry(
        const LlmModelEntry(
          id: 'or',
          provider: LlmProvider.openai,
          model: 'gpt',
          baseUrl: 'https://openrouter.ai/api/v1',
        ),
      );
      expect(settings.needsConsent, isTrue);
      expect(settings.entriesAwaitingConsent.single.host, 'openrouter.ai');
      expect(settings.isConfigured, isTrue); // Claude still answers.
    });
  });

  group('editing the list', () {
    test(
      'order, enabled flag and names persist; keys go to the vault',
      () async {
        final settings = LlmSettings.forTesting();
        await settings.load();
        await settings.addEntry(
          const LlmModelEntry(
            id: 'ol',
            name: 'Ollama Cloud gpt-oss',
            provider: LlmProvider.ollama,
            model: 'gpt-oss:120b',
            baseUrl: 'https://ollama.com',
          ),
          apiKey: 'ol-secret',
        );
        await settings.addEntry(
          const LlmModelEntry(
            id: 'lm',
            name: 'LM Studio local',
            provider: LlmProvider.openai,
            model: 'qwen',
            baseUrl: 'http://localhost:1234/v1',
          ),
        );
        await settings.moveEntry(2, 0);
        await settings.setEntryEnabled('primary', false);

        expect(vault['llm_model_key_ol'], 'ol-secret');
        final prefs = await SharedPreferences.getInstance();
        for (final key in prefs.getKeys()) {
          expect('${prefs.get(key)}', isNot(contains('ol-secret')));
        }

        final reloaded = LlmSettings.forTesting();
        await reloaded.load();
        expect(reloaded.entries.map((e) => e.id), ['lm', 'primary', 'ol']);
        expect(reloaded.entries.map((e) => e.label), [
          'LM Studio local',
          LlmSettings.defaultClaudeModel,
          'Ollama Cloud gpt-oss',
        ]);
        expect(reloaded.entryById('primary')!.enabled, isFalse);
        expect(reloaded.keyFor(reloaded.entryById('ol')!), 'ol-secret');
      },
    );

    test('deleting an entry deletes its key', () async {
      final settings = LlmSettings.forTesting();
      await settings.load();
      await settings.addEntry(
        LlmModelEntry.create(LlmProvider.claude, id: 'c2'),
        apiKey: 'sk-2',
      );
      expect(vault, containsPair('llm_model_key_c2', 'sk-2'));
      await settings.removeEntry('c2');
      expect(vault, isNot(contains('llm_model_key_c2')));
    });

    test('Delete all data clears every entry key and the old three', () async {
      mockVault({'claude_api_key': 'a', 'ollama_api_key': 'b'});
      final settings = LlmSettings.forTesting();
      await settings.load();
      await settings.addEntry(
        LlmModelEntry.create(LlmProvider.openai, id: 'x'),
        apiKey: 'c',
      );
      await settings.eraseAllKeys();
      settings.resetInMemory();
      expect(vault, isEmpty);
      expect(settings.entries.single.provider, LlmProvider.claude);
    });

    test('changing provider never carries a key to the other host', () async {
      final settings = LlmSettings.forTesting();
      await settings.load();
      await settings.addEntry(
        LlmModelEntry.create(LlmProvider.claude, id: 'c2'),
        apiKey: 'sk-ant',
      );
      final entry = settings.entryById('c2')!;
      await settings.updateEntry(
        entry.copyWith(
          provider: LlmProvider.openai,
          baseUrl: 'https://llm.example.com/v1',
          model: 'gpt',
        ),
        clearKey: true,
      );
      expect(settings.keyFor(settings.entryById('c2')!), isNull);
      expect(vault, isNot(contains('llm_model_key_c2')));
    });
  });

  group('consent covers all enabled entries', () {
    test('the dialog text names every host waiting for consent', () async {
      final privacy = PrivacySettings.forTesting();
      final settings = LlmSettings.forTesting(
        requireConsent: true,
        privacy: privacy,
      );
      await settings.load();
      await settings.setClaudeApiKey('sk-ant');
      await settings.addEntry(
        const LlmModelEntry(
          id: 'ol',
          provider: LlmProvider.ollama,
          model: 'gpt-oss:120b',
          baseUrl: 'https://ollama.com',
        ),
        apiKey: 'ol',
      );
      await settings.addEntry(
        const LlmModelEntry(
          id: 'or',
          provider: LlmProvider.openai,
          model: 'gpt',
          baseUrl: 'https://openrouter.ai/api/v1',
        ),
      );
      final l10n = AppLocalizationsEn();
      expect(
        aiProviderName(l10n, settings),
        'Claude (Anthropic) (api.anthropic.com), Ollama Cloud (ollama.com) '
        'and openrouter.ai (an OpenAI-compatible service)',
      );
      expect(settings.blockedByConsent, isTrue);

      await privacy.setAiConsent(
        true,
        hosts: [for (final e in settings.entries) e.host],
      );
      expect(settings.needsConsent, isFalse);
      expect(privacy.aiConsentHosts, {
        'api.anthropic.com',
        'ollama.com',
        'openrouter.ai',
      });

      // Withdrawing forgets every host.
      await privacy.setAiConsent(false);
      expect(privacy.aiConsentHosts, isEmpty);
      expect(settings.isConfigured, isFalse);
    });

    test('a local server is covered by the consent itself', () async {
      final privacy = PrivacySettings.forTesting();
      await privacy.setAiConsent(true, hosts: const []);
      final settings = LlmSettings.forTesting(
        requireConsent: true,
        privacy: privacy,
      );
      await settings.load();
      await settings.replaceEntries([
        const LlmModelEntry(
          id: 'lm',
          provider: LlmProvider.openai,
          model: 'q',
          baseUrl: 'http://192.168.1.5:1234/v1',
        ),
      ]);
      expect(settings.isConfigured, isTrue);
      expect(settings.needsConsent, isFalse);
    });
  });

  group('restore', () {
    test('drops unsafe URLs and never trusts ids or vault names', () {
      final restored = restoreModelEntries(
        jsonEncode([
          {
            'id': 'primary',
            'legacy_key': true,
            'provider': 'openai',
            'model': 'gpt',
            'base_url': 'https://evil.example.com/v1',
          },
          {
            'provider': 'ollama',
            'model': 'x',
            'base_url': 'http://evil.example.com:11434',
          },
          {'provider': 'nope', 'model': 'x'},
        ]),
        const [],
      )!;
      expect(restored, hasLength(1));
      expect(restored.single.id, isNot('primary'));
      expect(restored.single.legacyKey, isFalse);
      expect(restored.single.vaultKey, startsWith('llm_model_key_'));
    });

    test('an entry for the same server and model keeps its key', () {
      const current = [
        LlmModelEntry(
          id: 'primary',
          provider: LlmProvider.claude,
          model: 'claude-sonnet-5',
          legacyKey: true,
        ),
      ];
      final restored = restoreModelEntries([
        {'provider': 'claude', 'model': 'claude-sonnet-5', 'name': 'Main'},
        {'provider': 'claude', 'model': 'claude-opus-5'},
      ], current)!;
      expect(restored.first.id, 'primary');
      expect(restored.first.legacyKey, isTrue);
      expect(restored.first.name, 'Main');
      expect(restored.last.legacyKey, isFalse);
      expect(restored.last.id, isNot('primary'));
    });
  });
}
