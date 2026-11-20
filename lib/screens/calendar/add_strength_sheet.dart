import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/intervals_session.dart';
import '../../data/intervals_workout_service.dart';
import '../../data/sync/auto_sync_service.dart';
import '../../data/sync/sync_service.dart';
import '../../l10n/app_localizations.dart';
import '../../plan/bodyweight_strength.dart';
import '../today/strength_target_chips.dart';
import '../today/train_now_screen.dart';

/// What the sheet hands back: put the default session on the calendar, or
/// let the trainer write one.
sealed class StrengthChoice {
  const StrengthChoice(this.targets, this.minutes);
  final Set<StrengthTarget> targets;
  final int minutes;
}

class StrengthAdd extends StrengthChoice {
  const StrengthAdd(super.targets, super.minutes);
}

class StrengthAskTrainer extends StrengthChoice {
  const StrengthAskTrainer(super.targets, super.minutes);
}

/// The planned workout "Add strength training" writes: bodyweight only,
/// aimed at [targets], [minutes] long, on [day].
PlannedWorkoutDraft bodyweightStrengthDraft(
  DateTime day,
  Set<StrengthTarget> targets,
  int minutes,
) => PlannedWorkoutDraft(
  name: bodyweightStrengthName(targets),
  sport: bodyweightStrengthSport,
  description: bodyweightStrengthDescription(targets, minutes: minutes),
  date: DateTime(day.year, day.month, day.day),
  durationSeconds: minutes * 60,
  load: bodyweightStrengthLoad(minutes),
  indoor: true,
);

/// Calendar day action "Add strength training": pick the sports it should
/// help and its length, see the exercises, then add it to the day — or
/// hand the same choice to Train now for the trainer to write.
///
/// [writer], [connected], [afterCreate] and [openTrainer] are test seams.
Future<void> showAddStrengthSheet(
  BuildContext context,
  DateTime day, {
  PlannedWorkoutWriter? writer,
  bool? connected,
  Future<void> Function(DateTime day)? afterCreate,
  void Function(
    BuildContext context,
    DateTime day,
    Set<StrengthTarget> t,
    int minutes,
  )?
  openTrainer,
}) async {
  final isConnected = connected ?? IntervalsSession.instance.isConnected;
  final choice = await showModalBottomSheet<StrengthChoice>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => _AddStrengthSheet(day: day, connected: isConnected),
  );
  if (choice == null || !context.mounted) return;
  final l10n = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);

  switch (choice) {
    case StrengthAskTrainer(:final targets, :final minutes):
      if (openTrainer != null) {
        openTrainer(context, day, targets, minutes);
      } else {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TrainNowScreen(
              today: () => day,
              initialSport: bodyweightStrengthSport,
              initialStrengthTargets: targets,
            ),
          ),
        );
      }
    case StrengthAdd(:final targets, :final minutes):
      final draft = bodyweightStrengthDraft(day, targets, minutes);
      try {
        final event = await (writer ?? IntervalsWorkoutService())
            .createPlannedWorkout(draft);
        try {
          await (afterCreate ?? _resync)(day);
        } catch (_) {
          // It is on Intervals.icu either way; the next sync brings it in.
        }
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.workoutCreated(event.name ?? draft.name)),
          ),
        );
      } catch (error) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.couldNotCreateWorkout('$error'))),
        );
      }
  }
}

Future<void> _resync(DateTime day) async {
  await SyncService().syncMonth(day);
  AutoSyncService.instance.notifyCacheChanged();
}

class _AddStrengthSheet extends StatefulWidget {
  const _AddStrengthSheet({required this.day, required this.connected});

  final DateTime day;
  final bool connected;

  @override
  State<_AddStrengthSheet> createState() => _AddStrengthSheetState();
}

class _AddStrengthSheetState extends State<_AddStrengthSheet> {
  static const _lengths = [20, 30, 45];

  Set<StrengthTarget> _targets = {...StrengthTarget.values};
  int _minutes = 30;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final sets = bodyweightSets(_minutes);
    final exercises = bodyweightExercises(_targets, minutes: _minutes);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.dayAddStrength} · '
              '${DateFormat.MMMEd(locale).format(widget.day)}',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.strengthBodyweightHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Text(l10n.strengthTargetsLabel, style: theme.textTheme.titleSmall),
            const SizedBox(height: 6),
            StrengthTargetChips(
              selected: _targets,
              onChanged: (t) => setState(() => _targets = t),
            ),
            const SizedBox(height: 12),
            SegmentedButton<int>(
              key: const ValueKey('strength-length'),
              showSelectedIcon: false,
              segments: [
                for (final m in _lengths)
                  ButtonSegment(value: m, label: Text(l10n.minutesShort(m))),
              ],
              selected: {_minutes},
              onSelectionChanged: (s) => setState(() => _minutes = s.first),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView(
                  key: const ValueKey('strength-exercises'),
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  children: [
                    for (final (i, e) in exercises.indexed)
                      ListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        title: Text(
                          e.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(e.cue),
                        trailing: Text(
                          i == 0 || i == exercises.length - 1
                              ? e.reps.split(':').first
                              : '$sets × ${e.reps.split(' (').first}',
                          style: theme.textTheme.labelMedium,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                OutlinedButton.icon(
                  key: const ValueKey('strength-ask-trainer'),
                  onPressed: () => Navigator.of(
                    context,
                  ).pop(StrengthAskTrainer(_targets, _minutes)),
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: Text(l10n.strengthSheetAskTrainer),
                ),
                FilledButton.icon(
                  key: const ValueKey('strength-add'),
                  onPressed: widget.connected
                      ? () => Navigator.of(
                          context,
                        ).pop(StrengthAdd(_targets, _minutes))
                      : null,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.strengthSheetAdd),
                ),
              ],
            ),
            if (!widget.connected) ...[
              const SizedBox(height: 6),
              Text(
                l10n.connectToCreateWorkout,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
