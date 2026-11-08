import 'package:flutter/material.dart';

import '../../data/models/local_activity.dart';
import '../../data/repositories/activities_repository.dart';
import '../../evaluation/session_streams.dart';
import '../../l10n/app_localizations.dart';
import '../../season/brick_analysis.dart';
import '../../widgets/section_card.dart';
import '../season/season_format.dart';

/// Loads what the brick card needs: the same-day activities and, for the
/// second leg of a bike→run, its streams (cached after the first look).
class BrickLoader {
  BrickLoader({
    ActivitiesRepository? activities,
    ActivityStreamsRepository? streams,
  }) : _activities = activities ?? ActivitiesRepository(),
       _streams = streams ?? ActivityStreamsRepository();

  final ActivitiesRepository _activities;
  final ActivityStreamsRepository _streams;

  /// The analysis when [activity] is part of a brick, else null.
  Future<BrickAnalysis?> load(LocalActivity activity) async {
    final day = await _activities.getByDate(activity.date);
    final brick = brickFor(activity, day);
    if (brick == null) return null;
    SessionStreams? streams;
    if (brick.kind == BrickKind.bikeRun) {
      try {
        streams = await _streams.load(brick.second.id);
      } catch (_) {
        // Offline or not available: judge the transition only.
      }
    }
    return analyseBrick(brick, streams);
  }
}

String brickNoteText(AppLocalizations l10n, BrickNote n) => switch (n) {
  BrickNote.settledFast => l10n.brickNoteSettledFast,
  BrickNote.settledSlow => l10n.brickNoteSettledSlow,
  BrickNote.slowStart => l10n.brickNoteSlowStart,
  BrickNote.highEarlyCost => l10n.brickNoteHighEarlyCost,
  BrickNote.hardFirstLeg => l10n.brickNoteHardFirstLeg,
  BrickNote.quickTransition => l10n.brickNoteQuickTransition,
  BrickNote.longTransition => l10n.brickNoteLongTransition,
  BrickNote.noStream => l10n.brickNoteNoStream,
};

/// "Brick: bike → run" with the transition and how the legs came round.
/// Renders nothing when the activity is not part of a brick.
class BrickCard extends StatefulWidget {
  BrickCard({super.key, required this.activity, BrickLoader? loader})
    : loader = loader ?? BrickLoader();

  final LocalActivity activity;
  final BrickLoader loader;

  @override
  State<BrickCard> createState() => _BrickCardState();
}

class _BrickCardState extends State<BrickCard> {
  late final Future<BrickAnalysis?> _future = widget.loader
      .load(widget.activity)
      .catchError((_) => null);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<BrickAnalysis?>(
      future: _future,
      builder: (context, snap) {
        final a = snap.data;
        if (a == null) return const SizedBox.shrink();
        final theme = Theme.of(context);
        final verdict = switch (a.verdict) {
          BrickVerdict.good => l10n.brickVerdictGood,
          BrickVerdict.ok => l10n.brickVerdictOk,
          BrickVerdict.rough => l10n.brickVerdictRough,
          BrickVerdict.unknown => l10n.brickVerdictUnknown,
        };
        final color = switch (a.verdict) {
          BrickVerdict.good => theme.colorScheme.primary,
          BrickVerdict.ok => theme.colorScheme.secondary,
          BrickVerdict.rough => theme.colorScheme.error,
          BrickVerdict.unknown => theme.colorScheme.outline,
        };
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SectionCard(
            key: const ValueKey('brick-card'),
            icon: Icons.link,
            title: a.brick.kind == BrickKind.bikeRun
                ? l10n.brickTitleBikeRun
                : l10n.brickTitleSwimBike,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.brickSessions(
                    a.brick.first.name ?? a.brick.first.type ?? '',
                    a.brick.second.name ?? a.brick.second.type ?? '',
                  ),
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  verdict,
                  key: const ValueKey('brick-verdict'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(l10n.brickTransition(clock(a.transitionSeconds))),
                if (a.settleSeconds != null)
                  Text(l10n.brickSettle(clock(a.settleSeconds!))),
                if (a.earlySpeedRatio != null)
                  Text(
                    l10n.brickEarly(
                      (a.earlySpeedRatio! * 100).toStringAsFixed(0),
                    ),
                  ),
                const SizedBox(height: 8),
                for (final n in a.notes)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '• ${brickNoteText(l10n, n)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
