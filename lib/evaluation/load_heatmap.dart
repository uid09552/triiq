import 'dart:math' as math;

import '../data/models/local_activity.dart';
import '../util/dates.dart';
import 'training_analytics.dart' show LoadSport, loadSportOf;

/// One day of the heatmap grid.
class HeatmapDay {
  const HeatmapDay({
    required this.date,
    required this.tss,
    required this.sessions,
    required this.inRange,
  });

  final DateTime date;
  final int tss;
  final int sessions;

  /// False for the padding days before the first and after the last day of
  /// the period (the grid starts on a Monday and ends on a Sunday).
  final bool inRange;
}

/// A period of daily training load laid out like a calendar: one column per
/// week (Monday first), seven rows.
class LoadHeatmap {
  const LoadHeatmap({
    required this.from,
    required this.to,
    required this.weeks,
    required this.reference,
    required this.totalTss,
    required this.activeDays,
    required this.longestStreak,
    this.busiestWeekStart,
    this.busiestWeekTss = 0,
  });

  final DateTime from;
  final DateTime to;

  /// Columns, oldest first; each has seven days, Monday to Sunday.
  final List<List<HeatmapDay>> weeks;

  /// The load that counts as a full colour: the 90th percentile of the
  /// training days, so one race day doesn't wash everything else out.
  final int reference;
  final int totalTss;
  final int activeDays;

  /// Most consecutive days with any load.
  final int longestStreak;
  final DateTime? busiestWeekStart;
  final int busiestWeekTss;

  /// Colour step 0 (rest) to 4 (hard) for [tss] against [reference].
  int levelOf(int tss) {
    if (tss <= 0) return 0;
    final f = tss / reference;
    return f < 0.25
        ? 1
        : f < 0.5
        ? 2
        : f < 0.75
        ? 3
        : 4;
  }

  HeatmapDay? dayOn(DateTime date) {
    final d = dateOnly(date);
    for (final week in weeks) {
      for (final day in week) {
        if (day.inRange && day.date == d) return day;
      }
    }
    return null;
  }
}

/// Daily load for [from]..[to] (inclusive), optionally for one sport.
LoadHeatmap buildLoadHeatmap(
  Iterable<LocalActivity> activities, {
  required DateTime from,
  required DateTime to,
  LoadSport? sport,
}) {
  final start = dateOnly(from);
  final end = dateOnly(to);
  final tss = <String, int>{};
  final sessions = <String, int>{};
  for (final a in activities) {
    if (sport != null && loadSportOf(a.type) != sport) continue;
    if (a.date.compareTo(isoDate(start)) < 0 ||
        a.date.compareTo(isoDate(end)) > 0) {
      continue;
    }
    tss.update(a.date, (v) => v + (a.trainingLoad ?? 0), ifAbsent: () => a.trainingLoad ?? 0);
    sessions.update(a.date, (v) => v + 1, ifAbsent: () => 1);
  }

  final weeks = <List<HeatmapDay>>[];
  var weekStart = startOfWeek(start);
  while (!weekStart.isAfter(end)) {
    weeks.add([
      for (var i = 0; i < 7; i++)
        () {
          final d = DateTime(weekStart.year, weekStart.month, weekStart.day + i);
          final inRange = !d.isBefore(start) && !d.isAfter(end);
          final key = isoDate(d);
          return HeatmapDay(
            date: d,
            tss: inRange ? tss[key] ?? 0 : 0,
            sessions: inRange ? sessions[key] ?? 0 : 0,
            inRange: inRange,
          );
        }(),
    ]);
    weekStart = DateTime(weekStart.year, weekStart.month, weekStart.day + 7);
  }

  final days = [
    for (final w in weeks)
      for (final d in w)
        if (d.inRange) d,
  ];
  final loaded = days.where((d) => d.tss > 0).map((d) => d.tss).toList()..sort();
  final reference = loaded.isEmpty
      ? 1
      : math.max(1, loaded[((loaded.length - 1) * 0.9).round()]);

  var streak = 0, longest = 0;
  for (final d in days) {
    streak = d.tss > 0 ? streak + 1 : 0;
    longest = math.max(longest, streak);
  }
  DateTime? bestWeek;
  var bestTss = 0;
  for (final w in weeks) {
    final sum = w.fold<int>(0, (s, d) => s + d.tss);
    if (sum > bestTss) {
      bestTss = sum;
      bestWeek = w.first.date;
    }
  }

  return LoadHeatmap(
    from: start,
    to: end,
    weeks: weeks,
    reference: reference,
    totalTss: days.fold<int>(0, (s, d) => s + d.tss),
    activeDays: loaded.length,
    longestStreak: longest,
    busiestWeekStart: bestWeek,
    busiestWeekTss: bestTss,
  );
}
