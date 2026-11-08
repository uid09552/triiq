import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../client/intervalls/intervalls_client.dart';
import '../../agent/chat_handoff.dart';
import '../../data/feel_prompt_store.dart';
import '../../data/feel_settings.dart';
import '../../data/intervals_session.dart';
import '../../data/models/local_activity.dart';
import '../../data/models/local_wellness.dart';
import '../../data/planned_items.dart';
import '../../data/repositories/wellness_repository.dart';
import '../../data/wellness_actions.dart';
import '../../evaluation/new_training.dart';
import '../../evaluation/session_evaluator.dart';
import '../../evaluation/session_streams.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/charts/chart_viewport.dart';
import '../../widgets/section_card.dart';
import '../../util/dates.dart';
import '../../widgets/main_navigation.dart';
import '../../widgets/stat_tile.dart';
import 'activity_icons.dart';
import 'feel_dialog.dart';
import '../insights/insights_card.dart';
import '../today/train_now_screen.dart';
import '../../evaluation/activity_route.dart';
import 'brick_card.dart';
import '../../evaluation/compare.dart' show isComparable;
import '../compare/compare_screen.dart';
import 'activity_extras_card.dart';
import 'route_card.dart';
import 'session_analysis.dart';

/// One activity's stats, its evaluation against the plan, its streams over
/// time, and a way out to the full analysis on
/// intervals.icu (no power curve, no map here —
/// that is what intervals.icu is for).
class ActivityDetailScreen extends StatefulWidget {
  const ActivityDetailScreen({
    super.key,
    required this.activity,
    this.streams,
    this.routes,
    this.plannedItems,
    this.insights,
    this.seenStore,
    this.wellness,
    this.wellnessActions,
    this.feelSettings,
    this.feelPromptStore,
  });

  final LocalActivity activity;

  /// Test seams; the app uses the defaults.
  final ActivityStreamsRepository? streams;
  final ActivityRouteRepository? routes;
  final PlannedItemsRepository? plannedItems;
  final SessionInsightsLoader? insights;
  final SeenSessionsStore? seenStore;
  final WellnessRepository? wellness;
  final WellnessActions? wellnessActions;
  final FeelSettings? feelSettings;
  final FeelPromptStore? feelPromptStore;

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  LocalActivity get activity => widget.activity;

  SeenSessionsStore get seen => widget.seenStore ?? SeenSessionsStore();
  WellnessRepository get _wellnessRepo =>
      widget.wellness ?? WellnessRepository();
  FeelSettings get _feelSettings =>
      widget.feelSettings ?? FeelSettings.instance;
  FeelPromptStore get _feelPromptStore =>
      widget.feelPromptStore ?? FeelPromptStore.instance;

  /// Today or yesterday — "recent" for the new-activity auto-prompt.
  static bool _isRecent(String date) {
    final today = isoDate(DateTime.now());
    final yesterday = isoDate(DateTime.now().subtract(const Duration(days: 1)));
    return date == today || date == yesterday;
  }

  /// Elapsed seconds under the pointer on the session diagram, shared with
  /// the route map so it can mark the same moment.
  final _cursor = ValueNotifier<double?>(null);

  /// The chart's zoom window, so a tap on an interval can zoom to it.
  final _viewport = ChartViewport();

  LocalWellness? _dayWellness;
  bool _autoPromptHandled = false;

  @override
  void initState() {
    super.initState();
    // Opening today's session counts as seeing it: it won't pop up again.
    if (activity.date == isoDate(DateTime.now())) {
      unawaited(seen.markSeen([activity.id]));
    }
    IntervalsSession.instance.addListener(_onConnectionChanged);
    unawaited(_loadWellnessAndMaybePrompt());
  }

  @override
  void dispose() {
    IntervalsSession.instance.removeListener(_onConnectionChanged);
    _cursor.dispose();
    _viewport.dispose();
    super.dispose();
  }

