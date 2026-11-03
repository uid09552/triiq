import 'dart:math' as math;

/// A race: swim / ride / run distances in metres (0 = leg not in the
/// race) and the transition allowances in seconds.
class RaceSpec {
  const RaceSpec({
    required this.id,
    required this.swimM,
    required this.rideM,
    required this.runM,
    this.t1 = 0,
    this.t2 = 0,
  });

  final String id;
  final double swimM;
  final double rideM;
  final double runM;
  final int t1;
  final int t2;

  bool get isTriathlon =>
      [swimM, rideM, runM].where((d) => d > 0).length >= 2;

  static const run5k = RaceSpec(id: 'run5k', swimM: 0, rideM: 0, runM: 5000);
  static const run10k = RaceSpec(id: 'run10k', swimM: 0, rideM: 0, runM: 10000);
  static const halfMarathon =
      RaceSpec(id: 'halfMarathon', swimM: 0, rideM: 0, runM: 21097.5);
  static const marathon =
      RaceSpec(id: 'marathon', swimM: 0, rideM: 0, runM: 42195);
  static const ride100k =
      RaceSpec(id: 'ride100k', swimM: 0, rideM: 100000, runM: 0);
  static const sprint = RaceSpec(
    id: 'sprint', swimM: 750, rideM: 20000, runM: 5000, t1: 90, t2: 60,
  );
  static const olympic = RaceSpec(
    id: 'olympic', swimM: 1500, rideM: 40000, runM: 10000, t1: 120, t2: 75,
  );
  static const half70 = RaceSpec(
    id: 'half70', swimM: 1900, rideM: 90000, runM: 21097.5, t1: 180, t2: 120,
  );
  static const full140 = RaceSpec(
    id: 'full140', swimM: 3800, rideM: 180000, runM: 42195, t1: 300, t2: 180,
  );

  static const presets = [
    run5k, run10k, halfMarathon, marathon, ride100k,
    sprint, olympic, half70, full140,
  ];

  static RaceSpec? byId(String id) {
    for (final p in presets) {
      if (p.id == id) return p;
    }
    return null;
  }
}

/// Best efforts to predict from.
class RaceInputs {
  const RaceInputs({
    this.runBests = const [],
    this.swimBests = const [],
    this.powerCurve = const [],
    this.ftp,
    this.ctl,
    this.raceDayForm,
    this.weightKg = 70,
    this.bikeKg = 9,
    this.cdA = 0.32,
    this.crr = 0.005,
    this.elevationGainM = 0,
    this.hot = false,
    this.openWater = true,
  });

  /// (metres, seconds) best efforts from the pace curve.
  final List<({double metres, double seconds})> runBests;
  final List<({double metres, double seconds})> swimBests;

  /// (seconds, watts) from the power curve.
  final List<({double seconds, double watts})> powerCurve;
  final double? ftp;
  final double? ctl;

  /// Forecast form (CTL − ATL) on race day, when known.
  final double? raceDayForm;
  final double weightKg;
  final double bikeKg;
  final double cdA;
  final double crr;
  final double elevationGainM;
  final bool hot;
  final bool openWater;
}

enum PacingNote { startControlled, holdSteady, finishStrong, negativeSplit }

/// One stretch of a leg with its target.
class PacingStep {
  const PacingStep({
    required this.fromM,
    required this.toM,
    required this.note,
    this.watts,
    this.paceSecPerKm,
    this.pacePer100m,
  });

  final double fromM;
  final double toM;
  final PacingNote note;
  final int? watts;
  final double? paceSecPerKm;
  final double? pacePer100m;
}

class LegPrediction {
  const LegPrediction({
    required this.sport,
    required this.metres,
    required this.seconds,
    required this.steps,
    this.watts,
    this.intensityFactor,
  });

  /// `Swim`, `Ride` or `Run`.
  final String sport;
  final double metres;
  final double seconds;
  final List<PacingStep> steps;
  final int? watts;
  final double? intensityFactor;

  double get speed => metres / seconds;
  double get paceSecPerKm => seconds / (metres / 1000);
  double get pacePer100m => seconds / (metres / 100);
}

class FuelStep {
  const FuelStep({
    required this.minute,
    required this.sport,
    required this.carbsG,
    required this.fluidMl,
  });

  final int minute;
  final String sport;
  final int carbsG;
  final int fluidMl;
}

class FuelingPlan {
  const FuelingPlan({
    required this.carbsPerHour,
    required this.fluidPerHour,
    required this.sodiumPerHour,
    required this.totalCarbsG,
    required this.totalFluidMl,
    required this.dayBeforeCarbsG,
    required this.preRaceCarbsG,
    required this.steps,
  });

