import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';

import '../../data/models/local_activity.dart';
import '../../data/models/local_event.dart';
import '../../evaluation/session_evaluator.dart' show sportFamily;
import '../../l10n/app_localizations.dart';
import '../../evaluation/compare.dart' show isComparable;
import '../activities/activity_detail_screen.dart';
import '../compare/compare_screen.dart';
import '../activities/planned_workout_actions.dart';
import '../activities/planned_workout_detail_screen.dart';
import '../plan/plan_session_sheet.dart';
import 'calendar_day_marker.dart';
import 'calendar_drag.dart';
import 'calendar_moves.dart';
import '../activities/feel_dialog.dart';
import 'day_actions.dart';
import 'day_events.dart';
import '../events/event_editor_screen.dart';
import '../events/event_labels.dart';
import 'performance_trend_icon.dart';

/// Planned and completed sessions for one selected day, colour-coded the
/// same way as the grid/list markers and tappable through to full detail.
///
/// A slim card: the date on one line (with a "Today" pill) and the day's
/// load on the right — done against planned TSS, with a hairline progress
/// bar — then one compact row per session. A planned session that a
/// completed activity of the same sport covers gets a check; completed
/// rows show their time and load instead of just "Completed".
class CalendarDayDetail extends StatelessWidget {
  const CalendarDayDetail({
    super.key,
    required this.date,
    required this.events,
    required this.activities,
    this.dayEvents = const [],
    this.today,
    this.mover,
    this.onMove,
    this.swipeActions = false,
    this.onOpenDay,
    this.onFeel,
  });

  /// Which planned sessions may be dragged to another day (long-press a
  /// row); without it rows can't be dragged.
  final CalendarMover? mover;

  /// "Move to…" for a planned session — the gesture-free way to move it.
  final ValueChanged<LocalEvent>? onMove;

  /// Swipe a planned row left to delete it (with the undo window), a
  /// completed one right for "How did it feel?". Off where the list isn't
  /// rebuilt from [PendingDeletes] at once.
  final bool swipeActions;

  /// Opens the full day view; shown as a button in the header.
  final VoidCallback? onOpenDay;

  /// Swipe right on a completed session; defaults to the feel dialog.
  final void Function(LocalActivity activity)? onFeel;

  /// Sick days, notes, holidays, races, … covering this day.
  final List<LocalEvent> dayEvents;

  final DateTime date;
  final List<LocalEvent> events;
  final List<LocalActivity> activities;

  /// Test seam for "now"; the app uses the clock.
  final DateTime Function()? today;

