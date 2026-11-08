import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/privacy_settings.dart';
import '../data/secure_key_store.dart';

/// Which LLM backend the agent talks to.
enum LlmProvider {
  /// Anthropic's hosted Claude API. Needs an API key; costs money per call.
  claude,

  /// Ollama — defaults to Ollama Cloud (`ollama.com`), which needs an API
  /// key, same shape as Claude. Pointed at a local/self-hosted server
  /// instead, no key is needed. Either way the model must support tool
  /// calling, or the agent can't read any training data.
  ollama,
}

/// The user's LLM choice and credentials, shared by Settings and the agent.
///
/// Split by sensitivity, following the same rule as the Intervals.icu key:
/// the Claude and Ollama API keys are secrets and go to the OS credential
/// vault via [SecureKeyStore]; the provider choice, model names and Ollama
/// URL are ordinary preferences and go to `shared_preferences`.
///
/// Nothing here is validated against the provider — unlike Intervals.icu,
/// there is no cheap auth-test call that doesn't cost tokens, so a bad key
/// or an unreachable Ollama server surfaces as an error on the first chat
/// message instead.
class LlmSettings extends ChangeNotifier {
  LlmSettings._({this.requireConsent = true}) {
    // A change of the AI consent changes whether the trainer is available.
    if (requireConsent) PrivacySettings.instance.addListener(notifyListeners);
  }

  static final LlmSettings instance = LlmSettings._();

  /// A standalone instance for tests, backed by whatever
  /// `SharedPreferences.setMockInitialValues` provides. It does not ask for
  /// the athlete's AI consent, which belongs to the app.
  @visibleForTesting
  factory LlmSettings.forTesting() => LlmSettings._(requireConsent: false);

  /// Whether sending data to the provider needs the athlete's consent
  /// ([PrivacySettings.aiConsent]) first. Always, in the app.
  final bool requireConsent;

  static const _providerKey = 'llm.provider';
  static const _claudeModelKey = 'llm.claude_model';
  static const _ollamaBaseUrlKey = 'llm.ollama_base_url';
  static const _ollamaModelKey = 'llm.ollama_model';

  static const defaultClaudeModel = 'claude-sonnet-5';
  static const defaultOllamaBaseUrl = 'https://ollama.com';
  static const defaultOllamaModel = 'gpt-oss:120b';

  /// The Ollama Cloud host. Used to decide whether an API key is required
  /// and whether to offer the "get an API key" link — both make sense for
  /// the cloud service and not for a local/self-hosted server.
  static const ollamaCloudHost = 'ollama.com';

  /// Models known to work with this agent, offered as suggestions. The
  /// fields stay free text: the provider's line-up moves faster than the
  /// app, and a hardcoded list would eventually only be able to say no.
  static const claudeModelSuggestions = [
    'claude-sonnet-5',
    'claude-opus-5',
    'claude-haiku-4-5-20251001',
  ];
  static const ollamaModelSuggestions = [
    'gpt-oss:120b',
    'gpt-oss:20b',
    'qwen3-coder:480b',
    'deepseek-v3.1:671b',
  ];

  final _claudeApiKeyStore = SecureKeyStore('claude_api_key');
  final _ollamaApiKeyStore = SecureKeyStore('ollama_api_key');

  LlmProvider _provider = LlmProvider.claude;
  String _claudeModel = defaultClaudeModel;
  String _ollamaBaseUrl = defaultOllamaBaseUrl;
  String _ollamaModel = defaultOllamaModel;
  String? _claudeApiKey;
  String? _ollamaApiKey;
  bool _loaded = false;

  LlmProvider get provider => _provider;
  String get claudeModel => _claudeModel;
  String get ollamaBaseUrl => _ollamaBaseUrl;
  String get ollamaModel => _ollamaModel;

  /// The Claude API key, held in memory once [load] has read it back out of
  /// the vault. `null` when none is stored.
  String? get claudeApiKey => _claudeApiKey;

  bool get hasClaudeApiKey => (_claudeApiKey ?? '').isNotEmpty;

  /// Whether a written Claude key survives an app restart (false on web).
  bool get remembersClaudeApiKey => _claudeApiKeyStore.isPersistent;

  /// The Ollama Cloud API key, held in memory once [load] has read it back
  /// out of the vault. `null` when none is stored (fine for a local server;
  /// required for the cloud host — see [isOllamaCloud]).
  String? get ollamaApiKey => _ollamaApiKey;

  bool get hasOllamaApiKey => (_ollamaApiKey ?? '').isNotEmpty;

  /// Whether a written Ollama key survives an app restart (false on web).
  bool get remembersOllamaApiKey => _ollamaApiKeyStore.isPersistent;

