import 'package:flutter/material.dart';

import 'monthly_calendar_view.dart';
import 'weekly_calendar_view.dart';

enum CalendarViewMode { month, week }

/// Training calendar: monthly view switchable to a weekly view, showing
/// both proposed (planned) and passed (completed) trainings.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarViewMode _mode = CalendarViewMode.month;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SegmentedButton<CalendarViewMode>(
            segments: const [
              ButtonSegment(
                value: CalendarViewMode.month,
                label: Text('Month'),
                icon: Icon(Icons.calendar_view_month),
              ),
              ButtonSegment(
                value: CalendarViewMode.week,
                label: Text('Week'),
                icon: Icon(Icons.calendar_view_week),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (selection) =>
                setState(() => _mode = selection.first),
          ),
        ),
        Expanded(
          child: switch (_mode) {
            CalendarViewMode.month => const MonthlyCalendarView(),
            CalendarViewMode.week => const WeeklyCalendarView(),
          },
        ),
      ],
    );
  }
}
