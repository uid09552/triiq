import '../analysis/analysis_screen.dart';
import '../events/events_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../activities/activities_screen.dart';
import '../knowledge/knowledge_library_screen.dart';
import '../plan/plan_screen.dart';
import '../statistics/weekly_review_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import '../sync/sync_screen.dart';

/// Submenu for functionality that doesn't need a permanent bottom-nav slot.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _MoreTile(
          icon: Icons.analytics_outlined,
          title: l10n.analysisTitle,
          subtitle: l10n.moreAnalysisSubtitle,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AnalysisScreen()),
          ),
        ),
        const SizedBox(height: 10),
        _MoreTile(
          icon: Icons.emoji_events_outlined,
          title: l10n.eventsTitle,
          subtitle: l10n.moreEventsSubtitle,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const EventsScreen()),
          ),
        ),
        const SizedBox(height: 10),
        _MoreTile(
          icon: Icons.person_outline,
          title: l10n.titleProfile,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ),
        ),
        const SizedBox(height: 10),
        _MoreTile(
          icon: Icons.settings_outlined,
          title: l10n.titleSettings,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
        const SizedBox(height: 10),
        _MoreTile(
          icon: Icons.cloud_sync_outlined,
          title: l10n.titleSync,
          subtitle: l10n.moreSyncSubtitle,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SyncScreen()),
          ),
        ),
        const SizedBox(height: 10),
        _MoreTile(
          icon: Icons.list_alt_outlined,
          title: l10n.titleActivities,
          subtitle: l10n.moreActivitiesSubtitle,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ActivitiesScreen()),
          ),
        ),
        const SizedBox(height: 10),
        _MoreTile(
          icon: Icons.event_note_outlined,
          title: l10n.trainingPlansTitle,
          subtitle: l10n.morePlanSubtitle,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PlanScreen()),
          ),
        ),
        const SizedBox(height: 10),
        _MoreTile(
          icon: Icons.insights_outlined,
          title: l10n.weeklyReviewTitle,
          subtitle: l10n.moreReviewSubtitle,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const WeeklyReviewScreen()),
          ),
        ),
        if (!kIsWeb) ...[
          const SizedBox(height: 10),
          _MoreTile(
            icon: Icons.menu_book_outlined,
            title: l10n.knowledgeLibraryTitle,
            subtitle: l10n.moreKnowledgeSubtitle,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => KnowledgeLibraryScreen()),
            ),
          ),
        ],
        const SizedBox(height: 20),
        const SizedBox(height: 10),
        _MoreTile(
          icon: Icons.fitness_center_outlined,
          title: l10n.gearTitle,
          subtitle: l10n.comingSoon,
          enabled: false,
        ),
      ],
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        enabled: enabled,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: enabled
                ? colorScheme.primary.withValues(alpha: 0.12)
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: enabled ? colorScheme.primary : colorScheme.outline,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: enabled ? const Icon(Icons.chevron_right) : null,
      ),
    );
  }
}
