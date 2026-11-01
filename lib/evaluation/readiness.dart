import 'dart:math' as math;

import '../data/models/local_wellness.dart';
import '../util/dates.dart';

/// The thresholds readiness is rated by (`readiness` in the `okf-rules`
/// block). Each pair is `[caution, back off]`.
class ReadinessRules {
  const ReadinessRules({
    this.hrvSd = const [1, 2],
    this.restingHrBpm = const [5, 10],
    this.sleepHoursCaution = 6,
    this.form = const [-20, -30],
    this.baselineDays = 60,
    this.minBaselineDays = 14,
  });

  /// HRV this many standard deviations below the baseline mean.
  final List<double> hrvSd;

  /// Resting HR this many bpm above the baseline mean.
  final List<double> restingHrBpm;

  /// Less sleep than this is a caution; sleep alone never says back off.
  final double sleepHoursCaution;

  /// Form (CTL − ATL) below these values.
  final List<double> form;

  /// The window before today a baseline is taken from, and how many days of
  /// it need a value before the baseline counts.
  final int baselineDays;
  final int minBaselineDays;

  factory ReadinessRules.fromJson(Map<String, dynamic> json) {
    const d = ReadinessRules();
    List<double> pair(String key, List<double> fallback) {
      final raw = json[key];
      if (raw == null) return fallback;
      if (raw is! List || raw.length != 2 || raw.any((v) => v is! num)) {
        throw FormatException('readiness.$key must be two numbers.');
      }
      return [for (final v in raw) (v as num).toDouble()];
    }

    num? number(String key) {
      final raw = json[key];
      if (raw == null || raw is num) return raw as num?;
      throw FormatException('readiness.$key must be a number.');
    }

    final rules = ReadinessRules(
      hrvSd: pair('hrvSd', d.hrvSd),
      restingHrBpm: pair('restingHrBpm', d.restingHrBpm),
      sleepHoursCaution:
          number('sleepHoursCaution')?.toDouble() ?? d.sleepHoursCaution,
      form: pair('form', d.form),
      baselineDays: number('baselineDays')?.toInt() ?? d.baselineDays,
      minBaselineDays: number('minBaselineDays')?.toInt() ?? d.minBaselineDays,
    );
    if (rules.minBaselineDays < 2 ||
        rules.minBaselineDays > rules.baselineDays) {
      throw const FormatException(
        'readiness.minBaselineDays must be 2..baselineDays.',
      );
    }
    return rules;
  }
}

/// Intervals.icu's subjective scores run 1 (good) to 4 (bad).
const subjectiveWorst = 4;

enum ReadinessLevel { ready, caution, backOff }

/// How one signal is rated. [noBaseline] and [missing] never affect the
/// status.
enum SignalRating { ok, caution, backOff, noBaseline, missing }

enum ReadinessSignalKind { hrv, restingHr, sleep, form, subjective }

/// Whether today's wearable data (HRV, resting HR, sleep) is in.
enum ReadinessDataState {
  complete,

  /// Today's record has none of them yet; [Readiness.lastRecordedDate] says
  /// when they were last seen.
  waitingForToday,

  /// None of them in the whole window — no wearable feeding Intervals.icu.
  noData,
}

class ReadinessSignal {
  const ReadinessSignal({
    required this.kind,
    required this.rating,
    this.value,
    this.mean,
    this.sd,
    this.okBound,
    this.fatigue,
    this.soreness,
  });

  final ReadinessSignalKind kind;
  final SignalRating rating;

  /// Today's value: ms (HRV), bpm (resting HR), hours (sleep), form, or the
  /// worse of fatigue/soreness.
  final double? value;

  /// The athlete's baseline, where the signal has one.
  final double? mean;
  final double? sd;

  /// The edge of the ok band: the lowest ok HRV, highest ok resting HR,
  /// least ok sleep, lowest ok form.
  final double? okBound;

  /// The two subjective scores behind [ReadinessSignalKind.subjective].
  final int? fatigue;
  final int? soreness;