  final int carbsPerHour;
  final int fluidPerHour;
  final int sodiumPerHour;
  final int totalCarbsG;
  final int totalFluidMl;

  /// Carb target for the day before (≥ 90 min events), 8 g/kg.
  final int dayBeforeCarbsG;

  /// 1–4 h before the start, 1.5 g/kg.
  final int preRaceCarbsG;
  final List<FuelStep> steps;
}

class RacePrediction {
  const RacePrediction({
    required this.spec,
    required this.legs,
    required this.t1,
    required this.t2,
    required this.slowdown,
    required this.fueling,
    required this.missing,
  });

  final RaceSpec spec;
  final List<LegPrediction> legs;
  final int t1;
  final int t2;

  /// Multiplier already applied to leg times for fitness shortfall and
  /// race-day form (1.0 = none).
  final double slowdown;
  final FuelingPlan fueling;

  /// Legs the data couldn't predict (`Swim`, `Ride`, `Run`).
  final List<String> missing;

  double get totalSeconds =>
      legs.fold(0.0, (s, l) => s + l.seconds) + t1 + t2;
  bool get complete => missing.isEmpty && legs.isNotEmpty;
}

const _riegel = 1.06;

/// Predicts the time for [metres] from the best-fitting known effort
/// (Riegel's formula, T2 = T1·(D2/D1)^1.06). Null without any effort.
double? predictFromBests(
  List<({double metres, double seconds})> bests,
  double metres,
) {
  if (bests.isEmpty || metres <= 0) return null;
  var ref = bests.first;
  var gap = double.infinity;
  for (final b in bests) {
    if (b.metres <= 0 || b.seconds <= 0) continue;
    final g = (math.log(b.metres) - math.log(metres)).abs();
    if (g < gap) {
      gap = g;
      ref = b;
    }
  }
  if (gap == double.infinity) return null;
  return ref.seconds * math.pow(metres / ref.metres, _riegel);
}

/// Watts the power curve holds for [seconds], interpolated on log time.
double? powerAt(List<({double seconds, double watts})> curve, double seconds) {
  final pts = [
    for (final p in curve)
      if (p.seconds > 0 && p.watts > 0) p,
  ]..sort((a, b) => a.seconds.compareTo(b.seconds));
  if (pts.isEmpty) return null;
  if (seconds <= pts.first.seconds) return pts.first.watts;
  if (seconds >= pts.last.seconds) {
    // Extrapolate past the longest effort: power fades ~4 % per doubling.
    final doublings = math.log(seconds / pts.last.seconds) / math.ln2;
    return pts.last.watts * math.pow(0.96, doublings);
  }
  for (var i = 1; i < pts.length; i++) {
    if (seconds <= pts[i].seconds) {
      final a = pts[i - 1];
      final b = pts[i];
      final f = (math.log(seconds) - math.log(a.seconds)) /
          (math.log(b.seconds) - math.log(a.seconds));
      return a.watts + (b.watts - a.watts) * f;
    }
  }
  return pts.last.watts;
}

/// Share of the best effort for a duration that can be held in a race:
/// 97 % up to an hour, down to 72 % by six hours. A triathlon bike leg is
/// held back a further 7 % to leave something for the run.
double raceFraction(double seconds, {bool triathlon = false}) {
  final h = seconds / 3600;
  const pts = [(1.0, 0.97), (2.0, 0.92), (4.0, 0.85), (6.0, 0.78), (9.0, 0.72)];
  double f;
  if (h <= pts.first.$1) {
    f = pts.first.$2;
  } else if (h >= pts.last.$1) {
    f = pts.last.$2;
  } else {
    f = pts.last.$2;
    for (var i = 1; i < pts.length; i++) {
      if (h <= pts[i].$1) {
        final a = pts[i - 1];
        final b = pts[i];
        f = a.$2 + (b.$2 - a.$2) * (h - a.$1) / (b.$1 - a.$1);
        break;
      }
    }
  }
  return triathlon ? f * 0.93 : f;
}

/// Steady speed (m/s) for [watts] at the pedals on the flat, with the
/// climbing work of [gainM] over [metres] added. Solved by bisection.
double rideSpeed({
  required double watts,
  required double massKg,
  required double cdA,
  required double crr,
  double gainM = 0,
  double metres = 40000,
}) {
  const rho = 1.2;
  const g = 9.81;
  final grade = metres > 0 ? gainM / metres : 0.0;
  final pw = watts * 0.975;
  double f(double v) =>
      v * (massKg * g * (crr + grade) + 0.5 * rho * cdA * v * v) - pw;
  var lo = 0.5;
  var hi = 30.0;
  for (var i = 0; i < 60; i++) {
    final mid = (lo + hi) / 2;
    if (f(mid) > 0) {
      hi = mid;
    } else {
      lo = mid;
    }
  }
  return (lo + hi) / 2;
}

