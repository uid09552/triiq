import 'dart:math' as math;

import '../../data/repositories/activities_repository.dart';
import '../../data/repositories/wellness_repository.dart';
import '../../util/dates.dart';
import '../../widgets/stat_tile.dart';
import 'tile_metric.dart';

/// A tile's tiny chart: the recent values and which way they are heading.
class TileSpark {
  const TileSpark(this.values, this.trend);

  final List<double> values;
  final StatTrend trend;
}

/// Which way [from] → [to] went. Within a small band (3 % of the larger
/// value, at least [minBand]) it counts as flat, so noise doesn't flip an
/// arrow.
StatTrend trendBetween(double from, double to, {double minBand = 0.5}) {
  final band = math.max(minBand, 0.03 * math.max(from.abs(), to.abs()));
  final d = to - from;
  if (d.abs() <= band) return StatTrend.flat;
  return d > 0 ? StatTrend.up : StatTrend.down;
}

double _mean(Iterable<double> v) => v.reduce((a, b) => a + b) / v.length;

/// Trend of a daily series: the last value against the value a week
/// earlier (or the first one available), ignoring gaps. Needs 2 values.
StatTrend? lineTrend(List<double?> series) {
  final values = series.whereType<double>().toList();
  if (values.length < 2) return null;
  final last = values.last;
  final ref = values.length > 7 ? values[values.length - 8] : values.first;
  return trendBetween(ref, last);
}

/// Trend of per-day load: the last 7 days' average against the 7 before.
StatTrend? loadTrend(List<double> daily) {
  if (daily.length < 14) return null;
  final recent = _mean(daily.sublist(daily.length - 7));
  final before = _mean(daily.sublist(daily.length - 14, daily.length - 7));
  return trendBetween(before, recent, minBand: 5);
}

/// Trend of weekly totals: the last *finished* week against the one before
/// it (the current week is still filling up, so it would always look low).
StatTrend? weeklyTrend(List<double> weekly) {
  if (weekly.length < 3) return null;
  final last = weekly[weekly.length - 2];
  final before = weekly[weekly.length - 3];
  return trendBetween(before, last, minBand: 10);
}

/// Reads the cache for the sparklines on Today's six tiles.
class TileSparkLoader {
  TileSparkLoader({
    WellnessRepository? wellness,
    ActivitiesRepository? activities,
    DateTime Function()? clock,
  }) : _wellness = wellness ?? WellnessRepository(),
       _activities = activities ?? ActivitiesRepository(),
       _clock = clock ?? DateTime.now;

  final WellnessRepository _wellness;
  final ActivitiesRepository _activities;
  final DateTime Function() _clock;

  static const lineDays = 14;
  static const weeks = 6;

  Future<Map<TileMetric, TileSpark>> load() async {
    final today = dateOnly(_clock());
    final out = <TileMetric, TileSpark>{};

    final lineStart = today.subtract(const Duration(days: lineDays - 1));
    final records = await _wellness.getRange(
      isoDate(lineStart),
      isoDate(today),
    );
    final byDate = {for (final r in records) r.date: r};
    List<double?> series(double? Function(dynamic r) read) => [
      for (var i = 0; i < lineDays; i++)
        read(byDate[isoDate(lineStart.add(Duration(days: i)))]),
    ];
    void line(TileMetric m, double? Function(dynamic r) read) {
      final s = series(read);
      final trend = lineTrend(s);
      final values = s.whereType<double>().toList();
      if (trend != null && values.length >= 2)
        out[m] = TileSpark(values, trend);
    }

    line(TileMetric.ctl, (r) => r?.ctl as double?);
    line(TileMetric.atl, (r) => r?.atl as double?);
    line(TileMetric.rampRate, (r) => r?.rampRate as double?);
    line(
      TileMetric.form,
      (r) => r?.ctl != null && r?.atl != null
          ? (r.ctl as double) - (r.atl as double)
          : null,
    );

    final weekStart = startOfWeek(
      today,
    ).subtract(const Duration(days: 7 * (weeks - 1)));
    final from = weekStart.isBefore(lineStart) ? weekStart : lineStart;
    final activities = await _activities.getRange(
      isoDate(from),
      isoDate(today),
    );
    final daily = List<double>.filled(lineDays, 0);
    final weekly = List<double>.filled(weeks, 0);
    for (final a in activities) {
      final d = DateTime.tryParse(a.date);
      if (d == null) continue;
      final day = dateOnly(d);
      final load = (a.trainingLoad ?? 0).toDouble();
      final di = day.difference(lineStart).inDays;
      if (di >= 0 && di < lineDays) daily[di] += load;
      final wi = day.difference(weekStart).inDays ~/ 7;
      if (wi >= 0 && wi < weeks) weekly[wi] += load;
    }
    final dt = loadTrend(daily);
    if (dt != null) out[TileMetric.tssToday] = TileSpark(daily, dt);
    final wt = weeklyTrend(weekly);
    if (wt != null) out[TileMetric.tssWeek] = TileSpark(weekly, wt);
    return out;
  }
}
