import '../data/models/local_activity.dart';
import '../data/models/local_event.dart';
import 'intensity.dart';

/// What a session was meant to be, as far as its plan says.
enum SessionIntent { easy, hard, unknown }

/// The one-line judgement on a session against its plan.
enum Verdict { onTarget, tooHard, tooEasy, cutShort }

/// Why the evaluation says what it says — each reason carries the figures
/// it is based on, so the screen can show them next to the verdict.
sealed class EvalReason {
  const EvalReason();
}

/// Done for [actualMinutes] of [plannedMinutes].
class ShortReason extends EvalReason {
  const ShortReason(this.actualMinutes, this.plannedMinutes);
  final int actualMinutes;
  final int plannedMinutes;
}

/// Planned as easy, but [hardShare] of the time was above the first
/// threshold (limit [limit]).
class TooIntenseReason extends EvalReason {
  const TooIntenseReason(this.hardShare, this.limit);
  final double hardShare;
  final double limit;
}

/// Planned as hard, but only [hardShare] of the time was above the first
/// threshold (at least [minimum] expected).
class NotIntenseReason extends EvalReason {
  const NotIntenseReason(this.hardShare, this.minimum);
  final double hardShare;
  final double minimum;
}

/// Load [actual] against [planned] TSS.
class LoadReason extends EvalReason {
  const LoadReason(this.actual, this.planned);
  final int actual;
  final int planned;
}

/// Planned versus actual duration and load (either side may be unknown).
class PlanComparison {
  const PlanComparison({
    required this.planned,
    this.plannedMinutes,
    this.actualMinutes,
    this.plannedLoad,
    this.actualLoad,
  });

  final LocalEvent planned;
  final int? plannedMinutes;
  final int? actualMinutes;
  final int? plannedLoad;
  final int? actualLoad;

  int? get minutesDelta => plannedMinutes == null || actualMinutes == null
      ? null
      : actualMinutes! - plannedMinutes!;
  int? get loadDelta => plannedLoad == null || actualLoad == null
      ? null
      : actualLoad! - plannedLoad!;
}

class SessionEvaluation {
  const SessionEvaluation({
    required this.split,
    required this.decouplingPercent,
    required this.decouplingAssessable,
    required this.plan,
    required this.intent,
    required this.verdict,
    required this.reasons,
  });

  /// Time per intensity domain; `null` when the activity has no zone times
  /// (then the split "cannot be assessed" — never estimated).
  final IntensitySplit? split;

  /// Aerobic decoupling (Intervals.icu's figure) when the session is long
  /// and steady enough for it to mean something.
  final double? decouplingPercent;
  final bool decouplingAssessable;

  final PlanComparison? plan;
  final SessionIntent intent;

  /// `null` without a plan to judge against.
  final Verdict? verdict;
  final List<EvalReason> reasons;
}

/// Evaluates one completed session — deterministic, from the cache only; the
/// agent explains these numbers but never makes them up.
///
/// The thresholds follow the training knowledge's 80/20 rule: an easy
/// session may have at most [easyHardShareLimit] of its time above the first
/// threshold (the 80/20 target minus its tolerance), an interval session
/// should have at least [hardMinimumShare] there.
class SessionEvaluator {
  const SessionEvaluator();

  static const easyHardShareLimit = 0.25;
  static const hardMinimumShare = 0.10;

  /// Less than this share of the planned duration is "cut short".
  static const cutShortRatio = 0.8;

  /// More than this ratio of the planned load is "too hard" whatever the
  /// intent; less than [underLoadRatio] on a hard session is "too easy".
  static const overLoadRatio = 1.25;
  static const underLoadRatio = 0.7;

  /// Decoupling only means something on a long, mostly steady session.
  static const decouplingMinMinutes = 60;
  static const decouplingMinLowShare = 0.7;