  void _onConnectionChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadWellnessAndMaybePrompt() async {
    final day = await _wellnessRepo.getByDate(activity.date);
    if (mounted) setState(() => _dayWellness = day);
    await _maybeAutoPrompt(day);
  }

  /// Shows the fatigue/soreness dialog, once, the first time a recent
  /// activity with nothing set yet opens — see
  /// `openspec/specs/fatigue-soreness-log/spec.md`.
  Future<void> _maybeAutoPrompt(LocalWellness? day) async {
    if (_autoPromptHandled) return;
    _autoPromptHandled = true;
    if (!_feelSettings.isLoaded) await _feelSettings.load();
    if (!_feelSettings.promptOnNewActivity) return;
    if (!_isRecent(activity.date)) return;
    if (!_feelPromptStore.isLoaded) await _feelPromptStore.load();
    if (_feelPromptStore.hasPrompted(activity.id)) return;
    if (day?.raw['fatigue'] != null || day?.raw['soreness'] != null) return;
    await _feelPromptStore.recordPrompted(activity.id);
    if (!mounted) return;
    await showFeelDialog(
      context,
      date: activity.date,
      actions: widget.wellnessActions,
    );
    if (mounted) setState(() => _dayWellness = null);
    unawaited(_reloadWellness());
  }

  Future<void> _reloadWellness() async {
    final day = await _wellnessRepo.getByDate(activity.date);
    if (mounted) setState(() => _dayWellness = day);
  }

