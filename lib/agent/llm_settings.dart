import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/privacy_settings.dart';
import '../data/secure_key_store.dart';
import 'llm_model_entry.dart';
import 'model_health.dart';

export 'llm_model_entry.dart';

/// The athlete's model list and credentials, shared by Settings, the agent
/// and every other LLM caller (through `LlmGateway`).
///
/// **Entries.** [entries] is an ordered list of [LlmModelEntry] — any mix
/// of Claude, Ollama and OpenAI-compatible servers. The order is the
/// priority: every LLM call uses the first enabled entry that works and
/// fails over down the list (see `LlmGateway`). The list itself goes to
/// `shared_preferences` (`llm.models`); each entry's API key goes to the OS
/// vault via [SecureKeyStore] under [LlmModelEntry.vaultKey], never in
/// preferences or a backup.
///
/// **Migration.** An install from before the list (one provider, model,
/// URL and key per provider) is migrated on the first [load] into a
/// one-entry list with the same provider, model and URL, whose key stays
/// under the old vault name ([LlmModelEntry.legacyKey]) — nothing is copied,
/// so the step is idempotent and cannot lose a key. A fresh install starts
/// with the same thing the old app showed: one Claude entry without a key.
///
/// **Single-model API.** [provider], [activeModel], `claudeModel`,
/// `setOllamaBaseUrl`, `setOpenAiApiKey`… predate the list and still work:
/// they read and edit the *primary* entry (the first one) — or, for the
/// per-provider ones, the first entry of that provider. Onboarding uses
/// them to set up its one model.
///
/// Nothing here is validated against the provider — a bad key surfaces on
/// the first call (or a Test in Settings).
class LlmSettings extends ChangeNotifier {
  LlmSettings._({
    this.requireConsent = true,
    PrivacySettings? privacy,
    DateTime Function()? clock,
  }) : _privacy = privacy ?? PrivacySettings.instance,
       health = ModelHealth(clock: clock) {
    // A change of the AI consent changes whether the trainer is available.
    if (requireConsent) _privacy.addListener(notifyListeners);
  }

  static final LlmSettings instance = LlmSettings._();

  /// A standalone instance for tests, backed by whatever
  /// `SharedPreferences.setMockInitialValues` provides. It does not ask for
  /// the athlete's AI consent unless [requireConsent] (then against
  /// [privacy]); [clock] drives the cooldowns of [health].
  @visibleForTesting
  factory LlmSettings.forTesting({
    bool requireConsent = false,
    PrivacySettings? privacy,
    DateTime Function()? clock,
  }) => LlmSettings._(
    requireConsent: requireConsent,
    privacy: privacy,
    clock: clock,
  );

  /// Whether sending data to a provider needs the athlete's consent
  /// ([PrivacySettings.aiConsentCovers]) first. Always, in the app.
  final bool requireConsent;
  final PrivacySettings _privacy;

  /// Per-entry failures and cooldowns, for the gateway and Settings.
  final ModelHealth health;

  /// The ordered model list (JSON, no secrets).
  static const modelsPref = 'llm.models';

  // The single-model app's preferences, read once by the migration.
  static const _providerKey = 'llm.provider';
  static const _claudeModelKey = 'llm.claude_model';
  static const _ollamaBaseUrlKey = 'llm.ollama_base_url';
  static const _ollamaModelKey = 'llm.ollama_model';
  static const openAiBaseUrlPref = 'llm.openai_base_url';
  static const openAiModelPref = 'llm.openai_model';

  static const defaultClaudeModel = LlmModelEntry.defaultClaudeModel;
  static const defaultOllamaBaseUrl = LlmModelEntry.defaultOllamaBaseUrl;
  static const defaultOllamaModel = LlmModelEntry.defaultOllamaModel;
  static const defaultOpenAiBaseUrl = LlmModelEntry.defaultOpenAiBaseUrl;
  static const defaultOpenAiModel = LlmModelEntry.defaultOpenAiModel;

  /// The Ollama Cloud host. Used to decide whether an API key is required
  /// and whether to offer the "get an API key" link — both make sense for
  /// the cloud service and not for a local/self-hosted server.
  static const ollamaCloudHost = LlmModelEntry.ollamaCloudHost;

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

