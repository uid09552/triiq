import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/intervals_session.dart';
import '../data/intervals_workout_service.dart';
import '../data/pending_writes.dart';
import '../data/models/local_event.dart';
import '../data/repositories/activities_repository.dart';
import '../data/repositories/events_repository.dart';
import '../data/repositories/plans_repository.dart';
import '../data/sync/auto_sync_service.dart';
import '../data/sync/sync_service.dart';
import '../data/sync/sync_settings.dart';
import '../evaluation/session_evaluator.dart';
import '../util/dates.dart';
import 'plan_changes.dart';
import 'plan_models.dart';
import 'plan_writer.dart';

/// How a replacement went.
enum ReplaceOutcome {
  /// The old session is gone and the new one is in its place (upstream too
  /// when it was there).
  replaced,

  /// A plan session that only lived in TriIQ was changed there.
  replacedLocally,

  /// The new workout was created but the old Intervals.icu event could not
  /// be deleted: both exist now.
  bothExist,

  /// Intervals.icu was unreachable: the change is made locally and the
  /// upstream replace is queued for when it is back.
  queued,
}

/// Replacing was refused before anything changed.
class ReplaceRefusedException implements Exception {
  const ReplaceRefusedException(this.reason, [this.detail]);

  final ReplaceRefusal reason;

  /// Extra context, e.g. the validation message for [ReplaceRefusal.invalid].
  final String? detail;

  @override
  String toString() => 'ReplaceRefusedException(${reason.name})';
}

enum ReplaceRefusal {
  /// The session is in Intervals.icu but sending is off or there is no
  /// connection: changing it only locally would leave the old event behind.
  sentButCannotSend,

  /// An Intervals.icu event can only be replaced while connected.
  notConnected,

  /// The planned session no longer exists.
  missing,

  /// The session is in the past (or today's date has already gone by for
  /// the target): history is not rewritten.
  past,

  /// The target date is outside the plan's weeks.
  outsidePlan,

  /// The goal edit doesn't pass validation.
  invalid,
}

/// Changes to the planned calendar that Train Now makes on the athlete's
/// behalf, after they confirmed them. Upstream first, local on success, so
/// a failure never leaves the local plan describing something Intervals.icu
/// doesn't have.
class PlanActions {
  PlanActions({
    PlannedWorkoutWriter? workouts,
    PlansRepository? plans,
    EventsRepository? events,
    ActivitiesRepository? activities,
    GoalStore? goals,
    bool Function()? sendEnabled,
    bool Function()? connected,
    PendingWritesService? queue,
    Future<void> Function(DateTime day)? resync,
    DateTime Function()? clock,
  }) : _workouts = workouts ?? QueuedWorkoutWriter(),
       _plans = plans ?? PlansRepository(),
       _events = events ?? EventsRepository(),
       _activities = activities ?? ActivitiesRepository(),
       _goals = goals ?? GoalStore(),
       _clock = clock ?? DateTime.now,
       _queue = queue ?? PendingWritesService.instance,
       _sendEnabled =
           sendEnabled ?? (() => SyncSettings.instance.sendPlanToIntervals),
       _connected = connected ?? (() => IntervalsSession.instance.isConnected),
       _resync = resync ?? _resyncMonth;

  final PlannedWorkoutWriter _workouts;
  final PendingWritesService _queue;
  final PlansRepository _plans;
  final EventsRepository _events;
  final ActivitiesRepository _activities;
  final GoalStore _goals;
  final DateTime Function() _clock;
  final bool Function() _sendEnabled;
  final bool Function() _connected;
  final Future<void> Function(DateTime day) _resync;

  /// Low-intensity share assumed for a replacement whose zone split is
  /// unknown, so the plan's 80/20 check stays defined.
  static const assumedLowShare = 0.8;

  static const estimatedNote = '(TSS estimated from the replaced session)';

