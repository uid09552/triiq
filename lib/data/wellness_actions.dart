import '../client/intervalls/intervalls_client.dart';
import 'intervals_session.dart';
import 'models/local_activity.dart';
import 'models/local_wellness.dart';
import 'repositories/activities_repository.dart';
import 'repositories/wellness_repository.dart';
import 'sync/auto_sync_service.dart';

/// Writes fatigue/soreness to Intervals.icu's Wellness record for one day,
/// then caches the server's response — the one path the manual action and
/// the new-activity prompt both call, so they can never disagree.
class WellnessActions {
  WellnessActions({
    IntervalsSession? session,
    WellnessRepository? wellness,
    ActivitiesRepository? activities,
  }) : _session = session ?? IntervalsSession.instance,
       _wellness = wellness ?? WellnessRepository(),
       _activities = activities ?? ActivitiesRepository();

  final IntervalsSession _session;
  final WellnessRepository _wellness;
  final ActivitiesRepository _activities;

  /// Sends how hard one session felt (RPE 1-10) to that Intervals.icu
  /// activity as a partial update (`icu_rpe`), then caches the response.
  /// Intervals.icu shows it on the activity, and the trainer reads it back
  /// (`get_activities` returns `rpe`), so plan-vs-actual can use it.
  Future<LocalActivity> setSessionRpe({
    required String activityId,
    required int rpe,
  }) async {
    final client = _session.client;
    if (client == null) throw StateError('Not connected to Intervals.icu.');
    final response = await client.getAktivittenApi().updateActivity(
      id: activityId,
      activity: Activity(icuRpe: rpe.clamp(1, 10)),
    );
    final updated = LocalActivity.fromApi(response.data!);
    await _activities.upsertAll([updated]);
    AutoSyncService.instance.notifyCacheChanged();
    return updated;
  }

  /// Sends fatigue/soreness (1-4 each) for [date] (ISO-8601) as a partial
  /// update — every other wellness field for that day is left as it is —
  /// then updates the local cache from what Intervals.icu sends back.
  Future<LocalWellness> setFeel({
    required String date,
    required int fatigue,
    required int soreness,
  }) async {
    final client = _session.client;
    final athleteId = _session.athleteId;
    if (client == null || athleteId == null) {
      throw StateError('Not connected to Intervals.icu.');
    }

    final response = await client.getWellnessApi().updateWellness(
      id: athleteId,
      date: date,
      wellness: Wellness(fatigue: fatigue, soreness: soreness),
    );
    final updated = LocalWellness.fromApi(response.data!);
    await _wellness.upsertAll([updated]);
    AutoSyncService.instance.notifyCacheChanged();
    return updated;
  }
}