  Future<void> _openFeelDialog(BuildContext context) async {
    await showFeelDialog(
      context,
      date: activity.date,
      initialFatigue: _dayWellness?.raw['fatigue'] as int?,
      initialSoreness: _dayWellness?.raw['soreness'] as int?,
      actions: widget.wellnessActions,
    );
    await _reloadWellness();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // The columns promoted to LocalActivity cover the list row; everything
    // else (HR, power, zones, ...) comes from re-decoding the full API
    // response, so this screen doesn't need its own SQLite columns for
    // fields only it cares about.
    final full = activity.toActivity();

    final connected = IntervalsSession.instance.isConnected;

    // Tabs that have something for this sport: intervals and a power or pace
    // profile for runs and rides, a map only outdoors.
    final tabs = <_Tab>[
      _Tab.overview,
      _Tab.charts,
      if (isComparable(activity)) _Tab.intervals,
      if (hasRouteMap(activity)) _Tab.map,
    ];

    final overview = <Widget>[
      SessionEvaluationCard(
        activity: activity,
        plannedItems: widget.plannedItems,
        onAskTrainer: (e) => _askTrainer(context, e),
      ),
      const SizedBox(height: 16),
      _StatGrid(activity: activity, full: full),
      if (_hasZoneData(full)) ...[
        const SizedBox(height: 16),
        SectionCard(
          icon: Icons.stacked_bar_chart_outlined,
          title: l10n.timeInZone,
          child: _ZoneTimeChart(zones: _zoneTimes(full)),
        ),
      ],
      const SizedBox(height: 16),
      BrickCard(
        activity: activity,
        loader: BrickLoader(streams: widget.streams),
      ),
      InsightsCard(
        activity: activity,
        loader: widget.insights,
        onFindAlternative: (e) {
          final day = DateTime.tryParse(e.date);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  TrainNowScreen(today: day == null ? null : () => day),
            ),
          );
        },
      ),
    ];
    final charts = <Widget>[
      SessionDiagramCard(
        activity: activity,
        streams: widget.streams,
        viewport: _viewport,
        showIntervalList: false,
        onCursorSeconds: (s) => _cursor.value = s,
      ),
      const SizedBox(height: 16),
      if (isComparable(activity))
        ActivityExtrasCard(
          activity: activity,
          streams: widget.streams,
          part: ExtrasPart.profile,
        ),
    ];
    Widget intervals(VoidCallback? showCharts) => ActivityExtrasCard(
      activity: activity,
      streams: widget.streams,
      part: ExtrasPart.intervals,
      onIntervalTap: (i) {
        showCharts?.call();
        final pad = (i.end - i.start) * 0.15 + 5;
        _viewport.setRange(i.start - pad, i.end + pad);
      },
    );
    final map = ActivityRouteCard(
      activity: activity,
      routes: widget.routes,
      cursor: _cursor,
    );

    Widget list(List<Widget> children) => ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: children,
    );

    final appBar = AppBar(
      title: Text(l10n.titleActivity),
      actions: [
        if (isComparable(activity))
          IconButton(
            key: const ValueKey('compare-action'),
            tooltip: l10n.cmpCompareWith,
            icon: const Icon(Icons.compare_arrows),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => CompareScreen(initialActivity: activity),
              ),
            ),
          ),
        PopupMenuButton<String>(
          key: const ValueKey('activity-menu'),
          tooltip: l10n.actMoreActions,
          onSelected: (choice) => switch (choice) {
            'feel' => _openFeelDialog(context),
            'intervals' => _openInIntervals(context),
            _ => null,
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              key: const ValueKey('feel-action'),
              value: 'feel',
              enabled: connected,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.mood_outlined),
                title: Text(l10n.feelActionLabel),
                subtitle: connected ? null : Text(l10n.feelNotConnectedHint),
              ),
            ),
            PopupMenuItem(
              key: const ValueKey('open-intervals-action'),
              value: 'intervals',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.open_in_new),
                title: Text(l10n.openInIntervals),
              ),
            ),
          ],
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Wide (Windows, tablets): no tabs — the overview and intervals on
        // the left, the chart above the map on the right, so the tracker is
        // visible on both at once.
        if (constraints.maxWidth >= 900) {
          return Scaffold(
            appBar: appBar,
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _Header(activity: activity),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: list([
                          ...overview,
                          if (tabs.contains(_Tab.intervals)) intervals(null),
                        ]),
                      ),
                      Expanded(
                        child: list([
                          ...charts,
                          if (tabs.contains(_Tab.map)) map,
                        ]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return DefaultTabController(
          length: tabs.length,
          child: Builder(
            builder: (context) {
              final controller = DefaultTabController.of(context);
              void showCharts() =>
                  controller.animateTo(tabs.indexOf(_Tab.charts));
              return Scaffold(
                appBar: appBar,
                body: NestedScrollView(
                  headerSliverBuilder: (context, _) => [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: _Header(activity: activity),
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _TabBarHeader(
                        TabBar(
                          key: const ValueKey('activity-tabs'),
                          isScrollable: tabs.length > 3,
                          tabAlignment: tabs.length > 3
                              ? TabAlignment.start
                              : TabAlignment.fill,
                          tabs: [
                            for (final t in tabs)
                              Tab(
                                key: ValueKey('tab-${t.name}'),
                                text: switch (t) {
                                  _Tab.overview => l10n.actTabOverview,
                                  _Tab.charts => l10n.actTabCharts,
                                  _Tab.intervals => l10n.actTabIntervals,
                                  _Tab.map => l10n.actTabMap,
                                },
                              ),
                          ],
                        ),
                        Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ],
                  body: TabBarView(
                    children: [
                      for (final t in tabs)
                        switch (t) {
                          _Tab.overview => list(overview),
                          _Tab.charts => list(charts),
                          _Tab.intervals => list([intervals(showCharts)]),
                          _Tab.map => list([map]),
                        },
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Opens Chat about this session, with its figures and evaluation as
  /// the agent's context.
  void _askTrainer(BuildContext context, SessionEvaluation e) {
    final l10n = AppLocalizations.of(context)!;
    final split = e.split;
    final plan = e.plan;
    ChatHandoff.instance.open(
      ChatTopic(
        title: activity.name ?? activity.type ?? 'session',
        context: jsonEncode({
          'activity': {
            'id': activity.id,
            'date': activity.date,
            'sport': activity.type,
            'name': activity.name,
            'minutes': activity.movingTime == null
                ? null
                : (activity.movingTime! / 60).round(),
            'tss': activity.trainingLoad,
          },
          'evaluation': {
            'verdict': e.verdict?.name,
            'intent': e.intent.name,
            if (split != null)
              'intensity_seconds': {
                'low': split.low,
                'moderate': split.moderate,
                'high': split.high,
                'source': split.source,
              },
            'decoupling_percent': e.decouplingPercent,
            if (plan != null)
              'planned': {
                'name': plan.planned.name,
                'minutes': plan.plannedMinutes,
                'tss': plan.plannedLoad,
              },
          },
          'note':
              'Computed by the app (session evaluation). Use these figures; '
              'do not recompute them.',
        }),
        draft: l10n.activityChatDraft(
          activity.name ?? activity.type ?? l10n.activityFallback,
          activity.date,
        ),
      ),
    );
    Navigator.of(context).popUntil((route) => route.isFirst);
    MainNavigation.instance.openTab(MainNavigation.chatTab);
  }

  Future<void> _openInIntervals(BuildContext context) async {
    final uri = Uri.parse('https://intervals.icu/activities/${activity.id}');
    // externalApplication: hand off to the OS rather than an in-app
    // webview, so it opens the Intervals.icu app if one is installed and
    // registered for that link (Android App Links / iOS Universal Links)
    // and falls back to the browser otherwise — the same choice the OS
    // would make for any link tapped outside this app.
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.couldNotOpenUrl(uri.toString()),
          ),
        ),
      );
    }
  }

  static bool _hasZoneData(Activity full) =>
      (full.icuZoneTimes?.isNotEmpty ?? false) ||
      (full.icuHrZoneTimes?.isNotEmpty ?? false);

  /// Prefers `icuZoneTimes` (self-labelled, usually power zones) over
  /// `icuHrZoneTimes` (a plain seconds-per-zone list — falls back to
  /// generic Z1..Zn labels since it has none of its own).
  static List<(String label, int secs)> _zoneTimes(Activity full) {
    final named = full.icuZoneTimes;
    if (named != null && named.isNotEmpty) {
      return [for (final zone in named) (zone.id ?? '?', zone.secs ?? 0)];
    }
    final hr = full.icuHrZoneTimes ?? const [];
    return [for (var i = 0; i < hr.length; i++) ('Z${i + 1}', hr[i])];
  }
}

/// The curated set of extra numbers worth a tile, built from whichever of
/// [full]'s many fields are actually present for this activity — a swim
/// won't have power, a strength session won't have distance.
class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.activity, required this.full});

  final LocalActivity activity;
  final Activity full;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final tiles = <StatTile>[
      if (activity.distance != null && activity.distance! > 0)
        StatTile(
          label: l10n.distanceLabel,
          value: formatDistanceMeters(activity.distance!),
          icon: Icons.straighten_outlined,
          color: colorScheme.primary,
        ),
      if (activity.movingTime != null && activity.movingTime! > 0)
        StatTile(
          label: l10n.durationLabel,
          value: formatDurationSecs(activity.movingTime!),
          icon: Icons.timer_outlined,
          color: colorScheme.tertiary,
        ),
      if (activity.trainingLoad != null)
        StatTile(
          label: l10n.tssSuffix,
          value: '${activity.trainingLoad}',
          icon: Icons.bolt_outlined,
          color: colorScheme.secondary,
        ),
      if (full.totalElevationGain != null && full.totalElevationGain! > 0)
        StatTile(
          label: l10n.elevationGainLabel,
          value: '${full.totalElevationGain!.round()} m',
          icon: Icons.terrain_outlined,
          color: colorScheme.primary,
        ),
      if (full.averageHeartrate != null)
        StatTile(
          label: l10n.avgHrLabel,
          value: '${full.averageHeartrate!.round()} bpm',
          icon: Icons.favorite_outline,
          color: colorScheme.error,
        ),
      if (full.maxHeartrate != null)
        StatTile(
          label: l10n.maxHrLabel,
          value: '${full.maxHeartrate} bpm',
          icon: Icons.favorite,
          color: colorScheme.error,
        ),
      if (full.icuWeightedAvgWatts != null)
        StatTile(
          label: l10n.avgPowerNpLabel,
          value: '${full.icuWeightedAvgWatts} W',
          icon: Icons.flash_on_outlined,
          color: colorScheme.tertiary,
        )
      else if (full.icuAverageWatts != null)
        StatTile(
          label: l10n.avgPowerLabel,
          value: '${full.icuAverageWatts} W',
          icon: Icons.flash_on_outlined,
          color: colorScheme.tertiary,
        ),
      if (full.calories != null)
        StatTile(
          label: l10n.caloriesLabel,
          value: '${full.calories}',
          icon: Icons.local_fire_department_outlined,
          color: colorScheme.secondary,
        ),
    ];

    if (tiles.isEmpty) return const SizedBox.shrink();

    // Taller tiles as the text grows, so a 200 % font still fits.
    final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.95 / (textScale < 1 ? 1 : textScale),
      children: tiles,
    );
  }
}

/// A simple horizontal-bar "time in zone" chart. Hand-rolled rather than a
/// charting package — it's one bar shape, and this app doesn't use a chart
/// library anywhere else yet.
class _ZoneTimeChart extends StatelessWidget {
  const _ZoneTimeChart({required this.zones});

  final List<(String label, int secs)> zones;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final maxSecs = zones.fold<int>(
      0,
      (max, zone) => zone.$2 > max ? zone.$2 : max,
    );
    if (maxSecs == 0) return const SizedBox.shrink();

    return Column(
      children: [
        for (var i = 0; i < zones.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _ZoneBar(
            label: zones[i].$1,
            secs: zones[i].$2,
            fraction: zones[i].$2 / maxSecs,
            color: colorScheme.primary.withValues(
              alpha: 0.35 + 0.65 * (i + 1) / zones.length,
            ),
          ),
        ],
      ],
    );
  }
}

