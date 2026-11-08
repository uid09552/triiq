import 'dart:async';

import 'package:flutter/material.dart';

import '../data/intervals_session.dart';
import '../data/pending_writes.dart';
import '../data/repositories/sync_state_repository.dart';
import '../data/sync/auto_sync_service.dart';
import '../l10n/app_localizations.dart';
import '../screens/sync/sync_screen.dart';

/// How long ago a sync was, in the units a glance wants: "just now", minutes,
/// hours, days.
enum SyncAgeUnit { now, minutes, hours, days }

({SyncAgeUnit unit, int value}) syncAge(DateTime last, DateTime now) {
  final d = now.difference(last);
  if (d.inMinutes < 1) return (unit: SyncAgeUnit.now, value: 0);
  if (d.inMinutes < 60) return (unit: SyncAgeUnit.minutes, value: d.inMinutes);
  if (d.inHours < 24) return (unit: SyncAgeUnit.hours, value: d.inHours);
  return (unit: SyncAgeUnit.days, value: d.inDays);
}

/// What the chip says and how worried it looks.
enum SyncHealth { ok, stale, attention, offline }

class SyncStatus {
  const SyncStatus({required this.health, required this.text, this.icon});

  final SyncHealth health;
  final String text;
  final IconData? icon;
}

/// Decides the status line from the facts: connection, queue, last sync.
/// Failed writes outrank everything (they need the athlete), then writes
/// waiting to go out, then "not connected", then how fresh the data is — over
/// a day old counts as stale.
SyncStatus syncStatusFor(
  AppLocalizations l10n, {
  required bool connected,
  required int pending,
  required int failed,
  required DateTime? lastSyncedAt,
  required DateTime now,
}) {
  if (failed > 0) {
    return SyncStatus(
      health: SyncHealth.attention,
      text: l10n.syncStatusFailed(failed),
      icon: Icons.error_outline,
    );
  }
  if (pending > 0) {
    return SyncStatus(
      health: SyncHealth.attention,
      text: l10n.syncStatusWaiting(pending),
      icon: Icons.cloud_upload_outlined,
    );
  }
  if (!connected) {
    return SyncStatus(
      health: SyncHealth.offline,
      text: l10n.syncStatusNotConnected,
      icon: Icons.cloud_off_outlined,
    );
  }
  if (lastSyncedAt == null) {
    return SyncStatus(
      health: SyncHealth.stale,
      text: l10n.syncStatusNever,
      icon: Icons.sync_problem_outlined,
    );
  }
  final age = syncAge(lastSyncedAt, now);
  final text = switch (age.unit) {
    SyncAgeUnit.now => l10n.syncStatusNow,
    SyncAgeUnit.minutes => l10n.syncStatusMinutes(age.value),
    SyncAgeUnit.hours => l10n.syncStatusHours(age.value),
    SyncAgeUnit.days => l10n.syncStatusDays(age.value),
  };
  return SyncStatus(
    health: age.unit == SyncAgeUnit.days ? SyncHealth.stale : SyncHealth.ok,
    text: text,
    icon: age.unit == SyncAgeUnit.days
        ? Icons.sync_problem_outlined
        : Icons.sync,
  );
}

/// A small "Synced 5 min ago" chip for Today and Statistics: the last sync,
/// writes waiting or failed, or that nothing is connected. Tapping it opens
/// the Sync screen. Updates when a sync lands or the queue changes, and once
/// a minute so "5 min ago" doesn't go stale on screen.
class SyncStatusChip extends StatefulWidget {
  SyncStatusChip({
    super.key,
    SyncStateRepository? state,
    PendingWritesService? queue,
    IntervalsSession? session,
    this.now,
    this.onTap,
  }) : state = state ?? SyncStateRepository(),
       queue = queue ?? PendingWritesService.instance,
       session = session ?? IntervalsSession.instance;

  final SyncStateRepository state;
  final PendingWritesService queue;
  final IntervalsSession session;

  /// The clock, for tests.
  final DateTime Function()? now;

  /// Defaults to opening the Sync screen.
  final VoidCallback? onTap;

  @override
  State<SyncStatusChip> createState() => _SyncStatusChipState();
}

class _SyncStatusChipState extends State<SyncStatusChip> {
  DateTime? _lastSyncedAt;
  Timer? _tick;

  DateTime get _now => (widget.now ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    AutoSyncService.instance.addListener(_refresh);
    widget.queue.addListener(_rebuild);
    widget.session.addListener(_rebuild);
    _tick = Timer.periodic(const Duration(minutes: 1), (_) => _rebuild());
    _refresh();
  }

  @override
  void dispose() {
    _tick?.cancel();
    AutoSyncService.instance.removeListener(_refresh);
    widget.queue.removeListener(_rebuild);
    widget.session.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  Future<void> _refresh() async {
    try {
      final a = await widget.state.get('activities');
      final w = await widget.state.get('wellness');
      final times = [?a?.lastSyncedAt, ?w?.lastSyncedAt]
        ..sort((x, y) => y.compareTo(x));
      if (mounted) setState(() => _lastSyncedAt = times.firstOrNull);
    } catch (_) {
      // The chip is a hint; a cache that can't be read just shows no time.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final status = syncStatusFor(
      l10n,
      connected: widget.session.isConnected,
      pending: widget.queue.pending,
      failed: widget.queue.failed,
      lastSyncedAt: _lastSyncedAt,
      now: _now,
    );
    final color = switch (status.health) {
      SyncHealth.ok => scheme.onSurfaceVariant,
      SyncHealth.stale => Colors.amber.shade800,
      SyncHealth.attention => scheme.error,
      SyncHealth.offline => scheme.onSurfaceVariant,
    };
    return Tooltip(
      message: l10n.syncStatusTooltip,
      child: InkWell(
        key: const ValueKey('sync-status'),
        borderRadius: BorderRadius.circular(12),
        onTap:
            widget.onTap ??
            () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => const SyncScreen())),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(status.icon, size: 14, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  status.text,
                  key: const ValueKey('sync-status-text'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
