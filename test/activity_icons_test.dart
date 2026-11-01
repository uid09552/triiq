import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/screens/activities/activity_icons.dart';

void main() {
  group('canonicalSport', () {
    test('buckets Ride and its virtual/gravel variants as cycle', () {
      expect(canonicalSport('Ride'), 'cycle');
      expect(canonicalSport('VirtualRide'), 'cycle');
      expect(canonicalSport('GravelRide'), 'cycle');
    });

    test('buckets Run and VirtualRun as run', () {
      expect(canonicalSport('Run'), 'run');
      expect(canonicalSport('VirtualRun'), 'run');
    });

    test('buckets Swim as swim', () {
      expect(canonicalSport('Swim'), 'swim');
    });

    test('returns null for an unmatched type', () {
      expect(canonicalSport('Walk'), isNull);
      expect(canonicalSport('Yoga'), isNull);
      expect(canonicalSport(null), isNull);
    });
  });
}
