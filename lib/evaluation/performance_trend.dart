import '../data/models/local_activity.dart';

enum PerformanceTrend { up, down }

/// Whether [activity] was more or less efficient than this athlete's recent
/// norm for the same sport, from Intervals.icu's efficiency factor (EF —
/// output per heartbeat, so higher means fitter at the same effort).
///
/// Compares against the mean EF of up to [maxBaseline] earlier same-type
/// activities from [history] in the [windowDays] before it. Returns null —
/// show nothing — when there's too little to compare: no EF, a short
/// session (EF is noisy), or fewer than [minBaseline] comparable sessions.
/// A change under [threshold] is treated as unchanged.
PerformanceTrend? performanceTrend(
  LocalActivity activity,
  Iterable<LocalActivity> history, {
  int windowDays = 42,
  int maxBaseline = 8,
  int minBaseline = 3,
  double threshold = 0.02,
  int minSeconds = 1200,
}) {
  final ef = _ef(activity);
  if (ef == null || activity.type == null) return null;
  final day = DateTime.tryParse(activity.date);
  if (day == null) return null;
  final earliest = day.subtract(Duration(days: windowDays));

  final prior = history.where((a) {
    if (a.id == activity.id || a.type != activity.type) return false;
    final d = DateTime.tryParse(a.date);
    if (d == null || d.isBefore(earliest)) return false;
    // Strictly earlier days only (same-day sessions aren't "before").
    return d.isBefore(day) && _ef(a) != null;
  }).toList()..sort((a, b) => b.date.compareTo(a.date));

  final recent = prior.take(maxBaseline).toList();
  if (recent.length < minBaseline) return null;
  final mean =
      recent.map((a) => _ef(a)!).reduce((a, b) => a + b) / recent.length;
  final change = (ef - mean) / mean;
  if (change >= threshold) return PerformanceTrend.up;
  if (change <= -threshold) return PerformanceTrend.down;
  return null;
}

double? _ef(LocalActivity a) {
  if ((a.movingTime ?? 0) < 1200) return null;
  final v = a.raw['icu_efficiency_factor'];
  return v is num && v > 0 ? v.toDouble() : null;
}
