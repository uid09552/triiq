import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/privacy_settings.dart';
import '../data/secure_key_store.dart';
import 'openai_connection.dart';

/// Which LLM backend the agent talks to.
enum LlmProvider {
  /// Anthropic's hosted Claude API. Needs an API key; costs money per call.
  claude,

  /// Ollama — defaults to Ollama Cloud (`ollama.com`), which needs an API
  /// key, same shape as Claude. Pointed at a local/self-hosted server
  /// instead, no key is needed. Either way the model must support tool
  /// calling, or the agent can't read any training data.
  ollama,

  /// Any OpenAI-compatible chat-completions server: OpenAI itself, Azure-
  /// style proxies, OpenRouter, LM Studio, vLLM, llama.cpp, LiteLLM… The
  /// key is optional (local servers need none). On a local/private URL it
  /// counts as a local model, anywhere else as a third-party cloud service.
  openai,
}

/// The user's LLM choice and credentials, shared by Settings and the agent.
///
/// Split by sensitivity, following the same rule as the Intervals.icu key:
/// the Claude, Ollama and OpenAI-compatible API keys are secrets and go to the OS credential
/// vault via [SecureKeyStore]; the provider choice, model names and server
/// URLs are ordinary preferences and go to `shared_preferences`.
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
  static const openAiBaseUrlPref = 'llm.openai_base_url';
  static const openAiModelPref = 'llm.openai_model';

  static const defaultClaudeModel = 'claude-sonnet-5';
  static const defaultOllamaBaseUrl = 'https://ollama.com';
  static const defaultOllamaModel = 'gpt-oss:120b';
  static const defaultOpenAiBaseUrl = 'https://api.openai.com/v1';
  static const defaultOpenAiModel = 'gpt-4o-mini';

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
  static const openAiModelSuggestions = [
    'gpt-4o-mini',
    'gpt-4.1-mini',
    'gpt-4o',
  ];

  final _claudeApiKeyStore = SecureKeyStore('claude_api_key');
  final _ollamaApiKeyStore = SecureKeyStore('ollama_api_key');
  final _openAiApiKeyStore = SecureKeyStore('openai_api_key');

  LlmProvider _provider = LlmProvider.claude;
  String _claudeModel = defaultClaudeModel;
  String _ollamaBaseUrl = defaultOllamaBaseUrl;
  String _ollamaModel = defaultOllamaModel;
  String? _claudeApiKey;
  String? _ollamaApiKey;
  String _openAiBaseUrl = defaultOpenAiBaseUrl;
  String _openAiModel = defaultOpenAiModel;
  String? _openAiApiKey;
  bool _loaded = false;

  LlmProvider get provider => _provider;
  String get claudeModel => _claudeModel;
  String get ollamaBaseUrl => _ollamaBaseUrl;
  String get ollamaModel => _ollamaModel;
  String get openAiBaseUrl => _openAiBaseUrl;
  String get openAiModel => _openAiModel;

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

  /// The OpenAI-compatible API key, held in memory once [load] has read it
  /// back out of the vault. `null` when none is stored (fine for a local
  /// server). Never logged, never in `shared_preferences`, never in a
  /// backup.
  String? get openAiApiKey => _openAiApiKey;

  bool get hasOpenAiApiKey => (_openAiApiKey ?? '').isNotEmpty;

  /// Whether a written OpenAI-compatible key survives a restart (false on
  /// web).
  bool get remembersOpenAiApiKey => _openAiApiKeyStore.isPersistent;

  /// Whether [openAiBaseUrl] is on the athlete's own machine or network
  /// (localhost, private/LAN address): a local model, not a third party.
  bool get isOpenAiLocal => isLocalServerUrl(_openAiBaseUrl);

  /// Whether [load] has finished, so the UI can avoid rendering defaults
  /// over the top of stored values.
  bool get isLoaded => _loaded;

  /// The model name currently in play, whichever provider is selected.
  String get activeModel => switch (_provider) {
    LlmProvider.claude => _claudeModel,
    LlmProvider.ollama => _ollamaModel,
    LlmProvider.openai => _openAiModel,
  };

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
    // The key is optional (local servers need none); the URL must pass the
    // https-or-local rule, and a model name is needed to ask anything.
    LlmProvider.openai =>
      isValidOpenAiBaseUrl(_openAiBaseUrl) && _openAiModel.trim().isNotEmpty,
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
    _openAiBaseUrl = defaultOpenAiBaseUrl;
    _openAiModel = defaultOpenAiModel;
    _openAiApiKey = null;
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
      _openAiBaseUrl = prefs.getString(openAiBaseUrlPref) ?? _openAiBaseUrl;
      _openAiModel = prefs.getString(openAiModelPref) ?? _openAiModel;
      _claudeApiKey = await _claudeApiKeyStore.read();
      _ollamaApiKey = await _ollamaApiKeyStore.read();
      _openAiApiKey = await _openAiApiKeyStore.read();
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

  Future<void> setOpenAiBaseUrl(String url) async {
    final value = url.trim().isEmpty ? defaultOpenAiBaseUrl : url.trim();
    if (value == _openAiBaseUrl) return;
    _openAiBaseUrl = value;
    notifyListeners();
    await _writeString(openAiBaseUrlPref, value);
  }

  Future<void> setOpenAiModel(String model) async {
    final value = model.trim().isEmpty ? defaultOpenAiModel : model.trim();
    if (value == _openAiModel) return;
    _openAiModel = value;
    notifyListeners();
    await _writeString(openAiModelPref, value);
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

  /// Stores (or, for an empty [key], clears) the OpenAI-compatible API key
  /// in the OS vault.
  Future<void> setOpenAiApiKey(String key) async {
    final value = key.trim();
    _openAiApiKey = value.isEmpty ? null : value;
    notifyListeners();
    if (value.isEmpty) {
      await _openAiApiKeyStore.delete();
    } else {
      await _openAiApiKeyStore.write(value);
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
