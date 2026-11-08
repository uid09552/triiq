import 'package:flutter/material.dart';

import '../../evaluation/performance_curves.dart' show CurveSport;
import '../../l10n/app_localizations.dart';
import '../activities/activities_screen.dart';
import '../analysis/analysis_screen.dart';
import '../compare/compare_screen.dart';
import '../../widgets/hold_preview.dart';
import 'analytics_screen.dart';
import 'best_efforts_screen.dart';
import 'durability_screen.dart';
import 'insight_previews.dart';
import 'load_heatmap_screen.dart';
import 'performance_screen.dart';
import 'weekly_review_screen.dart';
import 'wellness_trends_screen.dart';

/// The groups the Insights destinations fall into, in display order; each
/// has its own accent so the grid reads as five small groups at a glance.
enum InsightsGroup { fitness, performance, health, compare, review }

/// One place to go from the Insights hub.
class InsightsDestination {
  const InsightsDestination({
    required this.id,
    required this.group,
    required this.icon,
    required this.label,
    required this.builder,
  });

  final String id;
  final InsightsGroup group;
  final IconData icon;
  final String Function(AppLocalizations l10n) label;
  final WidgetBuilder builder;
}

/// Every analysis view of the app, one tap away from the Insights hub.
final List<InsightsDestination> insightsDestinations = [
  InsightsDestination(
    id: 'analytics',
    group: InsightsGroup.fitness,
    icon: Icons.stacked_line_chart,
    label: (l) => l.anTitle,
    builder: (_) => const AnalyticsScreen(),
  ),
  InsightsDestination(
    id: 'explorer',
    group: InsightsGroup.fitness,
    icon: Icons.analytics_outlined,
    label: (l) => l.analysisTitle,
    builder: (_) => const AnalysisScreen(),
  ),
  InsightsDestination(
    id: 'heatmap',
    group: InsightsGroup.fitness,
    icon: Icons.grid_view_rounded,
    label: (l) => l.hmTitle,
    builder: (_) => LoadHeatmapScreen(),
  ),
  InsightsDestination(
    id: 'curves',
    group: InsightsGroup.performance,
    icon: Icons.trending_up,
    label: (l) => l.performanceTitle,
    builder: (_) => const PerformanceScreen(),
  ),
  InsightsDestination(
    id: 'best-efforts',
    group: InsightsGroup.performance,
    icon: Icons.emoji_events_outlined,
    label: (l) => l.beTitle,
    builder: (_) => BestEffortsScreen(),
  ),
  InsightsDestination(
    id: 'durability',
    group: InsightsGroup.performance,
    icon: Icons.battery_charging_full,
    label: (l) => l.durTitle,
    builder: (_) => DurabilityScreen(sport: CurveSport.ride),
  ),
  InsightsDestination(
    id: 'wellness',
    group: InsightsGroup.health,
    icon: Icons.monitor_heart_outlined,
    label: (l) => l.wtTitle,
    builder: (_) => WellnessTrendsScreen(),
  ),
  InsightsDestination(
    id: 'compare',
    group: InsightsGroup.compare,
    icon: Icons.compare_arrows,
    label: (l) => l.cmpTitle,
    builder: (_) => const CompareScreen(),
  ),
  InsightsDestination(
    id: 'weekly-review',
    group: InsightsGroup.review,
    icon: Icons.fact_check_outlined,
    label: (l) => l.weeklyReviewTitle,
    builder: (_) => const WeeklyReviewScreen(),
  ),
  InsightsDestination(
    id: 'activities',
    group: InsightsGroup.review,
    icon: Icons.list_alt_outlined,
    label: (l) => l.titleActivities,
    builder: (_) => const ActivitiesScreen(),
  ),
];

/// The Insights hub's way in: every destination as a small tile — icon and
/// a two-line name — four to a row on a phone, so the hub's own charts start
/// right below instead of under a stack of full-width cards.
class InsightsGrid extends StatelessWidget {
  const InsightsGrid({super.key, this.destinations, this.previewSource});

  /// Where a held tile's peek reads from (default: the local cache).
  final InsightPreviewSource? previewSource;

  /// Defaults to [insightsDestinations].
  final List<InsightsDestination>? destinations;

  static Color accent(ColorScheme scheme, InsightsGroup group) =>
      switch (group) {
        InsightsGroup.fitness => scheme.primary,
        InsightsGroup.performance => scheme.tertiary,
        InsightsGroup.health => scheme.error,
        InsightsGroup.compare => scheme.secondary,
        InsightsGroup.review => scheme.outline,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final items = destinations ?? insightsDestinations;
    final source = previewSource ?? InsightPreviewSource();
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;
        final columns = constraints.maxWidth < 340
            ? 3
            : constraints.maxWidth < 600
            ? 4
            : 5;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          key: const ValueKey('insights-grid'),
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final d in items)
              SizedBox(
                width: width,
                // Hold a tile to peek at what is behind it; a tap opens it.
                child: HoldPreview(
                  preview: (context) => InsightPreview(
                    id: d.id,
                    icon: d.icon,
                    title: d.label(l10n),
                    accent: accent(theme.colorScheme, d.group),
                    source: source,
                  ),
                  child: Material(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      key: ValueKey('insights-${d.id}'),
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.of(
                        context,
                      ).push(MaterialPageRoute<void>(builder: d.builder)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 4,
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: accent(
                                  theme.colorScheme,
                                  d.group,
                                ).withValues(alpha: 0.14),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                d.icon,
                                size: 20,
                                color: accent(theme.colorScheme, d.group),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              d.label(l10n),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
