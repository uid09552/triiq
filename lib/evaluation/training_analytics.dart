import 'dart:math' as math;

import '../data/models/local_activity.dart';
import '../util/dates.dart';
import 'intensity.dart';

/// Pure analytics over the cached activities (and CTL from wellness): fitness
/// per sport, intensity distribution, load-safety ratios and the aerobic
/// decoupling / efficiency trend. No I/O — the Analytics screen feeds it the
/// cache and draws what comes back.

// ---------------------------------------------------------------------------
// Per-sport fitness
// ---------------------------------------------------------------------------

enum LoadSport { swim, ride, run, other }

/// Folds an Intervals.icu activity `type` into the three triathlon sports.
LoadSport loadSportOf(String? type) {
  switch (type) {
    case 'Swim':
    case 'OpenWaterSwim':
      return LoadSport.swim;
    case 'Ride':
    case 'VirtualRide':
    case 'GravelRide':
    case 'MountainBikeRide':
    case 'EBikeRide':
    case 'Handcycle':
    case 'Velomobile':
      return LoadSport.ride;
    case 'Run':
    case 'TrailRun':
    case 'VirtualRun':
      return LoadSport.run;
    default:
      return LoadSport.other;
  }
}

/// Time constants Intervals.icu uses for CTL and ATL.
const ctlDays = 42;
const atlDays = 7;

class SportFitnessDay {
  const SportFitnessDay({
    required this.date,
    required this.ctl,
    required this.atl,
  });

  final DateTime date;
  final Map<LoadSport, double> ctl;
  final Map<LoadSport, double> atl;

  double get totalCtl => ctl.values.fold(0, (a, b) => a + b);
  double get totalAtl => atl.values.fold(0, (a, b) => a + b);
}

/// Daily training load per sport, `date -> sport -> load`.
Map<String, Map<LoadSport, double>> dailyLoadBySport(
  Iterable<LocalActivity> activities,
) {
  final out = <String, Map<LoadSport, double>>{};
  for (final a in activities) {
    final load = a.trainingLoad;
    if (load == null || load <= 0) continue;
    final day = out.putIfAbsent(a.date, () => {});
    day.update(
      loadSportOf(a.type),
      (v) => v + load,
      ifAbsent: () => load.toDouble(),
    );
  }
  return out;
}

/// CTL / ATL for each sport as an exponentially weighted average of its own
/// daily load (the same model Intervals.icu uses for the combined figure), for
/// every day in [from]..[to]. The averages start from zero at the earliest
/// activity in [activities], so pass history from before [from] as warm-up.
/// Sports with no load in the data are left out.
List<SportFitnessDay> sportFitness(
  Iterable<LocalActivity> activities, {
  required DateTime from,
  required DateTime to,
}) {
  final loads = dailyLoadBySport(activities);
  final start = dateOnly(from);
  final end = dateOnly(to);
  if (end.isBefore(start)) return const [];

  final earliest = loads.keys.isEmpty
      ? start
      : loads.keys.map(DateTime.parse).reduce((a, b) => a.isBefore(b) ? a : b);
  var day = earliest.isBefore(start) ? dateOnly(earliest) : start;

  final ctl = {for (final s in LoadSport.values) s: 0.0};
  final atl = {for (final s in LoadSport.values) s: 0.0};
  final used = <LoadSport>{for (final m in loads.values) ...m.keys};

  final out = <SportFitnessDay>[];
  while (!day.isAfter(end)) {
    final today = loads[isoDate(day)] ?? const <LoadSport, double>{};
    for (final s in LoadSport.values) {
      final load = today[s] ?? 0;
      ctl[s] = ctl[s]! + (load - ctl[s]!) / ctlDays;
      atl[s] = atl[s]! + (load - atl[s]!) / atlDays;
    }
    if (!day.isBefore(start)) {
      out.add(
        SportFitnessDay(
          date: day,
          ctl: {for (final s in used) s: ctl[s]!},
          atl: {for (final s in used) s: atl[s]!},
        ),
      );
    }
    day = DateTime(day.year, day.month, day.day + 1);
  }
  return out;
}

