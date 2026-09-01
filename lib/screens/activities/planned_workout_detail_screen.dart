import 'package:flutter/material.dart';

import '../../data/models/local_event.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/section_card.dart';
import '../../widgets/stat_tile.dart';
import 'activity_icons.dart';
import 'planned_workout_actions.dart';

/// A *planned* calendar entry's details — the counterpart to
/// [ActivityDetailScreen] for something that hasn't happened yet.
///
/// Pops `true` when the session was deleted, so whoever pushed it knows the
/// entry it was showing is gone.
class PlannedWorkoutDetailScreen extends StatefulWidget {
  const PlannedWorkoutDetailScreen({super.key, required this.event});

  final LocalEvent event;

  @override
  State<PlannedWorkoutDetailScreen> createState() =>
      _PlannedWorkoutDetailScreenState();
}

class _PlannedWorkoutDetailScreenState
    extends State<PlannedWorkoutDetailScreen> {
  /// Set while the delete round-trip runs, so the buttons can't be tapped
  /// twice into a second (now failing) delete.
  bool _deleting = false;

  Future<void> _delete() async {
    setState(() => _deleting = true);
    final deleted = await confirmAndDeletePlannedWorkout(
      context,
      widget.event,
    );
    if (!mounted) return;
    if (deleted) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final tiles = <StatTile>[
      if (event.plannedTime != null && event.plannedTime! > 0)
        StatTile(
          label: l10n.durationLabel,
          value: formatDurationSecs(event.plannedTime!),
          icon: Icons.timer_outlined,
          color: colorScheme.tertiary,
        ),
      if (event.plannedDistance != null && event.plannedDistance! > 0)
        StatTile(
          label: l10n.distanceLabel,
          value: formatDistanceMeters(event.plannedDistance!),
          icon: Icons.straighten_outlined,
          color: colorScheme.primary,
        ),
      if (event.plannedLoad != null)
        StatTile(
          label: l10n.plannedTssLabel,
          value: '${event.plannedLoad}',
          icon: Icons.bolt_outlined,
          color: colorScheme.secondary,
        ),
      if (event.indoor)
        StatTile(
          label: l10n.locationLabel,
          value: l10n.indoorLabel,
          icon: Icons.home_outlined,
          color: colorScheme.primary,
        ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.titlePlannedTraining)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colorScheme.primary, colorScheme.tertiary],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    activityTypeIcon(event.type),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.name ?? event.type ?? l10n.plannedSessionFallback,
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          formatIsoDate(event.date),
                          if (event.type != null) event.type!,
                        ].join(' · '),
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (tiles.isNotEmpty) ...[
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.95,
              children: tiles,
            ),
          ],
          if (event.description != null && event.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            SectionCard(
              icon: Icons.notes_outlined,
              title: l10n.workoutTitle,
              child: Text(event.description!.trim()),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _deleting
                    ? null
                    : () => addPlannedWorkoutToGoogleCalendar(context, event),
                icon: const Icon(Icons.event_outlined),
                label: Text(l10n.addToGoogleCalendar),
              ),
              if (canDeletePlannedWorkout(event))
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                  ),
                  onPressed: _deleting ? null : _delete,
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.deleteButton),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
