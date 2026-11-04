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
  WellnessRepository get _wellnessRepo => widget.wellness ?? WellnessRepository();
  FeelSettings get _feelSettings => widget.feelSettings ?? FeelSettings.instance;
  FeelPromptStore get _feelPromptStore =>
      widget.feelPromptStore ?? FeelPromptStore.instance;

  /// Today or yesterday — "recent" for the new-activity auto-prompt.
  static bool _isRecent(String date) {
    final today = isoDate(DateTime.now());
    final yesterday = isoDate(DateTime.now().subtract(const Duration(days: 1)));
    return date == today || date == yesterday;
  }

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
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    // The columns promoted to LocalActivity cover the list row; everything
    // else (HR, power, zones, ...) comes from re-decoding the full API
    // response, so this screen doesn't need its own SQLite columns for
    // fields only it cares about.
    final full = activity.toActivity();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleActivity)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colorScheme.primary, colorScheme.tertiary],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    activityTypeIcon(activity.type),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.name ?? activity.type ?? l10n.activityFallback,
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          formatIsoDate(activity.date),
                          if (activity.type != null) activity.type!,
                        ].join(' · '),
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
          SessionEvaluationCard(
            activity: activity,
            plannedItems: widget.plannedItems,
            onAskTrainer: (e) => _askTrainer(context, e),
          ),
          const SizedBox(height: 16),
          SessionDiagramCard(activity: activity, streams: widget.streams),
          const SizedBox(height: 16),
          ActivityRouteCard(activity: activity, routes: widget.routes),
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
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () => _openInIntervals(context),
                icon: const Icon(Icons.open_in_new),
                label: Text(l10n.openInIntervals),
              ),
              Tooltip(
                message: IntervalsSession.instance.isConnected
                    ? ''
                    : l10n.feelNotConnectedHint,
                child: FilledButton.tonalIcon(
                  key: const ValueKey('feel-action'),
                  onPressed: IntervalsSession.instance.isConnected
                      ? () => _openFeelDialog(context)
                      : null,
                  icon: const Icon(Icons.mood_outlined),
                  label: Text(l10n.feelActionLabel),
                ),
              ),
            ],
          ),
        ],
      ),
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
      return [
        for (final zone in named) (zone.id ?? '?', zone.secs ?? 0),
      ];
    }
    final hr = full.icuHrZoneTimes ?? const [];
    return [
      for (var i = 0; i < hr.length; i++) ('Z${i + 1}', hr[i]),
    ];
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

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.95,
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
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
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
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
