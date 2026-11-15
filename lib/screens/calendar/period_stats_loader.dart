import '../../data/planned_items.dart';
import '../../data/repositories/activities_repository.dart';
import '../../data/repositories/wellness_repository.dart';
import '../../evaluation/period_stats.dart';
import '../../evaluation/year_stats_service.dart';
import '../../util/dates.dart';
import 'calendar_data.dart';

/// One month as the header summary reads it, plus its sports.
class MonthStats {
  const MonthStats({
    required this.month,
    required this.doneTss,
    required this.plannedTss,
    required this.doneMinutes,
    required this.doneCount,
    required this.plannedCount,
    required this.ctlChange,
    required this.bySport,
  });

  /// First day of the month.
  final DateTime month;
  final int doneTss;
  final int plannedTss;
  final int doneMinutes;
  final int doneCount;
  final int plannedCount;
  final double? ctlChange;
  final Map<StatSport, SportTotals> bySport;

  /// Endurance total (no strength) — distance for the headline.
  SportTotals get total => enduranceTotal(bySport);
  bool get isEmpty => doneCount == 0 && plannedCount == 0;
}

/// Everything the period statistics peek draws.
class PeriodStatsData {
  const PeriodStatsData({required this.date, this.month, required this.year});

  final DateTime date;

  /// Null when the peek is for a year alone.
  final MonthStats? month;
  final YearStats year;
}

/// Reads a month and its year from the local cache — never the network.
/// The month's headline figures come from [PeriodSummary], the same maths as
/// the Calendar header; the sports from [totalsBySport], the same as the
/// year.
class PeriodStatsLoader {
  PeriodStatsLoader({
    ActivitiesRepository? activities,
    PlannedItemsRepository? planned,
    WellnessRepository? wellness,
    YearStatsService? years,
    DateTime Function()? clock,
  }) : _activities = activities ?? ActivitiesRepository(),
       _planned = planned ?? PlannedItemsRepository(),
       _wellness = wellness ?? WellnessRepository(),
       _years = years ?? YearStatsService.instance,
       _clock = clock ?? DateTime.now;

  final ActivitiesRepository _activities;
  final PlannedItemsRepository _planned;
  final WellnessRepository _wellness;
  final YearStatsService _years;
  final DateTime Function() _clock;

  Future<PeriodStatsData> load(DateTime date, {bool withMonth = true}) async {
    final day = dateOnly(date);
    final year = (await _years.load(day.year, fresh: true)).stats;
    MonthStats? month;
    if (withMonth) month = await _month(DateTime(day.year, day.month, 1));
    return PeriodStatsData(date: day, month: month, year: year);
  }

  Future<MonthStats> _month(DateTime first) async {
    final last = DateTime(first.year, first.month + 1, 0);
    final from = isoDate(first);
    final to = isoDate(last);
    final activities = await _activities.getRange(from, to);
    final events = await _planned.getRange(from, to);
    final wellness = await _wellness.getRange(from, to);
    final data = const CalendarFilter().apply(
      CalendarData(
        eventsByDate: _byDate(events, (e) => e.date),
        activitiesByDate: _byDate(activities, (a) => a.date),
        wellnessByDate: {for (final w in wellness) w.date: w},
      ),
    );
    final summary = PeriodSummary(data, first, last, today: _clock());
    return MonthStats(
      month: first,
      doneTss: summary.doneTss,
      plannedTss: summary.plannedTss,
      doneMinutes: summary.doneMinutes,
      doneCount: summary.doneCount,
      plannedCount: summary.plannedCount,
      ctlChange: summary.ctlChange,
      bySport: totalsBySport(
        statRows([for (final l in data.activitiesByDate.values) ...l]),
        from: from,
        to: to,
      ),
    );
  }

  static Map<String, List<T>> _byDate<T>(
    Iterable<T> items,
    String Function(T) date,
  ) {
    final out = <String, List<T>>{};
    for (final item in items) {
      out.putIfAbsent(date(item), () => []).add(item);
    }
    return out;
  }
}
