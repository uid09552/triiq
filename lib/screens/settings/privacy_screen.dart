import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../agent/llm_settings.dart';
import '../../data/data_eraser.dart';
import '../../data/privacy_settings.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/section_card.dart';
import 'ai_consent.dart';

/// Where the full privacy notice lives (the docs site).
final privacyNoticeUrl = Uri.parse('https://uid09552.github.io/triiq/privacy/');

/// What TriIQ stores, who receives it and why, how long, and the athlete's
/// rights — with the controls that exercise them: AI consent, map tiles, and
/// deleting everything on the device. Export is in Settings → Backup.
class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({
    super.key,
    this.privacy,
    this.llm,
    this.eraser,
    this.openUrl,
  });

  final PrivacySettings? privacy;
  final LlmSettings? llm;
  final DataEraser? eraser;

  /// Opens a link; defaults to the system browser. A seam for tests.
  final Future<bool> Function(Uri url)? openUrl;

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  late final PrivacySettings _privacy =
      widget.privacy ?? PrivacySettings.instance;
  late final LlmSettings _llm = widget.llm ?? LlmSettings.instance;

  bool _erasing = false;

  @override
  void initState() {
    super.initState();
    _privacy.addListener(_changed);
  }

  @override
  void dispose() {
    _privacy.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  Future<void> _toggleAi(bool on) async {
    if (on) {
      await askAiConsent(context, settings: _llm, privacy: _privacy);
    } else {
      await _privacy.setAiConsent(false);
    }
  }

  Future<void> _erase() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l10n.pvEraseConfirmTitle),
        content: Text(l10n.pvEraseConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            key: const ValueKey('erase-confirm'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialog).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(l10n.pvEraseConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _erasing = true);
    String message;
    try {
      await (widget.eraser ?? DataEraser()).eraseAll();
      message = l10n.pvEraseDone;
    } catch (error) {
      message = l10n.pvEraseFailed('$error');
    }
    if (!mounted) return;
    setState(() => _erasing = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final since = _privacy.aiConsentAt;

    Widget section(IconData icon, String title, String body) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SectionCard(
        icon: icon,
        title: title,
        child: SelectableText(body, style: theme.textTheme.bodyMedium),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pvTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.pvIntro, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 16),
          SectionCard(
            icon: Icons.tune,
            title: l10n.pvControlsTitle,
            child: Column(
              children: [
                SwitchListTile(
                  key: const ValueKey('privacy-ai-consent'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.pvAiConsentTitle),
                  subtitle: Text(
                    since == null
                        ? l10n.pvAiConsentHelp
                        : '${l10n.pvAiConsentHelp}\n'
                              '${l10n.pvAiConsentSince(DateFormat.yMMMd(locale).format(since))}',
                  ),
                  value: _privacy.aiConsent,
                  onChanged: _toggleAi,
                ),
                SwitchListTile(
                  key: const ValueKey('privacy-map-tiles'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.pvMapTilesTitle),
                  subtitle: Text(l10n.pvMapTilesHelp),
                  value: _privacy.mapTiles,
                  onChanged: _privacy.setMapTiles,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          section(Icons.dataset_outlined, l10n.pvDataTitle, l10n.pvDataBody),
          section(Icons.phone_android, l10n.pvStoredTitle, l10n.pvStoredBody),
          section(
            Icons.share_outlined,
            l10n.pvRecipientsTitle,
            l10n.pvRecipientsBody,
          ),
          section(Icons.public, l10n.pvTransferTitle, l10n.pvTransferBody),
          section(Icons.gavel_outlined, l10n.pvBasisTitle, l10n.pvBasisBody),
          section(
            Icons.schedule_outlined,
            l10n.pvRetentionTitle,
            l10n.pvRetentionBody,
          ),
          section(
            Icons.verified_user_outlined,
            l10n.pvRightsTitle,
            l10n.pvRightsBody,
          ),
          SectionCard(
            icon: Icons.delete_forever_outlined,
            title: l10n.pvEraseTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.pvEraseHelp, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  key: const ValueKey('privacy-erase'),
                  onPressed: _erasing ? null : _erase,
                  style: FilledButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                  icon: _erasing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline),
                  label: Text(l10n.pvEraseButton),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            key: const ValueKey('privacy-open-web'),
            onPressed: () => (widget.openUrl ?? _launch)(privacyNoticeUrl),
            icon: const Icon(Icons.open_in_new),
            label: Text(l10n.pvOpenWeb),
          ),
          Text(
            l10n.pvContact,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  static Future<bool> _launch(Uri url) =>
      launchUrl(url, mode: LaunchMode.externalApplication);
}
