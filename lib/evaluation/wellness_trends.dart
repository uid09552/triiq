import 'dart:math' as math;

import '../data/models/local_wellness.dart';
import '../util/dates.dart';

/// The wellness figures with a long-term trend: what the readiness screen's
/// 30-day chart shows (HRV, resting HR) plus sleep and weight, over any range.
enum WellnessMetric { hrv, restingHr, sleep, weight }

/// One day's value of [metric], or null when it wasn't recorded. A wearable
/// writes 0 for "not measured", so zero and below count as missing. Sleep is
/// in hours, weight in kg.
double? wellnessValue(LocalWellness r, WellnessMetric metric) {
  double? positive(Object? raw) {
    final v = raw is num ? raw.toDouble() : null;
    return v == null || v <= 0 ? null : v;
  }

  return switch (metric) {
    WellnessMetric.hrv => positive(r.raw['hrv']),
    WellnessMetric.restingHr => positive(r.raw['restingHR']),
    WellnessMetric.sleep => switch (positive(r.raw['sleepSecs'])) {
      final secs? => secs / 3600,
      null => null,
    },
    WellnessMetric.weight => positive(r.raw['weight']),
  };
}

/// [metric] for each of [days], in order.
List<double?> dailyValues(
  Iterable<LocalWellness> records,
  List<DateTime> days,
  WellnessMetric metric,
) {
  final byDate = {for (final r in records) r.date: r};
  return [
    for (final d in days)
      () {
        final r = byDate[isoDate(d)];
        return r == null ? null : wellnessValue(r, metric);
      }(),
  ];
}

/// The mean of the values recorded in the last [window] entries up to and
/// including each one — a missing day doesn't break the line, it just has
/// fewer neighbours. Null while fewer than [minCount] values have been seen.
List<double?> trailingAverage(
  List<double?> values, {
  int window = 7,
  int minCount = 2,
}) {
  final out = <double?>[];
  for (var i = 0; i < values.length; i++) {
    var sum = 0.0, count = 0;
    for (var k = math.max(0, i - window + 1); k <= i; k++) {
      final v = values[k];
      if (v != null) {
        sum += v;
        count++;
      }
    }
    out.add(count >= minCount ? sum / count : null);
  }
  return out;
}

/// The athlete's normal range for a metric: the mean and one standard
/// deviation either side, over the values given. Null with fewer than
/// [minCount] values — too little to call anything normal.
class BaselineBand {
  const BaselineBand(this.mean, this.sd);

  final double mean;
  final double sd;

  double get low => mean - sd;
  double get high => mean + sd;

  bool contains(double v) => v >= low && v <= high;
}

BaselineBand? baselineBand(List<double?> values, {int minCount = 14}) {
  final v = values.whereType<double>().toList();
  if (v.length < minCount) return null;
  final mean = v.reduce((a, b) => a + b) / v.length;
  final variance =
      v.fold<double>(0, (s, x) => s + (x - mean) * (x - mean)) / (v.length - 1);
  return BaselineBand(mean, math.sqrt(variance));
}

/// Where the latest value stands against the baseline.
enum BandPosition { below, within, above }

class WellnessTrend {
  const WellnessTrend({
    required this.metric,
    required this.days,
    required this.daily,
    required this.average,
    this.band,
  });

  final WellnessMetric metric;
  final List<DateTime> days;
  final List<double?> daily;

  /// The 7-day trailing average, same length as [daily].
  final List<double?> average;
  final BaselineBand? band;

  bool get hasData => daily.any((v) => v != null);

  /// The most recent recorded value and its day.
  (DateTime, double)? get latest {
    for (var i = daily.length - 1; i >= 0; i--) {
      final v = daily[i];
      if (v != null) return (days[i], v);
    }
    return null;
  }

  /// The last 7-day average.
  double? get latestAverage {
    for (var i = average.length - 1; i >= 0; i--) {
      final v = average[i];
      if (v != null) return v;
    }
    return null;
  }

  /// The 7-day average now against a week earlier (absolute change), or null.
  double? get weekChange {
    final now = latestAverage;
    if (now == null) return null;
    final lastIdx = average.lastIndexWhere((v) => v != null);
    final before = lastIdx - 7 >= 0 ? average[lastIdx - 7] : null;
    return before == null ? null : now - before;
  }

  BandPosition? get position {
    final b = band, v = latestAverage;
    if (b == null || v == null) return null;
    return v < b.low
        ? BandPosition.below
        : v > b.high
        ? BandPosition.above
        : BandPosition.within;
  }
}

/// The trend of [metric] over the [rangeDays] ending [today].
WellnessTrend wellnessTrend(
  Iterable<LocalWellness> records,
  WellnessMetric metric,
  DateTime today,
  int rangeDays,
) {
  final end = dateOnly(today);
  final days = [
    for (var i = rangeDays - 1; i >= 0; i--)
      DateTime(end.year, end.month, end.day - i),
  ];
  final daily = dailyValues(records, days, metric);
  return WellnessTrend(
    metric: metric,
    days: days,
    daily: daily,
    average: trailingAverage(daily),
    band: baselineBand(daily),
  );
}
