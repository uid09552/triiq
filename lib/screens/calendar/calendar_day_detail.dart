import 'package:flutter/material.dart';

import '../../data/models/local_activity.dart';
import '../../data/models/local_event.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/section_card.dart';
import '../activities/activity_detail_screen.dart';
import '../activities/activity_icons.dart';
import '../activities/planned_workout_actions.dart';
import '../activities/planned_workout_detail_screen.dart';
import '../plan/plan_session_sheet.dart';
import 'calendar_day_marker.dart';
import 'day_actions.dart';
import 'performance_trend_icon.dart';

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

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPress: () => showDayActions(context, date, plannedEvents),
      child: SectionCard(
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
                for (final event in plannedEvents.where((e) => e.isPlanSession))
                  _Row(
                    key: ValueKey('plan-session-${event.planSessionId}'),
                    color: colorScheme.secondary,
                    type: event.type,
                    title: plannedWorkoutTitle(l10n, event),
                    subtitle:
                        '${l10n.planSessionBadge} · '
                        '${l10n.planSessionMinutes((event.plannedTime ?? 0) ~/ 60, event.plannedLoad ?? 0)}',
                    onTap: () => showPlanSessionSheetForEvent(context, event),
                    onDelete: canDeletePlannedWorkout(event)
                        ? () => confirmAndDeletePlannedWorkout(context, event)
                        : null,
                    deleteTooltip: l10n.deleteTooltip,
                    status: Tooltip(
                      message: event.planSessionSent
                          ? l10n.planSessionSent
                          : l10n.planSessionLocalOnly,
                      child: Icon(
                        event.planSessionSent
                            ? Icons.cloud_done_outlined
                            : Icons.cloud_off_outlined,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                for (final event in plannedEvents.where(
                  (e) => !e.isPlanSession,
                ))
                  _Row(
                    color: colorScheme.tertiary,
                    type: event.type,
                    title: plannedWorkoutTitle(l10n, event),
                    subtitle: l10n.plannedStatus,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            PlannedWorkoutDetailScreen(event: event),
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
                    title:
                        activity.name ?? activity.type ?? l10n.activityFallback,
                    subtitle: l10n.completedStatus,
                    status: PerformanceTrendIcon(
                      key: ValueKey('trend-${activity.id}'),
                      activity: activity,
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ActivityDetailScreen(activity: activity),
                      ),
                    ),
                  ),
              ],
            ),
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
    super.key,
    required this.color,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.onDelete,
    this.deleteTooltip,
    this.status,
  });

  /// A small trailing indicator, e.g. whether a plan session was sent.
  final Widget? status;

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
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
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
            if (status != null) ...[status!, const SizedBox(width: 8)],
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
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
