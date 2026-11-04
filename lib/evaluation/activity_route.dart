import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../client/intervalls/intervalls_client.dart';
import '../data/db/app_database.dart';
import '../data/intervals_session.dart';

/// One GPS fix of an activity's track.
class RoutePoint {
  const RoutePoint(this.lat, this.lng);

  final double lat;
  final double lng;
}

/// An activity's GPS track, thinned for drawing. Empty when the activity has
/// no GPS (indoor, treadmill, a manual entry).
class ActivityRoute {
  const ActivityRoute(
    this.points, {
    this.times = const [],
    this.timesKnown = true,
  });

  final List<RoutePoint> points;

  /// Elapsed seconds of each point (same length as [points]), or empty when
  /// unknown. Lets a moment on the diagram be found on the map.
  final List<double> times;

  /// False for a track cached before times were kept: worth refetching.
  final bool timesKnown;

  bool get isEmpty => points.length < 2;

  bool get hasTimes => times.length == points.length && points.isNotEmpty;

  /// The point where the activity was [seconds] in: the nearest fix, or null
  /// without times.
  RoutePoint? pointAt(double seconds) {
    if (!hasTimes) return null;
    var lo = 0;
    var hi = times.length - 1;
    while (lo < hi) {
      final mid = (lo + hi) ~/ 2;
      if (times[mid] < seconds) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    if (lo > 0 && (seconds - times[lo - 1]).abs() <= (times[lo] - seconds).abs()) {
      lo--;
    }
    return points[lo];
  }

  Map<String, dynamic> toJson() => {
    'lat': [for (final p in points) p.lat],
    'lng': [for (final p in points) p.lng],
    'time': times,
  };

  factory ActivityRoute.fromJson(Map<String, dynamic> j) {
    final lat = (j['lat'] as List? ?? const []).cast<num>();
    final lng = (j['lng'] as List? ?? const []).cast<num>();
    final n = lat.length < lng.length ? lat.length : lng.length;
    final time = (j['time'] as List? ?? const []).cast<num>();
    return ActivityRoute(
      [
        for (var i = 0; i < n; i++) RoutePoint(lat[i].toDouble(), lng[i].toDouble()),
      ],
      times: time.length == n ? [for (final t in time) t.toDouble()] : const [],
      timesKnown: j.containsKey('time'),
    );
  }

  /// Points kept for drawing: a track of tens of thousands of fixes is
  /// pointless on a phone-sized map and slow to paint.
  static const maxPoints = 1200;

  /// Builds a route from raw latitude / longitude samples (`null` and the
  /// (0, 0) a device writes for "no fix" are dropped), keeping about
  /// [maxPoints] evenly spaced points and always the first and last.
  factory ActivityRoute.fromSamples(
    List<Object?> lat,
    List<Object?> lng, {
    List<Object?> time = const [],
  }) {
    final n = lat.length < lng.length ? lat.length : lng.length;
    final withTime = time.length >= n;
    final valid = <RoutePoint>[];
    final validTimes = <double>[];
    for (var i = 0; i < n; i++) {
      final a = lat[i];
      final b = lng[i];
      if (a is! num || b is! num) continue;
      if (a == 0 && b == 0) continue;
      if (a.abs() > 90 || b.abs() > 180) continue;
      final t = withTime ? time[i] : null;
      if (withTime && t is! num) continue;
      valid.add(RoutePoint(a.toDouble(), b.toDouble()));
      if (withTime) validTimes.add((t as num).toDouble());
    }
    if (valid.length <= maxPoints) {
      return ActivityRoute(valid, times: withTime ? validTimes : const []);
    }
    final step = (valid.length - 1) / (maxPoints - 1);
    final picks = [for (var i = 0; i < maxPoints; i++) (i * step).round()];
    return ActivityRoute(
      [for (final i in picks) valid[i]],
      times: withTime ? [for (final i in picks) validTimes[i]] : const [],
    );
  }
}

typedef RouteFetcher = Future<ActivityRoute> Function(String activityId);

/// GPS tracks by activity, fetched the first time an activity's map is
/// opened and read from SQLite afterwards (an activity without GPS is
/// remembered too, so it isn't asked for again). Stored beside the diagram
/// streams under a `route:` key, so there is no schema change.
class ActivityRouteRepository {
  ActivityRouteRepository({AppDatabase? database, RouteFetcher? fetch})
    : _database = database ?? AppDatabase.instance,
      _fetch = fetch ?? _fetchFromApi;

  final AppDatabase _database;
  final RouteFetcher _fetch;

  static String _key(String activityId) => 'route:$activityId';

  Future<ActivityRoute?> cached(String activityId) async {
    final db = await _database.database;
    final rows = await db.query(
      'activity_streams',
      where: 'activity_id = ?',
      whereArgs: [_key(activityId)],
    );
    if (rows.isEmpty) return null;
    return ActivityRoute.fromJson(
      jsonDecode(rows.first['data'] as String) as Map<String, dynamic>,
    );
  }

  Future<ActivityRoute> load(String activityId) async {
    final hit = await cached(activityId);
    // A track cached before times were kept is fetched again once, so the
    // diagram can point at it.
    if (hit != null && (hit.isEmpty || hit.timesKnown)) return hit;
    final ActivityRoute route;
    try {
      route = await _fetch(activityId);
    } catch (_) {
      if (hit != null) return hit; // offline: the old track still draws
      rethrow;
    }
    final db = await _database.database;
    await db.insert('activity_streams', {
      'activity_id': _key(activityId),
      'data': jsonEncode(route.toJson()),
      'fetched_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    return route;
  }

  static Future<ActivityRoute> _fetchFromApi(String activityId) async {
    final client = IntervalsSession.instance.client;
    if (client == null) throw StateError('Not connected to Intervals.icu.');
    final streams = await client.getAktivittenApi().getActivityStreams(
      id: activityId,
      ext: '',
      types: const ['latlng', 'time'],
    );
    List<Object?> time = const [];
    ActivityStream? gps;
    for (final s in streams.data ?? const <ActivityStream>[]) {
      if (s.type == 'time' && s.data is List) time = s.data as List<Object?>;
      if (s.type == 'latlng' && s.data is List && s.data2 is List) gps = s;
    }
    if (gps == null) return const ActivityRoute([]);
    return ActivityRoute.fromSamples(
      gps.data as List<Object?>,
      gps.data2 as List<Object?>,
      time: time,
    );
  }
}
