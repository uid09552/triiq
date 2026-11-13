import 'dart:math' as math;

import '../data/models/local_wellness.dart';
import '../util/dates.dart';

/// The shared "what is normal for this athlete" for HRV and resting HR.
/// Readiness (Today), the fatigue early warning, the wellness trends on
/// Insights and the trainer's `get_readiness` tool all take their baseline
/// from here, so they agree on what "usual" means.
///
/// * The baseline is **robust**: the median and the MAD (median absolute
///   deviation, scaled ×1.4826 so it reads like a standard deviation, "MADσ")
///   of the window, after dropping implausible readings and anything more
///   than [WellnessBaselineRules.outlierMad] MADσ from the median. A sick week
///   or a strap that slipped doesn't drag "normal" with it.
/// * Today's figure is **smoothed**: the median of the last
///   [WellnessBaselineRules.smoothingDays] days with a value, so one odd
///   morning doesn't move the rating.
/// * The smoothing window is never part of the baseline it is compared with.

/// Days of values a baseline needs before it counts, unless the rules say
/// otherwise.
const defaultMinBaselineDays = 21;

/// MAD → standard-deviation equivalent for normally distributed data.
const madToSigma = 1.4826;

/// The two wearable signals that are rated against a personal baseline.
enum WellnessSignal {
  restingHr(min: 25, max: 120, minSigma: 1),
  hrv(min: 0, max: 300, minSigma: 1);

  const WellnessSignal({
    required this.min,
    required this.max,
    required this.minSigma,
  });

  /// Readings outside (min, max] — resting HR [min, max] — are not
  /// physiological; a wearable writes 0 for "not measured".
  final double min;
  final double max;

  /// The smallest spread a baseline reports: a perfectly flat history would
  /// otherwise make every 1-unit wobble an outlier. HRV also floors at 3 % of
  /// its median (see [sigmaFloor]).
  final double minSigma;

  double sigmaFloor(double median) => switch (this) {
    WellnessSignal.restingHr => minSigma,
    WellnessSignal.hrv => math.max(minSigma, 0.03 * median),
  };

  bool plausible(double v) => switch (this) {
    WellnessSignal.restingHr => v >= min && v <= max,
    WellnessSignal.hrv => v > min && v <= max,
  };

  String get rawKey => switch (this) {
    WellnessSignal.restingHr => 'restingHR',
    WellnessSignal.hrv => 'hrv',
  };
}

/// How the baseline and the smoothed value are taken.
class WellnessBaselineRules {
  const WellnessBaselineRules({
    this.baselineDays = 60,
    this.minBaselineDays = defaultMinBaselineDays,
    this.smoothingDays = 3,
    this.outlierMad = 4,
  });

  /// The window before the smoothing window that the baseline comes from.
  final int baselineDays;

  /// Values the baseline needs (after outliers are dropped) before it counts.
  final int minBaselineDays;

  /// Today's figure is the median of this many latest days with a value.
  final int smoothingDays;

  /// Baseline readings this many MADσ from the median are dropped.
  final double outlierMad;

  /// How far back the smoothing window may reach for its values — gaps are
  /// skipped, but a value from weeks ago is not "recent".
  int get smoothingLookback => 2 * smoothingDays;
}

/// The plausible value of [signal] on [r], or null.
double? wellnessSignalValue(LocalWellness r, WellnessSignal signal) {
  final raw = r.raw[signal.rawKey];
  final v = raw is num ? raw.toDouble() : null;
  return v == null || !signal.plausible(v) ? null : v;
}

/// The plausible values of [signal] in [records], by ISO date.
Map<String, double> wellnessSignalValues(
  Iterable<LocalWellness> records,
  WellnessSignal signal,
) => {for (final r in records) r.date: ?wellnessSignalValue(r, signal)};

double median(List<double> values) {
  final s = [...values]..sort();
  final n = s.length;
  return n.isOdd ? s[n ~/ 2] : (s[n ~/ 2 - 1] + s[n ~/ 2]) / 2;
}

