import '../client/intervalls/intervalls_client.dart' show SportSettings;
import 'performance_curves.dart';

/// Whether a suggestion raises or lowers the threshold.
enum ThresholdDirection { up, down }

/// What data a suggestion's candidate came from — the UI localizes this
/// into the confirm sheet's explanation (see docs/okf.md); kept as data
/// rather than pre-rendered English so it can be shown in German too.
enum ThresholdBasisKind {
  /// Ride: this season's power-curve model fit.
  rideSeasonModel,

  /// Ride: the last-42-days power-curve model fit.
  rideRecentModel,

  /// Run: this season's ~60-minute best effort, used directly.
  runSeason60Min,

  /// Run: this season's ~40-minute best effort, scaled toward a
  /// sustainable 60-minute pace (heuristic).
  runSeason40MinHeuristic,

  /// Run: the last-42-days ~60-minute best effort, used directly.
  runRecent60Min,

  /// Run: the last-42-days ~40-minute best effort, scaled (heuristic).
  runRecent40MinHeuristic,

  /// Swim: CSS from this season's 400 m / 200 m bests.
  swimSeasonCss,

  /// Swim: CSS from the last-42-days 400 m / 200 m bests.
  swimRecentCss,
}

/// A suggested change to one sport's threshold (ride FTP, run/swim
/// threshold pace), derived from the cached performance curves against the
/// athlete's current Intervals.icu setting. Pure data — see
/// `SportSettingsService` for writing one, and the Performance-screen UI
/// for showing it.
class ThresholdSuggestion {
  const ThresholdSuggestion({
    required this.sport,
    required this.field,
    required this.currentValue,
    required this.candidateValue,
    required this.direction,
    required this.basisKind,
    this.effortActivityIds = const [],
  });

  final CurveSport sport;

  /// The `SportSettings` field this changes: `'ftp'` for ride, or
  /// `'thresholdPace'` for run/swim (stored as metres/second).
  final String field;

  final double currentValue;
  final double candidateValue;
  final ThresholdDirection direction;

  /// What produced [candidateValue] — the UI turns this (plus
  /// [changeFraction]) into the confirm sheet's explanation, localized.
  final ThresholdBasisKind basisKind;

  /// Activities whose efforts produced [candidateValue], for "efforts
  /// used" in the confirm sheet. Empty when the candidate comes from a
  /// model fit rather than a specific effort (ride FTP).
  final List<String> effortActivityIds;

  /// Signed fractional change, e.g. `0.034` for +3.4%.
  double get changeFraction => (candidateValue - currentValue) / currentValue;
}

/// A suggestion the athlete dismissed, read back so the same (or a close)
/// candidate doesn't resurface for 30 days — `SharedPreferences`-backed in
/// the service layer; this module only consumes it.
class ThresholdDismissal {
  const ThresholdDismissal({required this.candidateValue, required this.at});

  final double candidateValue;
  final DateTime at;
}

/// +3%: how far a derived value must beat the current setting to suggest
/// raising it.
const thresholdUpFraction = 0.03;

/// −5%: how far a derived value must fall below the current setting to
/// suggest lowering it — only ever from recent data, never from an absent
/// curve (see the `curves == null` guards below).
const thresholdDownFraction = 0.05;

/// How long a dismissal suppresses a suggestion for the same sport and
/// direction, unless the candidate has moved by [_dismissRetrigger] since.
const _dismissWindow = Duration(days: 30);
const _dismissRetrigger = 0.03;

/// Ride FTP: an **up** suggestion from the current season's model fit
/// (`s0`), a **down** suggestion from the last-42-days model fit. The
/// curves API has no custom rolling window, so `42d` stands in for
/// design.md decision 3's "a maximal effort in the last ~30 days" — the
/// closest period Intervals.icu actually exposes. Unlike the run/swim
/// derivations, a model fit isn't tied to one activity, so the 90-day
/// effort-age check ([_recent]) can't apply here; `s0`/`42d` themselves
/// stand in for "within 90 days" / "within 30 days".
List<ThresholdSuggestion> rideFtpSuggestions({
  required SportSettings? settings,
  required PerformanceCurves? curves,
  required DateTime now,
  ThresholdDismissal? upDismissal,
  ThresholdDismissal? downDismissal,
}) {
  final current = settings?.ftp?.toDouble();
  if (current == null || current <= 0 || curves == null) return const [];

  final suggestions = <ThresholdSuggestion>[];

  final seasonFtp = curves.period('s0')?.model?.ftp;
  if (seasonFtp != null) {
    final frac = (seasonFtp - current) / current;
    if (frac >= thresholdUpFraction &&
        _notDismissed(upDismissal, seasonFtp, now)) {
      suggestions.add(
        ThresholdSuggestion(
          sport: CurveSport.ride,
          field: 'ftp',
          currentValue: current,
          candidateValue: seasonFtp.roundToDouble(),
          direction: ThresholdDirection.up,
          basisKind: ThresholdBasisKind.rideSeasonModel,
        ),
      );
    }
  }

  final recentFtp = curves.period('42d')?.model?.ftp;
  if (recentFtp != null) {
    final frac = (recentFtp - current) / current;
    if (frac <= -thresholdDownFraction &&
        _notDismissed(downDismissal, recentFtp, now)) {
      suggestions.add(
        ThresholdSuggestion(
          sport: CurveSport.ride,
          field: 'ftp',
          currentValue: current,
          candidateValue: recentFtp.roundToDouble(),
          direction: ThresholdDirection.down,
          basisKind: ThresholdBasisKind.rideRecentModel,
        ),
      );
    }
  }
  return suggestions;
}

