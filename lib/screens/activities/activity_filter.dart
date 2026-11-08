import 'package:flutter/material.dart';

import '../../data/models/local_activity.dart';
import '../../util/dates.dart';
import 'route_card.dart' show hasRouteMap;

/// Date presets offered in the Activities filter.
enum DatePreset { thisWeek, thisMonth, last3Months, custom }

/// How the Activities list is ordered.
enum ActivitySort { date, distance, duration, load }

/// Search, filters and sort of the Activities list — pure, so it is applied
/// to the local cache on every keystroke without touching the network.
@immutable
class ActivityFilter {
  const ActivityFilter({
    this.query = '',
    this.type,
    this.datePreset,
    this.customRange,
    this.minKm,
    this.maxKm,
    this.minMinutes,
    this.maxMinutes,
    this.hasPower = false,
    this.hasGps = false,
    this.sort = ActivitySort.date,
  });

  /// Matched case-insensitively against the name (and type).
  final String query;
  final String? type;
  final DatePreset? datePreset;

  /// Only with [DatePreset.custom].
  final DateTimeRange? customRange;
  final double? minKm, maxKm;
  final int? minMinutes, maxMinutes;
  final bool hasPower, hasGps;
  final ActivitySort sort;

  bool get hasDistance => minKm != null || maxKm != null;
  bool get hasDuration => minMinutes != null || maxMinutes != null;

  /// Anything narrowing the list (sorting doesn't).
  bool get isActive =>
      query.trim().isNotEmpty ||
      type != null ||
      datePreset != null ||
      hasDistance ||
      hasDuration ||
      hasPower ||
      hasGps;

  ActivityFilter copyWith({
    String? query,
    Object? type = _keep,
    Object? datePreset = _keep,
    Object? customRange = _keep,
    Object? minKm = _keep,
    Object? maxKm = _keep,
    Object? minMinutes = _keep,
    Object? maxMinutes = _keep,
    bool? hasPower,
    bool? hasGps,
    ActivitySort? sort,
  }) => ActivityFilter(
    query: query ?? this.query,
    type: type == _keep ? this.type : type as String?,
    datePreset: datePreset == _keep
        ? this.datePreset
        : datePreset as DatePreset?,
    customRange: customRange == _keep
        ? this.customRange
        : customRange as DateTimeRange?,
    minKm: minKm == _keep ? this.minKm : minKm as double?,
    maxKm: maxKm == _keep ? this.maxKm : maxKm as double?,
    minMinutes: minMinutes == _keep ? this.minMinutes : minMinutes as int?,
    maxMinutes: maxMinutes == _keep ? this.maxMinutes : maxMinutes as int?,
    hasPower: hasPower ?? this.hasPower,
    hasGps: hasGps ?? this.hasGps,
    sort: sort ?? this.sort,
  );

  static const _keep = Object();

  /// The first and last day (inclusive) of the date filter, or null.
  DateTimeRange? dateRange(DateTime now) {
    final today = dateOnly(now);
    switch (datePreset) {
      case null:
        return null;
      case DatePreset.thisWeek:
        return DateTimeRange(
          start: today.subtract(Duration(days: today.weekday - 1)),
          end: today,
        );
      case DatePreset.thisMonth:
        return DateTimeRange(
          start: DateTime(today.year, today.month),
          end: today,
        );
      case DatePreset.last3Months:
        return DateTimeRange(
          start: DateTime(today.year, today.month - 3, today.day),
          end: today,
        );
      case DatePreset.custom:
        return customRange;
    }
  }

  List<LocalActivity> apply(List<LocalActivity> all, {DateTime? now}) {
    final q = query.trim().toLowerCase();
    final range = dateRange(now ?? DateTime.now());
    final from = range == null ? null : isoDate(range.start);
    final to = range == null ? null : isoDate(range.end);
    final out = [
      for (final a in all)
        if ((q.isEmpty ||
                (a.name ?? '').toLowerCase().contains(q) ||
                (a.type ?? '').toLowerCase().contains(q)) &&
            (type == null || a.type == type) &&
            (from == null || a.date.compareTo(from) >= 0) &&
            (to == null || a.date.compareTo(to) <= 0) &&
            _inRange((a.distance ?? 0) / 1000, minKm, maxKm) &&
            _inRange(
              (a.movingTime ?? 0) / 60,
              minMinutes?.toDouble(),
              maxMinutes?.toDouble(),
            ) &&
            (!hasPower || activityHasPower(a)) &&
            (!hasGps || activityHasGps(a)))
          a,
    ];
    int byDate(LocalActivity a, LocalActivity b) => b.date.compareTo(a.date);
    int desc(num? a, num? b) => (b ?? -1).compareTo(a ?? -1);
    out.sort(
      (a, b) => switch (sort) {
        ActivitySort.date => byDate(a, b),
        ActivitySort.distance => desc(a.distance, b.distance),
        ActivitySort.duration => desc(a.movingTime, b.movingTime),
        ActivitySort.load => desc(a.trainingLoad, b.trainingLoad),
      },
    );
    return out;
  }

  static bool _inRange(double v, double? min, double? max) =>
      (min == null || v >= min) && (max == null || v <= max);
}

/// Recorded with a power meter.
bool activityHasPower(LocalActivity a) {
  final w = a.raw['icu_average_watts'];
  return a.raw['device_watts'] == true || (w is num && w > 0);
}

/// Has a GPS track: from the recorded streams when Intervals.icu lists them,
/// else an outdoor run or ride.
bool activityHasGps(LocalActivity a) {
  final streams = a.raw['stream_types'];
  if (streams is List) return streams.contains('latlng');
  return hasRouteMap(a);
}
