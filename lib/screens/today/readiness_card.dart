import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../agent/chat_handoff.dart';
import '../../data/models/local_event.dart';
import '../../evaluation/readiness.dart';
import '../../evaluation/readiness_service.dart';
import '../../evaluation/session_evaluator.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/hold_preview.dart';
import '../../widgets/gauge_ring.dart';
import '../../widgets/main_navigation.dart';
import 'readiness_options.dart';
import 'readiness_peek.dart';
import 'readiness_screen.dart';

String readinessLevelLabel(AppLocalizations l10n, ReadinessLevel level) =>
    switch (level) {
      ReadinessLevel.ready => l10n.readinessReady,
      ReadinessLevel.caution => l10n.readinessCaution,
      ReadinessLevel.backOff => l10n.readinessBackOff,
    };

String readinessSignalLabel(AppLocalizations l10n, ReadinessSignalKind kind) =>
    switch (kind) {
      ReadinessSignalKind.hrv => l10n.readinessSignalHrv,
      ReadinessSignalKind.restingHr => l10n.readinessSignalRestingHr,
      ReadinessSignalKind.sleep => l10n.readinessSignalSleep,
      ReadinessSignalKind.form => l10n.readinessSignalForm,
      ReadinessSignalKind.subjective => l10n.readinessSignalSubjective,
      ReadinessSignalKind.load => l10n.readinessSignalLoad,
      ReadinessSignalKind.device => l10n.readinessSignalDevice,
    };

/// Green / amber / red, from the theme where it has a fitting role.
Color readinessColor(ColorScheme scheme, ReadinessLevel level) =>
    switch (level) {
      ReadinessLevel.ready => Colors.green.shade600,
      ReadinessLevel.caution => Colors.amber.shade700,
      ReadinessLevel.backOff => scheme.error,
    };

/// A planned session readiness would warn about: an interval session, or a
/// TriIQ long session (its slot says so even though [SessionEvaluator]
/// counts long as easy intensity — it is still a big day).
bool isHardSession(LocalEvent event) =>
    event.planSessionSlot == 'long' ||
    SessionEvaluator.intentOf(event) == SessionIntent.hard;

/// Today's readiness as a compact card: a score ring in the status colour,
/// the status and what drives it, and a row of small signal pills (HRV,
/// resting HR, sleep, form, feel, and CTL with its trend) each tinted by how
/// it rates. Opens the detail screen on tap.
class ReadinessCard extends StatelessWidget {
  const ReadinessCard({super.key, required this.report});

  final ReadinessReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final r = report.readiness;
    final color = readinessColor(scheme, r.level);
    final hasData = r.dataState != ReadinessDataState.noData;

    final String subtitle;
    switch (r.dataState) {
      case ReadinessDataState.noData:
        subtitle = l10n.readinessNoData;
      case ReadinessDataState.waitingForToday:
        subtitle = l10n.readinessWaiting(
          _shortDate(context, r.lastRecordedDate),
        );
      case ReadinessDataState.complete:
        subtitle = r.reasons.isEmpty
            ? l10n.readinessAllOk
            : l10n.readinessReasons(
                r.reasons
                    .map((s) => readinessSignalLabel(l10n, s.kind))
                    .join(', '),
              );
    }
    final score = r.dataState == ReadinessDataState.complete
        ? readinessScore(r)
        : null;

    return Card(
      key: const ValueKey('readiness-card'),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ReadinessScreen(report: report)),
        ),
        // Which values count toward readiness.
        onLongPress: () => showReadinessOptions(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _ScoreRing(
                    score: score,
                    level: r.level,
                    color: color,
                    dim: !hasData,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.readinessTitle.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            letterSpacing: 1.1,
                          ),
                        ),
                        Text(
                          readinessLevelLabel(l10n, r.level),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: hasData ? color : scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                ],
              ),
              if (hasData) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _SignalPills(report: report),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The readiness gauge: the 0–100 score in the middle with a small icon for
