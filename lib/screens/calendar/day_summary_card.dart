import 'package:flutter/material.dart';

import '../../data/models/local_activity.dart';
import '../../data/models/local_event.dart';
import '../../data/models/local_wellness.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/peekable.dart';
import 'calendar_data.dart';
import 'day_cell_parts.dart';

/// The day view's statistics: done against planned load, time and sessions,
/// the per-sport minutes bar the month cells show, and the week so far.
/// Hold it for the details: per sport, per session, fitness and the week.
class DaySummaryCard extends StatelessWidget {
  const DaySummaryCard({
    super.key,
    required this.events,
    required this.activities,
    this.dayEvents = const [],
    this.wellness,
    this.week,
  });

  final List<LocalEvent> events;
  final List<LocalActivity> activities;
  final List<LocalEvent> dayEvents;
  final LocalWellness? wellness;

  /// The week the day is in, Monday to Sunday.
  final PeriodSummary? week;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final s = DaySummary.of(events, activities, dayEvents: dayEvents);
    final plannedMin = s.plannedMinutes.values.fold(0, (a, b) => a + b);
    final doneMin = s.doneMinutes.values.fold(0, (a, b) => a + b);
    final ratio = s.plannedTss > 0 ? s.doneTss / s.plannedTss : null;
    final accent = switch (s.fill) {
      DayFill.over => scheme.tertiary,
      DayFill.partial => Colors.amber.shade700,
      _ => scheme.primary,
    };

    Widget stat(String label, String value, {Key? key}) => Expanded(
      child: Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );

    String ofPlanned(num done, num planned, String unit) =>
        planned > 0 ? '$done / $planned $unit' : '$done $unit';

    final card = Card(
      key: const ValueKey('day-summary'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: s.isEmpty
            ? Text(
                l10n.calDayStatsRest,
                key: const ValueKey('day-summary-rest'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      stat(
                        l10n.calDayStatsLoad,
                        ofPlanned(s.doneTss, s.plannedTss, 'TSS'),
                        key: const ValueKey('day-summary-load'),
                      ),
                      stat(
                        l10n.calDayStatsTime,
                        ofPlanned(doneMin, plannedMin, 'min'),
                      ),
                      stat(
                        l10n.calDayStatsSessions,
                        ofPlanned(s.doneCount, s.plannedCount, ''),
                      ),
                      if (ratio != null)
                        Container(
                          key: const ValueKey('day-summary-percent'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${(ratio * 100).round()}%',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (ratio != null) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: ratio.clamp(0.0, 1.0),
                        minHeight: 5,
                        color: accent,
                        backgroundColor: scheme.surfaceContainerHighest,
                      ),
                    ),
                  ],
                  if (plannedMin > 0 || doneMin > 0) ...[
                    const SizedBox(height: 8),
                    SportMinutesBar(summary: s, height: 5),
                  ],
                  if (week case final w?) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.calDayStatsWeek(
                        w.doneTss,
                        w.plannedTss,
                        (w.doneMinutes / 60).toStringAsFixed(1),
                      ),
                      key: const ValueKey('day-summary-week'),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );

    return Peekable(
      estimatedHeight: 360,
      preview: (context) => DaySummaryDetails(
        summary: s,
        events: events,
        activities: activities,
        wellness: wellness,
        week: week,
      ),
      child: card,
    );
  }
}

/// The day's details, floated over the day view by a long press.
class DaySummaryDetails extends StatelessWidget {
  const DaySummaryDetails({
    super.key,
    required this.summary,
    required this.events,
    required this.activities,
    this.wellness,
    this.week,
  });

  final DaySummary summary;
  final List<LocalEvent> events;
  final List<LocalActivity> activities;
  final LocalWellness? wellness;
  final PeriodSummary? week;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final heading = theme.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w700,
    );
    String mins(int? secs) =>
        secs == null || secs <= 0 ? '' : ' · ${(secs / 60).round()} min';
    String tss(int? load) => load == null ? '' : ' · $load TSS';
    String km(double? metres) => metres == null || metres <= 0
        ? ''
        : ' · ${(metres / 1000).toStringAsFixed(1)} km';

    final sports = <CalendarSport>{
      ...summary.plannedMinutes.keys,
      ...summary.doneMinutes.keys,
    };
    final planned = events.where((e) => e.isTraining).toList();
    final ctl = wellness?.ctl, atl = wellness?.atl;
    final ramp = wellness?.raw['rampRate'];

    return Column(
      key: const ValueKey('day-summary-details'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sports.isNotEmpty) ...[
          Text(l10n.calDayPeekSports, style: heading),
          const SizedBox(height: 4),
          for (final sport in CalendarSport.values)
            if (sports.contains(sport))
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: calendarSportColor(sport, scheme),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(child: Text(calendarSportLabel(l10n, sport))),
                    Text(
                      l10n.calDayPeekMinutes(
                        summary.doneMinutes[sport] ?? 0,
                        summary.plannedMinutes[sport] ?? 0,
                      ),
                      style: theme.textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
          const SizedBox(height: 8),
        ],
        if (planned.isNotEmpty) ...[
          Text(l10n.calDayPeekPlanned, style: heading),
          for (final e in planned)
            Text(
              '${e.name ?? e.type ?? ''}${mins(e.plannedTime)}${tss(e.plannedLoad)}',
              style: muted,
            ),
          const SizedBox(height: 8),
        ],
        if (activities.isNotEmpty) ...[
          Text(l10n.calDayPeekDone, style: heading),
          for (final a in activities)
            Text(
              '${a.name ?? a.type ?? ''}${mins(a.movingTime)}'
              '${km(a.distance)}${tss(a.trainingLoad)}',
              style: muted,
            ),
          const SizedBox(height: 8),
        ],
        if (ctl != null && atl != null) ...[
          Text(l10n.calDayPeekFitness, style: heading),
          Text(
            l10n.calDayPeekForm(
              ctl.round(),
              atl.round(),
              '${ctl - atl >= 0 ? '+' : '−'}${(ctl - atl).abs().round()}',
            ),
            key: const ValueKey('day-summary-form'),
            style: muted,
          ),
          if (ramp is num)
            Text(l10n.calDayPeekRamp(ramp.toStringAsFixed(1)), style: muted),
          const SizedBox(height: 8),
        ],
        if (week case final w?) ...[
          Text(l10n.calDayPeekWeek, style: heading),
          Text(
            l10n.calDayPeekWeekLine(
              w.doneTss,
              w.plannedTss,
              (w.doneMinutes / 60).toStringAsFixed(1),
              (w.plannedMinutes / 60).toStringAsFixed(1),
              w.doneCount,
              w.plannedCount,
            ),
            style: muted,
          ),
        ],
        if (summary.isEmpty && ctl == null && week == null)
          Text(l10n.calDayStatsRest, style: muted),
      ],
    );
  }
}
