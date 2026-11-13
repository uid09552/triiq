import '../data/models/local_activity.dart';
import '../evaluation/readiness.dart';
import '../evaluation/session_evaluator.dart';
import '../util/dates.dart';
import 'knowledge.dart';
import 'load_curve.dart';
import 'plan_models.dart';

/// Where the athlete has drifted from the saved plan, and what to do about
/// it. Pure data: `AdaptationService` turns each into a proposal the
/// athlete applies or dismisses — nothing here changes the plan.
sealed class Adaptation {
  const Adaptation(this.key);

  /// Stable across runs for the same situation, so a dismissal sticks and
  /// Today and the chat share one proposal.
  final String key;
}

/// A past session of the current week with nothing done for it: move it to
/// [to], or let it go when [to] is null.
class MissedSession extends Adaptation {
  MissedSession(this.session, this.to) : super('missed:${session.id}');

  final PlanSession session;
  final DateTime? to;
}

/// The week that just ended was well off its target: set the next week's
/// load-graph factor to [factor].
class WeekLoadOffTarget extends Adaptation {
  WeekLoadOffTarget({
    required this.endedWeek,
    required this.nextWeek,
    required this.target,
    required this.actual,
    required this.currentFactor,
    required this.factor,
    required this.uncappedLoad,
  }) : super('load:${endedWeek.index}');

  final PlanWeek endedWeek;
  final PlanWeek nextWeek;
  final double target;
  final int actual;
  final double currentFactor;
  final double factor;

  /// The next week's load the rule asked for before the 80 % floor; above
  /// [newLoad] when the floor held it up.
  final double uncappedLoad;

  bool get under => actual < target;
  double get newLoad => nextWeek.requestedLoad * factor;
  bool get floorLimited => uncappedLoad < newLoad - 0.5;
}

/// Readiness says Caution or Back off and [session] (today, hard) is
/// planned: swap it with [swapWith], move it to [to], or let it go when
/// both are null.
class ReadinessConflict extends Adaptation {
  ReadinessConflict(this.session, this.level, {this.swapWith, this.to})
    : super('readiness:${isoDate(session.date)}:${session.id}');

  final PlanSession session;
  final ReadinessLevel level;
  final PlanSession? swapWith;
  final DateTime? to;
}

/// Below and above these shares of a week's target, the next week is
/// adjusted.
const underTargetShare = 0.8;
const overTargetShare = 1.2;

bool isHardSlot(SessionSlot slot) =>
    slot == SessionSlot.intervals || slot == SessionSlot.long;

/// Every adaptation that applies on [today], minus [dismissed] keys.
/// [rampCap] is the goal's weekly increase (0.10 = 10 %).
List<Adaptation> adaptPlan({
  required TrainingPlan plan,
  required Goal goal,
  required List<LocalActivity> activities,
  required DateTime today,
  required double rampCap,
  Readiness? readiness,
  Set<String> dismissed = const {},
}) {
  final day = dateOnly(today);
  final current = weekOf(plan, day);
  final result = <Adaptation>[];

  if (current != null) {
    for (final s in current.sessions) {
      if (!s.date.isBefore(day) || s.id == null) continue;
      if (_doneOn(activities, s)) continue;
      result.add(
        MissedSession(
          s,
          isHardSlot(s.slot) || s.isStrength
              ? rescheduleDay(plan, goal, current, s, after: day)
              : null,
        ),
      );
    }

    final ended = current.index > 0 ? plan.weeks[current.index - 1] : null;
    if (ended != null) {
      final load = _weekLoad(plan, ended, current, activities, rampCap);
      if (load != null) result.add(load);
    }

    if (readiness != null && readiness.level != ReadinessLevel.ready) {
      for (final s in current.sessions) {
        if (s.date != day || s.id == null || !isHardSlot(s.slot)) continue;
        final swap = current.sessions
            .where(
              (o) =>
                  o.id != null &&
                  o.slot == SessionSlot.z2 &&
                  o.date.isAfter(day),
            )
            .fold<PlanSession?>(
              null,
              (best, o) =>
                  best == null || o.date.isBefore(best.date) ? o : best,
            );
        result.add(
          ReadinessConflict(
            s,
            readiness.level,
            swapWith: swap,
            to: swap == null
                ? rescheduleDay(plan, goal, current, s, after: day)
                : null,
          ),
        );
      }
    }
  }

  return [
    for (final a in result)
      if (!dismissed.contains(a.key)) a,
  ];
}