/// the status beneath it (ready, caution, rest), the arc in the status colour.
/// An empty ring, "–" and a dash when there is no score yet.
class _ScoreRing extends StatelessWidget {
  const _ScoreRing({
    required this.score,
    required this.level,
    required this.color,
    this.dim = false,
  });

  final int? score;
  final ReadinessLevel level;
  final Color color;
  final bool dim;

  static IconData _icon(ReadinessLevel level) => switch (level) {
    ReadinessLevel.ready => Icons.bolt_rounded,
    ReadinessLevel.caution => Icons.warning_amber_rounded,
    ReadinessLevel.backOff => Icons.bedtime_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tone = dim ? scheme.onSurfaceVariant : color;
    final l10n = AppLocalizations.of(context)!;
    return GaugeRing(
      semanticsLabel: score == null
          ? l10n.a11yReadinessNoScore
          : l10n.a11yReadinessScore(score!),
      progress: (score ?? 0) / 100,
      color: color,
      size: 76,
      strokeWidth: 6,
      dim: dim,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            score == null ? '–' : '$score',
            key: const ValueKey('readiness-score'),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: dim ? scheme.onSurfaceVariant : null,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Icon(
            dim ? Icons.remove_rounded : _icon(level),
            key: ValueKey('readiness-ring-${dim ? 'none' : level.name}'),
            size: 14,
            color: tone,
          ),
        ],
      ),
    );
  }
}

/// HRV, resting HR, sleep, form and feel with today's value, tinted by
/// rating — plus CTL with its change over the last week as the fitness
/// indicator.
class _SignalPills extends StatelessWidget {
  const _SignalPills({required this.report});

  final ReadinessReport report;

  static String _num(double v, [int digits = 0]) => v.toStringAsFixed(digits);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final r = report.readiness;

    String? valueOf(ReadinessSignal s) {
      final v = s.value;
      if (v == null) return null;
      return switch (s.kind) {
        ReadinessSignalKind.hrv => _num(v),
        ReadinessSignalKind.restingHr => _num(v),
        ReadinessSignalKind.sleep => '${_num(v, 1)} h',
        ReadinessSignalKind.form => '${v >= 0 ? '+' : ''}${_num(v)}',
        ReadinessSignalKind.subjective => '${v.round()}/4',
        ReadinessSignalKind.load => _num(v, 2),
        ReadinessSignalKind.device => _num(v),
      };
    }

    Color tint(SignalRating rating) => switch (rating) {
      SignalRating.ok => Colors.green.shade600,
      SignalRating.caution => Colors.amber.shade700,
      SignalRating.backOff => scheme.error,
      _ => scheme.outline,
    };

    final pills = <Widget>[
      for (final s in r.active)
        // The device's own figure is a bonus signal: no pill without one.
        if (!(s.kind == ReadinessSignalKind.device &&
            s.rating == SignalRating.missing))
          // Hold a pill to peek at the signal behind it.
          HoldPreview(
            preview: (_) => ReadinessPeek.signal(signal: s, report: report),
            child: _Pill(
              key: ValueKey('pill-${s.kind.name}'),
              label: readinessSignalLabel(l10n, s.kind),
              value: valueOf(s) ?? '–',
              color: tint(s.rating),
              icon: switch (s.rating) {
                SignalRating.ok => Icons.check_circle,
                SignalRating.caution => Icons.warning_amber_rounded,
                SignalRating.backOff => Icons.error,
                _ => Icons.remove_circle_outline,
              },
              rating: switch (s.rating) {
                SignalRating.ok => l10n.a11ySignalOk,
                SignalRating.caution => l10n.a11ySignalCaution,
                SignalRating.backOff => l10n.a11ySignalBackOff,
                _ => l10n.a11ySignalNone,
              },
            ),
          ),
    ];

