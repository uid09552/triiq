import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

import '../data/db/app_database.dart';
import '../data/intervals_session.dart';
import '../util/dates.dart';
import 'performance_curves.dart' show CurveSport;

/// Best efforts over time: the best 5 s / 1 min / 5 min / 20 min power (rides)
/// or the fastest 1 / 5 / 10 km (runs) of every session, from Intervals.icu's
/// per-activity curves, and what they add up to month by month.

/// Durations (s) asked for rides, distances (m) for runs.
const effortSeconds = [5, 60, 300, 1200];
const effortDistances = [1000.0, 5000.0, 10000.0];

/// One session's best figures, aligned with the points asked for: watts, or
/// seconds over the distance for pace. Null where the session has none.
class EffortSession {
  const EffortSession(this.id, this.date, this.values);

  final String id;

  /// `YYYY-MM-DD`.
  final String date;
  final List<double?> values;

  Map<String, dynamic> toJson() => {'id': id, 'date': date, 'values': values};

  static EffortSession? fromJson(Map<String, dynamic> j) {
    final id = j['id'], date = j['date'], values = j['values'];
    if (id is! String || date is! String || values is! List) return null;
    return EffortSession(id, date, [
      for (final v in values) v is num && v > 0 ? v.toDouble() : null,
    ]);
  }
}

String? _day(Object? local) {
  final s = local is String ? local : null;
  return s != null && s.length >= 10 ? s.substring(0, 10) : null;
}

/// Parses `activity-power-curves`: `{secs: [...], curves: [{id,
/// start_date_local, watts: [...]}]}`, picking out the [wanted] durations.
List<EffortSession> parsePowerEfforts(
  Map<String, dynamic> json,
  List<int> wanted,
) {
  final secs = (json['secs'] as List? ?? const []).whereType<num>().toList();
  final out = <EffortSession>[];
  for (final c in json['curves'] as List? ?? const []) {
    if (c is! Map) continue;
    final date = _day(c['start_date_local']);
    final watts = c['watts'];
    if (date == null || watts is! List) continue;
    out.add(
      EffortSession('${c['id']}', date, [
        for (final w in wanted)
          () {
            final i = secs.indexWhere((s) => s == w);
            if (i < 0 || i >= watts.length) return null;
            final v = watts[i];
            return v is num && v > 0 ? v.toDouble() : null;
          }(),
      ]),
    );
  }
  return out;
}

/// Parses `activity-pace-curves`: `{distances: [...], curves: [{id,
/// start_date_local, <list>}]}`. The response isn't documented, so the list
/// of figures is whichever numeric list matches `distances` in length; values
/// small enough to be a speed (under 30) are turned into the time over the
/// distance, so the result is always seconds.
List<EffortSession> parsePaceEfforts(
  Map<String, dynamic> json,
  List<double> wanted,
) {
  final distances = (json['distances'] as List? ?? const [])
      .whereType<num>()
      .toList();
  final out = <EffortSession>[];
  for (final c in json['curves'] as List? ?? const []) {
    if (c is! Map) continue;
    final date = _day(c['start_date_local']);
    if (date == null) continue;
    List? figures;
    for (final key in ['times', 'secs', 'seconds', 'values', 'pace', 'speeds']) {
      final v = c[key];
      if (v is List && v.length == distances.length) {
        figures = v;
        break;
      }
    }
    figures ??= c.values
        .whereType<List>()
        .where((l) => l.length == distances.length && l.every((e) => e == null || e is num))
        .firstOrNull;
    if (figures == null) continue;
    out.add(
      EffortSession('${c['id']}', date, [
        for (final d in wanted)
          () {
            final i = distances.indexWhere((x) => (x - d).abs() <= d * 0.01);
            if (i < 0) return null;
            final v = figures![i];
            if (v is! num || v <= 0) return null;
            return v < 30 ? d / v : v.toDouble();
          }(),
      ]),
    );
  }
  return out;
}

typedef EffortsFetcher =
    Future<List<EffortSession>> Function(CurveSport sport, int days);

/// Per-session best efforts, fetched once and kept in SQLite beside the other
/// cached streams (under `efforts:` keys) for [maxAge].
class BestEffortsRepository {
  BestEffortsRepository({
    AppDatabase? database,
    EffortsFetcher? fetch,
    DateTime Function()? clock,
    this.maxAge = const Duration(hours: 6),
  }) : _database = database ?? AppDatabase.instance,
       _fetch = fetch ?? _fetchFromApi,
       _clock = clock ?? DateTime.now;

  final AppDatabase _database;
  final EffortsFetcher _fetch;
  final DateTime Function() _clock;
  final Duration maxAge;

  static String _key(CurveSport sport, int days) =>
      'efforts:${sport.name}:$days';

