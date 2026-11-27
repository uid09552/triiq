import 'package:flutter/material.dart';

import '../../data/models/local_activity.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/gauge_ring.dart';
import '../activities/activity_icons.dart';
import '../settings/weekly_targets_settings.dart';
import '../settings/year_goals_progress.dart';
import '../settings/year_goals_settings.dart';
import 'week_activities_sheet.dart';
import 'weekly_targets_row.dart';

/// "This week" on Today: TSS against plan, sessions done of planned, the
/// hours per sport against their targets (the hours bar and one small ring
/// per sport), and the year goals as one line — what used to be three cards.
class ThisWeekCard extends StatelessWidget {
  const ThisWeekCard({
    super.key,
    required this.weekActivities,
    required this.weekLoad,
    required this.weekPlannedLoad,
    required this.sessionsPlanned,
    this.collapsed,
    this.onToggleCollapsed,
    this.targets,
    this.yearGoals,
  });

  final List<LocalActivity> weekActivities;
  final int weekLoad;
  final int weekPlannedLoad;

  /// Training sessions planned this week (done or not).
  final int sessionsPlanned;
  final bool? collapsed;
  final VoidCallback? onToggleCollapsed;
  final WeeklyTargetsSettings? targets;
  final YearGoalsSettings? yearGoals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final targetSettings = targets ?? WeeklyTargetsSettings.instance;
    final goals = yearGoals ?? YearGoalsSettings.instance;

    return ListenableBuilder(
      listenable: Listenable.merge([targetSettings, goals]),
      builder: (context, _) {
        final showTargets =
            targetSettings.showOnToday && targetSettings.hasAnyTarget;
        final targetList = <double>[
          ?targetSettings.swimHours,
          ?targetSettings.cycleHours,
          ?targetSettings.runHours,
        ];
        final seconds = weeklySportSeconds(weekActivities);

        Widget? sport(String key, double? target, String label, String type) {
          if (target == null) return null;
          final hours = (seconds[key] ?? 0) / 3600;
          final progress = hours / target;
          final done = progress >= 1;
          final color = done ? scheme.tertiary : sportColor(type, scheme);
          final value =
              '${hours.toStringAsFixed(1)} / ${target.toStringAsFixed(1)} h';
          return Expanded(
            child: Semantics(
              container: true,
              label: '$label: $value, ${(progress * 100).round()}%',
              excludeSemantics: true,
              child: InkWell(
                key: ValueKey('weekly-target-ring-$key'),
                borderRadius: BorderRadius.circular(12),
                // Tap or hold: the week's activities behind the ring.
                onTap: () => showWeekActivitiesSheet(
                  context,
                  sportLabel: label,
                  sport: key,
                  weekActivities: weekActivities,
                ),
                onLongPress: () => showWeekActivitiesSheet(
                  context,
                  sportLabel: label,
                  sport: key,
                  weekActivities: weekActivities,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      GaugeRing(
                        progress: progress,
                        color: color,
                        size: 34,
                        strokeWidth: 4,
                        child: Icon(
                          done ? Icons.check_rounded : activityTypeIcon(type),
                          size: 14,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          value,
                          maxLines: 2,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        final rings = showTargets
            ? [
                sport('swim', targetSettings.swimHours, l10n.sportSwim, 'Swim'),
                sport(
                  'cycle',
                  targetSettings.cycleHours,
                  l10n.sportRide,
                  'Ride',
                ),
                sport('run', targetSettings.runHours, l10n.sportRun, 'Run'),
              ].whereType<Widget>().toList()
            : const <Widget>[];
        final showGoals = goals.showOnToday && goals.hasAnyGoal;

        final isCollapsed = collapsed ?? false;
        final body = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (weekPlannedLoad > 0)
              WeeklyGoalProgress(completed: weekLoad, planned: weekPlannedLoad)
            else
              Text(
                l10n.todayThisWeekLoad(weekLoad),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            if (showTargets || weekActivities.isNotEmpty) ...[
              const SizedBox(height: 8),
              WeeklyHoursBar(
                weekActivities: weekActivities,
                targetHours: !showTargets || targetList.isEmpty
                    ? null
                    : targetList.reduce((a, b) => a + b),
              ),
            ],
            if (rings.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  for (final (i, r) in rings.indexed) ...[
                    if (i > 0) const SizedBox(width: 6),
                    r,
                  ],
                ],
              ),
            ],
            if (showGoals) ...[
              const SizedBox(height: 6),
              YearGoalsProgress(
                key: const ValueKey('today-year-goals'),
                compact: true,
                settings: goals,
              ),
            ],
          ],
        );
        // Slimmer than a `SectionCard` (12 dp padding, a one-line header),
        // so the hero and this card fit one phone screen together.
        return Card(
          key: const ValueKey('this-week-card'),
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 4, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: onToggleCollapsed,
                  borderRadius: BorderRadius.circular(8),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 40),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_view_week_outlined,
                          size: 18,
                          color: scheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.todayThisWeekTitle,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            l10n.todayThisWeekSessions(
                              weekActivities.length,
                              sessionsPlanned,
                            ),
                            key: const ValueKey('this-week-sessions'),
                            textAlign: TextAlign.end,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (onToggleCollapsed != null)
                          Semantics(
                            button: true,
                            label: l10n.todayThisWeekTitle,
                            expanded: !isCollapsed,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: Icon(
                                isCollapsed
                                    ? Icons.expand_more
                                    : Icons.expand_less,
                                size: 20,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (!isCollapsed)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: body,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// This week's completed load against its planned total (the sum of every
/// planned event in the week) — the "goal" today's session is working
/// toward.
class WeeklyGoalProgress extends StatelessWidget {
  const WeeklyGoalProgress({
    super.key,
    required this.completed,
    required this.planned,
  });

  final int completed;
  final int planned;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final remaining = planned - completed;
    final progress = (completed / planned).clamp(0.0, 1.0);
    final accent = remaining > 0 ? colorScheme.primary : colorScheme.tertiary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          remaining > 0
              ? l10n.weeklyGoalProgress(completed, planned, remaining)
              : l10n.weeklyGoalReached(completed, planned),
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: colorScheme.surfaceContainerHighest,
            color: accent,
          ),
        ),
      ],
    );
  }
}
