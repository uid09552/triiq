import 'dart:math' as math;

import '../data/models/local_activity.dart';
import '../data/repositories/activities_repository.dart';
import '../util/dates.dart';
import 'performance_curves.dart';
import 'session_streams.dart';
import 'training_analytics.dart' show LoadSport, loadSportOf;

/// Durability: how much of your fresh power (or pace) is left once you have
/// already done a lot of work. Intervals.icu only offers two predefined
/// fatigued curves, so the 1,000 / 2,000 / 3,000 kJ levels (and, for runs,
/// 10 / 20 / 30 km) are computed here from the activities' own streams: the
/// best effort of each duration (distance) that *started after* the athlete
/// had already put out that much work, taken across the recent long sessions.

/// Work levels offered, per sport: kilojoules of work for rides, kilometres
/// run for runs. The first entry (0) is the fresh reference.
const rideFatigueKj = [1000.0, 2000.0, 3000.0];
const runFatigueKm = [10.0, 20.0, 30.0];

/// Durations (s) shown for power, distances (m) shown for pace. Chosen to
/// exist as points on Intervals.icu's season curves too, so the fresh
/// reference can come from there.
const durabilityDurations = [5, 60, 300, 1200, 3600];
const durabilityDistances = [1000.0, 3000.0, 5000.0, 10000.0];

/// A series sampled once per second, from a stream and its `time`: missing
/// samples (a paused device, a dropout) count as 0 — no output.
List<double> perSecond(List<double?> time, List<double?> values) {
  final n = math.min(time.length, values.length);
  if (n == 0) return const [];
  var last = 0;
  for (var i = 0; i < n; i++) {
    final t = time[i];
    if (t != null && t > last) last = t.floor();
  }
  final out = List<double>.filled(last + 1, 0);
  for (var i = 0; i < n; i++) {
    final t = time[i], v = values[i];
    if (t == null || v == null || t < 0) continue;
    out[t.floor().clamp(0, last)] = v;
  }
  return out;
}

/// For each of [durations] (s): the best mean of [perSec] over a window that
/// starts at or after the first second where the cumulative work reaches
/// [afterWork]. [workPerSecond] turns one second of [perSec] into work units
/// (watts → kJ is `1/1000`). Null where no such window fits.
List<double?> bestMeanAfter(
  List<double> perSec,
  List<int> durations, {
  double afterWork = 0,
  double workPerSecond = 1 / 1000,
}) {
  final n = perSec.length;
  final prefix = List<double>.filled(n + 1, 0);
  for (var i = 0; i < n; i++) {
    prefix[i + 1] = prefix[i] + perSec[i];
  }
  // First second from which the work done before it reaches the threshold.
  var start = 0;
  if (afterWork > 0) {
    start = -1;
    for (var i = 0; i <= n; i++) {
      if (prefix[i] * workPerSecond >= afterWork) {
        start = i;
        break;
      }
    }
    if (start < 0) return List<double?>.filled(durations.length, null);
  }
  return [
    for (final d in durations)
      () {
        if (d <= 0 || start + d > n) return null;
        var best = 0.0;
        for (var i = start; i + d <= n; i++) {
          final mean = (prefix[i + d] - prefix[i]) / d;
          if (mean > best) best = mean;
        }
        return best > 0 ? best : null;
      }(),
  ];
}

/// For each of [distances] (m): the shortest time (s) to cover it starting at
/// or after [afterMetres] of running. [speedPerSec] is m/s once per second.
List<double?> bestTimeAfter(
  List<double> speedPerSec,
  List<double> distances, {
  double afterMetres = 0,
}) {
  final n = speedPerSec.length;
  final dist = List<double>.filled(n + 1, 0);
  for (var i = 0; i < n; i++) {
    dist[i + 1] = dist[i] + speedPerSec[i];
  }
  var start = 0;
  if (afterMetres > 0) {
    start = -1;
    for (var i = 0; i <= n; i++) {
      if (dist[i] >= afterMetres) {
        start = i;
        break;
      }
    }
    if (start < 0) return List<double?>.filled(distances.length, null);
  }
  return [
    for (final d in distances)
      () {
        double? best;
        var j = start;
        for (var i = start; i <= n; i++) {
          if (j < i) j = i;
          while (j <= n && dist[j] - dist[i] < d) {
            j++;
          }
          if (j > n) break;
          final t = (j - i).toDouble();
          if (best == null || t < best) best = t;
        }
        return best;
      }(),
  ];
}

