import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../agent/plan_proposals.dart';
import '../../l10n/app_localizations.dart';
import '../../plan/plan_actions.dart';
import '../chat/proposal_card.dart';

/// Plan → Changes: every change applied from a suggestion (Today, Chat or
/// Plan), newest first, each with Revert while nothing else changed the
/// plan since. Kept on the device; survives a cleared chat.
class AppliedChangesScreen extends StatelessWidget {
  const AppliedChangesScreen({
    super.key,
    this.log,
    this.proposals,
    this.actions,
  });

  final AppliedChangesLog? log;
  final PlanProposals? proposals;
  final PlanActions? actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final log = this.log ?? AppliedChangesLog.instance;
    final locale = Localizations.localeOf(context).toString();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.changesTitle)),
      body: ListenableBuilder(
        listenable: log,
        builder: (context, _) {
          final entries = log.entries;
          if (entries.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  l10n.changesEmpty,
                  key: const ValueKey('changes-empty'),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: entries.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, i) {
              final e = entries[i];
              return ListTile(
                key: ValueKey('change-$i'),
                title: Text(e.summary),
                subtitle: Text(
                  DateFormat.yMMMd(locale).add_Hm().format(e.at) +
                      (e.undone ? ' · ${l10n.changesReverted}' : ''),
                ),
                trailing: e.revertible
                    ? TextButton(
                        key: ValueKey('change-revert-$i'),
                        onPressed: () => _revert(context, e),
                        child: Text(l10n.changesRevert),
                      )
                    : null,
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _revert(BuildContext context, AppliedChange e) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final registry = proposals ?? PlanProposals.instance;
    final p = registry.restoreApplied(e.proposal);
    if (p == null) return;
    final result = await revertProposal(context, registry, p, actions: actions);
    messenger.showSnackBar(
      SnackBar(
        content: Text(switch (result) {
          UndoResult.done => l10n.changesRevertDone,
          UndoResult.stale => l10n.changesRevertStale,
          UndoResult.failed => l10n.changesRevertFailed(p.error ?? ''),
          UndoResult.unavailable => l10n.proposalUndoUnavailable,
        }),
      ),
    );
  }
}
