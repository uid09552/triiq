import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/intervals_workout_service.dart';
import '../data/pending_writes.dart';
import '../data/repositories/plans_repository.dart';
import '../data/sync/auto_sync_service.dart';
import '../data/sync/sync_service.dart';
import '../util/dates.dart';
import 'plan_models.dart';

/// Which sessions made it to Intervals.icu and which did not.
class PlanWriteReport {
  const PlanWriteReport({
    required this.created,
    required this.failed,
    this.queued = const [],
  });

  final List<PlanSession> created;

  /// Sessions stored for sending once Intervals.icu is reachable again.
  final List<PlanSession> queued;
  final List<({PlanSession session, Object error})> failed;

  bool get allCreated => failed.isEmpty;
}

/// Puts a confirmed plan on the athlete's Intervals.icu calendar and takes
/// the not-yet-done part of it off again.
///
/// Every created event carries the plan's tag, so what the plan made is
/// recognisable — and only ever those events are removed, never completed
/// activities or entries the athlete added themselves.
class PlanWriter {
  PlanWriter({
    required PlannedWorkoutWriter workouts,
    required PlansRepository plans,
    Future<void> Function(DateTime oldest, DateTime newest)? afterWrite,
  }) : _workouts = workouts,
       _plans = plans,
       _afterWrite = afterWrite ?? _resyncAndNotify;

  final PlannedWorkoutWriter _workouts;
  final PlansRepository _plans;
  final Future<void> Function(DateTime oldest, DateTime newest) _afterWrite;

  static String tagFor(int planId) => 'triiq-plan-$planId';

  /// Creates every session that isn't on Intervals.icu yet, one by one, so a
  /// failure on one leaves the others written and the report names what is
  /// left to retry. Run it again with the same plan to retry only those.
  /// With [from], sessions dated before it are left alone (sending a plan
  /// later doesn't fill in days already past).
  Future<PlanWriteReport> write(TrainingPlan plan, {DateTime? from}) async {
    final planId = plan.id;
    if (planId == null) throw ArgumentError('Save the plan before writing it.');
    final cutoff = from == null ? null : dateOnly(from);

    final created = <PlanSession>[];
    final failed = <({PlanSession session, Object error})>[];
    final queued = <PlanSession>[];
    for (final session in plan.sessions) {
      if (session.status == PlanSessionStatus.created) continue;
      if (cutoff != null && session.date.isBefore(cutoff)) continue;
      try {
        final event = await _workouts.createPlannedWorkout(
          PlannedWorkoutDraft(
            name: session.name,
            sport: session.sport,
            description: session.description,
            date: session.date,
            durationSeconds: session.minutes * 60,
            load: session.load,
            tags: [tagFor(planId)],
            externalId: '${tagFor(planId)}-${session.id}',
          ),
        );
        final done = session.copyWith(
          intervalsEventId: event.id?.toString(),
          status: PlanSessionStatus.created,
        );
        await _plans.updateSession(done);
        created.add(done);
      } on QueuedOfflineException {
        queued.add(session);
      } catch (error) {
        debugPrint('PlanWriter: ${session.name} ${isoDate(session.date)}: $error');
        final marked = session.copyWith(status: PlanSessionStatus.failed);
        await _plans.updateSession(marked);
        failed.add((session: marked, error: error));
      }
    }

    if (created.isNotEmpty) {
      await _refresh(plan);
    }
    if (failed.isEmpty) await _plans.setStatus(planId, PlanStatus.active);
    return PlanWriteReport(created: created, failed: failed, queued: queued);
  }

  /// Deletes the plan's sessions dated [from] or later that are on
  /// Intervals.icu, and drops them from the plan. Earlier sessions stay: they
  /// are history. Returns how many were removed from Intervals.icu.
  Future<int> removeFrom(TrainingPlan plan, DateTime from) async {
    final cutoff = dateOnly(from);
    var removed = 0;
    for (final session in plan.sessions) {
      if (session.date.isBefore(cutoff)) continue;
      final eventId = session.intervalsEventId;
      if (eventId != null) {
        try {
          await _workouts.deletePlannedWorkout(eventId);
          removed++;
        } on DioException catch (error) {
          // Already gone upstream (the athlete deleted it): nothing to do.
          if (error.response?.statusCode != 404) rethrow;
        }
      }
      if (session.id != null) await _plans.deleteSession(session.id!);
    }
    if (removed > 0) await _refresh(plan);
    return removed;
  }

  Future<void> _refresh(TrainingPlan plan) async {
    final dates = plan.sessions.map((s) => s.date).toList()..sort();
    if (dates.isEmpty) return;
    try {
      await _afterWrite(dates.first, dates.last);
    } catch (error) {
      // The write itself succeeded; a failed re-read only means the calendar
      // shows it after the next sync.
      debugPrint('PlanWriter: re-sync failed: $error');
    }
  }

  static Future<void> _resyncAndNotify(DateTime oldest, DateTime newest) async {
    await SyncService().syncRange(oldest, newest);
    AutoSyncService.instance.notifyCacheChanged();
  }
}
