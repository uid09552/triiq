import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../client/intervalls/intervalls_client.dart';
import '../../data/intervals_session.dart';
import '../../data/repositories/activities_repository.dart';
import '../../evaluation/performance_curves.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/charts/duration_curve_chart.dart';
import '../../widgets/charts/line_chart.dart';
import '../../widgets/section_card.dart';
import '../activities/activity_detail_screen.dart';
import 'threshold_suggestion_card.dart';

/// Best efforts over every duration (power, heart rate) or distance (pace)
/// for one sport, this season against last season and the last 42 days,
/// with the model Intervals.icu fits next to the athlete's settings.
///
/// Curves come from [PerformanceCurvesRepository]: the cached copy shows
/// straight away, and a fetch only happens when nothing is cached or a newer
/// activity of the sport has been synced since. A failed fetch keeps
/// whatever was cached on screen.
class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({
    super.key,
    this.repository,
    this.activities,
    this.settingsForSport,
  });

  /// Test seams; the app uses the defaults.
  final PerformanceCurvesRepository? repository;
  final ActivitiesRepository? activities;
  final SportSettings? Function(String sport)? settingsForSport;

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

/// Which metrics a sport offers, most useful first. Running power only
/// stays if the account has any.
const _metricsBySport = {
  CurveSport.ride: [CurveMetric.power, CurveMetric.hr],
  CurveSport.run: [CurveMetric.pace, CurveMetric.power, CurveMetric.hr],
  CurveSport.swim: [CurveMetric.pace, CurveMetric.hr],
};

class _PerformanceScreenState extends State<PerformanceScreen> {
  late final _repository = widget.repository ?? PerformanceCurvesRepository();
  late final _activities = widget.activities ?? ActivitiesRepository();

  CurveSport _sport = CurveSport.ride;
  CurveMetric _metric = CurveMetric.power;
  PerformanceCurves? _curves;
  bool _loading = false;
  Object? _error;
  double? _selectedX;

  /// Metrics that came back empty for a sport, so they are no longer offered.
  final _empty = <(CurveSport, CurveMetric)>{};

  /// Guards against a slow response for a sport the athlete already left.
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  List<CurveMetric> get _metrics => [
    for (final m in _metricsBySport[_sport]!)
      if (!_empty.contains((_sport, m)) || m == _metric) m,
  ];

