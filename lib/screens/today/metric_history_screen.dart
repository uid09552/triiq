import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../data/models/local_wellness.dart';
import '../../data/repositories/wellness_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../util/dates.dart';
import '../../widgets/charts/line_chart.dart';
import '../../widgets/section_card.dart';

/// The load metrics the Today tiles drill into. Each is a single number per
/// day, read from the cached Intervals.icu wellness records.
enum LoadMetric {
  /// Chronic training load — the 42-day exponentially weighted average.
  ctl,

  /// Acute training load — the 7-day one.
  atl,

  /// Training stress balance, CTL - ATL. Not stored by Intervals.icu as its
  /// own field, so it's derived here.
  form,

  /// Change in CTL, as Intervals.icu reports it.
  rampRate,
}

/// History and context for one load metric: a line chart over the chosen
/// window, the summary numbers under it, and a plain-language note on what
/// the metric does and doesn't say.
///
/// Reads only the local cache, like every other screen — the range picker
/// changes what's charted, never what's fetched, so it stays instant and
/// works offline.
class MetricHistoryScreen extends StatefulWidget {
  const MetricHistoryScreen({super.key, required this.metric});

  final LoadMetric metric;

  @override
  State<MetricHistoryScreen> createState() => _MetricHistoryScreenState();
}

class _MetricHistoryScreenState extends State<MetricHistoryScreen> {
  static const _rangeOptions = [30, 90, 365];

  final _wellnessRepository = WellnessRepository();

  int _days = 90;
  bool _loading = true;
  List<({DateTime date, double? ctl, double? atl, double? ramp})> _points =
      const [];
  int? _selected;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final today = dateOnly(DateTime.now());
    final start = today.subtract(Duration(days: _days - 1));
    final records = await _wellnessRepository.getRange(
      isoDate(start),
      isoDate(today),
    );
    final byDate = {for (final record in records) record.date: record};

    final points = [
      for (var i = 0; i < _days; i++)
        _pointFor(start.add(Duration(days: i)), byDate),
    ];

