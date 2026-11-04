import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/local_event.dart';
import '../../l10n/app_localizations.dart';
import '../activities/planned_workout_actions.dart';
import '../today/train_now_screen.dart';

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
}) async {
  final now = (today ?? DateTime.now)();
  final day = DateTime(date.year, date.month, date.day);
  final canPropose = !day.isBefore(DateTime(now.year, now.month, now.day));
  final planned = events.where((e) => e.isTraining).toList();
  final canDelete = planned.any(canDeletePlannedWorkout);
  if (!canPropose && !canDelete) return;

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
          MaterialPageRoute(
            builder: (_) => TrainNowScreen(today: () => day),
          ),
        );
      }
    case 'delete':
      await confirmAndDeleteDaysWorkouts(context, planned);
  }
}
