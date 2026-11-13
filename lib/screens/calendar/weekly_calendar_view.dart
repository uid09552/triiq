import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../data/models/local_activity.dart';
import '../../data/models/local_event.dart';
import '../../evaluation/readiness.dart';
import '../../l10n/app_localizations.dart';
import '../../util/dates.dart';
import '../../widgets/progress_ring.dart';
import '../activities/activity_icons.dart';
import '../events/event_labels.dart';
import 'calendar_data.dart';
import 'calendar_drag.dart';
import 'calendar_moves.dart';
import 'day_cell_parts.dart';
import 'day_events.dart';

/// Week list of planned (tertiary colour) vs. completed (primary colour)
/// trainings, one row per day, each session a block sized by its duration.
/// Above it, the week's planned vs. done load and hours and a ring per sport.
class WeeklyCalendarView extends StatelessWidget {
  const WeeklyCalendarView({
    super.key,
    required this.weekStart,
    required this.selectedDate,
    required this.eventsByDate,
    required this.activitiesByDate,
    required this.onSelect,
    this.dayEventsByDate = const {},
    this.readinessByDate = const {},
    this.onLongPress,
    this.onDrop,
    this.mover,
    this.onWeekActions,
    this.today,
  });

  /// Sick days, notes, holidays, races, … by every day they cover.
  final Map<String, List<LocalEvent>> dayEventsByDate;
  final Map<String, Readiness> readinessByDate;

  /// Long-press on a day, e.g. to offer clearing it.
  final ValueChanged<DateTime>? onLongPress;

  /// A planned session dropped on a day.
  final PlannedDrop? onDrop;
  final CalendarMover? mover;

  /// The week's actions menu (the same as a long-press on its number).
  final VoidCallback? onWeekActions;

  /// Test seam for "now".
  final DateTime Function()? today;