  Future<void> _load({bool force = false}) async {
    final generation = ++_generation;
    final sport = _sport;
    final metric = _metric;
    final cached = await _repository.cached(sport, metric);
    if (!mounted || generation != _generation) return;
    setState(() {
      _curves = cached;
      _error = null;
      _selectedX = null;
    });
    if (!force && cached != null && !await _repository.isStale(sport, metric)) {
      _afterLoad(cached);
      return;
    }
    if (!mounted || generation != _generation) return;
    setState(() => _loading = true);
    try {
      final curves = await _repository.load(sport, metric, force: force);
      if (!mounted || generation != _generation) return;
      setState(() {
        _curves = curves;
        _loading = false;
      });
      _afterLoad(curves);
    } catch (error) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  /// A metric with no data for this sport (running power, usually) drops
  /// out, and the first one that has data is shown instead.
  void _afterLoad(PerformanceCurves curves) {
    if (!curves.isEmpty) return;
    final key = (curves.sport, curves.metric);
    if (_empty.contains(key)) return;
    _empty.add(key);
    final fallback = _metricsBySport[_sport]!.firstWhere(
      (m) => !_empty.contains((_sport, m)),
      orElse: () => _metric,
    );
    if (fallback != _metric) {
      setState(() => _metric = fallback);
      _load();
    } else {
      setState(() {});
    }
  }

  void _selectSport(CurveSport sport) {
    setState(() {
      _sport = sport;
      _metric = _metricsBySport[sport]!.firstWhere(
        (m) => !_empty.contains((sport, m)),
        orElse: () => _metricsBySport[sport]!.first,
      );
    });
    _load();
  }

  void _selectMetric(CurveMetric metric) {
    setState(() => _metric = metric);
    _load();
  }

  String _periodLabel(AppLocalizations l10n, String id) => switch (id) {
    's0' => l10n.curvePeriodThisSeason,
    's1' => l10n.curvePeriodLastSeason,
    '42d' => l10n.curvePeriodLast42,
    _ => id,
  };

  Color _periodColor(ColorScheme scheme, String id) => switch (id) {
    's0' => scheme.primary,
    's1' => scheme.tertiary,
    _ => scheme.secondary,
  };

  String _metricLabel(AppLocalizations l10n, CurveMetric metric) =>
      switch (metric) {
        CurveMetric.power => l10n.curveMetricPower,
        CurveMetric.pace => l10n.curveMetricPace,
        CurveMetric.hr => l10n.curveMetricHr,
      };

  String _sportLabel(AppLocalizations l10n, CurveSport sport) =>
      switch (sport) {
        CurveSport.ride => l10n.sportRide,
        CurveSport.run => l10n.sportRun,
        CurveSport.swim => l10n.sportSwim,
      };

  String get _paceUnit => _sport == CurveSport.swim ? 'min/100 m' : 'min/km';

  String _formatX(double x) =>
      _metric.byDistance ? formatCurveDistance(x) : formatCurveDuration(x);

  /// A plotted value (watts, bpm, or speed for pace) in its display unit.
  String _formatPlot(double y) => switch (_metric) {
    CurveMetric.power => '${y.round()}',
    CurveMetric.hr => '${y.round()}',
    CurveMetric.pace => formatPace(y, per: paceUnitMetres(_sport)),
  };

  /// A curve point's value with its unit: "312 W", "176 bpm", "4:05 /km".
  String _formatPoint(CurvePoint p) => switch (_metric) {
    CurveMetric.power => '${p.value.round()} W',
    CurveMetric.hr => '${p.value.round()} bpm',
    CurveMetric.pace =>
      '${formatPace(p.x / p.value, per: paceUnitMetres(_sport))} '
          '${_sport == CurveSport.swim ? '/100 m' : '/km'}',
  };

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
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ActivityDetailScreen(activity: activity),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final curves = _curves;
    final connected =
        widget.repository != null || IntervalsSession.instance.isConnected;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.performanceTitle),
        actions: [
          IconButton(
            tooltip: l10n.retryButton,
            onPressed: _loading || !connected ? null : () => _load(force: true),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ThresholdSuggestionsSection(),
              SegmentedButton<CurveSport>(
                segments: [
                  for (final sport in CurveSport.values)
                    ButtonSegment(
                      value: sport,
                      label: Text(_sportLabel(l10n, sport)),
                    ),
                ],
                selected: {_sport},
                onSelectionChanged: (s) => _selectSport(s.first),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final metric in _metrics)
                    ChoiceChip(
                      label: Text(_metricLabel(l10n, metric)),
                      selected: metric == _metric,
                      onSelected: (_) => _selectMetric(metric),
                    ),
                ],
              ),
              if (_loading) ...[
                const SizedBox(height: 12),
                const LinearProgressIndicator(),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Card(
                  color: colorScheme.errorContainer,
                  child: ListTile(
                    leading: Icon(
                      Icons.error_outline,
                      color: colorScheme.onErrorContainer,
                    ),
                    title: Text(
                      connected
                          ? l10n.curvesLoadFailed('$_error')
                          : l10n.statsNotConnected,
                      style: TextStyle(color: colorScheme.onErrorContainer),
                    ),
                    trailing: connected
                        ? TextButton(
                            onPressed: () => _load(force: true),
                            child: Text(l10n.retryButton),
                          )
                        : null,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              if (curves != null && !curves.isEmpty) ...[
                _chartCard(context, curves),
                const SizedBox(height: 16),
                _keyEffortsCard(context, curves),
                if (_metric != CurveMetric.hr) ...[
                  const SizedBox(height: 16),
                  _modelCard(context, curves),
                ],
              ] else if (!_loading && _error == null)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    curves == null && !connected
                        ? l10n.statsNotConnected
                        : l10n.curvesEmpty,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chartCard(BuildContext context, PerformanceCurves curves) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    String dateLabel(String? date) => date == null
        ? '?'
        : DateFormat.yMMMd(locale).format(DateTime.parse(date));

    final series = <CurveSeries>[];
    final legend = <ChartSeries>[];
    for (final id in curvePeriodIds) {
      final period = curves.period(id);
      final label = _periodLabel(l10n, id);
      final color = _periodColor(colorScheme, id);
      if (period == null || period.isEmpty) {
        legend.add(
          ChartSeries(
            label: l10n.curvePeriodNoData(label),
            color: color.withValues(alpha: 0.3),
            values: const [],
          ),
        );
        continue;
      }
      series.add(
        CurveSeries(
          label: label,
          color: color,
          points: downsampleLog(period.points, _metric),
        ),
      );
      legend.add(
        ChartSeries(
          label: period.start != null && period.end != null
              ? l10n.curvePeriodRange(
                  label,
                  dateLabel(period.start),
                  dateLabel(period.end),
                )
              : label,
          color: color,
          values: const [],
        ),
      );
    }

    final selected = _selectedX;
    final readout = <Widget>[];
    if (selected == null) {
      readout.add(
        Text(
          l10n.curveTapHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    } else {
      readout.add(Text(_formatX(selected), style: theme.textTheme.titleSmall));
      for (final id in curvePeriodIds) {
        final point = curves.period(id)?.at(selected);
        if (point == null) continue;
        final activityId = point.activityId;
        final activity = activityId == null
            ? null
            : curves.activities[activityId];
        readout.add(
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _periodColor(colorScheme, id),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  [
                    _formatPoint(point),
                    if (activity?.date != null) dateLabel(activity!.date),
                    ?activity?.name,
                  ].join(' · '),
                  style: theme.textTheme.bodySmall,
                ),
              ),
              if (activityId != null)
                TextButton(
                  onPressed: () => _openSession(activityId),
                  child: Text(l10n.curveOpenSession),
                ),
            ],
          ),
        );
      }
    }

    return SectionCard(
      icon: Icons.trending_up,
      title: '${_sportLabel(l10n, _sport)} · ${_metricLabel(l10n, _metric)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 240,
            child: DurationCurveChart(
              series: series,
              metric: _metric,
              ticks: curveTicks(_sport, _metric),
              formatX: _formatX,
              formatY: _formatPlot,
              xTitle: _metric.byDistance
                  ? l10n.curveAxisDistance
                  : l10n.curveAxisDuration,
              yTitle: switch (_metric) {
                CurveMetric.power => l10n.curveAxisPower,
                CurveMetric.hr => l10n.curveAxisHr,
                CurveMetric.pace => l10n.curveAxisPace(_paceUnit),
              },
              selectedX: selected,
              onSelect: (x) => setState(() => _selectedX = x),
            ),
          ),
          const SizedBox(height: 12),
          ChartLegend(series: legend),
          const SizedBox(height: 12),
          ...readout,
        ],
      ),
    );
  }

  Widget _keyEffortsCard(BuildContext context, PerformanceCurves curves) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final current = curves.period('s0');
    final previous = curves.period('s1');

    String delta(CurvePoint? now, CurvePoint? before) {
      if (now == null || before == null) return '';
      if (_metric.byDistance) {
        // Seconds per pace unit; negative is faster.
        final unit = paceUnitMetres(_sport);
        final diff = (now.value / now.x * unit - before.value / before.x * unit)
            .round();
        return diff == 0 ? '±0 s' : '${diff > 0 ? '+' : '−'}${diff.abs()} s';
      }
      final diff = (now.value - before.value).round();
      return diff == 0 ? '±0' : '${diff > 0 ? '+' : '−'}${diff.abs()}';
    }

    TableRow row(List<String> cells, {bool header = false}) => TableRow(
      children: [
        for (var i = 0; i < cells.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              cells[i],
              textAlign: i == 0 ? TextAlign.start : TextAlign.end,
              style: header
                  ? theme.textTheme.labelMedium
                  : theme.textTheme.bodyMedium,
            ),
          ),
      ],
    );

    return SectionCard(
      icon: Icons.emoji_events_outlined,
      title: l10n.keyEffortsTitle,
      child: Table(
        columnWidths: const {0: FlexColumnWidth(1.1)},
        children: [
          row([
            '',
            l10n.curvePeriodThisSeason,
            l10n.curvePeriodLastSeason,
            l10n.keyEffortsChange,
          ], header: true),
          for (final x in curves.keyPoints)
            () {
              final now = current?.at(x);
              final before = previous?.at(x);
              return row([
                _formatX(x),
                now == null ? '' : _formatPoint(now),
                before == null ? '' : _formatPoint(before),
                delta(now, before),
              ]);
            }(),
        ],
      ),
    );
  }

  Widget _modelCard(BuildContext context, PerformanceCurves curves) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final model = curves.period('s0')?.model;
    final settings =
        (widget.settingsForSport ?? IntervalsSession.instance.settingsForSport)(
          _sport.apiType,
        );

    final rows = <(String, String)>[];
    (String, String)? settingsRow;
    String? gap;
    if (_metric == CurveMetric.power) {
      final settingsFtp = settings?.ftp?.toDouble();
      if (model != null) {
        if (model.ftp != null) rows.add(('FTP', '${model.ftp!.round()} W'));
        if (model.criticalPower != null) {
          rows.add(('CP', '${model.criticalPower!.round()} W'));
        }
        if (model.wPrime != null) {
          rows.add(("W'", '${(model.wPrime! / 1000).toStringAsFixed(1)} kJ'));
        }
        if (model.pMax != null) rows.add(('Pmax', '${model.pMax!.round()} W'));
      }
      settingsRow = (
        '${l10n.modelSettingsValue} (FTP)',
        settingsFtp == null
            ? l10n.modelNoSettingsValue
            : '${settingsFtp.round()} W',
      );
      if (model?.ftp != null && settingsFtp != null && settingsFtp > 0) {
        gap = l10n.modelGap(
          '${model!.ftp!.round()} W',
          '${settingsFtp.round()} W',
          _diff(model.ftp! - settingsFtp, model.ftp! / settingsFtp - 1, 'W'),
        );
      }
    } else {
      final unit = paceUnitMetres(_sport);
      final suffix = _sport == CurveSport.swim ? '/100 m' : '/km';
      final settingsSpeed = settings?.thresholdPace;
      if (model?.criticalSpeed != null) {
        rows.add((
          l10n.modelCriticalSpeed,
          '${formatPace(model!.criticalSpeed!, per: unit)} $suffix',
        ));
      }
      if (model?.dPrime != null) {
        rows.add(("D'", '${model!.dPrime!.round()} m'));
      }
      settingsRow = (
        '${l10n.modelSettingsValue} (${l10n.thresholdPaceLabel})',
        settingsSpeed == null || settingsSpeed <= 0
            ? l10n.modelNoSettingsValue
            : '${formatPace(settingsSpeed, per: unit)} $suffix',
      );
      final cs = model?.criticalSpeed;
      if (cs != null && settingsSpeed != null && settingsSpeed > 0) {
        // Seconds per unit; negative = the model is faster than settings.
        final seconds = (unit / cs - unit / settingsSpeed).round();
        gap = l10n.modelGap(
          formatPace(cs, per: unit),
          formatPace(settingsSpeed, per: unit),
          '${seconds > 0
              ? '+'
              : seconds < 0
              ? '−'
              : '±'}${seconds.abs()} s'
          '$suffix (${_percent(cs / settingsSpeed - 1)})',
        );
      }
    }

    return SectionCard(
      icon: Icons.functions,
      title: l10n.modelCardTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (model == null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l10n.modelNone,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          LayoutBuilder(
            builder: (context, constraints) {
              // As many tiles per row as fit: the card uses its full width
              // instead of a label on the far left and a value on the far
              // right of a wide window.
              const spacing = 8.0;
              final all = [...rows, ?settingsRow];
              final columns = (constraints.maxWidth / 150).floor().clamp(
                1,
                all.length < 4 ? all.length : 4,
              );
              final tileWidth =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final (label, value) in all)
                    _ModelTile(
                      key: ValueKey('model-$label'),
                      width: tileWidth,
                      label: label,
                      value: value,
                      highlight: settingsRow != null && label == settingsRow.$1,
                    ),
                ],
              );
            },
          ),
          if (gap != null) ...[
            const SizedBox(height: 12),
            Container(
              key: const ValueKey('model-gap'),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.compare_arrows,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(gap, style: theme.textTheme.bodyMedium)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _percent(double fraction) {
    final p = (fraction * 100).round();
    return '${p > 0
        ? '+'
        : p < 0
        ? '−'
        : '±'}${p.abs()}%';
  }

  static String _diff(double absolute, double fraction, String unit) {
    final a = absolute.round();
    return '${a > 0
            ? '+'
            : a < 0
            ? '−'
            : '±'}${a.abs()} $unit '
        '(${_percent(fraction)})';
  }
}

/// One model figure (FTP, CP, W′, Pmax, critical pace, or the value in the
/// athlete's settings) as a small tile: the label above, the value large.
class _ModelTile extends StatelessWidget {
  const _ModelTile({
    super.key,
    required this.width,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final double width;
  final String label;
  final String value;

  /// The settings value, drawn with an outline to tell it from the fitted ones.
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: highlight ? Colors.transparent : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight
              ? scheme.outline
              : scheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