/// One level of the result: the fresh reference or a fatigued curve.
class DurabilityLevel {
  const DurabilityLevel({
    required this.label,
    required this.workAfter,
    required this.values,
    this.sessions = 0,
  });

  /// Shown on the legend ("Season best", "After 2000 kJ").
  final String label;

  /// kJ (rides) or km (runs) done before the efforts count; 0 = fresh.
  final double workAfter;

  /// Aligned with [DurabilityResult.points]: watts, or seconds for pace.
  final List<double?> values;

  /// How many sessions supplied at least one value.
  final int sessions;

  bool get hasData => values.any((v) => v != null);
}

class DurabilityResult {
  const DurabilityResult({
    required this.sport,
    required this.metric,
    required this.points,
    required this.fresh,
    required this.fatigued,
    required this.candidates,
    required this.analysed,
    required this.failed,
    required this.days,
  });

  final CurveSport sport;

  /// [CurveMetric.power] (rides) or [CurveMetric.pace] (runs).
  final CurveMetric metric;

  /// Durations in seconds (power) or distances in metres (pace).
  final List<double> points;
  final DurabilityLevel fresh;
  final List<DurabilityLevel> fatigued;

  /// Sessions long enough to qualify, how many were analysed, and how many
  /// had no usable stream.
  final int candidates;
  final int analysed;
  final int failed;
  final int days;

  bool get isEmpty => !fatigued.any((l) => l.hasData);

  /// Share of the fresh level kept at point [i] by [level] (0..1+): watts
  /// against watts, fresh time against fatigued time for pace. Null when
  /// either side is missing.
  double? retained(DurabilityLevel level, int i) {
    final f = fresh.values[i], v = level.values[i];
    if (f == null || v == null || f <= 0 || v <= 0) return null;
    return metric.byDistance ? f / v : v / f;
  }
}

/// Work done in a ride, in kJ, as Intervals.icu records it.
double? activityKj(LocalActivity a) {
  final j = a.raw['icu_joules'];
  return j is num && j > 0 ? j / 1000 : null;
}

/// Whether [a] is long enough that a fatigued effort could exist at the
/// lowest level: a ride with at least [rideFatigueKj].first of work (or, with
/// no work figure, over 1.5 h), a run of at least [runFatigueKm].first.
bool isDurabilityCandidate(LocalActivity a, LoadSport sport) {
  if (loadSportOf(a.type) != sport) return false;
  switch (sport) {
    case LoadSport.ride:
      final kj = activityKj(a);
      return kj != null
          ? kj >= rideFatigueKj.first
          : (a.movingTime ?? 0) >= 5400;
    case LoadSport.run:
      return (a.distance ?? 0) >= runFatigueKm.first * 1000;
    default:
      return false;
  }
}

/// The streams of one session reduced to its values at each level.
class SessionDurability {
  const SessionDurability(this.byLevel);

  /// One list per fatigue level, aligned with the points.
  final List<List<double?>> byLevel;
}

SessionDurability? analyseRide(SessionStreams s, List<double> levelsKj) {
  final time = s.time, watts = s.series['watts'];
  if (time == null || watts == null) return null;
  final sec = perSecond(time, watts);
  if (sec.isEmpty) return null;
  return SessionDurability([
    for (final kj in levelsKj)
      bestMeanAfter(sec, durabilityDurations, afterWork: kj),
  ]);
}

SessionDurability? analyseRun(SessionStreams s, List<double> levelsKm) {
  final time = s.time, speed = s.series['velocity_smooth'];
  if (time == null || speed == null) return null;
  final sec = perSecond(time, speed);
  if (sec.isEmpty) return null;
  return SessionDurability([
    for (final km in levelsKm)
      bestTimeAfter(sec, durabilityDistances, afterMetres: km * 1000),
  ]);
}