  static List<String> modelSuggestionsFor(LlmProvider provider) =>
      switch (provider) {
        LlmProvider.claude => claudeModelSuggestions,
        LlmProvider.ollama => ollamaModelSuggestions,
        LlmProvider.openai => openAiModelSuggestions,
      };

  /// What a fresh install (and "Delete all data") starts from.
  static List<LlmModelEntry> get _defaultEntries => [
    LlmModelEntry.create(LlmProvider.claude, id: 'primary', legacyKey: true),
  ];

  List<LlmModelEntry> _entries = _defaultEntries;

  /// Keys by vault name, held in memory once [load] has read them.
  final _keys = <String, String>{};
  final _stores = <String, SecureKeyStore>{};
  bool _loaded = false;

  SecureKeyStore _store(String vaultKey) =>
      _stores.putIfAbsent(vaultKey, () => SecureKeyStore(vaultKey));

  // ---------------------------------------------------------------------
  // The list.

  /// The models, in priority order.
  List<LlmModelEntry> get entries => List.unmodifiable(_entries);

  /// The first entry — what the single-model API reads and edits.
  LlmModelEntry? get primary => _entries.firstOrNull;

  LlmModelEntry? entryById(String id) =>
      _entries.where((e) => e.id == id).firstOrNull;

  /// The API key stored for [entry], or null.
  String? keyFor(LlmModelEntry entry) => _keys[entry.vaultKey];

  bool hasKey(LlmModelEntry entry) => (keyFor(entry) ?? '').isNotEmpty;

  /// Whether a written key survives an app restart (false on web).
  bool get remembersKeys => _store('claude_api_key').isPersistent;

  /// What keeps [entry] from working, before anything is sent.
  LlmEntryProblem? problemOf(LlmModelEntry entry) =>
      entry.problem(hasKey: hasKey(entry));

  /// Enabled and complete.
  bool isUsable(LlmModelEntry entry) =>
      entry.enabled && problemOf(entry) == null;

  /// Whether data may go to [entry]'s host (always, for test instances).
  bool isConsented(LlmModelEntry entry) =>
      !requireConsent ||
      _privacy.aiConsentCovers(entry.host, local: entry.isLocal);

  /// Usable entries the athlete has not agreed to send data to yet.
  List<LlmModelEntry> get entriesAwaitingConsent => [
    for (final e in _entries)
      if (isUsable(e) && !isConsented(e)) e,
  ];

  /// Whether [load] has finished, so the UI can avoid rendering defaults
  /// over the top of stored values.
  bool get isLoaded => _loaded;

  /// At least one enabled entry is complete (key or server), whether or not
  /// the athlete has consented to data being sent to it yet.
  bool get hasProvider => _entries.any(isUsable);

  /// Whether the trainer can run: some enabled, complete entry may receive
  /// data.
  bool get isConfigured => _entries.any((e) => isUsable(e) && isConsented(e));

  /// Some enabled, complete entry waits for the athlete's consent — the
  /// consent card shows, naming its host. Others may still answer.
  bool get needsConsent => requireConsent && entriesAwaitingConsent.isNotEmpty;

  /// Nothing may be used until the athlete agrees: the chat cannot send.
  bool get blockedByConsent => needsConsent && !isConfigured;

  /// Adds [entry] at the end (lowest priority), with its key if given.
  Future<void> addEntry(LlmModelEntry entry, {String? apiKey}) async {
    _entries = [..._entries, entry];
    notifyListeners();
    await _saveEntries();
    if (apiKey != null && apiKey.trim().isNotEmpty) {
      await _writeKey(entry.vaultKey, apiKey);
    }
  }

