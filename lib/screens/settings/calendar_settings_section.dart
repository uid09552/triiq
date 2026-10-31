import 'package:flutter/material.dart';

import '../../data/intervals_session.dart';
import '../../data/sync/sync_service.dart';
import '../../data/sync/sync_settings.dart';
import '../../l10n/app_localizations.dart';
import '../../plan/plan_service.dart';

/// Settings → Calendar: whether TriIQ's plan goes to Intervals.icu, and
/// whether Intervals.icu's planned events come into TriIQ. Independent.
class CalendarSettingsSection extends StatelessWidget {
  CalendarSettingsSection({
    super.key,
    SyncSettings? settings,
    PlanService? planService,
    Future<void> Function(DateTime oldest, DateTime newest)? syncRange,
    IntervalsSession? session,
  }) : settings = settings ?? SyncSettings.instance,
       _planService = planService,
       _syncRange = syncRange,
       _session = session ?? IntervalsSession.instance;

  final SyncSettings settings;
  final PlanService? _planService;
  final Future<void> Function(DateTime, DateTime)? _syncRange;
  final IntervalsSession _session;

  PlanService get _plans => _planService ?? PlanService();

  Future<void> _setSend(BuildContext context, bool on) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    await settings.setSendPlanToIntervals(on);
    if (!on || !_session.isConnected || !context.mounted) return;

    final unsent = await _plans.unsentUpcoming();
    final plan = unsent.plan;
    if (plan == null || unsent.count == 0 || !context.mounted) return;
    final send = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.calendarSendNowTitle),
        content: Text(l10n.calendarSendNowBody(unsent.count)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.calendarSendLater),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.calendarSendNow(unsent.count)),
          ),
        ],
      ),
    );
    if (send != true) return;
    try {
      final outcome = await _plans.send(plan, from: DateTime.now());
      final report = outcome.report;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            report.allCreated
                ? l10n.planCreatedAll(report.created.length)
                : l10n.planCreatedPartial(
                    report.created.length,
                    report.failed.length,
                  ),
          ),
        ),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.planGenerateFailed('$error'))),
      );
    }
  }

  Future<void> _setCopy(BuildContext context, bool on) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    await settings.setCopyIntervalsEvents(on);
    if (!on || !_session.isConnected) return;
    // Bring the current month's events back in.
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, 1);
    final last = DateTime(now.year, now.month + 1, 0);
    try {
      await (_syncRange ?? _defaultSync)(first, last);
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.syncFailedMessage('$error'))));
    }
  }

  static Future<void> _defaultSync(DateTime oldest, DateTime newest) =>
      SyncService().syncRange(oldest, newest);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => Column(
        children: [
          SwitchListTile(
            key: const ValueKey('calendar-send-plan'),
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.calendarSendPlan),
            subtitle: Text(l10n.calendarSendPlanHelp),
            value: settings.sendPlanToIntervals,
            onChanged: (on) => _setSend(context, on),
          ),
          SwitchListTile(
            key: const ValueKey('calendar-copy-events'),
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.calendarCopyEvents),
            subtitle: Text(l10n.calendarCopyEventsHelp),
            value: settings.copyIntervalsEvents,
            onChanged: (on) => _setCopy(context, on),
          ),
        ],
      ),
    );
  }
}
