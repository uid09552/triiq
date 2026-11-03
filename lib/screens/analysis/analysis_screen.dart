import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../data/repositories/activities_repository.dart';
import '../../data/repositories/wellness_repository.dart';
import '../../data/sync/auto_sync_service.dart';
import '../../evaluation/series_stats.dart';
import '../../l10n/app_localizations.dart';
import '../../util/dates.dart';
import '../../widgets/charts/chart_viewport.dart';
import '../../widgets/charts/line_chart.dart';
import '../../widgets/section_card.dart';
import 'analysis_data.dart';

enum _Range { d30, d90, m6, y1, ytd, custom }

String analysisMetricLabel(AppLocalizations l10n, AnalysisMetric m) =>
    switch (m) {
      AnalysisMetric.tss => l10n.analysisMetricTss,
      AnalysisMetric.hours => l10n.analysisMetricHours,
      AnalysisMetric.distance => l10n.analysisMetricDistance,
      AnalysisMetric.ctl => l10n.ctlLabel,
      AnalysisMetric.atl => l10n.atlLabel,
      AnalysisMetric.form => l10n.formLabel,
      AnalysisMetric.rampRate => l10n.rampRateLabel,
      AnalysisMetric.hrv => l10n.hrvLabel,
      AnalysisMetric.restingHr => l10n.restingHrLabel,
      AnalysisMetric.sleep => l10n.analysisMetricSleep,
    };

Color _metricColor(AnalysisMetric m, ColorScheme scheme) {
  final dark = scheme.brightness == Brightness.dark;
  return switch (m) {
    AnalysisMetric.tss => scheme.primary,
    AnalysisMetric.hours => scheme.secondary,
    AnalysisMetric.distance => scheme.tertiary,
    AnalysisMetric.ctl => scheme.tertiary,
    AnalysisMetric.atl => scheme.secondary,
    AnalysisMetric.form => scheme.primary,
    AnalysisMetric.rampRate => scheme.outline,
    AnalysisMetric.hrv =>
      dark ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
    AnalysisMetric.restingHr =>
      dark ? const Color(0xFFEF9A9A) : const Color(0xFFC62828),
    AnalysisMetric.sleep =>
      dark ? const Color(0xFF9FA8DA) : const Color(0xFF3949AB),
  };
}

String _format(AnalysisMetric m, double v) => switch (m) {
  AnalysisMetric.tss => v.toStringAsFixed(0),
  AnalysisMetric.hours => '${v.toStringAsFixed(1)} h',
  AnalysisMetric.distance => '${v.toStringAsFixed(1)} km',
  AnalysisMetric.hrv => '${v.toStringAsFixed(0)} ms',
  AnalysisMetric.restingHr => '${v.toStringAsFixed(0)} bpm',
  AnalysisMetric.sleep => '${v.toStringAsFixed(1)} h',
  _ => v.toStringAsFixed(1),
};

