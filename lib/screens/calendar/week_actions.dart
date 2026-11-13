import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../agent/chat_handoff.dart';
import '../../l10n/app_localizations.dart';
import '../../util/dates.dart';
import '../chat/ask_trainer.dart';
import '../statistics/weekly_review_screen.dart';
import 'calendar_data.dart';
import 'calendar_level.dart';

/// Long-press on a week number (or the week view's ⋯ button): open the
/// week, its weekly review (weeks that have started), or ask the trainer
/// about it.
///
/// [today], [openReview] and [onAskTrainer] are test seams.
Future<void> showWeekActions(
  BuildContext context,
  DateTime monday, {
  VoidCallback? onOpenWeek,
  PeriodSummary? summary,
  DateTime Function()? today,
  void Function(BuildContext context, DateTime monday)? openReview,
  void Function(BuildContext context, ChatTopic topic)? onAskTrainer,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final locale = Localizations.localeOf(context).toString();
  final start = dateOnly(monday);
  final now = dateOnly((today ?? DateTime.now)());
  final started = !start.isAfter(now);
  final week = isoWeekNumber(start);
  final end = DateTime(start.year, start.month, start.day + 6);
  final range =
      '${DateFormat.MMMd(locale).format(start)} – '
      '${DateFormat.MMMd(locale).format(end)}';

  final choice = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                '${l10n.calBreadcrumbWeek(week)} · $range',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (onOpenWeek != null)
              ListTile(
                key: const ValueKey('week-open'),
                leading: const Icon(Icons.calendar_view_week),
                title: Text(l10n.calWeekOpen),
                onTap: () => Navigator.of(context).pop('open'),
              ),
            if (started)
              ListTile(
                key: const ValueKey('week-review'),
                leading: const Icon(Icons.assignment_outlined),
                title: Text(l10n.weeklyReviewTitle),
                onTap: () => Navigator.of(context).pop('review'),
              ),
            ListTile(
              key: const ValueKey('week-ask-trainer'),
              leading: const Icon(Icons.forum_outlined),
              title: Text(l10n.calWeekAskTrainer),
              onTap: () => Navigator.of(context).pop('ask'),
            ),
          ],
        ),
      ),
    ),
  );
  if (choice == null || !context.mounted) return;
  switch (choice) {
    case 'open':
      onOpenWeek?.call();
    case 'review':
      if (openReview != null) {
        openReview(context, start);
      } else {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => WeeklyReviewScreen(initialWeek: start),
          ),
        );
      }
    case 'ask':
      final s = summary;
      final facts = s == null
          ? ''
          : '\nPlanned ${s.plannedTss} TSS, ${s.plannedCount} sessions, '
                '${(s.plannedMinutes / 60).toStringAsFixed(1)} h; done '
                '${s.doneTss} TSS, ${s.doneCount} sessions, '
                '${(s.doneMinutes / 60).toStringAsFixed(1)} h.';
      (onAskTrainer ?? askTrainer)(
        context,
        ChatTopic(
          title: '${l10n.calBreadcrumbWeek(week)} · $range',
          context: 'Calendar week ${isoDate(start)} to ${isoDate(end)}.$facts',
          draft: l10n.calWeekAskDraft(range),
        ),
      );
  }
}