/// Total training load per sport in each bucket starting on [starts]
/// (week or month starts, ascending); a bucket runs to the next start, the
/// last one to [end] inclusive.
List<Map<LoadSport, double>> loadBySportPerBucket(
  Iterable<LocalActivity> activities,
  List<DateTime> starts,
  DateTime end,
) {
  final out = [for (final _ in starts) <LoadSport, double>{}];
  for (final a in activities) {
    final load = a.trainingLoad;
    if (load == null || load <= 0) continue;
    final i = _bucketOf(DateTime.tryParse(a.date), starts, end);
    if (i < 0) continue;
    out[i].update(
      loadSportOf(a.type),
      (v) => v + load,
      ifAbsent: () => load.toDouble(),
    );
  }
  return out;
}

int _bucketOf(DateTime? date, List<DateTime> starts, DateTime end) {
  if (date == null || starts.isEmpty) return -1;
  final d = dateOnly(date);
  if (d.isBefore(starts.first) || d.isAfter(dateOnly(end))) return -1;
  for (var i = starts.length - 1; i >= 0; i--) {
    if (!d.isBefore(starts[i])) return i;
  }
  return -1;
}

// ---------------------------------------------------------------------------
// Intensity distribution
// ---------------------------------------------------------------------------

enum DistributionModel { polarized, pyramidal, threshold, highIntensity }

class IntensityBucket {
  const IntensityBucket({
    required this.start,
    required this.low,
    required this.moderate,
    required this.high,
    required this.sessionsWithoutZones,
  });

  final DateTime start;

  /// Seconds below / in / above the threshold domain.
  final int low;
  final int moderate;
  final int high;

  /// Activities in the bucket that carried no zone times (not counted above).
  final int sessionsWithoutZones;

  int get total => low + moderate + high;
  bool get isEmpty => total == 0;

  /// The model this bucket's distribution follows, or null when there's too
  /// little zone time ([minSeconds]) to say.
  DistributionModel? model({int minSeconds = 3600}) =>
      total < minSeconds ? null : classifyDistribution(low, moderate, high);

  double? polarizationIndex({int minSeconds = 3600}) =>
      total < minSeconds ? null : polarizationIndexOf(low, moderate, high);
}

/// Treff et al.'s polarization index, `log10(f1 · f3 / f2 · 100)` over the
/// time shares of the three zones. A value above 2.0 marks a polarized
/// distribution. A share of zero in the middle zone is floored at 1% so a
/// perfectly polarized week doesn't divide by zero; null when there's no
/// high-intensity time at all (the index is undefined, not zero).
double? polarizationIndexOf(int low, int moderate, int high) {
  final total = low + moderate + high;
  if (total == 0 || high == 0 || low == 0) return null;
  final f1 = low / total;
  final f2 = math.max(moderate / total, 0.01);
  final f3 = high / total;
  return math.log(f1 / f2 * f3 * 100) / math.ln10;
}

/// Names the distribution: polarized (easy » hard » threshold, index > 2),
/// pyramidal (easy > threshold > hard), threshold (the middle zone is the
/// largest or ties the easy one) or high-intensity (hard is the largest).
DistributionModel? classifyDistribution(int low, int moderate, int high) {
  final total = low + moderate + high;
  if (total == 0) return null;
  final f1 = low / total, f2 = moderate / total, f3 = high / total;
  if (f3 > f1 && f3 > f2) return DistributionModel.highIntensity;
  if (f2 >= f1) return DistributionModel.threshold;
  if (f1 > f3 && f3 > f2) {
    final pi = polarizationIndexOf(low, moderate, high);
    return pi != null && pi > 2.0
        ? DistributionModel.polarized
        : DistributionModel.pyramidal;
  }
  return DistributionModel.pyramidal;
}

