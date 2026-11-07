import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../data/intervals_session.dart';
import '../../data/models/local_activity.dart';
import '../../data/planned_items.dart';
import '../../data/repositories/activities_repository.dart';
import '../../data/repositories/wellness_repository.dart';
import '../../data/sync/auto_sync_service.dart';
import '../../data/sync/sync_settings.dart';
import '../../data/sync/sync_service.dart';
import '../../l10n/app_localizations.dart';
import '../../plan/plan_changes.dart';
import '../../util/dates.dart';
import '../../util/intervals_links.dart';
import '../../widgets/charts/bar_chart.dart';
import '../../widgets/charts/line_chart.dart';
import '../../widgets/chart_options.dart';
import '../../widgets/section_card.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/sync_status_chip.dart';
import '../../widgets/stat_tile.dart';
import '../activities/activities_screen.dart';
import '../activities/activity_icons.dart';
import 'analytics_screen.dart';
import '../compare/compare_screen.dart';
import 'load_heatmap_screen.dart';
import 'performance_screen.dart';
import 'wellness_trends_screen.dart';

/// Training-load trends and volume, all of it read from the local cache:
/// the CTL/ATL curve over the chosen window, completed-vs-planned load per
/// week, distance and time for the week/month/year to date, and what each
/// sport contributed.
///
/// The range picker only changes what is charted — nothing here fetches, so
/// it stays instant and works offline. Pull to refresh re-syncs the current
/// month through the same throttled path Today's pull uses, then reloads.
/// Tapping a sport opens the Activities list filtered to it.
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  static const _rangeOptions = [30, 90, 365];

  final _session = IntervalsSession.instance;
  final _syncService = SyncService();
  final _activitiesRepository = ActivitiesRepository();
  final _eventsRepository = PlannedItemsRepository();
  final _wellnessRepository = WellnessRepository();

  int _days = 90;
  bool _loading = true;

  List<({DateTime date, double? ctl, double? atl})> _fitness = const [];
  List<({DateTime start, int completed, int planned})> _weeks = const [];
  List<_SportTotals> _sports = const [];
  int _selectedWeek = -1;

  _Volume _week = _Volume.empty;
  _Volume _month = _Volume.empty;
  _Volume _year = _Volume.empty;

  @override
  void initState() {
    super.initState();
    _session.addListener(_load);
    AutoSyncService.instance.addListener(_load);
    PlanChanges.instance.addListener(_load);
    SyncSettings.instance.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    _session.removeListener(_load);
    AutoSyncService.instance.removeListener(_load);
    PlanChanges.instance.removeListener(_load);
    SyncSettings.instance.removeListener(_load);
    super.dispose();
  }

  Future<void> _refreshFromGesture() async {
    try {
      // Same throttled, non-overlapping, timed-out fetch Today's pull runs:
      // it joins one already in flight rather than starting a second, and
      // no-ops when disconnected or within
      // `SyncService.refreshMinGap` of the last one.
      await _syncService.refreshMonthWindow();
    } catch (_) {
      // Reading the cache is still worth doing when the network isn't
      // there; the Sync screen is where sync errors belong.
    }
    await _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);

    final today = dateOnly(DateTime.now());
    final rangeStart = today.subtract(Duration(days: _days - 1));
    final yearStart = DateTime(today.year, 1, 1);

    // One read covering the widest window anything on this screen needs.
    final earliest = rangeStart.isBefore(yearStart) ? rangeStart : yearStart;
    final activities = await _activitiesRepository.getRange(
      isoDate(earliest),
      isoDate(today),
    );
    final events = await _eventsRepository.getRange(
      isoDate(rangeStart),
      isoDate(today),
    );
    final wellness = await _wellnessRepository.getRange(
      isoDate(rangeStart),
      isoDate(today),
    );

    final wellnessByDate = {for (final record in wellness) record.date: record};
    final fitness = [
      for (var i = 0; i < _days; i++)
        () {
          final date = rangeStart.add(Duration(days: i));
          final record = wellnessByDate[isoDate(date)];
          return (date: date, ctl: record?.ctl, atl: record?.atl);
        }(),
    ];

    // Weekly buckets across the range, so a partial first week doesn't get
    // its own misleading bar.
    final firstWeek = startOfWeek(rangeStart.add(const Duration(days: 6)));
    final weekCount =
        (dateOnly(startOfWeek(today)).difference(firstWeek).inDays ~/ 7) + 1;
    final completedByWeek = <String, int>{};
    final plannedByWeek = <String, int>{};
    for (final activity in activities) {
      final date = DateTime.parse(activity.date);
      if (date.isBefore(firstWeek)) continue;
      completedByWeek.update(
        isoDate(startOfWeek(date)),
        (sum) => sum + (activity.trainingLoad ?? 0),
        ifAbsent: () => activity.trainingLoad ?? 0,
      );
    }
    for (final event in events.where((e) => e.isTraining)) {
      final date = DateTime.parse(event.date);
      if (date.isBefore(firstWeek)) continue;
      plannedByWeek.update(
        isoDate(startOfWeek(date)),
        (sum) => sum + (event.plannedLoad ?? 0),
        ifAbsent: () => event.plannedLoad ?? 0,
      );
    }
    final weeks = [
      for (var i = 0; i < weekCount; i++)
        () {
          final start = firstWeek.add(Duration(days: 7 * i));
          return (
            start: start,
            completed: completedByWeek[isoDate(start)] ?? 0,
            planned: plannedByWeek[isoDate(start)] ?? 0,
          );
        }(),
    ];

    final inRange = activities
        .where((a) => a.date.compareTo(isoDate(rangeStart)) >= 0)
        .toList();
    final bySport = <String, _SportTotals>{};
    for (final activity in inRange) {
      final sport = activity.type ?? _SportTotals.unknownSport;
      bySport[sport] = (bySport[sport] ?? _SportTotals(sport: sport)).plus(
        activity,
      );
    }

    if (!mounted) return;
    setState(() {
      _fitness = fitness;
      _weeks = weeks;
      _selectedWeek = -1;
      _sports = bySport.values.toList()
        ..sort((a, b) => b.seconds.compareTo(a.seconds));
      _week = _Volume.of(activities, from: startOfWeek(today));
      _month = _Volume.of(
        activities,
        from: DateTime(today.year, today.month, 1),
      );
      _year = _Volume.of(activities, from: yearStart);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    final series = <ChartSeries>[
      ChartSeries(
        label: l10n.ctlLabel,
        color: colorScheme.tertiary,
        values: [for (final point in _fitness) point.ctl],
        fill: true,
      ),
      ChartSeries(
        label: l10n.atlLabel,
        color: colorScheme.secondary,
        values: [for (final point in _fitness) point.atl],
      ),
    ];
    final hasFitness = _fitness.any((point) => point.ctl != null);
    final totalSeconds = _sports.fold<int>(0, (sum, s) => sum + s.seconds);
    final hasWeeks = _weeks.any(
      (week) => week.completed > 0 || week.planned > 0,
    );

    return RefreshIndicator(
      onRefresh: _refreshFromGesture,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              SyncStatusChip(),
              const Spacer(),
              ChartOptionsButton(
                summary: _days == 365
                    ? l10n.rangeOneYear
                    : l10n.rangeDaysShort(_days),
                onPressed: () => showChartOptions(
                  context,
                  title: l10n.navStatistics,
                  ownerSetState: setState,
                  builder: (sheet, apply) => OptionGroup(
                    label: l10n.chartOptionsRange,
                    child: SegmentedButton<int>(
                      showSelectedIcon: false,
                      segments: [
                        for (final days in _rangeOptions)
                          ButtonSegment(
                            value: days,
                            label: Text(
                              days == 365
                                  ? l10n.rangeOneYear
                                  : l10n.rangeDaysShort(days),
                            ),
                          ),
                      ],
                      selected: {_days},
                      onSelectionChanged: (selection) {
                        apply(() => _days = selection.first);
                        _load();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.trending_up),
              title: Text(l10n.performanceTitle),
              subtitle: Text(l10n.performanceSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PerformanceScreen(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.insights_outlined),
              title: Text(l10n.anTitle),
              subtitle: Text(l10n.anSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AnalyticsScreen(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.grid_view_rounded),
              title: Text(l10n.hmTitle),
              subtitle: Text(l10n.hmSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => LoadHeatmapScreen()),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.monitor_heart_outlined),
              title: Text(l10n.wtTitle),
              subtitle: Text(l10n.wtSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => WellnessTrendsScreen()),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.compare_arrows),
              title: Text(l10n.cmpTitle),
              subtitle: Text(l10n.cmpSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const CompareScreen()),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            icon: Icons.show_chart,
            title: l10n.fitnessTrendTitle,
            child: _loading
                ? const _ChartPlaceholder()
                : !hasFitness
                ? _EmptyChart(
                    message: _session.isConnected
                        ? l10n.noDataCachedForRange
                        : l10n.statsNotConnected,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 190,
                        child: MetricLineChart(
                          series: series,
                          labels: [
                            for (final point in _fitness)
                              DateFormat.MMMd(locale).format(point.date),
                          ],
                          labelEvery: (_fitness.length / 4).ceil(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ChartLegend(series: series),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            icon: Icons.bar_chart_outlined,
            title: l10n.completedVsPlanned,
            child: _loading
                ? const _ChartPlaceholder()
                : !hasWeeks
                ? _EmptyChart(
                    message: _session.isConnected
                        ? l10n.noDataCachedForRange
                        : l10n.statsNotConnected,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedWeek >= 0
                            ? l10n.selectedWeekLoad(
                                DateFormat.MMMd(
                                  locale,
                                ).format(_weeks[_selectedWeek].start),
                                _weeks[_selectedWeek].completed,
                                _weeks[_selectedWeek].planned,
                              )
                            : l10n.tapBarForWeek,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 180,
                        child: SimpleBarChart(
                          bars: [
                            for (final week in _weeks)
                              ChartBar(
                                label: DateFormat.Md(locale).format(week.start),
                                value: week.completed.toDouble(),
                                target: week.planned > 0
                                    ? week.planned.toDouble()
                                    : null,
                                highlighted: week == _weeks.last,
                              ),
                          ],
                          selectedIndex: _selectedWeek < 0
                              ? null
                              : _selectedWeek,
                          onSelect: (index) =>
                              setState(() => _selectedWeek = index),
                          labelEvery: (_weeks.length / 6).ceil().clamp(1, 12),
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            icon: Icons.route_outlined,
            title: l10n.volumeTitle,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        label: l10n.thisWeek,
                        value: _week.distanceLabel,
                        subtitle: _week.timeLabel,
                        icon: Icons.calendar_view_week,
                        color: colorScheme.primary,
                        onLongPress: () => showOpenInIntervalsSheet(
                          context,
                          label: l10n.thisWeek,
                          path: 'activities',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatTile(
                        label: l10n.thisMonth,
                        value: _month.distanceLabel,
                        subtitle: _month.timeLabel,
                        icon: Icons.calendar_view_month,
                        color: colorScheme.tertiary,
                        onLongPress: () => showOpenInIntervalsSheet(
                          context,
                          label: l10n.thisMonth,
                          path: 'activities',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatTile(
                        label: l10n.thisYear,
                        value: _year.distanceLabel,
                        subtitle: _year.timeLabel,
                        icon: Icons.calendar_today_outlined,
                        color: colorScheme.secondary,
                        onLongPress: () => showOpenInIntervalsSheet(
                          context,
                          label: l10n.thisYear,
                          path: 'activities',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            icon: Icons.pie_chart_outline,
            title: l10n.bySportTitle,
            child: _sports.isEmpty
                ? Text(
                    _session.isConnected
                        ? l10n.noDataCachedForRange
                        : l10n.statsNotConnected,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  )
                : Column(
                    children: [
                      for (final sport in _sports)
                        _SportRow(
                          totals: sport,
                          // Share of time, not of load: load isn't
                          // comparable across sports.
                          shareOfTime: totalSeconds == 0
                              ? 0
                              : sport.seconds / totalSeconds,
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Distance and moving time since a start date.
class _Volume {
  const _Volume({required this.meters, required this.seconds});

  static const empty = _Volume(meters: 0, seconds: 0);

  final double meters;
  final int seconds;

  factory _Volume.of(List<LocalActivity> activities, {required DateTime from}) {
    final start = isoDate(dateOnly(from));
    var meters = 0.0;
    var seconds = 0;
    for (final activity in activities) {
      if (activity.date.compareTo(start) < 0) continue;
      meters += activity.distance ?? 0;
      seconds += activity.movingTime ?? 0;
    }
    return _Volume(meters: meters, seconds: seconds);
  }

  String get distanceLabel =>
      meters <= 0 ? '—' : '${(meters / 1000).toStringAsFixed(0)} km';

  String get timeLabel =>
      seconds <= 0 ? '—' : '${(seconds / 3600).toStringAsFixed(1)} h';
}

class _SportTotals {
  const _SportTotals({
    required this.sport,
    this.sessions = 0,
    this.seconds = 0,
    this.meters = 0,
    this.load = 0,
  });

  /// Bucket for activities Intervals.icu gave no type — there is nothing
  /// to filter the Activities list by, so this row doesn't open one.
  static const unknownSport = '—';

  final String sport;
  final int sessions;
  final int seconds;
  final double meters;
  final int load;

  bool get hasType => sport != unknownSport;

  _SportTotals plus(LocalActivity activity) => _SportTotals(
    sport: sport,
    sessions: sessions + 1,
    seconds: seconds + (activity.movingTime ?? 0),
    meters: meters + (activity.distance ?? 0),
    load: load + (activity.trainingLoad ?? 0),
  );
}

/// One sport's contribution, with a bar showing its share of total time —
/// the "where does my training actually go" line.
class _SportRow extends StatelessWidget {
  const _SportRow({required this.totals, required this.shareOfTime});

  final _SportTotals totals;
  final double shareOfTime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      // The obvious follow-up question from "40% of my time is running" is
      // "which runs?" — so the row is the way into that list.
      onTap: totals.hasType
          ? () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ActivitiesScreen(initialType: totals.sport),
              ),
            )
          : null,
      onLongPress: () => showOpenInIntervalsSheet(
        context,
        label: totals.sport,
        path: 'activities',
      ),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  activityTypeIcon(totals.sport),
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    totals.sport,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  '${(shareOfTime * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (totals.hasType)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: shareOfTime.clamp(0, 1),
                minHeight: 6,
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              [
                l10n.sessionsCount(totals.sessions),
                formatDurationSecs(totals.seconds),
                if (totals.meters > 0) formatDistanceMeters(totals.meters),
                '${totals.load} ${l10n.tssSuffix}',
              ].join(' · '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The chart-shaped hole a card shows while its data is being read, so the
/// screen doesn't jump around as each card resolves.
class _ChartPlaceholder extends StatelessWidget {
  const _ChartPlaceholder();

  @override
  Widget build(BuildContext context) => const Skeleton(height: 190, radius: 14);
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 160,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.primary.withValues(alpha: 0.12),
            colorScheme.primary.withValues(alpha: 0.02),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insights_outlined,
            size: 32,
            color: colorScheme.primary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 8),
          Text(message, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