({double seconds, double watts})? _predictRide(
  RaceSpec spec,
  RaceInputs i,
  bool tri,
) {
  if (i.powerCurve.isEmpty) return null;
  final mass = i.weightKg + i.bikeKg;
  // Fixed point on duration: the power held for a time decides the speed,
  // which decides the time.
  var t = spec.rideM / 9; // start at 32 km/h
  var watts = 0.0;
  for (var n = 0; n < 40; n++) {
    final best = powerAt(i.powerCurve, t);
    if (best == null) return null;
    watts = best * raceFraction(t, triathlon: tri);
    final v = rideSpeed(
      watts: watts,
      massKg: mass,
      cdA: i.cdA,
      crr: i.crr,
      gainM: i.elevationGainM,
      metres: spec.rideM,
    );
    final next = spec.rideM / v;
    if ((next - t).abs() < 1) {
      t = next;
      break;
    }
    t = (t + next) / 2;
  }
  return (seconds: t, watts: watts);
}

/// How much slower than the ideal the athlete will go: a CTL shortfall for
/// the race length (up to 15 % at CTL 0, only past ~1.5 h) plus a small
/// penalty for arriving loaded or detrained.
double raceSlowdown({
  required double totalSeconds,
  double? ctl,
  double? raceDayForm,
}) {
  final hours = totalSeconds / 3600;
  var s = 1.0;
  if (ctl != null && hours > 1.5) {
    final needed = 15 * math.pow(hours, 0.9);
    final shortfall = (1 - ctl / needed).clamp(0.0, 1.0);
    final weight = ((hours - 1.5) / 2).clamp(0.0, 1.0);
    s += 0.15 * shortfall * weight;
  }
  if (raceDayForm != null) {
    if (raceDayForm < -10) {
      s += 0.015;
    } else if (raceDayForm > 25) {
      s += 0.01;
    }
  }
  return s;
}

double _offBikeRunFactor(double runM) =>
    runM <= 10000 ? 1.03 : (runM <= 21100 ? 1.07 : 1.12);

/// The carbohydrate, fluid and sodium plan for a race of [totalSeconds]
/// with [legs] (intake on the bike every 20 min, on the run every 30 min).
FuelingPlan fuelingPlan({
  required List<LegPrediction> legs,
  required int t1,
  required double weightKg,
  required bool hot,
  required double totalSeconds,
}) {
  final hours = totalSeconds / 3600;
  final perHour = hours < 0.75
      ? 0
      : hours < 1.25
      ? 30
      : hours < 2
      ? 50
      : hours < 3
      ? 70
      : 85;
  final fluid = hot ? 750 : 500;
  final sodium = hot ? 800 : 500;
  final steps = <FuelStep>[];
  var clock = 0.0;
  var carbs = 0.0;
  var fluidTotal = 0.0;
  var legStart = 0.0;
  for (final leg in legs) {
    final isSwim = leg.sport == 'Swim';
    final interval = leg.sport == 'Ride' ? 20 : 30;
    if (isSwim) {
      clock += leg.seconds + t1;
      continue;
    }
    final rate = leg.sport == 'Run' ? perHour * 0.8 : perHour.toDouble();
    final fluidRate = leg.sport == 'Run' ? fluid * 0.8 : fluid.toDouble();
    legStart = clock;
    final legMin = (leg.seconds / 60).floor();
    for (var m = interval; m <= legMin; m += interval) {
      final c = rate * interval / 60;
      final f = fluidRate * interval / 60;
      steps.add(
        FuelStep(
          minute: ((legStart / 60) + m).round(),
          sport: leg.sport,
          carbsG: c.round(),
          fluidMl: f.round(),
        ),
      );
      carbs += c;
      fluidTotal += f;
    }
    clock += leg.seconds;
  }
  return FuelingPlan(
    carbsPerHour: perHour,
    fluidPerHour: fluid,
    sodiumPerHour: sodium,
    totalCarbsG: carbs.round(),
    totalFluidMl: fluidTotal.round(),
    dayBeforeCarbsG: hours >= 1.5 ? (8 * weightKg).round() : 0,
    preRaceCarbsG: (1.5 * weightKg).round(),
    steps: steps,
  );
}

