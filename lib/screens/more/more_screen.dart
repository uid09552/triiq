import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../navigation/app_destinations.dart';
import '../../navigation/nav_items.dart';
import '../../navigation/navigation_layout.dart';
import '../../navigation/okf_index.dart';
import '../../widgets/peek_cards.dart';
import '../../widgets/peekable.dart';
import '../events/events_screen.dart';
import '../info/info_screen.dart';
import '../knowledge/knowledge_library_screen.dart';
import '../memory/memory_screen.dart';
import '../plan/applied_changes_screen.dart';
import '../plan/plan_screen.dart';
import '../settings/settings_screen.dart';
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
    id: 'changes',
    group: MoreGroup.plan,
    icon: Icons.history,
    title: (l) => l.changesTitle,
    subtitle: (l) => l.moreChangesSubtitle,
    builder: (_) => const AppliedChangesScreen(),
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
  MoreEntry(
    id: 'info',
    group: MoreGroup.data,
    icon: Icons.info_outline,
    title: (l) => l.infoTitle,
    subtitle: (l) => l.moreInfoSubtitle,
    builder: (_) => const InfoScreen(),
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
  const MoreScreen({super.key, this.okf, this.destinations, this.layout});

  /// Test seam: where the okf text the search also matches comes from.
  final Future<OkfIndex>? okf;

  /// Test seam: what the search covers (default: [appDestinations]).
  final List<AppDestination>? destinations;

  /// Test seam (default: [NavigationLayout.instance]): what More lists and
  /// in which order — everything that is not in the bottom bar.
  final NavigationLayout? layout;

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
        if (!searching)
          _MoreTile(
            key: const ValueKey('more-settings'),
            icon: Icons.settings_outlined,
            title: l10n.titleSettings,
            subtitle: l10n.searchDescSettings,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
        if (searching)
          ..._results(context, l10n)
        else
          ListenableBuilder(
            listenable: _layout,
            builder: (context, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _entries(context, l10n),
            ),
          ),
      ],
    );
  }

  NavigationLayout get _layout => widget.layout ?? NavigationLayout.instance;

  /// Everything not in the bottom bar, in the athlete's order. The group
  /// headers (Main sections, Plan, Trainer, Data) show while each group's
  /// items stay together — as shipped; an order that mixes them is one
  /// plain list.
  List<Widget> _entries(BuildContext context, AppLocalizations l10n) {
    final items = [for (final id in _layout.more) navItem(id)];
    String? groupOf(NavItem i) => i.entry?.group.name;
    final groups = [for (final i in items) groupOf(i)];
    var grouped = true;
    for (var i = 0; i < groups.length; i++) {
      final first = groups.indexOf(groups[i]);
      if (first != i && groups[i - 1] != groups[i]) grouped = false;
    }
    return [
      for (var i = 0; i < items.length; i++) ...[
        if (grouped && (i == 0 || groups[i - 1] != groups[i]))
          _GroupHeader(
            items[i].entry == null
                ? l10n.moreGroupMain
                : moreGroupTitle(l10n, items[i].entry!.group),
          ),
        _MoreTile(
          key: ValueKey('more-${items[i].id}'),
          icon: items[i].icon,
          title: items[i].title(l10n),
          subtitle: _subtitle(l10n, items[i]),
          onTap: () => openNavItem(context, items[i].id, layout: _layout),
        ),
      ],
    ];
  }

  static String _subtitle(AppLocalizations l10n, NavItem item) =>
      item.entry?.subtitle(l10n) ??
      switch (item.id) {
        'today' => l10n.searchDescToday,
        'calendar' => l10n.searchDescCalendar,
        'chat' => l10n.searchDescChat,
        'insights' => l10n.searchDescInsights,
        _ => '',
      };

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
    // Hold a result to read more of what the app docs say about it.
    final excerpt = okf == null
        ? description
        : OkfIndex.trimToSentence(
            OkfIndex.userText(okf!.resolve(destination.okfAnchor) ?? ''),
            520,
          );
    return Peekable(
      preview: (_) => TextPeek(
        icon: destination.icon,
        title: destination.title(l10n),
        path: path,
        text: excerpt.isEmpty ? description : excerpt,
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Semantics(
          hint: l10n.appSearchOpenHint,
          child: ListTile(
            key: ValueKey('search-result-${destination.id}'),
            onTap: () => destination.open(context),
            leading: Icon(destination.icon, color: theme.colorScheme.primary),
            title: Text(
              destination.title(l10n),
              style: const TextStyle(fontWeight: FontWeight.w500),
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
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
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
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
