import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../agent/plan_proposals.dart';
import '../../l10n/app_localizations.dart';
import '../../plan/load_curve_controller.dart';
import '../../plan/plan_actions.dart';
import '../../plan/plan_service.dart';
import '../../widgets/charts/load_curve_editor.dart';
import '../activities/activity_icons.dart';
import '../plan/plan_labels.dart';
import '../plan/plan_take_flow.dart';

/// One change the agent proposed, under the reply that proposed it:
/// what it would change, a picture of it, and Apply / Dismiss. Nothing
/// changes until Apply; a proposal made before the goal or plan changed
/// refuses to apply and says so.
class ProposalCard extends StatelessWidget {
  ProposalCard({
    super.key,
    required this.proposal,
    PlanProposals? proposals,
    PlanActions? actions,
    PlanService? planService,
  }) : proposals = proposals ?? PlanProposals.instance,
       _actions = actions,
       _planService = planService;

  final PlanProposal proposal;
  final PlanProposals proposals;
  final PlanActions? _actions;
  final PlanService? _planService;

  PlanActions get _act => _actions ?? PlanActions();
  PlanService get _service => _planService ?? PlanService();

  Future<void> _apply(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    await proposals.apply(proposal.id, (p) async {
      try {
        switch (p) {
          case CurveProposal(:final goal):
            await _act.applyGoal(goal);
            return true;
          case SessionChangeProposal(:final sessionId, :final to):
            if (to == null) {
              await _act.removeSession(sessionId);
            } else {
              await _act.moveSession(sessionId, to);
            }
            return true;
          case PlanDraftProposal(:final goal):
            final result = await _service.generate(goal);
            final failure = result.failure;
            if (failure != null) throw _Readable(failure.message);
            if (!context.mounted) return false;
            final current = await _service.plans.getCurrent();
            if (!context.mounted) return false;
            final taken = await previewAndTakePlan(
              context,
              service: _service,
              draft: result.plan!,
              replacing: current,
            );
            return taken != null;
        }
      } on ReplaceRefusedException catch (e) {
        throw _Readable(refusalLabel(l10n, e));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: proposals,
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final p = proposal;
    final state = p.state;
    final locale = Localizations.localeOf(context).toString();
    final day = DateFormat.MMMEd(locale);

    final (IconData icon, String title) = switch (p) {
      CurveProposal() => (Icons.show_chart, l10n.proposalCurveTitle),
      PlanDraftProposal() => (Icons.calendar_month, l10n.proposalPlanTitle),
      SessionChangeProposal(isRemoval: true) => (
        Icons.event_busy_outlined,
        l10n.proposalRemoveTitle,
      ),
      SessionChangeProposal() => (Icons.swap_horiz, l10n.proposalMoveTitle),
    };

    Widget? picture;
    switch (p) {
      case CurveProposal(:final limits, :final weeks, :final goal):
        picture = LoadCurveEditor(
          controller: LoadCurveController(
            limits: limits,
            weeks: weeks,
            factors: goal.loadFactors,
          ),
          readOnly: true,
          highlight: p.changedWeeks,
          height: 170,
        );
      case PlanDraftProposal(:final limits, :final weeks, :final goal):
        if (limits != null && weeks != null) {
          picture = LoadCurveEditor(
            controller: LoadCurveController(
              limits: limits,
              weeks: weeks,
              factors: goal.loadFactors,
            ),
            readOnly: true,
            height: 170,
          );
        }
      case SessionChangeProposal(:final sport, :final name, :final from, :final to):
        picture = Row(
          children: [
            Icon(activityTypeIcon(sport), color: sportColor(sport, scheme)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                to == null
                    ? '$name · ${day.format(from)}'
                    : '$name · ${day.format(from)} → ${day.format(to)}',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        );
    }

    final status = switch (state) {
      ProposalState.applied => (Icons.check_circle, scheme.primary, l10n.proposalApplied),
      ProposalState.dismissed => (Icons.cancel_outlined, scheme.onSurfaceVariant, l10n.proposalDismissed),
      ProposalState.stale => (Icons.history, scheme.error, l10n.proposalStale),
      ProposalState.failed => (Icons.error_outline, scheme.error, l10n.proposalFailed(p.error ?? '')),
      ProposalState.applying => null,
      ProposalState.pending => null,
    };

    return Card(
      key: ValueKey('proposal-${p.id}'),
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(p.summary, style: theme.textTheme.bodySmall),
            if (picture != null) ...[const SizedBox(height: 8), picture],
            if (p is PlanDraftProposal && p.canApply) ...[
              const SizedBox(height: 4),
              Text(
                l10n.proposalPlanHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            if (status != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(status.$1, size: 16, color: status.$2),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      status.$3,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: status.$2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (state == ProposalState.applying)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(),
              ),
            if (p.canApply)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => proposals.dismiss(p.id),
                    child: Text(l10n.proposalDismiss),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => _apply(context),
                    child: Text(
                      state == ProposalState.failed
                          ? l10n.retryButton
                          : l10n.proposalApply,
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

/// An error whose text is already meant for the athlete.
class _Readable implements Exception {
  const _Readable(this.message);

  final String message;

  @override
  String toString() => message;
}
