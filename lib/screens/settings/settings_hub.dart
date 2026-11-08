import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'privacy_screen.dart';
import 'settings_screen.dart';

/// Every settings section, wherever it lives.
enum SettingsSection {
  appearance,
  language,
  notifications,
  sync,
  calendar,
  backup,
  feel,
  weeklyTargets,
  yearGoals,
  privacy,
  ai;

  String title(AppLocalizations l10n) => switch (this) {
    appearance => l10n.appearanceTitle,
    language => l10n.languageTitle,
    notifications => l10n.notificationsTitle,
    sync => l10n.syncSectionTitle,
    calendar => l10n.calendarSettingsTitle,
    backup => l10n.backupTitle,
    feel => l10n.feelSettingsTitle,
    weeklyTargets => l10n.weeklyTargetsSectionTitle,
    yearGoals => l10n.yearGoalsTitle,
    privacy => l10n.pvTitle,
    ai => l10n.llmProviderTitle,
  };

  IconData get icon => switch (this) {
    appearance => Icons.brightness_6_outlined,
    language => Icons.language_outlined,
    notifications => Icons.notifications_outlined,
    sync => Icons.sync_outlined,
    calendar => Icons.calendar_month_outlined,
    backup => Icons.backup_outlined,
    feel => Icons.mood_outlined,
    weeklyTargets => Icons.track_changes_outlined,
    yearGoals => Icons.flag_outlined,
    privacy => Icons.privacy_tip_outlined,
    ai => Icons.auto_awesome_outlined,
  };

  /// Words a search matches besides the title — English and German both,
  /// so a setting is found whichever language the athlete thinks in.
  List<String> get keywords => switch (this) {
    appearance => const [
      'appearance',
      'theme',
      'dark',
      'light',
      'colour',
      'color',
      'developer',
      'erscheinungsbild',
      'design',
      'dunkel',
      'hell',
      'farbe',
    ],
    language => const [
      'language',
      'english',
      'german',
      'sprache',
      'deutsch',
      'englisch',
    ],
    notifications => const [
      'notifications',
      'reminder',
      'briefing',
      'morning',
      'push',
      'benachrichtigungen',
      'erinnerung',
      'morgen',
    ],
    sync => const [
      'sync',
      'background',
      'automatic',
      'interval',
      'refresh',
      'synchronisierung',
      'hintergrund',
      'automatisch',
      'aktualisieren',
    ],
    calendar => const [
      'calendar',
      'week start',
      'device calendar',
      'kalender',
      'wochenbeginn',
    ],
    backup => const [
      'backup',
      'export',
      'import',
      'restore',
      'datensicherung',
      'sicherung',
      'wiederherstellen',
    ],
    feel => const [
      'feel',
      'fatigue',
      'soreness',
      'prompt',
      'befinden',
      'müdigkeit',
      'muskelkater',
      'gefühl',
    ],
    weeklyTargets => const [
      'weekly targets',
      'hours',
      'goal',
      'swim',
      'ride',
      'run',
      'wochenziele',
      'stunden',
      'ziel',
      'schwimmen',
      'rad',
      'laufen',
    ],
    yearGoals => const [
      'year goals',
      'distance',
      'annual',
      'jahresziele',
      'jahr',
      'distanz',
    ],
    privacy => const [
      'privacy',
      'gdpr',
      'consent',
      'delete',
      'map tiles',
      'openstreetmap',
      'data',
      'datenschutz',
      'dsgvo',
      'einwilligung',
      'löschen',
      'karte',
      'daten',
    ],
    ai => const [
      'ai',
      'llm',
      'claude',
      'ollama',
      'model',
      'api key',
      'trainer',
      'consent',
      'ki',
      'modell',
      'schlüssel',
      'einwilligung',
      'anbieter',
    ],
  };

  SettingsGroup get group =>
      SettingsGroup.values.firstWhere((g) => g.sections.contains(this));

  bool matches(String query, AppLocalizations l10n) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return false;
    return title(l10n).toLowerCase().contains(q) ||
        keywords.any((k) => k.contains(q));
  }
}

/// The four pages Settings is split into.
enum SettingsGroup {
  training([
    SettingsSection.weeklyTargets,
    SettingsSection.yearGoals,
    SettingsSection.feel,
  ]),
  ai([SettingsSection.ai]),
  data([
    SettingsSection.sync,
    SettingsSection.calendar,
    SettingsSection.backup,
    SettingsSection.privacy,
  ]),
  app([
    SettingsSection.appearance,
    SettingsSection.language,
    SettingsSection.notifications,
  ]);

  const SettingsGroup(this.sections);

  final List<SettingsSection> sections;

  String title(AppLocalizations l10n) => switch (this) {
    training => l10n.setGroupTraining,
    ai => l10n.setGroupAi,
    data => l10n.setGroupData,
    app => l10n.setGroupApp,
  };

  String subtitle(AppLocalizations l10n) => switch (this) {
    training => l10n.setGroupTrainingSub,
    ai => l10n.setGroupAiSub,
    data => l10n.setGroupDataSub,
    app => l10n.setGroupAppSub,
  };

  IconData get icon => switch (this) {
    training => Icons.fitness_center,
    ai => Icons.auto_awesome_outlined,
    data => Icons.shield_outlined,
    app => Icons.tune,
  };
}

/// Opens [section]: its group's page, scrolled to it — or, for Privacy &
/// data, the privacy screen itself.
void openSettingsSection(BuildContext context, SettingsSection section) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => section == SettingsSection.privacy
          ? const PrivacyScreen()
          : SettingsGroupScreen(group: section.group, focus: section),
    ),
  );
}

/// Settings: a search field and four groups, each one tap away — every
/// setting in at most two taps.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final results = [
      for (final s in SettingsSection.values)
        if (s.matches(_query, l10n)) s,
    ];
    final searching = _query.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleSettings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SearchBar(
            key: const ValueKey('settings-search'),
            controller: _search,
            hintText: l10n.setSearchHint,
            leading: const Icon(Icons.search),
            trailing: [
              if (searching)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _search.clear();
                    setState(() => _query = '');
                  },
                ),
            ],
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 16),
          if (searching) ...[
            if (results.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.setNoResults(_query.trim()),
                  textAlign: TextAlign.center,
                ),
              ),
            for (final s in results)
              Card(
                child: ListTile(
                  key: ValueKey('settings-result-${s.name}'),
                  leading: Icon(s.icon),
                  title: Text(s.title(l10n)),
                  subtitle: Text(s.group.title(l10n)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => openSettingsSection(context, s),
                ),
              ),
          ] else
            for (final g in SettingsGroup.values)
              Card(
                child: ListTile(
                  key: ValueKey('settings-group-${g.name}'),
                  leading: Icon(g.icon),
                  title: Text(
                    g.title(l10n),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(g.subtitle(l10n)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SettingsGroupScreen(group: g),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
