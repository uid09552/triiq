import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../data/models/local_activity.dart';
import '../../data/models/local_event.dart';
import '../../evaluation/load_heatmap.dart';
import '../../l10n/app_localizations.dart';
import '../../plan/load_curve.dart';
import '../../plan/plan_models.dart';
import '../../util/dates.dart';
import '../../widgets/charts/chart_theme.dart';
import '../plan/plan_labels.dart';
import 'calendar_level.dart';
import 'day_events.dart';

/// Twelve mini-months, each day tinted by its load on the load heatmap's
/// colour scale, with markers for races, sick/injured days and holidays and
/// the plan's phase as a band beside each week. Tap a month to open it.
class YearCalendarView extends StatelessWidget {
  const YearCalendarView({
    super.key,
    required this.year,
    required this.activitiesByDate,
    required this.onOpenMonth,
    this.dayEventsByDate = const {},
    this.plan,
    this.scale = HeatScale.theme,
    this.selectedDate,
    this.today,
  });

  final int year;
  final Map<String, List<LocalActivity>> activitiesByDate;
  final Map<String, List<LocalEvent>> dayEventsByDate;
  final TrainingPlan? plan;
  final HeatScale scale;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onOpenMonth;

  /// Test seam for "now".
  final DateTime Function()? today;

  @override
  Widget build(BuildContext context) {
    final heatmap = buildLoadHeatmap(
      [for (final list in activitiesByDate.values) ...list],
      from: DateTime(year, 1, 1),
      to: DateTime(year, 12, 31),
    );
    final now = dateOnly((today ?? DateTime.now)());
    final l10n = AppLocalizations.of(context)!;
    final phases = plan == null
        ? const <String>{}
        : {for (final w in plan!.weeks) w.phase};
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textScale = MediaQuery.textScalerOf(context).scale(1);
          final minWidth = 150 * textScale.clamp(1.0, 1.6);
          final columns = (constraints.maxWidth / minWidth).floor().clamp(1, 4);
          final width = (constraints.maxWidth - 8 * (columns - 1)) / columns;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: [
                  for (var m = 1; m <= 12; m++)
                    SizedBox(
                      width: width,
                      child: _MiniMonth(
                        month: DateTime(year, m, 1),
                        heatmap: heatmap,
                        dayEventsByDate: dayEventsByDate,
                        plan: plan,
                        scale: scale,
                        now: now,
                        selected:
                            selectedDate != null &&
                            selectedDate!.year == year &&
                            selectedDate!.month == m,
                        onTap: () => onOpenMonth(DateTime(year, m, 1)),
                      ),
                    ),
                ],
              ),
              if (phases.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    for (final p in phases)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: phaseColor(
                                p,
                                Theme.of(context).colorScheme,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            phaseLabel(l10n, p),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// The plan phase's band colour.
Color phaseColor(String phase, ColorScheme scheme) => switch (phase) {
  recoveryPhase => Colors.green.shade400,
  taperPhase => Colors.lightBlue.shade400,
  racePhase => Colors.amber.shade700,
  'peak' => scheme.error,
  'build_plus' => scheme.tertiary,
  _ => scheme.primary,
};

class _MiniMonth extends StatelessWidget {
  const _MiniMonth({
    required this.month,
    required this.heatmap,
    required this.dayEventsByDate,
    required this.plan,
    required this.scale,
    required this.now,
    required this.selected,
    required this.onTap,
  });

  final DateTime month;
  final LoadHeatmap heatmap;
  final Map<String, List<LocalEvent>> dayEventsByDate;
  final TrainingPlan? plan;
  final HeatScale scale;
  final DateTime now;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final chart = ChartTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final (gridStart, _) = calendarRange(CalendarLevel.month, month);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final weeks = (lastDay.difference(gridStart).inDays ~/ 7) + 1; // 4–6 rows

    var tss = 0;
    var sessions = 0;
    var races = 0;
    for (var d = 1; d <= lastDay.day; d++) {
      final day = heatmap.dayOn(DateTime(month.year, month.month, d));
      tss += day?.tss ?? 0;
      sessions += day?.sessions ?? 0;
      final events =
          dayEventsByDate[isoDate(DateTime(month.year, month.month, d))];
      if (events?.any((e) => isRaceCategory(e.category)) ?? false) races++;
    }
    final title = DateFormat.MMMM(locale).format(month);

    return Semantics(
      button: true,
      selected: selected,
      label: l10n.calMonthSemantics(title, tss, sessions),
      value: races > 0 ? l10n.calSemRaces(races) : null,
      excludeSemantics: true,
      child: InkWell(
        key: ValueKey('year-month-${month.month}'),
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? scheme.primary
                  : scheme.outlineVariant.withValues(alpha: 0.6),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color:
                            month.year == now.year && month.month == now.month
                            ? scheme.primary
                            : null,
                      ),
                    ),
                  ),
                  if (tss > 0)
                    Text(
                      '$tss',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              for (var w = 0; w < weeks; w++)
                _weekRow(
                  context,
                  DateTime(
                    gridStart.year,
                    gridStart.month,
                    gridStart.day + 7 * w,
                  ),
                  chart,
                  scheme,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _weekRow(
    BuildContext context,
    DateTime monday,
    ChartTheme chart,
    ColorScheme scheme,
  ) {
    String? phase;
    for (final w in plan?.weeks ?? const <PlanWeek>[]) {
      if (dateOnly(w.startDate) == monday ||
          (!monday.isBefore(w.startDate) &&
              monday.isBefore(w.startDate.add(const Duration(days: 7))))) {
        phase = w.phase;
        break;
      }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Container(
            key: phase == null
                ? null
                : ValueKey('phase-band-$phase-${isoDate(monday)}'),
            width: 3,
            height: 12,
            margin: const EdgeInsets.only(right: 3),
            decoration: BoxDecoration(
              color: phase == null ? null : phaseColor(phase, scheme),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          for (var i = 0; i < 7; i++)
            Expanded(
              child: _cell(
                DateTime(monday.year, monday.month, monday.day + i),
                chart,
                scheme,
              ),
            ),
        ],
      ),
    );
  }

  Widget _cell(DateTime date, ChartTheme chart, ColorScheme scheme) {
    if (date.month != month.month) return const SizedBox(height: 12);
    final day = heatmap.dayOn(date);
    final level = day == null ? 0 : heatmap.levelOf(day.tss);
    final events = dayEventsByDate[isoDate(date)] ?? const <LocalEvent>[];
    Color? marker;
    if (events.any((e) => isRaceCategory(e.category))) {
      marker = Colors.amber.shade800;
    } else if (events.any((e) => tintsDay(e.category))) {
      marker = scheme.error;
    } else if (events.any((e) => e.category == 'HOLIDAY')) {
      marker = Colors.lightBlue.shade600;
    }
    return Container(
      key: ValueKey('year-day-${isoDate(date)}-$level'),
      height: 12,
      margin: const EdgeInsets.all(0.5),
      decoration: BoxDecoration(
        color: chart.heatColorOf(level, scale),
        borderRadius: BorderRadius.circular(2),
        border: date == now
            ? Border.all(color: scheme.onSurface, width: 1)
            : marker != null
            ? Border.all(color: marker, width: 1.5)
            : null,
      ),
    );
  }
}
