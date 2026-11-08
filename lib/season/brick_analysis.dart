import '../data/models/local_activity.dart';
import '../evaluation/session_evaluator.dart' show sportFamily;
import '../evaluation/session_streams.dart';

enum BrickKind { bikeRun, swimBike }

/// How the second leg of a brick went.
enum BrickVerdict { good, ok, rough, unknown }

enum BrickNote {
  /// Legs came round quickly (settle time under 3 min).
  settledFast,

  /// Took a long time to find the pace.
  settledSlow,

  /// The opening minutes were much slower than the rest.
  slowStart,

  /// The opening minutes cost far more heart rate per unit of speed.
  highEarlyCost,

  /// The first leg was hard (intensity ≥ 85 %), which explains a rough start.
  hardFirstLeg,

  /// Transition under 5 min.
  quickTransition,

  /// Transition over 10 min.
  longTransition,

  /// No stream for the second leg, so only the transition is judged.
  noStream,
}

class Brick {
  const Brick({required this.kind, required this.first, required this.second});

  final BrickKind kind;
  final LocalActivity first;
  final LocalActivity second;
}

class BrickAnalysis {
  const BrickAnalysis({
    required this.brick,
    required this.transitionSeconds,
    required this.verdict,
    required this.notes,
    this.settleSeconds,
    this.earlySpeedRatio,
    this.earlyHrCostRatio,
  });

  final Brick brick;

  /// Gap between the end of the first leg and the start of the second.
  final int transitionSeconds;
  final BrickVerdict verdict;
  final List<BrickNote> notes;

  /// Seconds until the rolling-minute speed reached 95 % of the steady
  /// speed that followed; null without a stream.
  final int? settleSeconds;

  /// Speed over the first 10 min ÷ speed over the rest (1.0 = no fade).
  final double? earlySpeedRatio;

  /// Heart-rate-per-speed in the first 10 min ÷ the rest.
  final double? earlyHrCostRatio;

  Map<String, dynamic> toJson() => {
    'kind': brick.kind.name,
    'first_activity_id': brick.first.id,
    'second_activity_id': brick.second.id,
    'transition_s': transitionSeconds,
    'verdict': verdict.name,
    'settle_s': settleSeconds,
    'early_speed_ratio': earlySpeedRatio == null
        ? null
        : double.parse(earlySpeedRatio!.toStringAsFixed(3)),
    'early_hr_cost_ratio': earlyHrCostRatio == null
        ? null
        : double.parse(earlyHrCostRatio!.toStringAsFixed(3)),
    'notes': [for (final n in notes) n.name],
  };
}

DateTime? _start(LocalActivity a) =>
    DateTime.tryParse(a.raw['start_date_local'] as String? ?? '');

int _elapsed(LocalActivity a) =>
    (a.raw['elapsed_time'] as num?)?.toInt() ?? a.movingTime ?? 0;

/// A brick is two sessions on one day where the second starts within
/// [maxGap] of the first ending: bike → run, or swim → bike.
const maxBrickGap = Duration(minutes: 45);

/// Bricks among [activities] (any order, any days).
List<Brick> findBricks(Iterable<LocalActivity> activities) {
  final timed = <(DateTime, LocalActivity)>[];
  for (final a in activities) {
    final s = _start(a);
    if (s != null && _elapsed(a) > 0) timed.add((s, a));
  }
  timed.sort((x, y) => x.$1.compareTo(y.$1));
  final bricks = <Brick>[];
  for (var i = 0; i + 1 < timed.length; i++) {
    final (s1, a) = timed[i];
    final (s2, b) = timed[i + 1];
    if (s1.year != s2.year || s1.month != s2.month || s1.day != s2.day) {
      continue;
    }
    final end = s1.add(Duration(seconds: _elapsed(a)));
    final gap = s2.difference(end);
    if (gap.isNegative && gap < const Duration(minutes: -2)) continue;
    if (gap > maxBrickGap) continue;
    final fa = sportFamily(a.type);
    final fb = sportFamily(b.type);
    final kind = fa == 'ride' && fb == 'run'
        ? BrickKind.bikeRun
        : fa == 'swim' && fb == 'ride'
        ? BrickKind.swimBike
        : null;
    if (kind != null) bricks.add(Brick(kind: kind, first: a, second: b));
  }
  return bricks;
}

/// The brick [activity] is a part of, if any, among [sameDay].
Brick? brickFor(LocalActivity activity, Iterable<LocalActivity> sameDay) {
  for (final b in findBricks(sameDay)) {
    if (b.first.id == activity.id || b.second.id == activity.id) return b;
  }
  return null;
}

