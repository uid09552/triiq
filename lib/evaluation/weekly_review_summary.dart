import '../data/models/local_event.dart';
import '../data/models/local_wellness.dart';
import '../data/planned_items.dart';
import '../data/repositories/activities_repository.dart';
import '../data/repositories/plans_repository.dart';
import '../data/repositories/wellness_repository.dart';
import '../plan/plan_models.dart';
import '../screens/settings/weekly_targets_settings.dart';
import '../screens/today/weekly_targets_row.dart' show weeklySportSeconds;
import '../util/dates.dart';
import 'fatigue_warning.dart' show FatigueRules;
import 'readiness.dart';
import 'readiness_service.dart';
import 'wellness_baseline.dart';
import 'weekly_review.dart';

/// Which way a wellness signal moved over the week.
enum TrendDirection { up, down, stable }

/// Done vs target time for one sport with a weekly target.
class SportProgress {
  const SportProgress({
    required this.sport,
    required this.seconds,
    required this.targetSeconds,
  });

  /// `swim`, `cycle` or `run` (see `canonicalSport`).
  final String sport;
  final int seconds;
  final int targetSeconds;

  Map<String, dynamic> toJson() => {
    'sport': sport,
    'hours': _round1(seconds / 3600),
    'target_hours': _round1(targetSeconds / 3600),
  };
}

/// A planned session that matters most in its week: an interval or long
/// slot of a TriIQ plan, else the one with the most planned load.
class KeySession {
  const KeySession({required this.date, required this.name, this.hit});

  final DateTime date;
  final String name;

  /// Whether a done session fulfilled it; `null` for next week's.
  final bool? hit;

  Map<String, dynamic> toJson() => {
    'date': isoDate(date),
    'name': name,
    'done': ?hit,
  };
}

/// A race in the coming week.
class UpcomingEvent {
  const UpcomingEvent({
    required this.date,
    required this.name,
    required this.category,
  });

  final DateTime date;
  final String name;
  final String category;

  Map<String, dynamic> toJson() => {
    'date': isoDate(date),
    'name': name,
    'category': category,
  };
}

/// What the plan holds for the week after the reviewed one.
class NextWeekOutlook {
  const NextWeekOutlook({
    this.targetLoad,
    this.phase,
    this.keySessions = const [],
    this.events = const [],
  });

  final int? targetLoad;
  final String? phase;
  final List<KeySession> keySessions;
  final List<UpcomingEvent> events;

  bool get isEmpty =>
      targetLoad == null &&
      phase == null &&
      keySessions.isEmpty &&
      events.isEmpty;

  Map<String, dynamic> toJson() => {
    'target_tss': ?targetLoad,
    'phase': ?phase,
    if (keySessions.isNotEmpty)
      'key_sessions': [for (final k in keySessions) k.toJson()],
    if (events.isNotEmpty) 'races': [for (final e in events) e.toJson()],
  };
}

/// The week in numbers — the weekly-review notification and the
/// `get_weekly_review` agent tool both read this, so they say the same.
/// Every figure is computed on the device; nothing here comes from an LLM.
class WeeklyReviewSummary {
  const WeeklyReviewSummary({
    required this.weekStart,
    required this.asOf,
    required this.activities,
    required this.load,
    required this.targetLoad,
    required this.sports,
    required this.plannedSessions,
    required this.completedSessions,
    required this.missedSessions,
    required this.keySession,
    required this.ctlChange,
    required this.ctlEnd,
    required this.formEnd,
    required this.usualCtlChange,
    required this.rampHigh,
    required this.readyDays,
    required this.cautionDays,
    required this.backOffDays,
    required this.hrv,
    required this.restingHr,
    required this.phase,
    required this.next,
  });

  final DateTime weekStart;

  /// The moment the figures describe — days after it are not "missed" yet.
  final DateTime asOf;
  final int activities;
  final int load;

  /// The plan week's target TSS, else the planned sessions' total; `null`
  /// when nothing was planned.
  final int? targetLoad;
  final List<SportProgress> sports;
  final int plannedSessions;
  final int completedSessions;
  final int missedSessions;
  final KeySession? keySession;
  final double? ctlChange;
  final double? ctlEnd;
  final double? formEnd;

