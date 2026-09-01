import 'package:flutter/material.dart';

import '../../data/models/local_activity.dart';
import '../../data/models/local_event.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/section_card.dart';
import '../activities/activity_detail_screen.dart';
import '../activities/activity_icons.dart';
import '../activities/planned_workout_actions.dart';
import '../activities/planned_workout_detail_screen.dart';
import 'calendar_day_marker.dart';

/// Planned and completed sessions for one selected day, colour-coded the
/// same way as the grid/list markers and tappable through to full detail.
class CalendarDayDetail extends StatelessWidget {
  const CalendarDayDetail({
    super.key,
    required this.date,
    required this.events,
    required this.activities,
  });

  final DateTime date;
  final List<LocalEvent> events;
  final List<LocalActivity> activities;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final plannedEvents = events.where((e) => e.isTraining).toList();

    return SectionCard(
      icon: Icons.event_note_outlined,
      title: formatIsoDate(_fmt(date)),
      child: plannedEvents.isEmpty && activities.isEmpty
          ? Text(
              l10n.nothingPlannedOrLogged,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final event in plannedEvents)
                  _Row(
                    color: colorScheme.tertiary,
                    type: event.type,
                    title: plannedWorkoutTitle(l10n, event),
                    subtitle: l10n.plannedStatus,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PlannedWorkoutDetailScreen(event: event),
                      ),
                    ),
                    // Deleting straight from the day's list, without opening
                    // the session first: the calendar is where reshuffling a
                    // week actually happens.
                    onDelete: canDeletePlannedWorkout(event)
                        ? () => confirmAndDeletePlannedWorkout(context, event)
                        : null,
                    deleteTooltip: l10n.deleteTooltip,
                  ),
                for (final activity in activities)
                  _Row(
                    color: colorScheme.primary,
                    type: activity.type,
                    title: activity.name ?? activity.type ?? l10n.activityFallback,
                    subtitle: l10n.completedStatus,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ActivityDetailScreen(activity: activity),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  static String _fmt(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

class _Row extends StatelessWidget {
  const _Row({
    required this.color,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.onDelete,
    this.deleteTooltip,
  });

  final Color color;
  final String? type;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  /// Shown as a trailing button when the entry can be removed upstream —
  /// planned sessions only; a completed activity is a record of something
  /// that happened, not a plan to change.
  final VoidCallback? onDelete;
  final String? deleteTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            CalendarDayMarker(type: type, color: color, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                tooltip: deleteTooltip,
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
