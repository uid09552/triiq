import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../agent/llm_settings.dart';
import '../../agent/model_connection.dart';
import '../../agent/ollama_connection.dart';
import '../../agent/openai_connection.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/status_message.dart' show describeLlmFailure;
import 'openai_texts.dart';

/// Adds a model entry ([entry] null) or edits one: name, provider, and the
/// provider's own fields — Claude key and model; Ollama server URL, key and
/// model; OpenAI-compatible base URL, optional key and model — with **Test
/// connection** / **Load models** to check it and list the server's models
/// for free. Nothing is stored until **Save**; a typed Ollama Cloud key is
/// tested first and not stored if the test fails. Pops the saved entry.
class ModelEntryEditorScreen extends StatefulWidget {
  const ModelEntryEditorScreen({super.key, this.entry, this.settings});

  final LlmModelEntry? entry;
  final LlmSettings? settings;

  @override
  State<ModelEntryEditorScreen> createState() => _ModelEntryEditorScreenState();
}

class _ModelEntryEditorScreenState extends State<ModelEntryEditorScreen> {
  late final LlmSettings _settings = widget.settings ?? LlmSettings.instance;
  late LlmProvider _provider = widget.entry?.provider ?? LlmProvider.claude;

  late final _name = TextEditingController(text: widget.entry?.name ?? '');
  final _key = TextEditingController();

  /// One model and one URL field per provider, so trying another chip and
  /// coming back keeps what was typed.
  late final _models = {
    for (final p in LlmProvider.values)
      p: TextEditingController(
        text: widget.entry?.provider == p
            ? widget.entry!.model
            : LlmModelEntry.defaultModelFor(p),
      ),
  };
  late final _urls = {
    for (final p in [LlmProvider.ollama, LlmProvider.openai])
      p: TextEditingController(
        text: widget.entry?.provider == p
            ? widget.entry!.effectiveBaseUrl
            : LlmModelEntry.defaultBaseUrlFor(p),
      ),
  };

  final _suggestions = {
    for (final p in LlmProvider.values)
      p: List.of(LlmSettings.modelSuggestionsFor(p)),
  };

  bool _showKey = false;
  bool _clearKey = false;
  bool _testing = false;
  bool _saving = false;
  String? _testError;
  String? _saveError;

  bool get _isNew => widget.entry == null;

  /// The key stored for this entry — only while it keeps its provider
  /// (a key never follows an entry to another provider's host).
  String? get _storedKey {
    final entry = widget.entry;
    if (entry == null || entry.provider != _provider || _clearKey) return null;
    return _settings.keyFor(entry);
  }

  bool get _hasStoredKey => (_storedKey ?? '').isNotEmpty;

  String? get _effectiveKey {
    final typed = _key.text.trim();
    return typed.isNotEmpty ? typed : _storedKey;
  }

