import '../../evaluation/session_evaluator.dart' show sportFamily;
import '../activities/activity_icons.dart' show formatDurationSecs;
import '../../widgets/charts/stream_chart.dart' show clockLabel;

/// Speed in m/s as min/km for runs, km/h for rides.
String speedLabel(double mps, String? sportType) {
  if (mps <= 0) return '–';
  if (sportFamily(sportType) == 'run') {
    final secPerKm = (1000 / mps).round();
    return '${secPerKm ~/ 60}:${(secPerKm % 60).toString().padLeft(2, '0')} /km';
  }
  return '${(mps * 3.6).toStringAsFixed(1)} km/h';
}

/// A value of a compared stream, with its unit.
String metricValue(String metric, double v, String? sportType) =>
    switch (metric) {
      'watts' => '${v.round()} W',
      'heartrate' => '${v.round()} bpm',
      'velocity_smooth' => speedLabel(v, sportType),
      'cadence' => '${v.round()} rpm',
      'altitude' => '${v.round()} m',
      _ => v.toStringAsFixed(1),
    };

/// A position on the x-axis: kilometres, or a clock.
String axisLabel(double x, {required bool distance}) =>
    distance ? '${(x / 1000).toStringAsFixed(2)} km' : clockLabel(x.round());

String shortAxisLabel(double x, {required bool distance}) =>
    distance ? (x / 1000).toStringAsFixed(1) : clockLabel(x.round());

String durationLabel(int seconds) => formatDurationSecs(seconds);

/// `+12%` / `-3%`, or null when there is no basis for a change.
String? changeLabel(double? change) {
  if (change == null) return null;
  final pct = (change * 100).round();
  return pct == 0 ? '±0%' : '${pct > 0 ? '+' : ''}$pct%';
}