  /// Replaces the entry with [entry]'s id. [apiKey] non-empty stores a new
  /// key; [clearKey] removes the stored one.
  Future<void> updateEntry(
    LlmModelEntry entry, {
    String? apiKey,
    bool clearKey = false,
  }) async {
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index < 0) return;
    final before = _entries[index];
    _entries = [..._entries]..[index] = entry;
    // A changed server or provider is a different endpoint: old failures
    // say nothing about it.
    if (before.provider != entry.provider ||
        before.effectiveBaseUrl != entry.effectiveBaseUrl ||
        before.model != entry.model) {
      health.forget(entry.id);
    }
    notifyListeners();
    await _saveEntries();
    if (before.vaultKey != entry.vaultKey) {
      await _deleteKeyIfUnused(before.vaultKey);
    }
    if (clearKey) {
      await _writeKey(entry.vaultKey, '');
    } else if (apiKey != null && apiKey.trim().isNotEmpty) {
      await _writeKey(entry.vaultKey, apiKey);
    }
  }

  Future<void> removeEntry(String id) async {
    final entry = entryById(id);
    if (entry == null) return;
    _entries = [
      for (final e in _entries)
        if (e.id != id) e,
    ];
    health.forget(id);
    notifyListeners();
    await _saveEntries();
    await _deleteKeyIfUnused(entry.vaultKey);
  }

  Future<void> setEntryEnabled(String id, bool enabled) async {
    final entry = entryById(id);
    if (entry == null || entry.enabled == enabled) return;
    await updateEntry(entry.copyWith(enabled: enabled));
  }

  Future<void> setEntryKey(String id, String key) async {
    final entry = entryById(id);
    if (entry == null) return;
    health.clear(id);
    await _writeKey(entry.vaultKey, key);
  }

  /// Moves the entry at [from] to [to] (indices in the list after removal,
  /// as `ReorderableListView` reports them once adjusted).
  Future<void> moveEntry(int from, int to) async {
    if (from < 0 || from >= _entries.length) return;
    final target = to.clamp(0, _entries.length - 1);
    if (target == from) return;
    final list = [..._entries];
    final moved = list.removeAt(from);
    list.insert(target, moved);
    _entries = list;
    notifyListeners();
    await _saveEntries();
  }

  /// Replaces the whole list (backup restore). Keys of entries that went
  /// away are deleted.
  Future<void> replaceEntries(List<LlmModelEntry> entries) async {
    final before = _entries;
    _entries = List.of(entries);
    notifyListeners();
    await _saveEntries();
    for (final e in before) {
      await _deleteKeyIfUnused(e.vaultKey);
    }
  }

  /// Removes every stored LLM key: each entry's, the single-model app's
  /// three, and any orphan under the per-entry prefix it knows of.
  Future<void> eraseAllKeys() async {
    final names = {
      for (final p in LlmProvider.values) LlmModelEntry.legacyVaultKey(p),
      for (final e in _entries) e.vaultKey,
      ..._keys.keys,
    };
    for (final name in names) {
      _keys.remove(name);
      await _store(name).delete();
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // The single-model API (the primary entry).

  LlmModelEntry? _firstOf(LlmProvider provider) =>
      _entries.where((e) => e.provider == provider).firstOrNull;

  /// The primary entry's provider (Claude when the list is empty).
  LlmProvider get provider => primary?.provider ?? LlmProvider.claude;

  /// The primary entry's model.
  String get activeModel =>
      primary?.model ?? LlmModelEntry.defaultModelFor(provider);

  String get claudeModel =>
      _firstOf(LlmProvider.claude)?.model ?? defaultClaudeModel;
  String get ollamaBaseUrl =>
      _firstOf(LlmProvider.ollama)?.effectiveBaseUrl ?? defaultOllamaBaseUrl;
  String get ollamaModel =>
      _firstOf(LlmProvider.ollama)?.model ?? defaultOllamaModel;
  String get openAiBaseUrl =>
      _firstOf(LlmProvider.openai)?.effectiveBaseUrl ?? defaultOpenAiBaseUrl;
  String get openAiModel =>
      _firstOf(LlmProvider.openai)?.model ?? defaultOpenAiModel;

  String? _keyOf(LlmProvider provider) {
    final entry = _firstOf(provider);
    return entry != null
        ? keyFor(entry)
        : _keys[LlmModelEntry.legacyVaultKey(provider)];
  }

  String? get claudeApiKey => _keyOf(LlmProvider.claude);
  bool get hasClaudeApiKey => (claudeApiKey ?? '').isNotEmpty;
  bool get remembersClaudeApiKey => remembersKeys;
  String? get ollamaApiKey => _keyOf(LlmProvider.ollama);
  bool get hasOllamaApiKey => (ollamaApiKey ?? '').isNotEmpty;
  bool get remembersOllamaApiKey => remembersKeys;
  String? get openAiApiKey => _keyOf(LlmProvider.openai);
  bool get hasOpenAiApiKey => (openAiApiKey ?? '').isNotEmpty;
  bool get remembersOpenAiApiKey => remembersKeys;

  /// Whether [ollamaBaseUrl] points at Ollama Cloud.
  bool get isOllamaCloud =>
      Uri.tryParse(ollamaBaseUrl.trim())?.host.toLowerCase() == ollamaCloudHost;

  /// Whether [openAiBaseUrl] is on the athlete's own machine or network.
  bool get isOpenAiLocal =>
      (_firstOf(LlmProvider.openai) ??
              LlmModelEntry.create(LlmProvider.openai, id: '-'))
          .isLocal;

  /// Makes the primary entry use [provider] (with that provider's default
  /// model and URL, and its single-model vault key). Adds one when the
  /// list is empty.
  Future<void> setProvider(LlmProvider provider) async {
    final first = primary;
    if (first != null && first.provider == provider) return;
    final replacement = LlmModelEntry.create(
      provider,
      id: first?.id ?? 'primary',
      name: '',
      legacyKey: true,
    );
    _entries = first == null
        ? [replacement]
        : ([..._entries]..[0] = replacement);
    if (first != null) health.forget(first.id);
    notifyListeners();
    await _saveEntries();
    if (first != null && first.vaultKey != replacement.vaultKey) {
      await _deleteKeyIfUnused(first.vaultKey, keepLegacy: true);
    }
  }

  Future<void> _editFirstOf(
    LlmProvider provider,
    LlmModelEntry Function(LlmModelEntry) edit,
  ) async {
    final entry = _firstOf(provider);
    if (entry == null) return;
    final edited = edit(entry);
    if (edited == entry) return;
    await updateEntry(edited);
  }

  Future<void> setClaudeModel(String model) => _editFirstOf(
    LlmProvider.claude,
    (e) => e.copyWith(
      model: model.trim().isEmpty ? defaultClaudeModel : model.trim(),
    ),
  );

  Future<void> setOllamaBaseUrl(String url) => _editFirstOf(
    LlmProvider.ollama,
    (e) => e.copyWith(
      baseUrl: url.trim().isEmpty ? defaultOllamaBaseUrl : url.trim(),
    ),
  );

  Future<void> setOllamaModel(String model) => _editFirstOf(
    LlmProvider.ollama,
    (e) => e.copyWith(
      model: model.trim().isEmpty ? defaultOllamaModel : model.trim(),
    ),
  );

  Future<void> setOpenAiBaseUrl(String url) => _editFirstOf(
    LlmProvider.openai,
    (e) => e.copyWith(
      baseUrl: url.trim().isEmpty ? defaultOpenAiBaseUrl : url.trim(),
    ),
  );

  Future<void> setOpenAiModel(String model) => _editFirstOf(
    LlmProvider.openai,
    (e) => e.copyWith(
      model: model.trim().isEmpty ? defaultOpenAiModel : model.trim(),
    ),
  );

  Future<void> _setProviderKey(LlmProvider provider, String key) async {
    final entry = _firstOf(provider);
    if (entry != null) health.clear(entry.id);
    await _writeKey(
      entry?.vaultKey ?? LlmModelEntry.legacyVaultKey(provider),
      key,
    );
  }

  /// Stores (or, for an empty [key], clears) the key of the first Claude
  /// entry.
  Future<void> setClaudeApiKey(String key) =>
      _setProviderKey(LlmProvider.claude, key);

  /// Stores (or, for an empty [key], clears) the key of the first Ollama
  /// entry.
  Future<void> setOllamaApiKey(String key) =>
      _setProviderKey(LlmProvider.ollama, key);

  /// Stores (or, for an empty [key], clears) the key of the first
  /// OpenAI-compatible entry.
  Future<void> setOpenAiApiKey(String key) =>
      _setProviderKey(LlmProvider.openai, key);

  // ---------------------------------------------------------------------
  // Loading and storing.

  /// Back to a fresh install (after "Delete all data"): the default entry,
  /// no keys in memory, no failure history. The stored keys are removed
  /// separately ([eraseAllKeys]).
  void resetInMemory() {
    _entries = _defaultEntries;
    _keys.clear();
    health.reset();
    notifyListeners();
  }

  /// Reads stored settings, migrating a single-model install once. Safe to
  /// call more than once; never throws.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(modelsPref);
      List<LlmModelEntry>? stored;
      if (raw != null) {
        try {
          stored = LlmModelEntry.decodeList(raw);
        } on FormatException catch (error) {
          debugPrint('LlmSettings: stored model list unreadable: $error');
        }
      }
      if (stored != null) {
        // A reload after a backup restore: keys of entries the restored
        // list no longer has must not linger in the vault.
        final previous = _loaded ? _entries : const <LlmModelEntry>[];
        _entries = stored;
        for (final gone in previous) {
          if (!gone.legacyKey) await _deleteKeyIfUnused(gone.vaultKey);
        }
      } else {
        _entries = [migrateSingleModel(prefs)];
        await prefs.setString(modelsPref, LlmModelEntry.encodeList(_entries));
        if (requireConsent) {
          await _privacy.adoptLegacyConsentHosts([
            for (final e in _entries)
              if (!e.isLocal) e.host,
          ]);
        }
      }
      final names = {
        for (final p in LlmProvider.values) LlmModelEntry.legacyVaultKey(p),
        for (final e in _entries) e.vaultKey,
      };
      _keys.clear();
      for (final name in names) {
        final value = await _store(name).read();
        if (value != null && value.isNotEmpty) _keys[name] = value;
      }
    } catch (error) {
      debugPrint('LlmSettings: cannot read stored settings: $error');
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  /// The one entry a single-model install becomes: its provider, that
  /// provider's model and URL, and its key under the old vault name. Pure
  /// over [prefs]; a fresh install gets the old default (Claude).
  @visibleForTesting
  static LlmModelEntry migrateSingleModel(SharedPreferences prefs) {
    final provider =
        LlmProvider.values
            .where((p) => p.name == prefs.getString(_providerKey))
            .firstOrNull ??
        LlmProvider.claude;
    final (modelKey, urlKey) = switch (provider) {
      LlmProvider.claude => (_claudeModelKey, null),
      LlmProvider.ollama => (_ollamaModelKey, _ollamaBaseUrlKey),
      LlmProvider.openai => (openAiModelPref, openAiBaseUrlPref),
    };
    return LlmModelEntry.create(
      provider,
      id: 'primary',
      model: prefs.getString(modelKey),
      baseUrl: urlKey == null ? null : prefs.getString(urlKey),
      legacyKey: true,
    );
  }

  Future<void> _saveEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(modelsPref, LlmModelEntry.encodeList(_entries));
    } catch (error) {
      // The change still applies for this run; only remembering it failed.
      debugPrint('LlmSettings: cannot persist the model list: $error');
    }
  }

  Future<void> _writeKey(String vaultKey, String key) async {
    final value = key.trim();
    if (value.isEmpty) {
      _keys.remove(vaultKey);
    } else {
      _keys[vaultKey] = value;
    }
    notifyListeners();
    if (value.isEmpty) {
      await _store(vaultKey).delete();
    } else {
      await _store(vaultKey).write(value);
    }
  }

  /// Deletes a key no entry refers to any more. The single-model names are
  /// kept with [keepLegacy] (the single-model API may switch back to them).
  Future<void> _deleteKeyIfUnused(
    String vaultKey, {
    bool keepLegacy = false,
  }) async {
    if (_entries.any((e) => e.vaultKey == vaultKey)) return;
    final legacy = LlmProvider.values
        .map(LlmModelEntry.legacyVaultKey)
        .contains(vaultKey);
    if (legacy && keepLegacy) return;
    if (_keys.remove(vaultKey) != null) notifyListeners();
    await _store(vaultKey).delete();
  }
}
