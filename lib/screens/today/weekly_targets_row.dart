import 'package:flutter/material.dart';

import '../../data/models/local_activity.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/progress_ring.dart';
import '../activities/activity_icons.dart';
import '../settings/weekly_targets_settings.dart';
import 'week_activities_sheet.dart';

/// Sums moving time (seconds) per canonical sport across this week's
/// cached activities — the data behind the weekly-target rings on Today.
/// A type that doesn't belong to any of the three target sports (e.g. a
/// hike) is left out rather than falling into a catch-all bucket.
Map<String, int> weeklySportSeconds(List<LocalActivity> weekActivities) {
  final totals = <String, int>{};
  for (final activity in weekActivities) {
    final sport = canonicalSport(activity.type);
    if (sport == null) continue;
    totals[sport] = (totals[sport] ?? 0) + (activity.movingTime ?? 0);
  }
  return totals;
}

/// One [ProgressRing] per sport with a weekly target set, reusing the
/// week's already-fetched activities (the same list behind the TSS-week
/// tile) — no new repository call, works offline. Hidden entirely when
/// "Show on Today" is off, or when no sport has a target at all.
class WeeklyTargetsRow extends StatelessWidget {
  const WeeklyTargetsRow({
    super.key,
    required this.weekActivities,
    this.settings,
  });

  final List<LocalActivity> weekActivities;
  final WeeklyTargetsSettings? settings;

  WeeklyTargetsSettings get _settings =>
      settings ?? WeeklyTargetsSettings.instance;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) {
        if (!_settings.showOnToday || !_settings.hasAnyTarget) {
          return const SizedBox.shrink();
        }
        final l10n = AppLocalizations.of(context)!;
        final colorScheme = Theme.of(context).colorScheme;
        final achievedSeconds = weeklySportSeconds(weekActivities);

        // `sportColor`/`activityTypeIcon` key off a raw Intervals.icu type
        // string, not the canonical 'swim'/'cycle'/'run' bucket, so each
        // ring passes a representative type to reuse the same colours the
        // rest of the app already shows for that sport.
        Widget? ring(
          String sport,
          double? targetHours,
          String label,
          String representativeType,
        ) {
          if (targetHours == null) return null;
          final achievedHours = (achievedSeconds[sport] ?? 0) / 3600;
          final progress = achievedHours / targetHours;
          final indicator = ProgressRing(
            key: ValueKey('weekly-target-ring-$sport'),
            label: label,
            percentLabel: '${(progress * 100).round()}%',
            valueLabel:
                '${achievedHours.toStringAsFixed(1)} / '
                '${targetHours.toStringAsFixed(1)} h',
            progress: progress,
            color: sportColor(representativeType, colorScheme),
            doneColor: colorScheme.tertiary,
            icon: activityTypeIcon(representativeType),
          );
          // Long-press lists the week's activities behind the ring, with
          // the same press feedback as the Today tiles.
          return _PressableRing(
            onLongPress: () => showWeekActivitiesSheet(
              context,
              sportLabel: label,
              sport: sport,
              weekActivities: weekActivities,
            ),
            child: indicator,
          );
        }

        final rings = [
          ring('swim', _settings.swimHours, l10n.sportSwim, 'Swim'),
          ring('cycle', _settings.cycleHours, l10n.sportRide, 'Ride'),
          ring('run', _settings.runHours, l10n.sportRun, 'Run'),
        ].whereType<Widget>().toList();

        final targets = <double>[
          ?_settings.swimHours,
          ?_settings.cycleHours,
          ?_settings.runHours,
        ];
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              WeeklyHoursBar(
                weekActivities: weekActivities,
                targetHours: targets.isEmpty
                    ? null
                    : targets.reduce((a, b) => a + b),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: rings,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Press feedback for a ring, matching `StatTile`'s compact style: a quick
/// scale-down, an ink ripple and the platform's long-press haptic
/// (`InkWell` fires it for any long-press handler).
class _PressableRing extends StatefulWidget {
  const _PressableRing({required this.child, required this.onLongPress});

  final Widget child;
  final VoidCallback onLongPress;

  @override
  State<_PressableRing> createState() => _PressableRingState();
}

class _PressableRingState extends State<_PressableRing> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.94 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onLongPress: widget.onLongPress,
          onHighlightChanged: (v) => setState(() => _pressed = v),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Total training time this week as a slim stacked bar above the rings:
/// one segment per sport (swim / ride / run, everything else in grey),
/// scaled against the sum of the weekly targets when there is one, so the
/// bar fills as the week goes. Counts every cached activity, not only the
/// three target sports.
class WeeklyHoursBar extends StatelessWidget {
  const WeeklyHoursBar({
    super.key,
    required this.weekActivities,
    this.targetHours,
  });

  final List<LocalActivity> weekActivities;

  /// Sum of the sport targets, or null when none is set.
  final double? targetHours;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final bySport = weeklySportSeconds(weekActivities);
    final totalSeconds = weekActivities.fold<int>(
      0,
      (sum, a) => sum + (a.movingTime ?? 0),
    );
    final otherSeconds = totalSeconds -
        bySport.values.fold<int>(0, (sum, v) => sum + v);
    final hours = totalSeconds / 3600;
    final target = targetHours;
    final scaleSeconds = (target != null && target > 0
            ? target * 3600
            : totalSeconds.toDouble())
        .clamp(1, double.infinity)
        .toDouble();
    final denominator = totalSeconds > scaleSeconds ? totalSeconds : scaleSeconds;

    Widget segment(int seconds, Color color) => seconds <= 0
        ? const SizedBox.shrink()
        : Expanded(
            flex: (seconds * 1000 / denominator).round().clamp(1, 1000),
            child: Container(color: color),
          );

    final fill = totalSeconds <= 0
        ? 0
        : (totalSeconds * 1000 / denominator).round().clamp(0, 1000);
    final text = target == null
        ? l10n.weeklyHoursTotal(hours.toStringAsFixed(1))
        : l10n.weeklyHoursOfTarget(
            hours.toStringAsFixed(1),
            target.toStringAsFixed(1),
          );
    return Column(
      key: const ValueKey('weekly-hours-bar'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              l10n.weeklyHoursLabel,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Text(
              text,
              key: const ValueKey('weekly-hours-text'),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Container(
            height: 6,
            color: scheme.surfaceContainerHighest,
            child: Row(
              children: [
                segment(bySport['swim'] ?? 0, sportColor('Swim', scheme)),
                segment(bySport['cycle'] ?? 0, sportColor('Ride', scheme)),
                segment(bySport['run'] ?? 0, sportColor('Run', scheme)),
                segment(otherSeconds, scheme.outline),
                if (fill < 1000) Spacer(flex: 1000 - fill),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
