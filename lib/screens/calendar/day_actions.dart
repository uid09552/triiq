import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/local_event.dart';
import '../../l10n/app_localizations.dart';
import '../activities/planned_workout_actions.dart';
import '../events/event_editor_screen.dart';
import '../events/event_labels.dart';
import '../today/train_now_screen.dart';
import 'day_events.dart';

/// Long-press on a calendar day: a sheet with "Propose training" (Train Now
/// for that day, so the created session lands on it) next to "Delete day's
/// training". Nothing is offered for a past day without deletable sessions,
/// so a day with no options just ignores the press.
///
/// [today] and [openTrainNow] are test seams.
Future<void> showDayActions(
  BuildContext context,
  DateTime date,
  List<LocalEvent> events, {
  DateTime Function()? today,
  void Function(BuildContext context, DateTime day)? openTrainNow,
  void Function(BuildContext context, DateTime day, String category)?
  openEventEditor,
  bool offerEvents = true,
}) async {
  final now = (today ?? DateTime.now)();
  final day = DateTime(date.year, date.month, date.day);
  final canPropose = !day.isBefore(DateTime(now.year, now.month, now.day));
  final planned = events.where((e) => e.isTraining).toList();
  final canDelete = planned.any(canDeletePlannedWorkout);
  if (!canPropose && !canDelete && !offerEvents) return;

  final l10n = AppLocalizations.of(context)!;
  final locale = Localizations.localeOf(context).toString();
  final choice = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              DateFormat.MMMMEEEEd(locale).format(day),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (canPropose)
            ListTile(
              key: const ValueKey('day-propose'),
              leading: const Icon(Icons.auto_awesome_outlined),
              title: Text(l10n.dayProposeTraining),
              subtitle: Text(l10n.dayProposeTrainingHelp),
              onTap: () => Navigator.of(context).pop('propose'),
            ),
          if (offerEvents)
            ListTile(
              key: const ValueKey('day-add-event'),
              leading: const Icon(Icons.event_note_outlined),
              title: Text(l10n.dayAddEvent),
              subtitle: Text(l10n.dayAddEventHelp),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).pop('event'),
            ),
          if (canDelete)
            ListTile(
              key: const ValueKey('day-delete'),
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(l10n.deleteDayTrainingsTitle),
              onTap: () => Navigator.of(context).pop('delete'),
            ),
        ],
      ),
    ),
  );
  if (!context.mounted) return;
  switch (choice) {
    case 'propose':
      if (openTrainNow != null) {
        openTrainNow(context, day);
      } else {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TrainNowScreen(today: () => day)),
        );
      }
    case 'delete':
      await confirmAndDeleteDaysWorkouts(context, planned);
    case 'event':
      // Second step: which kind, so the editor opens on it.
      final category = await showModalBottomSheet<String>(
        context: context,
        showDragHandle: true,
        builder: (context) => SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final c in const [
                  'SICK',
                  'INJURED',
                  'HOLIDAY',
                  'NOTE',
                  'RACE_A',
                  'RACE_B',
                  'RACE_C',
                  'TARGET',
                  'SEASON_START',
                ])
                  ListTile(
                    key: ValueKey('event-kind-$c'),
                    leading: Icon(
                      eventCategoryIcon(c),
                      color: eventCategoryColor(
                        c,
                        Theme.of(context).colorScheme,
                      ),
                    ),
                    title: Text(eventCategoryLabel(l10n, c)),
                    onTap: () => Navigator.of(context).pop(c),
                  ),
              ],
            ),
          ),
        ),
      );
      if (category == null || !context.mounted) return;
      if (openEventEditor != null) {
        openEventEditor(context, day, category);
      } else {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                EventEditorScreen(initialDate: day, initialCategory: category),
          ),
        );
      }
  }
}
