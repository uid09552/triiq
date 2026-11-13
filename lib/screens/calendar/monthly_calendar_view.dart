import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../data/models/local_activity.dart';
import '../../data/models/local_event.dart';
import '../../evaluation/readiness.dart';
import '../../l10n/app_localizations.dart';
import '../../util/dates.dart';
import 'calendar_data.dart';
import 'calendar_day_marker.dart';
import 'calendar_drag.dart';
import 'calendar_level.dart';
import 'calendar_moves.dart';
import 'day_cell_parts.dart';
import 'day_events.dart';

const _maxMarkersPerCell = 3;
const _weekColumnWidth = 22.0;

/// Month grid of planned (tertiary colour) vs. completed (primary colour)
/// trainings, each day carrying a tiny icon per session, a fill for done
/// against planned load, a per-sport minutes bar, a readiness dot and
/// badges. A week-number column opens (tap) or acts on (long-press) a week.
class MonthlyCalendarView extends StatelessWidget {
  const MonthlyCalendarView({
    super.key,
    required this.month,
    required this.selectedDate,
    required this.eventsByDate,
    required this.activitiesByDate,
    required this.onSelect,
    this.dayEventsByDate = const {},
    this.readinessByDate = const {},
    this.onLongPress,
    this.onOpenWeek,
    this.onWeekLongPress,
    this.onDrop,
    this.mover,
    this.compact = true,
    this.today,
  });

  /// Sick days, notes, holidays, races, … by every day they cover.
  final Map<String, List<LocalEvent>> dayEventsByDate;

  /// Readiness for days with wearable data.
  final Map<String, Readiness> readinessByDate;

  /// Long-press on a day, e.g. to offer clearing it.
  final ValueChanged<DateTime>? onLongPress;

  /// Tap / long-press on a week number (the week's Monday).
  final ValueChanged<DateTime>? onOpenWeek;
  final ValueChanged<DateTime>? onWeekLongPress;

  /// A planned session dropped on a day.
  final PlannedDrop? onDrop;

  /// Which sessions may be dragged from a cell.
  final CalendarMover? mover;

  /// Square cells (true) or taller ones with room for more markers.
  final bool compact;

  /// Test seam for "now".
  final DateTime Function()? today;

