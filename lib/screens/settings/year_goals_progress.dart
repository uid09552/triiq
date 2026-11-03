import 'package:flutter/material.dart';

import '../../data/models/local_activity.dart';
import '../../data/repositories/activities_repository.dart';
import '../../data/sync/auto_sync_service.dart';
import '../../l10n/app_localizations.dart';
import '../../util/dates.dart';
import '../activities/activity_icons.dart';
import 'year_goals_settings.dart';

/// Kilometres per canonical sport (`swim`/`cycle`/`run`) across [activities];
/// other sports are left out, like the weekly rings.
Map<String, double> yearSportKm(List<LocalActivity> activities) {
  final totals = <String, double>{};
  for (final a in activities) {
    final sport = canonicalSport(a.type);
    if (sport == null) continue;
    totals[sport] = (totals[sport] ?? 0) + (a.distance ?? 0) / 1000;
  }
  return totals;
}

/// How much of the year has passed at [now], 0..1 (by day).
double yearElapsedFraction(DateTime now) {
  final start = DateTime(now.year);
  final end = DateTime(now.year + 1);
  final day = dateOnly(now).difference(start).inDays + 1;
  return day / end.difference(start).inDays;
}

/// Progress bars for the year goals: distance so far against the goal, a
/// marker where an even pace would be by today, how far ahead or behind
/// that is, and where the year ends up at the current pace.
///
/// Reads the activities cached on this device for the calendar year, so the
/// numbers are only as complete as the last year sync.
class YearGoalsProgress extends StatefulWidget {
  YearGoalsProgress({
    super.key,
    YearGoalsSettings? settings,
    ActivitiesRepository? activities,
    this.now,
  }) : settings = settings ?? YearGoalsSettings.instance,
       activities = activities ?? ActivitiesRepository();

  final YearGoalsSettings settings;
  final ActivitiesRepository activities;

  /// Test seam for the date.
  final DateTime? now;

  @override
  State<YearGoalsProgress> createState() => _YearGoalsProgressState();
}

class _YearGoalsProgressState extends State<YearGoalsProgress> {
  Map<String, double> _km = const {};

  DateTime get _now => widget.now ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    AutoSyncService.instance.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    AutoSyncService.instance.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final now = _now;
      final records = await widget.activities.getRange(
        isoDate(DateTime(now.year)),
        isoDate(now),
      );
      if (mounted) setState(() => _km = yearSportKm(records));
    } catch (error) {
      debugPrint('YearGoalsProgress: cannot read activities: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final elapsed = yearElapsedFraction(_now);

    return ListenableBuilder(
      listenable: widget.settings,
      builder: (context, _) {
        final rows = <Widget>[];
        for (final (sport, label, type) in [
          ('swim', l10n.sportSwim, 'Swim'),
          ('cycle', l10n.sportRide, 'Ride'),
          ('run', l10n.sportRun, 'Run'),
        ]) {
          final goal = widget.settings.goalFor(sport);
          if (goal == null) continue;
          final done = _km[sport] ?? 0;
          final color = sportColor(type, scheme);
          final progress = done / goal;
          final expected = goal * elapsed;
          final diff = done - expected;
          final onTrack = diff.abs() <= goal * 0.02;
          final projected = elapsed > 0.03 ? done / elapsed : null;
          final status = onTrack
              ? l10n.yearGoalOnTrack
              : diff > 0
              ? l10n.yearGoalAhead(diff.round().toString())
              : l10n.yearGoalBehind((-diff).round().toString());

          rows.add(
            Padding(
              key: ValueKey('year-goal-$sport'),
              padding: EdgeInsets.only(top: rows.isEmpty ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(activityTypeIcon(type), size: 18, color: color),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Text(
                        '${done.round()} / ${goal.round()} km',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _Bar(
                    progress: progress,
                    pace: elapsed,
                    color: progress >= 1 ? scheme.tertiary : color,
                    track: scheme.surfaceContainerHighest,
                    marker: scheme.onSurface,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      '${(progress * 100).round()}%',
                      status,
                      if (projected != null && progress < 1)
                        l10n.yearGoalProjection(projected.round().toString()),
                    ].join(' · '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows,
        );
      },
    );
  }
}

/// A rounded progress bar with a tick where an even pace would be today.
class _Bar extends StatelessWidget {
  const _Bar({
    required this.progress,
    required this.pace,
    required this.color,
    required this.track,
    required this.marker,
  });

  final double progress;
  final double pace;
  final Color color;
  final Color track;
  final Color marker;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return SizedBox(
          height: 12,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Stack(
                  children: [
                    Container(color: track),
                    TweenAnimationBuilder<double>(
                      tween: Tween(end: progress.clamp(0.0, 1.0).toDouble()),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => FractionallySizedBox(
                        widthFactor: value,
                        child: Container(color: color),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: (width * pace.clamp(0.0, 1.0)) - 1,
                top: -2,
                bottom: -2,
                child: Container(width: 2, color: marker.withValues(alpha: 0.7)),
              ),
            ],
          ),
        );
      },
    );
  }
}