    // Fitness: latest CTL and its change against a week before.
    final withCtl = [
      for (final w in report.records)
        if (w.ctl != null) w,
    ]..sort((a, b) => a.date.compareTo(b.date));
    if (withCtl.isNotEmpty) {
      final last = withCtl.last;
      final lastDay = DateTime.tryParse(last.date);
      double? before;
      if (lastDay != null) {
        final target = lastDay.subtract(const Duration(days: 7));
        for (final w in withCtl) {
          final d = DateTime.tryParse(w.date);
          if (d != null && !d.isAfter(target)) before = w.ctl;
        }
      }
      final delta = before == null ? null : last.ctl! - before;
      pills.add(
        HoldPreview(
          preview: (_) => ReadinessPeek.fitness(report: report),
          child: _Pill(
            key: const ValueKey('pill-fitness'),
            label: l10n.readinessFitness,
            value:
                '${_num(last.ctl!)}'
                '${delta == null
                    ? ''
                    : delta > 0.5
                    ? ' ↗'
                    : delta < -0.5
                    ? ' ↘'
                    : ' →'}',
            color: scheme.primary,
          ),
        ),
      );
    }

    return Wrap(spacing: 6, runSpacing: 4, children: pills);
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.icon,
    this.rating,
  });

  final String label;
  final String value;
  final Color color;

  /// The rating as a shape, not only a colour.
  final IconData? icon;

  /// The rating in words, for a screen reader.
  final String? rating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      label: rating == null ? '$label $value' : '$label $value, $rating',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null)
                  Icon(icon, size: 12, color: color)
                else
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when readiness says Caution or Back off and today has a hard
/// session: a nudge, and a way to talk it through. It never touches the
/// plan.
class ReadinessHint extends StatelessWidget {
  const ReadinessHint({
    super.key,
    required this.readiness,
    required this.todaysPlan,
  });

  final Readiness readiness;
  final List<LocalEvent> todaysPlan;

  /// The hard session the hint is about, or `null` when no hint is due.
  static LocalEvent? hardSessionFor(
    Readiness readiness,
    List<LocalEvent> todaysPlan,
  ) {
    if (readiness.level == ReadinessLevel.ready) return null;
    return todaysPlan.where(isHardSession).firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final session = hardSessionFor(readiness, todaysPlan);
    if (session == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final level = readinessLevelLabel(l10n, readiness.level);
    final name = session.name ?? session.type ?? l10n.activityFallback;

    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.readinessHintTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(l10n.readinessHintBody(level, name)),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _askTrainer(context, l10n, session),
                icon: const Icon(Icons.chat_bubble_outline),
                label: Text(l10n.askTrainer),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _askTrainer(
    BuildContext context,
    AppLocalizations l10n,
    LocalEvent session,
  ) {
    final level = readinessLevelLabel(l10n, readiness.level);
    final reasons = readiness.reasons
        .map((s) => readinessSignalLabel(l10n, s.kind))
        .join(', ');
    final name = session.name ?? session.type ?? l10n.activityFallback;
    ChatHandoff.instance.open(
      ChatTopic(
        title: l10n.readinessTopic,
        context: jsonEncode({
          'readiness': readiness.level.name,
          'reasons': [for (final s in readiness.reasons) s.kind.name],
          'session': {
            'name': name,
            'type': session.type,
            'date': session.date,
            'planned_minutes': session.plannedTime == null
                ? null
                : (session.plannedTime! / 60).round(),
            'planned_load': session.plannedLoad,
          },
          'note': 'Call get_readiness for the signal values and baselines.',
        }),
        draft: l10n.readinessChatDraft(level, reasons, name),
      ),
    );
    MainNavigation.instance.openTab(MainNavigation.chatTab);
  }
}

String _shortDate(BuildContext context, String? iso) {
  final date = iso == null ? null : DateTime.tryParse(iso);
  if (date == null) return '—';
  return DateFormat.MMMd(
    Localizations.localeOf(context).toString(),
  ).format(date);
}
