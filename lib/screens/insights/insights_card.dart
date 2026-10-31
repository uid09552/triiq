import 'package:flutter/material.dart';

import '../../data/models/local_activity.dart';
import '../../data/models/local_event.dart';
import '../../data/planned_items.dart';
import '../../data/repositories/activities_repository.dart';
import '../../data/repositories/wellness_repository.dart';
import '../../evaluation/insights.dart';
import '../../evaluation/session_evaluator.dart';
import '../../l10n/app_localizations.dart';
import '../../plan/knowledge.dart';
import '../../util/dates.dart';
import '../../widgets/section_card.dart';

/// What [InsightsCard] shows, gathered from the cache.
class SessionInsights {
  const SessionInsights({
    required this.bests,
    required this.efficiency,
    required this.recovery,
  });

  final List<BestEffort> bests;
  final EfficiencyTrend? efficiency;

  /// Only for a session done today.
  final RecoveryHint? recovery;

  bool get isEmpty => bests.isEmpty && efficiency == null && recovery == null;
}

/// Gathers [SessionInsights] for one activity.
class SessionInsightsLoader {
  SessionInsightsLoader({
    ActivitiesRepository? activities,
    PlannedItemsRepository? planned,
    WellnessRepository? wellness,
    KnowledgeRepository? knowledge,
    DateTime Function()? clock,
  }) : _activities = activities ?? ActivitiesRepository(),
       _planned = planned ?? PlannedItemsRepository(),
       _wellness = wellness ?? WellnessRepository(),
       _knowledge = knowledge ?? KnowledgeRepository(),
       _clock = clock ?? DateTime.now;

  final ActivitiesRepository _activities;
  final PlannedItemsRepository _planned;
  final WellnessRepository _wellness;
  final KnowledgeRepository _knowledge;
  final DateTime Function() _clock;

  Future<SessionInsights> load(LocalActivity a) async {
    final day = DateTime.tryParse(a.date) ?? _clock();
    final planned = matchPlanned(a, await _planned.getByDate(a.date));
    final history = await _activities.getRange(
      isoDate(day.subtract(const Duration(days: efficiencyWindowDays))),
      isoDate(day.subtract(const Duration(days: 1))),
    );

    RecoveryHint? recovery;
    final today = dateOnly(_clock());
    if (dateOnly(day) == today && a.trainingLoad != null) {
      final wellness = await _wellness.getRange(
        isoDate(today.subtract(const Duration(days: 3))),
        isoDate(today),
      );
      double? form;
      for (final w in wellness) {
        if (w.ctl != null && w.atl != null) form = w.ctl! - w.atl!;
      }
      final start = DateTime.tryParse(a.raw['start_date_local'] as String? ?? '');
      final ended = start == null
          ? _clock()
          : start.add(Duration(seconds: a.movingTime ?? 0));
      final tomorrow = today.add(const Duration(days: 1));
      final rules = (await _knowledge.load()).rules.recovery;
      recovery = recoveryHint(
        tss: a.trainingLoad!,
        form: form,
        endedAt: ended,
        tomorrow: await _planned.getByDate(isoDate(tomorrow)),
        rules: rules,
      );
    }

    return SessionInsights(
      bests: personalBests(a.raw),
      efficiency: efficiencyTrend(a, history, planned: planned),
      recovery: recovery,
    );
  }
}

/// Personal bests, the efficiency trend and (for today's session) the
/// recovery hint. [onFindAlternative] gets tomorrow's conflicting session.
class InsightsCard extends StatefulWidget {
  InsightsCard({
    super.key,
    required this.activity,
    SessionInsightsLoader? loader,
    this.onFindAlternative,
  }) : loader = loader ?? SessionInsightsLoader();

  final LocalActivity activity;
  final SessionInsightsLoader loader;
  final ValueChanged<LocalEvent>? onFindAlternative;

  @override
  State<InsightsCard> createState() => _InsightsCardState();
}

