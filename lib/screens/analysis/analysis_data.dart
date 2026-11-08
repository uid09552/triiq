import '../../data/models/local_activity.dart';
import '../../data/models/local_wellness.dart';
import '../activities/activity_icons.dart';
import '../../util/dates.dart';

/// What the Analysis screen can chart.
enum AnalysisMetric {
  tss,
  hours,
  distance,
  ctl,
  atl,
  form,
  rampRate,
  hrv,
  restingHr,
  sleep;

  /// Metrics derived from activities (summed per bucket, zero when nothing
  /// was done) as opposed to wellness records (averaged, gap when missing).
  bool get fromActivities => this == tss || this == hours || this == distance;

  /// Crosses zero meaningfully.
  bool get hasZeroLine => this == form || this == rampRate;
}

/// The series behind one Analysis view: one value per bucket (day or week)
/// for every [AnalysisMetric], on a shared x-axis.
class AnalysisSeries {
  const AnalysisSeries({required this.dates, required this.values});

  /// First day of each bucket.
  final List<DateTime> dates;
  final Map<AnalysisMetric, List<double?>> values;

  int get length => dates.length;
}

/// Buckets [from]..[to] by day, or by Monday-start week when [weekly], and
/// fills every metric. [sport] (`swim`/`cycle`/`run`) restricts the
/// activity-derived metrics; wellness metrics are not sport-specific.
AnalysisSeries buildAnalysisSeries({
  required DateTime from,
  required DateTime to,
  required List<LocalWellness> wellness,
  required List<LocalActivity> activities,
  bool weekly = false,
  String? sport,
}) {
  final start = weekly ? startOfWeek(from) : dateOnly(from);
  final end = dateOnly(to);
  final step = weekly ? 7 : 1;
  final dates = <DateTime>[];
  for (var d = start; !d.isAfter(end); d = d.add(Duration(days: step))) {
    dates.add(d);
  }

  int? bucketOf(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return null;
    final index = dateOnly(d).difference(start).inDays ~/ step;
    return index < 0 || index >= dates.length ? null : index;
  }

  final tss = List<double>.filled(dates.length, 0);
  final hours = List<double>.filled(dates.length, 0);
  final distance = List<double>.filled(dates.length, 0);
  for (final a in activities) {
    if (sport != null && canonicalSport(a.type) != sport) continue;
    final i = bucketOf(a.date);
    if (i == null) continue;
    tss[i] += (a.trainingLoad ?? 0).toDouble();
    hours[i] += (a.movingTime ?? 0) / 3600;
    distance[i] += (a.distance ?? 0) / 1000;
  }

  List<double?> mean(double? Function(LocalWellness) pick) {
    final sums = List<double>.filled(dates.length, 0);
    final counts = List<int>.filled(dates.length, 0);
    for (final w in wellness) {
      final i = bucketOf(w.date);
      final v = pick(w);
      if (i == null || v == null) continue;
      sums[i] += v;
      counts[i]++;
    }
    return [
      for (var i = 0; i < dates.length; i++)
        counts[i] == 0 ? null : sums[i] / counts[i],
    ];
  }

  double? positive(Object? v) => v is num && v > 0 ? v.toDouble() : null;

  return AnalysisSeries(
    dates: dates,
    values: {
      AnalysisMetric.tss: tss,
      AnalysisMetric.hours: hours,
      AnalysisMetric.distance: distance,
      AnalysisMetric.ctl: mean((w) => w.ctl),
      AnalysisMetric.atl: mean((w) => w.atl),
      AnalysisMetric.form: mean(
        (w) => w.ctl != null && w.atl != null ? w.ctl! - w.atl! : null,
      ),
      AnalysisMetric.rampRate: mean((w) => w.rampRate),
      AnalysisMetric.hrv: mean((w) => positive(w.raw['hrv'])),
      AnalysisMetric.restingHr: mean((w) => positive(w.raw['restingHR'])),
      AnalysisMetric.sleep: mean((w) {
        final secs = positive(w.raw['sleepSecs']);
        return secs == null ? null : secs / 3600;
      }),
    },
  );
}
