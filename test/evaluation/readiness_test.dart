import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_wellness.dart';
import 'package:triiq/evaluation/readiness.dart';
import 'package:triiq/util/dates.dart';

final _today = DateTime(2026, 11, 1);

LocalWellness _day(
  int daysAgo, {
  num? hrv,
  num? rhr,
  num? sleepSecs,
  double? ctl = 60,
  double? atl = 60,
  int? fatigue,
  int? soreness,
  num? readiness,
}) {
  final date = isoDate(
    DateTime(_today.year, _today.month, _today.day - daysAgo),
  );
  return LocalWellness(
    date: date,
    ctl: ctl,
    atl: atl,
    ctlLoad: null,
    atlLoad: null,
    rampRate: null,
    raw: {
      'id': date,
      'hrv': ?hrv,
      'restingHR': ?rhr,
      'sleepSecs': ?sleepSecs,
      'fatigue': ?fatigue,
      'soreness': ?soreness,
      'readiness': ?readiness,
    },
    syncedAt: DateTime(2026),
  );
}

/// [count] baseline days alternating mean ± sd, so the sample mean is
/// exactly [mean] and the SD close to [sd].
List<LocalWellness> _baseline({
  int count = 40,
  double hrvMean = 62,
  double hrvSd = 6,
  double rhr = 48,
}) => [
  for (var i = 1; i <= count; i++)
    _day(
      i,
      hrv: hrvMean + (i.isEven ? hrvSd : -hrvSd),
      rhr: rhr,
      sleepSecs: 8 * 3600,
    ),
];