  /// Puts [draft] in [planned]'s place: a TriIQ plan session is changed in
  /// place (same plan, week, date), an Intervals.icu event is swapped for
  /// a new workout. Throws [ReplaceRefusedException] when it can't be done
  /// cleanly; any other error means nothing local changed.
  Future<ReplaceOutcome> replaceSession(
    LocalEvent planned,
    PlannedWorkoutDraft draft,
  ) async {
    final outcome = planned.isPlanSession
        ? await _replacePlanSession(planned.planSessionId!, draft)
        : await _replaceEvent(planned, draft);
    PlanChanges.instance.notify();
    AutoSyncService.instance.notifyCacheChanged();
    return outcome;
  }

  Future<ReplaceOutcome> _replacePlanSession(
    int sessionId,
    PlannedWorkoutDraft draft,
  ) async {
    final session = await _plans.getSession(sessionId);
    if (session == null) {
      throw const ReplaceRefusedException(ReplaceRefusal.missing);
    }
    final oldEventId = session.intervalsEventId;
    final minutes = draft.durationSeconds == null
        ? session.minutes
        : (draft.durationSeconds! / 60).round();
    final estimated = draft.load == null;
    final load = draft.load ?? session.load;
    final description = estimated
        ? '${draft.description}\n\n$estimatedNote'
        : draft.description;

    Future<void> store(String? eventId, PlanSessionStatus status) =>
        _plans.replaceSessionContent(
          sessionId,
          sport: draft.sport,
          name: draft.name,
          minutes: minutes,
          load: load,
          lowMinutes: minutes * assumedLowShare,
          description: description,
          intervalsEventId: eventId,
          status: status,
        );

    if (oldEventId == null) {
      await store(null, PlanSessionStatus.planned);
      return ReplaceOutcome.replacedLocally;
    }
    if (!_sendEnabled()) {
      throw const ReplaceRefusedException(ReplaceRefusal.sentButCannotSend);
    }

    final planId = await _plans.planIdOfSession(sessionId);
    final externalId = planId == null
        ? null
        : '${PlanWriter.tagFor(planId)}-$sessionId';
    final sendDraft = PlannedWorkoutDraft(
      name: draft.name,
      sport: draft.sport,
      description: description,
      date: session.date,
      durationSeconds: minutes * 60,
      load: load,
      indoor: draft.indoor,
      tags: planId == null ? null : [PlanWriter.tagFor(planId)],
      externalId: externalId,
    );
    if (_connected()) {
      try {
        final created = await _workouts.createPlannedWorkout(sendDraft);
        // The new event is the session from here on, whatever the delete
        // does.
        await store(created.id?.toString(), PlanSessionStatus.created);
        final deleted = await _deleteUpstream(oldEventId);
        await _safeResync(session.date);
        return deleted ? ReplaceOutcome.replaced : ReplaceOutcome.bothExist;
      } catch (error) {
        if (!isOfflineError(error)) rethrow;
      }
    }
    // Offline: the session shows the new content now; the upstream replace
    // (create the new event, delete the old one) waits in the queue.
    await store(null, PlanSessionStatus.planned);
    await _events.deleteById(oldEventId);
    await _queue.enqueue(PendingKind.replaceWorkout, {
      'old_event_id': oldEventId,
      'plan_session_id': sessionId,
      'draft': QueuedWorkoutWriter.draftToJson(sendDraft),
    });
    return ReplaceOutcome.queued;
  }

