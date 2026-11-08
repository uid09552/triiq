import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/evaluation/performance_trend.dart';

LocalActivity act(String id, String date, double? ef, {String type = 'Ride'}) =>
    LocalActivity(
      id: id,
      date: date,
      type: type,
      name: id,
      movingTime: 3600,
      distance: null,
      trainingLoad: null,
      raw: {if (ef != null) 'icu_efficiency_factor': ef},
      syncedAt: DateTime(2026),
    );

void main() {
  final history = [
    act('a', '2026-10-01', 1.5),
    act('b', '2026-10-05', 1.5),
    act('c', '2026-10-10', 1.5),
  ];

  test('up when clearly above recent norm', () {
    expect(
      performanceTrend(act('x', '2026-10-15', 1.6), history),
      PerformanceTrend.up,
    );
  });

  test('down when clearly below', () {
    expect(
      performanceTrend(act('x', '2026-10-15', 1.4), history),
      PerformanceTrend.down,
    );
  });

  test('null within threshold, too little data, other sport or no EF', () {
    expect(performanceTrend(act('x', '2026-10-15', 1.51), history), isNull);
    expect(
      performanceTrend(act('x', '2026-10-15', 1.7), history.take(2)),
      isNull,
    );
    expect(
      performanceTrend(act('x', '2026-10-15', 1.7, type: 'Run'), history),
      isNull,
    );
    expect(performanceTrend(act('x', '2026-10-15', null), history), isNull);
  });
}
