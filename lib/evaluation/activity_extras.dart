import 'dart:math' as math;

import 'session_streams.dart';

/// Extras on top of an activity's streams: how time was spread across power
/// (or pace), how variable the effort was, and how each interval held up.
/// Pure — the activity page loads the streams and draws what comes back.

/// Time spent in one band of the stream: [lo] up to (excluding) [hi], in the
/// stream's own unit (watts, or m/s for pace).
class HistogramBin {
  const HistogramBin(this.lo, this.hi, this.seconds);

  final double lo;
  final double hi;
  final double seconds;

  double get mid => (lo + hi) / 2;
}

class Histogram {
  const Histogram({
    required this.bins,
    required this.zeroSeconds,
    required this.totalSeconds,
  });

  /// Only bins with time in them, lowest first.
  final List<HistogramBin> bins;

  /// Seconds at zero (coasting, stopped, no signal), kept out of [bins].
  final double zeroSeconds;
  final double totalSeconds;

  bool get isEmpty => bins.isEmpty;

  /// The bin holding the most time.
  HistogramBin? get peak => bins.isEmpty
      ? null
      : bins.reduce((a, b) => b.seconds > a.seconds ? b : a);

  /// Share of the non-zero time at or above [value].
  double shareAtLeast(double value) {
    final total = bins.fold<double>(0, (s, b) => s + b.seconds);
    if (total == 0) return 0;
    return bins
            .where((b) => b.lo >= value)
            .fold<double>(0, (s, b) => s + b.seconds) /
        total;
  }
}

/// Time per band of [values] (one sample per entry; [secondsPerSample] each,
/// 1 s for the usual stream). Samples at or below zero and gaps are counted as
/// [Histogram.zeroSeconds]. Bands are [binWidth] wide, starting at a multiple
/// of it.
Histogram histogramOf(
  List<double?> values, {
  required double binWidth,
  double secondsPerSample = 1,
}) {
  final counts = <int, int>{};
  var zero = 0;
  for (final v in values) {
    if (v == null || v <= 0) {
      zero++;
      continue;
    }
    counts.update((v / binWidth).floor(), (c) => c + 1, ifAbsent: () => 1);
  }
  final keys = counts.keys.toList()..sort();
  return Histogram(
    bins: [
      for (final k in keys)
        HistogramBin(
          k * binWidth,
          (k + 1) * binWidth,
          counts[k]! * secondsPerSample,
        ),
    ],
    zeroSeconds: zero * secondsPerSample,
    totalSeconds: values.length * secondsPerSample,
  );
}

/// A sensible band width for the effort: 25 W up to a 600 W peak (50 W
/// beyond), 0.25 m/s for speed.
double binWidthFor(String stream, List<double?> values) {
  if (stream == 'watts') {
    final max = values.whereType<double>().fold<double>(0, math.max);
    return max > 600 ? 50 : 25;
  }
  return 0.25;
}

/// Normalized value of a 1 Hz series: the 4th-power mean of its 30 s rolling
/// average, rooted back — Coggan's normalized power, and the same idea for
/// speed. Null for under 30 s of data.
double? normalizedMean(List<double?> values, {int window = 30}) {
  final v = [for (final x in values) x ?? 0.0];
  if (v.length < window) return null;
  var sum = 0.0;
  for (var i = 0; i < window; i++) {
    sum += v[i];
  }
  var fourth = 0.0;
  var count = 0;
  for (var i = window; i <= v.length; i++) {
    final avg = sum / window;
    fourth += avg * avg * avg * avg;
    count++;
    if (i < v.length) sum += v[i] - v[i - window];
  }
  return math.pow(fourth / count, 0.25).toDouble();
}

/// Variability index: normalized over average. 1.00 is perfectly even;
/// rides above ~1.05 were stop-and-go or surged, a time trial sits near 1.0.
/// Null when there's nothing to average.
double? variabilityIndex(List<double?> values) {
  final v = [for (final x in values) x ?? 0.0];
  if (v.isEmpty) return null;
  final avg = v.reduce((a, b) => a + b) / v.length;
  final np = normalizedMean(values);
  return np == null || avg <= 0 ? null : np / avg;
}

enum VariabilityBand { steady, moderate, variable }

/// Steady (≤ 1.05), moderate (≤ 1.15), variable beyond — the usual cycling
/// reading, applied to pace too.
VariabilityBand variabilityBand(double vi) => vi <= 1.05
    ? VariabilityBand.steady
    : vi <= 1.15
    ? VariabilityBand.moderate
    : VariabilityBand.variable;

/// One interval of the session with how it went.
class IntervalStat {
  const IntervalStat({
    required this.number,
    required this.isWork,
    required this.seconds,
    this.avgOutput,
    this.avgHeartrate,
    this.drift,
    this.fade,
  });

  final int number;
  final bool isWork;
  final int seconds;

  /// Mean watts (rides) or speed in m/s (runs).
  final double? avgOutput;
  final double? avgHeartrate;

  /// Decoupling inside the interval, percent: how much less output per
  /// heartbeat the second half gave than the first. Positive = HR drifted up
  /// against steady effort. Null for intervals under [minDriftSeconds] or
  /// without heart rate.
  final double? drift;

  /// Output against the first work interval, as a fraction (−0.04 = 4 %
  /// down). Null for the first work interval itself and for recoveries.
  final double? fade;
}

/// Intervals shorter than this are too noisy to split in halves.
const minDriftSeconds = 120;

double? _mean(List<double?> v, int from, int to) {
  var sum = 0.0, n = 0;
  for (var i = math.max(0, from); i <= to && i < v.length; i++) {
    final x = v[i];
    if (x != null && x > 0) {
      sum += x;
      n++;
    }
  }
  return n == 0 ? null : sum / n;
}

/// The stats of each interval in [streams] for the effort stream
/// [outputKey] (`watts` or `velocity_smooth`). Interval bounds are sample
/// indexes, as Intervals.icu gives them.
List<IntervalStat> intervalStats(
  SessionStreams streams, {
  required String outputKey,
}) {
  final output = streams.series[outputKey];
  final hr = streams.series['heartrate'];
  if (output == null) return const [];
  final out = <IntervalStat>[];
  double? firstWork;
  for (final (n, i) in streams.intervals.indexed) {
    final length = i.end - i.start + 1;
    if (length <= 0) continue;
    final avg = _mean(output, i.start, i.end);
    final avgHr = hr == null ? null : _mean(hr, i.start, i.end);
    double? drift;
    if (hr != null && length >= minDriftSeconds) {
      final mid = i.start + length ~/ 2;
      final o1 = _mean(output, i.start, mid - 1);
      final o2 = _mean(output, mid, i.end);
      final h1 = _mean(hr, i.start, mid - 1);
      final h2 = _mean(hr, mid, i.end);
      if (o1 != null && o2 != null && h1 != null && h2 != null) {
        final ef1 = o1 / h1, ef2 = o2 / h2;
        drift = (ef1 - ef2) / ef1 * 100;
      }
    }
    double? fade;
    if (i.isWork && avg != null) {
      if (firstWork == null) {
        firstWork = avg;
      } else {
        fade = (avg - firstWork) / firstWork;
      }
    }
    out.add(
      IntervalStat(
        number: n + 1,
        isWork: i.isWork,
        seconds: length,
        avgOutput: avg,
        avgHeartrate: avgHr,
        drift: drift,
        fade: fade,
      ),
    );
  }
  return out;
}