  Future<ReplaceOutcome> _replaceEvent(
    LocalEvent planned,
    PlannedWorkoutDraft draft,
  ) async {
    if (_connected()) {
      try {
        await _workouts.createPlannedWorkout(draft);
        final deleted = await _deleteUpstream(planned.id);
        if (deleted) await _events.deleteById(planned.id);
        await _safeResync(draft.date);
        return deleted ? ReplaceOutcome.replaced : ReplaceOutcome.bothExist;
      } catch (error) {
        if (!isOfflineError(error)) rethrow;
      }
    }
    // Offline: show the new workout as a placeholder in the calendar and
    // queue the real replace.
    final placeholderId = 'pending:${_clock().microsecondsSinceEpoch}';
    await _events.upsert(
      LocalEvent(
        id: placeholderId,
        date: isoDate(draft.date),
        category: 'WORKOUT',
        type: draft.sport,
        name: draft.name,
        description: draft.description,
        plannedLoad: draft.load,
        plannedTime: draft.durationSeconds,
        plannedDistance: null,
        indoor: draft.indoor,
        raw: {
          'start_date_local': '${isoDate(draft.date)}T00:00:00',
          'triiq_pending': true,
        },
        syncedAt: _clock(),
      ),
    );
    await _events.deleteById(planned.id);
    await _queue.enqueue(PendingKind.replaceWorkout, {
      'old_event_id': planned.id,
      'placeholder_id': placeholderId,
      'draft': QueuedWorkoutWriter.draftToJson(draft),
    });
    _notify();
    return ReplaceOutcome.queued;
  }

  /// Takes the planned session [planned] off the calendar: a TriIQ plan
  /// session through [removeSession], an Intervals.icu event upstream first
  /// and then from the cache. Throws [ReplaceRefusedException] when an
  /// event can't be removed cleanly.
  Future<void> removePlanned(LocalEvent planned) async {
    if (planned.isPlanSession) {
      await removeSession(planned.planSessionId!);
      return;
    }
    if (!await _deleteUpstream(planned.id)) {
      throw const ReplaceRefusedException(ReplaceRefusal.notConnected);
    }
    await _events.deleteById(planned.id);
    final day = DateTime.tryParse(planned.date);
    if (day != null) await _safeResync(day);
    _notify();
  }

  /// Saves [goal] — a load-graph, length or sport-mix edit — after the same
  /// validation the goal editor applies.
  Future<void> applyGoal(Goal goal) async {
    final problem = goal.validate(today: _clock());
    if (problem != null) {
      throw ReplaceRefusedException(ReplaceRefusal.invalid, problem);
    }
    await _goals.save(goal);
    PlanChanges.instance.notify();
  }

  /// Moves plan session [sessionId] to [date] (same plan), upstream first
  /// when it is in Intervals.icu. [missed] lets a past session with nothing
  /// done for it move to a later day of its own week — the one past edit
  /// allowed.
  Future<void> moveSession(
    int sessionId,
    DateTime date, {
    bool missed = false,
  }) async {
    final session = await _editable(sessionId, missed: missed);
    final target = DateTime(date.year, date.month, date.day);
    if (target.isBefore(_today)) {
      throw const ReplaceRefusedException(ReplaceRefusal.past);
    }
    final plan = await _plans.getCurrent();
    if (plan == null || !_insidePlan(plan, target)) {
      throw const ReplaceRefusedException(ReplaceRefusal.outsidePlan);
    }
    if (session.date.isBefore(_today) &&
        !_sameWeek(plan, session.date, target)) {
      throw const ReplaceRefusedException(ReplaceRefusal.outsidePlan);
    }
    final eventId = session.intervalsEventId;
    if (eventId != null) {
      // Offline, the writer queues the move and the local change goes ahead.
      _requireSendEnabled();
      await _workouts.updatePlannedWorkoutDate(eventId, target);
    }
    await _plans.updateSession(session.copyWith(date: target));
    if (eventId != null) {
      await _safeResync(session.date);
      if (!_sameMonth(session.date, target)) await _safeResync(target);
    }
    _notify();
  }

