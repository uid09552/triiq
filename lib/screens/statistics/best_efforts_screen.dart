import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../evaluation/best_efforts.dart';
import '../../evaluation/performance_curves.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/chart_options.dart';
import '../../widgets/charts/line_chart.dart';
import '../../widgets/section_card.dart';

/// The best 5 s / 1 min / 5 min / 20 min power (rides) or fastest 1 / 5 /
/// 10 km (runs) month by month, so a season's progress is one line, with the
/// last 30 days set against the best of the 90 before them.
class BestEffortsScreen extends StatefulWidget {
  BestEffortsScreen({
    super.key,
    this.sport = CurveSport.ride,
    BestEffortsRepository? repository,
    this.today,
  }) : repository = repository ?? BestEffortsRepository();

  final CurveSport sport;
  final BestEffortsRepository repository;
  final DateTime? today;

  @override
  State<BestEffortsScreen> createState() => _BestEffortsScreenState();
}

class _BestEffortsScreenState extends State<BestEffortsScreen> {
  /// Twelve 30-day windows, plus the 90 days the rolling best looks back.
  static const _fetchDays = 12 * 30 + 90;

  late CurveSport _sport = widget.sport == CurveSport.run
      ? CurveSport.run
      : CurveSport.ride;
  int _point = 1;
  bool _loading = true;
  Object? _error;
  List<EffortSession> _sessions = const [];

  bool get _isRide => _sport == CurveSport.ride;
  DateTime get _today => widget.today ?? DateTime.now();
  int get _points => _isRide ? effortSeconds.length : effortDistances.length;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool force = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await widget.repository.load(
        _sport,
        _fetchDays,
        force: force,
      );
      if (!mounted) return;
      setState(() {
        _sessions = rows;
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

  String _pointLabel(int i) => _isRide
      ? formatCurveDuration(effortSeconds[i].toDouble())
      : formatCurveDistance(effortDistances[i]);

  /// A value as the athlete reads it: watts, or a pace for the distance.
  String _format(double v, int point) {
    if (_isRide) return '${v.round()} W';
    return formatPace(effortDistances[point] / v, per: 1000);
  }

  void _openOptions(AppLocalizations l10n) {
    showChartOptions(
      context,
      title: l10n.beTitle,
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
                apply(() {
                  _sport = s.first;
                  _point = 1;
                  _sessions = const [];
                });
                _load();
              },
            ),
          ),
          OptionGroup(
            label: l10n.beColEffort,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var i = 0; i < _points; i++)
                  ChoiceChip(
                    key: ValueKey('be-point-$i'),
                    label: Text(_pointLabel(i)),
                    selected: _point == i,
                    onSelected: (_) => apply(() => _point = i),
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
    final theme = Theme.of(context);
    final lower = lowerIsBetter(_sport);
    final point = _point.clamp(0, _points - 1);
    final windows = progression(_sessions, point, _today, lower: lower);
    final deltas = effortDeltas(_sessions, _points, _today, lower: lower);
    final locale = Localizations.localeOf(context).toString();

    // Plot watts as they are and pace as speed, so faster is always higher.
    double? plot(double? v) =>
        v == null ? null : (_isRide ? v : effortDistances[point] / v);
    final series = [
      ChartSeries(
        label: l10n.beWindowBest,
        color: theme.colorScheme.primary,
        average: false,
        strokeWidth: 2.8,
        values: [for (final w in windows) plot(w.best)],
      ),
      ChartSeries(
        label: l10n.beRollingBest,
        color: theme.colorScheme.tertiary,
        average: false,
        strokeWidth: 1.6,
        opacity: 0.8,
        values: [for (final w in windows) plot(w.rollingBest)],
      ),
    ];
    final hasData = _sessions.any((s) => s.values.any((v) => v != null));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.beTitle),
        actions: [
          ChartOptionsButton(
            summary:
                '${_isRide ? l10n.anSportRide : l10n.anSportRun} · ${_pointLabel(point)}',
            onPressed: () => _openOptions(l10n),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_error != null)
                  Text(l10n.beError('$_error'))
                else if (!hasData)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(l10n.beNoData, textAlign: TextAlign.center),
                  )
                else ...[
                  SectionCard(
                    icon: Icons.trending_up,
                    title: '${l10n.beTitle} · ${_pointLabel(point)}',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 200,
                          child: MetricLineChart(
                            key: ValueKey('be-chart-$_sport-$point'),
                            series: series,
                            labels: [
                              for (final w in windows)
                                DateFormat.MMMd(locale).format(w.end),
                            ],
                            labelEvery: 3,
                            showAverage: false,
                            smooth: false,
                            zoomable: false,
                            formatValue: (v) => _isRide
                                ? '${v.round()} W'
                                : formatPace(v, per: 1000),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ChartLegend(series: series),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SectionCard(
                    icon: Icons.compare_arrows,
                    title: l10n.beTableTitle,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _table(context, l10n, deltas),
                        const SizedBox(height: 8),
                        Text(
                          l10n.beHint,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _table(
    BuildContext context,
    AppLocalizations l10n,
    List<EffortDelta> deltas,
  ) {
    final theme = Theme.of(context);
    Widget cell(
      String text, {
      Color? color,
      bool head = false,
      bool bold = false,
    }) => Expanded(
      child: Text(
        text,
        textAlign: TextAlign.end,
        style: (head ? theme.textTheme.labelSmall : theme.textTheme.bodySmall)
            ?.copyWith(
              color:
                  color ?? (head ? theme.colorScheme.onSurfaceVariant : null),
              fontWeight: bold ? FontWeight.w700 : null,
            ),
      ),
    );
    Color changeColor(double c) => c > 0.005
        ? Colors.green.shade600
        : c < -0.005
        ? theme.colorScheme.error
        : theme.colorScheme.onSurfaceVariant;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.beColEffort,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            cell(l10n.beColNow, head: true),
            cell(l10n.beColBefore, head: true),
            cell(l10n.beColChange, head: true),
          ],
        ),
        const Divider(height: 10),
        for (var i = 0; i < deltas.length; i++)
          Padding(
            key: ValueKey('be-row-$i'),
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _pointLabel(i),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                cell(
                  deltas[i].current == null
                      ? '–'
                      : _format(deltas[i].current!, i),
                  bold: true,
                ),
                cell(
                  deltas[i].baseline == null
                      ? '–'
                      : _format(deltas[i].baseline!, i),
                ),
                cell(
                  deltas[i].improvement == null
                      ? '–'
                      : '${deltas[i].improvement! > 0 ? '+' : ''}'
                            '${(deltas[i].improvement! * 100).toStringAsFixed(1)}%',
                  color: deltas[i].improvement == null
                      ? null
                      : changeColor(deltas[i].improvement!),
                  bold: true,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
