import 'package:flutter/material.dart';

import '../../evaluation/readiness.dart';
import '../../evaluation/readiness_service.dart';
import '../../l10n/app_localizations.dart';
import 'readiness_card.dart';
import 'readiness_format.dart';
import 'readiness_options.dart';
import 'readiness_screen.dart';

/// Tapping the readiness ring on Today: a sheet that explains the score in
/// plain lines — each signal with its rating and how it compares to usual
/// ("3-day median 54 bpm vs usual 48 ± 1") — instead of a new screen. The
/// full detail screen and the signal options are a button away.
Future<void> showReadinessExplainSheet(
  BuildContext context,
  ReadinessReport report,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => _ReadinessExplainSheet(report: report),
);

class _ReadinessExplainSheet extends StatelessWidget {
  const _ReadinessExplainSheet({required this.report});

  final ReadinessReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final r = report.readiness;
    final complete = r.dataState == ReadinessDataState.complete;
    final color = readinessColor(scheme, r.level);
    final score = complete ? readinessScore(r) : null;
    // Signals behind the status first, then the rest that count.
    final signals = [
      ...r.reasons,
      for (final s in r.active)
        if (!r.reasons.contains(s) &&
            !(s.kind == ReadinessSignalKind.device &&
                s.rating == SignalRating.missing))
          s,
    ];

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: ListView(
          key: const ValueKey('readiness-explain'),
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          children: [
            Text(
              score == null
                  ? readinessLevelLabel(l10n, r.level)
                  : '${readinessLevelLabel(l10n, r.level)} · $score / 100',
              style: theme.textTheme.titleLarge?.copyWith(
                color: complete ? color : scheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(switch (r.dataState) {
              ReadinessDataState.noData => l10n.readinessNoData,
              ReadinessDataState.waitingForToday => l10n.todayWaitingForWatch,
              ReadinessDataState.complete =>
                r.reasons.isEmpty
                    ? l10n.readinessAllOk
                    : l10n.readinessReasons(
                        r.reasons
                            .map((s) => readinessSignalLabel(l10n, s.kind))
                            .join(', '),
                      ),
            }, style: theme.textTheme.bodyMedium),
            if (r.dataState != ReadinessDataState.noData) ...[
              const SizedBox(height: 12),
              // Hold a pill to peek at its last 30 days.
              ReadinessSignalPills(report: report),
            ],
            const SizedBox(height: 12),
            for (final s in signals) _SignalLine(signal: s),
            const SizedBox(height: 8),
            Text(
              l10n.readinessExplainScore,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonal(
                  key: const ValueKey('readiness-explain-details'),
                  onPressed: () {
                    final navigator = Navigator.of(context);
                    navigator.pop();
                    navigator.push(
                      MaterialPageRoute(
                        builder: (_) => ReadinessScreen(report: report),
                      ),
                    );
                  },
                  child: Text(l10n.readinessExplainDetails),
                ),
                TextButton(
                  onPressed: () {
                    final outer = Navigator.of(context);
                    final parent = outer.context;
                    outer.pop();
                    showReadinessOptions(parent);
                  },
                  child: Text(l10n.readinessOptionsTitle),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SignalLine extends StatelessWidget {
  const _SignalLine({required this.signal});

  final ReadinessSignal signal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (rating, color) = readinessRatingStyle(
      l10n,
      scheme,
      signal.rating,
      signal: signal,
    );
    final range = readinessRangeText(l10n, signal);
    return Padding(
      key: ValueKey('explain-${signal.kind.name}'),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              switch (signal.rating) {
                SignalRating.ok => Icons.check_circle,
                SignalRating.caution => Icons.warning_amber_rounded,
                SignalRating.backOff => Icons.error,
                _ => Icons.remove_circle_outline,
              },
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${readinessSignalLabel(l10n, signal.kind)} · '
                  '${readinessValueText(signal)} · $rating',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (range != null)
                  Text(
                    range,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
