import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/screens/today/weekly_targets_row.dart';

LocalActivity _activity({
  required String id,
  required String type,
  required int movingTime,
}) => LocalActivity(
  id: id,
  date: '2026-10-26',
  type: type,
  name: null,
  movingTime: movingTime,
  distance: null,
  trainingLoad: null,
  raw: const {},
  syncedAt: DateTime(2026, 10, 26),
);

void main() {
  group('weeklySportSeconds', () {
    test('empty list sums to nothing', () {
      expect(weeklySportSeconds(const []), isEmpty);
    });

    test('mixed Ride/VirtualRide activities sum into one cycle total', () {
      final totals = weeklySportSeconds([
        _activity(id: '1', type: 'Ride', movingTime: 3600),
        _activity(id: '2', type: 'VirtualRide', movingTime: 1800),
      ]);

      expect(totals['cycle'], 5400);
    });

    test('each sport totals independently', () {
      final totals = weeklySportSeconds([
        _activity(id: '1', type: 'Swim', movingTime: 1500),
        _activity(id: '2', type: 'Run', movingTime: 2400),
        _activity(id: '3', type: 'Ride', movingTime: 3600),
      ]);

      expect(totals, {'swim': 1500, 'run': 2400, 'cycle': 3600});
    });

    test('activities outside the three target sports are left out', () {
      final totals = weeklySportSeconds([
        _activity(id: '1', type: 'Hike', movingTime: 3000),
      ]);

      expect(totals, isEmpty);
    });
  });
}
