import '../events/events_screen.dart';
import '../memory/memory_screen.dart';
import '../season/season_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../knowledge/knowledge_library_screen.dart';
import '../plan/plan_screen.dart';
import '../sync/sync_screen.dart';

/// What doesn't need a permanent bottom-nav slot, in three small groups:
/// planning, the trainer's knowledge, and data. Analysis views live in the
/// Insights hub, the activity list too; sync is also one tap away from the
/// status chip on Today and Insights.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    void open(Widget Function() screen) => Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => screen()));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _GroupHeader(l10n.moreGroupPlan),
        _MoreTile(
          icon: Icons.event_note_outlined,
          title: l10n.trainingPlansTitle,
          subtitle: l10n.morePlanSubtitle,
          onTap: () => open(() => const PlanScreen()),
        ),
        _MoreTile(
          icon: Icons.timeline,
          title: l10n.seasonTitle,
          subtitle: l10n.moreSeasonSubtitle,
          onTap: () => open(() => const SeasonScreen()),
        ),
        _MoreTile(
          icon: Icons.emoji_events_outlined,
          title: l10n.eventsTitle,
          subtitle: l10n.moreEventsSubtitle,
          onTap: () => open(() => const EventsScreen()),
        ),
        _GroupHeader(l10n.moreGroupTrainer),
        _MoreTile(
          icon: Icons.psychology_alt_outlined,
          title: l10n.memoryTitle,
          subtitle: l10n.moreMemorySubtitle,
          onTap: () => open(() => const MemoryScreen()),
        ),
        if (!kIsWeb)
          _MoreTile(
            icon: Icons.menu_book_outlined,
            title: l10n.knowledgeLibraryTitle,
            subtitle: l10n.moreKnowledgeSubtitle,
            onTap: () => open(() => KnowledgeLibraryScreen()),
          ),
        _GroupHeader(l10n.moreGroupData),
        _MoreTile(
          icon: Icons.cloud_sync_outlined,
          title: l10n.titleSync,
          subtitle: l10n.moreSyncSubtitle,
          onTap: () => open(() => const SyncScreen()),
        ),
      ],
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 1.1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
