import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/local_event.dart';
import '../../evaluation/readiness.dart';
import '../../l10n/app_localizations.dart';
import '../../util/dates.dart';
import '../activities/activity_icons.dart';
import '../today/readiness_card.dart' show readinessColor, readinessLevelLabel;
import 'calendar_data.dart';
import 'day_events.dart';

/// The sport's colour, as everywhere else in the app.
Color calendarSportColor(CalendarSport sport, ColorScheme scheme) =>
    switch (sport) {
      CalendarSport.swim => sportColor('Swim', scheme),
      CalendarSport.ride => sportColor('Ride', scheme),
      CalendarSport.run => sportColor('Run', scheme),
      CalendarSport.strength => scheme.tertiary,
      CalendarSport.other => scheme.outline,
    };

String calendarSportLabel(AppLocalizations l10n, CalendarSport sport) =>
    switch (sport) {
      CalendarSport.swim => l10n.sportSwim,
      CalendarSport.ride => l10n.sportRide,
      CalendarSport.run => l10n.sportRun,
      CalendarSport.strength => l10n.sportStrength,
      CalendarSport.other => l10n.calSportOther,
    };

/// The cell fill for done against planned load: nothing for an empty day,
/// a faint wash for planned-not-done, stronger as more is done, and the
/// tertiary colour when the plan was overshot.
Color? dayFillColor(DayFill fill, ColorScheme scheme) => switch (fill) {
  DayFill.none => null,
  DayFill.empty => scheme.secondary.withValues(alpha: 0.06),
  DayFill.partial => scheme.primary.withValues(alpha: 0.12),
  DayFill.done => scheme.primary.withValues(alpha: 0.22),
  DayFill.over => scheme.tertiary.withValues(alpha: 0.28),
};

/// Green / amber / red readiness for a day.
class ReadinessDot extends StatelessWidget {
  const ReadinessDot({super.key, required this.level, this.size = 6});

  final ReadinessLevel level;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    key: ValueKey('readiness-dot-${level.name}'),
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: readinessColor(Theme.of(context).colorScheme, level),
      shape: BoxShape.circle,
    ),
  );
}

/// One badge per day, most important first: a key session (star) or a
/// strength session (dumbbell). Races carry their own flag icon.
class DayBadge extends StatelessWidget {
  const DayBadge({super.key, required this.summary, this.size = 10});

  final DaySummary summary;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (summary.hasKey) {
      return Icon(
        Icons.star,
        key: const ValueKey('badge-key'),
        size: size,
        color: Colors.amber.shade700,
      );
    }
    if (summary.hasStrength) {
      return Icon(
        Icons.fitness_center,
        key: const ValueKey('badge-strength'),
        size: size,
        color: scheme.tertiary,
      );
    }
    return const SizedBox.shrink();
  }
}

/// A thin two-line bar per sport: planned minutes on top (faint), done
/// minutes below (solid), both on one scale.
class SportMinutesBar extends StatelessWidget {
  const SportMinutesBar({super.key, required this.summary, this.height = 2});

  final DaySummary summary;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final planned = summary.plannedMinutes.values.fold(0, (a, b) => a + b);
    final done = summary.doneMinutes.values.fold(0, (a, b) => a + b);
    final scale = planned > done ? planned : done;
    if (scale <= 0) return SizedBox(height: height * 2 + 1);

    Widget line(Map<CalendarSport, int> minutes, double alpha) {
      final total = minutes.values.fold(0, (a, b) => a + b);
      return SizedBox(
        height: height,
        child: Row(
          children: [
            for (final sport in CalendarSport.values)
              if ((minutes[sport] ?? 0) > 0)
                Expanded(
                  flex: minutes[sport]!,
                  child: ColoredBox(
                    color: calendarSportColor(
                      sport,
                      scheme,
                    ).withValues(alpha: alpha),
                  ),
                ),
            if (scale > total) Spacer(flex: scale - total),
          ],
        ),
      );
    }

    return ExcludeSemantics(
      child: ClipRRect(
        key: const ValueKey('sport-bar'),
        borderRadius: BorderRadius.circular(height),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            line(summary.plannedMinutes, 0.35),
            const SizedBox(height: 1),
            line(summary.doneMinutes, 1),
          ],
        ),
      ),
    );
  }
}

/// Days until the next race on or after [today] among [dayEvents], or null.
int? raceCountdown(DateTime date, List<LocalEvent> dayEvents, DateTime today) {
  if (!dayEvents.any((e) => isRaceCategory(e.category))) return null;
  final days = dateOnly(date).difference(dateOnly(today)).inDays;
  return days >= 0 ? days : null;
}

/// What a screen reader says for a day cell: the date, then planned and
/// done sessions, load, readiness, race and badges.
String daySemanticLabel(
  BuildContext context,
  DateTime date,
  DaySummary summary, {
  ReadinessLevel? readiness,
  List<LocalEvent> dayEvents = const [],
  DateTime? today,
}) {
  final l10n = AppLocalizations.of(context)!;
  final locale = Localizations.localeOf(context).toString();
  final parts = <String>[DateFormat.MMMMEEEEd(locale).format(date)];
  if (summary.isEmpty) {
    parts.add(l10n.calSemNothing);
  } else {
    if (summary.plannedCount > 0) {
      parts.add(l10n.calSemPlanned(summary.plannedCount));
    }
    if (summary.doneCount > 0) parts.add(l10n.calSemDone(summary.doneCount));
    if (summary.plannedTss > 0) {
      parts.add(l10n.dayCardLoadOfPlanned(summary.doneTss, summary.plannedTss));
    } else if (summary.doneTss > 0) {
      parts.add(l10n.dayCardLoadDone(summary.doneTss));
    }
  }
  if (readiness != null) {
    parts.add(l10n.calReadiness(readinessLevelLabel(l10n, readiness)));
  }
  for (final e in dayEvents) {
    if (e.name != null) parts.add(e.name!);
  }
  final countdown = today == null
      ? null
      : raceCountdown(date, dayEvents, today);
  if (countdown != null && countdown > 0) {
    parts.add(l10n.calRaceInDays(countdown));
  }
  if (summary.hasKey) parts.add(l10n.calSemKey);
  if (summary.hasStrength) parts.add(l10n.calSemStrength);
  return parts.join(', ');
}