/// Run threshold pace: the ~60-minute best effort if the curve has one,
/// else the ~40-minute best scaled down by 1.02 — a 40-minute max effort
/// runs faster than a sustainable 60-minute threshold pace, so the
/// estimate is nudged toward threshold. Labelled a heuristic via
/// [ThresholdBasisKind] either way (design.md decision 4).
List<ThresholdSuggestion> runThresholdPaceSuggestions({
  required SportSettings? settings,
  required PerformanceCurves? curves,
  required DateTime now,
  ThresholdDismissal? upDismissal,
  ThresholdDismissal? downDismissal,
}) {
  final current = settings?.thresholdPace;
  if (current == null || current <= 0 || curves == null) return const [];

  final suggestions = <ThresholdSuggestion>[];

  final season = _runDerivedPace(curves, curves.period('s0'), now);
  if (season != null) {
    final frac = (season.speed - current) / current;
    if (frac >= thresholdUpFraction &&
        _notDismissed(upDismissal, season.speed, now)) {
      suggestions.add(
        ThresholdSuggestion(
          sport: CurveSport.run,
          field: 'thresholdPace',
          currentValue: current,
          candidateValue: season.speed,
          direction: ThresholdDirection.up,
          basisKind: season.heuristic
              ? ThresholdBasisKind.runSeason40MinHeuristic
              : ThresholdBasisKind.runSeason60Min,
          effortActivityIds: [season.activityId].whereType<String>().toList(),
        ),
      );
    }
  }

  final recent = _runDerivedPace(curves, curves.period('42d'), now);
  if (recent != null) {
    final frac = (recent.speed - current) / current;
    if (frac <= -thresholdDownFraction &&
        _notDismissed(downDismissal, recent.speed, now)) {
      suggestions.add(
        ThresholdSuggestion(
          sport: CurveSport.run,
          field: 'thresholdPace',
          currentValue: current,
          candidateValue: recent.speed,
          direction: ThresholdDirection.down,
          basisKind: recent.heuristic
              ? ThresholdBasisKind.runRecent40MinHeuristic
              : ThresholdBasisKind.runRecent60Min,
          effortActivityIds: [recent.activityId].whereType<String>().toList(),
        ),
      );
    }
  }
  return suggestions;
}

/// Swim CSS from the 400 m and 200 m bests: `(t400 - t200) / 2` is the
/// critical-swim-speed pace in seconds per 100 m, converted to the m/s
/// speed `thresholdPace` is stored as.
List<ThresholdSuggestion> swimCssSuggestions({
  required SportSettings? settings,
  required PerformanceCurves? curves,
  required DateTime now,
  ThresholdDismissal? upDismissal,
  ThresholdDismissal? downDismissal,
}) {
  final current = settings?.thresholdPace;
  if (current == null || current <= 0 || curves == null) return const [];

  final suggestions = <ThresholdSuggestion>[];

  final season = _swimCss(curves, curves.period('s0'), now);
  if (season != null) {
    final frac = (season.speed - current) / current;
    if (frac >= thresholdUpFraction &&
        _notDismissed(upDismissal, season.speed, now)) {
      suggestions.add(
        ThresholdSuggestion(
          sport: CurveSport.swim,
          field: 'thresholdPace',
          currentValue: current,
          candidateValue: season.speed,
          direction: ThresholdDirection.up,
          basisKind: ThresholdBasisKind.swimSeasonCss,
          effortActivityIds: season.activityIds,
        ),
      );
    }
  }

  final recent = _swimCss(curves, curves.period('42d'), now);
  if (recent != null) {
    final frac = (recent.speed - current) / current;
    if (frac <= -thresholdDownFraction &&
        _notDismissed(downDismissal, recent.speed, now)) {
      suggestions.add(
        ThresholdSuggestion(
          sport: CurveSport.swim,
          field: 'thresholdPace',
          currentValue: current,
          candidateValue: recent.speed,
          direction: ThresholdDirection.down,
          basisKind: ThresholdBasisKind.swimRecentCss,
          effortActivityIds: recent.activityIds,
        ),
      );
    }
  }
  return suggestions;
}

