import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/plan/plan_models.dart';

void main() {
  final today = DateTime(2026, 10, 31);
  const base = Goal(
    targetType: 'long_distance',
    sport: Goal.triathlon,
    weekdays: {2, 4, 6, 7},
    weeklyHours: 10,
  );

  test('new fields round-trip through JSON', () {
    final g = base.copyWith(
      holdEvery4th: false,
      slotShares: {'z2': 20, 'intervals': 50, 'long': 30},
      longDays: {'Ride': 6, 'Run': 7},
      intervalDays: {2},
      maxSessionsPerDay: 1,
    );

    final back = Goal.fromJson(g.toJson());

    expect(back.holdEvery4th, isFalse);
    expect(back.slotShares, {'z2': 20, 'intervals': 50, 'long': 30});
    expect(back.longDays, {'Ride': 6, 'Run': 7});
    expect(back.intervalDays, {2});
    expect(back.maxSessionsPerDay, 1);
    expect(back.validate(today: today), isNull);
  });

  test('a goal saved before has the defaults', () {
    final back = Goal.fromJson({
      'targetType': 'long_distance',
      'weekdays': [2, 4, 6],
      'weeklyHours': 6,
      'sport': 'Run',
    });

    expect(back.holdEvery4th, isTrue);
    expect(back.slotShares, isNull);
    expect(back.longDays, isEmpty);
    expect(back.intervalDays, isEmpty);
    expect(back.effectiveMaxPerDay, 1);
    expect(base.effectiveMaxPerDay, 2);
  });

  test('validation', () {
    String? v(Goal g) => g.validate(today: today);

    expect(
      v(base.copyWith(slotShares: {'z2': 20, 'intervals': 45, 'long': 30})),
      contains('95%'),
    );
    expect(
      v(base.copyWith(slotShares: {'z2': 22, 'intervals': 48, 'long': 30})),
      contains('5% steps'),
    );
    expect(v(base.copyWith(longDays: {'Ride': 3})), contains('training day'));
    expect(
      v(base.copyWith(longDays: {'Ride': 6, 'Run': 6})),
      contains('different days'),
    );
    expect(v(base.copyWith(intervalDays: {1})), contains('training days'));
    expect(v(base.copyWith(maxSessionsPerDay: 3)), contains('1 or 2'));
  });

  test('unticking a day drops the preferences on it', () {
    final g = base
        .copyWith(longDays: {'Ride': 6, 'Run': 7}, intervalDays: {2, 4})
        .copyWith(weekdays: {2, 4, 7})
        .withoutStalePreferences();

    expect(g.longDays, {'Run': 7});
    expect(g.intervalDays, {2, 4});
    expect(g.validate(today: today), isNull);
  });
}
