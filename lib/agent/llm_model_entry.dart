import 'dart:convert';
import 'dart:math';

import 'llm_provider.dart';
import 'openai_connection.dart';
import '../util/clock.dart';

export 'llm_provider.dart';

/// What keeps a model entry from being usable, before anything is sent.
enum LlmEntryProblem {
  /// Claude, or Ollama Cloud, without a stored API key.
  missingKey,

  /// No server URL, or one that fails the https-or-local rule.
  invalidUrl,

  /// No model name.
  missingModel,
}

/// One configured model: which provider, which model, where, and whether
/// it takes part. The athlete's ordered list of these is the failover
/// priority (first = tried first). See `LlmSettings.entries`.
///
/// Only non-secret fields live here; the entry's API key is in the OS vault
/// under [vaultKey] and never in `shared_preferences` or a backup.
class LlmModelEntry {
  const LlmModelEntry({
    required this.id,
    required this.provider,
    required this.model,
    this.name = '',
    this.baseUrl = '',
    this.enabled = true,
    this.legacyKey = false,
  });

  /// A fresh entry for [provider] with that provider's defaults.
  factory LlmModelEntry.create(
    LlmProvider provider, {
    String? id,
    String name = '',
    String? model,
    String? baseUrl,
    bool legacyKey = false,
  }) => LlmModelEntry(
    id: id ?? newId(),
    provider: provider,
    name: name,
    model: model ?? defaultModelFor(provider),
    baseUrl: baseUrl ?? defaultBaseUrlFor(provider),
    legacyKey: legacyKey,
  );

  /// Stable within this device; used for the vault key and the health
  /// record. Never trusted from a backup (see [restoreModelEntries]).
  final String id;

  /// What the athlete called it ("Claude Sonnet", "LM Studio local"). Empty
  /// = show the model name.
  final String name;
  final LlmProvider provider;
  final String model;

  /// Server URL for Ollama / OpenAI-compatible; unused for Claude.
  final String baseUrl;

  /// Disabled entries stay in the list but are never called.
  final bool enabled;

  /// The key lives under the pre-multi-model vault name for this provider
  /// (`claude_api_key`, `ollama_api_key`, `openai_api_key`) — the entry an
  /// existing single-model install was migrated into, so its stored key
  /// keeps working without being copied.
  final bool legacyKey;

  static const defaultClaudeModel = 'claude-sonnet-5';
  static const defaultOllamaBaseUrl = 'https://ollama.com';
  static const defaultOllamaModel = 'gpt-oss:120b';
  static const defaultOpenAiBaseUrl = 'https://api.openai.com/v1';
  static const defaultOpenAiModel = 'gpt-4o-mini';

  /// The Ollama Cloud host (the only place an Ollama key is ever sent).
  static const ollamaCloudHost = 'ollama.com';

  /// The Claude API host, for the consent text and the consent record.
  static const claudeHost = 'api.anthropic.com';

  static String defaultModelFor(LlmProvider provider) => switch (provider) {
    LlmProvider.claude => defaultClaudeModel,
    LlmProvider.ollama => defaultOllamaModel,
    LlmProvider.openai => defaultOpenAiModel,
  };

  static String defaultBaseUrlFor(LlmProvider provider) => switch (provider) {
    LlmProvider.claude => '',
    LlmProvider.ollama => defaultOllamaBaseUrl,
    LlmProvider.openai => defaultOpenAiBaseUrl,
  };

  /// The vault name the single-model app used for [provider]'s key.
  static String legacyVaultKey(LlmProvider provider) => switch (provider) {
    LlmProvider.claude => 'claude_api_key',
    LlmProvider.ollama => 'ollama_api_key',
    LlmProvider.openai => 'openai_api_key',
  };

  /// Prefix of every per-entry vault key, so "Delete all data" can find
  /// them.
  static const vaultKeyPrefix = 'llm_model_key_';

  static final _random = Random();

  static String newId() =>
      '${clockNow().microsecondsSinceEpoch.toRadixString(36)}'
      '${_random.nextInt(1 << 20).toRadixString(36)}';

  /// Where this entry's API key is stored in the OS vault.
  String get vaultKey =>
      legacyKey ? legacyVaultKey(provider) : '$vaultKeyPrefix$id';

  /// [baseUrl], or the provider's default when blank. Empty for Claude.
  String get effectiveBaseUrl {
    if (provider == LlmProvider.claude) return '';
    final url = baseUrl.trim();
    return url.isEmpty ? defaultBaseUrlFor(provider) : url;
  }

  bool get isOllamaCloud =>
      provider == LlmProvider.ollama &&
      Uri.tryParse(effectiveBaseUrl)?.host.toLowerCase() == ollamaCloudHost;

  /// On the athlete's own machine or network (no third party sees data).
  bool get isLocal =>
      provider != LlmProvider.claude && isLocalServerUrl(effectiveBaseUrl);

  /// The host data goes to, as named in the consent text and recorded with
  /// the consent.
  String get host => provider == LlmProvider.claude
      ? claudeHost
      : serverHostOf(effectiveBaseUrl);

  /// Whether a key is required (Claude, Ollama Cloud); optional otherwise.
  bool get needsKey => provider == LlmProvider.claude || isOllamaCloud;

  /// The name shown in lists and in the "answered by" chip.
  String get label => name.trim().isNotEmpty ? name.trim() : model.trim();

