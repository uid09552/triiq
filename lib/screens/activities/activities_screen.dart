import 'package:flutter/material.dart';

import '../../data/intervals_session.dart';
import '../../data/models/local_activity.dart';
import '../../data/repositories/activities_repository.dart';
import '../../l10n/app_localizations.dart';
import 'activity_detail_screen.dart';
import 'activity_icons.dart';

/// Every cached activity, most recent first. Reachable from More →
/// Activities, and from a sport row on Statistics — which arrives with
/// [initialType] set, so the list opens showing that sport alone. Reads
/// only from the local SQLite cache — use Sync to pull more history in
/// first.
class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key, this.initialType});

  /// Intervals.icu activity type to show on arrival (`Ride`, `Run`, …), or
  /// null for the unfiltered list. The filter is a starting point, not a
  /// fixed one: it shows as a chip the user can clear.
  final String? initialType;

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  final _repository = ActivitiesRepository();
  final _session = IntervalsSession.instance;

  bool _loading = true;
  String? _error;
  List<LocalActivity> _activities = const [];

  /// Active type filter, or null for "all sports".
  String? _type;

  /// What the list actually renders.
  List<LocalActivity> get _visible => _type == null
      ? _activities
      : _activities.where((a) => a.type == _type).toList();

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final activities = await _repository.getAll();
      if (!mounted) return;
      setState(() {
        _activities = activities;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activities = _visible;
    final type = _type;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.titleActivities),
        bottom: type == null
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(52),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: InputChip(
                      avatar: Icon(activityTypeIcon(type), size: 18),
                      label: Text(type),
                      onDeleted: () => setState(() => _type = null),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      tooltip: l10n.showAllActivities,
                    ),
                  ),
                ),
              ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _EmptyState(connected: _session.isConnected, error: _error)
            : activities.isEmpty
            ? _EmptyState(connected: _session.isConnected, type: type)
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: activities.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) =>
                    _ActivityRow(activity: activities[index]),
              ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity});

  final LocalActivity activity;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final details = <String>[
      formatIsoDate(activity.date),
      if (activity.distance != null && activity.distance! > 0)
        formatDistanceMeters(activity.distance!),
      if (activity.movingTime != null && activity.movingTime! > 0)
        formatDurationSecs(activity.movingTime!),
    ];

    return Card(
      child: ListTile(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ActivityDetailScreen(activity: activity),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            activityTypeIcon(activity.type),
            color: colorScheme.primary,
          ),
        ),
        title: Text(
          activity.name ?? activity.type ?? l10n.activityFallback,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(details.join(' · ')),
        trailing: activity.trainingLoad == null
            ? const Icon(Icons.chevron_right)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${activity.trainingLoad}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.primary,
                    ),
                  ),
                  Text(
                    l10n.tssSuffix,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.connected, this.error, this.type});

  final bool connected;
  final String? error;

  /// Set when the list is empty only because a sport filter is on — "no
  /// rides cached" is a different problem from "nothing cached at all".
  final String? type;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    error != null
                        ? Icons.error_outline
                        : Icons.event_busy_outlined,
                    size: 40,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    error ??
                        (type != null
                            ? l10n.noActivitiesOfType(type!)
                            : connected
                            ? l10n.noActivitiesCachedConnected
                            : l10n.noActivitiesCachedDisconnected),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
