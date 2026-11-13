import 'package:flutter/foundation.dart';

import '../../data/intervals_session.dart';
import '../../data/models/local_activity.dart';
import '../../data/models/local_event.dart';
import '../../data/models/local_wellness.dart';
import '../../data/pending_deletes.dart';
import '../../data/planned_items.dart';
import '../../data/repositories/activities_repository.dart';
import '../../data/repositories/events_repository.dart';
import '../../data/repositories/plans_repository.dart';
import '../../data/repositories/wellness_repository.dart';
import '../../data/sync/sync_service.dart';
import '../../evaluation/readiness.dart';
import '../../evaluation/readiness_service.dart';
import '../../evaluation/session_evaluator.dart';
import '../../plan/plan_models.dart';
import '../../util/dates.dart';
import '../today/readiness_card.dart' show isHardSession;
import 'day_events.dart';

/// How hard [CalendarLoader.sync] tries to refetch before the cache is read.
enum CalendarFreshness {
  /// Only fetch a span that has never been synced — plain navigation.
  ifMissing,

  /// Fetch unless the cache was refreshed within [SyncService.staleAfter] —
  /// arriving on the tab.
  ifStale,

  /// Always fetch — the refresh button.
  force,
}

/// Everything the calendar draws for one visible range, keyed by ISO date.
class CalendarData {
  const CalendarData({
    this.eventsByDate = const {},
    this.dayEventsByDate = const {},
    this.activitiesByDate = const {},
    this.readinessByDate = const {},
    this.wellnessByDate = const {},
    this.plan,
  });

  /// Planned sessions (plan sessions and Intervals.icu events).
  final Map<String, List<LocalEvent>> eventsByDate;

  /// Sick days, notes, holidays, races, … by every day they cover.
  final Map<String, List<LocalEvent>> dayEventsByDate;
  final Map<String, List<LocalActivity>> activitiesByDate;

  /// Readiness for past days and today that had wearable data.
  final Map<String, Readiness> readinessByDate;
  final Map<String, LocalWellness> wellnessByDate;

  /// The current training plan, for the year view's phase bands.
  final TrainingPlan? plan;
}

