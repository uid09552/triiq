import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../data/intervals_session.dart';
import '../../data/intervals_workout_service.dart';
import '../../data/pending_deletes.dart';
import '../../data/pending_writes.dart';
import '../../data/models/local_event.dart';
import '../../data/repositories/events_repository.dart';
import '../../data/repositories/plans_repository.dart';
import '../../data/sync/auto_sync_service.dart';
import '../../data/sync/sync_service.dart';
import '../../plan/plan_changes.dart';
import '../../plan/plan_models.dart';
import '../../l10n/app_localizations.dart';
import '../../util/calendar_export.dart';

/// What you can do with a planned session, shared by the places that offer
/// it: the calendar's day list and the planned-workout detail screen.

/// Removes one planned entry everywhere: Intervals.icu (an event that is
/// already gone counts as deleted), the event cache, and — for a TriIQ plan
/// session, or an Intervals.icu event a plan session was sent as — the plan
/// itself, so it doesn't reappear as a local-only session.
Future<void> _deleteEverywhere(
  LocalEvent event, {
  required PlannedWorkoutWriter service,
  required EventsRepository events,
  required PlansRepository plans,
}) async {
  Future<void> deleteUpstream(String eventId) async {
    try {
      await service.deletePlannedWorkout(eventId);
    } on DioException catch (error) {
      if (error.response?.statusCode != 404) rethrow;
    }
    await events.deleteById(eventId);
  }

  if (event.isPlanSession) {
    final id = event.planSessionId;
    if (id == null) return;
    final eventId = (await plans.getSession(id))?.intervalsEventId;
    if (eventId != null) await deleteUpstream(eventId);
    await plans.deleteSession(id);
  } else {
    await deleteUpstream(event.id);
    // The plan session this event was created from, if any.
    final plan = await plans.getCurrent();
    for (final session in plan?.sessions ?? const <PlanSession>[]) {
      if (session.intervalsEventId == event.id && session.id != null) {
        await plans.deleteSession(session.id!);
      }
    }
  }
  PlanChanges.instance.notify();
}

/// Refetches [day] from Intervals.icu after a delete, so the cache shows
/// exactly what the calendar upstream now holds. A failure is not an error:
/// the delete itself succeeded and the next sync catches up.
Future<void> _syncDay(String day) async {
  final date = DateTime.tryParse(day);
  if (date == null || !IntervalsSession.instance.isConnected) return;
  try {
    await SyncService().syncRange(date, date);
  } catch (error) {
    debugPrint('planned_workout_actions: day resync failed: $error');
  }
}

/// Deletes [event] with a way back: it disappears from the calendar at once
/// and a snackbar offers **Undo** for [undoWindow]. Only when the snackbar
/// goes away is the delete carried out for real — upstream on Intervals.icu,
/// from the event cache, and (for a plan session, or the event a plan session
/// was sent as) from the plan. Undo, or a failed delete, brings it back.
///
/// Nothing is written inside the window, so leaving the app then keeps the
/// entry. Returns true: the entry is gone from view (the detail screen closes
/// on it).
Future<bool> deletePlannedWorkoutWithUndo(
  BuildContext context,
  LocalEvent event, {
  PlannedWorkoutWriter? workoutService,
  EventsRepository? eventsRepository,
  PlansRepository? plansRepository,
  PendingDeletes? pendingDeletes,
  Duration undoWindow = const Duration(seconds: 6),
}) async {
  final l10n = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);
  final hidden = pendingDeletes ?? PendingDeletes.instance;
  final name = plannedWorkoutTitle(l10n, event);

  void refreshLists() {
    PlanChanges.instance.notify();
    AutoSyncService.instance.notifyCacheChanged();
  }

  hidden.hide(event.id);
  refreshLists();

  final controller = messenger.showSnackBar(
    SnackBar(
      content: Text(l10n.workoutDeletedUndoable(name)),
      duration: undoWindow,
      // A snackbar with an action otherwise stays until dismissed, and the
      // delete would never be carried out.
      persist: false,
      action: SnackBarAction(label: l10n.undoButton, onPressed: () {}),
    ),
  );

  unawaited(
    controller.closed.then((reason) async {
      if (reason == SnackBarClosedReason.action) {
        hidden.restore(event.id);
        refreshLists();
        return;
      }
      try {
        await _deleteEverywhere(
          event,
          service: workoutService ?? QueuedWorkoutWriter(),
          events: eventsRepository ?? EventsRepository(),
          plans: plansRepository ?? PlansRepository(),
        );
        await _syncDay(event.date);
        // Gone for real: the hide is no longer needed.
        hidden.restore(event.id);
        refreshLists();
      } catch (error) {
        hidden.restore(event.id);
        refreshLists();
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.couldNotDeleteWorkout('$error'))),
        );
      }
    }),
  );
  return true;
}

