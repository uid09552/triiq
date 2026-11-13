import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/data/models/local_wellness.dart';
import 'package:triiq/data/repositories/wellness_repository.dart';
import 'package:triiq/evaluation/fatigue_warning.dart';
import 'package:triiq/evaluation/readiness.dart';
import 'package:triiq/evaluation/readiness_service.dart';
import 'package:triiq/evaluation/readiness_settings.dart';
import 'package:triiq/evaluation/wellness_baseline.dart';
import 'package:triiq/util/dates.dart';

final _today = DateTime(2026, 11, 1);

DateTime _ago(int days) =>
    DateTime(_today.year, _today.month, _today.day - days);

LocalWellness _day(int daysAgo, {num? hrv, num? rhr, num? sleepSecs}) {
  final date = isoDate(_ago(daysAgo));
  return LocalWellness(
    date: date,
    ctl: 60,
    atl: 60,
    ctlLoad: null,
    atlLoad: null,
    rampRate: null,
    raw: {'id': date, 'hrv': ?hrv, 'restingHR': ?rhr, 'sleepSecs': ?sleepSecs},
    syncedAt: DateTime(2026),
  );
}

/// Resting HR cycling 47 / 48 / 49 (median 48, MAD 1 → MADσ 1.48): caution
/// from 51 (48 + 3 bpm), back off from 54 (48 + 6 bpm), clears below 50.
/// HRV cycling 58 / 62 / 66 (median 62, MADσ 5.93): caution below 56.1,
/// back off below 50.1.
num _rhrBase(int i) => 47 + i % 3;
num _hrvBase(int i) => 58 + 4 * (i % 3);

/// Baseline days [from] .. [to] days ago, and [recent] values (index 0 =
/// today) on top. Recent entries are `(rhr, hrv)`; a null keeps the baseline.
List<LocalWellness> _history({
  int from = 0,
  int to = 60,
  List<(num?, num?)> recent = const [],
  bool withHrv = true,
  bool withSleep = false,
}) => [
  for (var i = to; i >= from; i--)
    _day(
      i,
      rhr: i < recent.length ? recent[i].$1 ?? _rhrBase(i) : _rhrBase(i),
      hrv: withHrv
          ? (i < recent.length ? recent[i].$2 ?? _hrvBase(i) : _hrvBase(i))
          : null,
      sleepSecs: withSleep ? 8 * 3600 : null,
    ),
];

ReadinessSignal _rhr(
  List<LocalWellness> r, {
  int daysAgo = 0,
  ReadinessRules? rules,
}) => evaluateReadiness(
  r,
  _ago(daysAgo),
  rules: rules ?? const ReadinessRules(),
).signal(ReadinessSignalKind.restingHr);

ReadinessSignal _hrv(List<LocalWellness> r, {int daysAgo = 0}) =>
    evaluateReadiness(r, _ago(daysAgo)).signal(ReadinessSignalKind.hrv);