/// Time-in-zone buckets (weeks, or months when [monthly]) from [from] to
/// [to], oldest first. Weeks start on Monday; the first bucket is the one
/// containing [from].
List<IntensityBucket> intensityBuckets(
  Iterable<LocalActivity> activities, {
  required DateTime from,
  required DateTime to,
  bool monthly = false,
}) {
  final starts = bucketStarts(from, to, monthly: monthly);
  final low = List.filled(starts.length, 0);
  final mod = List.filled(starts.length, 0);
  final high = List.filled(starts.length, 0);
  final missing = List.filled(starts.length, 0);
  for (final a in activities) {
    final i = _bucketOf(DateTime.tryParse(a.date), starts, to);
    if (i < 0) continue;
    final split = intensityOf(a.raw);
    if (split == null) {
      if ((a.movingTime ?? 0) > 0) missing[i]++;
      continue;
    }
    low[i] += split.low;
    mod[i] += split.moderate;
    high[i] += split.high;
  }
  return [
    for (var i = 0; i < starts.length; i++)
      IntensityBucket(
        start: starts[i],
        low: low[i],
        moderate: mod[i],
        high: high[i],
        sessionsWithoutZones: missing[i],
      ),
  ];
}

/// Week (Monday) or month starts covering [from]..[to].
List<DateTime> bucketStarts(
  DateTime from,
  DateTime to, {
  bool monthly = false,
}) {
  final out = <DateTime>[];
  final end = dateOnly(to);
  if (monthly) {
    var d = DateTime(from.year, from.month, 1);
    while (!d.isAfter(end)) {
      out.add(d);
      d = DateTime(d.year, d.month + 1, 1);
    }
  } else {
    var d = startOfWeek(from);
    while (!d.isAfter(end)) {
      out.add(d);
      d = DateTime(d.year, d.month, d.day + 7);
    }
  }
  return out;
}

// ---------------------------------------------------------------------------
// Load safety: ramp rate, acute:chronic ratio, monotony, strain
// ---------------------------------------------------------------------------

enum RiskLevel { safe, risky, high }

/// Acute:chronic workload ratio bands (Gabbett): 0.8–1.3 is the sweet spot,
/// up to 1.5 is caution, beyond that the load jumped too fast. Below 0.8 the
/// athlete is detraining — flagged `risky` only on the low side of the ratio
/// when it is clearly under, otherwise safe.
RiskLevel acwrRisk(double ratio) {
  if (ratio > 1.5) return RiskLevel.high;
  if (ratio > 1.3) return RiskLevel.risky;
  return RiskLevel.safe;
}

/// CTL change per week: up to 5 is sustainable, 5–8 is aggressive, beyond
/// that is too fast.
RiskLevel rampRisk(double rampPerWeek) {
  if (rampPerWeek > 8) return RiskLevel.high;
  if (rampPerWeek > 5) return RiskLevel.risky;
  return RiskLevel.safe;
}

/// Foster's monotony: above 2.0 the week is dangerously uniform, 1.5–2.0 is
/// elevated.
RiskLevel monotonyRisk(double monotony) {
  if (monotony > 2.0) return RiskLevel.high;
  if (monotony > 1.5) return RiskLevel.risky;
  return RiskLevel.safe;
}

class LoadSafetyDay {
  const LoadSafetyDay({
    required this.date,
    this.acwr,
    this.rampRate,
    this.monotony,
    this.strain,
  });

  final DateTime date;

  /// 7-day mean load over 28-day mean load; null until 28 days of history.
  final double? acwr;

  /// CTL change over the last 7 days.
  final double? rampRate;

  /// 7-day mean load over its standard deviation; null on a flat-zero week
  /// or a perfectly flat one (undefined).
  final double? monotony;

  /// 7-day load × monotony.
  final double? strain;
}

