import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../agent/llm_settings.dart';
import '../../agent/model_connection.dart';
import '../../agent/model_health.dart';
import '../../agent/openai_connection.dart';
import '../../data/privacy_settings.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/status_message.dart' show describeLlmFailureShort;
import 'ai_consent.dart';
import 'model_entry_editor.dart';

/// Settings → AI trainer: the ordered list of model entries. Every LLM call
/// uses the first enabled entry that works and fails over down the list.
///
/// Each row: drag handle, name, provider and model, status (OK / needs
/// attention / cooling down, with the reason and when it last answered),
/// an on/off switch, and Up / Down / Test / Edit / Delete. Up and Down do
/// what the drag does, for anyone who cannot drag; screen readers get
/// "Move up / down / to the start / to the end" actions on each row from
/// [ReorderableListView] itself, routed through the same `onReorder`. **Add model** opens the editor.
class LlmModelsSection extends StatelessWidget {
  const LlmModelsSection({super.key, this.settings, this.privacy});

  final LlmSettings? settings;
  final PrivacySettings? privacy;

  LlmSettings get _llm => settings ?? LlmSettings.instance;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final llm = _llm;
    return ListenableBuilder(
      listenable: Listenable.merge([llm, llm.health]),
      builder: (context, _) {
        final entries = llm.entries;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.llmModelsIntro,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  l10n.llmModelsEmpty,
                  key: const ValueKey('llm-models-empty'),
                ),
              )
            else
              ReorderableListView(
                key: const ValueKey('llm-models-list'),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                onReorder: (from, to) =>
                    llm.moveEntry(from, to > from ? to - 1 : to),
                children: [
                  for (var i = 0; i < entries.length; i++)
                    _ModelTile(
                      key: ValueKey('llm-model-${entries[i].id}'),
                      settings: llm,
                      privacy: privacy,
                      entry: entries[i],
                      index: i,
                      count: entries.length,
                    ),
                ],
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonalIcon(
                key: const ValueKey('llm-add-model'),
                onPressed: () => _add(context),
                icon: const Icon(Icons.add),
                label: Text(l10n.llmAddModelButton),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _add(BuildContext context) async {
    final added = await Navigator.of(context).push<LlmModelEntry>(
      MaterialPageRoute(
        builder: (_) => ModelEntryEditorScreen(settings: settings),
      ),
    );
    if (added == null || !context.mounted) return;
    await _askConsentIfNeeded(context, _llm, privacy);
  }
}

/// A newly added or edited entry on a host the athlete has not agreed to
/// yet: ask right away (the consent card stays until they decide).
Future<void> _askConsentIfNeeded(
  BuildContext context,
  LlmSettings llm,
  PrivacySettings? privacy,
) async {
  if (!llm.needsConsent || !context.mounted) return;
  await askAiConsent(context, settings: llm, privacy: privacy);
}

class _ModelTile extends StatelessWidget {
  const _ModelTile({
    super.key,
    required this.settings,
    required this.privacy,
    required this.entry,
    required this.index,
    required this.count,
  });

  final LlmSettings settings;
  final PrivacySettings? privacy;
  final LlmModelEntry entry;
  final int index;
  final int count;

  String _providerName(AppLocalizations l10n) => switch (entry.provider) {
    LlmProvider.claude => l10n.claudeLabel,
    LlmProvider.ollama => l10n.ollamaLabel,
    LlmProvider.openai => l10n.openaiLabel,
  };

  /// The status line and whether it is a problem.
  (String, bool) _status(BuildContext context, AppLocalizations l10n) {
    if (!entry.enabled) return (l10n.llmStatusOff, false);
    final problem = settings.problemOf(entry);
    if (problem != null) {
      return (
        l10n.llmStatusNeedsAttention(switch (problem) {
          LlmEntryProblem.missingKey => l10n.llmProblemMissingKey,
          LlmEntryProblem.invalidUrl => l10n.llmProblemInvalidUrl,
          LlmEntryProblem.missingModel => l10n.llmModelMissingModel,
        }),
        true,
      );
    }
    if (!settings.isConsented(entry)) {
      return (l10n.llmStatusAwaitingConsent, true);
    }
    final ModelStatus status = settings.health.statusOf(entry.id);
    String time(DateTime t) =>
        DateFormat.Hm(Localizations.localeOf(context).toString()).format(t);
    final reason = describeLlmFailureShort(status.lastFailure, l10n);
    if (settings.health.isCoolingDown(entry.id)) {
      return (l10n.llmStatusCooling(time(status.coolingUntil!), reason), true);
    }
    if (status.needsAttention) {
      return (l10n.llmStatusNeedsAttention(reason), true);
    }
    if (status.lastFailure != null) {
      return (l10n.llmStatusLastFailed(reason), true);
    }
    if (status.lastUsed != null) {
      return (l10n.llmStatusOkLastUsed(time(status.lastUsed!)), false);
    }
    return (l10n.llmStatusReady, false);
  }

  Future<void> _move(int to) => settings.moveEntry(index, to);

  Future<void> _edit(BuildContext context) async {
    final edited = await Navigator.of(context).push<LlmModelEntry>(
      MaterialPageRoute(
        builder: (_) =>
            ModelEntryEditorScreen(entry: entry, settings: settings),
      ),
    );
    if (edited == null || !context.mounted) return;
    await _askConsentIfNeeded(context, settings, privacy);
  }

  Future<void> _delete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l10n.llmDeleteModelTitle),
        content: Text(l10n.llmDeleteModelBody(entry.label)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            key: const ValueKey('llm-model-delete-confirm'),
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(l10n.llmDeleteModelConfirm),
          ),
        ],
      ),
    );
    if (ok == true) await settings.removeEntry(entry.id);
  }

  Future<void> _test(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final models = await testModelConnection(
        entry,
        apiKey: settings.keyFor(entry),
      );
      settings.health.clear(entry.id);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.llmTestOk(entry.label, models.length))),
      );
    } catch (error) {
      final kind = error is OpenAiConnectionException
          ? error.kind
          : LlmFailureKind.unreachable;
      // A test is a manual retry: it replaces the cooldown with what it
      // found, flagging a refused key or unknown model.
      settings.health.clear(entry.id);
      settings.health.recordFailure(
        entry.id,
        kind,
        needsAttention:
            kind == LlmFailureKind.unauthorized ||
            kind == LlmFailureKind.notFound ||
            kind == LlmFailureKind.notConfigured,
      );
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.llmTestFailed(
              entry.label,
              describeLlmFailureShort(kind, l10n),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final (status, problem) = _status(context, l10n);
    final canUp = index > 0;
    final canDown = index < count - 1;
    final id = entry.id;
    final subtitle =
        '${_providerName(l10n)} · ${entry.model}'
        '${entry.provider == LlmProvider.claude ? '' : ' · ${entry.host}'}';

    return Semantics(
      container: true,
      label: l10n.llmModelSemantics(index + 1, count, entry.label),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 8, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReorderableDragStartListener(
                    index: index,
                    child: Tooltip(
                      message: l10n.llmDragToReorder,
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.drag_indicator),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1}. ${entry.label}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2, right: 4),
                              child: Icon(
                                problem
                                    ? Icons.warning_amber_rounded
                                    : Icons.check_circle_outline,
                                size: 14,
                                color: problem
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.primary,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                status,
                                key: ValueKey('llm-model-status-$id'),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: problem
                                      ? theme.colorScheme.error
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    key: ValueKey('llm-model-enabled-$id'),
                    value: entry.enabled,
                    onChanged: (on) async {
                      await settings.setEntryEnabled(id, on);
                      if (on && context.mounted) {
                        await _askConsentIfNeeded(context, settings, privacy);
                      }
                    },
                  ),
                ],
              ),
              Wrap(
                alignment: WrapAlignment.end,
                children: [
                  IconButton(
                    key: ValueKey('llm-model-up-$id'),
                    tooltip: l10n.llmMoveUp,
                    onPressed: canUp ? () => _move(index - 1) : null,
                    icon: const Icon(Icons.arrow_upward),
                  ),
                  IconButton(
                    key: ValueKey('llm-model-down-$id'),
                    tooltip: l10n.llmMoveDown,
                    onPressed: canDown ? () => _move(index + 1) : null,
                    icon: const Icon(Icons.arrow_downward),
                  ),
                  IconButton(
                    key: ValueKey('llm-model-test-$id'),
                    tooltip: l10n.testConnectionButton,
                    onPressed: () => _test(context),
                    icon: const Icon(Icons.wifi_tethering),
                  ),
                  IconButton(
                    key: ValueKey('llm-model-edit-$id'),
                    tooltip: l10n.llmEditModelTitle,
                    onPressed: () => _edit(context),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    key: ValueKey('llm-model-delete-$id'),
                    tooltip: l10n.llmDeleteModelTitle,
                    onPressed: () => _delete(context),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
