import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../data/repositories/activities_repository.dart';
import '../../data/repositories/wellness_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../util/dates.dart';
import '../../widgets/charts/bar_chart.dart';
import '../../widgets/charts/line_chart.dart';

/// The figures on Today's tiles that have a graph behind them.
enum TileMetric { tssToday, tssWeek, ctl, atl, form, rampRate }

String tileMetricExplainer(AppLocalizations l10n, TileMetric metric) =>
    switch (metric) {
      TileMetric.tssToday => l10n.metricTssTodayExplainer,
      TileMetric.tssWeek => l10n.metricTssWeekExplainer,
      TileMetric.ctl => l10n.metricCtlExplainer,
      TileMetric.atl => l10n.metricAtlExplainer,
      TileMetric.form => l10n.metricFormExplainer,
      TileMetric.rampRate => l10n.metricRampExplainer,
    };

/// A small graph of one tile's metric from the local cache: daily load bars
/// for TSS today, weekly bars for TSS week, a filled line (with its Ø) over
/// the last 30 days for the Intervals.icu load figures.
class MetricPreview extends StatefulWidget {
  const MetricPreview({
    super.key,
    required this.metric,
    required this.color,
    this.height = 96,
    this.interactive = false,
    this.wellness,
    this.activities,
  });

  final TileMetric metric;
  final Color color;
  final double height;

  /// Lets the line chart zoom and scrub (the long-press sheet); the hover
  /// card is look-only.
  final bool interactive;

  /// Test seams; the app uses the defaults.
  final WellnessRepository? wellness;
  final ActivitiesRepository? activities;

  @override
  State<MetricPreview> createState() => _MetricPreviewState();
}

class _MetricPreviewState extends State<MetricPreview> {
  late final Future<Widget Function(BuildContext)> _future = _load();

  Future<Widget Function(BuildContext)> _load() async {
    final today = dateOnly(DateTime.now());
    switch (widget.metric) {
      case TileMetric.tssToday:
        const days = 14;
        final start = today.subtract(const Duration(days: days - 1));
        final records = await (widget.activities ?? ActivitiesRepository())
            .getRange(isoDate(start), isoDate(today));
        final byDay = <String, int>{};
        for (final a in records) {
          byDay[a.date] = (byDay[a.date] ?? 0) + (a.trainingLoad ?? 0);
        }
        return (context) {
          final locale = Localizations.localeOf(context).toString();
          return SizedBox(
            height: widget.height,
            child: SimpleBarChart(
              bars: [
                for (var i = 0; i < days; i++)
                  ChartBar(
                    label: DateFormat.Md(locale).format(
                      start.add(Duration(days: i)),
                    ),
                    value:
                        (byDay[isoDate(start.add(Duration(days: i)))] ?? 0)
                            .toDouble(),
                    highlighted: i == days - 1,
                  ),
              ],
              labelEvery: 4,
              barColor: widget.color,
            ),
          );
        };
      case TileMetric.tssWeek:
        const weeks = 8;
        final thisWeek = startOfWeek(today);
        final start = thisWeek.subtract(const Duration(days: 7 * (weeks - 1)));
        final records = await (widget.activities ?? ActivitiesRepository())
            .getRange(isoDate(start), isoDate(today));
        final perWeek = List<int>.filled(weeks, 0);
        for (final a in records) {
          final d = DateTime.tryParse(a.date);
          if (d == null) continue;
          final index = dateOnly(d).difference(start).inDays ~/ 7;
          if (index >= 0 && index < weeks) {
            perWeek[index] += a.trainingLoad ?? 0;
          }
        }
        return (context) {
          final locale = Localizations.localeOf(context).toString();
          return SizedBox(
            height: widget.height,
            child: SimpleBarChart(
              bars: [
                for (var i = 0; i < weeks; i++)
                  ChartBar(
                    label: DateFormat.Md(locale).format(
                      start.add(Duration(days: 7 * i)),
                    ),
                    value: perWeek[i].toDouble(),
                    highlighted: i == weeks - 1,
                  ),
              ],
              labelEvery: 2,
              barColor: widget.color,
            ),
          );
        };
      case TileMetric.ctl:
      case TileMetric.atl:
      case TileMetric.form:
      case TileMetric.rampRate:
        const days = 30;
        final start = today.subtract(const Duration(days: days - 1));
        final records = await (widget.wellness ?? WellnessRepository())
            .getRange(isoDate(start), isoDate(today));
        final byDate = {for (final r in records) r.date: r};
        final values = <double?>[
          for (var i = 0; i < days; i++)
            switch (widget.metric) {
              TileMetric.ctl => byDate[isoDate(start.add(Duration(days: i)))]?.ctl,
              TileMetric.atl => byDate[isoDate(start.add(Duration(days: i)))]?.atl,
              TileMetric.rampRate =>
                byDate[isoDate(start.add(Duration(days: i)))]?.rampRate,
              _ => () {
                final r = byDate[isoDate(start.add(Duration(days: i)))];
                return r?.ctl != null && r?.atl != null
                    ? r!.ctl! - r.atl!
                    : null;
              }(),
            },
        ];
        return (context) {
          final locale = Localizations.localeOf(context).toString();
          return SizedBox(
            height: widget.height,
            child: MetricLineChart(
              series: [
                ChartSeries(
                  label: '',
                  color: widget.color,
                  values: values,
                  fill: true,
                ),
              ],
              labels: [
                for (var i = 0; i < days; i++)
                  DateFormat.Md(locale).format(start.add(Duration(days: i))),
              ],
              labelEvery: 10,
              zeroLine:
                  widget.metric == TileMetric.form ||
                  widget.metric == TileMetric.rampRate,
              zoomable: widget.interactive,
            ),
          );
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget Function(BuildContext)>(
      future: _future,
      builder: (context, snap) {
        if (snap.hasError) return const SizedBox.shrink();
        final build = snap.data;
        if (build == null) {
          return SizedBox(
            height: widget.height,
            child: const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: build(context),
        );
      },
    );
  }
}
