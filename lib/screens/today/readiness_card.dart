import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../agent/chat_handoff.dart';
import '../../data/models/local_event.dart';
import '../../evaluation/readiness.dart';
import '../../evaluation/readiness_service.dart';
import '../../evaluation/session_evaluator.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/main_navigation.dart';
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

/// Today's readiness in one full-width row above the load tiles: the
/// status and what drives it, or why there is no status yet. Opens the
/// detail screen on tap.
class ReadinessCard extends StatelessWidget {
  const ReadinessCard({super.key, required this.report});

  final ReadinessReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final r = report.readiness;
    final color = readinessColor(theme.colorScheme, r.level);

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

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ReadinessScreen(report: report)),
        ),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(Icons.favorite_outline, color: color),
        ),
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: '${l10n.readinessTitle}: '),
              TextSpan(
                text: readinessLevelLabel(l10n, r.level),
                style: TextStyle(color: color, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
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
