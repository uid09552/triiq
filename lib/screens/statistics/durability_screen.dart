import 'package:flutter/material.dart';

import '../../evaluation/durability.dart';
import '../../evaluation/performance_curves.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/chart_options.dart';
import '../../widgets/charts/line_chart.dart';
import '../../widgets/section_card.dart';

/// Power (rides) or pace (runs) after a lot of work, against the fresh
/// season best: the best efforts that started after 1,000 / 2,000 / 3,000 kJ
/// (or 10 / 20 / 30 km), taken from the recent long sessions' own streams.
class DurabilityScreen extends StatefulWidget {
  DurabilityScreen({
    super.key,
    this.sport = CurveSport.ride,
    DurabilityLoader? loader,
  }) : loader = loader ?? DurabilityLoader();

  final CurveSport sport;
  final DurabilityLoader loader;

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
            Text(l10n.durError('$_error'))
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
      SectionCard(
        icon: Icons.table_rows_outlined,
        title: l10n.durRetained,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _table(context, l10n, r),
            const SizedBox(height: 8),
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
