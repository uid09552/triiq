import 'package:flutter/material.dart';

import '../../evaluation/durability.dart';
import '../../evaluation/performance_curves.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/chart_options.dart';
import '../../data/repositories/activities_repository.dart';
import '../../widgets/charts/chart_theme.dart';
import '../../widgets/charts/line_chart.dart';
import '../../widgets/charts/radar_chart.dart';
import '../../widgets/section_card.dart';
import '../../widgets/status_message.dart';
import '../activities/activity_detail_screen.dart';

/// Power (rides) or pace (runs) after a lot of work, against the fresh
/// season best: the best efforts that started after 1,000 / 2,000 / 3,000 kJ
/// (or 10 / 20 / 30 km), taken from the recent long sessions' own streams.
class DurabilityScreen extends StatefulWidget {
  DurabilityScreen({
    super.key,
    this.sport = CurveSport.ride,
    DurabilityLoader? loader,
    this.activities,
  }) : loader = loader ?? DurabilityLoader();

  final CurveSport sport;
  final DurabilityLoader loader;

  /// Where "Open session" looks the activity up; the shared cache by default.
  final ActivitiesRepository? activities;

  @override
  State<DurabilityScreen> createState() => _DurabilityScreenState();
}

class _DurabilityScreenState extends State<DurabilityScreen> {
  static const _ranges = [90, 180, 365];

