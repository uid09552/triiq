import 'package:flutter/material.dart';

import '../../agent/llm_settings.dart';
import '../../data/privacy_settings.dart';
import '../../l10n/app_localizations.dart';

/// The provider's name as the athlete reads it in the consent text.
String aiProviderName(AppLocalizations l10n, LlmSettings settings) =>
    switch (settings.provider) {
      LlmProvider.claude => l10n.pvProviderClaude,
      LlmProvider.ollama =>
        settings.isOllamaCloud
            ? l10n.pvProviderOllamaCloud
            : l10n.pvProviderOllamaServer,
    };

/// Asks for the explicit consent to send training and health data to the AI
/// provider (GDPR Art. 6(1)(a), 9(2)(a)). Records it when given. Returns
/// whether consent now stands.
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
      content: Text(l10n.pvConsentDialogBody(aiProviderName(l10n, llm))),
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
  if (granted == true) await store.setAiConsent(true);
  return store.aiConsent;
}

/// Shown where the AI trainer would be used while a provider is set up but
/// the athlete has not agreed yet: what it needs, and the button to decide.
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
