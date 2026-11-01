import 'dart:convert';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

import '../data/db/app_database.dart';
import '../data/intervals_session.dart';

/// The sports the Performance screen offers, with the Intervals.icu `type`
/// each curve request uses (which also covers its variants: `Ride` includes
/// `VirtualRide`).
enum CurveSport {
  ride('Ride'),
  run('Run'),
  swim('Swim');

  const CurveSport(this.apiType);

  final String apiType;

  static CurveSport? fromName(String? name) {
    final n = (name ?? '').toLowerCase();
    for (final s in values) {
      if (s.name == n || s.apiType.toLowerCase() == n) return s;
    }
    return null;
  }
}

/// What a curve measures. Power and heart rate are best averages over a
/// duration; pace is the fastest time over a distance — Intervals.icu keys
/// pace curves by metres, not seconds.
enum CurveMetric {
  power('power-curves'),
  pace('pace-curves'),
  hr('hr-curves');

  const CurveMetric(this.apiPath);

  final String apiPath;

  bool get byDistance => this == CurveMetric.pace;

  static CurveMetric? fromName(String? name) {
    final n = (name ?? '').toLowerCase();
    for (final m in values) {
      if (m.name == n) return m;
    }
    if (n == 'heartrate' || n == 'heart_rate') return CurveMetric.hr;
    return null;
  }
}

/// The periods every request asks for, in the order they are drawn: this
/// season, last season, the last 42 days.
const curvePeriodIds = ['s0', 's1', '42d'];

/// One point of a curve: the best [value] over [x] seconds (power, HR) or
/// [x] metres (pace, where [value] is the time in seconds).
class CurvePoint {
  const CurvePoint(this.x, this.value, [this.activityId]);

  final double x;
  final double value;

  /// The session that set this best, when Intervals.icu says.
  final String? activityId;
}

/// What Intervals.icu fits to a curve. Power models give FTP/CP/W'/Pmax,
/// pace models critical speed (m/s) and D' (metres).
class CurveModel {
  const CurveModel({
    this.ftp,
    this.criticalPower,
    this.wPrime,
    this.pMax,
    this.criticalSpeed,
    this.dPrime,
  });

  final double? ftp;
  final double? criticalPower;
  final double? wPrime;
  final double? pMax;
  final double? criticalSpeed;
  final double? dPrime;

  bool get isEmpty =>
      ftp == null &&
      criticalPower == null &&
      wPrime == null &&
      pMax == null &&
      criticalSpeed == null &&
      dPrime == null;

  Map<String, dynamic> toJson() => {
    'ftp': ?ftp,
    'critical_power': ?criticalPower,
    'w_prime': ?wPrime,
    'p_max': ?pMax,
    'critical_speed_mps': ?criticalSpeed,
    'd_prime_m': ?dPrime,
  };
}

/// One period's curve (`s0`, `s1` or `42d`).
class CurvePeriod {
  const CurvePeriod({
    required this.id,
    required this.points,
    this.start,
    this.end,
    this.model,
  });

  final String id;

  /// Sorted by [CurvePoint.x], ascending.
  final List<CurvePoint> points;
  final String? start;
  final String? end;
  final CurveModel? model;

  bool get isEmpty => points.isEmpty;

  /// The point at exactly [x], allowing 1% for rounding (21097 m vs a
  /// 21100 m bucket) — never interpolated, so no effort is invented.
  CurvePoint? at(double x) {
    CurvePoint? best;
    var bestGap = double.infinity;
    for (final p in points) {
      final gap = (p.x - x).abs();
      if (gap <= x * 0.01 && gap < bestGap) {
        best = p;
        bestGap = gap;
      }
    }
    return best;
  }
}

/// A source session named in the response, for the readout.
class CurveActivity {
  const CurveActivity({required this.id, this.date, this.name});

  final String id;

  /// `YYYY-MM-DD`.
  final String? date;
  final String? name;
}

