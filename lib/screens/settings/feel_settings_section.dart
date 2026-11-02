import 'package:flutter/material.dart';

import '../../data/feel_settings.dart';
import '../../l10n/app_localizations.dart';

/// Settings → Fatigue & soreness: whether a recent activity's detail
/// screen auto-prompts for the day's fatigue/soreness. The manual action
/// on any activity's detail screen stays available either way.
class FeelSettingsSection extends StatelessWidget {
  FeelSettingsSection({super.key, FeelSettings? settings})
    : settings = settings ?? FeelSettings.instance;

  final FeelSettings settings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => SwitchListTile(
        key: const ValueKey('feel-prompt-on-new-activity'),
        contentPadding: EdgeInsets.zero,
        title: Text(l10n.feelPromptOnNewActivity),
        subtitle: Text(l10n.feelPromptOnNewActivityHelp),
        value: settings.promptOnNewActivity,
        onChanged: (on) => settings.setPromptOnNewActivity(on),
      ),
    );
  }
}