/// Median and MADσ of a set of readings.
class RobustBaseline {
  const RobustBaseline({
    required this.median,
    required this.sigma,
    required this.count,
  });

  final double median;

  /// MAD × 1.4826, floored by [WellnessSignal.sigmaFloor].
  final double sigma;

  /// Readings it was taken from, after outliers were dropped.
  final int count;
}

/// The baseline of [values]: implausible readings and those more than
/// [outlierMad] MADσ from a first median are dropped, then median and MADσ
/// are taken again. Null when [values] is empty.
RobustBaseline? robustBaseline(
  Iterable<double> values, {
  WellnessSignal? signal,
  double outlierMad = 4,
  double minSigma = 0,
}) {
  final plausible = [
    for (final v in values)
      if (signal == null || signal.plausible(v)) v,
  ];
  if (plausible.isEmpty) return null;
  double sigmaOf(List<double> v, double med) {
    final mad = median([for (final x in v) (x - med).abs()]) * madToSigma;
    final floor = signal?.sigmaFloor(med) ?? minSigma;
    return math.max(mad, floor);
  }

  final med0 = median(plausible);
  final sigma0 = sigmaOf(plausible, med0);
  final kept = [
    for (final v in plausible)
      // A zero spread (no floor, most values identical) can't tell an
      // outlier from an ordinary reading: keep everything then.
      if (sigma0 == 0 || (v - med0).abs() <= outlierMad * sigma0) v,
  ];
  final med = median(kept);
  return RobustBaseline(
    median: med,
    sigma: sigmaOf(kept, med),
    count: kept.length,
  );
}

/// One day's reading of a signal: the raw value, the smoothed value it is
/// rated by, and the baseline it is rated against.
class WellnessReading {
  const WellnessReading({
    required this.date,
    required this.today,
    required this.smoothed,
    required this.smoothedDays,
    required this.baseline,
    required this.baselineCount,
    required this.baselineNeeded,
  });

  final String date;

  /// The day's own (plausible) value, or null.
  final double? today;

  /// The median of the latest values in the smoothing window, today's
  /// included; null without a value today.
  final double? smoothed;

  /// How many values [smoothed] is the median of.
  final int smoothedDays;

  /// Null while fewer than [baselineNeeded] values are in the window.
  final RobustBaseline? baseline;
  final int baselineCount;
  final int baselineNeeded;
}

/// [signal] on [day] from [values] (plausible values by ISO date, see
/// [wellnessSignalValues]).
WellnessReading wellnessReading(
  Map<String, double> values,
  DateTime day,
  WellnessSignal signal, {
  WellnessBaselineRules rules = const WellnessBaselineRules(),
}) {
  final d = dateOnly(day);
  DateTime back(int n) => DateTime(d.year, d.month, d.day - n);
  final todayIso = isoDate(d);
  final today = values[todayIso];

  // The smoothing window: today and the latest days before it with a
  // value, within the lookback.
  final used = <String>[];
  if (today != null) {
    for (var i = 0; i < rules.smoothingLookback; i++) {
      final iso = isoDate(back(i));
      if (values.containsKey(iso)) used.add(iso);
      if (used.length >= rules.smoothingDays) break;
    }
  }
  final smoothed = used.isEmpty
      ? null
      : median([for (final iso in used) values[iso]!]);

  // The baseline: the window before the smoothing window.
  final baselineEnd = used.isEmpty
      ? isoDate(back(rules.smoothingDays - 1))
      : used.last;
  final baselineStart = isoDate(back(rules.baselineDays));
  final base = [
    for (final e in values.entries)
      if (e.key.compareTo(baselineStart) >= 0 &&
          e.key.compareTo(baselineEnd) < 0)
        e.value,
  ];
  final robust = robustBaseline(
    base,
    signal: signal,
    outlierMad: rules.outlierMad,
  );
  final count = robust?.count ?? 0;
  return WellnessReading(
    date: todayIso,
    today: today,
    smoothed: smoothed,
    smoothedDays: used.length,
    baseline: count >= rules.minBaselineDays ? robust : null,
    baselineCount: count,
    baselineNeeded: rules.minBaselineDays,
  );
}