  /// Any day within the month to display — only year/month are used.
  final DateTime month;
  final DateTime selectedDate;
  final Map<String, List<LocalEvent>> eventsByDate;
  final Map<String, List<LocalActivity>> activitiesByDate;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final firstOfMonth = DateTime(month.year, month.month, 1);
    final (gridStart, _) = calendarRange(CalendarLevel.month, firstOfMonth);
    final now = dateOnly((today ?? DateTime.now)());
    final locale = Localizations.localeOf(context).toString();
    // A reference Monday-start week, so the header always reads Mon..Sun.
    final weekdayLabels = [
      for (var i = 0; i < 7; i++)
        DateFormat.E(locale).format(DateTime(2024, 1, 1 + i)),
    ];
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.3,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cellWidth = (constraints.maxWidth - _weekColumnWidth) / 7;
            final cellHeight = cellWidth / (compact ? 1.05 : 0.84);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const SizedBox(width: _weekColumnWidth),
                    for (final label in weekdayLabels)
                      Expanded(
                        child: ExcludeSemantics(
                          child: Center(child: Text(label, style: labelStyle)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                for (var week = 0; week < 6; week++)
                  SizedBox(
                    height: cellHeight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _WeekNumberCell(
                          monday: DateTime(
                            gridStart.year,
                            gridStart.month,
                            gridStart.day + 7 * week,
                          ),
                          onTap: onOpenWeek,
                          onLongPress: onWeekLongPress,
                          style: labelStyle,
                        ),
                        for (var i = 0; i < 7; i++)
                          Expanded(
                            child: _cell(
                              context,
                              l10n,
                              DateTime(
                                gridStart.year,
                                gridStart.month,
                                gridStart.day + 7 * week + i,
                              ),
                              firstOfMonth,
                              now,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _cell(
    BuildContext context,
    AppLocalizations l10n,
    DateTime date,
    DateTime firstOfMonth,
    DateTime now,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final key = isoDate(date);
    final events = eventsByDate[key] ?? const <LocalEvent>[];
    final activities = activitiesByDate[key] ?? const <LocalActivity>[];
    final dayEvents = dayEventsByDate[key] ?? const <LocalEvent>[];
    final summary = DaySummary.of(events, activities, dayEvents: dayEvents);
    final readiness = date.isAfter(now) ? null : readinessByDate[key];
    final planned = [
      for (final e in events)
        if (e.isTraining && !isRaceCategory(e.category)) e,
    ];
    return DayDropTarget(
      date: date,
      onDrop: onDrop,
      builder: (context, hovering) => _DayCell(
        date: date,
        inMonth: date.month == firstOfMonth.month,
        isToday: date == now,
        isSelected: date == dateOnly(selectedDate),
        planned: planned,
        activities: activities,
        dayEvents: dayEvents,
        summary: summary,
        readiness: readiness?.level,
        hovering: hovering != null,
        compact: compact,
        mover: mover,
        semanticLabel: daySemanticLabel(
          context,
          date,
          summary,
          readiness: readiness?.level,
          dayEvents: dayEvents,
          today: now,
        ),
        onTap: () => onSelect(date),
        onLongPress: onLongPress == null ? null : () => onLongPress!(date),
        colorScheme: colorScheme,
      ),
    );
  }
}

class _WeekNumberCell extends StatelessWidget {
  const _WeekNumberCell({
    required this.monday,
    required this.onTap,
    required this.onLongPress,
    required this.style,
  });

  final DateTime monday;
  final ValueChanged<DateTime>? onTap;
  final ValueChanged<DateTime>? onLongPress;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final week = isoWeekNumber(monday);
    return SizedBox(
      width: _weekColumnWidth,
      child: Semantics(
        button: onTap != null,
        label: l10n.calBreadcrumbWeek(week),
        excludeSemantics: true,
        onLongPressHint: onLongPress == null ? null : l10n.calWeekActions,
        child: InkWell(
          key: ValueKey('week-number-${isoDate(monday)}'),
          borderRadius: BorderRadius.circular(8),
          onTap: onTap == null ? null : () => onTap!(monday),
          onLongPress: onLongPress == null ? null : () => onLongPress!(monday),
          child: Center(child: Text('$week', style: style)),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.inMonth,
    required this.isToday,
    required this.isSelected,
    required this.planned,
    required this.activities,
    required this.dayEvents,
    required this.summary,
    required this.readiness,
    required this.hovering,
    required this.compact,
    required this.mover,
    required this.semanticLabel,
    required this.onTap,
    required this.onLongPress,
    required this.colorScheme,
  });

  final DateTime date;
  final bool inMonth;
  final bool isToday;
  final bool isSelected;
  final List<LocalEvent> planned;
  final List<LocalActivity> activities;
  final List<LocalEvent> dayEvents;
  final DaySummary summary;
  final ReadinessLevel? readiness;
  final bool hovering;
  final bool compact;
  final CalendarMover? mover;
  final String semanticLabel;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final maxMarkers = compact ? _maxMarkersPerCell : _maxMarkersPerCell + 2;
    final markers = <Widget>[
      for (final e in planned)
        PlannedDragSource(
          key: ValueKey('cell-planned-${e.id}'),
          event: e,
          mover: mover,
          child: CalendarDayMarker(
            type: e.type,
            // TriIQ plan sessions vs Intervals.icu events.
            color: e.isPlanSession
                ? colorScheme.secondary
                : colorScheme.tertiary,
            size: 12,
          ),
        ),
      for (final a in activities)
        CalendarDayMarker(type: a.type, color: colorScheme.primary, size: 12),
    ];
    final overflow = markers.length > maxMarkers;
    final tint = dayEvents.where((e) => tintsDay(e.category)).firstOrNull;
    final fill = tint != null
        ? eventCategoryColor(tint.category, colorScheme).withValues(alpha: 0.10)
        : dayFillColor(summary.fill, colorScheme);

    return Semantics(
      label: semanticLabel,
      button: true,
      selected: isSelected,
      excludeSemantics: true,
      onLongPressHint: onLongPress == null
          ? null
          : AppLocalizations.of(context)!.calDayActions,
      child: InkWell(
        key: ValueKey('day-cell-${isoDate(date)}'),
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          key: ValueKey('day-fill-${summary.fill.name}-${isoDate(date)}'),
          margin: const EdgeInsets.all(1),
          padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
          decoration: BoxDecoration(
            color: hovering
                ? colorScheme.primary.withValues(alpha: 0.25)
                : fill,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: colorScheme.primary, width: 2)
                : hovering
                ? Border.all(color: colorScheme.primary, width: 1.5)
                : isToday
                ? Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.6),
                    width: 1.5,
                  )
                : null,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 9,
                    child: DayBadge(summary: summary, size: 9),
                  ),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isToday
                              ? FontWeight.w800
                              : FontWeight.w500,
                          color: isToday
                              ? colorScheme.primary
                              : inMonth
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.4,
                                ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 6,
                    child: readiness == null
                        ? null
                        : ReadinessDot(level: readiness!, size: 6),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Expanded(
                child: ClipRect(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 2,
                    runSpacing: 2,
                    children: [
                      for (final e in dayEvents.take(2))
                        Icon(
                          eventCategoryIcon(e.category),
                          key: ValueKey('day-event-${e.id}'),
                          size: 12,
                          color: eventCategoryColor(e.category, colorScheme),
                        ),
                      ...markers.take(maxMarkers),
                      if (overflow)
                        Text(
                          '+${markers.length - maxMarkers}',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SportMinutesBar(summary: summary, height: 2),
            ],
          ),
        ),
      ),
    );
  }
}
