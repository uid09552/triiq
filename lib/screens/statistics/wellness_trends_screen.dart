import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../data/models/local_wellness.dart';
import '../../data/repositories/wellness_repository.dart';
import '../../evaluation/wellness_trends.dart';
import '../../l10n/app_localizations.dart';
import '../../util/dates.dart';
import '../../widgets/chart_options.dart';
import '../../widgets/charts/line_chart.dart';
import '../../widgets/section_card.dart';
import '../../widgets/skeleton.dart';

/// HRV, resting HR, sleep and weight over 30 days to a year: the daily
/// values, their 7-day average and the shaded band the athlete normally sits
/// in (mean ± 1 SD over the period). Read from the local wellness cache.
class WellnessTrendsScreen extends StatefulWidget {
  WellnessTrendsScreen({super.key, WellnessRepository? repository, this.today})
    : repository = repository ?? WellnessRepository();

  final WellnessRepository repository;

  /// The last day shown; defaults to today.
  final DateTime? today;

  @override
  State<WellnessTrendsScreen> createState() => _WellnessTrendsScreenState();
}

class _WellnessTrendsScreenState extends State<WellnessTrendsScreen> {
  static const _ranges = [30, 90, 180, 365];

  int _days = 90;
  final Set<WellnessMetric> _shown = {...WellnessMetric.values};
  bool _loading = true;
  List<LocalWellness> _records = const [];

