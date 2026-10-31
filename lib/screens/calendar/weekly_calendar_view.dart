import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../data/models/local_activity.dart';
import '../../data/models/local_event.dart';
import '../../l10n/app_localizations.dart';
import 'calendar_day_marker.dart';

/// Week list of planned (tertiary colour) vs. completed (primary colour)
/// trainings, one row per day.
class WeeklyCalendarView extends StatelessWidget {
  const WeeklyCalendarView({
    super.key,
    required this.weekStart,
    required this.selectedDate,
    required this.eventsByDate,
    required this.activitiesByDate,
    required this.onSelect,
  });

  /// Monday of the displayed week.
  final DateTime weekStart;
  final DateTime selectedDate;
  final Map<String, List<LocalEvent>> eventsByDate;
  final Map<String, List<LocalActivity>> activitiesByDate;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final today = _dateOnly(DateTime.now());
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 7,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final date = weekStart.add(Duration(days: index));
        final isToday = _dateOnly(date) == today;
        final isSelected = _dateOnly(date) == _dateOnly(selectedDate);
        final key = _fmt(date);
        final events = (eventsByDate[key] ?? const [])
            .where((e) => e.isTraining)
            .toList();
        final activities = activitiesByDate[key] ?? const [];
        final hasAny = events.isNotEmpty || activities.isNotEmpty;

        return Card(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.08)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isToday
                ? BorderSide(color: colorScheme.primary, width: 1.5)
                : BorderSide.none,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => onSelect(date),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Column(
                      children: [
                        Text(
                          '${date.day}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat.EEEE(locale).format(date),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        if (hasAny)
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              for (final event in events)
                                CalendarDayMarker(
                                  type: event.type,
                                  // TriIQ plan sessions vs Intervals.icu events.
                                  color: event.isPlanSession
                                      ? colorScheme.secondary
                                      : colorScheme.tertiary,
                                ),
                              for (final activity in activities)
                                CalendarDayMarker(
                                  type: activity.type,
                                  color: colorScheme.primary,
                                ),
                            ],
                          )
                        else
                          Text(
                            l10n.noTrainingData,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static String _fmt(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