class _InsightsCardState extends State<InsightsCard> {
  late final Future<SessionInsights> _future = widget.loader.load(
    widget.activity,
  );

  String _duration(int secs) {
    if (secs < 60) return '$secs s';
    if (secs < 3600) return '${secs ~/ 60} min';
    return '${(secs / 3600).toStringAsFixed(secs % 3600 == 0 ? 0 : 1)} h';
  }

  /// 1260 → "21:00", 4000 → "1:06:40".
  String _clock(double secs) {
    final s = secs.round();
    String two(int v) => v.toString().padLeft(2, '0');
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    return h > 0 ? '$h:${two(m)}:${two(s % 60)}' : '$m:${two(s % 60)}';
  }

  String _distance(double m) =>
      m >= 1000 ? '${(m / 1000).toStringAsFixed(m % 1000 == 0 ? 0 : 1)} km' : '${m.round()} m';

  String _best(AppLocalizations l10n, BestEffort b) {
    final previous = b.previous;
    final String main;
    final String? was;
    switch (b.kind) {
      case BestEffortKind.power:
        main = l10n.bestPower(_duration(b.seconds!), b.value.round());
        was = previous == null ? null : '${previous.round()} W';
      case BestEffortKind.time:
        main = l10n.bestTime(
          b.distance == null ? '' : _distance(b.distance!),
          _clock(b.value),
        );
        was = previous == null ? null : _clock(previous);
      case BestEffortKind.pace || BestEffortKind.other:
        main = b.label ?? l10n.bestOther(b.value.toStringAsFixed(1));
        was = previous?.toStringAsFixed(1);
    }
    return was == null ? main : l10n.bestWas(main, was);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return FutureBuilder<SessionInsights>(
      future: _future,
      builder: (context, snap) {
        final i = snap.data;
        if (i == null || i.isEmpty) return const SizedBox.shrink();
        final ef = i.efficiency;
        final r = i.recovery;
        return SectionCard(
          key: const ValueKey('insights'),
          icon: Icons.auto_graph,
          title: l10n.insightsTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (i.bests.isNotEmpty) ...[
                Text(l10n.insightsBests, style: theme.textTheme.titleSmall),
                for (final b in i.bests)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.emoji_events_outlined, size: 18),
                        const SizedBox(width: 6),
                        Expanded(child: Text(_best(l10n, b))),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
              ],
              if (ef != null) ...[
                Text(l10n.insightsEfficiency, style: theme.textTheme.titleSmall),
                Text(
                  ef.median == null
                      ? l10n.insightsEfficiencyTooFew(
                          ef.value.toStringAsFixed(2),
                          efficiencyMinSessions,
                        )
                      : l10n.insightsEfficiencyChange(
                          ef.value.toStringAsFixed(2),
                          _signedPct(ef.change!),
                          ef.sessions,
                        ),
                  key: const ValueKey('insights-ef'),
                ),
                const SizedBox(height: 10),
              ],
              if (r != null) ...[
                Text(l10n.insightsRecovery, style: theme.textTheme.titleSmall),
                Text(
                  l10n.insightsRecoveryHours(r.hours),
                  key: const ValueKey('insights-recovery'),
                ),
                Text(
                  r.penalised
                      ? l10n.insightsRecoveryRuleForm(
                          r.tss,
                          r.form!.toStringAsFixed(0),
                        )
                      : l10n.insightsRecoveryRule(r.tss),
                  style: muted,
                ),
                if (r.conflict != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    l10n.insightsRecoveryConflict(r.conflict!.name ?? ''),
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  if (widget.onFindAlternative != null)
                    TextButton.icon(
                      key: const ValueKey('insights-alternative'),
                      onPressed: () => widget.onFindAlternative!(r.conflict!),
                      icon: const Icon(Icons.swap_horiz),
                      label: Text(l10n.findAlternative),
                    ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  static String _signedPct(double f) {
    final p = (f * 100).round();
    return p > 0 ? '+$p' : '$p';
  }
}
