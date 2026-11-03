import 'dart:math' as math;

/// Summary of a series with gaps (`null` entries are ignored).
class SeriesStats {
  const SeriesStats({
    required this.count,
    required this.mean,
    required this.min,
    required this.minIndex,
    required this.max,
    required this.maxIndex,
    required this.stdDev,
    required this.change,
  });

  /// How many non-null values.
  final int count;
  final double mean;
  final double min;
  final int minIndex;
  final double max;
  final int maxIndex;

  /// Sample standard deviation (0 for a single value).
  final double stdDev;

  /// Last non-null value minus the first.
  final double change;
}

/// Statistics of [values], or `null` when there is nothing to summarise.
SeriesStats? computeStats(List<double?> values) {
  var count = 0;
  var sum = 0.0;
  int? minI, maxI;
  double? first, last;
  for (var i = 0; i < values.length; i++) {
    final v = values[i];
    if (v == null) continue;
    count++;
    sum += v;
    first ??= v;
    last = v;
    if (minI == null || v < values[minI]!) minI = i;
    if (maxI == null || v > values[maxI]!) maxI = i;
  }
  if (count == 0) return null;
  final mean = sum / count;
  var squares = 0.0;
  for (final v in values) {
    if (v != null) squares += (v - mean) * (v - mean);
  }
  return SeriesStats(
    count: count,
    mean: mean,
    min: values[minI!]!,
    minIndex: minI,
    max: values[maxI!]!,
    maxIndex: maxI,
    stdDev: count > 1 ? math.sqrt(squares / (count - 1)) : 0,
    change: last! - first!,
  );
}

/// The mean of the last [window] entries up to each point, ignoring gaps —
/// a trailing rolling average. A point with no value in its window stays a
/// gap; a window of 1 or less returns [values] unchanged.
List<double?> trailingMean(List<double?> values, int window) {
  if (window <= 1) return values;
  return [
    for (var i = 0; i < values.length; i++)
      () {
        var sum = 0.0;
        var n = 0;
        for (var j = math.max(0, i - window + 1); j <= i; j++) {
          final v = values[j];
          if (v == null) continue;
          sum += v;
          n++;
        }
        return n == 0 ? null : sum / n;
      }(),
  ];
}
