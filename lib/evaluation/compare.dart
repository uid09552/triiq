import 'dart:math' as math;

import '../data/models/local_activity.dart';
import '../util/dates.dart';
import 'activity_route.dart';
import 'intensity.dart';
import 'session_evaluator.dart' show sportFamily;
import 'session_streams.dart';
import '../widgets/charts/stream_chart.dart' show rollingMean;

/// Comparing two activities stream against stream, and two blocks of
/// training against each other. Pure — the compare screen loads the cache
/// and draws what comes back.

/// Only running and cycling are compared.
bool isComparable(LocalActivity a) {
  final family = sportFamily(a.type);
  return family == 'run' || family == 'ride';
}

// ---------------------------------------------------------------------------
// Two activities, stream over stream
// ---------------------------------------------------------------------------

/// What the x-axis of the overlay measures: the same course lines up on
/// distance, the same effort on time.
enum CompareAxis { distance, time }

/// The streams the overlay can show, in the order they are offered.
const compareMetrics = [
  'watts',
  'heartrate',
  'velocity_smooth',
  'cadence',
  'altitude',
];

/// The x value of every sample of [s] on [axis], made non-decreasing (a
/// paused device repeats distance; a glitch can step back). Null when the
/// activity has no such stream (indoor ride without distance).
List<double>? axisValues(SessionStreams s, CompareAxis axis) {
  final raw = axis == CompareAxis.time ? s.time : s.series['distance'];
  if (raw == null || raw.isEmpty) return null;
  var last = 0.0;
  final out = <double>[];
  for (final v in raw) {
    if (v != null && v > last) last = v;
    out.add(last);
  }
  return out.last > 0 ? out : null;
}

/// The largest x the activity reaches on [axis], or null without the stream.
double? axisLength(SessionStreams s, CompareAxis axis) =>
    axisValues(s, axis)?.last;

/// Index of the first sample whose x is >= [x] (binary search).
int _lowerBound(List<double> xs, double x, [int? length]) {
  var lo = 0, hi = (length ?? xs.length) - 1;
  while (lo < hi) {
    final mid = (lo + hi) ~/ 2;
    if (xs[mid] < x) {
      lo = mid + 1;
    } else {
      hi = mid;
    }
  }
  return lo;
}

/// [metric] of [s] at each of [grid]'s x positions, smoothed over
/// [smoothSeconds] samples first (1 Hz recordings). Beyond the end of the
/// activity the value is null, so a shorter ride simply stops.
List<double?> resampleMetric(
  SessionStreams s,
  String metric,
  CompareAxis axis,
  List<double> grid, {
  int smoothSeconds = 15,
}) {
  final xs = axisValues(s, axis);
  final raw = s.series[metric];
  if (xs == null || raw == null) return List<double?>.filled(grid.length, null);
  final values = metric == 'altitude' ? raw : rollingMean(raw, smoothSeconds);
  final n = math.min(xs.length, values.length);
  final out = <double?>[];
  for (final x in grid) {
    if (x > xs[n - 1]) {
      out.add(null);
      continue;
    }
    final i = _lowerBound(xs, x, n);
    final b = values[i];
    if (i == 0) {
      out.add(b);
      continue;
    }
    final a = values[i - 1];
    if (a == null || b == null) {
      out.add(b ?? a);
      continue;
    }
    final span = xs[i] - xs[i - 1];
    out.add(span <= 0 ? b : a + (b - a) * (x - xs[i - 1]) / span);
  }
  return out;
}

/// [count] evenly spaced x values from 0 to [max].
List<double> axisGrid(double max, {int count = 240}) => [
  for (var i = 0; i < count; i++) max * i / (count - 1),
];

/// The elapsed seconds at which the activity was at [x] on [axis]; null
/// when the stream is missing or [x] is past the end.
double? timeAtX(SessionStreams s, CompareAxis axis, double x) {
  if (axis == CompareAxis.time) {
    final len = axisLength(s, axis);
    return len == null || x > len ? null : x;
  }
  final xs = axisValues(s, axis);
  final time = s.time;
  if (xs == null || time == null || x > xs.last) return null;
  final i = _lowerBound(xs, x);
  double t(int k) => (k < time.length ? time[k] : null) ?? k.toDouble();
  if (i == 0) return t(0);
  final span = xs[i] - xs[i - 1];
  final f = span <= 0 ? 1.0 : (x - xs[i - 1]) / span;
  return t(i - 1) + (t(i) - t(i - 1)) * f;
}