List<PacingStep> _runSteps(double metres, double pace) {
  final first = math.min(metres * 0.1, 2000.0);
  final last = metres > 12000 ? metres * 0.1 : metres * 0.2;
  final negative = metres <= 12000;
  return [
    PacingStep(
      fromM: 0, toM: first, note: PacingNote.startControlled,
      paceSecPerKm: pace * 1.03,
    ),
    PacingStep(
      fromM: first, toM: metres - last,
      note: negative ? PacingNote.negativeSplit : PacingNote.holdSteady,
      paceSecPerKm: pace,
    ),
    PacingStep(
      fromM: metres - last, toM: metres, note: PacingNote.finishStrong,
      paceSecPerKm: pace * 0.98,
    ),
  ];
}

List<PacingStep> _rideSteps(double metres, double watts) {
  final first = math.min(metres * 0.08, 8000.0);
  return [
    PacingStep(
      fromM: 0, toM: first, note: PacingNote.startControlled,
      watts: (watts * 0.95).round(),
    ),
    PacingStep(
      fromM: first, toM: metres, note: PacingNote.holdSteady,
      watts: watts.round(),
    ),
  ];
}

/// The full prediction for [spec] from [inputs]; legs without data are
/// listed in [RacePrediction.missing] and the total is then incomplete.
RacePrediction predictRace(RaceSpec spec, RaceInputs inputs) {
  final tri = spec.isTriathlon;
  final legs = <LegPrediction>[];
  final missing = <String>[];

  if (spec.swimM > 0) {
    final s = predictFromBests(inputs.swimBests, spec.swimM);
    if (s == null) {
      missing.add('Swim');
    } else {
      final secs = s * (inputs.openWater && tri ? 1.03 : 1.0);
      final pace = secs / (spec.swimM / 100);
      legs.add(
        LegPrediction(
          sport: 'Swim', metres: spec.swimM, seconds: secs,
          steps: [
            PacingStep(
              fromM: 0, toM: spec.swimM, note: PacingNote.holdSteady,
              pacePer100m: pace,
            ),
          ],
        ),
      );
    }
  }
  if (spec.rideM > 0) {
    final r = _predictRide(spec, inputs, tri);
    if (r == null) {
      missing.add('Ride');
    } else {
      final ifx = inputs.ftp != null && inputs.ftp! > 0
          ? r.watts / inputs.ftp!
          : null;
      legs.add(
        LegPrediction(
          sport: 'Ride', metres: spec.rideM, seconds: r.seconds,
          steps: _rideSteps(spec.rideM, r.watts),
          watts: r.watts.round(), intensityFactor: ifx,
        ),
      );
    }
  }
  if (spec.runM > 0) {
    final r = predictFromBests(inputs.runBests, spec.runM);
    if (r == null) {
      missing.add('Run');
    } else {
      final secs = r * (spec.rideM > 0 ? _offBikeRunFactor(spec.runM) : 1.0);
      final pace = secs / (spec.runM / 1000);
      legs.add(
        LegPrediction(
          sport: 'Run', metres: spec.runM, seconds: secs,
          steps: _runSteps(spec.runM, pace),
        ),
      );
    }
  }

  final raw = legs.fold(0.0, (s, l) => s + l.seconds) + spec.t1 + spec.t2;
  final slow = raceSlowdown(
    totalSeconds: raw,
    ctl: inputs.ctl,
    raceDayForm: inputs.raceDayForm,
  );
  final adjusted = <LegPrediction>[
    for (final l in legs)
      LegPrediction(
        sport: l.sport,
        metres: l.metres,
        seconds: l.seconds * slow,
        // Slower legs mean easier targets: scale watts down, pace up.
        steps: [
          for (final s in l.steps)
            PacingStep(
              fromM: s.fromM, toM: s.toM, note: s.note,
              watts: s.watts == null ? null : (s.watts! / _wattDiv(l, slow)).round(),
              paceSecPerKm: s.paceSecPerKm == null ? null : s.paceSecPerKm! * slow,
              pacePer100m: s.pacePer100m == null ? null : s.pacePer100m! * slow,
            ),
        ],
        watts: l.watts == null ? null : (l.watts! / _wattDiv(l, slow)).round(),
        intensityFactor: l.intensityFactor == null
            ? null
            : l.intensityFactor! / _wattDiv(l, slow),
      ),
  ];
  final total = adjusted.fold(0.0, (s, l) => s + l.seconds) + spec.t1 + spec.t2;
  return RacePrediction(
    spec: spec,
    legs: adjusted,
    t1: spec.t1,
    t2: spec.t2,
    slowdown: slow,
    fueling: fuelingPlan(
      legs: adjusted,
      t1: spec.t1,
      weightKg: inputs.weightKg,
      hot: inputs.hot,
      totalSeconds: total,
    ),
    missing: missing,
  );
}

/// Speed on the bike goes with the cube root of power, so a leg that is
/// [slow]× slower needs about 1/slow³ of the watts.
double _wattDiv(LegPrediction l, double slow) => slow * slow * slow;