  /// Mean weekly CTL change of the weeks before; `null` without history.
  final double? usualCtlChange;

  /// CTL rose by the fatigue warning's ramp threshold or more, or clearly
  /// faster than usual.
  final bool rampHigh;
  final int readyDays;
  final int cautionDays;
  final int backOffDays;
  final TrendDirection? hrv;
  final TrendDirection? restingHr;

  /// The plan phase of the reviewed week.
  final String? phase;
  final NextWeekOutlook next;

  DateTime get weekEnd =>
      DateTime(weekStart.year, weekStart.month, weekStart.day + 6);

  /// Nothing done and nothing planned: no review to send.
  bool get hasData => activities > 0 || plannedSessions > 0;

  Map<String, dynamic> toJson() => {
    'week_start': isoDate(weekStart),
    'week_end': isoDate(weekEnd),
    'as_of': isoDate(asOf),
    'activities': activities,
    'load_tss': load,
    'target_tss': ?targetLoad,
    'phase': ?phase,
    if (sports.isNotEmpty)
      'sport_targets': [for (final s in sports) s.toJson()],
    'planned_sessions': plannedSessions,
    'completed_planned_sessions': completedSessions,
    'missed_sessions': missedSessions,
    'key_session': ?keySession?.toJson(),
    'ctl_change': ?_round1n(ctlChange),
    'ctl_end': ?_round1n(ctlEnd),
    'form_end': ?_round1n(formEnd),
    'usual_weekly_ctl_change': ?_round1n(usualCtlChange),
    'ramp_above_usual': rampHigh,
    'readiness_days': {
      'ready': readyDays,
      'caution': cautionDays,
      'back_off': backOffDays,
    },
    'hrv_trend': ?hrv?.name,
    'resting_hr_trend': ?restingHr?.name,
    if (!next.isEmpty) 'next_week': next.toJson(),
  };
}

double _round1(double v) => (v * 10).round() / 10;
double? _round1n(double? v) => v == null ? null : _round1(v);

const _keySlots = {'intervals', 'long'};

/// The 1–[count] key sessions of [planned] (training only, races left out),
/// in date order.
List<LocalEvent> keySessionsOf(List<LocalEvent> planned, {int count = 1}) {
  final workouts = [
    for (final p in planned)
      if (p.category == 'WORKOUT') p,
  ];
  if (workouts.isEmpty) return const [];
  int rank(LocalEvent e) => _keySlots.contains(e.planSessionSlot) ? 1 : 0;
  final sorted = [...workouts]
    ..sort((a, b) {
      final r = rank(b).compareTo(rank(a));
      if (r != 0) return r;
      final l = (b.plannedLoad ?? 0).compareTo(a.plannedLoad ?? 0);
      return l != 0 ? l : a.date.compareTo(b.date);
    });
  return (sorted.take(count).toList()
    ..sort((a, b) => a.date.compareTo(b.date)));
}

/// The direction [signal] moved from the end of the week before to
/// [end]: its smoothed value against half a baseline MADσ.
TrendDirection? signalTrend(
  List<LocalWellness> wellness,
  WellnessSignal signal,
  DateTime start,
  DateTime end,
) {
  final values = wellnessSignalValues(wellness, signal);
  WellnessReading? latest(DateTime from, DateTime to) {
    for (
      var d = to;
      !d.isBefore(from);
      d = DateTime(d.year, d.month, d.day - 1)
    ) {
      final r = wellnessReading(values, d, signal);
      if (r.smoothed != null) return r;
    }
    return null;
  }

  final before = latest(
    DateTime(start.year, start.month, start.day - 3),
    DateTime(start.year, start.month, start.day - 1),
  );
  final after = latest(DateTime(end.year, end.month, end.day - 3), end);
  if (before == null || after == null) return null;
  final sigma = after.baseline?.sigma ?? signal.minSigma;
  final delta = after.smoothed! - before.smoothed!;
  if (delta > sigma / 2) return TrendDirection.up;
  if (delta < -sigma / 2) return TrendDirection.down;
  return TrendDirection.stable;
}

