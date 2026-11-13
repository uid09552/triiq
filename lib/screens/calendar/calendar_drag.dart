import 'package:flutter/material.dart';

import '../../data/models/local_event.dart';
import '../../l10n/app_localizations.dart';
import '../../util/dates.dart';
import '../activities/activity_icons.dart';
import '../activities/planned_workout_actions.dart';
import 'calendar_moves.dart';

/// Called when a planned session is dropped on a day.
typedef PlannedDrop = void Function(LocalEvent event, DateTime day);

/// Long-press [child] to pick up [event] and drag it to another day. A
/// session that can't move says why on a snackbar instead. Without a
/// [mover] the child is shown as it is.
class PlannedDragSource extends StatelessWidget {
  const PlannedDragSource({
    super.key,
    required this.event,
    required this.mover,
    required this.child,
  });

  final LocalEvent event;
  final CalendarMover? mover;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final m = mover;
    if (m == null) return child;
    final l10n = AppLocalizations.of(context)!;
    if (m.whyNot(l10n, event) != null) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPress: () => checkMovable(context, m, event),
        child: child,
      );
    }
    final scheme = Theme.of(context).colorScheme;
    return LongPressDraggable<LocalEvent>(
      data: event,
      hapticFeedbackOnStart: true,
      childWhenDragging: Opacity(opacity: 0.35, child: child),
      feedback: Material(
        elevation: 6,
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                activityTypeIcon(event.type),
                size: 18,
                color: scheme.onSecondaryContainer,
              ),
              const SizedBox(width: 6),
              Text(
                plannedWorkoutTitle(l10n, event),
                style: TextStyle(
                  color: scheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      child: child,
    );
  }
}

/// A day that accepts a dragged planned session. [builder] gets the
/// session hovering over it, if any, to preview the drop.
class DayDropTarget extends StatelessWidget {
  const DayDropTarget({
    super.key,
    required this.date,
    required this.onDrop,
    required this.builder,
  });

  final DateTime date;
  final PlannedDrop? onDrop;
  final Widget Function(BuildContext context, LocalEvent? hovering) builder;

  @override
  Widget build(BuildContext context) {
    final drop = onDrop;
    if (drop == null) return builder(context, null);
    return DragTarget<LocalEvent>(
      onWillAcceptWithDetails: (d) => d.data.date != isoDate(date),
      onAcceptWithDetails: (d) => drop(d.data, dateOnly(date)),
      builder: (context, candidates, _) =>
          builder(context, candidates.isEmpty ? null : candidates.first),
    );
  }
}