/// The plan week [day] falls in, or `null` outside the plan.
PlanWeek? weekOf(TrainingPlan plan, DateTime day) {
  for (final w in plan.weeks) {
    final end = w.startDate.add(const Duration(days: 7));
    if (!day.isBefore(w.startDate) && day.isBefore(end)) return w;
  }
  return null;
}

/// The earliest training day after [after] in [week] that can take
/// [session]: a goal training day, below the per-day cap, with no other
/// hard session on it or the day either side, and no strength session the
/// day before it. A strength session instead needs a day with no hard
/// session on it or the day after, at most one other session, and no
/// strength session on it or the day either side — it is never stacked
/// onto a hard day. `null` when none fits.
DateTime? rescheduleDay(
  TrainingPlan plan,
  Goal goal,
  PlanWeek week,
  PlanSession session, {
  required DateTime after,
}) {
  final others = plan.sessions.where((o) => o.id != session.id).toList();
  bool hardOn(DateTime d) =>
      others.any((o) => o.date == d && isHardSlot(o.slot));
  bool strengthOn(DateTime d) => others.any((o) => o.date == d && o.isStrength);
  for (var i = 0; i < 7; i++) {
    final d = DateTime(
      week.startDate.year,
      week.startDate.month,
      week.startDate.day + i,
    );
    if (!d.isAfter(after) || !goal.weekdays.contains(d.weekday)) continue;
    final before = DateTime(d.year, d.month, d.day - 1);
    final next = DateTime(d.year, d.month, d.day + 1);
    if (session.isStrength) {
      final endurance = others.where((o) => o.date == d && !o.isStrength);
      if (endurance.length >= 2 || hardOn(d) || hardOn(next)) continue;
      if (strengthOn(d) || strengthOn(before) || strengthOn(next)) continue;
      return d;
    }
    // Strength sessions are extra: they don't count against the cap.
    if (others.where((o) => o.date == d && !o.isStrength).length >=
        goal.effectiveMaxPerDay) {
      continue;
    }
    if (isHardSlot(session.slot) &&
        (hardOn(d) || hardOn(before) || hardOn(next) || strengthOn(before))) {
      continue;
    }
    return d;
  }
  return null;
}

/// Whether any activity of [s]'s sport family is on its date — looser than
/// one-to-one matching on purpose: a false "missed" costs more than a
/// missed one.
bool _doneOn(List<LocalActivity> activities, PlanSession s) {
  final date = isoDate(s.date);
  final family = sportFamily(s.sport);
  return activities.any((a) => a.date == date && sportFamily(a.type) == family);
}

WeekLoadOffTarget? _weekLoad(
  TrainingPlan plan,
  PlanWeek ended,
  PlanWeek next,
  List<LocalActivity> activities,
  double rampCap,
) {
  if (isTaperPhase(next.phase) || next.requestedLoad <= 0) return null;
  final target = ended.targetLoad;
  if (target <= 0) return null;
  final first = isoDate(ended.startDate);
  final last = isoDate(ended.startDate.add(const Duration(days: 6)));
  // Strength load is outside the endurance target, so outside the actual.
  final actual = activities
      .where(
        (a) =>
            a.date.compareTo(first) >= 0 &&
            a.date.compareTo(last) <= 0 &&
            !isStrengthType(a.type),
      )
      .fold<int>(0, (sum, a) => sum + (a.trainingLoad ?? 0));

  final double wanted;
  if (actual < target * underTargetShare) {
    wanted = actual * (1 + rampCap);
  } else if (actual > target * overTargetShare) {
    wanted = target;
  } else {
    return null;
  }
  final factor = double.parse(
    (wanted / next.requestedLoad)
        .clamp(Goal.minFactor, Goal.maxFactor)
        .toStringAsFixed(2),
  );
  if (factor >= next.factor - 1e-9) return null;
  return WeekLoadOffTarget(
    endedWeek: ended,
    nextWeek: next,
    target: target,
    actual: actual,
    currentFactor: next.factor,
    factor: factor,
    uncappedLoad: wanted,
  );
}