/// Syncs and reads a range for the calendar. The app uses the cache and
/// [SyncService]; tests hand the screen their own.
class CalendarLoader {
  CalendarLoader({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  final _syncService = SyncService();

  Future<void> sync(
    DateTime oldest,
    DateTime newest,
    CalendarFreshness freshness,
  ) async {
    switch (freshness) {
      case CalendarFreshness.ifMissing:
        await _syncService.syncRangeIfMissing(oldest, newest);
      case CalendarFreshness.ifStale:
        await _syncService.syncRangeIfStale(oldest, newest);
      case CalendarFreshness.force:
        // syncRange throws when disconnected; an offline calendar should
        // just show what's cached.
        if (IntervalsSession.instance.isConnected) {
          await _syncService.syncRange(oldest, newest);
        }
    }
  }

  Future<CalendarData> read(DateTime oldest, DateTime newest) async {
    final from = isoDate(oldest);
    final to = isoDate(newest);
    final events = await PlannedItemsRepository().getRange(from, to);
    final activities = await ActivitiesRepository().getRange(from, to);
    // A sick week that started before the visible range still covers it.
    final dayEvents = expandDayEvents(
      await EventsRepository().getRange(
        isoDate(oldest.subtract(const Duration(days: 90))),
        to,
      ),
      from,
      to,
    );
    final wellness = await WellnessRepository().getRange(from, to);

    final readiness = <String, Readiness>{};
    final today = dateOnly(_clock());
    if (!oldest.isAfter(today)) {
      final last = newest.isAfter(today) ? today : newest;
      try {
        final days = await ReadinessService(
          clock: _clock,
        ).loadDays(oldest, last);
        var d = dateOnly(oldest);
        for (final r in days) {
          if (r.dataState == ReadinessDataState.complete) {
            readiness[isoDate(d)] = r;
          }
          d = DateTime(d.year, d.month, d.day + 1);
        }
      } catch (error) {
        debugPrint('CalendarLoader: readiness unavailable: $error');
      }
    }

    TrainingPlan? plan;
    try {
      plan = await PlansRepository().getCurrent();
    } catch (error) {
      debugPrint('CalendarLoader: plan unavailable: $error');
    }

    return CalendarData(
      eventsByDate: _byDate(events, (e) => e.date),
      dayEventsByDate: dayEvents,
      activitiesByDate: _byDate(activities, (a) => a.date),
      readinessByDate: readiness,
      wellnessByDate: {for (final w in wellness) w.date: w},
      plan: plan,
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

/// The sports the filter chips offer.
enum CalendarSport { swim, ride, run, strength, other }

CalendarSport calendarSportOf(String? type) => switch (sportFamily(type)) {
  'swim' => CalendarSport.swim,
  'ride' => CalendarSport.ride,
  'run' => CalendarSport.run,
  'strength' => CalendarSport.strength,
  _ => CalendarSport.other,
};

/// What the filter chips leave on screen. Day events (sick days, races, …)
/// always stay.
@immutable
class CalendarFilter {
  const CalendarFilter({
    this.sports = const {},
    this.planned = true,
    this.completed = true,
  });

  /// Empty = every sport.
  final Set<CalendarSport> sports;
  final bool planned;
  final bool completed;

  bool get isActive => sports.isNotEmpty || !planned || !completed;

  CalendarFilter copyWith({
    Set<CalendarSport>? sports,
    bool? planned,
    bool? completed,
  }) => CalendarFilter(
    sports: sports ?? this.sports,
    planned: planned ?? this.planned,
    completed: completed ?? this.completed,
  );

  bool _sportOk(String? type) =>
      sports.isEmpty || sports.contains(calendarSportOf(type));

  /// [data] with what the filter hides — and planned entries still inside
  /// their undo window ([PendingDeletes]) — left out.
  CalendarData apply(CalendarData data, {PendingDeletes? pendingDeletes}) {
    final hidden = pendingDeletes ?? PendingDeletes.instance;
    if (!isActive && hidden.isEmpty) return data;
    return CalendarData(
      eventsByDate: {
        for (final entry in data.eventsByDate.entries)
          entry.key: [
            for (final e in entry.value)
              if (!hidden.isHidden(e.id) &&
                  (!e.isTraining ||
                      isRaceCategory(e.category) ||
                      (planned && _sportOk(e.type))))
                e,
          ],
      },
      dayEventsByDate: data.dayEventsByDate,
      activitiesByDate: {
        for (final entry in data.activitiesByDate.entries)
          entry.key: [
            for (final a in entry.value)
              if (completed && _sportOk(a.type)) a,
          ],
      },
      readinessByDate: data.readinessByDate,
      wellnessByDate: data.wellnessByDate,
      plan: data.plan,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CalendarFilter &&
      setEquals(other.sports, sports) &&
      other.planned == planned &&
      other.completed == completed;

  @override
  int get hashCode => Object.hash(Object.hashAll(sports), planned, completed);
}

/// How a day's done load compares with its plan, for the cell fill.
enum DayFill {
  /// Nothing planned and nothing done.
  none,

  /// Planned, nothing done (yet).
  empty,

  /// Below 80 % of the planned load.
  partial,

  /// 80–120 % of the plan, or training on an unplanned day.
  done,

  /// Over 120 % of the plan.
  over,
}

/// The figures a day cell and its screen-reader summary are drawn from.
class DaySummary {
  DaySummary._({
    required this.plannedTss,
    required this.doneTss,
    required this.plannedCount,
    required this.doneCount,
    required this.plannedMinutes,
    required this.doneMinutes,
    required this.hasRace,
    required this.hasKey,
    required this.hasStrength,
  });

  factory DaySummary.of(
    List<LocalEvent> events,
    List<LocalActivity> activities, {
    List<LocalEvent> dayEvents = const [],
  }) {
    final sessions = events
        .where((e) => e.isTraining && !isRaceCategory(e.category))
        .toList();
    final plannedMinutes = <CalendarSport, int>{};
    for (final e in sessions) {
      final sport = calendarSportOf(e.type);
      plannedMinutes[sport] =
          (plannedMinutes[sport] ?? 0) + ((e.plannedTime ?? 0) ~/ 60);
    }
    final doneMinutes = <CalendarSport, int>{};
    for (final a in activities) {
      final sport = calendarSportOf(a.type);
      doneMinutes[sport] =
          (doneMinutes[sport] ?? 0) + ((a.movingTime ?? 0) ~/ 60);
    }
    bool strength(String? type, String? slot) =>
        slot == 'strength' || isStrengthType(type);
    return DaySummary._(
      plannedTss: sessions.fold(0, (s, e) => s + (e.plannedLoad ?? 0)),
      doneTss: activities.fold(0, (s, a) => s + (a.trainingLoad ?? 0)),
      plannedCount: sessions.length,
      doneCount: activities.length,
      plannedMinutes: plannedMinutes,
      doneMinutes: doneMinutes,
      hasRace:
          dayEvents.any((e) => isRaceCategory(e.category)) ||
          events.any((e) => isRaceCategory(e.category)),
      hasKey: sessions.any(isHardSession),
      hasStrength:
          sessions.any((e) => strength(e.type, e.planSessionSlot)) ||
          activities.any((a) => strength(a.type, null)),
    );
  }

  final int plannedTss;
  final int doneTss;
  final int plannedCount;
  final int doneCount;
  final Map<CalendarSport, int> plannedMinutes;
  final Map<CalendarSport, int> doneMinutes;
  final bool hasRace;
  final bool hasKey;
  final bool hasStrength;

  bool get isEmpty => plannedCount == 0 && doneCount == 0;

  DayFill get fill {
    if (plannedCount == 0) return doneCount == 0 ? DayFill.none : DayFill.done;
    if (doneCount == 0) return DayFill.empty;
    if (plannedTss <= 0) return DayFill.done;
    final ratio = doneTss / plannedTss;
    if (ratio < 0.8) return DayFill.partial;
    if (ratio <= 1.2) return DayFill.done;
    return DayFill.over;
  }
}

/// Totals over a range of days, for the header and the week view.
class PeriodSummary {
  PeriodSummary(
    CalendarData data,
    DateTime from,
    DateTime to, {
    DateTime? today,
  }) {
    final last = dateOnly(today ?? DateTime.now());
    double? firstCtl;
    double? lastCtl;
    for (
      var d = dateOnly(from);
      !d.isAfter(to);
      d = DateTime(d.year, d.month, d.day + 1)
    ) {
      final key = isoDate(d);
      final s = DaySummary.of(
        data.eventsByDate[key] ?? const [],
        data.activitiesByDate[key] ?? const [],
      );
      plannedTss += s.plannedTss;
      doneTss += s.doneTss;
      plannedCount += s.plannedCount;
      doneCount += s.doneCount;
      for (final e in s.plannedMinutes.entries) {
        plannedMinutesBySport[e.key] =
            (plannedMinutesBySport[e.key] ?? 0) + e.value;
        plannedMinutes += e.value;
      }
      for (final e in s.doneMinutes.entries) {
        doneMinutesBySport[e.key] = (doneMinutesBySport[e.key] ?? 0) + e.value;
        doneMinutes += e.value;
      }
      final ctl = data.wellnessByDate[key]?.ctl;
      if (ctl != null && !d.isAfter(last)) {
        firstCtl ??= ctl;
        lastCtl = ctl;
      }
    }
    ctlChange = firstCtl != null && lastCtl != null ? lastCtl - firstCtl : null;
  }

  int plannedTss = 0;
  int doneTss = 0;
  int plannedCount = 0;
  int doneCount = 0;
  int plannedMinutes = 0;
  int doneMinutes = 0;
  final plannedMinutesBySport = <CalendarSport, int>{};
  final doneMinutesBySport = <CalendarSport, int>{};

  /// CTL at the last day with a value (up to today) minus the first.
  late final double? ctlChange;
}
