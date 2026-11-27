import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/local_activity.dart';
import '../../data/models/local_event.dart';
import '../../l10n/app_localizations.dart';
import 'calendar_day_marker.dart';
import '../../util/dates.dart';
import '../../plan/risk_forecast.dart';
import 'calendar_level.dart' show isoWeekNumber;
import 'risk_badge.dart';

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
    this.riskByDate = const {},
  });

  /// Days ahead flagged by the load forecast.
  final Map<String, DayRiskInfo> riskByDate;

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
      final planned = (eventsByDate[key] ?? const []).where(
        (e) => e.isTraining,
      );
      if (planned.isNotEmpty ||
          (activitiesByDate[key] ?? const []).isNotEmpty) {
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
        for (final (i, date) in days.indexed) ...[
          if (i == 0 || startOfWeek(date) != startOfWeek(days[i - 1]))
            _weekHeader(context, l10n, startOfWeek(date)),
          Semantics(
            button: true,
            label: _rowLabel(l10n, locale, date),
            excludeSemantics: true,
            child: InkWell(
              key: ValueKey('agenda-${isoDate(date)}'),
              onTap: () => onSelect(date),
              onLongPress: onLongPress == null
                  ? null
                  : () => onLongPress!(date),
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
                                      ? FontWeight.w700
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
                          if (riskByDate[isoDate(date)] case final risk?)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  RiskBadge(info: risk, size: 16),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      riskLabel(l10n, risk),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          for (final e
                              in (eventsByDate[isoDate(date)] ?? const [])
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
                          for (final a
                              in activitiesByDate[isoDate(date)] ??
                                  const <LocalActivity>[])
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
          ),
        ],
      ],
    );
  }

  String _rowLabel(AppLocalizations l10n, String locale, DateTime date) {
    final key = isoDate(date);
    final names = [
      for (final e in (eventsByDate[key] ?? const <LocalEvent>[]).where(
        (e) => e.isTraining,
      ))
        l10n.agendaPlannedItem(e.name ?? e.type ?? ''),
      for (final a in activitiesByDate[key] ?? const <LocalActivity>[])
        l10n.agendaDoneItem(a.name ?? a.type ?? ''),
      if (riskByDate[key] case final r?) riskLabel(l10n, r),
    ];
    return '${DateFormat.MMMMEEEEd(locale).format(date)}: ${names.join(', ')}';
  }

  /// "Week 47 · planned 6:30 h · done 4:10 h" over the whole ISO week.
  Widget _weekHeader(
    BuildContext context,
    AppLocalizations l10n,
    DateTime monday,
  ) {
    var planned = 0, done = 0;
    for (var d = 0; d < 7; d++) {
      final key = isoDate(monday.add(Duration(days: d)));
      for (final e in eventsByDate[key] ?? const <LocalEvent>[]) {
        if (e.isTraining) planned += e.plannedTime ?? 0;
      }
      for (final a in activitiesByDate[key] ?? const <LocalActivity>[]) {
        done += a.movingTime ?? 0;
      }
    }
    String h(int secs) =>
        '${secs ~/ 3600}:${((secs % 3600) ~/ 60).toString().padLeft(2, '0')}';
    return Padding(
      key: ValueKey('agenda-week-${isoDate(monday)}'),
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        l10n.agendaWeekTotals(isoWeekNumber(monday), h(planned), h(done)),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
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
