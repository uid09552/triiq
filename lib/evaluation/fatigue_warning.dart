import 'dart:math' as math;

import '../data/models/local_wellness.dart';
import '../util/dates.dart';

/// Thresholds for the multi-day fatigue trend. Readiness rates one day
/// against the athlete's baseline; this looks for the *same* signals
/// staying off for several days, which is what precedes illness, injury or
/// a flat spell.
class FatigueRules {
  const FatigueRules({
    this.window = 5,
    this.baselineDays = 60,
    this.minBaselineDays = 14,
    this.minDataDays = 3,
    this.hrvSd = 1.0,
    this.restingHrBpm = 4.0,
    this.sleepHours = 6.5,
    this.form = -25.0,
    this.rampPerWeek = 8.0,
    this.subjective = 3,
    this.badDays = 3,
    this.subjectiveDays = 2,
  });

  /// Days looked at, ending today.
  final int window;
  final int baselineDays;
  final int minBaselineDays;

  /// Days with a value a signal needs before it can fire.
  final int minDataDays;

  /// HRV this many SD below the baseline mean is a bad day.
  final double hrvSd;

  /// Resting HR this many bpm over the baseline mean is a bad day.
  final double restingHrBpm;
  final double sleepHours;
  final double form;
  final double rampPerWeek;

  /// Fatigue or soreness at or above this (1 good … 4 bad) is a bad day.
  final int subjective;

  /// Bad days (of [window]) for a signal to fire; subjective needs fewer.
  final int badDays;
  final int subjectiveDays;
}

enum FatigueSignalKind {
  hrvLow,
  restingHrHigh,
  sleepShort,
  formLow,
  rampHigh,
  subjective,
}

class FatigueSignal {
  const FatigueSignal({
    required this.kind,
    required this.badDays,
    required this.dataDays,
    required this.fires,
  });

  final FatigueSignalKind kind;
  final int badDays;
  final int dataDays;
  final bool fires;

  bool get physiological =>
      kind == FatigueSignalKind.hrvLow ||
      kind == FatigueSignalKind.restingHrHigh;
  bool get load =>
      kind == FatigueSignalKind.formLow || kind == FatigueSignalKind.rampHigh;
}

enum FatigueLevel { none, watch, warning }

class FatigueWarning {
  const FatigueWarning({
    required this.level,
    required this.signals,
    required this.window,
  });

  final FatigueLevel level;

  /// Every signal that could be evaluated, firing or not.
  final List<FatigueSignal> signals;
  final int window;

  List<FatigueSignal> get firing => [
    for (final s in signals)
      if (s.fires) s,
  ];

  Map<String, dynamic> toJson() => {
    'level': level.name,
    'window_days': window,
    'signals': [
      for (final s in firing)
        {'kind': s.kind.name, 'bad_days': s.badDays, 'of_days': s.dataDays},
    ],
  };
}

double? _positive(Object? raw) => raw is num && raw > 0 ? raw.toDouble() : null;

(double, double) _meanSd(List<double> v) {
  final mean = v.reduce((a, b) => a + b) / v.length;
  final variance =
      v.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) / v.length;
  return (mean, math.sqrt(variance));
}

