import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/local_activity.dart';
import '../../data/models/local_event.dart';
import '../../l10n/app_localizations.dart';
import 'calendar_day_marker.dart';
import 'calendar_data.dart';

/// The month as a vertical list of only the days that have a session, planned
/// or done: easier to read on a phone than a grid of tiny cells.
class AgendaView extends StatelessWidget {
  const AgendaView({
    super.key,
    required this.month,
    required this.eventsByDate,
    required this.activitiesByDate,
    required this.onSelect,
    this.onLongPress,
    this.today,
  });

  final DateTime month;
  final Map<String, List<LocalEvent>> eventsByDate;
  final Map<String, List<LocalActivity>> activitiesByDate;
  final ValueChanged<DateTime> onSelect;
  final ValueChanged<DateTime>? onLongPress;
  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final days = <DateTime>[];
    final last = DateTime(month.year, month.month + 1, 0).day;
    for (var d = 1; d <= last; d++) {
      final date = DateTime(month.year, month.month, d);
      final key = isoDate(date);
      final planned = (eventsByDate[key] ?? const []).where((e) => e.isTraining);
      if (planned.isNotEmpty || (activitiesByDate[key] ?? const []).isNotEmpty) {
        days.add(date);
      }
    }
    if (days.isEmpty) {
      return Padding(
        key: const ValueKey('agenda-empty'),
        padding: const EdgeInsets.all(24),
        child: Center(child: Text(l10n.agendaEmpty)),
      );
    }
    final now = today == null ? null : dateOnly(today!);
    return ListView(
      key: const ValueKey('agenda-list'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: [
        for (final date in days)
          InkWell(
            key: ValueKey('agenda-${isoDate(date)}'),
            onTap: () => onSelect(date),
            onLongPress: onLongPress == null ? null : () => onLongPress!(date),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 56,
                    child: Column(
                      children: [
                        Text(
                          DateFormat.E(locale).format(date),
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        Text(
                          '${date.day}',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: date == now ? scheme.primary : null,
                                fontWeight: date == now
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final e in (eventsByDate[isoDate(date)] ?? const [])
                            .where((e) => e.isTraining))
                          _row(
                            context,
                            CalendarDayMarker(
                              type: e.type,
                              size: 22,
                              color: e.isPlanSession
                                  ? scheme.secondary
                                  : scheme.tertiary,
                              kind: e.isPlanSession
                                  ? MarkerKind.triiqPlan
                                  : MarkerKind.planned,
                            ),
                            e.name ?? e.type ?? '',
                          ),
                        for (final a in activitiesByDate[isoDate(date)] ?? const <LocalActivity>[])
                          _row(
                            context,
                            CalendarDayMarker(
                              type: a.type,
                              size: 22,
                              color: scheme.primary,
                            ),
                            a.name ?? a.type ?? '',
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _row(BuildContext context, Widget marker, String label) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        marker,
        const SizedBox(width: 8),
        Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    ),
  );
}