/// The x on [axis] the activity had reached after [seconds]; the inverse of
/// [timeAtX]. Null without the stream.
double? xAtTime(SessionStreams s, CompareAxis axis, double seconds) {
  if (axis == CompareAxis.time) return seconds;
  final xs = axisValues(s, axis);
  final time = s.time;
  if (xs == null || time == null || time.isEmpty) return null;
  var lo = 0, hi = time.length - 1;
  double t(int k) => time[k] ?? k.toDouble();
  while (lo < hi) {
    final mid = (lo + hi) ~/ 2;
    if (t(mid) < seconds) {
      lo = mid + 1;
    } else {
      hi = mid;
    }
  }
  final i = math.min(lo, xs.length - 1);
  if (i == 0) return xs[0];
  final span = t(i) - t(i - 1);
  final f = span <= 0 ? 1.0 : ((seconds - t(i - 1)) / span).clamp(0.0, 1.0);
  return xs[i - 1] + (xs[i] - xs[i - 1]) * f;
}

/// The point of [route] where the activity was at [x] on [axis], or null
/// when the route or the stream can't say.
RoutePoint? routePointAtX(
  ActivityRoute route,
  SessionStreams streams,
  CompareAxis axis,
  double x,
) {
  final t = timeAtX(streams, axis, x);
  return t == null ? null : route.pointAt(t);
}

/// The x on [axis] closest to a tap at ([lat], [lng]): the nearest fix of
/// [route], turned into a position along the activity. Null without times or
/// a stream.
double? xAtNearestPoint(
  ActivityRoute route,
  SessionStreams streams,
  CompareAxis axis,
  double lat,
  double lng, {
  double? maxMetres,
}) {
  if (!route.hasTimes) return null;
  var best = -1;
  var bestD = double.infinity;
  for (var i = 0; i < route.points.length; i++) {
    final d = _metres(lat, lng, route.points[i].lat, route.points[i].lng);
    if (d < bestD) {
      bestD = d;
      best = i;
    }
  }
  if (best < 0 || (maxMetres != null && bestD > maxMetres)) return null;
  return xAtTime(streams, axis, route.times[best]);
}

/// Distance in metres between two coordinates (equirectangular is plenty at
/// the scale of a tap on a map).
double _metres(double lat1, double lng1, double lat2, double lng2) {
  const r = 6371000.0;
  final dLat = (lat2 - lat1) * math.pi / 180;
  final dLng =
      (lng2 - lng1) *
      math.pi /
      180 *
      math.cos((lat1 + lat2) / 2 * math.pi / 180);
  return r * math.sqrt(dLat * dLat + dLng * dLng);
}

/// Distance in metres between two route points — shared with tests and the
/// map's tap tolerance.
double routeMetres(RoutePoint a, RoutePoint b) =>
    _metres(a.lat, a.lng, b.lat, b.lng);

// ---------------------------------------------------------------------------
// Summary figures: one activity, or a block of them
// ---------------------------------------------------------------------------

/// Figures summed or averaged over a set of activities — one activity
/// (count 1) or a block of training. Time-weighted where an average over
/// sessions would mislead.
class BlockStats {
  const BlockStats({
    required this.count,
    required this.seconds,
    required this.distance,
    required this.elevation,
    required this.load,
    this.avgHeartrate,
    this.avgWatts,
    this.avgSpeed,
    this.efficiencyFactor,
    this.decoupling,
    this.split,
  });

  final int count;
  final int seconds;
  final double distance;
  final double elevation;
  final int load;

  /// Time-weighted over the sessions that recorded it.
  final double? avgHeartrate;
  final double? avgWatts;

  /// Metres per second: distance over moving time.
  final double? avgSpeed;

  /// Mean of the sessions long enough to have one.
  final double? efficiencyFactor;
  final double? decoupling;

  /// Seconds easy / threshold / hard across the block.
  final IntensitySplit? split;

  static const empty = BlockStats(
    count: 0,
    seconds: 0,
    distance: 0,
    elevation: 0,
    load: 0,
  );

  bool get isEmpty => count == 0;
}