  LlmModelEntry get _draft {
    final base =
        widget.entry ??
        LlmModelEntry.create(_provider, id: LlmModelEntry.newId());
    return LlmModelEntry(
      id: base.id,
      provider: _provider,
      name: _name.text.trim(),
      model: _models[_provider]!.text.trim(),
      baseUrl: _urls[_provider]?.text.trim() ?? '',
      enabled: base.enabled,
      // A provider change leaves the single-model vault name behind.
      legacyKey: base.legacyKey && base.provider == _provider,
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _key.dispose();
    for (final c in [..._models.values, ..._urls.values]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? l10n.llmAddModelTitle : l10n.llmEditModelTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const ValueKey('model-name'),
              controller: _name,
              decoration: InputDecoration(
                labelText: l10n.llmModelNameLabel,
                hintText: _models[_provider]!.text,
                helperText: l10n.llmModelNameHelp,
                helperMaxLines: 3,
              ),
            ),
            const SizedBox(height: 16),
            // Chips that wrap, not a SegmentedButton: three labels, one of
            // them long, do not fit a 360 dp phone in a row.
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (provider, label, icon) in [
                  (LlmProvider.claude, l10n.claudeLabel, Icons.bolt_outlined),
                  (LlmProvider.ollama, l10n.ollamaLabel, Icons.dns_outlined),
                  (LlmProvider.openai, l10n.openaiLabel, Icons.hub_outlined),
                ])
                  ChoiceChip(
                    key: ValueKey('llm-provider-${provider.name}'),
                    avatar: Icon(icon, size: 18),
                    label: Text(label),
                    selected: _provider == provider,
                    onSelected: (_) => setState(() {
                      _provider = provider;
                      _testError = null;
                      _saveError = null;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            ...switch (_provider) {
              LlmProvider.claude => _claudeFields(context),
              LlmProvider.ollama => _ollamaFields(context),
              LlmProvider.openai => _openAiFields(context),
            },
            if (_saveError != null) ...[
              const SizedBox(height: 10),
              Text(
                _saveError!,
                key: const ValueKey('model-save-error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                key: const ValueKey('model-save'),
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Icon(Icons.check),
                label: Text(l10n.llmSaveModelButton),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _keyField(
    BuildContext context, {
    required Key fieldKey,
    required String label,
    String? hint,
    Widget? trailing,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final field = TextField(
      key: fieldKey,
      controller: _key,
      obscureText: !_showKey,
      autocorrect: false,
      enableSuggestions: false,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: IconButton(
          tooltip: _showKey ? l10n.hideTooltip : l10n.showTooltip,
          icon: Icon(
            _showKey
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          onPressed: () => setState(() => _showKey = !_showKey),
        ),
      ),
      onChanged: (_) => setState(() => _testError = null),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (trailing == null)
          field
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: field),
              const SizedBox(width: 8),
              Padding(padding: const EdgeInsets.only(top: 4), child: trailing),
            ],
          ),
        if (_hasStoredKey)
          TextButton(
            key: const ValueKey('model-clear-key'),
            onPressed: () => setState(() => _clearKey = true),
            child: Text(l10n.clearButton),
          ),
      ],
    );
  }

  Widget _testRow(BuildContext context, {required String label, Key? key}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            TextButton.icon(
              key: key ?? const ValueKey('model-test'),
              onPressed: _testing ? null : () => _test(announce: true),
              icon: _testing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Icon(Icons.wifi_tethering, size: 16),
              label: Text(label),
            ),
          ],
        ),
        if (_testError != null) ...[
          const SizedBox(height: 6),
          Text(
            _testError!,
            key: const ValueKey('model-test-error'),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    );
  }

  List<Widget> _claudeFields(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      _keyField(
        context,
        fieldKey: const ValueKey('claude-key'),
        label: l10n.claudeApiKeyLabel,
        hint: _hasStoredKey ? l10n.claudeKeyStoredHint : 'sk-ant-…',
      ),
      const SizedBox(height: 10),
      _testRow(context, label: l10n.testConnectionButton),
      const SizedBox(height: 14),
      _modelField(
        fieldKey: const ValueKey('claude-model'),
        label: l10n.claudeModelLabel,
      ),
      const SizedBox(height: 10),
      _helpText(
        context,
        _settings.remembersKeys
            ? l10n.claudeKeySecureHelp
            : l10n.claudeKeyInsecureHelp,
      ),
    ];
  }

  List<Widget> _ollamaFields(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final url = _urls[LlmProvider.ollama]!;
    final isCloud = isOllamaCloudUrl(url.text);
    return [
      TextField(
        key: const ValueKey('ollama-url'),
        controller: url,
        autocorrect: false,
        keyboardType: TextInputType.url,
        decoration: InputDecoration(
          labelText: l10n.ollamaServerUrlLabel,
          // Plain http is fine for a server on your own network, but the
          // prompts and your training data travel unencrypted.
          helperText: isPlainHttpUrl(url.text) ? l10n.ollamaHttpWarning : null,
          helperMaxLines: 3,
        ),
        onChanged: (_) => setState(() => _testError = null),
      ),
      const SizedBox(height: 14),
      _keyField(
        context,
        fieldKey: const ValueKey('ollama-key'),
        label: isCloud
            ? l10n.ollamaCloudApiKeyLabel
            : l10n.ollamaApiKeyOptionalLabel,
        hint: _hasStoredKey ? l10n.ollamaKeyStoredHint : null,
        trailing: isCloud
            ? TextButton.icon(
                onPressed: _openOllamaKeysPage,
                icon: const Icon(Icons.open_in_new, size: 16),
                label: Text(l10n.getAKeyButton),
              )
            : null,
      ),
      const SizedBox(height: 10),
      _testRow(context, label: l10n.testConnectionButton),
      const SizedBox(height: 14),
      _modelField(
        fieldKey: const ValueKey('ollama-model'),
        label: l10n.ollamaModelLabel,
      ),
      const SizedBox(height: 10),
      _helpText(
        context,
        isCloud
            ? (_settings.remembersKeys
                  ? l10n.ollamaKeySecureHelp
                  : l10n.ollamaKeyInsecureHelp)
            : l10n.ollamaLocalHelp,
      ),
    ];
  }

  List<Widget> _openAiFields(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final url = _urls[LlmProvider.openai]!;
    final problem = checkOpenAiBaseUrl(url.text);
    final isLocal = isLocalServerUrl(url.text);
    final host = serverHostOf(url.text);
    return [
      TextField(
        key: const ValueKey('openai-url'),
        controller: url,
        autocorrect: false,
        keyboardType: TextInputType.url,
        decoration: InputDecoration(
          labelText: l10n.openaiBaseUrlLabel,
          hintText: LlmSettings.defaultOpenAiBaseUrl,
          // A rejected URL (http:// to a public host...) says why; a plain
          // http:// URL on the local network is allowed but warned about.
          errorText: problem == null
              ? null
              : openAiUrlProblemText(l10n, problem, url.text),
          errorMaxLines: 3,
          helperText: problem == null && isPlainHttpUrl(url.text)
              ? l10n.ollamaHttpWarning
              : null,
          helperMaxLines: 3,
        ),
        onChanged: (_) => setState(() => _testError = null),
      ),
      const SizedBox(height: 14),
      _keyField(
        context,
        fieldKey: const ValueKey('openai-key'),
        label: l10n.openaiApiKeyOptionalLabel,
        hint: _hasStoredKey ? l10n.openaiKeyStoredHint : null,
      ),
      const SizedBox(height: 10),
      _testRow(
        context,
        label: l10n.openaiLoadModelsButton,
        key: const ValueKey('openai-load-models'),
      ),
      const SizedBox(height: 14),
      _modelField(
        fieldKey: const ValueKey('openai-model'),
        label: l10n.openaiModelLabel,
      ),
      const SizedBox(height: 10),
      _helpText(
        context,
        isLocal
            ? l10n.openaiLocalHelp(host)
            : '${l10n.openaiCloudHelp(host)}\n'
                  '${_settings.remembersKeys ? l10n.openaiKeySecureHelp : l10n.openaiKeyInsecureHelp}',
      ),
    ];
  }

  Widget _modelField({required Key fieldKey, required String label}) {
    final controller = _models[_provider]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          key: fieldKey,
          controller: controller,
          autocorrect: false,
          decoration: InputDecoration(labelText: label),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final suggestion in _suggestions[_provider]!)
              ActionChip(
                label: Text(suggestion),
                onPressed: () => setState(() => controller.text = suggestion),
              ),
          ],
        ),
      ],
    );
  }

  Widget _helpText(BuildContext context, String text) => Text(
    text,
    style: Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  );

  /// The free connection check: lists the server's models. [announce]
  /// false is the silent check on open.
  Future<bool> _test({required bool announce}) async {
    final l10n = AppLocalizations.of(context)!;
    final draft = _draft;
    if (draft.provider == LlmProvider.openai) {
      final problem = checkOpenAiBaseUrl(draft.effectiveBaseUrl);
      if (problem != null) {
        if (announce) {
          setState(
            () => _testError = openAiUrlProblemText(
              l10n,
              problem,
              draft.effectiveBaseUrl,
            ),
          );
        }
        return false;
      }
    }
    setState(() {
      _testing = true;
      _testError = null;
    });
    try {
      final models = await testModelConnection(draft, apiKey: _effectiveKey);
      if (!mounted) return true;
      setState(() {
        if (models.isNotEmpty) _suggestions[draft.provider] = models;
        _testing = false;
      });
      if (!_isNew) _settings.health.clear(draft.id);
      if (announce) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.connectedModelsMessage(l10n.connectedPrefix, models.length),
            ),
          ),
        );
      }
      return true;
    } catch (e) {
      if (!mounted) return false;
      final message = e is OpenAiConnectionException
          ? () {
              final friendly = describeLlmFailure(e.kind, l10n);
              return '${friendly.title}. ${friendly.reason}';
            }()
          : l10n.couldNotConnect('$e');
      setState(() {
        _testing = false;
        if (announce) _testError = message;
      });
      return false;
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final draft = _draft;
    final typedKey = _key.text.trim();
    String? error;
    if (draft.model.isEmpty) {
      error = l10n.llmModelMissingModel;
    } else if (draft.provider == LlmProvider.openai) {
      final problem = checkOpenAiBaseUrl(draft.effectiveBaseUrl);
      if (problem != null) {
        error = openAiUrlProblemText(l10n, problem, draft.effectiveBaseUrl);
      }
    } else if (draft.provider == LlmProvider.ollama &&
        typedKey.isNotEmpty &&
        !draft.isOllamaCloud) {
      // The key is only ever sent to Ollama Cloud over https; saving it for
      // any other server would look like it works while doing nothing.
      error = l10n.ollamaKeyCloudOnly;
    }
    if (error != null) {
      setState(() => _saveError = error);
      return;
    }
    setState(() {
      _saving = true;
      _saveError = null;
    });
    // An Ollama Cloud key is tested before it is stored (the test is free),
    // the same principle as the Intervals.icu key.
    if (draft.provider == LlmProvider.ollama && typedKey.isNotEmpty) {
      final ok = await _test(announce: true);
      if (!mounted) return;
      if (!ok) {
        setState(() {
          _saving = false;
          _saveError = l10n.couldNotConnectKeyNotSaved(_testError ?? '');
        });
        return;
      }
    }
    final providerChanged =
        widget.entry != null && widget.entry!.provider != draft.provider;
    if (_isNew) {
      await _settings.addEntry(draft, apiKey: typedKey);
    } else {
      await _settings.updateEntry(
        draft,
        apiKey: typedKey,
        clearKey: typedKey.isEmpty && (_clearKey || providerChanged),
      );
    }
    if (!mounted) return;
    Navigator.of(context).pop(draft);
  }

  Future<void> _openOllamaKeysPage() async {
    final uri = Uri.parse('https://ollama.com/settings/keys');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.couldNotOpenUrl(uri.toString()),
          ),
        ),
      );
    }
  }
}
