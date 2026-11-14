import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// In race week, this replaces the load tiles: the countdown, where the
/// plan is in its taper, and the form the season forecast expects on the
/// day.
class RaceWeekHeader extends StatelessWidget {
  const RaceWeekHeader({
    super.key,
    required this.days,
    this.phase,
    this.raceDayForm,
  });

  /// Days to the race, 0 on the day.
  final int days;

  /// The plan's phase this week ("Taper", "Race week"), when known.
  final String? phase;

  /// Projected form (CTL − ATL) on race day, when the forecast has one.
  final double? raceDayForm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final form = raceDayForm;
    final details = [
      ?phase,
      if (form != null)
        l10n.raceWeekFormForecast(
          '${form >= 0 ? '+' : ''}${form.toStringAsFixed(0)}',
        ),
    ];
    return Card(
      key: const ValueKey('race-week-header'),
      margin: EdgeInsets.zero,
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            Icon(Icons.flag, color: scheme.onPrimaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.raceWeekTitle.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onPrimaryContainer,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    days == 0
                        ? l10n.todayRaceDay
                        : l10n.todayRaceCountdown(days),
                    key: const ValueKey('race-countdown'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                  if (details.isNotEmpty)
                    Text(
                      details.join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
