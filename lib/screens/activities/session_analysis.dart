import 'package:flutter/material.dart';

import '../../data/models/local_activity.dart';
import '../../data/repositories/activities_repository.dart';
import '../../data/models/local_event.dart';
import '../../data/planned_items.dart';
import '../../evaluation/intensity.dart';
import '../../evaluation/session_evaluator.dart';
import '../../evaluation/session_streams.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/charts/stream_chart.dart';
import '../../widgets/section_card.dart';

String _clock(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;
  String two(int v) => v.toString().padLeft(2, '0');
  return h > 0 ? '$h:${two(m)}:${two(s)}' : '$m:${two(s)}';
}

/// Speed in m/s as min/km for runs, km/h otherwise.
String _speed(double mps, String? sport) {
  if ((sport ?? '').toLowerCase().contains('run') && mps > 0) {
    final secPerKm = (1000 / mps).round();
    return '${secPerKm ~/ 60}:${(secPerKm % 60).toString().padLeft(2, '0')} /km';
  }
  return '${(mps * 3.6).toStringAsFixed(1)} km/h';
}

String streamLabel(AppLocalizations l10n, String type) => switch (type) {
  'watts' => l10n.streamPower,
  'heartrate' => l10n.streamHeartRate,
  'velocity_smooth' => l10n.streamSpeed,
  'cadence' => l10n.streamCadence,
  'altitude' => l10n.streamAltitude,
  _ => type,
};

/// The session over time: stream chart (fetched on first open, cached
/// after), toggles per stream, and the detected intervals.
class SessionDiagramCard extends StatefulWidget {
  SessionDiagramCard({
    super.key,
    required this.activity,
    ActivityStreamsRepository? streams,
  }) : streams = streams ?? ActivityStreamsRepository();

  final LocalActivity activity;
  final ActivityStreamsRepository streams;

  @override
  State<SessionDiagramCard> createState() => _SessionDiagramCardState();
}

class _SessionDiagramCardState extends State<SessionDiagramCard> {
  late Future<SessionStreams> _future = widget.streams.load(widget.activity.id);
  Set<String>? _visible;

  void _retry() {
    setState(() {
      _future = widget.streams.load(widget.activity.id);
    });
  }