  bool _isToday() {
    final now = (today ?? DateTime.now)();
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final plannedEvents = events.where((e) => e.isTraining).toList();

    final plannedTss = plannedEvents.fold<int>(
      0,
      (s, e) => s + (e.plannedLoad ?? 0),
    );
    final doneTss = activities.fold<int>(
      0,
      (s, a) => s + (a.trainingLoad ?? 0),
    );
    final doneFamilies = {for (final a in activities) sportFamily(a.type)};
    bool covered(LocalEvent e) => doneFamilies.contains(sportFamily(e.type));

    String? load;
    if (plannedTss > 0) {
      load = l10n.dayCardLoadOfPlanned(doneTss, plannedTss);
    } else if (doneTss > 0) {
      load = l10n.dayCardLoadDone(doneTss);
    }
    final empty =
        plannedEvents.isEmpty && activities.isEmpty && dayEvents.isEmpty;

    String detail(int? seconds, int? tss) {
      final mins = seconds == null || seconds <= 0
          ? null
          : (seconds / 60).round();
      if (mins != null && tss != null)
        return l10n.planSessionMinutes(mins, tss);
      if (mins != null) return '$mins min';
      if (tss != null) return '$tss TSS';
      return '';
    }

    String withDetail(String lead, String d) => d.isEmpty ? lead : '$lead · $d';

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPress: () =>
          showDayActions(context, date, plannedEvents, activities: activities),
      child: Card(
        key: const ValueKey('day-detail-card'),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 8, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        DateFormat.MMMEd(locale).format(date),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (_isToday()) ...[
                      const SizedBox(width: 8),
                      Container(
                        key: const ValueKey('day-today-pill'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          l10n.dayCardToday,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (load != null)
                      Flexible(
                        child: Text(
                          load,
                          key: const ValueKey('day-load'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (onOpenDay != null)
                      IconButton(
                        key: const ValueKey('day-open'),
                        tooltip: l10n.calOpenDay,
                        visualDensity: VisualDensity.compact,
                        onPressed: onOpenDay,
                        icon: const Icon(Icons.open_in_full, size: 18),
                      ),
                  ],
                ),
              ),
              if (plannedTss > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 6, right: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      key: const ValueKey('day-progress'),
                      minHeight: 3,
                      value: (doneTss / plannedTss).clamp(0.0, 1.0),
                      backgroundColor: colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ),
              if (empty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  child: Text(
                    l10n.nothingPlannedOrLogged,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else ...[
                const SizedBox(height: 2),
                for (final e in dayEvents)
                  _DayEventRow(
                    key: ValueKey('day-event-row-${e.id}'),
                    event: e,
                  ),
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
                        ? () => deletePlannedWorkoutWithUndo(context, event)
                        : null,
                    deleteTooltip: l10n.deleteTooltip,
                    onMove: onMove == null ? null : () => onMove!(event),
                    dragEvent: event,
                    mover: mover,
                    swipe: swipeActions,
                    swipeId: event.id,
                    status: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (covered(event))
                          Icon(
                            Icons.check_circle,
                            key: const ValueKey('planned-done'),
                            size: 16,
                            color: colorScheme.tertiary,
                          ),
                        const SizedBox(width: 4),
                        Tooltip(
                          message: event.planSessionSent
                              ? l10n.planSessionSent
                              : l10n.planSessionLocalOnly,
                          child: Icon(
                            event.planSessionSent
                                ? Icons.cloud_done_outlined
                                : Icons.cloud_off_outlined,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                for (final event in plannedEvents.where(
                  (e) => !e.isPlanSession,
                ))
                  _Row(
                    color: colorScheme.tertiary,
                    type: event.type,
                    title: plannedWorkoutTitle(l10n, event),
                    subtitle: withDetail(
                      l10n.plannedStatus,
                      detail(event.plannedTime, event.plannedLoad),
                    ),
                    status: covered(event)
                        ? Icon(
                            Icons.check_circle,
                            key: const ValueKey('planned-done'),
                            size: 16,
                            color: colorScheme.tertiary,
                          )
                        : null,
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
                        ? () => deletePlannedWorkoutWithUndo(context, event)
                        : null,
                    deleteTooltip: l10n.deleteTooltip,
                    onMove: onMove == null ? null : () => onMove!(event),
                    dragEvent: event,
                    mover: mover,
                    swipe: swipeActions,
                    swipeId: event.id,
                  ),
                for (final activity in activities)
                  _Row(
                    color: colorScheme.primary,
                    type: activity.type,
                    title:
                        activity.name ?? activity.type ?? l10n.activityFallback,
                    subtitle: withDetail(
                      l10n.completedStatus,
                      detail(activity.movingTime, activity.trainingLoad),
                    ),
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
                    // Same "Compare with…" as on the activity's own page.
                    onLongPress: isComparable(activity)
                        ? () => _showActivityActions(context, activity)
                        : null,
                    swipe: swipeActions,
                    swipeId: activity.id,
                    onSwipeRight: () => onFeel != null
                        ? onFeel!(activity)
                        : showFeelDialog(context, date: activity.date),
                    swipeRightLabel: l10n.feelDialogTitle,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A sick day, note, holiday, race … on the day card: its icon and colour,
/// name, kind and (for a multi-day entry) its span. Tap to edit it.
class _DayEventRow extends StatelessWidget {
  const _DayEventRow({super.key, required this.event});

  final LocalEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final color = eventCategoryColor(event.category, theme.colorScheme);
    final end = DateTime.tryParse(event.raw['end_date_local'] as String? ?? '');
    final start = DateTime.tryParse(event.date);
    final span = end != null && start != null && end.isAfter(start)
        ? ' · ${DateFormat.MMMd(locale).format(start)}–${DateFormat.MMMd(locale).format(end)}'
        : '';
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => EventEditorScreen(event: event)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                eventCategoryIcon(event.category),
                size: 14,
                color: color,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name ?? eventCategoryLabel(l10n, event.category),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${eventCategoryLabel(l10n, event.category)}$span',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    super.key,
    required this.color,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.onLongPress,
    this.onDelete,
    this.deleteTooltip,
    this.status,
    this.onMove,
    this.dragEvent,
    this.mover,
    this.swipe = false,
    this.swipeId,
    this.onSwipeRight,
    this.swipeRightLabel,
  });

  /// "Move to…" (a button and a screen-reader action).
  final VoidCallback? onMove;

  /// The planned session a long-press picks up for dragging.
  final LocalEvent? dragEvent;
  final CalendarMover? mover;

  /// Swipe left = [onDelete], swipe right = [onSwipeRight].
  final bool swipe;
  final String? swipeId;
  final VoidCallback? onSwipeRight;
  final String? swipeRightLabel;

  /// A small trailing indicator, e.g. whether a plan session was sent.
  final Widget? status;

  final Color color;
  final String? type;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  /// Shown as a trailing button when the entry can be removed upstream —
  /// planned sessions only; a completed activity is a record of something
  /// that happened, not a plan to change.
  final VoidCallback? onDelete;
  final String? deleteTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    Widget row = _content(context, theme);
    if (dragEvent != null && mover != null) {
      row = PlannedDragSource(event: dragEvent!, mover: mover, child: row);
    }
    final canLeft = swipe && onDelete != null;
    final canRight = swipe && onSwipeRight != null;
    if (canLeft || canRight) {
      final scheme = theme.colorScheme;
      Widget bg(Color color, IconData icon, String label, Alignment align) =>
          Container(
            color: color,
            alignment: align,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
      final right = bg(
        scheme.primary,
        Icons.mood,
        swipeRightLabel ?? '',
        Alignment.centerLeft,
      );
      final left = bg(
        scheme.error,
        Icons.delete_outline,
        deleteTooltip ?? '',
        Alignment.centerRight,
      );
      row = Dismissible(
        key: ValueKey('swipe-$swipeId'),
        direction: canLeft && canRight
            ? DismissDirection.horizontal
            : canLeft
            ? DismissDirection.endToStart
            : DismissDirection.startToEnd,
        background: canRight ? right : left,
        secondaryBackground: canRight && canLeft ? left : null,
        // The row never stays dismissed here: deleting hides it through
        // [PendingDeletes] (with Undo), the feel dialog leaves it be.
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            onDelete?.call();
          } else {
            onSwipeRight?.call();
          }
          return false;
        },
        child: row,
      );
    }
    return Semantics(
      customSemanticsActions: {
        CustomSemanticsAction(label: l10n.calMoveTo): ?onMove,
        if (onDelete != null && deleteTooltip != null)
          CustomSemanticsAction(label: deleteTooltip!): onDelete!,
        if (onSwipeRight != null && swipeRightLabel != null)
          CustomSemanticsAction(label: swipeRightLabel!): onSwipeRight!,
      },
      child: row,
    );
  }

  Widget _content(BuildContext context, ThemeData theme) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            CalendarDayMarker(type: type, color: color, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (status != null) ...[status!, const SizedBox(width: 8)],
            if (onMove != null)
              IconButton(
                key: ValueKey('move-$swipeId'),
                onPressed: onMove,
                tooltip: AppLocalizations.of(context)!.calMoveTo,
                iconSize: 20,
                icon: Icon(
                  Icons.event_repeat,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                tooltip: deleteTooltip,
                iconSize: 20,
                icon: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

/// The long-press menu of a completed run or ride on the day card.
void _showActivityActions(BuildContext context, LocalActivity activity) {
  final l10n = AppLocalizations.of(context)!;
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            key: const ValueKey('calendar-compare-action'),
            leading: const Icon(Icons.compare_arrows),
            title: Text(l10n.cmpCompareWith),
            onTap: () {
              Navigator.of(sheet).pop();
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CompareScreen(initialActivity: activity),
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}