/// Looks at the last [FatigueRules.window] days to [today] in [records]
/// (any order) against the baseline before them.
///
/// * a signal *fires* when it is off on enough of the days that have a
///   value (HRV low, resting HR high, short sleep, deep negative form,
///   fast CTL ramp, high fatigue/soreness scores);
/// * **warning** — three or more signals fire, or HRV/resting HR fire
///   together with a load or subjective signal;
/// * **watch** — two signals fire, or HRV/resting HR alone on four days.
FatigueWarning evaluateFatigue(
  List<LocalWellness> records,
  DateTime today, {
  FatigueRules rules = const FatigueRules(),
}) {
  final day = dateOnly(today);
  final windowStart = day.subtract(Duration(days: rules.window - 1));
  final baselineStart = day.subtract(Duration(days: rules.baselineDays));
  final startIso = isoDate(windowStart);
  final baseIso = isoDate(baselineStart);
  final todayIso = isoDate(day);

  final window = [
    for (final r in records)
      if (r.date.compareTo(startIso) >= 0 && r.date.compareTo(todayIso) <= 0) r,
  ];
  final baseline = [
    for (final r in records)
      if (r.date.compareTo(baseIso) >= 0 && r.date.compareTo(startIso) < 0) r,
  ];

  final signals = <FatigueSignal>[];

  void low(
    FatigueSignalKind kind,
    double? Function(LocalWellness) read, {
    required bool Function(double value, double mean, double sd) bad,
  }) {
    final base = baseline.map(read).nonNulls.toList();
    if (base.length < rules.minBaselineDays) return;
    final (mean, sd) = _meanSd(base);
    final values = window.map(read).nonNulls.toList();
    if (values.length < rules.minDataDays) return;
    final badCount = values.where((v) => bad(v, mean, sd)).length;
    signals.add(
      FatigueSignal(
        kind: kind,
        badDays: badCount,
        dataDays: values.length,
        fires: badCount >= rules.badDays,
      ),
    );
  }

  low(
    FatigueSignalKind.hrvLow,
    (r) => _positive(r.raw['hrv']),
    bad: (v, mean, sd) => v < mean - rules.hrvSd * sd,
  );
  low(
    FatigueSignalKind.restingHrHigh,
    (r) => _positive(r.raw['restingHR']),
    bad: (v, mean, sd) => v >= mean + rules.restingHrBpm,
  );

  final sleep = window
      .map((r) => _positive(r.raw['sleepSecs']))
      .nonNulls
      .map((s) => s / 3600)
      .toList();
  if (sleep.length >= rules.minDataDays) {
    final bad = sleep.where((h) => h < rules.sleepHours).length;
    signals.add(
      FatigueSignal(
        kind: FatigueSignalKind.sleepShort,
        badDays: bad,
        dataDays: sleep.length,
        fires: bad >= rules.badDays,
      ),
    );
  }

  final forms = [
    for (final r in window)
      if (r.ctl != null && r.atl != null) r.ctl! - r.atl!,
  ];
  if (forms.length >= rules.minDataDays) {
    final bad = forms.where((f) => f <= rules.form).length;
    signals.add(
      FatigueSignal(
        kind: FatigueSignalKind.formLow,
        badDays: bad,
        dataDays: forms.length,
        fires: bad >= rules.badDays,
      ),
    );
  }

  final ramps = [
    for (final r in window)
      if (r.rampRate != null) r.rampRate!,
  ];
  if (ramps.length >= rules.minDataDays) {
    final bad = ramps.where((x) => x >= rules.rampPerWeek).length;
    signals.add(
      FatigueSignal(
        kind: FatigueSignalKind.rampHigh,
        badDays: bad,
        dataDays: ramps.length,
        fires: bad >= rules.subjectiveDays,
      ),
    );
  }

  final scores = <int>[];
  for (final r in window) {
    final f = r.raw['fatigue'];
    final s = r.raw['soreness'];
    final worst = [
      if (f is num && f > 0) f.toInt(),
      if (s is num && s > 0) s.toInt(),
    ];
    if (worst.isNotEmpty) scores.add(worst.reduce(math.max));
  }
  if (scores.length >= rules.subjectiveDays) {
    final bad = scores.where((v) => v >= rules.subjective).length;
    signals.add(
      FatigueSignal(
        kind: FatigueSignalKind.subjective,
        badDays: bad,
        dataDays: scores.length,
        fires: bad >= rules.subjectiveDays,
      ),
    );
  }

  final firing = signals.where((s) => s.fires).toList();
  final physio = firing.where((s) => s.physiological).toList();
  final other = firing.where((s) => !s.physiological).toList();
  final loadOrFeel = other.any(
    (s) => s.load || s.kind == FatigueSignalKind.subjective,
  );

  FatigueLevel level;
  if (firing.length >= 3 || (physio.isNotEmpty && loadOrFeel)) {
    level = FatigueLevel.warning;
  } else if (firing.length >= 2 || physio.any((s) => s.badDays >= 4)) {
    level = FatigueLevel.watch;
  } else {
    level = FatigueLevel.none;
  }
  return FatigueWarning(level: level, signals: signals, window: rules.window);
}