  /// Takes plan session [sessionId] out of the plan, and off Intervals.icu
  /// when it is there. [missed] as for [moveSession].
  Future<void> removeSession(int sessionId, {bool missed = false}) async {
    final session = await _editable(sessionId, missed: missed);
    final eventId = session.intervalsEventId;
    if (eventId != null) {
      _requireSendEnabled();
      try {
        await _workouts.deletePlannedWorkout(eventId);
      } on DioException catch (error) {
        // Already gone upstream is what we wanted; anything else stops here.
        if (error.response?.statusCode != 404) rethrow;
      }
      await _events.deleteById(eventId);
    }
    await _plans.deleteSession(sessionId);
    if (eventId != null) await _safeResync(session.date);
    _notify();
  }

  /// Swaps the dates of plan sessions [a] and [b]. If the second move
  /// fails, the first is moved back before the error surfaces, so the plan
  /// never ends up with both on one day.
  Future<void> swapSessions(int a, int b) async {
    final first = await _editable(a);
    final second = await _editable(b);
    await moveSession(a, second.date);
    try {
      await moveSession(b, first.date);
    } catch (_) {
      try {
        await moveSession(a, first.date);
      } catch (rollback) {
        debugPrint('PlanActions: swap rollback failed: $rollback');
      }
      rethrow;
    }
  }

  DateTime get _today {
    final now = _clock();
    return DateTime(now.year, now.month, now.day);
  }

  /// A session that may still change: it exists and isn't in the past —
  /// unless [missed] and it really was: in the current plan week, with no
  /// activity of its sport family on its date.
  Future<PlanSession> _editable(int sessionId, {bool missed = false}) async {
    final session = await _plans.getSession(sessionId);
    if (session == null) {
      throw const ReplaceRefusedException(ReplaceRefusal.missing);
    }
    if (session.date.isBefore(_today) &&
        !(missed && await _wasMissed(session))) {
      throw const ReplaceRefusedException(ReplaceRefusal.past);
    }
    return session;
  }

  Future<bool> _wasMissed(PlanSession session) async {
    final plan = await _plans.getCurrent();
    if (plan == null || !_sameWeek(plan, session.date, _today)) return false;
    final family = sportFamily(session.sport);
    final done = await _activities.getByDate(isoDate(session.date));
    return !done.any((a) => sportFamily(a.type) == family);
  }

  static bool _sameWeek(TrainingPlan plan, DateTime a, DateTime b) {
    int index(DateTime d) =>
        DateTime.utc(d.year, d.month, d.day)
            .difference(
              DateTime.utc(
                plan.startDate.year,
                plan.startDate.month,
                plan.startDate.day,
              ),
            )
            .inDays ~/
        7;
    return _insidePlan(plan, a) && _insidePlan(plan, b) && index(a) == index(b);
  }

  /// Moving or deleting a sent session is refused only when the athlete
  /// switched sending off; being offline just queues the change.
  void _requireSendEnabled() {
    if (!_sendEnabled()) {
      throw const ReplaceRefusedException(ReplaceRefusal.sentButCannotSend);
    }
  }

  static bool _insidePlan(TrainingPlan plan, DateTime day) {
    final end = plan.startDate.add(Duration(days: 7 * plan.weeks.length));
    return !day.isBefore(plan.startDate) && day.isBefore(end);
  }

  static bool _sameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  void _notify() {
    PlanChanges.instance.notify();
    AutoSyncService.instance.notifyCacheChanged();
  }

  /// Deletes an Intervals.icu event; already gone counts as deleted.
  Future<bool> _deleteUpstream(String eventId) async {
    try {
      await _workouts.deletePlannedWorkout(eventId);
      return true;
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return true;
      debugPrint('PlanActions: cannot delete event $eventId: $error');
      return false;
    } catch (error) {
      debugPrint('PlanActions: cannot delete event $eventId: $error');
      return false;
    }
  }

  Future<void> _safeResync(DateTime day) async {
    try {
      await _resync(day);
    } catch (error) {
      // Upstream is right either way; the cache catches up on the next sync.
      debugPrint('PlanActions: resync after replace failed: $error');
    }
  }

  static Future<void> _resyncMonth(DateTime day) =>
      SyncService().syncMonth(day).then((_) {});
}
