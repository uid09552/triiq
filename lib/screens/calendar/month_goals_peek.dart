import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/local_activity.dart';
import '../../l10n/app_localizations.dart';
import '../activities/activity_icons.dart';
import '../settings/year_goals_settings.dart';

/// One sport's numbers for the year view's month peek.
class MonthSportStats {
  const MonthSportStats({
    required this.sport,
    required this.monthKm,
    required this.monthHours,
    required this.monthlyKm,
    this.goalKm,
  });

  /// `swim`, `cycle` or `run`.
  final String sport;
  final double monthKm;
  final double monthHours;

  /// Kilometres per month of the year, January first (12 entries).
  final List<double> monthlyKm;

  /// The year goal, if one is set.
  final double? goalKm;

  /// The month's distance against an even 1/12 of the goal, in percent.
  int? get shareOfMonthlyGoal =>
      goalKm == null ? null : (monthKm / (goalKm! / 12) * 100).round();

  /// Cumulative share of the year goal at the end of each month (0..∞).
  List<double> get cumulativeShare {
    if (goalKm == null) return const [];
    var sum = 0.0;
    return [for (final km in monthlyKm) (sum += km) / goalKm!];
  }
}

const _sports = ['swim', 'cycle', 'run'];

/// Per-sport stats for [month] from the year's activities. A sport shows
/// when it has a goal or any distance/time this year.
List<MonthSportStats> monthSportStats(
  Map<String, List<LocalActivity>> activitiesByDate,
  DateTime month,
  YearGoalsSettings goals,
) {
  final monthly = {for (final s in _sports) s: List<double>.filled(12, 0)};
  final hours = {for (final s in _sports) s: 0.0};
  for (final entry in activitiesByDate.entries) {
    final day = DateTime.tryParse(entry.key);
    if (day == null || day.year != month.year) continue;
    for (final a in entry.value) {
      final sport = canonicalSport(a.type);
      if (sport == null) continue;
      monthly[sport]![day.month - 1] += (a.distance ?? 0) / 1000;
      if (day.month == month.month) {
        hours[sport] = hours[sport]! + (a.movingTime ?? 0) / 3600;
      }
    }
  }
  return [
    for (final s in _sports)
      if (goals.goalFor(s) != null || monthly[s]!.any((km) => km > 0))
        MonthSportStats(
          sport: s,
          monthKm: monthly[s]![month.month - 1],
          monthHours: hours[s]!,
          monthlyKm: monthly[s]!,
          goalKm: goals.goalFor(s),
        ),
  ];
}

String _typeFor(String sport) => switch (sport) {
  'swim' => 'Swim',
  'cycle' => 'Ride',
  _ => 'Run',
};

/// What holding a month in the year view shows: per sport the month's
/// distance and time, that distance against a twelfth of the year goal,
/// and the year goal's cumulative progress month by month up to 100 %.
class MonthGoalsPeek extends StatelessWidget {
  MonthGoalsPeek({
    super.key,
    required this.month,
    required this.activitiesByDate,
    YearGoalsSettings? goals,
  }) : goals = goals ?? YearGoalsSettings.instance;

  final DateTime month;
  final Map<String, List<LocalActivity>> activitiesByDate;
  final YearGoalsSettings goals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final stats = monthSportStats(activitiesByDate, month, goals);
    final monthName = DateFormat.MMMM(locale).format(month);
    final number = NumberFormat.decimalPattern(locale)
      ..maximumFractionDigits = 1;
    final whole = NumberFormat.decimalPattern(locale)
      ..maximumFractionDigits = 0;
    String km(double v) =>
        '${v >= 100 ? whole.format(v) : number.format(v)} km';
    String hours(double v) => '${number.format(v)} h';

    final children = <Widget>[
      Text(
        DateFormat.yMMMM(locale).format(month),
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 8),
    ];

    if (stats.every((s) => s.monthKm == 0 && s.monthHours == 0)) {
      children.add(
        Text(l10n.calMonthPeekNothing, style: theme.textTheme.bodySmall),
      );
    }

    for (final s in stats) {
      final type = _typeFor(s.sport);
      final color = sportColor(type, scheme);
      final label = switch (s.sport) {
        'swim' => l10n.sportSwim,
        'cycle' => l10n.sportRide,
        _ => l10n.sportRun,
      };
      final share = s.shareOfMonthlyGoal;
      children.add(
        Padding(
          key: ValueKey('month-peek-${s.sport}'),
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(activityTypeIcon(type), size: 16, color: color),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  Text(
                    '${km(s.monthKm)} · ${hours(s.monthHours)}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (share != null)
                Text(
                  l10n.calMonthPeekShare(share, km(s.goalKm! / 12)),
                  key: ValueKey('month-peek-share-${s.sport}'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: share >= 100
                        ? scheme.tertiary
                        : scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              if (s.goalKm != null) ...[
                const SizedBox(height: 4),
                SizedBox(
                  height: 44,
                  child: CustomPaint(
                    key: ValueKey('month-peek-chart-${s.sport}'),
                    size: Size.infinite,
                    painter: _YearProgressPainter(
                      cumulative: s.cumulativeShare,
                      month: month.month,
                      color: color,
                      track: scheme.surfaceContainerHighest,
                      pace: scheme.onSurface.withValues(alpha: 0.55),
                      goalLine: scheme.outline,
                    ),
                  ),
                ),
                Text(
                  l10n.calMonthPeekThrough(
                    monthName,
                    (s.cumulativeShare[month.month - 1] * 100).round(),
                    km(s.goalKm!),
                  ),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (!goals.hasAnyGoal) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            l10n.calMonthPeekNoGoals,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

/// Twelve bars, one per month: the year goal's cumulative share at the end
/// of that month (capped at the top line, which is 100 %), a tick where an
/// even pace would be (m/12), the held month highlighted, later months
/// faint.
class _YearProgressPainter extends CustomPainter {
  _YearProgressPainter({
    required this.cumulative,
    required this.month,
    required this.color,
    required this.track,
    required this.pace,
    required this.goalLine,
  });

  final List<double> cumulative;
  final int month;
  final Color color;
  final Color track;
  final Color pace;
  final Color goalLine;

  @override
  void paint(Canvas canvas, Size size) {
    const gap = 3.0;
    final barWidth = (size.width - gap * 11) / 12;
    final h = size.height;
    final bar = Paint();
    final tick = Paint()
      ..color = pace
      ..strokeWidth = 2;
    for (var i = 0; i < 12; i++) {
      final x = i * (barWidth + gap);
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 0, barWidth, h),
        const Radius.circular(4),
      );
      canvas.drawRRect(r, bar..color = track);
      final value = i < cumulative.length ? cumulative[i] : 0.0;
      if (i < month && value > 0) {
        final top = h * (1 - math.min(value, 1.0));
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, top, barWidth, h - top),
            const Radius.circular(4),
          ),
          bar
            ..color = value >= 1
                ? color
                : color.withValues(alpha: i == month - 1 ? 1 : 0.55),
        );
      }
      final paceY = h * (1 - (i + 1) / 12);
      canvas.drawLine(Offset(x, paceY), Offset(x + barWidth, paceY), tick);
    }
    // The 100 % line along the top.
    canvas.drawLine(
      Offset.zero,
      Offset(size.width, 0),
      Paint()
        ..color = goalLine
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_YearProgressPainter old) =>
      old.cumulative != cumulative || old.month != month || old.color != color;
}