void main() {
  group('baselines', () {
    test('enough history: HRV baseline from the recorded days', () {
      final r = evaluateReadiness([
        ..._baseline(count: 40),
        _day(0, hrv: 62, rhr: 48, sleepSecs: 8 * 3600),
      ], _today);

      final hrv = r.signal(ReadinessSignalKind.hrv);
      expect(hrv.mean, closeTo(62, 1e-9));
      expect(hrv.sd, closeTo(6, 0.1));
      expect(hrv.rating, SignalRating.ok);
    });

    test('too little history: no baseline, no effect on the status', () {
      final r = evaluateReadiness([
        for (var i = 1; i <= 10; i++) _day(i, rhr: 48),
        _day(0, rhr: 70, sleepSecs: 8 * 3600),
      ], _today);

      expect(
        r.signal(ReadinessSignalKind.restingHr).rating,
        SignalRating.noBaseline,
      );
      expect(r.level, ReadinessLevel.ready);
    });

    test('days older than the window and today are not in the baseline', () {
      final r = evaluateReadiness([
        for (var i = 61; i <= 100; i++) _day(i, hrv: 100),
        _day(0, hrv: 30),
      ], _today);

      expect(r.signal(ReadinessSignalKind.hrv).rating, SignalRating.noBaseline);
    });
  });

  group('signal ratings', () {
    test('low HRV: 52 against 62 ± 6 is caution', () {
      final r = evaluateReadiness([
        ..._baseline(),
        _day(0, hrv: 52, rhr: 48, sleepSecs: 8 * 3600),
      ], _today);

      expect(r.signal(ReadinessSignalKind.hrv).rating, SignalRating.caution);
      expect(r.level, ReadinessLevel.caution);
    });

    test('HRV two SD down is back off', () {
      final r = evaluateReadiness([
        ..._baseline(),
        _day(0, hrv: 48, rhr: 48, sleepSecs: 8 * 3600),
      ], _today);

      expect(r.signal(ReadinessSignalKind.hrv).rating, SignalRating.backOff);
    });

    test('elevated resting HR: 59 against 48 is back off', () {
      final r = evaluateReadiness([
        ..._baseline(),
        _day(0, hrv: 62, rhr: 59, sleepSecs: 8 * 3600),
      ], _today);

      expect(
        r.signal(ReadinessSignalKind.restingHr).rating,
        SignalRating.backOff,
      );
      expect(r.level, ReadinessLevel.backOff);
    });

    test('resting HR 5 bpm up is caution', () {
      final r = evaluateReadiness([
        ..._baseline(),
        _day(0, hrv: 62, rhr: 53, sleepSecs: 8 * 3600),
      ], _today);

      expect(
        r.signal(ReadinessSignalKind.restingHr).rating,
        SignalRating.caution,
      );
    });

    test('short sleep: 5 h 20 min is caution, never back off', () {
      final r = evaluateReadiness([
        ..._baseline(),
        _day(0, hrv: 62, rhr: 48, sleepSecs: 5 * 3600 + 20 * 60),
      ], _today);

      expect(r.signal(ReadinessSignalKind.sleep).rating, SignalRating.caution);
      expect(r.level, ReadinessLevel.caution);
    });

    test('form below -20 is caution, below -30 back off', () {
      Readiness withForm(double atl) => evaluateReadiness([
        ..._baseline(),
        _day(0, hrv: 62, rhr: 48, sleepSecs: 8 * 3600, ctl: 60, atl: atl),
      ], _today);

      expect(
        withForm(85).signal(ReadinessSignalKind.form).rating,
        SignalRating.caution,
      );
      expect(
        withForm(95).signal(ReadinessSignalKind.form).rating,
        SignalRating.backOff,
      );
      expect(
        withForm(70).signal(ReadinessSignalKind.form).rating,
        SignalRating.ok,
      );
    });

    test('fatigue or soreness at the worst level is caution', () {
      final r = evaluateReadiness([
        ..._baseline(),
        _day(0, hrv: 62, rhr: 48, sleepSecs: 8 * 3600, fatigue: 2, soreness: 4),
      ], _today);

      final s = r.signal(ReadinessSignalKind.subjective);
      expect(s.rating, SignalRating.caution);
      expect(s.fatigue, 2);
      expect(s.soreness, 4);
    });

    test('rules from the knowledge change the thresholds', () {
      final r = evaluateReadiness(
        [..._baseline(), _day(0, hrv: 62, rhr: 48, sleepSecs: 6.5 * 3600)],
        _today,
        rules: const ReadinessRules(sleepHoursCaution: 7),
      );

      expect(r.signal(ReadinessSignalKind.sleep).rating, SignalRating.caution);
    });
  });

  group('status', () {
    test('two cautions: back off, with both as reasons', () {
      final r = evaluateReadiness([
        ..._baseline(),
        _day(0, hrv: 52, rhr: 48, sleepSecs: 5 * 3600),
      ], _today);

      expect(r.level, ReadinessLevel.backOff);
      expect(r.reasons.map((s) => s.kind), [
        ReadinessSignalKind.hrv,
        ReadinessSignalKind.sleep,
      ]);
    });

    test('all ok: ready, no reasons', () {
      final r = evaluateReadiness([
        ..._baseline(),
        _day(0, hrv: 63, rhr: 47, sleepSecs: 8 * 3600),
      ], _today);

      expect(r.level, ReadinessLevel.ready);
      expect(r.reasons, isEmpty);
      expect(r.dataState, ReadinessDataState.complete);
    });

    test('back-off reasons come before caution reasons', () {
      final r = evaluateReadiness([
        ..._baseline(),
        _day(0, hrv: 52, rhr: 60, sleepSecs: 8 * 3600),
      ], _today);

      expect(r.reasons.map((s) => s.kind), [
        ReadinessSignalKind.restingHr,
        ReadinessSignalKind.hrv,
      ]);
    });
  });

  group('missing data', () {
    test('no wellness signals in 60 days: no data, form still rated', () {
      final r = evaluateReadiness([
        for (var i = 0; i <= 30; i++) _day(i, ctl: 50, atl: 80),
      ], _today);

      expect(r.dataState, ReadinessDataState.noData);
      expect(r.signal(ReadinessSignalKind.form).rating, SignalRating.caution);
      expect(r.level, ReadinessLevel.caution);
    });

    test('not synced yet: waiting, with yesterday as last recorded', () {
      final r = evaluateReadiness([
        ..._baseline(),
        _day(0, ctl: 60, atl: 65),
      ], _today);

      expect(r.dataState, ReadinessDataState.waitingForToday);
      expect(r.lastRecordedDate, '2026-10-31');
      expect(r.signal(ReadinessSignalKind.hrv).rating, SignalRating.missing);
      expect(r.signal(ReadinessSignalKind.form).rating, SignalRating.ok);
      expect(r.level, ReadinessLevel.ready);
    });

    test('no record for today at all: form from the latest day', () {
      final r = evaluateReadiness([
        ..._baseline(),
        _day(1, ctl: 40, atl: 75),
      ], _today);

      expect(r.dataState, ReadinessDataState.waitingForToday);
      expect(r.signal(ReadinessSignalKind.form).value, -35);
    });

    test('zero readings count as missing', () {
      final r = evaluateReadiness([
        ..._baseline(),
        _day(0, hrv: 0, rhr: 0, sleepSecs: 0),
      ], _today);

      expect(r.dataState, ReadinessDataState.waitingForToday);
    });
  });

  group('device readiness', () {
    test('shown but not used in the status', () {
      final r = evaluateReadiness([
        ..._baseline(),
        _day(0, hrv: 62, rhr: 48, sleepSecs: 8 * 3600, readiness: 12),
      ], _today);

      expect(r.deviceReadiness, 12);
      expect(r.level, ReadinessLevel.ready);
    });
  });

  group('readinessScore', () {
    test('null without any rated signal', () {
      final r = evaluateReadiness(const [], DateTime(2026, 5, 20));
      expect(readinessScore(r), isNull);
    });

    test('averages ok / caution / back-off signals', () {
      const r = Readiness(
        level: ReadinessLevel.caution,
        dataState: ReadinessDataState.complete,
        signals: [
          ReadinessSignal(
            kind: ReadinessSignalKind.hrv,
            rating: SignalRating.ok,
          ),
          ReadinessSignal(
            kind: ReadinessSignalKind.restingHr,
            rating: SignalRating.caution,
          ),
          ReadinessSignal(
            kind: ReadinessSignalKind.sleep,
            rating: SignalRating.backOff,
          ),
          ReadinessSignal(
            kind: ReadinessSignalKind.form,
            rating: SignalRating.noBaseline,
          ),
        ],
      );
      expect(readinessScore(r), 65); // (100 + 65 + 30) / 3
    });
  });
}
