import 'package:flutter/material.dart';

import '../../data/intervals_session.dart';
import '../../data/repositories/sync_state_repository.dart';
import '../../data/sync/sync_scope.dart';
import '../../data/sync/sync_service.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/pending_changes_card.dart';
import '../../notifications/notification_service.dart';
import '../../notifications/notification_settings.dart';
import '../../widgets/section_card.dart';

/// Lets the user pull a range of Intervals.icu history into the local
/// SQLite cache: today (usually automatic), this month, this year, or a
/// full initial sync of everything.
class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  final _session = IntervalsSession.instance;
  final _syncService = SyncService();
  final _syncStateRepository = SyncStateRepository();

  SyncScope? _running;
  String? _lastMessage;
  ({String oldest, String newest, DateTime lastSyncedAt})? _activitiesState;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final state = await _syncStateRepository.get('activities');
    if (!mounted) return;
    setState(() => _activitiesState = state);
  }

  Future<void> _run(SyncScope scope) async {
    setState(() {
      _running = scope;
      _lastMessage = null;
    });
    final l10n = AppLocalizations.of(context)!;
    try {
      final result = await _syncService.syncScope(scope);
      if (!mounted) return;
      setState(() {
        _running = null;
        _lastMessage = l10n.syncedMessage(
          result.activitiesCount,
          result.wellnessCount,
        );
      });
      await _loadState();
      if (NotificationSettings.instance.enabled) {
        await NotificationService.instance.showSyncComplete(
          activities: result.activitiesCount,
          wellness: result.wellnessCount,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _running = null;
        _lastMessage = l10n.syncFailedMessage(e.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final connected = _session.isConnected;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleSync)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PendingChangesCard(),
          if (!connected)
            SectionCard(
              icon: Icons.link_off,
              title: l10n.syncNotConnectedTitle,
              child: Text(l10n.syncNotConnectedBody),
            ),
          if (connected && _activitiesState != null)
            SectionCard(
              icon: Icons.history,
              title: l10n.localCacheTitle,
              child: Text(
                l10n.localCacheBody(
                  _activitiesState!.oldest,
                  _activitiesState!.newest,
                  _activitiesState!.lastSyncedAt.toString(),
                ),
              ),
            ),
          const SizedBox(height: 16),
          for (final scope in SyncScope.values) ...[
            _SyncTile(
              scope: scope,
              running: _running == scope,
              enabled: connected && _running == null,
              onTap: () => _run(scope),
            ),
            const SizedBox(height: 10),
          ],
          if (_lastMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _lastMessage!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _SyncTile extends StatelessWidget {
  const _SyncTile({
    required this.scope,
    required this.running,
    required this.enabled,
    required this.onTap,
  });

  final SyncScope scope;
  final bool running;
  final bool enabled;
  final VoidCallback onTap;

  static const _icons = {
    SyncScope.today: Icons.today_outlined,
    SyncScope.month: Icons.calendar_view_month,
    SyncScope.year: Icons.calendar_today_outlined,
    SyncScope.all: Icons.cloud_sync_outlined,
  };

  static String _label(AppLocalizations l10n, SyncScope scope) =>
      switch (scope) {
        SyncScope.today => l10n.syncScopeToday,
        SyncScope.month => l10n.syncScopeMonth,
        SyncScope.year => l10n.syncScopeYear,
        SyncScope.all => l10n.syncScopeAll,
      };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: ListTile(
        enabled: enabled,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: enabled
                ? colorScheme.primary.withValues(alpha: 0.12)
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _icons[scope],
            color: enabled ? colorScheme.primary : colorScheme.outline,
          ),
        ),
        title: Text(
          _label(l10n, scope),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: running
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : const Icon(Icons.chevron_right),
      ),
    );
  }
}
