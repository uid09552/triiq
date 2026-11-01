import 'intervals_session.dart';
import 'threshold_dismissals_store.dart';
import '../evaluation/performance_curves.dart';
import '../evaluation/threshold_suggestions.dart';

/// Gathers what [evaluateThresholdSuggestions] needs — cached curves,
/// current settings, stored dismissals — and returns today's suggestions.
/// Reads only the cache (like the load tiles and the model card): nothing
/// here fetches, so it works offline and never forces a network call just
/// because a suggestion card is on screen.
class ThresholdSuggestionsService {
  ThresholdSuggestionsService({
    PerformanceCurvesRepository? curves,
    IntervalsSession? session,
    ThresholdDismissalsStore? dismissals,
    DateTime Function()? clock,
  }) : _curves = curves ?? PerformanceCurvesRepository(),
       _session = session ?? IntervalsSession.instance,
       _dismissals = dismissals ?? ThresholdDismissalsStore.instance,
       _clock = clock ?? DateTime.now;

  final PerformanceCurvesRepository _curves;
  final IntervalsSession _session;
  final ThresholdDismissalsStore _dismissals;
  final DateTime Function() _clock;

  Future<List<ThresholdSuggestion>> load() async {
    if (!_dismissals.isLoaded) await _dismissals.load();

    final ridePower = await _curves.cached(CurveSport.ride, CurveMetric.power);
    final runPace = await _curves.cached(CurveSport.run, CurveMetric.pace);
    final swimPace = await _curves.cached(CurveSport.swim, CurveMetric.pace);

    return evaluateThresholdSuggestions(
      rideSettings: _session.settingsForSport(CurveSport.ride.apiType),
      ridePowerCurves: ridePower,
      runSettings: _session.settingsForSport(CurveSport.run.apiType),
      runPaceCurves: runPace,
      swimSettings: _session.settingsForSport(CurveSport.swim.apiType),
      swimPaceCurves: swimPace,
      now: _clock(),
      dismissals: _dismissals.all,
    );
  }
}