  /// What stops this entry from working, given whether its key is stored.
  LlmEntryProblem? problem({required bool hasKey}) {
    if (model.trim().isEmpty) return LlmEntryProblem.missingModel;
    switch (provider) {
      case LlmProvider.claude:
        if (!hasKey) return LlmEntryProblem.missingKey;
      case LlmProvider.ollama:
        if (effectiveBaseUrl.isEmpty) return LlmEntryProblem.invalidUrl;
        if (isOllamaCloud && !hasKey) return LlmEntryProblem.missingKey;
      case LlmProvider.openai:
        if (!isValidOpenAiBaseUrl(effectiveBaseUrl)) {
          return LlmEntryProblem.invalidUrl;
        }
    }
    return null;
  }

  LlmModelEntry copyWith({
    String? name,
    LlmProvider? provider,
    String? model,
    String? baseUrl,
    bool? enabled,
    bool? legacyKey,
  }) => LlmModelEntry(
    id: id,
    name: name ?? this.name,
    provider: provider ?? this.provider,
    model: model ?? this.model,
    baseUrl: baseUrl ?? this.baseUrl,
    enabled: enabled ?? this.enabled,
    legacyKey: legacyKey ?? this.legacyKey,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    if (name.isNotEmpty) 'name': name,
    'provider': provider.name,
    'model': model,
    if (provider != LlmProvider.claude) 'base_url': baseUrl,
    'enabled': enabled,
    if (legacyKey) 'legacy_key': true,
  };

  /// The fields a backup carries: no id, no vault reference, no key.
  Map<String, Object?> toBackupJson() => {
    if (name.isNotEmpty) 'name': name,
    'provider': provider.name,
    'model': model,
    if (provider != LlmProvider.claude) 'base_url': baseUrl,
    'enabled': enabled,
  };

  /// Null for anything that is not a well-formed entry.
  static LlmModelEntry? fromJson(Object? json) {
    if (json is! Map) return null;
    final provider = LlmProvider.values
        .where((p) => p.name == json['provider'])
        .firstOrNull;
    final id = json['id'];
    final model = json['model'];
    if (provider == null || id is! String || id.isEmpty || model is! String) {
      return null;
    }
    final name = json['name'];
    final baseUrl = json['base_url'];
    return LlmModelEntry(
      id: id,
      provider: provider,
      model: model,
      name: name is String ? name : '',
      baseUrl: baseUrl is String ? baseUrl : '',
      enabled: json['enabled'] != false,
      legacyKey: json['legacy_key'] == true,
    );
  }

  static String encodeList(List<LlmModelEntry> entries) =>
      jsonEncode([for (final e in entries) e.toJson()]);

  /// The stored list; malformed entries are dropped.
  static List<LlmModelEntry> decodeList(String raw) {
    final json = jsonDecode(raw);
    if (json is! List) throw const FormatException('not a list');
    return [for (final e in json) ?fromJson(e)];
  }

  @override
  bool operator ==(Object other) =>
      other is LlmModelEntry &&
      other.id == id &&
      other.name == name &&
      other.provider == provider &&
      other.model == model &&
      other.baseUrl == baseUrl &&
      other.enabled == enabled &&
      other.legacyKey == legacyKey;

  @override
  int get hashCode =>
      Object.hash(id, name, provider, model, baseUrl, enabled, legacyKey);

  @override
  String toString() => 'LlmModelEntry($id, ${provider.name}, $model)';
}

/// The model list from a backup file, made safe for this device.
///
/// A backup is not trusted to aim the trainer — or a stored key — at a
/// server: every URL must pass the same https-or-local rule as Settings
/// (entries that fail are dropped), ids and vault references are never
/// taken from the file, and a restored entry only reuses a key already on
/// this device when [current] has an entry for the same provider, server
/// and model (so the key goes nowhere it did not go before). Every other
/// entry comes back without a key. Returns null when [value] holds no list.
List<LlmModelEntry>? restoreModelEntries(
  Object? value,
  List<LlmModelEntry> current,
) {
  Object? json = value;
  if (json is String) {
    try {
      json = jsonDecode(json);
    } on FormatException {
      return null;
    }
  }
  if (json is! List) return null;
  String norm(String url) => normalizeOpenAiBaseUrl(url).toLowerCase();
  final taken = <String>{};
  final restored = <LlmModelEntry>[];
  for (final item in json) {
    if (item is! Map) continue;
    final parsed = LlmModelEntry.fromJson({...item, 'id': 'restored'});
    if (parsed == null) continue;
    if (parsed.provider != LlmProvider.claude &&
        !isValidOpenAiBaseUrl(parsed.effectiveBaseUrl)) {
      continue;
    }
    final match = current
        .where(
          (c) =>
              !taken.contains(c.id) &&
              c.provider == parsed.provider &&
              c.model.trim() == parsed.model.trim() &&
              norm(c.effectiveBaseUrl) == norm(parsed.effectiveBaseUrl),
        )
        .firstOrNull;
    if (match != null) {
      taken.add(match.id);
      restored.add(
        match.copyWith(
          name: parsed.name,
          baseUrl: parsed.baseUrl,
          enabled: parsed.enabled,
        ),
      );
    } else {
      restored.add(
        LlmModelEntry(
          id: LlmModelEntry.newId(),
          provider: parsed.provider,
          model: parsed.model,
          name: parsed.name,
          baseUrl: parsed.baseUrl,
          enabled: parsed.enabled,
        ),
      );
    }
  }
  return restored;
}