/// Daily total training load (all sports) keyed by ISO date.
Map<String, double> dailyTotalLoad(Iterable<LocalActivity> activities) {
  final out = <String, double>{};
  for (final a in activities) {
    final load = a.trainingLoad;
    if (load == null || load <= 0) continue;
    out.update(a.date, (v) => v + load, ifAbsent: () => load.toDouble());
  }
  return out;
}

/// Rolling load-safety metrics for every day in [from]..[to].
///
/// [ctlByDate] (ISO date → CTL, e.g. from the wellness cache) drives the ramp
/// rate; when a date is missing it falls back to the CTL computed from the
/// activities themselves. ACWR needs 28 days of history and monotony 7, so
/// pass activities from before [from].
List<LoadSafetyDay> loadSafety(
  Iterable<LocalActivity> activities, {
  required DateTime from,
  required DateTime to,
  Map<String, double> ctlByDate = const {},
}) {
  final loads = dailyTotalLoad(activities);
  final start = dateOnly(from);
  final end = dateOnly(to);
  if (end.isBefore(start)) return const [];

  final earliest = loads.keys.isEmpty
      ? start
      : loads.keys.map(DateTime.parse).reduce((a, b) => a.isBefore(b) ? a : b);
  final first = earliest.isBefore(start) ? dateOnly(earliest) : start;

  // Day-indexed load and computed CTL from the earliest activity on.
  final days = <DateTime>[];
  final load = <double>[];
  final ctl = <double>[];
  var c = 0.0;
  for (
    var d = first;
    !d.isAfter(end);
    d = DateTime(d.year, d.month, d.day + 1)
  ) {
    final l = loads[isoDate(d)] ?? 0;
    c += (l - c) / ctlDays;
    days.add(d);
    load.add(l);
    ctl.add(c);
  }
  final firstDay = first;
  double? ctlAt(int i) {
    final provided = ctlByDate[isoDate(days[i])];
    return provided ?? ctl[i];
  }

  double mean(int endExclusive, int n) {
    var sum = 0.0;
    for (var i = endExclusive - n; i < endExclusive; i++) {
      sum += load[i];
    }
    return sum / n;
  }

  final out = <LoadSafetyDay>[];
  for (var i = 0; i < days.length; i++) {
    if (days[i].isBefore(start)) continue;
    final haveHistory = days[i].difference(firstDay).inDays;

    double? acwr;
    if (i >= 27 && haveHistory >= 27) {
      final chronic = mean(i + 1, 28);
      if (chronic > 0) acwr = mean(i + 1, 7) / chronic;
    }

    double? ramp;
    if (i >= 7) {
      final now = ctlAt(i), then = ctlAt(i - 7);
      if (now != null && then != null) ramp = now - then;
    }

    double? monotony, strain;
    if (i >= 6) {
      final week = load.sublist(i - 6, i + 1);
      final avg = week.fold<double>(0, (a, b) => a + b) / 7;
      final variance =
          week.fold<double>(0, (a, b) => a + (b - avg) * (b - avg)) / 7;
      final sd = math.sqrt(variance);
      if (avg > 0 && sd > 1e-9) {
        monotony = avg / sd;
        strain = avg * 7 * monotony;
      }
    }

    out.add(
      LoadSafetyDay(
        date: days[i],
        acwr: acwr,
        rampRate: ramp,
        monotony: monotony,
        strain: strain,
      ),
    );
  }
  return out;
}

// ---------------------------------------------------------------------------
// Aerobic decoupling and efficiency factor
// ---------------------------------------------------------------------------

class AerobicSession {
  const AerobicSession({
    required this.activity,
    required this.date,
    required this.sport,
    required this.efficiencyFactor,
    required this.decoupling,
  });

  final LocalActivity activity;
  final DateTime date;
  final LoadSport sport;

