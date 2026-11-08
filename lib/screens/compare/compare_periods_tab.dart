import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../data/models/local_activity.dart';
import '../../data/repositories/activities_repository.dart';
import '../../evaluation/compare.dart';
import '../../l10n/app_localizations.dart';
import '../../util/dates.dart';
import '../../widgets/chart_options.dart';
import '../../widgets/charts/line_chart.dart';
import '../../widgets/section_card.dart';
import '../../widgets/skeleton.dart';
import 'compare_route_map.dart' show compareColorA, compareColorB;
import 'compare_table.dart';
import '../../widgets/status_message.dart';

enum _Cumulative { distance, load, time }

/// This block of training against the one before it, for runs or rides:
/// the same figures for both (sessions, distance, time, elevation, load,
/// pace / speed, power, heart rate, efficiency, decoupling, easy share),
/// the change between them, and a day-by-day cumulative line for each.
class ComparePeriodsTab extends StatefulWidget {
  ComparePeriodsTab({super.key, ActivitiesRepository? activities, this.today})
    : activities = activities ?? ActivitiesRepository();

  final ActivitiesRepository activities;

  /// The last day of the current block; defaults to today.
  final DateTime? today;

  @override
  State<ComparePeriodsTab> createState() => _ComparePeriodsTabState();
}

class _ComparePeriodsTabState extends State<ComparePeriodsTab> {
  static const _lengths = [7, 14, 28, 56];

  int _days = 28;
  String _sport = 'ride';
  _Cumulative _metric = _Cumulative.distance;
  bool _loading = true;
  List<LocalActivity> _activities = const [];

  DateTime get _end => dateOnly(widget.today ?? DateTime.now());

  @override
  void initState() {
    super.initState();
    _load();
  }

  Object? _error;

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final pair = BlockPair(end: _end, days: _days);
    try {
      final rows = await widget.activities.getRange(
        isoDate(pair.previousStart),
        isoDate(pair.currentEnd),
      );
      if (!mounted) return;
      setState(() {
        _activities = rows;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  void _openOptions(BuildContext context, AppLocalizations l10n) {
    showChartOptions(
      context,
      title: l10n.cmpTabPeriods,
      ownerSetState: setState,
      builder: (sheet, apply) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OptionGroup(
            label: l10n.chartOptionsSport,
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: 'ride', label: Text(l10n.anSportRide)),
                ButtonSegment(value: 'run', label: Text(l10n.anSportRun)),
              ],
              selected: {_sport},
              onSelectionChanged: (s) => apply(() => _sport = s.first),
            ),
          ),
          OptionGroup(
            label: l10n.chartOptionsBlock,
            child: SegmentedButton<int>(
              showSelectedIcon: false,
              segments: [
                for (final d in _lengths)
                  ButtonSegment(value: d, label: Text(l10n.rangeDaysShort(d))),
              ],
              selected: {_days},
              onSelectionChanged: (s) {
                apply(() => _days = s.first);
                _load();
              },
            ),
          ),
          OptionGroup(
            label: l10n.cmpCumulative,
            child: SegmentedButton<_Cumulative>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: _Cumulative.distance,
                  label: Text(l10n.cmpDistance),
                ),
                ButtonSegment(
                  value: _Cumulative.time,
                  label: Text(l10n.cmpTime),
                ),
                ButtonSegment(
                  value: _Cumulative.load,
                  label: Text(l10n.cmpLoad),
                ),
              ],
              selected: {_metric},
              onSelectionChanged: (s) => apply(() => _metric = s.first),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final pair = BlockPair(end: _end, days: _days);
    final sportActivities = ofSport(_activities, _sport).toList();
    final previous = [
      for (final a in sportActivities)
        if (pair.inPrevious(a.date)) a,
    ];
    final current = [
      for (final a in sportActivities)
        if (pair.inCurrent(a.date)) a,
    ];
    final prevStats = blockStats(previous);
    final curStats = blockStats(current);
    String range(DateTime a, DateTime b) => l10n.cmpBlockRange(
      DateFormat.MMMd(locale).format(a),
      DateFormat.MMMd(locale).format(b),
    );

    double Function(LocalActivity) pick() => switch (_metric) {
      _Cumulative.distance => (a) => (a.distance ?? 0) / 1000,
      _Cumulative.load => (a) => (a.trainingLoad ?? 0).toDouble(),
      _Cumulative.time => (a) => (a.movingTime ?? 0) / 3600,
    };
    final cumPrev = cumulativeByDay(
      previous,
      pair.previousStart,
      _days,
      pick(),
    );
    final cumCur = cumulativeByDay(
      current,
      pair.currentStart,
      _days,
      pick(),
      end: pair.currentEnd,
    );
    final unit = switch (_metric) {
      _Cumulative.distance => 'km',
      _Cumulative.load => 'TSS',
      _Cumulative.time => 'h',
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ChartOptionsButton(
            summary:
                '${_sport == 'run' ? l10n.anSportRun : l10n.anSportRide} · '
                '${l10n.rangeDaysShort(_days)}',
            onPressed: () => _openOptions(context, l10n),
          ),
        ),
        const SizedBox(height: 8),
        if (_loading)
          const Column(
            children: [
              SkeletonCard(height: 160, lines: 4),
              SizedBox(height: 16),
              SkeletonCard(height: 180),
            ],
          )
        else if (_error != null)
          StatusMessage.error(error: _error!, onRetry: _load)
        else if (previous.isEmpty && current.isEmpty)
          StatusMessage.needsSync(
            context,
            title: l10n.cmpNoBlockActivities,
            icon: Icons.compare_arrows,
          )
        else ...[
          SectionCard(
            icon: Icons.compare_arrows,
            title: l10n.cmpStatsTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.cmpPreviousBlock}: ${range(pair.previousStart, pair.previousEnd)}\n'
                  '${l10n.cmpThisBlock}: ${range(pair.currentStart, pair.currentEnd)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                CompareTable(
                  rows: compareRows(
                    l10n,
                    prevStats,
                    curStats,
                    _sport == 'run' ? 'Run' : 'Ride',
                    showSessions: true,
                  ),
                  colorA: compareColorA,
                  colorB: compareColorB,
                  headerA: l10n.cmpPreviousBlock,
                  headerB: l10n.cmpThisBlock,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            icon: Icons.show_chart,
            title: l10n.cmpCumulative,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 200,
                  child: MetricLineChart(
                    key: ValueKey('cum-$_metric-$_days-$_sport'),
                    series: [
                      ChartSeries(
                        label: l10n.cmpPreviousBlock,
                        color: compareColorA,
                        values: cumPrev,
                        average: false,
                      ),
                      ChartSeries(
                        label: l10n.cmpThisBlock,
                        color: compareColorB,
                        values: cumCur,
                        average: false,
                      ),
                    ],
                    labels: [
                      for (var i = 0; i < _days; i++) l10n.cmpDayOfBlock(i + 1),
                    ],
                    labelEvery: (_days / 4).ceil(),
                    showAverage: false,
                    smooth: false,
                    formatValue: (v) =>
                        '${v.toStringAsFixed(v < 10 ? 1 : 0)} $unit',
                  ),
                ),
                const SizedBox(height: 8),
                ChartLegend(
                  series: [
                    ChartSeries(
                      label: l10n.cmpPreviousBlock,
                      color: compareColorA,
                      values: const [],
                    ),
                    ChartSeries(
                      label: l10n.cmpThisBlock,
                      color: compareColorB,
                      values: const [],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