  /// Whether [ollamaBaseUrl] points at Ollama Cloud rather than a
  /// local/self-hosted server.
  bool get isOllamaCloud =>
      Uri.tryParse(_ollamaBaseUrl.trim())?.host.toLowerCase() ==
      ollamaCloudHost;

  /// Whether [load] has finished, so the UI can avoid rendering defaults
  /// over the top of stored values.
  bool get isLoaded => _loaded;

  /// The model name currently in play, whichever provider is selected.
  String get activeModel =>
      _provider == LlmProvider.claude ? _claudeModel : _ollamaModel;

  /// Whether the agent has enough to run. A local/self-hosted Ollama server
  /// needs no credential, only a URL (which always has a default); Ollama
  /// Cloud needs a key, same as Claude.
  bool get isConfigured =>
      hasProvider && (!requireConsent || PrivacySettings.instance.aiConsent);

  /// A provider is set up (key or server), whether or not the athlete has
  /// consented to data being sent to it yet.
  bool get hasProvider => switch (_provider) {
    LlmProvider.claude => hasClaudeApiKey,
    LlmProvider.ollama =>
      _ollamaBaseUrl.trim().isNotEmpty && (!isOllamaCloud || hasOllamaApiKey),
  };

  /// A provider is set up but data may not be sent to it yet.
  bool get needsConsent =>
      requireConsent && hasProvider && !PrivacySettings.instance.aiConsent;

  /// Back to a fresh install (after "Delete all data"): default provider and
  /// models, no keys in memory. The stored keys are removed separately.
  void resetInMemory() {
    _provider = LlmProvider.claude;
    _claudeModel = defaultClaudeModel;
    _ollamaBaseUrl = defaultOllamaBaseUrl;
    _ollamaModel = defaultOllamaModel;
    _claudeApiKey = null;
    _ollamaApiKey = null;
    notifyListeners();
  }

  /// Reads stored settings. Safe to call more than once; never throws.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedProvider = prefs.getString(_providerKey);
      _provider = LlmProvider.values.firstWhere(
        (p) => p.name == storedProvider,
        orElse: () => _provider,
      );
      _claudeModel = prefs.getString(_claudeModelKey) ?? _claudeModel;
      _ollamaBaseUrl = prefs.getString(_ollamaBaseUrlKey) ?? _ollamaBaseUrl;
      _ollamaModel = prefs.getString(_ollamaModelKey) ?? _ollamaModel;
      _claudeApiKey = await _claudeApiKeyStore.read();
      _ollamaApiKey = await _ollamaApiKeyStore.read();
    } catch (error) {
      debugPrint('LlmSettings: cannot read stored settings: $error');
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  Future<void> setProvider(LlmProvider provider) async {
    if (provider == _provider) return;
    _provider = provider;
    notifyListeners();
    await _writeString(_providerKey, provider.name);
  }

  Future<void> setClaudeModel(String model) async {
    final value = model.trim().isEmpty ? defaultClaudeModel : model.trim();
    if (value == _claudeModel) return;
    _claudeModel = value;
    notifyListeners();
    await _writeString(_claudeModelKey, value);
  }

  Future<void> setOllamaBaseUrl(String url) async {
    final value = url.trim().isEmpty ? defaultOllamaBaseUrl : url.trim();
    if (value == _ollamaBaseUrl) return;
    _ollamaBaseUrl = value;
    notifyListeners();
    await _writeString(_ollamaBaseUrlKey, value);
  }

  Future<void> setOllamaModel(String model) async {
    final value = model.trim().isEmpty ? defaultOllamaModel : model.trim();
    if (value == _ollamaModel) return;
    _ollamaModel = value;
    notifyListeners();
    await _writeString(_ollamaModelKey, value);
  }

  /// Stores (or, for an empty [key], clears) the Claude API key.
  Future<void> setClaudeApiKey(String key) async {
    final value = key.trim();
    _claudeApiKey = value.isEmpty ? null : value;
    notifyListeners();
    if (value.isEmpty) {
      await _claudeApiKeyStore.delete();
    } else {
      await _claudeApiKeyStore.write(value);
    }
  }

  /// Stores (or, for an empty [key], clears) the Ollama Cloud API key.
  Future<void> setOllamaApiKey(String key) async {
    final value = key.trim();
    _ollamaApiKey = value.isEmpty ? null : value;
    notifyListeners();
    if (value.isEmpty) {
      await _ollamaApiKeyStore.delete();
    } else {
      await _ollamaApiKeyStore.write(value);
    }
  }

  Future<void> _writeString(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (error) {
      // The choice still applies for this run; only remembering it failed.
      debugPrint('LlmSettings: cannot persist "$key": $error');
    }
  }
}