  /// Intervals.icu's EF: normalized power (or speed) per heartbeat.
  final double? efficiencyFactor;

  /// Pa:HR as a percentage; positive means heart rate drifted up against
  /// steady output.
  final double? decoupling;
}

/// A session counts as long and steady for aerobic analysis when it lasts at
/// least [minMinutes] and at least [minLowShare] of its zone time sits below
/// the first threshold. Sessions without zone times don't qualify.
bool isLongSteady(
  LocalActivity a, {
  int minMinutes = 60,
  double minLowShare = 0.7,
}) {
  if ((a.movingTime ?? 0) < minMinutes * 60) return false;
  final split = intensityOf(a.raw);
  return (split?.lowShare ?? 0) >= minLowShare;
}

/// Long steady sessions with an EF and/or decoupling figure, oldest first.
/// Swims are skipped — heart rate drift isn't recorded for them.
List<AerobicSession> aerobicSessions(
  Iterable<LocalActivity> activities, {
  int minMinutes = 60,
  double minLowShare = 0.7,
}) {
  final out = <AerobicSession>[];
  for (final a in activities) {
    final sport = loadSportOf(a.type);
    if (sport == LoadSport.swim || sport == LoadSport.other) continue;
    if (!isLongSteady(a, minMinutes: minMinutes, minLowShare: minLowShare)) {
      continue;
    }
    final ef = a.raw['icu_efficiency_factor'];
    final dec = a.raw['decoupling'];
    final efValue = ef is num && ef > 0 ? ef.toDouble() : null;
    final decValue = dec is num ? dec.toDouble() : null;
    final date = DateTime.tryParse(a.date);
    if (date == null || (efValue == null && decValue == null)) continue;
    out.add(
      AerobicSession(
        activity: a,
        date: date,
        sport: sport,
        efficiencyFactor: efValue,
        decoupling: decValue,
      ),
    );
  }
  out.sort((a, b) => a.date.compareTo(b.date));
  return out;
}

/// Decoupling bands: under 5 % the aerobic base is solid, 5–10 % is
/// developing, over 10 % the session drifted too much.
RiskLevel decouplingRisk(double percent) {
  final p = percent.abs();
  if (p > 10) return RiskLevel.high;
  if (p > 5) return RiskLevel.risky;
  return RiskLevel.safe;
}

/// Least-squares line through [values] against the time of [dates], plus how
/// much it moves per 30 days.
class LinearTrend {
  const LinearTrend({
    required this.intercept,
    required this.slopePerDay,
    required this.firstDay,
  });

  final double intercept;
  final double slopePerDay;
  final DateTime firstDay;

  double at(DateTime date) =>
      intercept + slopePerDay * date.difference(firstDay).inDays;

  double get slopePer30Days => slopePerDay * 30;
}

/// Fits a line through the non-null points; null with fewer than [minPoints]
/// or when all points fall on one day.
LinearTrend? linearTrend(
  List<DateTime> dates,
  List<double?> values, {
  int minPoints = 3,
}) {
  final xs = <double>[], ys = <double>[];
  DateTime? first;
  for (var i = 0; i < dates.length; i++) {
    final v = values[i];
    if (v == null) continue;
    first ??= dates[i];
    xs.add(dates[i].difference(first).inDays.toDouble());
    ys.add(v);
  }
  if (xs.length < minPoints) return null;
  final n = xs.length;
  final mx = xs.reduce((a, b) => a + b) / n;
  final my = ys.reduce((a, b) => a + b) / n;
  var sxx = 0.0, sxy = 0.0;
  for (var i = 0; i < n; i++) {
    sxx += (xs[i] - mx) * (xs[i] - mx);
    sxy += (xs[i] - mx) * (ys[i] - my);
  }
  if (sxx == 0) return null;
  final slope = sxy / sxx;
  return LinearTrend(
    intercept: my - slope * mx,
    slopePerDay: slope,
    firstDay: first!,
  );
}