/// Asks for confirmation, then deletes every deletable planned session in
/// [events] (one day's worth) upstream and from the local cache.
///
/// Sessions that [canDeletePlannedWorkout] refuses (TriIQ plan sessions) are
/// left alone. Returns how many were deleted; a failure stops the run and
/// surfaces as a snackbar, keeping what was already removed.
Future<int> confirmAndDeleteDaysWorkouts(
  BuildContext context,
  List<LocalEvent> events, {
  PlannedWorkoutWriter? workoutService,
  EventsRepository? eventsRepository,
  PlansRepository? plansRepository,
}) async {
  final deletable = events.where(canDeletePlannedWorkout).toList();
  if (deletable.isEmpty) return 0;
  final l10n = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      return AlertDialog(
        title: Text(l10n.deleteDayTrainingsTitle),
        content: Text(l10n.deleteDayTrainingsConfirm(deletable.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.deleteButton),
          ),
        ],
      );
    },
  );
  if (confirmed != true) return 0;

  final service = workoutService ?? QueuedWorkoutWriter();
  final repository = eventsRepository ?? EventsRepository();
  final plans = plansRepository ?? PlansRepository();
  var deleted = 0;
  try {
    for (final event in deletable) {
      await _deleteEverywhere(
        event,
        service: service,
        events: repository,
        plans: plans,
      );
      deleted++;
    }
  } catch (error) {
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.couldNotDeleteWorkout('$error'))),
    );
  }
  if (deleted > 0) {
    // One refetch per affected day, so the cache matches Intervals.icu.
    for (final day in {for (final e in deletable) e.date}) {
      await _syncDay(day);
    }
    AutoSyncService.instance.notifyCacheChanged();
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.dayTrainingsDeleted(deleted))),
    );
  }
  return deleted;
}

/// Hands [event] to Google Calendar's "add event" flow, prefilled.
Future<void> addPlannedWorkoutToGoogleCalendar(
  BuildContext context,
  LocalEvent event,
) async {
  final l10n = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);
  final plannedTime = event.plannedTime;

  final launched = await launchGoogleCalendarEvent(
    title: plannedWorkoutTitle(l10n, event),
    description: event.description ?? '',
    start: event.startsAt ?? DateTime.now(),
    // No prescribed duration: an hour is the honest default for a block on
    // a calendar, and the athlete can drag it afterwards.
    duration: Duration(
      seconds: plannedTime != null && plannedTime > 0 ? plannedTime : 3600,
    ),
    allDay: !event.hasTimeOfDay,
  );

  if (!launched) {
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.couldNotOpenGoogleCalendar)),
    );
  }
}

/// Deleting writes upstream, so an Intervals.icu event (or a plan session
/// that was sent there) is only deletable against a live session. A plan
/// session that only lives in TriIQ can always be deleted.
bool canDeletePlannedWorkout(LocalEvent event) {
  if (event.isPlanSession) {
    return !event.planSessionSent || IntervalsSession.instance.isConnected;
  }
  return IntervalsSession.instance.isConnected && event.id.isNotEmpty;
}

String plannedWorkoutTitle(AppLocalizations l10n, LocalEvent event) =>
    event.name ?? event.type ?? l10n.plannedSessionFallback;