  DateTime get _end => dateOnly(widget.today ?? DateTime.now());

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final from = _end.subtract(Duration(days: _days));
    final rows = await widget.repository.getRange(isoDate(from), isoDate(_end));
    if (!mounted) return;
    setState(() {
      _records = rows;
      _loading = false;
    });
  }

  String _label(AppLocalizations l10n, WellnessMetric m) => switch (m) {
    WellnessMetric.hrv => l10n.readinessSignalHrv,
    WellnessMetric.restingHr => l10n.readinessSignalRestingHr,
    WellnessMetric.sleep => l10n.readinessSignalSleep,
    WellnessMetric.weight => l10n.wtMetricWeight,
  };

  String _value(WellnessMetric m, double v, {bool delta = false}) {
    final sign = delta && v > 0 ? '+' : '';
    return switch (m) {
      WellnessMetric.hrv => '$sign${v.toStringAsFixed(delta ? 1 : 0)} ms',
      WellnessMetric.restingHr =>
        '$sign${v.toStringAsFixed(delta ? 1 : 0)} bpm',
      WellnessMetric.sleep =>
        delta ? '$sign${v.toStringAsFixed(1)} h' : _hours(v),
      WellnessMetric.weight => '$sign${v.toStringAsFixed(1)} kg',
    };
  }

  static String _hours(double hours) {
    final minutes = (hours * 60).round();
    return '${minutes ~/ 60}:${(minutes % 60).toString().padLeft(2, '0')} h';
  }

  Color _color(ColorScheme s, WellnessMetric m) => switch (m) {
    WellnessMetric.hrv => s.primary,
    WellnessMetric.restingHr => s.error,
    WellnessMetric.sleep => s.tertiary,
    WellnessMetric.weight => s.secondary,
  };

  void _openOptions(AppLocalizations l10n) {
    showChartOptions(
      context,
      title: l10n.wtTitle,
      ownerSetState: setState,
      builder: (sheet, apply) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OptionGroup(
            label: l10n.chartOptionsRange,
            child: SegmentedButton<int>(
              showSelectedIcon: false,
              segments: [
                for (final d in _ranges)
                  ButtonSegment(
                    value: d,
                    label: Text(
                      d == 365 ? l10n.rangeOneYear : l10n.rangeDaysShort(d),
                    ),
                  ),
              ],
              selected: {_days},
              onSelectionChanged: (s) {
                apply(() => _days = s.first);
                _load();
              },
            ),
          ),
          OptionGroup(
            label: l10n.wtShow,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final m in WellnessMetric.values)
                  FilterChip(
                    key: ValueKey('wt-metric-${m.name}'),
                    label: Text(_label(l10n, m)),
                    selected: _shown.contains(m),
                    onSelected: (on) => apply(
                      () => on
                          ? _shown.add(m)
                          : (_shown.length > 1 ? _shown.remove(m) : null),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final trends = [
      for (final m in WellnessMetric.values)
        if (_shown.contains(m)) wellnessTrend(_records, m, _end, _days),
    ];
    final withData = trends.where((t) => t.hasData).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.wtTitle),
        actions: [
          ChartOptionsButton(
            summary: _days == 365
                ? l10n.rangeOneYear
                : l10n.rangeDaysShort(_days),
            onPressed: () => _openOptions(l10n),
          ),
        ],
      ),
      body: _loading
          ? const SkeletonScreen(cards: 3)
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (withData.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(l10n.wtNoData, textAlign: TextAlign.center),
                  ),
                for (final t in withData) ...[
                  _card(context, l10n, t),
                  const SizedBox(height: 12),
                ],
                if (withData.any((t) => t.band != null))
                  Text(
                    l10n.wtBandNote,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _card(BuildContext context, AppLocalizations l10n, WellnessTrend t) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final color = _color(scheme, t.metric);
    final latest = t.latest;
    final avg = t.latestAverage;
    final change = t.weekChange;
    final position = t.position;
    final positionColor = switch (position) {
      BandPosition.within => Colors.green.shade600,
      BandPosition.below || BandPosition.above => Colors.amber.shade700,
      null => scheme.onSurfaceVariant,
    };
    final positionText = switch (position) {
      BandPosition.below => l10n.wtBelow,
      BandPosition.within => l10n.wtWithin,
      BandPosition.above => l10n.wtAbove,
      null => null,
    };

    Widget stat(String label, String value) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    final band = t.band;
    return SectionCard(
      key: ValueKey('wt-${t.metric.name}'),
      icon: switch (t.metric) {
        WellnessMetric.hrv => Icons.monitor_heart_outlined,
        WellnessMetric.restingHr => Icons.favorite_border,
        WellnessMetric.sleep => Icons.bedtime_outlined,
        WellnessMetric.weight => Icons.monitor_weight_outlined,
      },
      title: _label(l10n, t.metric),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              stat(
                l10n.wtLatest,
                latest == null ? '–' : _value(t.metric, latest.$2),
              ),
              stat(l10n.wtAverage, avg == null ? '–' : _value(t.metric, avg)),
              stat(
                l10n.wtWeek,
                change == null ? '–' : _value(t.metric, change, delta: true),
              ),
            ],
          ),
          if (positionText != null) ...[
            const SizedBox(height: 4),
            Text(
              positionText,
              style: theme.textTheme.labelSmall?.copyWith(color: positionColor),
            ),
          ],
          const SizedBox(height: 8),
          SizedBox(
            height: 150,
            child: MetricLineChart(
              key: ValueKey('wt-chart-${t.metric.name}-$_days'),
              series: [
                ChartSeries(
                  label: _label(l10n, t.metric),
                  color: color,
                  strokeWidth: 1.2,
                  opacity: 0.45,
                  average: false,
                  values: t.daily,
                ),
                ChartSeries(
                  label: l10n.wtAverage,
                  color: color,
                  strokeWidth: 2.8,
                  average: false,
                  values: t.average,
                ),
              ],
              labels: [
                for (final d in t.days) DateFormat.MMMd(locale).format(d),
              ],
              labelEvery: (t.days.length / 4).ceil(),
              showAverage: false,
              smooth: false,
              band: band == null
                  ? null
                  : ChartBand(
                      low: band.low,
                      high: band.high,
                      color: color.withValues(alpha: 0.12),
                    ),
              formatValue: (v) => switch (t.metric) {
                WellnessMetric.sleep => v.toStringAsFixed(1),
                WellnessMetric.weight => v.toStringAsFixed(1),
                _ => v.toStringAsFixed(0),
              },
            ),
          ),
        ],
      ),
    );
  }
}