    if (!mounted) return;
    setState(() {
      _points = points;
      _selected = null;
      _loading = false;
    });
  }

  static ({DateTime date, double? ctl, double? atl, double? ramp}) _pointFor(
    DateTime date,
    Map<String, LocalWellness> byDate,
  ) {
    final record = byDate[isoDate(date)];
    return (
      date: date,
      ctl: record?.ctl,
      atl: record?.atl,
      ramp: record?.rampRate,
    );
  }

  double? _valueAt(int index) => switch (widget.metric) {
    LoadMetric.ctl => _points[index].ctl,
    LoadMetric.atl => _points[index].atl,
    LoadMetric.form => _formAt(index),
    LoadMetric.rampRate => _points[index].ramp,
  };

  double? _formAt(int index) {
    final point = _points[index];
    final ctl = point.ctl;
    final atl = point.atl;
    if (ctl == null || atl == null) return null;
    return ctl - atl;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final values = [
      for (var i = 0; i < _points.length; i++) _valueAt(i),
    ];
    final known = values.whereType<double>().toList();

    final series = <ChartSeries>[
      ChartSeries(
        label: _metricLabel(l10n, widget.metric),
        color: _metricColor(colorScheme, widget.metric),
        values: values,
        fill: true,
      ),
      // CTL and ATL only make sense against each other, so each is charted
      // with the other behind it. Form and ramp rate stand alone.
      if (widget.metric == LoadMetric.ctl)
        ChartSeries(
          label: l10n.atlLabel,
          color: colorScheme.secondary,
          values: [for (final point in _points) point.atl],
        ),
      if (widget.metric == LoadMetric.atl)
        ChartSeries(
          label: l10n.ctlLabel,
          color: colorScheme.tertiary,
          values: [for (final point in _points) point.ctl],
        ),
    ];

    final selectedIndex = _selected;
    final selectedValue = selectedIndex == null || selectedIndex >= values.length
        ? null
        : values[selectedIndex];

    return Scaffold(
      appBar: AppBar(title: Text(_metricTitle(l10n, widget.metric))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<int>(
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
            onSelectionChanged: _loading
                ? null
                : (selection) {
                    setState(() => _days = selection.first);
                    _load();
                  },
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (known.isEmpty)
            SectionCard(
              icon: Icons.cloud_off_outlined,
              title: _metricTitle(l10n, widget.metric),
              child: Text(
                l10n.noDataCachedForRange,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else ...[
            SectionCard(
              icon: Icons.show_chart,
              title: _metricTitle(l10n, widget.metric),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedIndex != null && selectedValue != null
                        ? l10n.selectedDayValue(
                            _formatDate(context, _points[selectedIndex].date),
                            _format(selectedValue),
                          )
                        : l10n.tapChartForDay,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: MetricLineChart(
                      series: series,
                      labels: [
                        for (final point in _points)
                          DateFormat.MMMd(
                            Localizations.localeOf(context).toString(),
                          ).format(point.date),
                      ],
                      selectedIndex: _selected,
                      onSelect: (index) => setState(() => _selected = index),
                      labelEvery: (_points.length / 4).ceil(),
                      zeroLine:
                          widget.metric == LoadMetric.form ||
                          widget.metric == LoadMetric.rampRate,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ChartLegend(series: series),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SummaryRow(
              values: [
                (l10n.currentLabel, _format(known.last)),
                (
                  l10n.changeLabel,
                  _formatSigned(known.last - known.first),
                ),
                (
                  l10n.avgLabel,
                  _format(
                    known.reduce((a, b) => a + b) / known.length,
                  ),
                ),
                (
                  l10n.rangeLabel,
                  '${_format(known.reduce((a, b) => a < b ? a : b))}'
                      ' – ${_format(known.reduce((a, b) => a > b ? a : b))}',
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          SectionCard(
            icon: Icons.info_outline,
            title: l10n.whatThisMeans,
            child: Text(
              _metricExplainer(l10n, widget.metric),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _format(double value) => value.toStringAsFixed(1);

  String _formatSigned(double value) =>
      '${value >= 0 ? '+' : ''}${value.toStringAsFixed(1)}';

  static String _formatDate(BuildContext context, DateTime date) =>
      DateFormat.MMMd(
        Localizations.localeOf(context).toString(),
      ).format(date);

  static String _metricTitle(AppLocalizations l10n, LoadMetric metric) =>
      switch (metric) {
        LoadMetric.ctl => l10n.metricCtlTitle,
        LoadMetric.atl => l10n.metricAtlTitle,
        LoadMetric.form => l10n.metricFormTitle,
        LoadMetric.rampRate => l10n.metricRampTitle,
      };

  static String _metricLabel(AppLocalizations l10n, LoadMetric metric) =>
      switch (metric) {
        LoadMetric.ctl => l10n.ctlLabel,
        LoadMetric.atl => l10n.atlLabel,
        LoadMetric.form => l10n.formLabel,
        LoadMetric.rampRate => l10n.rampRateLabel,
      };

  static String _metricExplainer(AppLocalizations l10n, LoadMetric metric) =>
      switch (metric) {
        LoadMetric.ctl => l10n.metricCtlExplainer,
        LoadMetric.atl => l10n.metricAtlExplainer,
        LoadMetric.form => l10n.metricFormExplainer,
        LoadMetric.rampRate => l10n.metricRampExplainer,
      };

  static Color _metricColor(ColorScheme colors, LoadMetric metric) =>
      switch (metric) {
        LoadMetric.ctl => colors.tertiary,
        LoadMetric.atl => colors.secondary,
        LoadMetric.form => colors.primary,
        LoadMetric.rampRate => colors.primary,
      };
}

/// The four summary numbers under a metric chart.
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.values});

  final List<(String, String)> values;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        for (final (index, entry) in values.indexed) ...[
          if (index > 0) const SizedBox(width: 12),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 6,
                ),
                child: Column(
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        entry.$2,
                        maxLines: 1,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.$1,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
