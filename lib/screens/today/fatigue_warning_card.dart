import 'dart:async';

import 'package:flutter/material.dart';

import '../../agent/chat_handoff.dart';
import '../../data/sync/auto_sync_service.dart';
import '../../evaluation/fatigue_warning.dart';
import '../../evaluation/fatigue_warning_service.dart';
import '../../l10n/app_localizations.dart';
import '../chat/ask_trainer.dart';

/// One line per firing signal, e.g. "HRV below your normal on 4 of the last
/// 5 days".
String fatigueSignalText(
  AppLocalizations l10n,
  FatigueSignal s,
) => switch (s.kind) {
  FatigueSignalKind.hrvLow => l10n.fatigueSignalHrv(s.badDays, s.dataDays),
  FatigueSignalKind.restingHrHigh => l10n.fatigueSignalRestingHr(
    s.badDays,
    s.dataDays,
  ),
  FatigueSignalKind.sleepShort => l10n.fatigueSignalSleep(
    s.badDays,
    s.dataDays,
  ),
  FatigueSignalKind.formLow => l10n.fatigueSignalForm(s.badDays, s.dataDays),
  FatigueSignalKind.rampHigh => l10n.fatigueSignalRamp(s.badDays, s.dataDays),
  FatigueSignalKind.subjective => l10n.fatigueSignalSubjective(
    s.badDays,
    s.dataDays,
  ),
};

/// The fatigue early warning on Today: loads itself, refreshes after each
/// sync, and shows nothing unless the multi-day trend says watch or
/// warning (and the athlete hasn't dismissed today's level).
class FatigueWarningBanner extends StatefulWidget {
  const FatigueWarningBanner({
    super.key,
    this.service,
    this.dismissals,
    this.sync,
    this.clock,
  });

  final FatigueWarningService? service;
  final FatigueWarningDismissals? dismissals;
  final Listenable? sync;
  final DateTime Function()? clock;

  @override
  State<FatigueWarningBanner> createState() => _FatigueWarningBannerState();
}

class _FatigueWarningBannerState extends State<FatigueWarningBanner> {
  late final _service = widget.service ?? FatigueWarningService();
  late final _dismissals = widget.dismissals ?? FatigueWarningDismissals();
  late final Listenable _sync = widget.sync ?? AutoSyncService.instance;
  DateTime _now() => (widget.clock ?? DateTime.now)();
  FatigueWarning? _warning;

  @override
  void initState() {
    super.initState();
    _sync.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    _sync.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final w = await _service.load();
      final hidden =
          w.level == FatigueLevel.none ||
          await _dismissals.isDismissed(_now(), w.level);
      if (mounted) setState(() => _warning = hidden ? null : w);
    } catch (_) {
      // Optional card: Today works without it.
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = _warning;
    if (w == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final warning = w.level == FatigueLevel.warning;
    final bg = warning ? scheme.errorContainer : scheme.tertiaryContainer;
    final fg = warning ? scheme.onErrorContainer : scheme.onTertiaryContainer;
    final reasons = [for (final s in w.firing) fatigueSignalText(l10n, s)];
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Card(
        key: const ValueKey('fatigue-card'),
        color: bg,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    warning
                        ? Icons.warning_amber_rounded
                        : Icons.trending_down_rounded,
                    color: fg,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      warning
                          ? l10n.fatigueWarningTitle
                          : l10n.fatigueWatchTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (final r in reasons)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('• $r', style: TextStyle(color: fg)),
                ),
              const SizedBox(height: 8),
              Text(
                warning ? l10n.fatigueAdviceWarning : l10n.fatigueAdviceWatch,
                style: TextStyle(color: fg),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilledButton(
                    key: const ValueKey('fatigue-ask'),
                    onPressed: () => askTrainer(
                      context,
                      ChatTopic(
                        title: warning
                            ? l10n.fatigueWarningTitle
                            : l10n.fatigueWatchTitle,
                        context:
                            'Fatigue early warning (${w.level.name}, last '
                            '${w.window} days): ${reasons.join('; ')}.',
                        draft: l10n.fatigueChatDraft(reasons.join('; ')),
                      ),
                    ),
                    child: Text(l10n.fatigueAsk),
                  ),
                  TextButton(
                    key: const ValueKey('fatigue-dismiss'),
                    onPressed: () async {
                      await _dismissals.dismiss(_now(), w.level);
                      if (mounted) setState(() => _warning = null);
                    },
                    child: Text(l10n.fatigueDismiss),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
