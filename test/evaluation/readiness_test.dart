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
  double? atlLoad,
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
    atlLoad: atlLoad,
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

/// [count] baseline days alternating mean ± sd, starting [from] days ago, so
/// the median is exactly [hrvMean] and the MADσ is 1.4826 × [hrvSd]
/// (≈ 5.9 for the default 4).
List<LocalWellness> _baseline({
  int count = 40,
  int from = 1,
  double hrvMean = 62,
  double hrvSd = 4,
  double rhr = 48,
}) => [
  for (var i = from; i < from + count; i++)
    _day(
      i,
      hrv: hrvMean + (i.isEven ? hrvSd : -hrvSd),
      rhr: rhr,
      sleepSecs: 8 * 3600,
    ),
];

/// The baseline, then the two days before today at [hrv] / [rhr]: HRV and
/// resting HR are rated by their 3-day median, so a change has to last.
List<LocalWellness> _sustained({num hrv = 62, num? rhr = 48}) => [
  ..._baseline(from: 3),
  for (final d in [2, 1]) _day(d, hrv: hrv, rhr: rhr, sleepSecs: 8 * 3600),
];

void main() {
  group('baselines', () {
    test('enough history: HRV baseline from the recorded days', () {
      final r = evaluateReadiness([
        ..._baseline(count: 40),
        _day(0, hrv: 62, rhr: 48, sleepSecs: 8 * 3600),
      ], _today);

      final hrv = r.signal(ReadinessSignalKind.hrv);
      // Median and MADσ: 62 and 4 × 1.4826.
      expect(hrv.mean, closeTo(62, 1e-9));
      expect(hrv.sd, closeTo(5.93, 0.01));
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
    test('low HRV: 52 for three days against 62 ± 5.9 is caution', () {
      final r = evaluateReadiness([
        ..._sustained(hrv: 52),
        _day(0, hrv: 52, rhr: 48, sleepSecs: 8 * 3600),
      ], _today);

      expect(r.signal(ReadinessSignalKind.hrv).rating, SignalRating.caution);
      expect(r.level, ReadinessLevel.caution);
    });

    test('HRV two MADσ down for three days is back off', () {
      final r = evaluateReadiness([
        ..._sustained(hrv: 48),
        _day(0, hrv: 48, rhr: 48, sleepSecs: 8 * 3600),
      ], _today);

      expect(r.signal(ReadinessSignalKind.hrv).rating, SignalRating.backOff);
    });

    test('elevated resting HR: 59 for three days against 48 is back off', () {
      // No HRV or sleep to say otherwise, so the back-off is not capped.
      final r = evaluateReadiness([
        ..._sustained(rhr: 59),
        _day(0, rhr: 59),
      ], _today);

      expect(
        r.signal(ReadinessSignalKind.restingHr).rating,
        SignalRating.backOff,
      );
      expect(r.level, ReadinessLevel.backOff);
    });

    test('resting HR 5 bpm up for three days is caution', () {
      final r = evaluateReadiness([
        ..._sustained(rhr: 53),
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
        ..._sustained(hrv: 52),
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
        ..._sustained(hrv: 52, rhr: 60),
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
      // ATL is 1.6 times CTL: the load signal sees it too.
      expect(r.signal(ReadinessSignalKind.load).rating, SignalRating.backOff);
      expect(r.level, ReadinessLevel.backOff);
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
    Readiness rate(num? value) => evaluateReadiness([
      ..._baseline(),
      _day(0, hrv: 62, rhr: 48, sleepSecs: 8 * 3600, readiness: value),
    ], _today);

    test('is a signal: low values are a caution or a back-off', () {
      expect(
        rate(80).signal(ReadinessSignalKind.device).rating,
        SignalRating.ok,
      );
      expect(
        rate(40).signal(ReadinessSignalKind.device).rating,
        SignalRating.caution,
      );
      expect(rate(40).level, ReadinessLevel.caution);
      expect(
        rate(12).signal(ReadinessSignalKind.device).rating,
        SignalRating.backOff,
      );
      expect(rate(12).level, ReadinessLevel.backOff);
      expect(rate(12).deviceReadiness, 12);
    });

    test('no figure, or one off the 0-100 scale, changes nothing', () {
      for (final v in [null, 0, 250]) {
        final r = rate(v);
        expect(
          r.signal(ReadinessSignalKind.device).rating,
          SignalRating.missing,
        );
        expect(r.level, ReadinessLevel.ready);
      }
    });

    test('can be switched off like the others', () {
      final r = evaluateReadiness(
        [
          ..._baseline(),
          _day(0, hrv: 62, rhr: 48, sleepSecs: 8 * 3600, readiness: 12),
        ],
        _today,
        enabled: ReadinessSignalKind.values.toSet()
          ..remove(ReadinessSignalKind.device),
      );
      expect(
        r.signal(ReadinessSignalKind.device).rating,
        SignalRating.excluded,
      );
      expect(r.level, ReadinessLevel.ready);
    });
  });

  group('load', () {
    Readiness rate({
      double ctl = 60,
      double atl = 60,
      double? atlLoad,
      bool today = true,
    }) => evaluateReadiness([
      ..._baseline(),
      if (today)
        _day(
          0,
          hrv: 62,
          rhr: 48,
          sleepSecs: 8 * 3600,
          ctl: ctl,
          atl: atl,
          atlLoad: atlLoad,
        ),
    ], _today);
    SignalRating load(Readiness r) => r.signal(ReadinessSignalKind.load).rating;

    test('a normal day and a normal ratio are fine', () {
      final r = rate(atl: 62, atlLoad: 55);
      expect(load(r), SignalRating.ok);
      expect(r.level, ReadinessLevel.ready);
      expect(readinessScore(r), 100);
    });

    test('a session that already took a lot today lowers readiness', () {
      // CTL 60, 100 TSS today: 1.67 times the usual day. The ratio is still
      // fine (ATL 66), so this is the day's load speaking.
      final after = rate(atl: 66, atlLoad: 100);
      final before = rate(atl: 62);
      expect(load(before), SignalRating.ok);
      expect(readinessScore(before), 100);
      expect(load(after), SignalRating.caution);
      expect(after.level, ReadinessLevel.caution);
      expect(readinessScore(after), lessThan(80));
      expect(after.signal(ReadinessSignalKind.load).dayLoad, 100);
    });

    test('a huge day is a back-off', () {
      final r = rate(atl: 70, atlLoad: 160); // 2.67 times CTL
      expect(load(r), SignalRating.backOff);
      expect(r.level, ReadinessLevel.backOff);
      expect(readinessScore(r), lessThanOrEqualTo(59));
    });

    test('recent load far ahead of the athlete: caution, then back off', () {
      expect(load(rate(atl: 80)), SignalRating.caution); // 1.33
      expect(load(rate(atl: 92)), SignalRating.backOff); // 1.53
      expect(
        rate(atl: 80).signal(ReadinessSignalKind.load).value,
        closeTo(1.33, 0.01),
      );
    });

    test('too little history, or no load data, says nothing', () {
      expect(load(rate(ctl: 6, atl: 12, atlLoad: 40)), SignalRating.noBaseline);
      final none = evaluateReadiness([
        ..._baseline().map(
          (d) => LocalWellness(
            date: d.date,
            ctl: null,
            atl: null,
            ctlLoad: null,
            atlLoad: null,
            rampRate: null,
            raw: d.raw,
            syncedAt: d.syncedAt,
          ),
        ),
      ], _today);
      expect(load(none), SignalRating.missing);
    });

    test(
      'without today\'s record the latest ratio still counts, the day does not',
      () {
        final r = rate(today: false);
        expect(load(r), SignalRating.ok);
        expect(r.signal(ReadinessSignalKind.load).dayLoad, isNull);
      },
    );

    test('can be switched off', () {
      final r = evaluateReadiness(
        [..._baseline(), _day(0, ctl: 60, atl: 66, atlLoad: 160)],
        _today,
        enabled: ReadinessSignalKind.values.toSet()
          ..remove(ReadinessSignalKind.load),
      );
      expect(load(r), SignalRating.excluded);
    });

    test('the thresholds come from the rules', () {
      final strict = ReadinessRules.fromJson({
        'acwr': [1.1, 1.2],
        'dayLoadVsCtl': [0.5, 1.0],
        'deviceReadiness': [70, 40],
        'minCtl': 5,
      });
      expect(strict.acwr, [1.1, 1.2]);
      expect(strict.dayLoadVsCtl, [0.5, 1.0]);
      expect(strict.deviceReadiness, [70, 40]);
      expect(strict.minCtl, 5);
      final r = evaluateReadiness(
        [..._baseline(), _day(0, ctl: 60, atl: 60, atlLoad: 45)],
        _today,
        rules: strict,
      );
      expect(load(r), SignalRating.caution); // 0.75 of CTL
      const d = ReadinessRules();
      expect(d.acwr, [1.3, 1.5]);
      expect(d.dayLoadVsCtl, [1.5, 2.5]);
      expect(d.deviceReadiness, [50, 25]);
      expect(
        () => ReadinessRules.fromJson({
          'acwr': [1],
        }),
        throwsFormatException,
      );
    });
  });

  group('readinessScore', () {
    test('null without any rated signal', () {
      final r = evaluateReadiness(const [], DateTime(2026, 5, 20));
      expect(readinessScore(r), isNull);
    });

    Readiness make(ReadinessLevel level, List<SignalRating> ratings) =>
        Readiness(
          level: level,
          dataState: ReadinessDataState.complete,
          signals: [
            for (var i = 0; i < ratings.length; i++)
              ReadinessSignal(
                kind: ReadinessSignalKind.values[i],
                rating: ratings[i],
              ),
          ],
        );

    test('is half the average, half the weakest signal', () {
      // average (100 + 65 + 30) / 3 = 65, weakest 30: (65 + 30) / 2 = 47.5.
      final r = make(ReadinessLevel.backOff, [
        SignalRating.ok,
        SignalRating.caution,
        SignalRating.backOff,
        SignalRating.noBaseline,
      ]);
      expect(readinessScore(r), 48);
    });

    test(
      'one signal off shows in the number instead of being averaged away',
      () {
        final ok = SignalRating.ok;
        // Seven signals, one caution: the plain average would say 95.
        final r = make(ReadinessLevel.caution, [
          ok,
          ok,
          ok,
          ok,
          ok,
          ok,
          SignalRating.caution,
        ]);
        expect(readinessScore(r), 79);
        final all = make(ReadinessLevel.ready, [ok, ok, ok, ok, ok, ok, ok]);
        expect(readinessScore(all), 100);
      },
    );

    test('never reads better than the verdict', () {
      final ok = SignalRating.ok;
      final c = SignalRating.caution;
      // Two cautions make Back off: the number is capped to match.
      final twoCautions = make(ReadinessLevel.backOff, [
        ok,
        ok,
        ok,
        ok,
        ok,
        c,
        c,
      ]);
      expect(readinessScore(twoCautions), lessThanOrEqualTo(59));
    });
  });
}