BlockStats blockStats(Iterable<LocalActivity> activities) {
  var count = 0, seconds = 0, load = 0;
  var distance = 0.0, elevation = 0.0;
  var hrSum = 0.0, hrSecs = 0.0, wSum = 0.0, wSecs = 0.0;
  final efs = <double>[], decs = <double>[];
  IntensitySplit? split;
  for (final a in activities) {
    count++;
    final t = a.movingTime ?? 0;
    seconds += t;
    load += a.trainingLoad ?? 0;
    distance += a.distance ?? 0;
    final elev = a.raw['total_elevation_gain'];
    if (elev is num) elevation += elev;
    final hr = a.raw['average_heartrate'];
    if (hr is num && hr > 0 && t > 0) {
      hrSum += hr * t;
      hrSecs += t;
    }
    final w = a.raw['icu_average_watts'] ?? a.raw['average_watts'];
    if (w is num && w > 0 && t > 0) {
      wSum += w * t;
      wSecs += t;
    }
    final ef = a.raw['icu_efficiency_factor'];
    if (ef is num && ef > 0 && t >= 1200) efs.add(ef.toDouble());
    final dec = a.raw['decoupling'];
    if (dec is num && t >= 3600) decs.add(dec.toDouble());
    final s = intensityOf(a.raw);
    if (s != null) split = split == null ? s : split + s;
  }
  double? mean(List<double> v) =>
      v.isEmpty ? null : v.reduce((a, b) => a + b) / v.length;
  return BlockStats(
    count: count,
    seconds: seconds,
    distance: distance,
    elevation: elevation,
    load: load,
    avgHeartrate: hrSecs > 0 ? hrSum / hrSecs : null,
    avgWatts: wSecs > 0 ? wSum / wSecs : null,
    avgSpeed: seconds > 0 && distance > 0 ? distance / seconds : null,
    efficiencyFactor: mean(efs),
    decoupling: mean(decs),
    split: split,
  );
}

/// Relative change from [before] to [after] as a fraction (0.1 = +10 %), or
/// null when [before] is missing or zero.
double? relativeChange(double? before, double? after) {
  if (before == null || after == null || before == 0) return null;
  return (after - before) / before.abs();
}

// ---------------------------------------------------------------------------
// Two blocks
// ---------------------------------------------------------------------------

/// A block of [days] days ending on [end] (inclusive) and the block of the
/// same length right before it.
class BlockPair {
  BlockPair({required DateTime end, required this.days})
    : currentEnd = dateOnly(end),
      currentStart = dateOnly(end).subtract(Duration(days: days - 1)),
      previousEnd = dateOnly(end).subtract(Duration(days: days)),
      previousStart = dateOnly(end).subtract(Duration(days: 2 * days - 1));

  final int days;
  final DateTime currentStart;
  final DateTime currentEnd;
  final DateTime previousStart;
  final DateTime previousEnd;

  bool inCurrent(String date) =>
      date.compareTo(isoDate(currentStart)) >= 0 &&
      date.compareTo(isoDate(currentEnd)) <= 0;

  bool inPrevious(String date) =>
      date.compareTo(isoDate(previousStart)) >= 0 &&
      date.compareTo(isoDate(previousEnd)) <= 0;
}

/// Which activities of [activities] belong to [sport] (`run` / `ride`).
Iterable<LocalActivity> ofSport(
  Iterable<LocalActivity> activities,
  String sport,
) => activities.where((a) => sportFamily(a.type) == sport);

/// Cumulative [pick] by day of the block, one value per day starting on
/// [start]; days past [end] are null so the current block stops at today.
List<double?> cumulativeByDay(
  Iterable<LocalActivity> activities,
  DateTime start,
  int days,
  double Function(LocalActivity) pick, {
  DateTime? end,
}) {
  final perDay = List<double>.filled(days, 0);
  final from = dateOnly(start);
  for (final a in activities) {
    final d = DateTime.tryParse(a.date);
    if (d == null) continue;
    final i = dateOnly(d).difference(from).inDays;
    if (i < 0 || i >= days) continue;
    perDay[i] += pick(a);
  }
  final last = end == null ? days - 1 : dateOnly(end).difference(from).inDays;
  var run = 0.0;
  return [
    for (var i = 0; i < days; i++)
      () {
        run += perDay[i];
        return i > last ? null : run;
      }(),
  ];
}