  late CurveSport _sport = widget.sport == CurveSport.run
      ? CurveSport.run
      : CurveSport.ride;
  int _days = 180;
  DurabilityResult? _result;
  Object? _error;
  bool _loading = true;
  int _done = 0, _total = 0;
  int _generation = 0;
  bool _showTable = false;
  final Set<String> _hiddenLevels = {};
  RadarSelection? _selected;
  late final _activities = widget.activities ?? ActivitiesRepository();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _error = null;
      _done = 0;
      _total = 0;
    });
    try {
      final result = await widget.loader.load(
        _sport,
        _days,
        onProgress: (done, total) {
          if (mounted && generation == _generation) {
            setState(() {
              _done = done;
              _total = total;
            });
          }
        },
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        _result = result;
        _selected = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  bool get _isRide => _sport == CurveSport.ride;

  Color _levelColor(int i) => switch (i) {
    0 => const Color(0xFFF9A825),
    1 => const Color(0xFFEF6C00),
    _ => const Color(0xFFC62828),
  };

  String _levelLabel(AppLocalizations l10n, DurabilityLevel level) => _isRide
      ? l10n.durAfterKj(level.workAfter.round())
      : l10n.durAfterKm(level.workAfter.round());

  String _pointLabel(double x) =>
      _isRide ? formatCurveDuration(x) : formatCurveDistance(x);

  /// Watts, or a pace per km from a time over [distance] metres.
  String _valueLabel(double value, double point) {
    if (_isRide) return '${value.round()} W';
    return formatPace(point / value, per: 1000);
  }

  static const _radarMarkers = [
    RadarMarker.circle,
    RadarMarker.square,
    RadarMarker.triangle,
  ];
  static const _radarDashes = <List<double>?>[
    null,
    [8, 4],
    [2, 4],
  ];

  /// One radar polygon per fatigue level: the share of the fresh value kept.
  List<RadarSeries> _radarSeries(AppLocalizations l10n, DurabilityResult r) => [
    for (var l = 0; l < r.fatigued.length; l++)
      RadarSeries(
        label: _levelLabel(l10n, r.fatigued[l]),
        color: _levelColor(l),
        marker: _radarMarkers[l % _radarMarkers.length],
        dash: _radarDashes[l % _radarDashes.length],
        values: [
          for (var i = 0; i < r.points.length; i++)
            r.retained(r.fatigued[l], i),
        ],
      ),
  ];

  /// "After 2000 kJ: 5 min 92 %, 20 min 85 %" for each level.
  String _radarSummary(
    AppLocalizations l10n,
    DurabilityResult r,
    List<RadarSeries> series,
  ) => [
    for (var l = 0; l < series.length; l++)
      () {
        final parts = [
          for (var i = 0; i < r.points.length; i++)
            if (series[l].values[i] != null)
              l10n.durRadarPart(
                _pointLabel(r.points[i]),
                (series[l].values[i]! * 100).round().toString(),
              ),
        ];
        return parts.isEmpty
            ? l10n.durRadarSummaryNone(series[l].label)
            : l10n.durRadarSummary(series[l].label, parts.join(', '));
      }(),
  ].join('. ');

  Future<void> _openSession(String activityId) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final activity = await _activities.getById(activityId);
    if (!mounted) return;
    if (activity == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.curveSessionNotCached)),
      );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ActivityDetailScreen(activity: activity),
      ),
    );
  }

  Widget _radarLegend(BuildContext context, List<RadarSeries> series) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        // Levels never reached have nothing to show or hide.
        for (final s in series.where((s) => s.values.any((v) => v != null)))
          Semantics(
            button: true,
            toggled: !_hiddenLevels.contains(s.label),
            label: s.label,
            excludeSemantics: true,
            child: InkWell(
              key: ValueKey('radar-legend-${s.label}'),
              borderRadius: BorderRadius.circular(8),
              onTap: () => setState(() {
                if (!_hiddenLevels.remove(s.label)) _hiddenLevels.add(s.label);
                _selected = null;
              }),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Opacity(
                  opacity: _hiddenLevels.contains(s.label) ? 0.4 : 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadarLegendSwatch(series: s),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            s.label,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// The tooltip: value, share kept and source session for the selected
  /// vertex, or for every visible level on a selected axis.
  Widget _radarDetail(
    BuildContext context,
    AppLocalizations l10n,
    DurabilityResult r,
    List<RadarSeries> series,
  ) {
    final theme = Theme.of(context);
    final sel = _selected;
    if (sel == null || sel.axis >= r.points.length) {
      return const SizedBox.shrink();
    }
    final i = sel.axis;
    final point = _pointLabel(r.points[i]);
    final rows = <Widget>[];
    for (var l = 0; l < r.fatigued.length; l++) {
      if (sel.series != null && sel.series != l) continue;
      if (_hiddenLevels.contains(series[l].label)) continue;
      final level = r.fatigued[l];
      final v = level.values[i];
      final kept = r.retained(level, i);
      final src = level.sourceAt(i);
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              Text(
                v == null || kept == null
                    ? l10n.durRadarTipNoData(point, series[l].label)
                    : l10n.durRadarTip(
                        point,
                        series[l].label,
                        _valueLabel(v, r.points[i]),
                        (kept * 100).round().toString(),
                      ),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (src != null && v != null) ...[
                Text(
                  l10n.durRadarSource(src.name ?? src.id, src.date),
                  style: theme.textTheme.bodySmall,
                ),
                TextButton(
                  key: ValueKey('radar-open-$l'),
                  onPressed: () => _openSession(src.id),
                  child: Text(l10n.durRadarOpen),
                ),
              ],
            ],
          ),
        ),
      );
    }
    if (rows.isEmpty) return const SizedBox.shrink();
    final chart = ChartTheme.of(context);
    return Container(
      key: const ValueKey('radar-detail'),
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: chart.tooltip,
        border: Border.all(color: chart.tooltipBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
    );
  }

  void _openOptions(AppLocalizations l10n) {
    showChartOptions(
      context,
      title: l10n.durTitle,
      ownerSetState: setState,
      builder: (sheet, apply) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OptionGroup(
            label: l10n.chartOptionsSport,
            child: SegmentedButton<CurveSport>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: CurveSport.ride,
                  label: Text(l10n.anSportRide),
                ),
                ButtonSegment(
                  value: CurveSport.run,
                  label: Text(l10n.anSportRun),
                ),
              ],
              selected: {_sport},
              onSelectionChanged: (s) {
                apply(() => _sport = s.first);
                _load();
              },
            ),
          ),
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.durTitle),
        actions: [
          ChartOptionsButton(
            summary:
                '${_isRide ? l10n.anSportRide : l10n.anSportRun} · '
                '${_days == 365 ? l10n.rangeOneYear : l10n.rangeDaysShort(_days)}',
            onPressed: () => _openOptions(l10n),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_loading) ...[
            LinearProgressIndicator(value: _total == 0 ? null : _done / _total),
            const SizedBox(height: 8),
            if (_total > 0)
              Text(
                l10n.durReading(_done, _total),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 8),
          ],
          if (_error != null)
            StatusMessage.error(error: _error!, onRetry: _load)
          else if (_result != null)
            ..._content(context, l10n, _result!),
        ],
      ),
    );
  }

  List<Widget> _content(
    BuildContext context,
    AppLocalizations l10n,
    DurabilityResult r,
  ) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    if (r.candidates == 0) {
      return [Text(_isRide ? l10n.durNoneRide : l10n.durNoneRun, style: muted)];
    }
    if (r.isEmpty && !_loading) {
      return [
        Text(l10n.durNoData, style: muted),
        const SizedBox(height: 8),
        Text(l10n.durBasedOn(r.analysed, r.candidates, r.days), style: muted),
      ];
    }

    // The chart plots watts, or speed for pace so that faster sits higher.
    double? plot(double? v, double point) =>
        v == null ? null : (_isRide ? v : point / v);
    final series = <ChartSeries>[
      if (r.fresh.hasData)
        ChartSeries(
          label: l10n.durFresh,
          color: theme.colorScheme.primary,
          strokeWidth: 3,
          average: false,
          values: [
            for (var i = 0; i < r.points.length; i++)
              plot(r.fresh.values[i], r.points[i]),
          ],
        ),
      for (var l = 0; l < r.fatigued.length; l++)
        if (r.fatigued[l].hasData)
          ChartSeries(
            label: _levelLabel(l10n, r.fatigued[l]),
            color: _levelColor(l),
            average: false,
            values: [
              for (var i = 0; i < r.points.length; i++)
                plot(r.fatigued[l].values[i], r.points[i]),
            ],
          ),
    ];

    String formatPlotted(double v) =>
        _isRide ? '${v.round()} W' : formatPace(v, per: 1000); // v is m/s here

    return [
      SectionCard(
        icon: Icons.battery_charging_full,
        title: l10n.durTitle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 220,
              child: MetricLineChart(
                key: ValueKey('durability-$_sport-$_days'),
                series: series,
                labels: [for (final x in r.points) _pointLabel(x)],
                labelEvery: 1,
                showAverage: false,
                smooth: false,
                zoomable: false,
                formatValue: formatPlotted,
              ),
            ),
            const SizedBox(height: 12),
            ChartLegend(series: series),
            const SizedBox(height: 8),
            Text(_isRide ? l10n.durHintRide : l10n.durHintRun, style: muted),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _radarCard(context, l10n, r, muted),
      const SizedBox(height: 16),
      SectionCard(
        icon: Icons.table_rows_outlined,
        title: l10n.durRetained,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                key: const ValueKey('durability-table-toggle'),
                onPressed: () => setState(() => _showTable = !_showTable),
                icon: Icon(_showTable ? Icons.expand_less : Icons.expand_more),
                label: Text(_showTable ? l10n.durHideTable : l10n.durShowTable),
              ),
            ),
            if (_showTable) ...[
              _table(context, l10n, r),
              const SizedBox(height: 8),
            ],
            Text(
              l10n.durBasedOn(r.analysed, r.candidates, r.days),
              style: muted,
            ),
            if (r.failed > 0) Text(l10n.durFailed(r.failed), style: muted),
          ],
        ),
      ),
    ];
  }

  Widget _radarCard(
    BuildContext context,
    AppLocalizations l10n,
    DurabilityResult r,
    TextStyle? muted,
  ) {
    final series = _radarSeries(l10n, r);
    return SectionCard(
      icon: Icons.radar,
      title: l10n.durRadarTitle,
      child: !r.fresh.hasData
          ? Text(l10n.durRadarNoFresh, style: muted)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: RadarChart(
                      key: ValueKey('durability-radar-$_sport-$_days'),
                      axes: [for (final x in r.points) _pointLabel(x)],
                      series: series,
                      hidden: _hiddenLevels,
                      selection: _selected,
                      onSelect: (s) => setState(() => _selected = s),
                      semanticsLabel:
                          '${l10n.durRadarTitle}. ${_radarSummary(l10n, r, series)}',
                    ),
                  ),
                ),
                _radarLegend(context, series),
                _radarDetail(context, l10n, r, series),
                const SizedBox(height: 8),
                Text(l10n.durRadarHint, style: muted),
              ],
            ),
    );
  }

  Widget _table(
    BuildContext context,
    AppLocalizations l10n,
    DurabilityResult r,
  ) {
    final theme = Theme.of(context);
    Widget cell(
      String text, {
      Color? color,
      bool bold = false,
      bool head = false,
    }) => Expanded(
      child: Text(
        text,
        textAlign: TextAlign.end,
        style: (head ? theme.textTheme.labelSmall : theme.textTheme.bodySmall)
            ?.copyWith(color: color, fontWeight: bold ? FontWeight.w700 : null),
      ),
    );
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: SizedBox.shrink()),
            cell(l10n.durFresh, head: true, color: theme.colorScheme.primary),
            for (var l = 0; l < r.fatigued.length; l++)
              cell(
                _isRide
                    ? '${r.fatigued[l].workAfter.round()} kJ'
                    : '${r.fatigued[l].workAfter.round()} km',
                head: true,
                color: _levelColor(l),
              ),
          ],
        ),
        const Divider(height: 10),
        for (var i = 0; i < r.points.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _pointLabel(r.points[i]),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                cell(
                  r.fresh.values[i] == null
                      ? '–'
                      : _valueLabel(r.fresh.values[i]!, r.points[i]),
                ),
                for (final level in r.fatigued)
                  cell(() {
                    final v = level.values[i];
                    if (v == null) return '–';
                    final kept = r.retained(level, i);
                    final pct = kept == null ? '' : ' ${(kept * 100).round()}%';
                    return '${_valueLabel(v, r.points[i])}$pct';
                  }()),
              ],
            ),
          ),
      ],
    );
  }
}
