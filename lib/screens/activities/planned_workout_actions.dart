import 'package:flutter/material.dart';

import '../../data/intervals_session.dart';
import '../../data/intervals_workout_service.dart';
import '../../data/models/local_event.dart';
import '../../data/repositories/events_repository.dart';
import '../../data/sync/auto_sync_service.dart';
import '../../l10n/app_localizations.dart';
import '../../util/calendar_export.dart';

/// What you can do with a planned session, shared by the places that offer
/// it: the calendar's day list and the planned-workout detail screen.

/// Asks for confirmation, then deletes [event] from the athlete's
/// Intervals.icu calendar and from the local cache.
///
/// Returns whether it was deleted. Failures surface as a snackbar rather
/// than an exception — every caller would otherwise do the same thing with
/// them.
Future<bool> confirmAndDeletePlannedWorkout(
  BuildContext context,
  LocalEvent event, {
  IntervalsWorkoutService? workoutService,
  EventsRepository? eventsRepository,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);
  final name = plannedWorkoutTitle(l10n, event);

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      return AlertDialog(
        title: Text(l10n.deletePlannedWorkoutTitle),
        content: Text(l10n.deletePlannedWorkoutConfirm(name)),
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
  if (confirmed != true) return false;

  try {
    await (workoutService ?? IntervalsWorkoutService()).deletePlannedWorkout(
      event.id,
    );
    // Drop it from the cache too: the calendar reads from there, and the
    // range it came from isn't refetched until it goes stale.
    await (eventsRepository ?? EventsRepository()).deleteById(event.id);
  } catch (error) {
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.couldNotDeleteWorkout('$error'))),
    );
    return false;
  }

  // Wakes the screens kept alive behind the current one, so the session is
  // gone from the calendar by the time the athlete is looking at it again.
  AutoSyncService.instance.notifyCacheChanged();
  messenger.showSnackBar(SnackBar(content: Text(l10n.workoutDeleted(name))));
  return true;
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

/// Deleting writes upstream, so it's only offered against a live session.
bool canDeletePlannedWorkout(LocalEvent event) =>
    IntervalsSession.instance.isConnected && event.id.isNotEmpty;

String plannedWorkoutTitle(AppLocalizations l10n, LocalEvent event) =>
    event.name ?? event.type ?? l10n.plannedSessionFallback;
