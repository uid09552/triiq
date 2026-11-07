import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../client/intervalls/intervalls_client.dart';
import '../data/db/app_database.dart';
import '../data/intervals_session.dart';

/// One interval Intervals.icu detected in an activity, by sample index.
class SessionInterval {
  const SessionInterval({
    required this.start,
    required this.end,
    this.label,
    this.type,
    this.movingTime,
    this.averageWatts,
    this.averageHeartrate,
    this.averageSpeed,
  });

  /// First and last sample index (into [SessionStreams.series]).
  final int start;
  final int end;
  final String? label;

  /// `WORK` or `RECOVERY` as Intervals.icu labels it.
  final String? type;
  final int? movingTime;
  final int? averageWatts;
  final int? averageHeartrate;

  /// Metres per second.
  final double? averageSpeed;

  bool get isWork => type == null || type == 'WORK';

  Map<String, dynamic> toJson() => {
    'start_index': start,
    'end_index': end,
    'label': label,
    'type': type,
    'moving_time': movingTime,
    'average_watts': averageWatts,
    'average_heartrate': averageHeartrate,
    'average_speed': averageSpeed,
  };

  static SessionInterval? fromJson(Map<String, dynamic> j) {
    final start = j['start_index'];
    final end = j['end_index'];
    if (start is! num || end is! num) return null;
    return SessionInterval(
      start: start.toInt(),
      end: end.toInt(),
      label: j['label'] as String?,
      type: j['type'] as String?,
      movingTime: (j['moving_time'] as num?)?.toInt(),
      averageWatts: (j['average_watts'] as num?)?.toInt(),
      averageHeartrate: (j['average_heartrate'] as num?)?.toInt(),
      averageSpeed: (j['average_speed'] as num?)?.toDouble(),
    );
  }
}

/// An activity's time series (one value per sample; `time` in seconds) and
/// its intervals.
class SessionStreams {
  const SessionStreams({required this.series, this.intervals = const []});

  /// By Intervals.icu stream type: `time`, `watts`, `heartrate`,
  /// `velocity_smooth`, `cadence`, `altitude`, …
  final Map<String, List<double?>> series;
  final List<SessionInterval> intervals;

  List<double?>? get time => series['time'];

  /// Streams worth drawing: those with at least one value, besides `time`.
  Iterable<String> get drawable => series.entries
      .where(
        (e) =>
            e.key != 'time' &&
            e.key != 'distance' &&
            e.value.any((v) => v != null),
      )
      .map((e) => e.key);

  bool get isEmpty => drawable.isEmpty;

  Map<String, dynamic> toJson() => {
    'series': series,
    'intervals': [for (final i in intervals) i.toJson()],
  };

  factory SessionStreams.fromJson(Map<String, dynamic> j) => SessionStreams(
    series: {
      for (final e
          in (j['series'] as Map<String, dynamic>? ?? const {}).entries)
        e.key: [
          for (final v in e.value as List) v is num ? v.toDouble() : null,
        ],
    },
    intervals: [
      for (final i in j['intervals'] as List? ?? const [])
        ?SessionInterval.fromJson(i as Map<String, dynamic>),
    ],
  );

  /// From the API's stream list and intervals.
  factory SessionStreams.fromApi(
    List<ActivityStream> streams,
    IntervalsDTO? intervals,
  ) {
    final series = <String, List<double?>>{};
    for (final s in streams) {
      final type = s.type;
      final data = s.data;
      if (type == null || data is! List) continue;
      series[type] = [for (final v in data) v is num ? v.toDouble() : null];
    }
    return SessionStreams(
      series: series,
      intervals: [
        for (final i in intervals?.icuIntervals ?? const <Interval>[])
          ?SessionInterval.fromJson(i.toJson()),
      ],
    );
  }
}

/// Fetches one activity's streams and intervals from Intervals.icu.
typedef StreamsFetcher = Future<SessionStreams> Function(String activityId);

/// The stream types the diagram shows (and so the ones fetched).
const diagramStreamTypes = [
  'time',
  'watts',
  'heartrate',
  'velocity_smooth',
  'cadence',
  'altitude',
  'distance',
];

/// Streams by activity, fetched the first time the diagram is opened and
/// read from SQLite afterwards — never part of sync, so long rides cost
/// nothing until someone looks at them.
class ActivityStreamsRepository {
  ActivityStreamsRepository({AppDatabase? database, StreamsFetcher? fetch})
    : _database = database ?? AppDatabase.instance,
      _fetch = fetch ?? _fetchFromApi;

  final AppDatabase _database;
  final StreamsFetcher _fetch;

  Future<SessionStreams?> cached(String activityId) async {
    final db = await _database.database;
    final rows = await db.query(
      'activity_streams',
      where: 'activity_id = ?',
      whereArgs: [activityId],
    );
    if (rows.isEmpty) return null;
    return SessionStreams.fromJson(
      jsonDecode(rows.first['data'] as String) as Map<String, dynamic>,
    );
  }

  final _inFlight = <String, Future<SessionStreams>>{};

  /// The cached streams, or fetched and cached now. Two cards asking for the
  /// same activity at once share one download.
  Future<SessionStreams> load(String activityId) {
    return _inFlight[activityId] ??= _loadOnce(activityId).whenComplete(() {
      // A block, not `=> remove(...)`: that would return the very future
      // being completed, and whenComplete would wait on it forever.
      _inFlight.remove(activityId);
    });
  }

  Future<SessionStreams> _loadOnce(String activityId) async {
    final hit = await cached(activityId);
    if (hit != null) return hit;
    final streams = await _fetch(activityId);
    await _store(activityId, streams);
    return streams;
  }

  final _withoutDistance = <String>{};

  /// Like [load], but guarantees the `distance` stream when the activity has
  /// one: streams cached before it was fetched are fetched once more. An
  /// activity that has none (indoor, no GPS) is remembered for this run so it
  /// isn't asked for again; offline, the old copy is used as it is.
  Future<SessionStreams> loadForCompare(String activityId) async {
    final hit = await cached(activityId);
    if (hit != null &&
        (hit.series.containsKey('distance') ||
            _withoutDistance.contains(activityId))) {
      return hit;
    }
    final SessionStreams fresh;
    try {
      fresh = await _fetch(activityId);
    } catch (_) {
      if (hit != null) return hit;
      rethrow;
    }
    if (!fresh.series.containsKey('distance')) _withoutDistance.add(activityId);
    await _store(activityId, fresh);
    return fresh;
  }

  Future<void> _store(String activityId, SessionStreams streams) async {
    final db = await _database.database;
    await db.insert('activity_streams', {
      'activity_id': activityId,
      'data': jsonEncode(streams.toJson()),
      'fetched_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<SessionStreams> _fetchFromApi(String activityId) async {
    final client = IntervalsSession.instance.client;
    if (client == null) throw StateError('Not connected to Intervals.icu.');
    final api = client.getAktivittenApi();
    final streams = await api.getActivityStreams(
      id: activityId,
      ext: '',
      types: diagramStreamTypes,
    );
    IntervalsDTO? intervals;
    try {
      intervals = (await api.getIntervals(id: activityId)).data;
    } catch (_) {
      // Intervals are a bonus on top of the curves; a failure here should
      // not hide the chart.
    }
    return SessionStreams.fromApi(streams.data ?? const [], intervals);
  }
}