/// Every period for one sport and metric, as parsed from one response.
class PerformanceCurves {
  const PerformanceCurves({
    required this.sport,
    required this.metric,
    required this.periods,
    this.activities = const {},
    this.fetchedAt,
  });

  final CurveSport sport;
  final CurveMetric metric;
  final List<CurvePeriod> periods;
  final Map<String, CurveActivity> activities;
  final DateTime? fetchedAt;

  bool get isEmpty => periods.every((p) => p.isEmpty);

  CurvePeriod? period(String id) {
    for (final p in periods) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// The fixed points the key-figures table shows for this sport/metric.
  List<double> get keyPoints => keyPointsFor(sport, metric);

  /// Parses an Intervals.icu `*-curves` response defensively: unknown
  /// fields are ignored, a curve without matching x/value lists is dropped.
  /// Curves are assigned to [curvePeriodIds] by their `id` when it names one,
  /// else by position (the API returns them in the requested order).
  factory PerformanceCurves.fromJson(
    CurveSport sport,
    CurveMetric metric,
    Map<String, dynamic> json, {
    DateTime? fetchedAt,
  }) {
    final list = json['list'];
    final periods = <CurvePeriod>[];
    if (list is List) {
      for (var i = 0; i < list.length; i++) {
        final curve = list[i];
        if (curve is! Map) continue;
        final rawId = '${curve['id'] ?? ''}';
        final id = curvePeriodIds.contains(rawId)
            ? rawId
            : i < curvePeriodIds.length
            ? curvePeriodIds[i]
            : rawId;
        if (periods.any((p) => p.id == id)) continue;
        periods.add(
          CurvePeriod(
            id: id,
            points: _points(curve, metric),
            start: _date(curve['start_date_local']),
            end: _date(curve['end_date_local']),
            model: _model(curve),
          ),
        );
      }
    }

    final activities = <String, CurveActivity>{};
    final rawActivities = json['activities'];
    if (rawActivities is Map) {
      rawActivities.forEach((key, value) {
        if (value is! Map) return;
        final id = '${value['id'] ?? key}';
        activities[id] = CurveActivity(
          id: id,
          date: _date(value['start_date_local']),
          name: value['name'] as String?,
        );
      });
    }

    return PerformanceCurves(
      sport: sport,
      metric: metric,
      periods: periods,
      activities: activities,
      fetchedAt: fetchedAt,
    );
  }

  static List<CurvePoint> _points(Map curve, CurveMetric metric) {
    final xs = curve[metric.byDistance ? 'distance' : 'secs'];
    final values = curve['values'];
    final ids = curve['activity_id'];
    if (xs is! List || values is! List) return const [];
    final points = <CurvePoint>[];
    final n = math.min(xs.length, values.length);
    for (var i = 0; i < n; i++) {
      final x = xs[i];
      final v = values[i];
      if (x is! num || v is! num || x <= 0 || v <= 0) continue;
      final id = ids is List && i < ids.length ? ids[i] : null;
      points.add(CurvePoint(x.toDouble(), v.toDouble(), id?.toString()));
    }
    points.sort((a, b) => a.x.compareTo(b.x));
    return points;
  }

  static CurveModel? _model(Map curve) {
    double? n(Object? v) => v is num ? v.toDouble() : null;
    final power = curve['powerModels'];
    if (power is List && power.isNotEmpty && power.first is Map) {
      final m = power.first as Map;
      final model = CurveModel(
        ftp: n(m['ftp']),
        criticalPower: n(m['criticalPower']),
        wPrime: n(m['wPrime']),
        pMax: n(m['pMax']),
      );
      return model.isEmpty ? null : model;
    }
    final pace = curve['paceModels'];
    if (pace is List && pace.isNotEmpty && pace.first is Map) {
      final m = pace.first as Map;
      final model = CurveModel(
        criticalSpeed: n(m['criticalSpeed']),
        dPrime: n(m['dPrime']),
      );
      return model.isEmpty ? null : model;
    }
    return null;
  }

  static String? _date(Object? value) {
    if (value is! String || value.length < 10) return null;
    return value.substring(0, 10);
  }
}

/// Key points per sport and metric: seconds for power/HR, metres for pace.
List<double> keyPointsFor(CurveSport sport, CurveMetric metric) {
  if (!metric.byDistance) return const [5, 60, 300, 1200, 3600];
  if (sport == CurveSport.swim) return const [100, 200, 400, 1500];
  return const [400, 1000, 5000, 10000, 21097.5];
}

/// The value the chart plots for [p]: watts or bpm as they are, pace as
/// speed in m/s so that faster sits higher.
double plotValue(CurveMetric metric, CurvePoint p) =>
    metric.byDistance ? p.x / p.value : p.value;

/// Thins [points] to at most about [buckets] for painting, keeping the best
/// value in each log-spaced bucket (a 6-hour ride has thousands of points).
List<CurvePoint> downsampleLog(
  List<CurvePoint> points,
  CurveMetric metric, {
  int buckets = 200,
}) {
  if (points.length <= buckets) return points;
  final minX = math.log(points.first.x);
  final maxX = math.log(points.last.x);
  final span = maxX - minX;
  if (span <= 0) return points;
  final result = <CurvePoint>[];
  var bucket = -1;
  CurvePoint? best;
  for (final p in points) {
    final b = ((math.log(p.x) - minX) / span * (buckets - 1)).floor();
    if (b != bucket) {
      if (best != null) result.add(best);
      bucket = b;
      best = p;
    } else if (plotValue(metric, p) > plotValue(metric, best!)) {
      best = p;
    }
  }
  if (best != null) result.add(best);
  return result;
}

/// "5s", "1m", "20m", "1h", "1h30m".
String formatCurveDuration(double seconds) {
  final s = seconds.round();
  if (s < 60) return '${s}s';
  if (s < 3600) {
    final m = s ~/ 60;
    final rest = s % 60;
    return rest == 0 ? '${m}m' : '${m}m${rest}s';
  }
  final h = s ~/ 3600;
  final m = (s % 3600) ~/ 60;
  return m == 0 ? '${h}h' : '${h}h${m}m';
}

/// "400 m", "1 km", "21.1 km".
String formatCurveDistance(double metres) {
  if (metres < 1000) return '${metres.round()} m';
  final km = metres / 1000;
  final text = km == km.roundToDouble()
      ? km.toStringAsFixed(0)
      : km.toStringAsFixed(1);
  return '$text km';
}

/// Pace from a speed in m/s, per 1000 m (run) or 100 m (swim): "4:05".
String formatPace(double metresPerSecond, {required int per}) {
  if (metresPerSecond <= 0) return '–';
  final seconds = (per / metresPerSecond).round();
  final m = seconds ~/ 60;
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// Metres the pace unit is quoted per for [sport].
int paceUnitMetres(CurveSport sport) => sport == CurveSport.swim ? 100 : 1000;

/// Fetches one sport/metric's curves for [curvePeriodIds] as raw JSON.
typedef CurvesFetcher =
    Future<Map<String, dynamic>> Function(CurveSport sport, CurveMetric metric);

/// The newest cached activity id for a sport family, or null.
typedef NewestActivityLookup = Future<String?> Function(CurveSport sport);

/// Curves per sport and metric, fetched when the Performance screen opens
/// and kept in SQLite. A cached copy is reused until a newer activity of
/// that sport lands in the cache — curves only change when one does.
class PerformanceCurvesRepository {
  PerformanceCurvesRepository({
    AppDatabase? database,
    CurvesFetcher? fetch,
    NewestActivityLookup? newestActivity,
    DateTime Function()? clock,
  }) : _database = database ?? AppDatabase.instance,
       _fetch = fetch ?? _fetchFromApi,
       _newestActivityOverride = newestActivity,
       _clock = clock ?? DateTime.now;

  final AppDatabase _database;
  final CurvesFetcher _fetch;
  final NewestActivityLookup? _newestActivityOverride;
  final DateTime Function() _clock;

  static String _key(CurveSport sport, CurveMetric metric) =>
      '${sport.name}|${metric.name}';

  /// The cached curves, whether or not they are stale.
  Future<PerformanceCurves?> cached(
    CurveSport sport,
    CurveMetric metric,
  ) async {
    final row = await _row(sport, metric);
    if (row == null) return null;
    return _parse(sport, metric, row);
  }

  /// Whether [load] would go to the network: nothing cached, or a newer
  /// activity of this sport arrived since the cached copy was fetched.
  Future<bool> isStale(CurveSport sport, CurveMetric metric) async {
    final row = await _row(sport, metric);
    if (row == null) return true;
    final newest = await _newestActivity(sport);
    return newest != row['newest_activity_id'];
  }

  /// The cached curves when fresh, else fetched, cached and returned.
  /// Throws when a fetch is needed and fails.
  Future<PerformanceCurves> load(
    CurveSport sport,
    CurveMetric metric, {
    bool force = false,
  }) async {
    final row = await _row(sport, metric);
    final newest = await _newestActivity(sport);
    if (!force && row != null && row['newest_activity_id'] == newest) {
      return _parse(sport, metric, row);
    }
    final json = await _fetch(sport, metric);
    final now = _clock();
    final db = await _database.database;
    await db.insert('performance_curves', {
      'key': _key(sport, metric),
      'data': jsonEncode(json),
      'newest_activity_id': newest,
      'fetched_at': now.millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    return PerformanceCurves.fromJson(sport, metric, json, fetchedAt: now);
  }

  Future<Map<String, Object?>?> _row(
    CurveSport sport,
    CurveMetric metric,
  ) async {
    final db = await _database.database;
    final rows = await db.query(
      'performance_curves',
      where: 'key = ?',
      whereArgs: [_key(sport, metric)],
    );
    return rows.isEmpty ? null : rows.first;
  }

  PerformanceCurves _parse(
    CurveSport sport,
    CurveMetric metric,
    Map<String, Object?> row,
  ) => PerformanceCurves.fromJson(
    sport,
    metric,
    jsonDecode(row['data'] as String) as Map<String, dynamic>,
    fetchedAt: DateTime.fromMillisecondsSinceEpoch(row['fetched_at'] as int),
  );

  Future<String?> _newestActivity(CurveSport sport) async {
    final override = _newestActivityOverride;
    if (override != null) return override(sport);
    // Same families as `sportFamily` in the session evaluator.
    final patterns = switch (sport) {
      CurveSport.ride => ['%ride%', '%bike%', '%cycl%'],
      CurveSport.run => ['%run%'],
      CurveSport.swim => ['%swim%'],
    };
    final db = await _database.database;
    final rows = await db.query(
      'activities',
      columns: ['id'],
      where: patterns.map((_) => 'LOWER(type) LIKE ?').join(' OR '),
      whereArgs: patterns,
      orderBy: 'date DESC, id DESC',
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['id'] as String?;
  }

  /// Raw GET rather than the generated `listAthlete*Curves`: those demand
  /// three filter lists and deserialize strictly, so any new field the
  /// server adds would fail the whole call.
  static Future<Map<String, dynamic>> _fetchFromApi(
    CurveSport sport,
    CurveMetric metric,
  ) async {
    final client = IntervalsSession.instance.client;
    if (client == null) throw StateError('Not connected to Intervals.icu.');
    final response = await client.dio.get<Object>(
      '/api/v1/athlete/0/${metric.apiPath}.json',
      queryParameters: {
        'type': sport.apiType,
        'curves': curvePeriodIds.join(','),
      },
      options: Options(
        // The generated auth interceptors only add credentials to requests
        // that declare this.
        extra: {
          'secure': <Map<String, String>>[
            {'type': 'http', 'scheme': 'basic', 'name': 'APIKey'},
          ],
        },
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is String) return jsonDecode(data) as Map<String, dynamic>;
    throw StateError('Unexpected curves response.');
  }
}
