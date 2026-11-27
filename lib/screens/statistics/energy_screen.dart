import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/local_activity.dart';
import '../../data/models/local_wellness.dart';
import '../../data/repositories/activities_repository.dart';
import '../../data/repositories/wellness_repository.dart';
import '../../evaluation/energy_balance.dart';
import '../../l10n/app_localizations.dart';
import '../../util/dates.dart';
import '../../widgets/section_card.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/status_message.dart';

/// Insights → Energy: what was eaten (as logged in Intervals.icu, usually
/// from a connected food app) next to what training burned, per day.
/// Read-only and descriptive: no targets, no deficit, no advice.
class EnergyScreen extends StatefulWidget {
  EnergyScreen({
    super.key,
    WellnessRepository? wellness,
    ActivitiesRepository? activities,
    this.today,
  }) : wellness = wellness ?? WellnessRepository(),
       activities = activities ?? ActivitiesRepository();

  final WellnessRepository wellness;
  final ActivitiesRepository activities;
  final DateTime? today;

  @override
  State<EnergyScreen> createState() => _EnergyScreenState();
}

class _EnergyScreenState extends State<EnergyScreen> {
  static const _ranges = [7, 28, 90];
  int _days = 28;
  bool _loading = true;
  Object? _error;
  List<EnergyDay> _list = const [];

  DateTime get _end => dateOnly(widget.today ?? DateTime.now());

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final from = _end.subtract(Duration(days: _days - 1));
    try {
      final List<LocalWellness> w = await widget.wellness.getRange(
        isoDate(from),
        isoDate(_end),
      );
      final List<LocalActivity> a = await widget.activities.getRange(
        isoDate(from),
        isoDate(_end),
      );
      if (!mounted) return;
      setState(() {
        _list = energyDays(from, _end, w, a);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final summary = EnergySummary(_list);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.energyTitle)),
      body: _loading
          ? const SkeletonScreen(cards: 2)
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SegmentedButton<int>(
                  key: const ValueKey('energy-range'),
                  showSelectedIcon: false,
                  segments: [
                    for (final d in _ranges)
                      ButtonSegment(
                        value: d,
                        label: Text(l10n.rangeDaysShort(d)),
                      ),
                  ],
                  selected: {_days},
                  onSelectionChanged: (s) {
                    _days = s.first;
                    _load();
                  },
                ),
                const SizedBox(height: 12),
                if (_error != null)
                  StatusMessage.error(error: _error!, onRetry: _load)
                else if (summary.isEmpty)
                  StatusMessage.needsSync(
                    context,
                    title: l10n.energyNoData,
                    reason: l10n.energyNoDataReason,
                    icon: Icons.restaurant_outlined,
                  )
                else ...[
                  _summaryCard(context, l10n, summary),
                  const SizedBox(height: 12),
                  _daysCard(context, l10n, summary),
                ],
                const SizedBox(height: 12),
                Text(
                  l10n.energyCareNote,
                  key: const ValueKey('energy-care-note'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
    );
  }

  String _kcal(double? v) => v == null ? '–' : '${v.round()} kcal';
  String _g(double? v) => v == null ? '–' : '${v.round()} g';

  Widget _summaryCard(
    BuildContext context,
    AppLocalizations l10n,
    EnergySummary s,
  ) {
    Widget stat(String key, String label, String value) => SizedBox(
      width: 150,
      child: Column(
        key: ValueKey('energy-$key'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
    return SectionCard(
      icon: Icons.restaurant_outlined,
      title: l10n.energySummaryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              stat('eaten', l10n.energyAvgEaten, _kcal(s.avgEatenKcal)),
              stat('burned', l10n.energyAvgTraining, _kcal(s.avgTrainingKcal)),
              stat('carbs', l10n.energyAvgCarbs, _g(s.avgCarbsG)),
              stat('protein', l10n.energyAvgProtein, _g(s.avgProteinG)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.energyLoggedDays(s.loggedDays, s.days.length),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (s.totalCarbsUsedG > 0)
            Text(
              l10n.energySessionCarbs(s.totalCarbsUsedG, s.totalCarbsTakenG),
              key: const ValueKey('energy-session-carbs'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (s.heavyBurnDays > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                l10n.energyHeavyBurn(s.heavyBurnDays),
                key: const ValueKey('energy-heavy-burn'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }

  Widget _daysCard(
    BuildContext context,
    AppLocalizations l10n,
    EnergySummary s,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final top = s.days.fold<int>(
      1,
      (m, d) => math.max(m, math.max(d.eatenKcal ?? 0, d.trainingKcal)),
    );
    Widget bar(int v, Color c) => FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: (v / top).clamp(0.0, 1.0),
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
    return SectionCard(
      icon: Icons.calendar_view_day_outlined,
      title: l10n.energyDaysTitle,
      child: Column(
        children: [
          Row(
            children: [
              _legend(scheme.primary, l10n.energyEaten, context),
              const SizedBox(width: 16),
              _legend(scheme.tertiary, l10n.energyTraining, context),
            ],
          ),
          const SizedBox(height: 8),
          for (final d in s.days.reversed)
            if (d.hasIntake || d.trainingKcal > 0)
              Padding(
                key: ValueKey('energy-day-${isoDate(d.date)}'),
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 72,
                      child: Text(
                        DateFormat.MMMEd(locale).format(d.date),
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          bar(d.eatenKcal ?? 0, scheme.primary),
                          const SizedBox(height: 3),
                          bar(d.trainingKcal, scheme.tertiary),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 86,
                      child: Text(
                        '${d.hasIntake ? d.eatenKcal : '–'} / ${d.trainingKcal}',
                        textAlign: TextAlign.end,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Widget _legend(Color c, String label, BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 12, height: 6, color: c),
      const SizedBox(width: 4),
      Text(label, style: Theme.of(context).textTheme.labelMedium),
    ],
  );
}
