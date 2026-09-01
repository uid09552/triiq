import 'dart:convert';

import 'package:triiq/client/intervalls/intervalls_client.dart';

/// A completed activity, cached from Intervals.icu.
class LocalActivity {
  const LocalActivity({
    required this.id,
    required this.date,
    required this.type,
    required this.name,
    required this.movingTime,
    required this.distance,
    required this.trainingLoad,
    required this.raw,
    required this.syncedAt,
  });

  final String id;

  /// ISO-8601 local day the activity started on, e.g. `2026-08-30`.
  final String date;
  final String? type;
  final String? name;
  final int? movingTime;
  final double? distance;

  /// Intervals.icu's training load for the activity (its TSS equivalent).
  final int? trainingLoad;

  /// The full API response, for fields not promoted to their own column.
  final Map<String, dynamic> raw;
  final DateTime syncedAt;

  /// Rehydrates the full typed [Activity] from [raw] — every field the API
  /// returned, not just the handful promoted to columns. Used by the
  /// activity detail screen instead of teaching this class about fields
  /// nothing else needs.
  Activity toActivity() => Activity.fromJson(raw);

  factory LocalActivity.fromApi(Activity activity) {
    final json = activity.toJson();
    final startDateLocal = activity.startDateLocal ?? '';
    return LocalActivity(
      id: activity.id ?? '',
      date: startDateLocal.length >= 10
          ? startDateLocal.substring(0, 10)
          : startDateLocal,
      type: activity.type,
      name: activity.name,
      movingTime: activity.movingTime,
      distance: activity.distance,
      trainingLoad: activity.icuTrainingLoad,
      raw: json,
      syncedAt: DateTime.now(),
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'date': date,
    'type': type,
    'name': name,
    'moving_time': movingTime,
    'distance': distance,
    'training_load': trainingLoad,
    'raw': jsonEncode(raw),
    'synced_at': syncedAt.millisecondsSinceEpoch,
  };

  factory LocalActivity.fromMap(Map<String, Object?> map) => LocalActivity(
    id: map['id'] as String,
    date: map['date'] as String,
    type: map['type'] as String?,
    name: map['name'] as String?,
    movingTime: map['moving_time'] as int?,
    distance: map['distance'] as double?,
    trainingLoad: map['training_load'] as int?,
    raw: jsonDecode(map['raw'] as String) as Map<String, dynamic>,
    syncedAt: DateTime.fromMillisecondsSinceEpoch(map['synced_at'] as int),
  );
}
