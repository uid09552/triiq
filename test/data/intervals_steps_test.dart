import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/intervals_steps.dart';

void main() {
  // The reported case: a 30-minute swim whose distances were written with
  // "m"; Intervals.icu read them as minutes (about 20 hours).
  const metresAsM = '''
- 300m Warm up, easy
4x
  - 50m Catch-up drill
  - 50m w/ paddles, moderate
2x
  - 100m w/ pull buoy, steady
  - 50m w/ fins, kick only
- 200m Cool down, easy''';

  group('estimateStepMinutes', () {
    test(
      'reads "m" as minutes, like Intervals.icu, with repeats multiplied',
      () {
        // 300 + 4*(50+50) + 2*(100+50) + 200 = 1200 minutes = 20 h.
        expect(estimateStepMinutes(metresAsM), 1200);
      },
    );

    test('a normal minute-based swim adds up', () {
      const text = '''
- 10m 75%
4x
  - 3m 98%
  - 1m 70%
- 5m 72%''';
      expect(estimateStepMinutes(text), 31);
    });

    test('inline repeats, seconds, hours; distances count for nothing', () {
      expect(estimateStepMinutes('- 4x50m drill'), 200);
      expect(estimateStepMinutes('- 90s easy'), 1.5);
      expect(estimateStepMinutes('- 1h 60%'), 60);
      expect(estimateStepMinutes('- 300mtr easy\n- 2km steady'), 0);
      // Numbers in the trailing text are not durations.
      expect(estimateStepMinutes('- 10m 70% pace 1:45/100m'), 10);
    });
  });

  group('fixSwimDistanceUnits', () {
    test('a 30-minute swim written in metres becomes mtr, not 20 hours', () {
      final fixed = fixSwimDistanceUnits(metresAsM, durationMinutes: 30);
      expect(fixed, contains('- 300mtr Warm up, easy'));
      expect(fixed, contains('  - 50mtr Catch-up drill'));
      expect(fixed, contains('- 200mtr Cool down, easy'));
      expect(estimateStepMinutes(fixed), 0);
    });

    test('minute-based swims are left alone', () {
      const text = '''
- 10m 75%
4x
  - 3m 98%
  - 1m 70%
- 5m 72%''';
      expect(fixSwimDistanceUnits(text, durationMinutes: 31), text);
      expect(fixSwimDistanceUnits(text, durationMinutes: 40), text);
    });

    test('already mtr, paces and "min" are never touched twice', () {
      const text = '- 300mtr easy\n- 200mtr 1:35/100m\n- 10min 70%';
      expect(fixSwimDistanceUnits(text, durationMinutes: 5), text);
      final once = fixSwimDistanceUnits(metresAsM, durationMinutes: 30);
      expect(fixSwimDistanceUnits(once, durationMinutes: 30), once);
    });

    test('keeps a pace per 100m while converting the distance', () {
      final fixed = fixSwimDistanceUnits(
        '- 200m w/ paddles, 1:35/100m\n- 4x50m drill',
        durationMinutes: 10,
      );
      expect(fixed, '- 200mtr w/ paddles, 1:35/100m\n- 4x50mtr drill');
    });

    test('without a duration it converts only on a 3-digit "m" step', () {
      expect(fixSwimDistanceUnits('- 300m easy'), '- 300mtr easy');
      expect(
        fixSwimDistanceUnits('- 10m 75%\n- 5m 70%'),
        '- 10m 75%\n- 5m 70%',
      );
    });
  });
}
