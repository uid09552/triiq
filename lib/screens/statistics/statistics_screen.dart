import 'package:flutter/material.dart';

import '../../widgets/section_card.dart';
import '../../widgets/stat_tile.dart';

/// Training-load graphs (TSS/CTL/ATL) and volume statistics (distance/time
/// per week, month, year).
///
/// TODO: wire up to lib/client/intervalls (WellnessApi for TSS/CTL/ATL
/// history, AktivittenApi for aggregated volume) and render with a charting
/// package once a data source is connected.
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          icon: Icons.show_chart,
          title: 'Training stress (TSS)',
          child: Container(
            height: 160,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.primary.withValues(alpha: 0.12),
                  colorScheme.primary.withValues(alpha: 0.02),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.insights_outlined,
                  size: 32,
                  color: colorScheme.primary.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 8),
                Text(
                  'Not connected to Intervals.icu',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          icon: Icons.route_outlined,
          title: 'Volume',
          child: Row(
            children: [
              Expanded(
                child: StatTile(
                  label: 'This week',
                  value: '— km',
                  icon: Icons.calendar_view_week,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  label: 'This month',
                  value: '— km',
                  icon: Icons.calendar_view_month,
                  color: colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  label: 'This year',
                  value: '— km',
                  icon: Icons.calendar_today_outlined,
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
