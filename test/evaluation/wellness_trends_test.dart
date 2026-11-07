import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_wellness.dart';
import 'package:triiq/evaluation/wellness_trends.dart';
import 'package:triiq/util/dates.dart';

final _today = DateTime(2026, 11, 7);

LocalWellness _day(int daysAgo, Map<String, Object?> raw) {
  final date = isoDate(DateTime(_today.year, _today.month, _today.day - daysAgo));
  return LocalWellness(
    date: date,
    ctl: null,
    atl: null,
    ctlLoad: null,
    atlLoad: null,
    rampRate: null,
    raw: {'id': date, ...raw},
    syncedAt: DateTime(2026),
  );
}

void main() {
  test('values per metric; zero counts as not measured; sleep in hours', () {
    final r = _day(0, {'hrv': 55, 'restingHR': 0, 'sleepSecs': 27000, 'weight': 71.4});
    expect(wellnessValue(r, WellnessMetric.hrv), 55);
    expect(wellnessValue(r, WellnessMetric.restingHr), isNull);
    expect(wellnessValue(r, WellnessMetric.sleep), 7.5);
    expect(wellnessValue(r, WellnessMetric.weight), 71.4);
    expect(wellnessValue(_day(1, {}), WellnessMetric.hrv), isNull);
  });

  test('trailing average ignores gaps and waits for two values', () {
    final avg = trailingAverage([10, null, 20, null, null, 30], window: 3);
    expect(avg[0], isNull); // one value only
    expect(avg[1], isNull);
    expect(avg[2], 15); // 10 and 20
    expect(avg[3], isNull); // window 1..3 holds only the 20
    expect(avg[5], isNull); // window 3..5 holds only the 30
    final wide = trailingAverage([10, null, 20, null, null, 30], window: 4);
    expect(wide[5], 25); // window 2..5: 20 and 30
  });

  test('baseline band is mean ± one SD, null on too little data', () {
    expect(baselineBand([1, 2, 3]), isNull);
    final b = baselineBand([for (var i = 0; i < 20; i++) i.isEven ? 60.0 : 70.0])!;
    expect(b.mean, 65);
    expect(b.sd, closeTo(5.13, 0.01));
    expect(b.contains(65), isTrue);
    expect(b.contains(80), isFalse);
  });

  test('a trend over a range: latest, weekly change and where it stands', () {
    // 30 days of HRV around 60 with the last week clearly lower.
    final records = [
      for (var i = 0; i < 30; i++)
        _day(i, {'hrv': i < 7 ? 45 : 60 + (i.isEven ? 4 : -4)}),
    ];
    final t = wellnessTrend(records, WellnessMetric.hrv, _today, 30);
    expect(t.days, hasLength(30));
    expect(t.days.last, DateTime(2026, 11, 7));
    expect(t.latest!.$2, 45);
    expect(t.latestAverage, 45);
    expect(t.weekChange, lessThan(0));
    expect(t.position, BandPosition.below);
    expect(t.hasData, isTrue);
  });

  test('no records: no data, no band', () {
    final t = wellnessTrend(const [], WellnessMetric.weight, _today, 90);
    expect(t.hasData, isFalse);
    expect(t.band, isNull);
    expect(t.latest, isNull);
    expect(t.position, isNull);
  });
}
