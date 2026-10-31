import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../data/planned_items.dart';
import '../../data/repositories/activities_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../util/dates.dart';
import '../../widgets/charts/bar_chart.dart';
import '../../widgets/section_card.dart';

/// Daily training load (TSS-equivalent) for the last [_days] days against
/// what was planned for each of them, reading straight from the local
/// cache — the same range Today's "TSS today" tile summarises just the last
/// one of.
class TssHistoryScreen extends StatefulWidget {
  const TssHistoryScreen({super.key});

  static const _days = 42;

  @override
  State<TssHistoryScreen> createState() => _TssHistoryScreenState();
}

class _TssHistoryScreenState extends State<TssHistoryScreen> {
  final _activitiesRepository = ActivitiesRepository();
  final _eventsRepository = PlannedItemsRepository();

  bool _loading = true;
  List<({DateTime date, int tss, int planned})> _days = const [];
  int? _selected;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final today = dateOnly(DateTime.now());
    final start = today.subtract(
      const Duration(days: TssHistoryScreen._days - 1),
    );
    final activities = await _activitiesRepository.getRange(
      isoDate(start),
      isoDate(today),
    );
    final events = await _eventsRepository.getRange(
      isoDate(start),
      isoDate(today),
    );

    final byDate = <String, int>{};
    for (final activity in activities) {
      byDate.update(
        activity.date,
        (sum) => sum + (activity.trainingLoad ?? 0),
        ifAbsent: () => activity.trainingLoad ?? 0,
      );
    }
    final plannedByDate = <String, int>{};
    for (final event in events.where((e) => e.isTraining)) {
      plannedByDate.update(
        event.date,
        (sum) => sum + (event.plannedLoad ?? 0),
        ifAbsent: () => event.plannedLoad ?? 0,
      );
    }

    final days = [
      for (var i = 0; i < TssHistoryScreen._days; i++)
        () {
          final date = start.add(Duration(days: i));
          return (
            date: date,
            tss: byDate[isoDate(date)] ?? 0,
            planned: plannedByDate[isoDate(date)] ?? 0,
          );
        }(),
    ];

    if (!mounted) return;
    setState(() {
      _days = days;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final total = _days.fold<int>(0, (sum, d) => sum + d.tss);
    final avgPerDay = _days.isEmpty ? 0 : total / _days.length;
    final avgPerWeek = avgPerDay * 7;
    final selected = _selected != null ? _days[_selected!] : null;
    final today = dateOnly(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tssHistoryTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _SummaryTile(
                        label: l10n.totalLabel,
                        value: '$total',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryTile(
                        label: l10n.avgPerDay,
                        value: avgPerDay.toStringAsFixed(1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryTile(
                        label: l10n.avgPerWeek,
                        value: avgPerWeek.toStringAsFixed(0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SectionCard(
                  icon: Icons.bar_chart_outlined,
                  title: l10n.dailyTss,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selected != null
                            ? l10n.selectedDayTss(
                                _formatDate(context, selected.date),
                                selected.tss,
                              )
                            : l10n.tapBarForDetails,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 180,
                        child: SimpleBarChart(
                          bars: [
                            for (final day in _days)
                              ChartBar(
                                label:
                                    '${day.date.day}/${day.date.month}',
                                value: day.tss.toDouble(),
                                target: day.planned > 0
                                    ? day.planned.toDouble()
                                    : null,
                                highlighted: day.date == today,
                              ),
                          ],
                          selectedIndex: _selected,
                          onSelect: (index) =>
                              setState(() => _selected = index),
                          labelEvery: 7,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  static String _formatDate(BuildContext context, DateTime date) =>
      DateFormat.MMMd(
        Localizations.localeOf(context).toString(),
      ).format(date);
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