  String _format(String type, double v) => switch (type) {
    'watts' => '${v.round()} W',
    'heartrate' => '${v.round()} bpm',
    'velocity_smooth' => _speed(v, widget.activity.type),
    'cadence' => '${v.round()} rpm',
    'altitude' => '${v.round()} m',
    _ => v.toStringAsFixed(1),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return SectionCard(
      icon: Icons.show_chart,
      title: l10n.sessionDiagramTitle,
      child: FutureBuilder<SessionStreams>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snap.hasError) {
            return Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.sessionDiagramError('${snap.error}'),
                    style: muted,
                  ),
                ),
                TextButton(onPressed: _retry, child: Text(l10n.retryButton)),
              ],
            );
          }
          final streams = snap.data!;
          if (streams.isEmpty) {
            return Text(l10n.sessionDiagramNoData, style: muted);
          }
          final drawable = streams.drawable.toList();
          final visible = _visible ??= {
            for (final t in drawable)
              if (t == 'watts' || t == 'heartrate' || drawable.length <= 2) t,
          };
          if (visible.isEmpty && drawable.isNotEmpty) visible.add(drawable.first);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final t in drawable)
                    FilterChip(
                      key: ValueKey('stream-$t'),
                      label: Text(streamLabel(l10n, t)),
                      avatar: CircleAvatar(
                        radius: 5,
                        backgroundColor: streamColor(t, theme.colorScheme),
                      ),
                      selected: visible.contains(t),
                      onSelected: (on) => setState(
                        () => on ? visible.add(t) : visible.remove(t),
                      ),
                    ),
                ],
              ),
              StreamChart(streams: streams, visible: visible, format: _format),
              if (streams.intervals.any((i) => i.isWork)) ...[
                const SizedBox(height: 12),
                Text(l10n.sessionIntervalsTitle, style: theme.textTheme.titleSmall),
                for (final (n, i) in streams.intervals
                    .where((i) => i.isWork)
                    .indexed)
                  ListTile(
                    key: ValueKey('interval-$n'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(i.label ?? l10n.sessionIntervalN(n + 1)),
                    subtitle: Text(
                      [
                        if (i.movingTime != null) _clock(i.movingTime!),
                        if (i.averageWatts != null) '${i.averageWatts} W',
                        if (i.averageHeartrate != null)
                          '${i.averageHeartrate} bpm',
                        if (i.averageSpeed != null)
                          _speed(i.averageSpeed!, widget.activity.type),
                      ].join(' · '),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Planned versus actual, the intensity split, decoupling and a verdict with
/// its reasons — all from [SessionEvaluator]. [onAskTrainer] opens Chat with
/// this evaluation as context.
class SessionEvaluationCard extends StatefulWidget {
  SessionEvaluationCard({
    super.key,
    required this.activity,
    PlannedItemsRepository? plannedItems,
    this.onAskTrainer,
  }) : plannedItems = plannedItems ?? PlannedItemsRepository();

  final LocalActivity activity;
  final PlannedItemsRepository plannedItems;
  final void Function(SessionEvaluation evaluation)? onAskTrainer;

  @override
  State<SessionEvaluationCard> createState() => _SessionEvaluationCardState();
}

class _SessionEvaluationCardState extends State<SessionEvaluationCard> {
  late final Future<SessionEvaluation> _future = _evaluate();

  Future<SessionEvaluation> _evaluate() async {
    List<LocalEvent> planned;
    try {
      planned = await widget.plannedItems.getByDate(widget.activity.date);
    } catch (_) {
      planned = const [];
    }
    return const SessionEvaluator().evaluate(
      widget.activity,
      planned: matchPlanned(widget.activity, planned),
    );
  }

  String _pct(double v) => '${(v * 100).round()}%';

  String _reason(AppLocalizations l10n, EvalReason r) => switch (r) {
    ShortReason(:final actualMinutes, :final plannedMinutes) =>
      l10n.evalReasonShort(actualMinutes, plannedMinutes),
    TooIntenseReason(:final hardShare, :final limit) =>
      l10n.evalReasonTooIntense(_pct(hardShare), _pct(limit)),
    NotIntenseReason(:final hardShare, :final minimum) =>
      l10n.evalReasonNotIntense(_pct(hardShare), _pct(minimum)),
    LoadReason(:final actual, :final planned) =>
      l10n.evalReasonLoad(actual, planned),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    return SectionCard(
      icon: Icons.fact_check_outlined,
      title: l10n.sessionEvaluationTitle,
      child: FutureBuilder<SessionEvaluation>(
        future: _future,
        builder: (context, snap) {
          final e = snap.data;
          if (e == null) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final verdict = e.verdict;
          final (Color color, String label)? chip = verdict == null
              ? null
              : switch (verdict) {
                  Verdict.onTarget => (scheme.primary, l10n.verdictOnTarget),
                  Verdict.tooHard => (scheme.error, l10n.verdictTooHard),
                  Verdict.tooEasy => (scheme.tertiary, l10n.verdictTooEasy),
                  Verdict.cutShort => (scheme.error, l10n.verdictCutShort),
                };
          final plan = e.plan;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (chip != null)
                Row(
                  children: [
                    Container(
                      key: const ValueKey('verdict'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: chip.$1.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        chip.$2,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: chip.$1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Text(l10n.evalNoPlan, style: muted),
              for (final r in e.reasons)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('• ${_reason(l10n, r)}'),
                ),
              if (plan != null) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.evalPlannedVsActual(plan.planned.name ?? ''),
                  style: theme.textTheme.titleSmall,
                ),
                if (plan.plannedMinutes != null && plan.actualMinutes != null)
                  Text(
                    l10n.evalMinutes(
                      plan.actualMinutes!,
                      plan.plannedMinutes!,
                      _signed(plan.minutesDelta!),
                    ),
                    key: const ValueKey('eval-minutes'),
                  ),
                if (plan.plannedLoad != null && plan.actualLoad != null)
                  Text(
                    l10n.evalLoad(
                      plan.actualLoad!,
                      plan.plannedLoad!,
                      _signed(plan.loadDelta!),
                    ),
                    key: const ValueKey('eval-load'),
                  ),
              ],
              const SizedBox(height: 12),
              Text(l10n.evalSplitTitle, style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              IntensitySplitBar(split: e.split),
              const SizedBox(height: 8),
              Text(
                e.decouplingAssessable
                    ? l10n.evalDecoupling(
                        e.decouplingPercent!.toStringAsFixed(1),
                      )
                    : l10n.evalDecouplingNotAssessable,
                style: muted,
              ),
              const SizedBox(height: 4),
              Text(l10n.evalThresholdsNote, style: muted),
              if (widget.onAskTrainer != null) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  key: const ValueKey('ask-trainer'),
                  onPressed: () => widget.onAskTrainer!(e),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: Text(l10n.askTrainer),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  static String _signed(int v) => v > 0 ? '+$v' : '$v';
}

/// Low / moderate / high as one bar with percentages, or why there is none.
class IntensitySplitBar extends StatelessWidget {
  const IntensitySplitBar({super.key, required this.split});

  final IntensitySplit? split;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final s = split;
    if (s == null || s.total == 0) {
      return Text(
        l10n.evalSplitNotAssessable,
        style: theme.textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      );
    }
    final parts = [
      (s.low, scheme.primary, l10n.domainLow),
      (s.moderate, scheme.tertiary, l10n.domainModerate),
      (s.high, scheme.error, l10n.domainHigh),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Row(
            children: [
              for (final p in parts)
                if (p.$1 > 0)
                  Expanded(
                    flex: p.$1,
                    child: Container(height: 14, color: p.$2),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          [
            for (final p in parts) '${p.$3} ${(p.$1 / s.total * 100).round()}%',
          ].join(' · '),
          key: const ValueKey('split-text'),
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// On a planned session: what was actually done, when an activity of that
/// day and sport matches it — planned versus actual duration and load.
class PlannedActualCard extends StatefulWidget {
  PlannedActualCard({
    super.key,
    required this.event,
    ActivitiesRepository? activities,
    this.onOpen,
  }) : activities = activities ?? ActivitiesRepository();

  final LocalEvent event;
  final ActivitiesRepository activities;
  final ValueChanged<LocalActivity>? onOpen;

  @override
  State<PlannedActualCard> createState() => _PlannedActualCardState();
}

class _PlannedActualCardState extends State<PlannedActualCard> {
  late final Future<LocalActivity?> _match = _find();

  Future<LocalActivity?> _find() async {
    final done = await widget.activities.getByDate(widget.event.date);
    final matches = matchAll(done, [widget.event]);
    for (final a in done) {
      if (matches.containsKey(a.id)) return a;
    }
    return null;
  }

  static String _signed(int v) => v > 0 ? '+$v' : '$v';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<LocalActivity?>(
      future: _match,
      builder: (context, snap) {
        final a = snap.data;
        if (a == null) return const SizedBox.shrink();
        final plannedMin = widget.event.plannedTime == null
            ? null
            : (widget.event.plannedTime! / 60).round();
        final actualMin = a.movingTime == null
            ? null
            : (a.movingTime! / 60).round();
        final plannedLoad = widget.event.plannedLoad;
        final actualLoad = a.trainingLoad;
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: SectionCard(
            key: const ValueKey('planned-actual'),
            icon: Icons.check_circle_outline,
            title: l10n.plannedDoneTitle(a.name ?? a.type ?? ''),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (plannedMin != null && actualMin != null)
                  Text(
                    l10n.evalMinutes(
                      actualMin,
                      plannedMin,
                      _signed(actualMin - plannedMin),
                    ),
                  ),
                if (plannedLoad != null && actualLoad != null)
                  Text(
                    l10n.evalLoad(
                      actualLoad,
                      plannedLoad,
                      _signed(actualLoad - plannedLoad),
                    ),
                  ),
                if (widget.onOpen != null)
                  TextButton(
                    onPressed: () => widget.onOpen!(a),
                    child: Text(l10n.plannedOpenActivity),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