void main() {
  group('robust baseline', () {
    test('median and MADσ, outliers and implausible readings dropped', () {
      final b = robustBaseline([
        for (var i = 0; i < 30; i++) 47.0 + i % 3,
        75, // a sick day: > 4 MADσ from the median
        15, // not a resting HR
        180,
      ], signal: WellnessSignal.restingHr)!;
      expect(b.median, 48);
      expect(b.sigma, closeTo(1.4826, 1e-4));
      expect(b.count, 30);
    });

    test('a flat history still has a spread', () {
      final b = robustBaseline([
        for (var i = 0; i < 25; i++) 48.0,
      ], signal: WellnessSignal.restingHr)!;
      expect(b.sigma, 1);
    });

    test('implausible single readings are not values', () {
      expect(
        wellnessSignalValue(_day(0, rhr: 20), WellnessSignal.restingHr),
        isNull,
      );
      expect(
        wellnessSignalValue(_day(0, rhr: 130), WellnessSignal.restingHr),
        isNull,
      );
      expect(wellnessSignalValue(_day(0, hrv: 0), WellnessSignal.hrv), isNull);
      expect(
        wellnessSignalValue(_day(0, hrv: 350), WellnessSignal.hrv),
        isNull,
      );
      expect(wellnessSignalValue(_day(0, hrv: 70), WellnessSignal.hrv), 70);
    });

    test('the smoothing window is not part of the baseline', () {
      final values = wellnessSignalValues(
        _history(to: 30, recent: [(60, null), (60, null), (60, null)]),
        WellnessSignal.restingHr,
      );
      final r = wellnessReading(values, _today, WellnessSignal.restingHr);
      expect(r.smoothed, 60);
      expect(r.smoothedDays, 3);
      expect(r.baseline!.median, 48);
      expect(r.baselineCount, 28); // days 3..30
    });
  });

  group('resting HR', () {
    test('a single +12 bpm day does not change the rating', () {
      final r = evaluateReadiness(
        _history(recent: [(60, null)], withSleep: true),
        _today,
      );
      final s = r.signal(ReadinessSignalKind.restingHr);
      expect(s.rating, SignalRating.ok);
      expect(s.todayValue, 60);
      expect(s.value, lessThan(51));
      expect(r.level, ReadinessLevel.ready);
      // Nor does it the day after.
      expect(
        _rhr(_history(recent: [(null, null), (60, null)])).rating,
        SignalRating.ok,
      );
    });

    test('+6 bpm for three days: back off, capped at caution when HRV and '
        'sleep are fine', () {
      final sustained = [(54, null), (54, null), (54, null)];
      final alone = _history(recent: sustained, withHrv: false);
      expect(_rhr(alone).rating, SignalRating.backOff);
      expect(evaluateReadiness(alone, _today).level, ReadinessLevel.backOff);

      final r = evaluateReadiness(
        _history(recent: sustained, withSleep: true),
        _today,
      );
      expect(r.signal(ReadinessSignalKind.hrv).rating, SignalRating.ok);
      expect(
        r.signal(ReadinessSignalKind.restingHr).rating,
        SignalRating.caution,
      );
      expect(r.level, ReadinessLevel.caution);

      // HRV low as well: no cap.
      final both = evaluateReadiness(
        _history(recent: [(54, 50), (54, 50), (54, 50)], withSleep: true),
        _today,
      );
      expect(
        both.signal(ReadinessSignalKind.restingHr).rating,
        SignalRating.backOff,
      );
    });

    test('+3 bpm for three days is a caution', () {
      expect(
        _rhr(_history(recent: [(51, null), (51, null), (51, null)])).rating,
        SignalRating.caution,
      );
    });

    test('no rating until the baseline has 21 values', () {
      // Today and the two days before are the smoothing window.
      final short = _rhr(_history(to: 22));
      expect(short.rating, SignalRating.noBaseline);
      expect(short.baselineCount, 20);
      expect(short.baselineNeeded, 21);
      expect(_rhr(_history(to: 23)).rating, SignalRating.ok);
    });

    test('a value wobbling around the threshold does not flip daily', () {
      // 52 / 50 / 52 / ...: the 3-day median alternates between caution and
      // just under the threshold, but never clears it by the 1 bpm margin.
      final records = _history(
        recent: [for (var i = 0; i < 12; i++) (i.isEven ? 52 : 50, null)],
        withHrv: false,
      );
      for (var d = 0; d < 6; d++) {
        expect(
          _rhr(records, daysAgo: d).rating,
          SignalRating.caution,
          reason: '$d days ago',
        );
      }
      // Without hysteresis the odd days would read ok.
      expect(_rhr(records, daysAgo: 1).value, 50);
    });

    test('a raised level clears after two days back under the margin', () {
      // 53 on days 6..4, normal from day 3.
      final records = _history(
        recent: [for (var i = 0; i <= 6; i++) (i >= 4 ? 53 : 48, null)],
        withHrv: false,
      );
      expect(_rhr(records, daysAgo: 4).rating, SignalRating.caution);
      expect(_rhr(records, daysAgo: 2).value, 48);
      expect(_rhr(records, daysAgo: 2).rating, SignalRating.caution);
      expect(_rhr(records, daysAgo: 1).rating, SignalRating.ok);
      expect(_rhr(records).rating, SignalRating.ok);
    });

    test('a 5-day window needs the change to last longer than a 3-day one', () {
      final records = _history(
        recent: [(54, null), (54, null)],
        withHrv: false,
      );
      expect(_rhr(records).rating, SignalRating.backOff);
      expect(_rhr(records).smoothingDays, 3);
      final five = _rhr(records, rules: const ReadinessRules(smoothingDays: 5));
      expect(five.rating, SignalRating.ok);
      expect(five.smoothingDays, 5);
      // Three of five days up is enough.
      expect(
        _rhr(
          _history(
            recent: [(54, null), (54, null), (54, null)],
            withHrv: false,
          ),
          rules: const ReadinessRules(smoothingDays: 5),
        ).rating,
        SignalRating.backOff,
      );
    });
  });

  group('HRV', () {
    test('one low morning is ignored, three are a caution or back off', () {
      expect(_hrv(_history(recent: [(null, 40)])).rating, SignalRating.ok);
      expect(
        _hrv(_history(recent: [(null, 52), (null, 52), (null, 52)])).rating,
        SignalRating.caution,
      );
      final low = _hrv(_history(recent: [(null, 48), (null, 48), (null, 48)]));
      expect(low.rating, SignalRating.backOff);
      expect(low.mean, 62);
      expect(low.sd, closeTo(4 * madToSigma, 1e-9));
      expect(low.okBound, closeTo(62 - 4 * madToSigma, 1e-9));
    });

    test('an implausible reading is no reading', () {
      final s = _hrv(_history(recent: [(null, 400)]));
      expect(s.rating, SignalRating.missing);
      expect(s.todayValue, isNull);
    });

    test('hysteresis: just above the threshold keeps the caution', () {
      // 52 on days 5..3, then 56.5: above the 56.1 threshold but inside the
      // 0.25 MADσ margin (57.6), so it holds.
      final records = _history(
        recent: [for (var i = 0; i <= 5; i++) (null, i >= 3 ? 52 : 56.5)],
      );
      expect(_hrv(records, daysAgo: 3).rating, SignalRating.caution);
      expect(_hrv(records).value, 56.5);
      expect(_hrv(records).rating, SignalRating.caution);
      // Back to normal for two days: clears.
      final recovered = _history(
        recent: [for (var i = 0; i <= 5; i++) (null, i >= 3 ? 52 : 62)],
      );
      expect(_hrv(recovered, daysAgo: 1).rating, SignalRating.caution);
      expect(_hrv(recovered).rating, SignalRating.ok);
    });
  });

  group('rules', () {
    test('the new keys come from okf-rules', () {
      final r = ReadinessRules.fromJson({
        'restingHrBpm': [4, 8],
        'restingHrMad': [2, 3],
        'smoothingDays': 5,
        'minBaselineDays': 28,
        'outlierMad': 3,
        'restingHrClearBpm': 2,
        'hrvClearSd': 0.5,
        'clearDays': 3,
      });
      expect(r.restingHrBpm, [4, 8]);
      expect(r.restingHrMad, [2, 3]);
      expect(r.smoothingDays, 5);
      expect(r.minBaselineDays, 28);
      expect(r.outlierMad, 3);
      expect(r.restingHrClearBpm, 2);
      expect(r.hrvClearSd, 0.5);
      expect(r.clearDays, 3);
      const d = ReadinessRules();
      expect(d.restingHrBpm, [3, 6]);
      expect(d.restingHrMad, [1.5, 2.5]);
      expect(d.smoothingDays, 3);
      expect(d.minBaselineDays, 21);
      expect(
        () => ReadinessRules.fromJson({'smoothingDays': 0}),
        throwsFormatException,
      );
      expect(
        () => ReadinessRules.fromJson({'clearDays': 0}),
        throwsFormatException,
      );
    });

    test('a stricter minimum keeps the signal unrated longer', () {
      final s = _rhr(
        _history(to: 30),
        rules: ReadinessRules.fromJson({'minBaselineDays': 30}),
      );
      expect(s.rating, SignalRating.noBaseline);
      expect(s.baselineNeeded, 30);
    });
  });

  group('smoothing setting', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('is stored, restored and validated', () async {
      final a = ReadinessSettings.forTesting();
      await a.load();
      expect(a.smoothingDays, isNull);
      await a.setSmoothingDays(5);
      expect(a.smoothingDays, 5);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('readiness.smoothing_days'), 5);

      final b = ReadinessSettings.forTesting();
      await b.load();
      expect(b.smoothingDays, 5);

      expect(() => b.setSmoothingDays(4), throwsArgumentError);
      await b.setSmoothingDays(null);
      expect(prefs.getInt('readiness.smoothing_days'), isNull);
    });

    test('a bad stored value is ignored', () async {
      SharedPreferences.setMockInitialValues({'readiness.smoothing_days': 9});
      final s = ReadinessSettings.forTesting();
      await s.load();
      expect(s.smoothingDays, isNull);
    });

    test('the service rates with the chosen window', () async {
      final now = dateOnly(DateTime.now());
      final repo = WellnessRepository();
      await repo.upsertAll([
        for (var i = 40; i >= 0; i--)
          LocalWellness(
            date: isoDate(DateTime(now.year, now.month, now.day - i)),
            ctl: 60,
            atl: 60,
            ctlLoad: null,
            atlLoad: null,
            rampRate: null,
            raw: {'restingHR': i <= 1 ? 56 : _rhrBase(i)},
            syncedAt: DateTime(2026),
          ),
      ]);
      final settings = ReadinessSettings.forTesting();
      final service = ReadinessService(wellness: repo, settings: settings);
      ReadinessSignal rhr(ReadinessReport r) =>
          r.readiness.signal(ReadinessSignalKind.restingHr);

      final three = rhr(await service.load());
      expect(three.smoothingDays, 3);
      expect(three.rating, SignalRating.backOff);
      await settings.setSmoothingDays(5);
      final five = rhr(await service.load());
      expect(five.smoothingDays, 5);
      expect(five.rating, SignalRating.ok);
    });
  });

  group('fatigue warning', () {
    final today = DateTime(2026, 5, 20);
    LocalWellness day(int ago, num rhr) {
      final d = today.subtract(Duration(days: ago));
      return LocalWellness(
        date: isoDate(d),
        ctl: 50,
        atl: 50,
        ctlLoad: null,
        atlLoad: null,
        rampRate: null,
        raw: {'restingHR': rhr, 'hrv': 60},
        syncedAt: DateTime(2026),
      );
    }

    test('a few sick days in the history do not hide a trend', () {
      // 55 bpm on 3 of the last 5 days against a 50 bpm baseline that has
      // nine 62 bpm days in it: the mean (≈ 51.8) would need 55.8, the
      // median needs 54.
      final records = [
        for (var i = 64; i >= 5; i--) day(i, i % 7 == 0 ? 62 : 50),
        for (var i = 4; i >= 0; i--) day(i, i <= 2 ? 55 : 50),
      ];
      final w = evaluateFatigue(records, today);
      expect(
        w.firing.map((s) => s.kind),
        contains(FatigueSignalKind.restingHrHigh),
      );
    });

    test('fewer than 21 baseline values: no physiological signal', () {
      final records = [
        for (var i = 24; i >= 5; i--) day(i, 50),
        for (var i = 4; i >= 0; i--) day(i, 60),
      ];
      expect(
        evaluateFatigue(records, today).signals.where((s) => s.physiological),
        isEmpty,
      );
    });
  });
}