/// Mean CTL change per week over the [weeks] weeks before [monday].
double? usualWeeklyCtlChange(
  List<LocalWellness> wellness,
  DateTime monday, {
  int weeks = 4,
}) {
  double? ctlOn(DateTime day) {
    LocalWellness? best;
    final iso = isoDate(day);
    for (final w in wellness) {
      if (w.ctl == null || w.date.compareTo(iso) > 0) continue;
      if (best == null || w.date.compareTo(best.date) > 0) best = w;
    }
    // Only a reading from that week counts as its end.
    if (best == null ||
        DateTime.parse(
          best.date,
        ).isBefore(DateTime(day.year, day.month, day.day - 6))) {
      return null;
    }
    return best.ctl;
  }

  final changes = <double>[];
  for (var i = 1; i <= weeks; i++) {
    final end = DateTime(
      monday.year,
      monday.month,
      monday.day - 1 - 7 * (i - 1),
    );
    final start = DateTime(end.year, end.month, end.day - 7);
    final a = ctlOn(start);
    final b = ctlOn(end);
    if (a != null && b != null) changes.add(b - a);
  }
  if (changes.isEmpty) return null;
  return changes.reduce((a, b) => a + b) / changes.length;
}

/// Builds the summary — pure over its inputs.
WeeklyReviewSummary buildWeeklyReviewSummary({
  required WeeklyReview review,
  required DateTime asOf,
  required int activities,
  required Map<String, int> sportSeconds,
  Map<String, int> sportTargets = const {},
  PlanWeek? planWeek,
  PlanWeek? nextPlanWeek,
  List<LocalEvent> nextPlanned = const [],
  List<Readiness> readiness = const [],
  List<LocalWellness> wellness = const [],
  FatigueRules fatigueRules = const FatigueRules(),
}) {
  final today = dateOnly(asOf);
  var missed = 0;
  for (final d in review.days) {
    if (d.date.isBefore(today)) missed += d.missed.length;
  }

  final planned = [for (final d in review.days) ...d.planned];
  final key = keySessionsOf(planned).firstOrNull;
  KeySession? keySession;
  if (key != null) {
    final day = review.days.firstWhere((d) => isoDate(d.date) == key.date);
    keySession = KeySession(
      date: day.date,
      name: key.name ?? key.type ?? '',
      hit: day.matches.values.contains(key),
    );
  }

  final target = planWeek != null
      ? planWeek.targetLoad.round()
      : review.plannedLoad > 0
      ? review.plannedLoad
      : null;

  final usual = usualWeeklyCtlChange(wellness, review.weekStart);
  final change = review.ctlChange;
  final rampHigh =
      change != null &&
      (change >= fatigueRules.rampPerWeek ||
          (usual != null && change >= 3 && change > usual + 3));

  var ready = 0, caution = 0, backOff = 0;
  for (final r in readiness) {
    if (r.dataState != ReadinessDataState.complete) continue;
    switch (r.level) {
      case ReadinessLevel.ready:
        ready++;
      case ReadinessLevel.caution:
        caution++;
      case ReadinessLevel.backOff:
        backOff++;
    }
  }

  final weekEnd = DateTime(
    review.weekStart.year,
    review.weekStart.month,
    review.weekStart.day + 6,
  );
  final trendEnd = today.isBefore(weekEnd) ? today : weekEnd;

  final nextSessions = keySessionsOf(nextPlanned, count: 2);
  final races = [
    for (final e in nextPlanned)
      if (e.category?.startsWith('RACE') ?? false)
        UpcomingEvent(
          date: DateTime.parse(e.date),
          name: e.name ?? e.type ?? '',
          category: e.category!,
        ),
  ];

  return WeeklyReviewSummary(
    weekStart: review.weekStart,
    asOf: asOf,
    activities: activities,
    load: review.load,
    targetLoad: target,
    sports: [
      for (final sport in const ['swim', 'cycle', 'run'])
        if (sportTargets[sport] != null)
          SportProgress(
            sport: sport,
            seconds: sportSeconds[sport] ?? 0,
            targetSeconds: sportTargets[sport]!,
          ),
    ],
    plannedSessions: review.plannedSessions,
    completedSessions: review.completedPlanned,
    missedSessions: missed,
    keySession: keySession,
    ctlChange: change,
    ctlEnd: review.ctlEnd,
    formEnd: review.formEnd,
    usualCtlChange: usual,
    rampHigh: rampHigh,
    readyDays: ready,
    cautionDays: caution,
    backOffDays: backOff,
    hrv: signalTrend(wellness, WellnessSignal.hrv, review.weekStart, trendEnd),
    restingHr: signalTrend(
      wellness,
      WellnessSignal.restingHr,
      review.weekStart,
      trendEnd,
    ),
    phase: planWeek?.phase,
    next: NextWeekOutlook(
      targetLoad: nextPlanWeek?.targetLoad.round(),
      phase: nextPlanWeek?.phase,
      keySessions: [
        for (final s in nextSessions)
          KeySession(
            date: DateTime.parse(s.date),
            name: s.name ?? s.type ?? '',
          ),
      ],
      events: races,
    ),
  );
}

