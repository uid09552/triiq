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
  const ActivityRoute(this.points);

  final List<RoutePoint> points;

  bool get isEmpty => points.length < 2;

  Map<String, dynamic> toJson() => {
    'lat': [for (final p in points) p.lat],
    'lng': [for (final p in points) p.lng],
  };

  factory ActivityRoute.fromJson(Map<String, dynamic> j) {
    final lat = (j['lat'] as List? ?? const []).cast<num>();
    final lng = (j['lng'] as List? ?? const []).cast<num>();
    final n = lat.length < lng.length ? lat.length : lng.length;
    return ActivityRoute([
      for (var i = 0; i < n; i++) RoutePoint(lat[i].toDouble(), lng[i].toDouble()),
    ]);
  }

  /// Points kept for drawing: a track of tens of thousands of fixes is
  /// pointless on a phone-sized map and slow to paint.
  static const maxPoints = 1200;

  /// Builds a route from raw latitude / longitude samples (`null` and the
  /// (0, 0) a device writes for "no fix" are dropped), keeping about
  /// [maxPoints] evenly spaced points and always the first and last.
  factory ActivityRoute.fromSamples(List<Object?> lat, List<Object?> lng) {
    final n = lat.length < lng.length ? lat.length : lng.length;
    final valid = <RoutePoint>[];
    for (var i = 0; i < n; i++) {
      final a = lat[i];
      final b = lng[i];
      if (a is! num || b is! num) continue;
      if (a == 0 && b == 0) continue;
      if (a.abs() > 90 || b.abs() > 180) continue;
      valid.add(RoutePoint(a.toDouble(), b.toDouble()));
    }
    if (valid.length <= maxPoints) return ActivityRoute(valid);
    final step = (valid.length - 1) / (maxPoints - 1);
    return ActivityRoute([
      for (var i = 0; i < maxPoints; i++) valid[(i * step).round()],
    ]);
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
    if (hit != null) return hit;
    final route = await _fetch(activityId);
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
      types: const ['latlng'],
    );
    for (final s in streams.data ?? const <ActivityStream>[]) {
      if (s.type == 'latlng' && s.data is List && s.data2 is List) {
        return ActivityRoute.fromSamples(
          s.data as List<Object?>,
          s.data2 as List<Object?>,
        );
      }
    }
    return const ActivityRoute([]);
  }
}
