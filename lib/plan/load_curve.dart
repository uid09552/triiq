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
  for (var i = 0; i < weeks; i++) {
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

/// The phase of each week of [targets]: recovery when a week drops below
/// [CurveLimits.recoveryThreshold] of the week before it, build otherwise.
List<String> phasesFor(CurveLimits limits, List<double> targets) {
  final phases = <String>[];
  var previous = limits.baseline;
  for (final target in targets) {
    phases.add(
      target < previous * limits.recoveryThreshold ? recoveryPhase : buildPhase,
    );
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
    final aboveProposal =
        proposal == null || i >= proposal.length || target > proposal[i] + _slack;
    if (aboveProposal && target > reference * (1 + limits.rampCap) + _slack) {
      flags.add(WeekLimit.weeklyIncrease);
    }
    if (ctl != null) {
      if (target > limits.ctlCeiling(ctl) + _slack) flags.add(WeekLimit.ctlRamp);
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
