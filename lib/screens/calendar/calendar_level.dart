import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../util/dates.dart';

/// The calendar's zoom levels, outermost first: pinch in or tap moves one
/// step down, pinch out or the breadcrumb moves back up.
enum CalendarLevel { year, month, week, day }

extension CalendarLevelSteps on CalendarLevel {
  CalendarLevel? get inner => switch (this) {
    CalendarLevel.year => CalendarLevel.month,
    CalendarLevel.month => CalendarLevel.week,
    CalendarLevel.week => CalendarLevel.day,
    CalendarLevel.day => null,
  };

  CalendarLevel? get outer => switch (this) {
    CalendarLevel.year => null,
    CalendarLevel.month => CalendarLevel.year,
    CalendarLevel.week => CalendarLevel.month,
    CalendarLevel.day => CalendarLevel.week,
  };
}

/// The first and last day (inclusive) a [level] shows around [focus]: the
/// whole year, the month's Monday-start grid (six weeks), the Monday-start
/// week, or the day itself.
(DateTime, DateTime) calendarRange(CalendarLevel level, DateTime focus) {
  final d = dateOnly(focus);
  switch (level) {
    case CalendarLevel.year:
      return (DateTime(d.year, 1, 1), DateTime(d.year, 12, 31));
    case CalendarLevel.month:
      final first = DateTime(d.year, d.month, 1);
      final start = DateTime(first.year, first.month, 1 - (first.weekday - 1));
      return (start, DateTime(start.year, start.month, start.day + 41));
    case CalendarLevel.week:
      final start = startOfWeek(d);
      return (start, DateTime(start.year, start.month, start.day + 6));
    case CalendarLevel.day:
      return (d, d);
  }
}

/// [focus] moved by [amount] periods of [level]. Month and year steps keep
/// the day where the target month has it, else its last day.
DateTime shiftPeriod(CalendarLevel level, DateTime focus, int amount) {
  final d = dateOnly(focus);
  DateTime clampDay(int year, int month) {
    final last = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, d.day > last ? last : d.day);
  }

  return switch (level) {
    CalendarLevel.year => clampDay(d.year + amount, d.month),
    CalendarLevel.month => clampDay(d.year, d.month + amount),
    CalendarLevel.week => DateTime(d.year, d.month, d.day + 7 * amount),
    CalendarLevel.day => DateTime(d.year, d.month, d.day + amount),
  };
}

/// ISO-8601 week number (weeks start Monday; week 1 holds the first
/// Thursday of the year).
int isoWeekNumber(DateTime date) {
  final d = DateTime.utc(date.year, date.month, date.day);
  final thursday = d.add(Duration(days: 4 - d.weekday));
  final firstOfYear = DateTime.utc(thursday.year, 1, 1);
  return thursday.difference(firstOfYear).inDays ~/ 7 + 1;
}

/// The level and date the calendar was last left on, so it reopens there
/// (shared_preferences `calendar.level` / `calendar.date`).
class CalendarPrefs {
  const CalendarPrefs(this.level, this.date);

  static const levelKey = 'calendar.level';
  static const dateKey = 'calendar.date';

  final CalendarLevel level;
  final DateTime? date;

  static Future<CalendarPrefs?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final level = prefs.getString(levelKey);
      if (level == null) return null;
      return CalendarPrefs(
        CalendarLevel.values.firstWhere(
          (l) => l.name == level,
          orElse: () => CalendarLevel.month,
        ),
        DateTime.tryParse(prefs.getString(dateKey) ?? ''),
      );
    } catch (error) {
      debugPrint('CalendarPrefs: cannot read: $error');
      return null;
    }
  }

  Future<void> save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(levelKey, level.name);
      if (date != null) await prefs.setString(dateKey, isoDate(date!));
    } catch (error) {
      debugPrint('CalendarPrefs: cannot persist: $error');
    }
  }
}
