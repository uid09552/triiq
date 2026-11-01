import 'dart:math' as math;

import 'plan_models.dart';

/// CTL's time constant, in days, as Intervals.icu uses it.
const ctlDays = 42.0;

/// How much one week's average daily load still counts in CTL a week later.
final double ctlWeekDecay = math.exp(-7 / ctlDays);

/// Everything that bounds a week's load, gathered once per plan. Pure data:
/// the engine and the load-graph editor read the same object, so a warning
/// shown while dragging is the warning the generated plan carries.
class CurveLimits {
  const CurveLimits({
    required this.baseline,
    required this.rampCap,
    required this.maxCtlRamp,
    required this.recoveryThreshold,
    this.ctl,
    this.hoursCeilings = const {},
    this.holdEvery = 0,
    this.taperFactors = const [],
  });

  /// Weekly load the plan builds from (TSS).
  final double baseline;

  /// Largest week-over-week increase, as a fraction.
  final double rampCap;
  final double maxCtlRamp;

  /// A week below this fraction of the week before it is a recovery week.
  final double recoveryThreshold;

  /// CTL when the plan starts; `null` disables the CTL limit.
  final double? ctl;

  /// Every [holdEvery]th proposed week keeps the previous week's load
  /// instead of ramping; 0 turns the hold off.
  final int holdEvery;

  /// The most load the hours budget can carry, per phase.
  final Map<String, double> hoursCeilings;

  /// The plan ends in the event week: its last weeks taper to these
  /// fractions of the last week before the taper. Empty: no taper.
  final List<double> taperFactors;

  /// Where the taper starts in a [weeks]-week plan (= [weeks] without one).
  int taperStart(int weeks) =>
      taperFactors.isEmpty ? weeks : math.max(0, weeks - taperFactors.length);

  /// The taper factor of week [index] of a [weeks]-week plan.
  double taperFactor(int index, int weeks) =>
      taperFactors[taperFactors.length - (weeks - index)];

  double hoursCeilingFor(String phase) =>
      hoursCeilings[phase] ?? hoursCeilings[buildPhase] ?? double.infinity;

  /// The most load a week can carry without the projected CTL rising more
  /// than [maxCtlRamp], starting the week at [ctlStart].
  double ctlCeiling(double ctlStart) =>
      7 * (ctlStart + maxCtlRamp / (1 - ctlWeekDecay));

  static double nextCtl(double ctlStart, double weekLoad) =>
      ctlStart * ctlWeekDecay + (weekLoad / 7) * (1 - ctlWeekDecay);
}

const buildPhase = 'build';
const recoveryPhase = 'recovery';

/// The weeks before the event week that step the load down.
const taperPhase = 'taper';

/// The week holding the event: the taper's last week.
const racePhase = 'race';

bool isTaperPhase(String phase) => phase == taperPhase || phase == racePhase;

/// Rounding slack so a week sitting exactly on a limit isn't flagged.
const _slack = 0.5;

/// The proposed load curve: one week after another, each [CurveLimits.rampCap]
/// above the last, held below the CTL and hours ceilings. [limits] says
/// which ceiling, if any, held a week below the ramp.
class LoadProposal {
  const LoadProposal(this.loads, this.limits);

  final List<double> loads;
  final List<WeekLimit> limits;
}

