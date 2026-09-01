import 'dart:convert';

import 'package:triiq/client/intervalls/intervalls_client.dart';

/// A *planned* calendar entry from Intervals.icu — a prescribed workout, a
/// race, a note, a rest day. The counterpart to [LocalActivity], which is
/// what actually happened.
class LocalEvent {
  const LocalEvent({
    required this.id,
    required this.date,
    required this.category,
    required this.type,
    required this.name,
    required this.description,
    required this.plannedLoad,
    required this.plannedTime,
    required this.plannedDistance,
    required this.indoor,
    required this.raw,
    required this.syncedAt,
  });

  final String id;

  /// ISO-8601 local day the entry falls on, e.g. `2026-08-30`.
  final String date;

  /// `WORKOUT`, `RACE_A`, `NOTE`, `HOLIDAY`, … See `EventCategoryEnum`.
  final String? category;

  /// Sport, e.g. `Ride`, `Run`, `Swim`.
  final String? type;
  final String? name;
  final String? description;

  /// Prescribed training load (TSS). Intervals.icu reports this as
  /// `icu_training_load` once a workout is structured, and as `load_target`
  /// when the athlete only set a target — prefer the former.
  final int? plannedLoad;

  /// Prescribed duration in seconds.
  final int? plannedTime;

  /// Prescribed distance in metres.
  final double? plannedDistance;

  final bool indoor;

  /// The full API response, for fields not promoted to their own column.
  final Map<String, dynamic> raw;
  final DateTime syncedAt;

  /// Whether this is something the athlete is meant to *do*, as opposed to a
  /// note, holiday, illness marker or plan container.
  bool get isTraining =>
      category == 'WORKOUT' ||
      category == 'RACE_A' ||
      category == 'RACE_B' ||
      category == 'RACE_C';

  /// When the entry starts, from `start_date_local`, falling back to the
  /// cached day. Null only if neither parses.
  DateTime? get startsAt =>
      DateTime.tryParse(raw['start_date_local'] as String? ?? '') ??
      DateTime.tryParse(date);

  /// Whether the entry is pinned to a time of day. Intervals.icu writes
  /// midnight for a session that is simply "somewhere today", which is an
  /// all-day entry in calendar terms rather than a workout at 00:00.
  bool get hasTimeOfDay {
    final start = startsAt;
    return start != null && (start.hour != 0 || start.minute != 0);
  }

  factory LocalEvent.fromApi(Event event) {
    final json = event.toJson();
    final startDateLocal = event.startDateLocal ?? '';
    return LocalEvent(
      id: event.id?.toString() ?? '',
      date: startDateLocal.length >= 10
          ? startDateLocal.substring(0, 10)
          : startDateLocal,
      category: event.category?.name,
      type: event.type,
      name: event.name,
      description: event.description,
      plannedLoad: event.icuTrainingLoad ?? event.loadTarget,
      plannedTime: event.movingTime ?? event.timeTarget,
      plannedDistance: event.distance ?? event.distanceTarget,
      indoor: event.indoor ?? false,
      raw: json,
      syncedAt: DateTime.now(),
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'date': date,
    'category': category,
    'type': type,
    'name': name,
    'description': description,
    'planned_load': plannedLoad,
    'planned_time': plannedTime,
    'planned_distance': plannedDistance,
    'indoor': indoor ? 1 : 0,
    'raw': jsonEncode(raw),
    'synced_at': syncedAt.millisecondsSinceEpoch,
  };

  factory LocalEvent.fromMap(Map<String, Object?> map) => LocalEvent(
    id: map['id'] as String,
    date: map['date'] as String,
    category: map['category'] as String?,
    type: map['type'] as String?,
    name: map['name'] as String?,
    description: map['description'] as String?,
    plannedLoad: map['planned_load'] as int?,
    plannedTime: map['planned_time'] as int?,
    plannedDistance: map['planned_distance'] as double?,
    indoor: (map['indoor'] as int? ?? 0) == 1,
    raw: jsonDecode(map['raw'] as String) as Map<String, dynamic>,
    syncedAt: DateTime.fromMillisecondsSinceEpoch(map['synced_at'] as int),
  );
}
