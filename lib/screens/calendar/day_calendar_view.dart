import 'package:flutter/material.dart';

import '../../data/models/local_activity.dart';
import '../../data/models/local_event.dart';
import '../../data/models/local_wellness.dart';
import '../../evaluation/readiness.dart';
import '../../l10n/app_localizations.dart';
import '../../util/dates.dart';
import '../today/readiness_card.dart' show readinessColor, readinessLevelLabel;
import 'calendar_day_detail.dart';
import 'calendar_moves.dart';
import 'day_cell_parts.dart';

/// One day, full width: the day's readiness, HRV, resting HR, sleep and
/// feel, then its sessions (swipe a planned one left to delete, a completed
/// one right for "How did it feel?"; long-press to drag, or "Move to…").
class DayCalendarView extends StatelessWidget {
  const DayCalendarView({
    super.key,
    required this.date,
    required this.events,
    required this.activities,
    this.dayEvents = const [],
    this.readiness,
    this.wellness,
    this.mover,
    this.onMove,
    this.today,
  });

  final DateTime date;
  final List<LocalEvent> events;
  final List<LocalActivity> activities;
  final List<LocalEvent> dayEvents;
  final Readiness? readiness;
  final LocalWellness? wellness;
  final CalendarMover? mover;
  final ValueChanged<LocalEvent>? onMove;
  final DateTime Function()? today;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final now = dateOnly((today ?? DateTime.now)());
    final raw = wellness?.raw ?? const <String, dynamic>{};
    num? n(Object? v) => v is num && v > 0 ? v : null;
    final hrv = n(raw['hrv']);
    final rhr = n(raw['restingHR']);
    final sleep = n(raw['sleepSecs']);
    final fatigue = n(raw['fatigue']);
    final soreness = n(raw['soreness']);
    final countdown = raceCountdown(date, dayEvents, now);
    final pills = <Widget>[
      if (readiness != null && !date.isAfter(now))
        _Pill(
          key: const ValueKey('day-readiness'),
          color: readinessColor(scheme, readiness!.level),
          text: l10n.calReadiness(readinessLevelLabel(l10n, readiness!.level)),
          leading: ReadinessDot(level: readiness!.level, size: 8),
        ),
      if (hrv != null)
        _Pill(color: scheme.primary, text: l10n.calWellnessHrv(hrv.round())),
      if (rhr != null)
        _Pill(color: scheme.primary, text: l10n.calWellnessRhr(rhr.round())),
      if (sleep != null)
        _Pill(
          color: scheme.primary,
          text: l10n.calWellnessSleep((sleep / 3600).toStringAsFixed(1)),
        ),
      if (fatigue != null || soreness != null)
        _Pill(
          color: scheme.tertiary,
          text: l10n.calWellnessFeel(
            fatigue?.round().toString() ?? '–',
            soreness?.round().toString() ?? '–',
          ),
        ),
      if (countdown != null && countdown > 0)
        _Pill(
          color: Colors.amber.shade800,
          text: l10n.calRaceInDays(countdown),
          leading: Icon(Icons.flag, size: 14, color: Colors.amber.shade800),
        ),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (pills.isNotEmpty) ...[
            Wrap(spacing: 6, runSpacing: 6, children: pills),
            const SizedBox(height: 10),
          ],
          CalendarDayDetail(
            date: date,
            events: events,
            dayEvents: dayEvents,
            activities: activities,
            today: today,
            mover: mover,
            onMove: onMove,
            swipeActions: true,
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    super.key,
    required this.color,
    required this.text,
    this.leading,
  });

  final Color color;
  final String text;
  final Widget? leading;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 6)],
        Flexible(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