  SessionEvaluation evaluate(LocalActivity activity, {LocalEvent? planned}) {
    final split = intensityOf(activity.raw);
    final minutes = activity.movingTime == null
        ? null
        : (activity.movingTime! / 60).round();

    final rawDecoupling = activity.raw['decoupling'];
    final assessable =
        rawDecoupling is num &&
        minutes != null &&
        minutes >= decouplingMinMinutes &&
        (split?.lowShare ?? 0) >= decouplingMinLowShare;

    final plan = planned == null
        ? null
        : PlanComparison(
            planned: planned,
            plannedMinutes: planned.plannedTime == null
                ? null
                : (planned.plannedTime! / 60).round(),
            actualMinutes: minutes,
            plannedLoad: planned.plannedLoad,
            actualLoad: activity.trainingLoad,
          );
    final intent = planned == null ? SessionIntent.unknown : intentOf(planned);

    final reasons = <EvalReason>[];
    Verdict? verdict;
    if (plan != null) {
      final hardShare = split == null ? null : 1 - split.lowShare!;
      final pMin = plan.plannedMinutes;
      final aMin = plan.actualMinutes;
      final pLoad = plan.plannedLoad;
      final aLoad = plan.actualLoad;

      final cutShort =
          pMin != null &&
          aMin != null &&
          pMin > 0 &&
          aMin < pMin * cutShortRatio;
      final overLoad =
          pLoad != null &&
          aLoad != null &&
          pLoad > 0 &&
          aLoad > pLoad * overLoadRatio;
      final underLoad =
          pLoad != null &&
          aLoad != null &&
          pLoad > 0 &&
          aLoad < pLoad * underLoadRatio;
      final tooIntense =
          intent == SessionIntent.easy &&
          hardShare != null &&
          hardShare > easyHardShareLimit;
      final notIntense =
          intent == SessionIntent.hard &&
          hardShare != null &&
          hardShare < hardMinimumShare;

      if (cutShort) reasons.add(ShortReason(aMin, pMin));
      if (tooIntense)
        reasons.add(TooIntenseReason(hardShare, easyHardShareLimit));
      if (notIntense)
        reasons.add(NotIntenseReason(hardShare, hardMinimumShare));
      if (overLoad || (intent == SessionIntent.hard && underLoad)) {
        reasons.add(LoadReason(aLoad, pLoad));
      }

      verdict = cutShort
          ? Verdict.cutShort
          : tooIntense || overLoad
          ? Verdict.tooHard
          : notIntense || (intent == SessionIntent.hard && underLoad)
          ? Verdict.tooEasy
          : Verdict.onTarget;
    }

    return SessionEvaluation(
      split: split,
      decouplingPercent: assessable ? rawDecoupling.toDouble() : null,
      decouplingAssessable: assessable,
      plan: plan,
      intent: intent,
      verdict: verdict,
      reasons: reasons,
    );
  }

  /// What [planned] was meant to be: a TriIQ plan session knows its slot;
  /// otherwise its name is read for the usual words.
  static SessionIntent intentOf(LocalEvent planned) {
    switch (planned.planSessionSlot) {
      case 'intervals':
        return SessionIntent.hard;
      case 'z2' || 'long':
        return SessionIntent.easy;
    }
    final name = '${planned.name ?? ''} ${planned.description ?? ''}'
        .toLowerCase();
    const hard = [
      'interval',
      'threshold',
      'vo2',
      'tempo',
      'sweet spot',
      'race',
    ];
    const easy = ['z2', 'zone 2', 'endurance', 'easy', 'recovery', 'aerobic'];
    if (hard.any(name.contains)) return SessionIntent.hard;
    if (easy.any(name.contains)) return SessionIntent.easy;
    return SessionIntent.unknown;
  }
}

/// The sport family an Intervals.icu type belongs to, for matching a plan
/// to what was done (a planned Ride matches a VirtualRide).
String sportFamily(String? type) {
  final t = (type ?? '').toLowerCase();
  if (t.contains('ride') || t.contains('bike') || t.contains('cycl')) {
    return 'ride';
  }
  if (t.contains('run')) return 'run';
  if (t.contains('swim')) return 'swim';
  return t;
}

/// The planned session [activity] most likely fulfilled: same day, same
/// sport family, and of several the one nearest in duration. `null` when
/// there is none — no guessing across days or sports.
LocalEvent? matchPlanned(LocalActivity activity, Iterable<LocalEvent> planned) {
  final family = sportFamily(activity.type);
  LocalEvent? best;
  var bestGap = 1 << 30;
  for (final p in planned) {
    if (!p.isTraining || p.date != activity.date) continue;
    if (sportFamily(p.type) != family) continue;
    final gap = (p.plannedTime == null || activity.movingTime == null)
        ? (1 << 29)
        : (p.plannedTime! - activity.movingTime!).abs();
    if (gap < bestGap) {
      bestGap = gap;
      best = p;
    }
  }
  return best;
}

/// One-to-one matches for a set of days: each planned session is used by at
/// most one activity, longest activities first.
Map<String, LocalEvent> matchAll(
  Iterable<LocalActivity> activities,
  Iterable<LocalEvent> planned,
) {
  final left = planned.toList();
  final result = <String, LocalEvent>{};
  final ordered = activities.toList()
    ..sort((a, b) => (b.movingTime ?? 0).compareTo(a.movingTime ?? 0));
  for (final a in ordered) {
    final match = matchPlanned(a, left);
    if (match == null) continue;
    result[a.id] = match;
    left.remove(match);
  }
  return result;
}
