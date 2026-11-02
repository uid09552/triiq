import 'package:flutter/material.dart';

import '../../data/models/local_event.dart';
import '../../l10n/app_localizations.dart';
import '../../plan/plan_models.dart';
import '../../util/calendar_export.dart';
import '../activities/activity_icons.dart';
import '../today/train_now_screen.dart';

/// Opens Train Now on [e]'s day with [e] preselected, to swap it for a
/// proposal.
Future<void> openChangeTraining(BuildContext context, LocalEvent e) {
  final day = DateTime.tryParse(e.date);
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => TrainNowScreen(
        today: day == null ? null : () => day,
        initialEventId: e.id,
      ),
    ),
  );
}

/// One TriIQ plan session: name, duration and TSS, its steps, and whether
/// it was sent to Intervals.icu. Opened from the Plan screen's week grid
/// and from the Calendar's day detail.
Future<void> showPlanSessionSheet(
  BuildContext context, {
  required String name,
  required String sport,
  required DateTime date,
  required int minutes,
  required int load,
  required String description,
  required bool sent,
  VoidCallback? onChange,
}) {
  final l10n = AppLocalizations.of(context)!;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      final theme = Theme.of(context);
      final scheme = theme.colorScheme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(activityTypeIcon(sport), color: sportColor(sport, scheme)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(l10n.planSessionMinutes(minutes, load)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    sent ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
                    size: 16,
                    color: sent ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    sent ? l10n.planSessionSent : l10n.planSessionLocalOnly,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SelectableText(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (onChange != null) ...[
                FilledButton.tonalIcon(
                  key: const ValueKey('change-training'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onChange();
                  },
                  icon: const Icon(Icons.swap_horiz),
                  label: Text(l10n.changeTraining),
                ),
                const SizedBox(height: 8),
              ],
              OutlinedButton.icon(
                onPressed: () => launchGoogleCalendarEvent(
                  title: name,
                  description: description,
                  start: date,
                  duration: Duration(minutes: minutes),
                  allDay: true,
                ),
                icon: const Icon(Icons.event_outlined),
                label: Text(l10n.planOpenSingle),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// [showPlanSessionSheet] for a [PlanSession] from the plan itself.
Future<void> showPlanSessionSheetFor(BuildContext context, PlanSession s) =>
    showPlanSessionSheet(
      context,
      name: s.name,
      sport: s.sport,
      date: s.date,
      minutes: s.minutes,
      load: s.load,
      description: s.description,
      sent: s.status == PlanSessionStatus.created,
    );

/// [showPlanSessionSheet] for a plan session as the Calendar holds it.
Future<void> showPlanSessionSheetForEvent(BuildContext context, LocalEvent e) =>
    showPlanSessionSheet(
      context,
      name: e.name ?? '',
      sport: e.type ?? '',
      date: DateTime.tryParse(e.date) ?? DateTime.now(),
      minutes: (e.plannedTime ?? 0) ~/ 60,
      load: e.plannedLoad ?? 0,
      description: e.description ?? '',
      sent: e.planSessionSent,
      onChange: () => openChangeTraining(context, e),
    );
