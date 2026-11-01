import '../client/intervalls/intervalls_client.dart';
import '../evaluation/performance_curves.dart' show CurveSport;
import '../evaluation/threshold_suggestions.dart';
import 'intervals_session.dart';

/// Writes a confirmed threshold change to Intervals.icu sport settings.
///
/// The second place in the app that writes upstream rather than reading
/// (the first is [IntervalsWorkoutService](intervals_workout_service.dart))
/// — and the first that changes *settings* rather than calendar data, so
/// the payload stays deliberately minimal: only the field the athlete
/// confirmed, nothing else re-sent. That minimality is only safe because
/// `test/sync_live_test.dart`'s live gate proved the server treats this PUT
/// as a partial update, not a full replace (see design.md decision 1,
/// openspec/changes/threshold-updates).
class SportSettingsService {
  SportSettingsService({IntervalsSession? session})
    : _session = session ?? IntervalsSession.instance;

  final IntervalsSession _session;

  /// Writes [suggestion]'s candidate value to Intervals.icu, then refreshes
  /// the cached athlete so `settingsForSport`/the model card reflect it.
  /// [recalcHrZones] is the confirm sheet's opt-in; off by default since a
  /// threshold change alone shouldn't silently move HR zones too.
  Future<SportSettings> apply(
    ThresholdSuggestion suggestion, {
    bool recalcHrZones = false,
  }) => _write(
    suggestion.sport,
    suggestion.field,
    suggestion.candidateValue,
    recalcHrZones: recalcHrZones,
  );

  /// Restores the value [suggestion] had before [apply] — the confirm
  /// sheet's Undo, writing the same way so the account ends up exactly as
  /// it started. Never recalculates HR zones: that was the athlete's
  /// explicit choice on the original apply, not something to repeat or
  /// reverse here.
  Future<SportSettings> undo(ThresholdSuggestion suggestion) =>
      _write(suggestion.sport, suggestion.field, suggestion.currentValue);

  Future<SportSettings> _write(
    CurveSport sport,
    String field,
    double value, {
    bool recalcHrZones = false,
  }) async {
    final client = _session.client;
    final athleteId = _session.athleteId;
    if (client == null || athleteId == null) {
      throw StateError('Not connected to Intervals.icu.');
    }
    final id = _session.settingsForSport(sport.apiType)?.id;
    if (id == null) {
      throw StateError('No ${sport.apiType} settings to update.');
    }

    final payload = switch (field) {
      'ftp' => SportSettings(id: id, ftp: value.round()),
      'thresholdPace' => SportSettings(id: id, thresholdPace: value),
      _ => throw ArgumentError.value(
        field,
        'field',
        'Unknown threshold field.',
      ),
    };

    final response = await client.getSportApi().updateSettings(
      athleteId: athleteId,
      id: id.toString(),
      recalcHrZones: recalcHrZones,
      sportSettings: payload,
    );
    final updated = response.data;
    if (updated == null) {
      throw StateError('Intervals.icu did not return the updated settings.');
    }

    // Only on success: a failed write must leave the cached (old) settings
    // exactly as they were, so the UI shows the write failed rather than a
    // value that was never actually saved.
    await _session.refreshAthlete();
    return updated;
  }
}
