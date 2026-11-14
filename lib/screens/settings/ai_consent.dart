import 'package:flutter/material.dart';

import '../../agent/llm_settings.dart';
import '../../data/privacy_settings.dart';
import '../../l10n/app_localizations.dart';

/// One model entry's recipient as the athlete reads it in the consent
/// text. With [withHost], a cloud recipient also names its host (used when
/// several entries are listed, so each address is visible).
String aiEntryRecipient(
  AppLocalizations l10n,
  LlmModelEntry entry, {
  bool withHost = false,
}) {
  final host = entry.host;
  final name = switch (entry.provider) {
    LlmProvider.claude => l10n.pvProviderClaude,
    LlmProvider.ollama =>
      entry.isOllamaCloud
          ? l10n.pvProviderOllamaCloud
          : l10n.pvProviderOllamaServer,
    // Named by its host, so the athlete sees where the data goes; a
    // localhost / private-network server counts as local, anything else
    // as a third-party service.
    LlmProvider.openai =>
      entry.isLocal
          ? l10n.pvProviderOpenAiLocal(host)
          : l10n.pvProviderOpenAiCloud(host),
  };
  if (!withHost || entry.provider == LlmProvider.openai) return name;
  return l10n.pvProviderWithHost(name, host);
}

/// The entries the consent text is about: those still waiting for consent,
/// or — when none is — every usable enabled one (the privacy screen's
/// switch, re-asked after a withdrawal).
List<LlmModelEntry> _consentSubjects(LlmSettings settings) {
  final pending = settings.entriesAwaitingConsent;
  if (pending.isNotEmpty) return pending;
  final usable = settings.entries.where(settings.isUsable).toList();
  if (usable.isNotEmpty) return usable;
  return [?settings.primary];
}

/// The recipients as the athlete reads them in the consent text: one name,
/// or a list naming each distinct host.
String aiProviderName(AppLocalizations l10n, LlmSettings settings) {
  final subjects = _consentSubjects(settings);
  final seen = <String>{};
  final distinct = [
    for (final e in subjects)
      if (seen.add('${e.provider.name}|${e.host}')) e,
  ];
  if (distinct.isEmpty) return l10n.pvProviderClaude;
  if (distinct.length == 1) return aiEntryRecipient(l10n, distinct.single);
  final names = [
    for (final e in distinct) aiEntryRecipient(l10n, e, withHost: true),
  ];
  return l10n.pvProvidersList(
    names.sublist(0, names.length - 1).join(', '),
    names.last,
  );
}

/// Whether the consent text should use the local-model wording (data stays
/// on the athlete's network) rather than the third-party one: every entry
/// it is about is a local OpenAI-compatible server.
bool aiProviderIsLocal(LlmSettings settings) {
  final subjects = _consentSubjects(settings);
  return subjects.isNotEmpty &&
      subjects.every((e) => e.provider == LlmProvider.openai && e.isLocal);
}

/// The hosts a consent given now covers: every usable enabled entry's.
List<String> _consentHosts(LlmSettings settings) => [
  for (final e in settings.entries)
    if (settings.isUsable(e) && !e.isLocal) e.host,
];

/// Asks for the explicit consent to send training and health data to the AI
/// provider(s) (GDPR Art. 6(1)(a), 9(2)(a)) — naming each host that has not
/// been agreed to yet. Records it, with those hosts, when given. Returns
/// whether every usable entry is now covered.
Future<bool> askAiConsent(
  BuildContext context, {
  LlmSettings? settings,
  PrivacySettings? privacy,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final llm = settings ?? LlmSettings.instance;
  final store = privacy ?? PrivacySettings.instance;
  final granted = await showDialog<bool>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: Text(l10n.pvConsentDialogTitle),
      content: SingleChildScrollView(
        child: Text(
          aiProviderIsLocal(llm)
              ? l10n.pvConsentDialogBodyLocal(aiProviderName(l10n, llm))
              : l10n.pvConsentDialogBody(aiProviderName(l10n, llm)),
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey('ai-consent-no'),
          onPressed: () => Navigator.of(dialog).pop(false),
          child: Text(l10n.pvConsentNotNow),
        ),
        FilledButton(
          key: const ValueKey('ai-consent-yes'),
          onPressed: () => Navigator.of(dialog).pop(true),
          child: Text(l10n.pvConsentAllow),
        ),
      ],
    ),
  );
  if (granted == true) {
    await store.setAiConsent(true, hosts: _consentHosts(llm));
  }
  return store.aiConsent &&
      llm.entries
          .where(llm.isUsable)
          .every((e) => store.aiConsentCovers(e.host, local: e.isLocal));
}

/// Shown where the AI trainer would be used while a model is set up but
/// the athlete has not agreed yet (to it, or to a newly added host): what
/// it needs, and the button to decide.
class AiConsentCard extends StatelessWidget {
  const AiConsentCard({super.key, this.settings, this.privacy});

  final LlmSettings? settings;
  final PrivacySettings? privacy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final llm = settings ?? LlmSettings.instance;
    return Card(
      key: const ValueKey('ai-consent-card'),
      color: theme.colorScheme.secondaryContainer,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.privacy_tip_outlined,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.pvConsentCardTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              l10n.pvConsentCardBody(aiProviderName(l10n, llm)),
              style: theme.textTheme.bodySmall,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                key: const ValueKey('ai-consent-review'),
                onPressed: () =>
                    askAiConsent(context, settings: llm, privacy: privacy),
                child: Text(l10n.pvConsentAllow),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
