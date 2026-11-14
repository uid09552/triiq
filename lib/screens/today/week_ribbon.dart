import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/local_activity.dart';
import '../../data/models/local_event.dart';
import '../../l10n/app_localizations.dart';
import '../../util/dates.dart';
import '../../widgets/main_navigation.dart';

enum RibbonDay { done, planned, missed, rest }

/// What a day of the week looks like on the ribbon: something done, still
/// planned (today or later), planned but not done (earlier), or rest.
RibbonDay ribbonDayStatus(
  DateTime day,
  DateTime today,
  List<LocalActivity> activities,
  List<LocalEvent> events,
) {
  final iso = isoDate(day);
  if (activities.any((a) => a.date == iso)) return RibbonDay.done;
  if (events.any((e) => e.date == iso && e.isTraining)) {
    return dateOnly(day).isBefore(dateOnly(today))
        ? RibbonDay.missed
        : RibbonDay.planned;
  }
  return RibbonDay.rest;
}

/// Mon–Sun as seven dots under the hero: done, planned, missed or rest,
/// today ringed. A tap opens that day in the Calendar.
class WeekRibbon extends StatelessWidget {
  const WeekRibbon({
    super.key,
    required this.today,
    required this.activities,
    required this.events,
  });

  final DateTime today;
  final List<LocalActivity> activities;
  final List<LocalEvent> events;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final monday = startOfWeek(today);

    return Card(
      key: const ValueKey('week-ribbon'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: _DayDot(
                  day: DateTime(monday.year, monday.month, monday.day + i),
                  status: ribbonDayStatus(
                    DateTime(monday.year, monday.month, monday.day + i),
                    today,
                    activities,
                    events,
                  ),
                  isToday:
                      isoDate(
                        DateTime(monday.year, monday.month, monday.day + i),
                      ) ==
                      isoDate(today),
                  locale: locale,
                  l10n: l10n,
                  scheme: scheme,
                  theme: theme,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({
    required this.day,
    required this.status,
    required this.isToday,
    required this.locale,
    required this.l10n,
    required this.scheme,
    required this.theme,
  });

  final DateTime day;
  final RibbonDay status;
  final bool isToday;
  final String locale;
  final AppLocalizations l10n;
  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      RibbonDay.done => l10n.ribbonDone,
      RibbonDay.planned => l10n.ribbonPlanned,
      RibbonDay.missed => l10n.ribbonMissed,
      RibbonDay.rest => l10n.ribbonRest,
    };
    // Shape as well as colour: filled check, outlined ring, cross, dash.
    final Widget dot = switch (status) {
      RibbonDay.done => Icon(
        Icons.check_circle,
        size: 16,
        color: scheme.primary,
      ),
      RibbonDay.planned => Icon(
        Icons.radio_button_unchecked,
        size: 16,
        color: scheme.primary,
      ),
      RibbonDay.missed => Icon(
        Icons.cancel_outlined,
        size: 16,
        color: scheme.error,
      ),
      RibbonDay.rest => Icon(Icons.remove, size: 16, color: scheme.outline),
    };
    final weekday = DateFormat.E(locale).format(day);
    return Semantics(
      button: true,
      selected: isToday,
      label: l10n.ribbonDaySemantics(
        DateFormat.MMMEd(locale).format(day),
        label,
      ),
      excludeSemantics: true,
      child: InkWell(
        key: ValueKey('ribbon-${isoDate(day)}'),
        borderRadius: BorderRadius.circular(10),
        onTap: () => MainNavigation.instance.openCalendar(day),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: isToday
              ? BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                weekday,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                  color: isToday
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              dot,
            ],
          ),
        ),
      ),
    );
  }
}
