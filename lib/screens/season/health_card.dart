import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../season/health_actions.dart';
import '../../season/illness_mode.dart';
import '../../season/season_service.dart';
import '../../util/dates.dart';
import '../events/events_screen.dart';

/// The illness / injury banner: what is logged, what it means for the
/// planned sessions, and one confirmed action to apply the proposed
/// changes. Nothing changes without the athlete pressing Apply.
class HealthCard extends StatefulWidget {
  const HealthCard({
    super.key,
    required this.status,
    required this.changes,
    required this.today,
    this.actions,
    this.onChanged,
    this.showLogButton = false,
  });

  final ({HealthIssue issue, HealthPhase phase})? status;
  final List<ReturnChange> changes;
  final DateTime today;
  final HealthActions? actions;
  final VoidCallback? onChanged;

  /// Offers "Log illness or injury" when nothing is logged.
  final bool showLogButton;

  @override
  State<HealthCard> createState() => _HealthCardState();
}

class _HealthCardState extends State<HealthCard> {
  late final _actions = widget.actions ?? HealthActions();
  bool _busy = false;

  Future<void> _apply() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.healthApply(widget.changes.length)),
        content: Text(l10n.healthApplyConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            key: const ValueKey('health-confirm'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    final result = await _actions.applyAll(widget.changes);
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.error == null
              ? l10n.healthApplyDone(result.done)
              : l10n.healthApplyFailed(result.done, '${result.error}'),
        ),
      ),
    );
    widget.onChanged?.call();
  }

  String _describe(AppLocalizations l10n, ReturnChange c) {
    final what = switch (c.action) {
      ReturnAction.rest => l10n.healthChangeRest,
      ReturnAction.easier => l10n.healthChangeEasier(
        c.minutes ?? 0,
        c.load ?? 0,
      ),
      ReturnAction.crossTrain => l10n.healthChangeCross(
        c.toSport ?? '',
        c.minutes ?? 0,
      ),
    };
    final reason = switch (c.reason) {
      ReturnReason.illness => l10n.healthReasonIllness,
      ReturnReason.injury => l10n.healthReasonInjury,
      ReturnReason.returnRamp => l10n.healthReasonReturn,
    };
    return '$what · $reason';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final status = widget.status;
    if (status == null) {
      if (!widget.showLogButton) return const SizedBox.shrink();
      return ListTile(
        key: const ValueKey('health-log'),
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.healing_outlined),
        title: Text(l10n.healthLogButton),
        subtitle: Text(l10n.healthLogHint),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const EventsScreen())),
      );
    }
    final issue = status.issue;
    final returning = status.phase == HealthPhase.returning;
    final title = returning
        ? l10n.healthReturningTitle
        : issue.kind == HealthKind.sick
        ? l10n.healthSickTitle
        : l10n.healthInjuredTitle;
    final subtitle = returning
        ? l10n.healthReturnSubtitle(
            DateFormat.MMMd(
              Localizations.localeOf(context).toString(),
            ).format(issue.backToNormal(widget.today)!),
          )
        : issue.kind == HealthKind.sick
        ? l10n.healthSickSubtitle(issue.daysUntil(widget.today))
        : l10n.healthInjuredSubtitle(issue.daysUntil(widget.today));
    final locale = Localizations.localeOf(context).toString();
    return Card(
      key: const ValueKey('health-card'),
      color: theme.colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.healing_outlined,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: theme.colorScheme.onTertiaryContainer),
            ),
            const SizedBox(height: 12),
            if (widget.changes.isEmpty)
              Text(
                l10n.healthNoChanges,
                style: TextStyle(color: theme.colorScheme.onTertiaryContainer),
              )
            else ...[
              for (final c in widget.changes.take(8))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '${DateFormat.MMMEd(locale).format(DateTime.parse(c.session.date))}'
                    ' · ${c.session.name ?? c.session.type ?? ''}'
                    ' → ${_describe(l10n, c)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
              if (widget.changes.length > 8)
                Text(
                  '+${widget.changes.length - 8}',
                  style: theme.textTheme.bodySmall,
                ),
              const SizedBox(height: 12),
              FilledButton(
                key: const ValueKey('health-apply'),
                onPressed: _busy ? null : _apply,
                child: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.healthApply(widget.changes.length)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A [HealthCard] that loads its own data — for Today.
class HealthBanner extends StatefulWidget {
  const HealthBanner({super.key, this.service});

  final SeasonService? service;

  @override
  State<HealthBanner> createState() => _HealthBannerState();
}

class _HealthBannerState extends State<HealthBanner> {
  SeasonSnapshot? _snapshot;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await (widget.service ?? SeasonService()).load(horizonDays: 60);
      if (mounted) setState(() => _snapshot = s);
    } catch (_) {
      // The banner is optional; Today works without it.
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _snapshot;
    if (s == null || s.health == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: HealthCard(
        status: s.health,
        changes: s.healthChanges,
        today: dateOnly(s.today),
        onChanged: _load,
      ),
    );
  }
}
