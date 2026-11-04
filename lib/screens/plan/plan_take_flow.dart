import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/intervals_session.dart';
import '../../data/sync/sync_settings.dart';
import '../../l10n/app_localizations.dart';
import '../../plan/plan_models.dart';
import '../../plan/plan_service.dart';
import '../../plan/plan_writer.dart';
import '../../widgets/main_navigation.dart';
import 'plan_preview_sheet.dart';

/// The one way a generated plan becomes the athlete's plan, shared by the
/// Plan screen and the chat's plan proposals: preview → **Take as plan**
/// (saved locally) → Calendar tab at the plan's first week → sent to
/// Intervals.icu in the background when that setting is on.
///
/// Returns the saved plan, or `null` when the athlete cancelled the preview.
/// [onTaking] runs once they confirmed, before saving (a caller's busy
/// indicator).
Future<TrainingPlan?> previewAndTakePlan(
  BuildContext context, {
  required PlanService service,
  required TrainingPlan draft,
  TrainingPlan? replacing,
  SyncSettings? settings,
  VoidCallback? onTaking,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await showModalBottomSheet<PlanPreviewResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => PlanPreviewSheet(plan: draft),
  );
  if (confirmed == null || !context.mounted) return null;

  onTaking?.call();
  final saved = await service.take(confirmed.plan, replacing: replacing);
  if (!context.mounted) return saved;
  final messenger = ScaffoldMessenger.of(context);
  Navigator.of(context).popUntil((route) => route.isFirst);
  MainNavigation.instance.openCalendar(saved.startDate);
  if (!(settings ?? SyncSettings.instance).sendPlanToIntervals) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.planTakenLocal)));
  } else if (!IntervalsSession.instance.isConnected) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.planTakenNotConnected)));
  } else {
    unawaited(sendPlanInBackground(service, saved, messenger, l10n));
  }
  return saved;
}

String planWriteReportMessage(AppLocalizations l10n, PlanWriteReport report) =>
    report.queued.isNotEmpty && report.allCreated
    ? l10n.planQueuedOffline(report.queued.length)
    : report.allCreated
    ? l10n.planCreatedAll(report.created.length)
    : l10n.planCreatedPartial(report.created.length, report.failed.length);

/// Sends [plan] to Intervals.icu after the screen that asked may already be
/// gone, reporting on the app-level [messenger]. A partial failure offers
/// Retry, which sends only what is still missing.
Future<void> sendPlanInBackground(
  PlanService service,
  TrainingPlan plan,
  ScaffoldMessengerState messenger,
  AppLocalizations l10n,
) async {
  try {
    final outcome = await service.send(plan);
    final report = outcome.report;
    messenger.showSnackBar(
      SnackBar(
        content: Text(planWriteReportMessage(l10n, report)),
        action: report.allCreated
            ? null
            : SnackBarAction(
                label: l10n.retryButton,
                onPressed: () =>
                    sendPlanInBackground(service, outcome.plan, messenger, l10n),
              ),
      ),
    );
  } catch (error) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.planGenerateFailed('$error')),
        action: SnackBarAction(
          label: l10n.retryButton,
          onPressed: () => sendPlanInBackground(service, plan, messenger, l10n),
        ),
      ),
    );
  }
}
