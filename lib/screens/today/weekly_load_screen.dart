import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../data/repositories/activities_repository.dart';
import '../../data/repositories/events_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../util/dates.dart';
import '../../util/intervals_links.dart';
import '../../widgets/charts/bar_chart.dart';
import '../../widgets/section_card.dart';
import '../../widgets/stat_tile.dart';

/// One week of load: what was completed, what the plan asked for, and how
/// much of it actually happened.
class _Week {
  const _Week({
    required this.start,
    required this.completed,
    required this.planned,
    required this.sessions,
    required this.movingSeconds,
  });

  final DateTime start;
  final int completed;
  final int planned;
  final int sessions;
  final int movingSeconds;
}

/// Completed vs planned training load per week — where the Today screen's
/// "TSS week" tile leads.
///
/// The comparison is the point: a week's TSS on its own says nothing, but
/// against the plan it says whether the week happened, and against the
/// weeks before it whether load is going anywhere.
class WeeklyLoadScreen extends StatefulWidget {
  const WeeklyLoadScreen({super.key});

  static const _weeks = 12;

  @override
  State<WeeklyLoadScreen> createState() => _WeeklyLoadScreenState();
}

class _WeeklyLoadScreenState extends State<WeeklyLoadScreen> {
  final _activitiesRepository = ActivitiesRepository();
  final _eventsRepository = EventsRepository();

  bool _loading = true;
  List<_Week> _weeks = const [];
  int? _selected;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final thisWeek = startOfWeek(DateTime.now());
    final start = thisWeek.subtract(
      Duration(days: 7 * (WeeklyLoadScreen._weeks - 1)),
    );
    final end = thisWeek.add(const Duration(days: 6));

    final activities = await _activitiesRepository.getRange(
      isoDate(start),
      isoDate(end),
    );
    final events = await _eventsRepository.getRange(
      isoDate(start),
      isoDate(end),
    );

    final completed = <String, int>{};
    final sessions = <String, int>{};
    final seconds = <String, int>{};
    for (final activity in activities) {
      final key = isoDate(startOfWeek(DateTime.parse(activity.date)));
      completed.update(
        key,
        (sum) => sum + (activity.trainingLoad ?? 0),
        ifAbsent: () => activity.trainingLoad ?? 0,
      );
      sessions.update(key, (count) => count + 1, ifAbsent: () => 1);
      seconds.update(
        key,
        (sum) => sum + (activity.movingTime ?? 0),
        ifAbsent: () => activity.movingTime ?? 0,
      );
    }

    final planned = <String, int>{};
    for (final event in events.where((e) => e.isTraining)) {
      final key = isoDate(startOfWeek(DateTime.parse(event.date)));
      planned.update(
        key,
        (sum) => sum + (event.plannedLoad ?? 0),
        ifAbsent: () => event.plannedLoad ?? 0,
      );
    }

    final weeks = [
      for (var i = 0; i < WeeklyLoadScreen._weeks; i++)
        () {
          final weekStart = start.add(Duration(days: 7 * i));
          final key = isoDate(weekStart);
          return _Week(
            start: weekStart,
            completed: completed[key] ?? 0,
            planned: planned[key] ?? 0,
            sessions: sessions[key] ?? 0,
            movingSeconds: seconds[key] ?? 0,
          );
        }(),
    ];

    if (!mounted) return;
    setState(() {
      _weeks = weeks;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.weeklyLoadTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final selected = _selected == null ? null : _weeks[_selected!];
    final thisWeek = _weeks.isEmpty ? null : _weeks.last;
    final completedTotal = _weeks.fold<int>(0, (sum, w) => sum + w.completed);
    // Last four full weeks against the four before them: the shortest span
    // that shows a direction rather than a single good or bad week.
    final recent = _average(_weeks.length - 5, _weeks.length - 1);
    final previous = _average(_weeks.length - 9, _weeks.length - 5);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.weeklyLoadTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: l10n.thisWeek,
                  value: '${thisWeek?.completed ?? 0}',
                  subtitle: thisWeek != null && thisWeek.planned > 0
                      ? l10n.ofPlanned(thisWeek.planned)
                      : null,
                  icon: Icons.calendar_view_week_outlined,
                  color: colorScheme.primary,
                  onLongPress: () => showOpenInIntervalsSheet(
                    context,
                    label: l10n.thisWeek,
                    path: 'activities',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  label: l10n.avgPerWeek,
                  value: (completedTotal / _weeks.length).toStringAsFixed(0),
                  icon: Icons.functions,
                  color: colorScheme.tertiary,
                  onLongPress: () => showOpenInIntervalsSheet(
                    context,
                    label: l10n.avgPerWeek,
                    path: 'fitness',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  label: l10n.fourWeekTrend,
                  value: previous == 0
                      ? '—'
                      : '${recent >= previous ? '+' : ''}'
                            '${(((recent - previous) / previous) * 100).toStringAsFixed(0)}%',
                  icon: recent >= previous
                      ? Icons.trending_up
                      : Icons.trending_down,
                  color: colorScheme.secondary,
                  onLongPress: () => showOpenInIntervalsSheet(
                    context,
                    label: l10n.fourWeekTrend,
                    path: 'fitness',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SectionCard(
            icon: Icons.bar_chart_outlined,
            title: l10n.completedVsPlanned,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selected != null
                      ? l10n.selectedWeekLoad(
                          _formatWeek(context, selected.start),
                          selected.completed,
                          selected.planned,
                        )
                      : l10n.tapBarForWeek,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (selected != null && selected.sessions > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.weekSessionsAndTime(
                      selected.sessions,
                      _formatHours(selected.movingSeconds),
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: SimpleBarChart(
                    bars: [
                      for (final week in _weeks)
                        ChartBar(
                          label: DateFormat.Md(
                            Localizations.localeOf(context).toString(),
                          ).format(week.start),
                          value: week.completed.toDouble(),
                          target: week.planned > 0
                              ? week.planned.toDouble()
                              : null,
                          highlighted: week == _weeks.last,
                        ),
                    ],
                    selectedIndex: _selected,
                    onSelect: (index) => setState(() => _selected = index),
                    labelEvery: 3,
                  ),
                ),
                const SizedBox(height: 12),
                _Legend(
                  entries: [
                    (colorScheme.primary, l10n.completedLegend),
                    (
                      colorScheme.tertiary.withValues(alpha: 0.3),
                      l10n.plannedLegend,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Mean completed load over `_weeks[from..to)`, clamped to what exists.
  double _average(int from, int to) {
    final start = from.clamp(0, _weeks.length);
    final end = to.clamp(0, _weeks.length);
    if (end <= start) return 0;
    var total = 0;
    for (var i = start; i < end; i++) {
      total += _weeks[i].completed;
    }
    return total / (end - start);
  }

  static String _formatWeek(BuildContext context, DateTime start) =>
      DateFormat.MMMd(
        Localizations.localeOf(context).toString(),
      ).format(start);

  static String _formatHours(int seconds) =>
      '${(seconds / 3600).toStringAsFixed(1)}h';
}

class _Legend extends StatelessWidget {
  const _Legend({required this.entries});

  final List<(Color, String)> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        for (final (color, label) in entries)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(label, style: theme.textTheme.bodySmall),
            ],
          ),
      ],
    );
  }
}
