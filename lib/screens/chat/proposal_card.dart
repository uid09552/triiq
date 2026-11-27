import 'package:flutter/material.dart' hide Adaptation;
import 'package:intl/intl.dart';

import '../../agent/plan_proposals.dart';
import '../../l10n/app_localizations.dart';
import '../../plan/load_curve_controller.dart';
import '../../plan/plan_actions.dart';
import '../../plan/plan_adaptation.dart';
import '../../plan/plan_models.dart';
import '../../plan/plan_service.dart';
import '../../plan/proposal_safety.dart';
import '../../widgets/charts/load_curve_editor.dart';
import '../activities/activity_icons.dart';
import '../today/readiness_card.dart';
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
    // A missed session: ask why first, and never move it forward when the
    // athlete was sick or injured — that is rest, not catching up.
    if (proposal case SessionChangeProposal(missed: true, :final to)) {
      final reason = await _askMissedReason(context);
      if (reason == null || !context.mounted) return;
      proposal.reason = reason.name;
      if (to != null &&
          (reason == MissedReason.sick || reason == MissedReason.injured)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.missedRestInstead)));
        return;
      }
    }
    if (!context.mounted) return;
    await proposals.apply(proposal.id, (p) async {
      try {
        switch (p) {
          case CurveProposal(:final goal):
            await _act.applyGoal(goal);
            return true;
          case SessionChangeProposal(
            :final sessionId,
            :final to,
            :final missed,
          ):
            if (to == null) {
              await _act.removeSession(sessionId, missed: missed);
            } else {
              await _act.moveSession(sessionId, to, missed: missed);
            }
            return true;
          case SessionSwapProposal(:final first, :final second):
            await _act.swapSessions(first.id!, second.id!);
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

  /// Takes an applied change back — only while nothing else has changed the
  /// plan since, so it can never undo more than this one proposal.
  Future<MissedReason?> _askMissedReason(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return showModalBottomSheet<MissedReason>(
      context: context,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.missedWhyTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.missedWhyBody,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final r in MissedReason.values)
                  ActionChip(
                    key: ValueKey('missed-reason-${r.name}'),
                    label: Text(missedReasonLabel(l10n, r)),
                    onPressed: () => Navigator.pop(context, r),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _undo(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final result = await revertProposal(
      context,
      proposals,
      proposal,
      actions: _act,
    );
    messenger.showSnackBar(
      SnackBar(
        content: Text(switch (result) {
          UndoResult.done => l10n.proposalUndoDone,
          UndoResult.stale => l10n.proposalUndoStale,
          UndoResult.failed => l10n.proposalUndoFailed(proposal.error ?? ''),
          UndoResult.unavailable => l10n.proposalUndoUnavailable,
        }),
      ),
    );
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
      SessionChangeProposal(isRemoval: true, adaptation: _?) => (
        Icons.event_busy_outlined,
        l10n.proposalLetGoTitle,
      ),
      SessionChangeProposal(isRemoval: true) => (
        Icons.event_busy_outlined,
        l10n.proposalRemoveTitle,
      ),
      SessionChangeProposal(missed: true) => (
        Icons.replay,
        l10n.proposalCatchUpTitle,
      ),
      SessionChangeProposal() => (Icons.swap_horiz, l10n.proposalMoveTitle),
      SessionSwapProposal() => (Icons.swap_vert, l10n.proposalSwapTitle),
    };
    final reason = _reason(l10n, day, p.adaptation);

    Widget? picture;
    switch (p) {
      case CurveProposal(:final limits, :final weeks, :final goal):
        picture = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LoadCurveEditor(
              controller: LoadCurveController(
                limits: limits,
                weeks: weeks,
                factors: goal.loadFactors,
              ),
              readOnly: true,
              highlight: p.changedWeeks,
              height: 170,
            ),
            if (p.clamps.isNotEmpty) _ClampNote(clamps: p.clamps),
            if (p.previousGoal != null) _CurveDiff(proposal: p),
          ],
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
      case SessionChangeProposal(
        :final sport,
        :final name,
        :final from,
        :final to,
      ):
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
      case SessionSwapProposal(:final first, :final second):
        Widget row(PlanSession a, DateTime to) => Row(
          children: [
            Icon(activityTypeIcon(a.sport), color: sportColor(a.sport, scheme)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${a.name} · ${day.format(a.date)} → ${day.format(to)}',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        );
        picture = Column(
          children: [
            row(first, second.date),
            const SizedBox(height: 4),
            row(second, first.date),
          ],
        );
    }

    final status = switch (state) {
      ProposalState.applied when p.undone => (
        Icons.undo,
        scheme.onSurfaceVariant,
        l10n.proposalUndone,
      ),
      ProposalState.applied => (
        Icons.check_circle,
        scheme.primary,
        l10n.proposalApplied,
      ),
      ProposalState.dismissed => (
        Icons.cancel_outlined,
        scheme.onSurfaceVariant,
        l10n.proposalDismissed,
      ),
      ProposalState.stale => (Icons.history, scheme.error, l10n.proposalStale),
      ProposalState.failed => (
        Icons.error_outline,
        scheme.error,
        l10n.proposalFailed(p.error ?? ''),
      ),
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
            Text(reason ?? p.summary, style: theme.textTheme.bodySmall),
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
            if (p.canUndo)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  key: ValueKey('proposal-undo-${p.id}'),
                  onPressed: () => _undo(context),
                  icon: const Icon(Icons.undo, size: 18),
                  label: Text(l10n.proposalUndo),
                ),
              ),
            if (p.canApply)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PopupMenuButton<DismissReason>(
                    key: ValueKey('proposal-dismiss-reason-${p.id}'),
                    tooltip: l10n.dismissWithReason,
                    icon: const Icon(Icons.more_horiz),
                    onSelected: (r) => proposals.dismiss(p.id, reason: r),
                    itemBuilder: (context) => [
                      for (final r in DismissReason.values)
                        PopupMenuItem(
                          value: r,
                          child: Text(dismissReasonLabel(l10n, r)),
                        ),
                    ],
                  ),
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

/// Says a week was limited to what the plan's weekly ramp allows, so the
/// card never looks like it does what was asked when it does not.
class _ClampNote extends StatelessWidget {
  const _ClampNote({required this.clamps});

  final List<RampClamp> clamps;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      key: const ValueKey('proposal-clamped'),
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            size: 18,
            color: theme.colorScheme.onTertiaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              [
                l10n.proposalClampedTitle,
                for (final k in clamps)
                  (k.raised
                      ? l10n.proposalClampedHigh
                      : l10n.proposalClampedLow)(k.week, k.asked, k.limited),
              ].join('\n'),
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// What a load-graph change does, week by week: each changed week's target
/// before and after, and the total. Both come from the same load-curve
/// maths the plan uses.
class _CurveDiff extends StatelessWidget {
  const _CurveDiff({required this.proposal});

  final CurveProposal proposal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    List<double> targets(Goal g) => LoadCurveController(
      limits: proposal.limits,
      weeks: proposal.weeks,
      factors: g.loadFactors,
    ).targets;
    final before = targets(proposal.previousGoal!);
    final after = targets(proposal.goal);
    final weeks = proposal.changedWeeks.toList()..sort();
    if (weeks.isEmpty) return const SizedBox.shrink();
    var total = 0.0;
    for (final w in weeks) {
      total += after[w] - before[w];
    }
    String signed(double v) => '${v >= 0 ? '+' : '−'}${v.abs().round()}';
    const shown = 4;
    return Padding(
      key: const ValueKey('proposal-diff'),
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final w in weeks.take(shown))
            Text(
              l10n.proposalDiffWeek(
                w + 1,
                before[w].round(),
                after[w].round(),
                signed(after[w] - before[w]),
              ),
              style: theme.textTheme.bodySmall,
            ),
          if (weeks.length > shown)
            Text(
              l10n.proposalDiffMore(weeks.length - shown),
              style: theme.textTheme.bodySmall,
            ),
          Text(
            l10n.proposalDiffTotal(signed(total), weeks.length),
            key: const ValueKey('proposal-diff-total'),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Why an adaptation proposal exists, in the athlete's language; `null`
/// for the agent's own proposals, which carry their summary instead.
String? _reason(AppLocalizations l10n, DateFormat day, Adaptation? a) =>
    switch (a) {
      null => null,
      MissedSession(:final session) => l10n.adaptMissedReason(
        day.format(session.date),
      ),
      WeekLoadOffTarget() => [
        (a.under ? l10n.adaptLoadUnderReason : l10n.adaptLoadOverReason)(
          a.endedWeek.index + 1,
          a.actual,
          a.target.round(),
          a.nextWeek.targetLoad.round(),
          a.newLoad.round(),
        ),
        if (a.floorLimited) l10n.adaptLoadFloor(a.uncappedLoad.round()),
        l10n.adaptLoadRegenerate,
      ].join(' '),
      ReadinessConflict(:final level) => l10n.adaptReadinessReason(
        readinessLevelLabel(l10n, level),
      ),
    };

/// An error whose text is already meant for the athlete.
class _Readable implements Exception {
  const _Readable(this.message);

  final String message;

  @override
  String toString() => message;
}

String missedReasonLabel(AppLocalizations l, MissedReason r) => switch (r) {
  MissedReason.sick => l.missedSick,
  MissedReason.injured => l.missedInjured,
  MissedReason.tired => l.missedTired,
  MissedReason.busy => l.missedBusy,
  MissedReason.travelling => l.missedTravelling,
  MissedReason.skipped => l.missedSkipped,
};

String dismissReasonLabel(AppLocalizations l, DismissReason r) => switch (r) {
  DismissReason.notNow => l.dismissNotNow,
  DismissReason.tooHard => l.dismissTooHard,
  DismissReason.tooEasy => l.dismissTooEasy,
  DismissReason.lifeConflict => l.dismissLife,
  DismissReason.other => l.dismissOther,
};

/// Takes back an applied [proposal] (a moved session, a swap, a load graph
/// with its previous goal) through [proposals], which refuses when the
/// plan changed since. Shared by the card's Undo and Plan → Changes.
Future<UndoResult> revertProposal(
  BuildContext context,
  PlanProposals proposals,
  PlanProposal proposal, {
  PlanActions? actions,
}) {
  final l10n = AppLocalizations.of(context)!;
  final act = actions ?? PlanActions();
  return proposals.undo(proposal.id, (p) async {
    try {
      switch (p) {
        case CurveProposal(:final previousGoal?):
          await act.applyGoal(previousGoal);
        case SessionChangeProposal(
          :final sessionId,
          :final from,
          :final missed,
          to: != null,
        ):
          await act.moveSession(sessionId, from, missed: missed);
        case SessionSwapProposal(:final first, :final second):
          await act.swapSessions(first.id!, second.id!);
        case _:
          throw _Readable(l10n.proposalUndoUnavailable);
      }
    } on ReplaceRefusedException catch (e) {
      throw _Readable(refusalLabel(l10n, e));
    }
  });
}
