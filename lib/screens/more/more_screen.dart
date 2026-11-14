import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../navigation/app_destinations.dart';
import '../../navigation/okf_index.dart';
import '../events/events_screen.dart';
import '../knowledge/knowledge_library_screen.dart';
import '../memory/memory_screen.dart';
import '../plan/plan_screen.dart';
import '../season/season_screen.dart';
import '../sync/sync_screen.dart';

/// The three small groups More is split into.
enum MoreGroup { plan, trainer, data }

/// One entry on the More tab.
class MoreEntry {
  const MoreEntry({
    required this.id,
    required this.group,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.builder,
    this.webAvailable = true,
  });

  final String id;
  final MoreGroup group;
  final IconData icon;
  final String Function(AppLocalizations l10n) title;
  final String Function(AppLocalizations l10n) subtitle;
  final WidgetBuilder builder;

  /// False for entries that need the local database (not on web).
  final bool webAvailable;

  bool get available => webAvailable || !kIsWeb;
}

/// Every More entry, in display order.
final List<MoreEntry> moreEntries = [
  MoreEntry(
    id: 'plan',
    group: MoreGroup.plan,
    icon: Icons.event_note_outlined,
    title: (l) => l.trainingPlansTitle,
    subtitle: (l) => l.morePlanSubtitle,
    builder: (_) => const PlanScreen(),
  ),
  MoreEntry(
    id: 'season',
    group: MoreGroup.plan,
    icon: Icons.timeline,
    title: (l) => l.seasonTitle,
    subtitle: (l) => l.moreSeasonSubtitle,
    builder: (_) => const SeasonScreen(),
  ),
  MoreEntry(
    id: 'events',
    group: MoreGroup.plan,
    icon: Icons.emoji_events_outlined,
    title: (l) => l.eventsTitle,
    subtitle: (l) => l.moreEventsSubtitle,
    builder: (_) => const EventsScreen(),
  ),
  MoreEntry(
    id: 'memory',
    group: MoreGroup.trainer,
    icon: Icons.psychology_alt_outlined,
    title: (l) => l.memoryTitle,
    subtitle: (l) => l.moreMemorySubtitle,
    builder: (_) => const MemoryScreen(),
  ),
  MoreEntry(
    id: 'knowledge',
    group: MoreGroup.trainer,
    icon: Icons.menu_book_outlined,
    title: (l) => l.knowledgeLibraryTitle,
    subtitle: (l) => l.moreKnowledgeSubtitle,
    builder: (_) => KnowledgeLibraryScreen(),
    webAvailable: false,
  ),
  MoreEntry(
    id: 'sync',
    group: MoreGroup.data,
    icon: Icons.cloud_sync_outlined,
    title: (l) => l.titleSync,
    subtitle: (l) => l.moreSyncSubtitle,
    builder: (_) => const SyncScreen(),
  ),
];

String moreGroupTitle(AppLocalizations l10n, MoreGroup group) =>
    switch (group) {
      MoreGroup.plan => l10n.moreGroupPlan,
      MoreGroup.trainer => l10n.moreGroupTrainer,
      MoreGroup.data => l10n.moreGroupData,
    };

/// What doesn't need a permanent bottom-nav slot, in three small groups:
/// planning, the trainer's knowledge, and data — plus, at the top, a search
/// over every page and setting of the app. Analysis views live in the
/// Insights hub, the activity list too; sync is also one tap away from the
/// status chip on Today and Insights.
class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key, this.okf, this.destinations});

  /// Test seam: where the okf text the search also matches comes from.
  final Future<OkfIndex>? okf;

  /// Test seam: what the search covers (default: [appDestinations]).
  final List<AppDestination>? destinations;

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  final _search = TextEditingController();
  String _query = '';
  OkfIndex? _okf;

  @override
  void initState() {
    super.initState();
    // Search works without it (titles, keywords, descriptions); the okf
    // text only adds matches once loaded.
    (widget.okf ?? OkfIndex.load()).then((index) {
      if (mounted) setState(() => _okf = index);
    }, onError: (Object _) {});
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final searching = _query.trim().isNotEmpty;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SearchBar(
          key: const ValueKey('more-search'),
          controller: _search,
          hintText: l10n.appSearchHint,
          leading: const Icon(Icons.search),
          trailing: [
            if (searching)
              IconButton(
                tooltip: l10n.clearButton,
                icon: const Icon(Icons.close),
                onPressed: () {
                  _search.clear();
                  setState(() => _query = '');
                },
              ),
          ],
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: 8),
        if (searching)
          ..._results(context, l10n)
        else
          for (final group in MoreGroup.values) ...[
            _GroupHeader(moreGroupTitle(l10n, group)),
            for (final e in moreEntries)
              if (e.group == group && e.available)
                _MoreTile(
                  key: ValueKey('more-${e.id}'),
                  icon: e.icon,
                  title: e.title(l10n),
                  subtitle: e.subtitle(l10n),
                  onTap: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute<void>(builder: e.builder)),
                ),
          ],
      ],
    );
  }

  List<Widget> _results(BuildContext context, AppLocalizations l10n) {
    final results = searchDestinations(
      _query,
      destinations: widget.destinations,
      okf: _okf,
    );
    if (results.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.appSearchNoResults(_query.trim()),
            textAlign: TextAlign.center,
          ),
        ),
      ];
    }
    return [
      for (final d in results) DestinationTile(destination: d, okf: _okf),
    ];
  }
}

/// One search result: icon, title, where it lives, what it is.
class DestinationTile extends StatelessWidget {
  const DestinationTile({super.key, required this.destination, this.okf});

  final AppDestination destination;
  final OkfIndex? okf;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final path = destination.path(l10n);
    final description = destination.describe(l10n, okf);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        hint: l10n.appSearchOpenHint,
        child: ListTile(
          key: ValueKey('search-result-${destination.id}'),
          onTap: () => destination.open(context),
          leading: Icon(destination.icon, color: theme.colorScheme.primary),
          title: Text(
            destination.title(l10n),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                path,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              if (description.isNotEmpty)
                Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
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
    super.key,
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
          child: Icon(icon, color: colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
