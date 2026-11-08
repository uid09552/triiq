import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../data/models/local_activity.dart';
import '../../data/models/local_event.dart';
import 'calendar_day_marker.dart';
import 'day_events.dart';

const _maxMarkersPerCell = 3;

/// Month grid of planned (tertiary colour) vs. completed (primary colour)
/// trainings, each day carrying a tiny icon per session.
class MonthlyCalendarView extends StatelessWidget {
  const MonthlyCalendarView({
    super.key,
    required this.month,
    required this.selectedDate,
    required this.eventsByDate,
    required this.activitiesByDate,
    required this.onSelect,
    this.dayEventsByDate = const {},
    this.onLongPress,
  });

  /// Sick days, notes, holidays, races, … by every day they cover.
  final Map<String, List<LocalEvent>> dayEventsByDate;

  /// Long-press on a day, e.g. to offer clearing it.
  final ValueChanged<DateTime>? onLongPress;

  /// Any day within the month to display — only year/month are used.
  final DateTime month;
  final DateTime selectedDate;
  final Map<String, List<LocalEvent>> eventsByDate;
  final Map<String, List<LocalActivity>> activitiesByDate;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final firstOfMonth = DateTime(month.year, month.month, 1);
    // Full weeks (Monday-start) covering the month, so the grid is always a
    // clean rectangle even when the month doesn't start on a Monday.
    final gridStart = firstOfMonth.subtract(
      Duration(days: firstOfMonth.weekday - 1),
    );
    final today = _dateOnly(DateTime.now());
    final locale = Localizations.localeOf(context).toString();
    // A reference Monday-start week, so the header always reads Mon..Sun
    // regardless of which week `month` falls in.
    final weekdayLabels = [
      for (var i = 0; i < 7; i++)
        DateFormat.E(locale).format(DateTime(2024, 1, 1 + i)),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              for (final label in weekdayLabels)
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: 42,
          itemBuilder: (context, index) {
            final date = gridStart.add(Duration(days: index));
            final inMonth = date.month == firstOfMonth.month;
            final isToday = _dateOnly(date) == today;
            final isSelected = _dateOnly(date) == _dateOnly(selectedDate);
            final key = _fmt(date);
            final markers = _markersFor(
              colorScheme,
              eventsByDate[key],
              activitiesByDate[key],
            );

            return _DayCell(
              day: date.day,
              inMonth: inMonth,
              isToday: isToday,
              isSelected: isSelected,
              markers: markers,
              dayEvents: dayEventsByDate[key] ?? const [],
              onTap: () => onSelect(date),
              onLongPress: onLongPress == null
                  ? null
                  : () => onLongPress!(date),
            );
          },
        ),
      ],
    );
  }

  static List<(String? type, Color color)> _markersFor(
    ColorScheme colorScheme,
    List<LocalEvent>? events,
    List<LocalActivity>? activities,
  ) {
    final markers = <(String? type, Color color)>[
      for (final event in (events ?? const []).where(
        (e) => e.isTraining && !isRaceCategory(e.category),
      ))
        (
          event.type,
          // TriIQ plan sessions vs Intervals.icu events.
          event.isPlanSession ? colorScheme.secondary : colorScheme.tertiary,
        ),
      for (final activity in activities ?? const [])
        (activity.type, colorScheme.primary),
    ];
    return markers.take(_maxMarkersPerCell + 1).toList();
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static String _fmt(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.inMonth,
    required this.isToday,
    required this.isSelected,
    required this.markers,
    required this.onTap,
    this.dayEvents = const [],
    this.onLongPress,
  });

  final List<LocalEvent> dayEvents;
  final VoidCallback? onLongPress;
  final int day;
  final bool inMonth;
  final bool isToday;
  final bool isSelected;
  final List<(String? type, Color color)> markers;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final overflow = markers.length > _maxMarkersPerCell;
    final shown = overflow ? markers.take(_maxMarkersPerCell) : markers;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.14)
              : dayEvents.any((e) => tintsDay(e.category))
              ? eventCategoryColor(
                  dayEvents.firstWhere((e) => tintsDay(e.category)).category,
                  colorScheme,
                ).withValues(alpha: 0.10)
              : null,
          borderRadius: BorderRadius.circular(12),
          border: isToday
              ? Border.all(color: colorScheme.primary, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                color: inMonth
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 3),
            Wrap(
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
                for (final marker in shown)
                  CalendarDayMarker(
                    type: marker.$1,
                    color: marker.$2,
                    size: 12,
                  ),
                if (overflow)
                  Text(
                    '+${markers.length - _maxMarkersPerCell}',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