/// A Power BI–style workbench over the cached data: pick a period, sport,
/// resolution and any number of metrics, and each becomes a graph on one
/// shared x-axis — zooming or panning one moves them all, and tapping a
/// point puts the crosshair at the same moment in every graph. Per graph:
/// rolling average, min/max markers, a ±1 σ band, and summary statistics.
class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key, this.wellness, this.activities});

  /// Test seams; the app uses the defaults.
  final WellnessRepository? wellness;
  final ActivitiesRepository? activities;

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  late final _wellness = widget.wellness ?? WellnessRepository();
  late final _activities = widget.activities ?? ActivitiesRepository();
  final _viewport = ChartViewport();

  _Range _range = _Range.d90;
  DateTimeRange? _custom;
  String? _sport;
  bool _weekly = false;
  int _rolling = 0;
  bool _extremes = true;
  bool _band = false;
  final Set<AnalysisMetric> _metrics = {
    AnalysisMetric.tss,
    AnalysisMetric.ctl,
    AnalysisMetric.form,
    AnalysisMetric.hrv,
  };

  AnalysisSeries? _series;
  bool _loading = true;
  int? _selected;

  @override
  void initState() {
    super.initState();
    AutoSyncService.instance.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    AutoSyncService.instance.removeListener(_load);
    _viewport.dispose();
    super.dispose();
  }

  (DateTime, DateTime) get _period {
    final today = dateOnly(DateTime.now());
    return switch (_range) {
      _Range.d30 => (today.subtract(const Duration(days: 29)), today),
      _Range.d90 => (today.subtract(const Duration(days: 89)), today),
      _Range.m6 => (DateTime(today.year, today.month - 6, today.day), today),
      _Range.y1 => (DateTime(today.year - 1, today.month, today.day), today),
      _Range.ytd => (DateTime(today.year), today),
      _Range.custom =>
        _custom == null
            ? (today.subtract(const Duration(days: 89)), today)
            : (dateOnly(_custom!.start), dateOnly(_custom!.end)),
    };
  }

  Future<void> _load() async {
    final (from, to) = _period;
    try {
      final wellness = await _wellness.getRange(isoDate(from), isoDate(to));
      final activities = await _activities.getRange(isoDate(from), isoDate(to));
      final series = buildAnalysisSeries(
        from: from,
        to: to,
        wellness: wellness,
        activities: activities,
        weekly: _weekly,
        sport: _sport,
      );
      if (!mounted) return;
      setState(() {
        _series = series;
        _selected = null;
        _loading = false;
      });
      _viewport.setLength(series.length);
    } catch (error) {
      debugPrint('AnalysisScreen: cannot load: $error');
      if (mounted) setState(() => _loading = false);
    }
  }

  void _change(VoidCallback update) {
    setState(update);
    _load();
  }

  Future<void> _pickCustom() async {
    final (from, to) = _period;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: from, end: to),
    );
    if (picked == null) return;
    _change(() {
      _custom = picked;
      _range = _Range.custom;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final series = _series;
    final ordered = [
      for (final m in AnalysisMetric.values)
        if (_metrics.contains(m)) m,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.analysisTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            icon: Icons.tune,
            title: l10n.analysisFilters,
            child: _filters(l10n),
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (series == null || series.length == 0)
            Text(l10n.analysisNoData)
          else if (ordered.isEmpty)
            Text(l10n.analysisPickMetric)
          else ...[
            _selectionCard(l10n, theme, series, ordered),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.analysisHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ZoomControls(viewport: _viewport),
              ],
            ),
            const SizedBox(height: 8),
            for (final m in ordered) ...[
              _MetricPanel(
                key: ValueKey('analysis-panel-${m.name}'),
                metric: m,
                series: series,
                viewport: _viewport,
                selected: _selected,
                onSelect: (i) => setState(() => _selected = i),
                rolling: _rolling,
                extremes: _extremes,
                band: _band,
                weekly: _weekly,
              ),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }

  Widget _filters(AppLocalizations l10n) {
    final theme = Theme.of(context);
    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(text, style: theme.textTheme.labelLarge),
    );

    final rangeLabels = {
      _Range.d30: l10n.analysisRange30d,
      _Range.d90: l10n.analysisRange90d,
      _Range.m6: l10n.analysisRange6m,
      _Range.y1: l10n.analysisRange1y,
      _Range.ytd: l10n.analysisRangeYtd,
    };
    final (from, to) = _period;
    final fmt = DateFormat.yMMMd(Localizations.localeOf(context).toString());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label(l10n.analysisPeriod),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final e in rangeLabels.entries)
              ChoiceChip(
                label: Text(e.value),
                selected: _range == e.key,
                onSelected: (_) => _change(() => _range = e.key),
              ),
            ChoiceChip(
              key: const ValueKey('analysis-custom-range'),
              label: Text(
                _range == _Range.custom
                    ? '${fmt.format(from)} – ${fmt.format(to)}'
                    : l10n.analysisRangeCustom,
              ),
              selected: _range == _Range.custom,
              onSelected: (_) => _pickCustom(),
            ),
          ],
        ),
        label(l10n.analysisSport),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final (sport, text) in [
              (null, l10n.analysisSportAll),
              ('swim', l10n.sportSwim),
              ('cycle', l10n.sportRide),
              ('run', l10n.sportRun),
            ])
              ChoiceChip(
                label: Text(text),
                selected: _sport == sport,
                onSelected: (_) => _change(() => _sport = sport),
              ),
          ],
        ),
        label(l10n.analysisResolution),
        SegmentedButton<bool>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: false, label: Text(l10n.analysisDay)),
            ButtonSegment(value: true, label: Text(l10n.analysisWeek)),
          ],
          selected: {_weekly},
          onSelectionChanged: (v) => _change(() => _weekly = v.first),
        ),
        label(l10n.analysisRolling),
        SegmentedButton<int>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: 0, label: Text(l10n.smoothOff)),
            const ButtonSegment(value: 7, label: Text('7')),
            const ButtonSegment(value: 14, label: Text('14')),
            const ButtonSegment(value: 28, label: Text('28')),
          ],
          selected: {_rolling},
          onSelectionChanged: (v) => setState(() => _rolling = v.first),
        ),
        const SizedBox(height: 4),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.analysisShowExtremes),
          value: _extremes,
          onChanged: (v) => setState(() => _extremes = v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.analysisShowBand),
          value: _band,
          onChanged: (v) => setState(() => _band = v),
        ),
        label(l10n.analysisMetrics),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final m in AnalysisMetric.values)
              FilterChip(
                key: ValueKey('analysis-metric-${m.name}'),
                avatar: CircleAvatar(
                  radius: 5,
                  backgroundColor: _metricColor(m, theme.colorScheme),
                ),
                label: Text(analysisMetricLabel(l10n, m)),
                selected: _metrics.contains(m),
                onSelected: (on) => setState(
                  () => on ? _metrics.add(m) : _metrics.remove(m),
                ),
              ),
          ],
        ),
      ],
    );
  }

  String _bucketLabel(AppLocalizations l10n, AnalysisSeries series, int i) {
    final locale = Localizations.localeOf(context).toString();
    final date = series.dates[i];
    final text = DateFormat.yMMMEd(locale).format(date);
    return _weekly ? l10n.analysisWeekOf(DateFormat.yMMMd(locale).format(date)) : text;
  }

  /// The values of every shown metric at the selected point.
  Widget _selectionCard(
    AppLocalizations l10n,
    ThemeData theme,
    AnalysisSeries series,
    List<AnalysisMetric> metrics,
  ) {
    final i = _selected;
    if (i == null || i >= series.length) return const SizedBox.shrink();
    return Card(
      key: const ValueKey('analysis-selection'),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _bucketLabel(l10n, series, i),
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                for (final m in metrics)
                  if (series.values[m]![i] != null)
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${analysisMetricLabel(l10n, m)}  ',
                            style: theme.textTheme.bodySmall,
                          ),
                          TextSpan(
                            text: _format(m, series.values[m]![i]!),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: _metricColor(m, theme.colorScheme),
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricPanel extends StatelessWidget {
  const _MetricPanel({
    super.key,
    required this.metric,
    required this.series,
    required this.viewport,
    required this.selected,
    required this.onSelect,
    required this.rolling,
    required this.extremes,
    required this.band,
    required this.weekly,
  });

  final AnalysisMetric metric;
  final AnalysisSeries series;
  final ChartViewport viewport;
  final int? selected;
  final ValueChanged<int> onSelect;
  final int rolling;
  final bool extremes;
  final bool band;
  final bool weekly;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final color = _metricColor(metric, scheme);
    final raw = series.values[metric]!;
    final stats = computeStats(raw);
    final label = analysisMetricLabel(l10n, metric);
    final dateFmt = DateFormat.MMMd(locale);

    final chartSeries = rolling > 1
        ? [
            ChartSeries(
              label: label,
              color: color,
              values: raw,
              strokeWidth: 1.2,
              opacity: 0.4,
              average: false,
            ),
            ChartSeries(
              label: '${l10n.analysisRolling} $rolling',
              color: color,
              values: trailingMean(raw, rolling),
              fill: true,
              markExtremes: extremes,
              average: false,
            ),
          ]
        : [
            ChartSeries(
              label: label,
              color: color,
              values: raw,
              fill: true,
              markExtremes: extremes,
            ),
          ];

    final chips = <String>[
      if (stats != null) ...[
        'Ø ${_format(metric, stats.mean)}',
        'Min ${_format(metric, stats.min)} · ${dateFmt.format(series.dates[stats.minIndex])}',
        'Max ${_format(metric, stats.max)} · ${dateFmt.format(series.dates[stats.maxIndex])}',
        'σ ${_format(metric, stats.stdDev)}',
        'Δ ${stats.change >= 0 ? '+' : ''}${_format(metric, stats.change)}',
      ],
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(label, style: theme.textTheme.titleSmall),
                ),
                if (selected != null &&
                    selected! < raw.length &&
                    raw[selected!] != null)
                  Text(
                    _format(metric, raw[selected!]!),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ),
            if (chips.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final c in chips)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(c, style: theme.textTheme.labelSmall),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            SizedBox(
              height: 160,
              child: MetricLineChart(
                series: chartSeries,
                labels: [for (final d in series.dates) dateFmt.format(d)],
                labelEvery: (series.length / 4).ceil().clamp(1, 1000),
                viewport: viewport,
                selectedIndex: selected,
                onSelect: onSelect,
                zeroLine: metric.hasZeroLine,
                formatValue: (v) => _format(metric, v).replaceAll(RegExp(r' [a-z]+$'), ''),
                band: band && stats != null && stats.stdDev > 0
                    ? ChartBand(
                        low: stats.mean - stats.stdDev,
                        high: stats.mean + stats.stdDev,
                        color: color,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