  bool get counts =>
      rating == SignalRating.caution || rating == SignalRating.backOff;
}

class Readiness {
  const Readiness({
    required this.level,
    required this.signals,
    required this.dataState,
    this.lastRecordedDate,
    this.deviceReadiness,
  });

  final ReadinessLevel level;

  /// Every signal, in [ReadinessSignalKind] order.
  final List<ReadinessSignal> signals;
  final ReadinessDataState dataState;

  /// The latest day with HRV, resting HR or sleep (ISO date).
  final String? lastRecordedDate;

  /// The readiness figure the athlete's device wrote, shown but never used.
  final double? deviceReadiness;

  /// The signals behind [level], back-off ones first.
  List<ReadinessSignal> get reasons => [
    ...signals.where((s) => s.rating == SignalRating.backOff),
    ...signals.where((s) => s.rating == SignalRating.caution),
  ];

  ReadinessSignal signal(ReadinessSignalKind kind) =>
      signals.firstWhere((s) => s.kind == kind);
}

/// Rates [today] from [records] (any order; only the [today] row and the
/// [ReadinessRules.baselineDays] before it are read).
Readiness evaluateReadiness(
  List<LocalWellness> records,
  DateTime today, {
  ReadinessRules rules = const ReadinessRules(),
}) {
  final todayIso = isoDate(today);
  final firstBaselineDay = isoDate(
    DateTime(today.year, today.month, today.day - rules.baselineDays),
  );
  final byDate = {for (final r in records) r.date: r};
  final todayRecord = byDate[todayIso];
  final baseline = records
      .where(
        (r) =>
            r.date.compareTo(firstBaselineDay) >= 0 &&
            r.date.compareTo(todayIso) < 0,
      )
      .toList();

  double? hrvOf(LocalWellness r) => _positive(r.raw['hrv']);
  double? rhrOf(LocalWellness r) => _positive(r.raw['restingHR']);
  double? sleepOf(LocalWellness r) {
    final secs = _positive(r.raw['sleepSecs']);
    return secs == null ? null : secs / 3600;
  }

  bool hasWearable(LocalWellness r) =>
      hrvOf(r) != null || rhrOf(r) != null || sleepOf(r) != null;

  final window = [...baseline, ?todayRecord];
  final recorded = window.where(hasWearable).map((r) => r.date).toList()
    ..sort();
  final dataState = recorded.isEmpty
      ? ReadinessDataState.noData
      : todayRecord != null && hasWearable(todayRecord)
      ? ReadinessDataState.complete
      : ReadinessDataState.waitingForToday;

  // HRV: low is bad.
  final hrvValues = baseline.map(hrvOf).nonNulls.toList();
  final hrvToday = todayRecord == null ? null : hrvOf(todayRecord);
  final ReadinessSignal hrv;
  if (hrvValues.length < rules.minBaselineDays) {
    hrv = ReadinessSignal(
      kind: ReadinessSignalKind.hrv,
      rating: hrvToday == null ? SignalRating.missing : SignalRating.noBaseline,
      value: hrvToday,
    );
  } else {
    final (mean, sd) = _meanSd(hrvValues);
    final caution = mean - rules.hrvSd[0] * sd;
    final backOff = mean - rules.hrvSd[1] * sd;
    hrv = ReadinessSignal(
      kind: ReadinessSignalKind.hrv,
      rating: hrvToday == null
          ? SignalRating.missing
          : hrvToday < backOff
          ? SignalRating.backOff
          : hrvToday < caution
          ? SignalRating.caution
          : SignalRating.ok,
      value: hrvToday,
      mean: mean,
      sd: sd,
      okBound: caution,
    );
  }

  // Resting HR: high is bad.
  final rhrValues = baseline.map(rhrOf).nonNulls.toList();
  final rhrToday = todayRecord == null ? null : rhrOf(todayRecord);
  final ReadinessSignal restingHr;
  if (rhrValues.length < rules.minBaselineDays) {
    restingHr = ReadinessSignal(
      kind: ReadinessSignalKind.restingHr,
      rating: rhrToday == null ? SignalRating.missing : SignalRating.noBaseline,
      value: rhrToday,
    );
  } else {
    final (mean, sd) = _meanSd(rhrValues);
    restingHr = ReadinessSignal(
      kind: ReadinessSignalKind.restingHr,
      rating: rhrToday == null
          ? SignalRating.missing
          : rhrToday >= mean + rules.restingHrBpm[1]
          ? SignalRating.backOff
          : rhrToday >= mean + rules.restingHrBpm[0]
          ? SignalRating.caution
          : SignalRating.ok,
      value: rhrToday,
      mean: mean,
      sd: sd,
      okBound: mean + rules.restingHrBpm[0],
    );
  }

  // Sleep: absolute, caution only.
  final sleepToday = todayRecord == null ? null : sleepOf(todayRecord);
  final sleep = ReadinessSignal(
    kind: ReadinessSignalKind.sleep,
    rating: sleepToday == null
        ? SignalRating.missing
        : sleepToday < rules.sleepHoursCaution
        ? SignalRating.caution
        : SignalRating.ok,
    value: sleepToday,
    okBound: rules.sleepHoursCaution,
  );

  // Form: from today's load, else the latest day that has it — CTL/ATL
  // come from Intervals.icu whether or not a wearable is connected.
  final loadRecord = [
    ?todayRecord,
    ...(baseline.toList()..sort((a, b) => b.date.compareTo(a.date))),
  ].where((r) => r.ctl != null && r.atl != null).firstOrNull;
  final formValue = loadRecord == null
      ? null
      : loadRecord.ctl! - loadRecord.atl!;
  final form = ReadinessSignal(
    kind: ReadinessSignalKind.form,
    rating: formValue == null
        ? SignalRating.missing
        : formValue < rules.form[1]
        ? SignalRating.backOff
        : formValue < rules.form[0]
        ? SignalRating.caution
        : SignalRating.ok,
    value: formValue,
    okBound: rules.form[0],
  );

  // Fatigue/soreness as logged today: the worst level is a caution.
  final fatigue = _int(todayRecord?.raw['fatigue']);
  final soreness = _int(todayRecord?.raw['soreness']);
  final worstScore = [
    ?fatigue,
    ?soreness,
  ].fold<int?>(null, (worst, v) => worst == null ? v : math.max(worst, v));
  final subjective = ReadinessSignal(
    kind: ReadinessSignalKind.subjective,
    rating: worstScore == null
        ? SignalRating.missing
        : worstScore >= subjectiveWorst
        ? SignalRating.caution
        : SignalRating.ok,
    value: worstScore?.toDouble(),
    fatigue: fatigue,
    soreness: soreness,
  );

  final signals = [hrv, restingHr, sleep, form, subjective];
  final backOffs = signals.where((s) => s.rating == SignalRating.backOff);
  final cautions = signals.where((s) => s.rating == SignalRating.caution);
  final level = backOffs.isNotEmpty || cautions.length >= 2
      ? ReadinessLevel.backOff
      : cautions.length == 1
      ? ReadinessLevel.caution
      : ReadinessLevel.ready;

  return Readiness(
    level: level,
    signals: signals,
    dataState: dataState,
    lastRecordedDate: recorded.isEmpty ? null : recorded.last,
    deviceReadiness: _positive(todayRecord?.raw['readiness']),
  );
}

(double, double) _meanSd(List<double> values) {
  final mean = values.reduce((a, b) => a + b) / values.length;
  final variance =
      values.fold<double>(0, (sum, v) => sum + (v - mean) * (v - mean)) /
      (values.length - 1);
  return (mean, math.sqrt(variance));
}

/// A wearable writes 0 for "not measured" often enough that it can't be a
/// real reading.
double? _positive(Object? raw) {
  final v = raw is num ? raw.toDouble() : null;
  return v == null || v <= 0 ? null : v;
}

int? _int(Object? raw) => raw is num ? raw.toInt() : null;
