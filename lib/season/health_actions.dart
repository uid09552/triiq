import '../data/intervals_workout_service.dart';
import '../plan/plan_actions.dart';
import 'illness_mode.dart';

/// The easy-aerobic step line for a replacement session, in Intervals.icu
/// syntax (`Z2` = the athlete's zone 2 for that sport).
String easyDescription(int minutes) => '- ${minutes}m Z2';

/// The draft that replaces [change]'s session: shorter and easy, in the
/// same sport or the cross-training one.
PlannedWorkoutDraft draftFor(
  ReturnChange change, {
  String Function(String sport, bool cross)? name,
}) {
  final e = change.session;
  final cross = change.action == ReturnAction.crossTrain;
  final sport = cross ? (change.toSport ?? 'Ride') : (e.type ?? 'Run');
  final minutes = change.minutes ?? ((e.plannedTime ?? 1800) / 60).round();
  return PlannedWorkoutDraft(
    name:
        name?.call(sport, cross) ??
        (cross ? 'Easy $sport (cross-training)' : 'Easy $sport (return)'),
    sport: sport,
    description: easyDescription(minutes),
    date: DateTime.parse(e.date),
    durationSeconds: minutes * 60,
    load: change.load,
    indoor: e.indoor,
  );
}

/// Applies the proposed changes one by one after the athlete confirmed.
/// Stops at the first failure and returns how many were done, so what is
/// left can be retried; nothing is half-applied per session (each is an
/// upstream-first replace or delete).
class HealthActions {
  HealthActions({PlanActions? actions}) : _actions = actions ?? PlanActions();

  final PlanActions _actions;

  Future<void> apply(ReturnChange change) async {
    switch (change.action) {
      case ReturnAction.rest:
        await _actions.removePlanned(change.session);
      case ReturnAction.easier || ReturnAction.crossTrain:
        await _actions.replaceSession(change.session, draftFor(change));
    }
  }

  Future<({int done, Object? error})> applyAll(
    Iterable<ReturnChange> changes,
  ) async {
    var done = 0;
    for (final c in changes) {
      try {
        await apply(c);
        done++;
      } catch (e) {
        return (done: done, error: e);
      }
    }
    return (done: done, error: null);
  }
}
