import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/evaluation/activity_extras.dart';
import 'package:triiq/evaluation/session_streams.dart';

void main() {
  group('histogram', () {
    test('time per band, zeros kept apart', () {
      final h = histogramOf([0, 0, 110, 120, 130, 130, 260, null], binWidth: 25);
      expect(h.zeroSeconds, 3); // two zeros and a gap
      expect(h.totalSeconds, 8);
      expect(h.bins.map((b) => b.lo), [100, 125, 250]);
      expect(h.bins.map((b) => b.seconds), [2, 2, 1]);
      expect(h.peak!.seconds, 2);
      expect(h.shareAtLeast(125), closeTo(3 / 5, 1e-9));
    });
    test('empty and all-zero are empty', () {
      expect(histogramOf(const [], binWidth: 25).isEmpty, isTrue);
      expect(histogramOf([0, 0], binWidth: 25).isEmpty, isTrue);
    });
    test('band width: 25 W, 50 W for big sprints, 0.25 m/s for speed', () {
      expect(binWidthFor('watts', [200, 300]), 25);
      expect(binWidthFor('watts', [200, 900]), 50);
      expect(binWidthFor('velocity_smooth', [3, 4]), 0.25);
    });
  });

  group('variability index', () {
    test('a perfectly even effort is 1.0', () {
      expect(variabilityIndex(List<double?>.filled(120, 200)), closeTo(1, 1e-9));
    });
    test('alternating hard and easy blocks raise it', () {
      final surges = <double?>[
        for (var b = 0; b < 8; b++) ...List<double?>.filled(60, b.isEven ? 350 : 100),
      ];
      final vi = variabilityIndex(surges)!;
      expect(vi, greaterThan(1.15));
      expect(variabilityBand(vi), VariabilityBand.variable);
    });
    test('bands and too-short input', () {
      expect(variabilityBand(1.02), VariabilityBand.steady);
      expect(variabilityBand(1.1), VariabilityBand.moderate);
      expect(variabilityIndex(List<double?>.filled(10, 200)), isNull);
      expect(variabilityIndex(const []), isNull);
    });
  });

  group('intervals', () {
    // Two 300 s work intervals with a 120 s recovery between. In the first,
    // HR stays at 150; in the second it climbs from 150 to 165 at the same
    // power.
    SessionStreams streams() {
      final watts = <double?>[
        ...List<double?>.filled(300, 300),
        ...List<double?>.filled(120, 100),
        ...List<double?>.filled(300, 285),
      ];
      final hr = <double?>[
        ...List<double?>.filled(300, 150),
        ...List<double?>.filled(120, 140),
        ...List<double?>.filled(150, 150),
        ...List<double?>.filled(150, 165),
      ];
      return SessionStreams(
        series: {
          'time': [for (var i = 0; i < watts.length; i++) i.toDouble()],
          'watts': watts,
          'heartrate': hr,
        },
        intervals: const [
          SessionInterval(start: 0, end: 299, type: 'WORK'),
          SessionInterval(start: 300, end: 419, type: 'RECOVERY'),
          SessionInterval(start: 420, end: 719, type: 'WORK'),
        ],
      );
    }

    test('averages, drift inside each interval and fade against the first', () {
      final s = intervalStats(streams(), outputKey: 'watts');
      expect(s, hasLength(3));
      expect(s[0].avgOutput, 300);
      expect(s[0].drift, closeTo(0, 1e-9));
      expect(s[0].fade, isNull); // the reference
      expect(s[1].isWork, isFalse);
      expect(s[1].fade, isNull);
      expect(s[2].avgOutput, 285);
      expect(s[2].fade, closeTo(-0.05, 1e-9));
      // Second half gives 285/165 vs 285/150: EF down 9.1 %.
      expect(s[2].drift, closeTo(9.09, 0.05));
      expect(s[2].avgHeartrate, closeTo(157.5, 1e-9));
    });

    test('short intervals have no drift; no output stream gives nothing', () {
      final short = SessionStreams(
        series: {
          'watts': List<double?>.filled(200, 250),
          'heartrate': List<double?>.filled(200, 140),
        },
        intervals: const [SessionInterval(start: 0, end: 59)],
      );
      expect(intervalStats(short, outputKey: 'watts').single.drift, isNull);
      expect(intervalStats(short, outputKey: 'velocity_smooth'), isEmpty);
    });
  });
}