int _transition(Brick b) {
  final s1 = _start(b.first)!;
  final s2 = _start(b.second)!;
  final gap = s2.difference(s1.add(Duration(seconds: _elapsed(b.first))));
  return gap.inSeconds < 0 ? 0 : gap.inSeconds;
}

({double early, double rest, double hrEarly, double hrRest, int? settle})?
_runMetrics(SessionStreams streams) {
  final time = streams.series['time'];
  final speed = streams.series['velocity_smooth'];
  final hr = streams.series['heartrate'];
  if (time == null || speed == null) return null;
  final n = [time.length, speed.length].reduce((a, b) => a < b ? a : b);
  if (n < 30) return null;
  final total = time[n - 1] ?? 0;
  if (total < 20 * 60) return null;

  double mean(List<double?> v, double from, double to) {
    var sum = 0.0;
    var c = 0;
    for (var i = 0; i < n; i++) {
      final t = time[i];
      final x = v[i];
      if (t == null || x == null || t < from || t >= to) continue;
      sum += x;
      c++;
    }
    return c == 0 ? double.nan : sum / c;
  }

  final early = mean(speed, 0, 600);
  final rest = mean(speed, 600, total + 1);
  if (early.isNaN || rest.isNaN || rest <= 0) return null;
  var hrEarly = double.nan;
  var hrRest = double.nan;
  if (hr != null && hr.length >= n) {
    hrEarly = mean(hr, 0, 600);
    hrRest = mean(hr, 600, total + 1);
  }
  // Settle: first minute whose mean speed reaches 95 % of the steady speed.
  int? settle;
  for (var start = 0.0; start + 60 <= 600; start += 15) {
    final m = mean(speed, start, start + 60);
    if (!m.isNaN && m >= 0.95 * rest) {
      settle = start.round();
      break;
    }
  }
  settle ??= 600;
  return (
    early: early,
    rest: rest,
    hrEarly: hrEarly,
    hrRest: hrRest,
    settle: settle,
  );
}

/// Judges a brick: the transition from the two start times, the run's
/// first 10 minutes against the rest from [secondStreams] (settle time,
/// speed fade, heart-rate cost) and, if the first leg was very hard, says
/// so. Pure; pass null streams when none are cached.
BrickAnalysis analyseBrick(Brick brick, SessionStreams? secondStreams) {
  final transition = _transition(brick);
  final notes = <BrickNote>[];
  if (transition <= 300) notes.add(BrickNote.quickTransition);
  if (transition > 600) notes.add(BrickNote.longTransition);

  final m = secondStreams == null ? null : _runMetrics(secondStreams);
  if (m == null) {
    notes.add(BrickNote.noStream);
    return BrickAnalysis(
      brick: brick,
      transitionSeconds: transition,
      verdict: BrickVerdict.unknown,
      notes: notes,
    );
  }
  final speedRatio = m.early / m.rest;
  double? hrCost;
  if (!m.hrEarly.isNaN && !m.hrRest.isNaN && m.early > 0) {
    hrCost = (m.hrEarly / m.early) / (m.hrRest / m.rest);
  }
  final settle = m.settle!;
  final intensity = (brick.first.raw['icu_intensity'] as num?)?.toDouble();
  final hardFirst = intensity != null && intensity >= 85;

  BrickVerdict verdict;
  if (settle <= 180 && speedRatio >= 0.95) {
    verdict = BrickVerdict.good;
    notes.add(BrickNote.settledFast);
  } else if (settle <= 480 && speedRatio >= 0.90) {
    verdict = BrickVerdict.ok;
  } else {
    verdict = BrickVerdict.rough;
    notes.add(BrickNote.settledSlow);
  }
  if (speedRatio < 0.93) notes.add(BrickNote.slowStart);
  if (hrCost != null && hrCost > 1.08) notes.add(BrickNote.highEarlyCost);
  if (hardFirst && verdict != BrickVerdict.good)
    notes.add(BrickNote.hardFirstLeg);

  return BrickAnalysis(
    brick: brick,
    transitionSeconds: transition,
    verdict: verdict,
    notes: notes,
    settleSeconds: settle,
    earlySpeedRatio: speedRatio,
    earlyHrCostRatio: hrCost,
  );
}

/// Median of the settle times and transitions across analysed bricks, for
/// a trend line ("legs settle in 2:30 now, 4:00 a month ago").
({int? settle, int? transition}) medians(Iterable<BrickAnalysis> items) {
  int? median(List<int> v) {
    if (v.isEmpty) return null;
    v.sort();
    return v[v.length ~/ 2];
  }

  return (
    settle: median([
      for (final a in items)
        if (a.settleSeconds != null) a.settleSeconds!,
    ]),
    transition: median([for (final a in items) a.transitionSeconds]),
  );
}