LoadProposal proposeCurve(CurveLimits limits, int weeks) {
  final loads = <double>[];
  final held = <WeekLimit>[];
  var previous = limits.baseline;
  var ctl = limits.ctl;
  final taperStart = limits.taperStart(weeks);
  for (var i = 0; i < weeks; i++) {
    if (i >= taperStart) {
      // A taper week is the last pre-taper week times its factor — a
      // deliberate drop, so neither the ramp nor the CTL limit applies.
      final anchor = taperStart == 0 ? limits.baseline : loads[taperStart - 1];
      var load = anchor * limits.taperFactor(i, weeks);
      var limit = WeekLimit.none;
      final hours = limits.hoursCeilingFor(taperPhase);
      if (hours < load) {
        load = hours;
        limit = WeekLimit.hours;
      }
      loads.add(load);
      held.add(limit);
      if (ctl != null) ctl = CurveLimits.nextCtl(ctl, load);
      continue;
    }
    final hold = limits.holdEvery > 0 && (i + 1) % limits.holdEvery == 0;
    var load = hold ? previous : previous * (1 + limits.rampCap);
    var limit = WeekLimit.none;
    if (ctl != null) {
      final ceiling = limits.ctlCeiling(ctl);
      if (ceiling < load) {
        load = ceiling;
        limit = WeekLimit.ctlRamp;
      }
    }
    final hours = limits.hoursCeilingFor(buildPhase);
    if (hours < load) {
      load = hours;
      limit = WeekLimit.hours;
    }
    loads.add(load);
    held.add(limit);
    if (ctl != null) ctl = CurveLimits.nextCtl(ctl, load);
    previous = load;
  }
  return LoadProposal(loads, held);
}

/// The phase of each week of [targets]: taper and race week by position
/// when the plan ends at the event; otherwise recovery when a week drops
/// below [CurveLimits.recoveryThreshold] of the week before it, build
/// otherwise.
List<String> phasesFor(CurveLimits limits, List<double> targets) {
  final phases = <String>[];
  final taperStart = limits.taperStart(targets.length);
  var previous = limits.baseline;
  for (var i = 0; i < targets.length; i++) {
    final target = targets[i];
    if (i >= taperStart) {
      phases.add(i == targets.length - 1 ? racePhase : taperPhase);
    } else {
      phases.add(
        target < previous * limits.recoveryThreshold
            ? recoveryPhase
            : buildPhase,
      );
    }
    previous = target;
  }
  return phases;
}

/// The limits each week of [targets] goes beyond. The ramp is measured
/// against the last non-recovery week, and a week at or below its
/// [proposal] is never a ramp jump — the proposal already respects the cap,
/// so returning to it after a dip is fine.
List<Set<WeekLimit>> flagWeeks(
  CurveLimits limits,
  List<double> targets, {
  List<double>? proposal,
}) {
  final phases = phasesFor(limits, targets);
  final result = <Set<WeekLimit>>[];
  var reference = limits.baseline;
  var ctl = limits.ctl;
  for (var i = 0; i < targets.length; i++) {
    final target = targets[i];
    final flags = <WeekLimit>{};
    if (isTaperPhase(phases[i])) {
      // Dropping load into the event is the point: only the hours budget
      // still applies.
      if (ctl != null) ctl = CurveLimits.nextCtl(ctl, target);
      if (target > limits.hoursCeilingFor(phases[i]) + _slack) {
        flags.add(WeekLimit.hours);
      }
      result.add(flags);
      continue;
    }
    final aboveProposal =
        proposal == null ||
        i >= proposal.length ||
        target > proposal[i] + _slack;
    if (aboveProposal && target > reference * (1 + limits.rampCap) + _slack) {
      flags.add(WeekLimit.weeklyIncrease);
    }
    if (ctl != null) {
      if (target > limits.ctlCeiling(ctl) + _slack) {
        flags.add(WeekLimit.ctlRamp);
      }
      ctl = CurveLimits.nextCtl(ctl, target);
    }
    if (target > limits.hoursCeilingFor(phases[i]) + _slack) {
      flags.add(WeekLimit.hours);
    }
    result.add(flags);
    if (phases[i] != recoveryPhase) reference = target;
  }
  return result;
}

/// Snaps a load-graph factor to its 5% grid inside 80..120%.
double snapFactor(double factor) {
  final steps = (factor / Goal.factorStep).round();
  final snapped = steps * Goal.factorStep;
  return double.parse(
    snapped.clamp(Goal.minFactor, Goal.maxFactor).toStringAsFixed(2),
  );
}
