import 'package:flutter/material.dart';

import '../../data/models/local_event.dart';
import '../../util/dates.dart';

/// Calendar entries that aren't sessions — sick and injured days, holidays,
/// notes, races, targets, season starts — by every day they cover.
///
/// Multi-day entries (`end_date_local`, the inclusive last day — the same
/// reading as the event editor and illness mode) appear on each day within
/// [oldest]..[newest] (ISO dates); workouts are left out (they are drawn as
/// sessions).
Map<String, List<LocalEvent>> expandDayEvents(
  Iterable<LocalEvent> events,
  String oldest,
  String newest,
) {
  final out = <String, List<LocalEvent>>{};
  final first = DateTime.tryParse(oldest);
  final last = DateTime.tryParse(newest);
  if (first == null || last == null) return out;
  for (final e in events) {
    if (e.category == null || e.category == 'WORKOUT') continue;
    final start = DateTime.tryParse(e.date);
    if (start == null) continue;
    final endRaw = DateTime.tryParse(e.raw['end_date_local'] as String? ?? '');
    var end = endRaw == null || endRaw.isBefore(start) ? start : endRaw;
    // Guard against a runaway range (a year is plenty for any entry).
    if (end.difference(start).inDays > 366) {
      end = start.add(const Duration(days: 366));
    }
    var day = dateOnly(start);
    final stop = dateOnly(end);
    while (!day.isAfter(stop)) {
      if (!day.isBefore(dateOnly(first)) && !day.isAfter(dateOnly(last))) {
        out.putIfAbsent(isoDate(day), () => []).add(e);
      }
      day = day.add(const Duration(days: 1));
    }
  }
  return out;
}

/// Races are drawn as day events, not as session markers.
bool isRaceCategory(String? category) =>
    category == 'RACE_A' || category == 'RACE_B' || category == 'RACE_C';

IconData eventCategoryIcon(String? category) => switch (category) {
  'SICK' => Icons.sick_outlined,
  'INJURED' => Icons.healing_outlined,
  'HOLIDAY' => Icons.beach_access_outlined,
  'NOTE' => Icons.sticky_note_2_outlined,
  'RACE_A' || 'RACE_B' || 'RACE_C' => Icons.flag_outlined,
  'TARGET' => Icons.track_changes,
  'SEASON_START' => Icons.play_circle_outline,
  _ => Icons.event_outlined,
};

Color eventCategoryColor(String? category, ColorScheme scheme) =>
    switch (category) {
      'SICK' => scheme.error,
      'INJURED' => Colors.deepOrange.shade400,
      'HOLIDAY' => Colors.lightBlue.shade600,
      'RACE_A' => Colors.amber.shade800,
      'RACE_B' || 'RACE_C' => Colors.amber.shade600,
      'TARGET' => scheme.tertiary,
      _ => scheme.outline,
    };

/// Sick and injured days tint the whole day cell, so a run of them reads
/// as a block.
bool tintsDay(String? category) => category == 'SICK' || category == 'INJURED';
