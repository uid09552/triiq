import '../data/repositories/activities_repository.dart';
import '../data/repositories/sync_state_repository.dart';
import '../data/repositories/wellness_repository.dart';
import '../util/dates.dart';

/// What the plan engine needs from the local cache: the completed weekly
/// load just before a plan starts, and the CTL to project from.
class PlanInputs {
  const PlanInputs({required this.weeklyLoads, required this.currentCtl});

  /// Completed weekly totals (TSS), oldest first, for the weeks right before
  /// the plan; `null` when the cache doesn't reach back far enough to know.
  final List<double>? weeklyLoads;
  final double? currentCtl;
}

class PlanInputsLoader {
  PlanInputsLoader({
    ActivitiesRepository? activities,
    WellnessRepository? wellness,
    SyncStateRepository? syncState,
  }) : _activities = activities ?? ActivitiesRepository(),
       _wellness = wellness ?? WellnessRepository(),
       _syncState = syncState ?? SyncStateRepository();

  final ActivitiesRepository _activities;
  final WellnessRepository _wellness;
  final SyncStateRepository _syncState;

  /// Gathers [weeks] full Monday-Sunday weeks ending the day before
  /// [planStart]. Weeks only count as known when the activity cache covers
  /// them — a week of zero because it was never synced would silently drag
  /// the baseline down.
  Future<PlanInputs> load(DateTime planStart, {int weeks = 4}) async {
    final monday = startOfWeek(planStart);
    final firstWeek = monday.subtract(Duration(days: 7 * weeks));
    final lastDay = monday.subtract(const Duration(days: 1));

    final state = await _syncState.get('activities');
    final covered =
        state != null && state.oldest.compareTo(isoDate(firstWeek)) <= 0;

    List<double>? loads;
    if (covered) {
      final activities = await _activities.getRange(
        isoDate(firstWeek),
        isoDate(lastDay),
      );
      loads = List.filled(weeks, 0.0);
      for (final activity in activities) {
        final date = DateTime.tryParse(activity.date);
        final load = activity.trainingLoad;
        if (date == null || load == null) continue;
        final index = date.difference(firstWeek).inDays ~/ 7;
        if (index >= 0 && index < weeks) loads[index] += load;
      }
    }

    // The newest CTL on or before the day the plan starts.
    final wellness = await _wellness.getRange(
      isoDate(lastDay.subtract(const Duration(days: 14))),
      isoDate(lastDay),
    );
    double? ctl;
    for (final record in wellness) {
      if (record.ctl != null) ctl = record.ctl;
    }

    return PlanInputs(weeklyLoads: loads, currentCtl: ctl);
  }
}
