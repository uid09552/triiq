import 'package:flutter/material.dart';

/// Week list of planned vs. completed trainings, one row per day.
///
/// TODO: wire up to lib/client/intervalls (BibliothekApi for planned
/// workouts/events, AktivittenApi for completed activities in the week).
class WeeklyCalendarView extends StatelessWidget {
  const WeeklyCalendarView({super.key});

  static const _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _days.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) => Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.circle_outlined,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          title: Text(
            _days[index],
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: const Text('No training data'),
        ),
      ),
    );
  }
}