class _ZoneBar extends StatelessWidget {
  const _ZoneBar({
    required this.label,
    required this.secs,
    required this.fraction,
    required this.color,
  });

  final String label;
  final int secs;
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        SizedBox(
          width: 36,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                children: [
                  Container(
                    height: 18,
                    color: colorScheme.surfaceContainerHighest,
                  ),
                  Container(
                    height: 18,
                    width: constraints.maxWidth * fraction.clamp(0.0, 1.0),
                    color: color,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 48,
          child: Text(
            formatDurationSecs(secs),
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

enum _Tab { overview, charts, intervals, map }

/// The pinned tab bar under the summary header.
class _TabBarHeader extends SliverPersistentHeaderDelegate {
  _TabBarHeader(this.tabBar, this.background);

  final TabBar tabBar;
  final Color background;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) =>
      Material(color: background, child: tabBar);

  @override
  bool shouldRebuild(_TabBarHeader old) =>
      old.tabBar != tabBar || old.background != background;
}

/// Name, sport, date and the key figures — what the session was, before
/// any detail.
class _Header extends StatelessWidget {
  const _Header({required this.activity});

  final LocalActivity activity;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final figures = [
      if (activity.movingTime != null) formatDurationSecs(activity.movingTime!),
      if (activity.distance != null && activity.distance! > 0)
        formatDistanceMeters(activity.distance!),
      if (activity.trainingLoad != null) '${activity.trainingLoad} TSS',
    ];
    return Container(
      key: const ValueKey('activity-header'),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.tertiary],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              activityTypeIcon(activity.type),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.name ?? activity.type ?? l10n.activityFallback,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  [
                    formatIsoDate(activity.date),
                    if (activity.type != null) activity.type!,
                  ].join(' · '),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                if (figures.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    figures.join('   ·   '),
                    key: const ValueKey('activity-figures'),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