  /// Monday of the displayed week.
  final DateTime weekStart;
  final DateTime selectedDate;
  final Map<String, List<LocalEvent>> eventsByDate;
  final Map<String, List<LocalActivity>> activitiesByDate;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final now = dateOnly((today ?? DateTime.now)());
    final data = CalendarData(
      eventsByDate: eventsByDate,
      activitiesByDate: activitiesByDate,
    );
    final summary = PeriodSummary(
      data,
      weekStart,
      DateTime(weekStart.year, weekStart.month, weekStart.day + 6),
      today: now,
    );
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _WeekSummaryCard(summary: summary, onWeekActions: onWeekActions),
          const SizedBox(height: 10),
          for (var i = 0; i < 7; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _dayRow(
              context,
              DateTime(weekStart.year, weekStart.month, weekStart.day + i),
              now,
            ),
          ],
        ],
      ),
    );
  }

  Widget _dayRow(BuildContext context, DateTime date, DateTime now) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final isToday = date == now;
    final isSelected = date == dateOnly(selectedDate);
    final key = isoDate(date);
    final allEvents = eventsByDate[key] ?? const <LocalEvent>[];
    final events = allEvents
        .where((e) => e.isTraining && !isRaceCategory(e.category))
        .toList();
    final dayEvents = dayEventsByDate[key] ?? const <LocalEvent>[];
    final activities = activitiesByDate[key] ?? const <LocalActivity>[];
    final summary = DaySummary.of(allEvents, activities, dayEvents: dayEvents);
    final readiness = date.isAfter(now) ? null : readinessByDate[key]?.level;
    final hasAny =
        events.isNotEmpty || activities.isNotEmpty || dayEvents.isNotEmpty;
    final countdown = raceCountdown(date, dayEvents, now);

    return DayDropTarget(
      date: date,
      onDrop: onDrop,
      builder: (context, hovering) {
        final previewTss = hovering == null
            ? null
            : summary.plannedTss + (hovering.plannedLoad ?? 0);
        return Semantics(
          label: daySemanticLabel(
            context,
            date,
            summary,
            readiness: readiness,
            dayEvents: dayEvents,
            today: now,
          ),
          selected: isSelected,
          button: true,
          onLongPressHint: onLongPress == null ? null : l10n.calDayActions,
          child: Card(
            margin: EdgeInsets.zero,
            color: hovering != null
                ? colorScheme.primary.withValues(alpha: 0.18)
                : isSelected
                ? colorScheme.primary.withValues(alpha: 0.08)
                : dayFillColor(summary.fill, colorScheme),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isToday || hovering != null
                  ? BorderSide(color: colorScheme.primary, width: 1.5)
                  : BorderSide.none,
            ),
            child: InkWell(
              key: ValueKey('week-day-$key'),
              borderRadius: BorderRadius.circular(16),
              onTap: () => onSelect(date),
              onLongPress: onLongPress == null
                  ? null
                  : () => onLongPress!(date),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 40,
                      child: ExcludeSemantics(
                        child: Column(
                          children: [
                            Text(
                              '${date.day}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: isToday ? colorScheme.primary : null,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                DayBadge(summary: summary, size: 12),
                                if (readiness != null) ...[
                                  const SizedBox(width: 3),
                                  ReadinessDot(level: readiness, size: 8),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ExcludeSemantics(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    DateFormat.EEEE(locale).format(date),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (previewTss != null)
                                  Text(
                                    '→ ${l10n.dayCardLoadDone(previewTss)}',
                                    key: const ValueKey('drop-preview'),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                else if (summary.plannedTss > 0 ||
                                    summary.doneTss > 0)
                                  Text(
                                    summary.plannedTss > 0
                                        ? l10n.dayCardLoadOfPlanned(
                                            summary.doneTss,
                                            summary.plannedTss,
                                          )
                                        : l10n.dayCardLoadDone(summary.doneTss),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (hasAny)
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                for (final e in dayEvents)
                                  ExcludeSemantics(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          eventCategoryIcon(e.category),
                                          size: 16,
                                          color: eventCategoryColor(
                                            e.category,
                                            colorScheme,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          e.name ??
                                              eventCategoryLabel(
                                                l10n,
                                                e.category,
                                              ),
                                          style: theme.textTheme.labelSmall,
                                        ),
                                        if (countdown != null &&
                                            countdown > 0 &&
                                            isRaceCategory(e.category))
                                          Text(
                                            ' · ${l10n.calRaceInDays(countdown)}',
                                            style: theme.textTheme.labelSmall,
                                          ),
                                      ],
                                    ),
                                  ),
                                for (final event in events)
                                  PlannedDragSource(
                                    key: ValueKey('week-planned-${event.id}'),
                                    event: event,
                                    mover: mover,
                                    child: _SessionBlock(
                                      type: event.type,
                                      seconds: event.plannedTime,
                                      // TriIQ plan sessions vs Intervals.icu.
                                      color: event.isPlanSession
                                          ? colorScheme.secondary
                                          : colorScheme.tertiary,
                                    ),
                                  ),
                                for (final activity in activities)
                                  _SessionBlock(
                                    type: activity.type,
                                    seconds: activity.movingTime,
                                    color: colorScheme.primary,
                                  ),
                              ],
                            )
                          else
                            ExcludeSemantics(
                              child: Text(
                                l10n.noTrainingData,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A session as a block whose width follows its duration.
class _SessionBlock extends StatelessWidget {
  const _SessionBlock({
    required this.type,
    required this.seconds,
    required this.color,
  });

  final String? type;
  final int? seconds;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final minutes = (seconds ?? 0) ~/ 60;
    final width = (28 + minutes * 0.5).clamp(32.0, 110.0);
    return ExcludeSemantics(
      child: Container(
        constraints: BoxConstraints(minWidth: width, minHeight: 24),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          border: Border.all(color: color, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(activityTypeIcon(type), size: 14, color: color),
            if (minutes > 0) ...[
              const SizedBox(width: 3),
              Text(
                '$minutes′',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The week's planned vs. done load and hours, and a ring per sport.
class _WeekSummaryCard extends StatelessWidget {
  const _WeekSummaryCard({required this.summary, this.onWeekActions});

  final PeriodSummary summary;
  final VoidCallback? onWeekActions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    String hours(int minutes) => (minutes / 60).toStringAsFixed(1);
    final sports = [
      for (final s in CalendarSport.values)
        if ((summary.plannedMinutesBySport[s] ?? 0) > 0 ||
            (summary.doneMinutesBySport[s] ?? 0) > 0)
          s,
    ];
    return Card(
      key: const ValueKey('week-summary'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.calWeekPlanned(
                          summary.plannedTss,
                          hours(summary.plannedMinutes),
                        ),
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        l10n.calWeekDone(
                          summary.doneTss,
                          hours(summary.doneMinutes),
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onWeekActions != null)
                  IconButton(
                    key: const ValueKey('week-actions-button'),
                    tooltip: l10n.calWeekActions,
                    onPressed: onWeekActions,
                    icon: const Icon(Icons.more_horiz),
                  ),
              ],
            ),
            if (sports.isNotEmpty) ...[
              const SizedBox(height: 8),
              MediaQuery.withClampedTextScaling(
                maxScaleFactor: 1.2,
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    for (final s in sports)
                      SizedBox(
                        width: 80,
                        child: ProgressRing(
                          size: 60,
                          strokeWidth: 5,
                          label: calendarSportLabel(l10n, s),
                          percentLabel:
                              (summary.plannedMinutesBySport[s] ?? 0) > 0
                              ? '${((summary.doneMinutesBySport[s] ?? 0) * 100 / summary.plannedMinutesBySport[s]!).round()}%'
                              : '–',
                          valueLabel:
                              '${hours(summary.doneMinutesBySport[s] ?? 0)} / '
                              '${hours(summary.plannedMinutesBySport[s] ?? 0)} h',
                          progress: (summary.plannedMinutesBySport[s] ?? 0) > 0
                              ? (summary.doneMinutesBySport[s] ?? 0) /
                                    summary.plannedMinutesBySport[s]!
                              : ((summary.doneMinutesBySport[s] ?? 0) > 0
                                    ? 1
                                    : 0),
                          color: calendarSportColor(s, scheme),
                          doneColor: calendarSportColor(s, scheme),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
