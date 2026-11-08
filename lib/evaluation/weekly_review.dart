import '../data/models/local_activity.dart';
import '../data/models/local_event.dart';
import '../data/models/local_wellness.dart';
import '../data/planned_items.dart';
import '../data/repositories/activities_repository.dart';
import '../data/repositories/wellness_repository.dart';
import '../util/dates.dart';
import 'intensity.dart';
import 'session_evaluator.dart';

/// One day of the review: what was planned, what was done, and which done
/// session fulfilled which plan.
class ReviewDay {
  const ReviewDay({
    required this.date,
    required this.planned,
    required this.done,
    required this.matches,
  });

  final DateTime date;
  final List<LocalEvent> planned;
  final List<LocalActivity> done;

  /// Activity id → the planned session it fulfilled.
  final Map<String, LocalEvent> matches;

  /// Planned sessions nothing was done for.
  List<LocalEvent> get missed => [
    for (final p in planned)
      if (!matches.values.contains(p)) p,
  ];
}

/// A week against its plan: compliance, intensity distribution and load
/// trend. Computed from the cache only, so it works offline; every number
/// here is code, the next-week note (elsewhere) only explains them.
class WeeklyReview {
  const WeeklyReview({
    required this.weekStart,
    required this.days,
    required this.split,
    required this.sessionsWithoutZones,
    required this.load,
    required this.plannedLoad,
    required this.recentAverageLoad,
    required this.ctlStart,
    required this.ctlEnd,
    required this.atlStart,
    required this.atlEnd,
    required this.lowTarget,
    required this.lowTolerance,
  });

  final DateTime weekStart;
  final List<ReviewDay> days;

  /// The week's time per intensity domain; `null` when no session had
  /// zone times.
  final IntensitySplit? split;

  /// Completed sessions whose split couldn't be counted.
  final int sessionsWithoutZones;

  final int load;
  final int plannedLoad;

  /// Mean completed load of the weeks before; `null` without history.
  final double? recentAverageLoad;
  final double? ctlStart;
  final double? ctlEnd;
  final double? atlStart;
  final double? atlEnd;
  final double lowTarget;
  final double lowTolerance;

  int get plannedSessions => days.fold(0, (n, d) => n + d.planned.length);
  int get completedPlanned => days.fold(0, (n, d) => n + d.matches.length);
  int get missedSessions => days.fold(0, (n, d) => n + d.missed.length);

  /// Planned sessions done, 0..1; `null` when nothing was planned.
  double? get compliance =>
      plannedSessions == 0 ? null : completedPlanned / plannedSessions;

  /// Too little easy time against the 80/20 target (more is fine).
  bool get outside8020 {
    final low = split?.lowShare;
    return low != null && low < lowTarget - lowTolerance;
  }

  double? get loadVsRecent =>
      recentAverageLoad == null || recentAverageLoad == 0
      ? null
      : load / recentAverageLoad! - 1;

  double? get ctlChange =>
      ctlStart == null || ctlEnd == null ? null : ctlEnd! - ctlStart!;
  double? get atlChange =>
      atlStart == null || atlEnd == null ? null : atlEnd! - atlStart!;
  double? get formEnd =>
      ctlEnd == null || atlEnd == null ? null : ctlEnd! - atlEnd!;
}

/// Builds a [WeeklyReview] — pure over its inputs.
WeeklyReview buildWeeklyReview({
  required DateTime weekStart,
  required List<LocalActivity> activities,
  required List<LocalEvent> planned,
  required List<LocalWellness> wellness,
  required List<int> previousWeekLoads,
  double lowTarget = 0.8,
  double lowTolerance = 0.05,
}) {
  final monday = startOfWeek(weekStart);
  final training = planned.where((p) => p.isTraining).toList();
  final days = <ReviewDay>[];
  for (var d = 0; d < 7; d++) {
    final day = monday.add(Duration(days: d));
    final key = isoDate(day);
    final done = activities.where((a) => a.date == key).toList();
    final dayPlanned = training.where((p) => p.date == key).toList();
    days.add(
      ReviewDay(
        date: day,
        planned: dayPlanned,
        done: done,
        matches: matchAll(done, dayPlanned),
      ),
    );
  }

  IntensitySplit? split;
  var noZones = 0;
  for (final a in activities) {
    final s = intensityOf(a.raw);
    if (s == null) {
      noZones++;
      continue;
    }
    split = split == null ? s : split + s;
  }

  final sorted = [...wellness]..sort((a, b) => a.date.compareTo(b.date));
  final before = sorted.where((w) => w.date.compareTo(isoDate(monday)) < 0);
  final inWeek = sorted.where(
    (w) =>
        w.date.compareTo(isoDate(monday)) >= 0 &&
        w.date.compareTo(isoDate(monday.add(const Duration(days: 6)))) <= 0,
  );
  final start = before.isEmpty ? null : before.last;
  final end = inWeek.isEmpty ? null : inWeek.last;

  return WeeklyReview(
    weekStart: monday,
    days: days,
    split: split,
    sessionsWithoutZones: noZones,
    load: activities.fold(0, (n, a) => n + (a.trainingLoad ?? 0)),
    plannedLoad: training.fold(0, (n, p) => n + (p.plannedLoad ?? 0)),
    recentAverageLoad: previousWeekLoads.isEmpty
        ? null
        : previousWeekLoads.fold<int>(0, (a, b) => a + b) /
              previousWeekLoads.length,
    ctlStart: start?.ctl,
    ctlEnd: end?.ctl,
    atlStart: start?.atl,
    atlEnd: end?.atl,
    lowTarget: lowTarget,
    lowTolerance: lowTolerance,
  );
}

/// Reads the inputs for a week's review from the cache.
class WeeklyReviewLoader {
  WeeklyReviewLoader({
    ActivitiesRepository? activities,
    PlannedItemsRepository? planned,
    WellnessRepository? wellness,
  }) : _activities = activities ?? ActivitiesRepository(),
       _planned = planned ?? PlannedItemsRepository(),
       _wellness = wellness ?? WellnessRepository();

  final ActivitiesRepository _activities;
  final PlannedItemsRepository _planned;
  final WellnessRepository _wellness;

  /// Weeks of history the load trend compares against.
  static const trendWeeks = 4;

  Future<WeeklyReview> load(DateTime anyDayOfWeek) async {
    final monday = startOfWeek(anyDayOfWeek);
    final sunday = monday.add(const Duration(days: 6));
    final from = isoDate(monday);
    final to = isoDate(sunday);
    final history = monday.subtract(const Duration(days: 7 * trendWeeks));
    final past = await _activities.getRange(
      isoDate(history),
      isoDate(monday.subtract(const Duration(days: 1))),
    );
    final loads = List.filled(trendWeeks, 0);
    var any = false;
    for (final a in past) {
      final d = DateTime.tryParse(a.date);
      if (d == null) continue;
      final i = d.difference(history).inDays ~/ 7;
      if (i >= 0 && i < trendWeeks) {
        loads[i] += a.trainingLoad ?? 0;
        any = true;
      }
    }
    return buildWeeklyReview(
      weekStart: monday,
      activities: await _activities.getRange(from, to),
      planned: await _planned.getRange(from, to),
      wellness: await _wellness.getRange(
        isoDate(monday.subtract(const Duration(days: 3))),
        to,
      ),
      previousWeekLoads: any ? loads : const [],
    );
  }
}