/// Reads recent long sessions from the cache, takes each one's streams (from
/// the local copy, fetched once if missing) and keeps the best value per
/// point and level. The fresh reference is the athlete's season curve.
class DurabilityLoader {
  DurabilityLoader({
    ActivitiesRepository? activities,
    ActivityStreamsRepository? streams,
    PerformanceCurvesRepository? curves,
    DateTime Function()? clock,
    this.maxSessions = 40,
  }) : _activities = activities ?? ActivitiesRepository(),
       _streams = streams ?? ActivityStreamsRepository(),
       _curves = curves ?? PerformanceCurvesRepository(),
       _clock = clock ?? DateTime.now;

  final ActivitiesRepository _activities;
  final ActivityStreamsRepository _streams;
  final PerformanceCurvesRepository _curves;
  final DateTime Function() _clock;

  /// At most this many sessions are analysed (the most recent first), so a
  /// year of long rides doesn't mean a year of downloads.
  final int maxSessions;

  Future<DurabilityResult> load(
    CurveSport sport,
    int days, {
    void Function(int done, int total)? onProgress,
  }) async {
    final isRide = sport == CurveSport.ride;
    final today = dateOnly(_clock());
    final from = today.subtract(Duration(days: days - 1));
    final rows = await _activities.getRange(isoDate(from), isoDate(today));
    final family = isRide ? LoadSport.ride : LoadSport.run;
    final candidates = [
      for (final a in rows)
        if (isDurabilityCandidate(a, family)) a,
    ]..sort((a, b) => b.date.compareTo(a.date));
    final chosen = candidates.take(maxSessions).toList();

    final levels = isRide ? rideFatigueKj : runFatigueKm;
    final points = isRide
        ? [for (final d in durabilityDurations) d.toDouble()]
        : durabilityDistances;
    final best = [
      for (final _ in levels) List<double?>.filled(points.length, null),
    ];
    final sessions = List<int>.filled(levels.length, 0);
    var analysed = 0, failed = 0;

    for (var n = 0; n < chosen.length; n++) {
      onProgress?.call(n, chosen.length);
      SessionStreams? streams;
      try {
        streams = await _streams.load(chosen[n].id);
      } catch (_) {
        streams = null;
      }
      final result = streams == null
          ? null
          : (isRide ? analyseRide(streams, levels) : analyseRun(streams, levels));
      if (result == null) {
        failed++;
      } else {
        analysed++;
        for (var l = 0; l < levels.length; l++) {
          var any = false;
          for (var p = 0; p < points.length; p++) {
            final v = result.byLevel[l][p];
            if (v == null) continue;
            any = true;
            final cur = best[l][p];
            if (cur == null || (isRide ? v > cur : v < cur)) best[l][p] = v;
          }
          if (any) sessions[l]++;
        }
      }
      // Keep the UI alive between sessions.
      await Future<void>.delayed(Duration.zero);
    }
    onProgress?.call(chosen.length, chosen.length);

    final metric = isRide ? CurveMetric.power : CurveMetric.pace;
    final fresh = await _freshReference(sport, metric, points);

    return DurabilityResult(
      sport: sport,
      metric: metric,
      points: points,
      fresh: fresh,
      fatigued: [
        for (var l = 0; l < levels.length; l++)
          DurabilityLevel(
            label: '${levels[l].round()}',
            workAfter: levels[l],
            values: best[l],
            sessions: sessions[l],
          ),
      ],
      candidates: candidates.length,
      analysed: analysed,
      failed: failed,
      days: days,
    );
  }

  /// The athlete's season-best curve at the points (this season, else the
  /// last 42 days); empty values when Intervals.icu can't be reached.
  Future<DurabilityLevel> _freshReference(
    CurveSport sport,
    CurveMetric metric,
    List<double> points,
  ) async {
    PerformanceCurves? curves;
    try {
      curves =
          await _curves.cached(sport, metric) ?? await _curves.load(sport, metric);
    } catch (_) {
      curves = null;
    }
    final period = curves == null
        ? null
        : [curves.period('s0'), curves.period('42d')]
              .whereType<CurvePeriod>()
              .where((p) => !p.isEmpty)
              .firstOrNull;
    return DurabilityLevel(
      label: '',
      workAfter: 0,
      values: [for (final x in points) period?.at(x)?.value],
    );
  }
}