/// Reads everything [buildWeeklyReviewSummary] needs from the cache.
class WeeklyReviewSummaryLoader {
  WeeklyReviewSummaryLoader({
    ActivitiesRepository? activities,
    PlannedItemsRepository? planned,
    WellnessRepository? wellness,
    PlansRepository? plans,
    ReadinessService? readiness,
    WeeklyTargetsSettings? targets,
    DateTime Function()? clock,
  }) : _activities = activities ?? ActivitiesRepository(),
       _planned = planned ?? PlannedItemsRepository(hidePendingDeletes: false),
       _wellness = wellness ?? WellnessRepository(),
       _plans = plans ?? PlansRepository(),
       _readiness = readiness ?? ReadinessService(wellness: wellness),
       _targets = targets ?? WeeklyTargetsSettings.instance,
       _clock = clock ?? DateTime.now;

  final ActivitiesRepository _activities;
  final PlannedItemsRepository _planned;
  final WellnessRepository _wellness;
  final PlansRepository _plans;
  final ReadinessService _readiness;
  final WeeklyTargetsSettings _targets;
  final DateTime Function() _clock;

  Future<WeeklyReviewSummary> load(DateTime anyDayOfWeek) async {
    final monday = startOfWeek(anyDayOfWeek);
    final sunday = DateTime(monday.year, monday.month, monday.day + 6);
    final nextMonday = DateTime(monday.year, monday.month, monday.day + 7);
    final nextSunday = DateTime(monday.year, monday.month, monday.day + 13);
    final now = _clock();
    final today = dateOnly(now);

    final review = await WeeklyReviewLoader(
      activities: _activities,
      planned: _planned,
      wellness: _wellness,
    ).load(monday);
    final weekActivities = await _activities.getRange(
      isoDate(monday),
      isoDate(sunday),
    );

    if (!_targets.isLoaded) await _targets.load();
    int? secs(double? hours) => hours == null ? null : (hours * 3600).round();
    final targets = <String, int>{
      'swim': ?secs(_targets.swimHours),
      'cycle': ?secs(_targets.cycleHours),
      'run': ?secs(_targets.runHours),
    };

    PlanWeek? planWeek, nextPlanWeek;
    try {
      final plan = await _plans.getCurrent();
      for (final w in plan?.weeks ?? const <PlanWeek>[]) {
        final start = dateOnly(w.startDate);
        if (start == monday) planWeek = w;
        if (start == nextMonday) nextPlanWeek = w;
      }
    } catch (_) {}

    final readinessEnd = today.isBefore(sunday) ? today : sunday;
    var readiness = const <Readiness>[];
    if (!readinessEnd.isBefore(monday)) {
      try {
        readiness = await _readiness.loadDays(monday, readinessEnd);
      } catch (_) {}
    }

    final wellness = await _wellness.getRange(
      isoDate(DateTime(monday.year, monday.month, monday.day - 70)),
      isoDate(sunday),
    );

    return buildWeeklyReviewSummary(
      review: review,
      asOf: now,
      activities: weekActivities.length,
      sportSeconds: weeklySportSeconds(weekActivities),
      sportTargets: targets,
      planWeek: planWeek,
      nextPlanWeek: nextPlanWeek,
      nextPlanned: await _planned.getRange(
        isoDate(nextMonday),
        isoDate(nextSunday),
      ),
      readiness: readiness,
      wellness: wellness,
    );
  }
}