/// All threshold suggestions across the three sports for one set of
/// current settings and cached curves.
List<ThresholdSuggestion> evaluateThresholdSuggestions({
  required SportSettings? rideSettings,
  required PerformanceCurves? ridePowerCurves,
  required SportSettings? runSettings,
  required PerformanceCurves? runPaceCurves,
  required SportSettings? swimSettings,
  required PerformanceCurves? swimPaceCurves,
  required DateTime now,
  Map<(CurveSport, ThresholdDirection), ThresholdDismissal>? dismissals,
}) {
  ThresholdDismissal? dismissal(CurveSport sport, ThresholdDirection dir) =>
      dismissals?[(sport, dir)];

  return [
    ...rideFtpSuggestions(
      settings: rideSettings,
      curves: ridePowerCurves,
      now: now,
      upDismissal: dismissal(CurveSport.ride, ThresholdDirection.up),
      downDismissal: dismissal(CurveSport.ride, ThresholdDirection.down),
    ),
    ...runThresholdPaceSuggestions(
      settings: runSettings,
      curves: runPaceCurves,
      now: now,
      upDismissal: dismissal(CurveSport.run, ThresholdDirection.up),
      downDismissal: dismissal(CurveSport.run, ThresholdDirection.down),
    ),
    ...swimCssSuggestions(
      settings: swimSettings,
      curves: swimPaceCurves,
      now: now,
      upDismissal: dismissal(CurveSport.swim, ThresholdDirection.up),
      downDismissal: dismissal(CurveSport.swim, ThresholdDirection.down),
    ),
  ];
}

({double speed, String? activityId, bool heuristic})? _runDerivedPace(
  PerformanceCurves curves,
  CurvePeriod? period,
  DateTime now,
) {
  final sixty = _recent(curves, _pointNearDuration(period, 3600), now);
  if (sixty != null) {
    return (
      speed: plotValue(CurveMetric.pace, sixty),
      activityId: sixty.activityId,
      heuristic: false,
    );
  }
  final forty = _recent(curves, _pointNearDuration(period, 2400), now);
  if (forty != null) {
    return (
      speed: plotValue(CurveMetric.pace, forty) / 1.02,
      activityId: forty.activityId,
      heuristic: true,
    );
  }
  return null;
}

({double speed, List<String> activityIds})? _swimCss(
  PerformanceCurves curves,
  CurvePeriod? period,
  DateTime now,
) {
  if (period == null) return null;
  final p400 = _recent(curves, period.at(400), now);
  final p200 = _recent(curves, period.at(200), now);
  if (p400 == null || p200 == null) return null;
  final cssSecondsPer100m = (p400.value - p200.value) / 2;
  if (cssSecondsPer100m <= 0) return null;
  return (
    speed: 100 / cssSecondsPer100m,
    activityIds: [
      p400.activityId,
      p200.activityId,
    ].whereType<String>().toList(),
  );
}

/// Window the "deriving thresholds" requirement sets: a candidate only
/// comes from efforts no older than this.
const _candidateWindow = Duration(days: 90);

/// Drops [point] when its activity is known and older than
/// [_candidateWindow]. A point with no matching [CurveActivity] (its date
/// is unknown) is kept rather than penalised for missing metadata.
CurvePoint? _recent(
  PerformanceCurves curves,
  CurvePoint? point,
  DateTime now,
) {
  if (point == null) return null;
  final dateStr = curves.activities[point.activityId]?.date;
  if (dateStr == null) return point;
  final date = DateTime.tryParse(dateStr);
  if (date == null) return point;
  return now.difference(date) <= _candidateWindow ? point : null;
}

/// The point whose effort *time* (not distance) is closest to
/// [targetSeconds], within 5% — the pace curve is indexed by distance, so
/// "the 60-minute effort" has to be found this way rather than looked up
/// directly like [CurvePeriod.at].
CurvePoint? _pointNearDuration(CurvePeriod? period, double targetSeconds) {
  if (period == null) return null;
  CurvePoint? best;
  var bestGap = double.infinity;
  for (final p in period.points) {
    final gap = (p.value - targetSeconds).abs();
    if (gap <= targetSeconds * 0.05 && gap < bestGap) {
      best = p;
      bestGap = gap;
    }
  }
  return best;
}

bool _notDismissed(
  ThresholdDismissal? dismissal,
  double candidate,
  DateTime now,
) {
  if (dismissal == null) return true;
  if (now.difference(dismissal.at) >= _dismissWindow) return true;
  final moved =
      (candidate - dismissal.candidateValue).abs() /
      dismissal.candidateValue.abs();
  return moved >= _dismissRetrigger;
}