  Future<List<EffortSession>> load(
    CurveSport sport,
    int days, {
    bool force = false,
  }) async {
    final db = await _database.database;
    final rows = await db.query(
      'activity_streams',
      where: 'activity_id = ?',
      whereArgs: [_key(sport, days)],
    );
    List<EffortSession>? cached;
    var fresh = false;
    if (rows.isNotEmpty) {
      final data = jsonDecode(rows.first['data'] as String) as Map<String, dynamic>;
      cached = [
        for (final s in data['sessions'] as List? ?? const [])
          ?EffortSession.fromJson(s as Map<String, dynamic>),
      ];
      final fetchedAt = DateTime.fromMillisecondsSinceEpoch(
        rows.first['fetched_at'] as int,
      );
      fresh = _clock().difference(fetchedAt) < maxAge;
    }
    if (cached != null && fresh && !force) return cached;
    try {
      final sessions = await _fetch(sport, days);
      await db.insert('activity_streams', {
        'activity_id': _key(sport, days),
        'data': jsonEncode({
          'sessions': [for (final s in sessions) s.toJson()],
        }),
        'fetched_at': _clock().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      return sessions;
    } catch (_) {
      if (cached != null) return cached; // offline: the last copy still draws
      rethrow;
    }
  }

  static Future<List<EffortSession>> _fetchFromApi(
    CurveSport sport,
    int days,
  ) async {
    final client = IntervalsSession.instance.client;
    if (client == null) throw StateError('Not connected to Intervals.icu.');
    final today = dateOnly(DateTime.now());
    final isRide = sport == CurveSport.ride;
    final response = await client.dio.get<Object>(
      '/api/v1/athlete/0/${isRide ? 'activity-power-curves' : 'activity-pace-curves'}.json',
      queryParameters: {
        'oldest': isoDate(today.subtract(Duration(days: days))),
        'newest': isoDate(today),
        'type': sport.apiType,
        if (isRide)
          'secs': effortSeconds.join(',')
        else
          'distances': effortDistances.map((d) => d.round()).join(','),
      },
      options: Options(
        extra: {
          'secure': <Map<String, String>>[
            {'type': 'http', 'scheme': 'basic', 'name': 'APIKey'},
          ],
        },
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
    final data = response.data;
    final json = data is Map<String, dynamic>
        ? data
        : data is String
        ? jsonDecode(data) as Map<String, dynamic>
        : throw StateError('Unexpected best-efforts response.');
    return isRide
        ? parsePowerEfforts(json, effortSeconds)
        : parsePaceEfforts(json, effortDistances);
  }
}

// ---------------------------------------------------------------------------
// Progression
// ---------------------------------------------------------------------------

/// Whether a smaller value is better (pace is a time; power is watts).
bool lowerIsBetter(CurveSport sport) => sport == CurveSport.run;

double? _better(double? a, double? b, bool lower) {
  if (a == null) return b;
  if (b == null) return a;
  return lower ? (a < b ? a : b) : (a > b ? a : b);
}

/// The best value at [point] among [sessions] dated within
/// [start]..[end] inclusive.
double? bestIn(
  Iterable<EffortSession> sessions,
  int point,
  DateTime start,
  DateTime end, {
  required bool lower,
}) {
  final a = isoDate(start), b = isoDate(end);
  double? best;
  for (final s in sessions) {
    if (s.date.compareTo(a) < 0 || s.date.compareTo(b) > 0) continue;
    if (point >= s.values.length) continue;
    best = _better(best, s.values[point], lower);
  }
  return best;
}

/// One point on the progression line: the window it covers, the best in that
/// window, and the best over the [rollingDays] ending with it.
class EffortWindow {
  const EffortWindow({
    required this.start,
    required this.end,
    required this.best,
    required this.rollingBest,
  });

  final DateTime start;
  final DateTime end;
  final double? best;
  final double? rollingBest;
}

/// [count] consecutive windows of [windowDays] ending [today], oldest first,
/// for the effort at [point].
List<EffortWindow> progression(
  List<EffortSession> sessions,
  int point,
  DateTime today, {
  required bool lower,
  int count = 12,
  int windowDays = 30,
  int rollingDays = 90,
}) {
  final end0 = dateOnly(today);
  return [
    for (var i = count - 1; i >= 0; i--)
      () {
        final end = end0.subtract(Duration(days: i * windowDays));
        final start = end.subtract(Duration(days: windowDays - 1));
        return EffortWindow(
          start: start,
          end: end,
          best: bestIn(sessions, point, start, end, lower: lower),
          rollingBest: bestIn(
            sessions,
            point,
            end.subtract(Duration(days: rollingDays - 1)),
            end,
            lower: lower,
          ),
        );
      }(),
  ];
}

/// The latest window against the best of the days before it.
class EffortDelta {
  const EffortDelta({this.current, this.baseline, this.improvement});

  /// Best of the last [currentDays] days.
  final double? current;

  /// Best of the [baselineDays] before those.
  final double? baseline;

  /// Fraction better than the baseline (0.04 = 4 % better, −0.02 = 2 %
  /// worse): watts up, or time down. Null without both sides.
  final double? improvement;
}

List<EffortDelta> effortDeltas(
  List<EffortSession> sessions,
  int points,
  DateTime today, {
  required bool lower,
  int currentDays = 30,
  int baselineDays = 90,
}) {
  final end = dateOnly(today);
  final curStart = end.subtract(Duration(days: currentDays - 1));
  final baseEnd = curStart.subtract(const Duration(days: 1));
  final baseStart = baseEnd.subtract(Duration(days: baselineDays - 1));
  return [
    for (var p = 0; p < points; p++)
      () {
        final cur = bestIn(sessions, p, curStart, end, lower: lower);
        final base = bestIn(sessions, p, baseStart, baseEnd, lower: lower);
        final change = cur == null || base == null || base <= 0
            ? null
            : lower
            ? (base - cur) / base
            : (cur - base) / base;
        return EffortDelta(current: cur, baseline: base, improvement: change);
      }(),
  ];
}
