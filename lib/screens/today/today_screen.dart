import 'package:flutter/material.dart';

import '../../data/intervals_session.dart';
import '../../data/models/local_activity.dart';
import '../../data/models/local_event.dart';
import '../../data/models/local_wellness.dart';
import '../../data/repositories/activities_repository.dart';
import '../../data/repositories/events_repository.dart';
import '../../data/repositories/wellness_repository.dart';
import '../../data/sync/sync_service.dart';
import '../../widgets/section_card.dart';
import '../../widgets/stat_tile.dart';

/// Today's and tomorrow's planned training, what was actually logged, and
/// the key load metrics (TSS today, TSS this week, CTL/ATL).
///
/// Opening the screen (and any change to the Intervals.icu connection)
/// fetches the current week plus tomorrow if today isn't cached yet;
/// pull-to-refresh always refetches. Display always reads from SQLite, so
/// the screen works offline once synced.
class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final _session = IntervalsSession.instance;
  final _syncService = SyncService();
  final _wellnessRepository = WellnessRepository();
  final _activitiesRepository = ActivitiesRepository();
  final _eventsRepository = EventsRepository();

  bool _loading = true;
  String? _error;
  LocalWellness? _wellness;
  List<LocalActivity> _activities = const [];
  List<LocalEvent> _todaysPlan = const [];
  List<LocalEvent> _tomorrowsPlan = const [];
  int _weekLoad = 0;
  int _weekPlannedLoad = 0;

  static String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static String get _today => _formatDate(DateTime.now());

  static String get _tomorrow =>
      _formatDate(DateTime.now().add(const Duration(days: 1)));

  @override
  void initState() {
    super.initState();
    _session.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    _session.removeListener(_load);
    super.dispose();
  }

  /// Opening the screen or reconnecting: sync only if today is missing.
  Future<void> _load() => _refresh(force: false);

  /// Pull-to-refresh: always refetch, otherwise the gesture would silently
  /// do nothing once today is cached.
  Future<void> _refreshFromGesture() => _refresh(force: true);

  Future<void> _refresh({required bool force}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    // A failed fetch shouldn't blank the screen: fall through to reading
    // whatever is already cached and surface the error alongside it.
    Object? syncError;
    try {
      if (force) {
        await _syncService.syncTodayWindow();
      } else {
        await _syncService.syncTodayWindowIfMissing();
      }
    } catch (e) {
      syncError = e;
    }

    try {
      final (weekStart, weekEnd) = SyncService.todayWindow();
      final wellness = await _wellnessRepository.getByDate(_today);
      final activities = await _activitiesRepository.getByDate(_today);
      final todaysPlan = await _eventsRepository.getByDate(_today);
      final tomorrowsPlan = await _eventsRepository.getByDate(_tomorrow);
      final weekActivities = await _activitiesRepository.getRange(
        _formatDate(weekStart),
        _formatDate(weekEnd),
      );
      final weekEvents = await _eventsRepository.getRange(
        _formatDate(weekStart),
        _formatDate(weekEnd),
      );

      if (!mounted) return;
      setState(() {
        _wellness = wellness;
        _activities = activities;
        _todaysPlan = todaysPlan.where((e) => e.isTraining).toList();
        _tomorrowsPlan = tomorrowsPlan.where((e) => e.isTraining).toList();
        _weekLoad = weekActivities.fold<int>(
          0,
          (sum, activity) => sum + (activity.trainingLoad ?? 0),
        );
        _weekPlannedLoad = weekEvents
            .where((e) => e.isTraining)
            .fold<int>(0, (sum, event) => sum + (event.plannedLoad ?? 0));
        _error = syncError?.toString();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = (syncError ?? e).toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final connected = _session.isConnected;

    final todaysLoad = _activities.isEmpty
        ? null
        : _activities.fold<int>(
            0,
            (sum, activity) => sum + (activity.trainingLoad ?? 0),
          );

    return RefreshIndicator(
      onRefresh: _refreshFromGesture,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colorScheme.primary, colorScheme.tertiary],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _activities.isEmpty
                            ? 'Ready to train'
                            : _activities.length == 1
                            ? '1 activity logged today'
                            : '${_activities.length} activities logged today',
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _describeStatus(connected),
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                      ),
                    ],
                  ),
                ),
                // Doubles as the refresh affordance: pull-to-refresh is
                // fine on a phone but awkward with a mouse on Windows.
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: _loading
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                        )
                      : IconButton(
                          onPressed: _refreshFromGesture,
                          padding: const EdgeInsets.all(14),
                          constraints: const BoxConstraints(),
                          tooltip: 'Refresh',
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            SectionCard(
              icon: Icons.error_outline,
              title: 'Sync failed',
              child: Text(_error!, style: Theme.of(context).textTheme.bodySmall),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: 'TSS today',
                  value: todaysLoad?.toString() ?? '—',
                  icon: Icons.bolt_outlined,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  // Actual load so far this week, against what the plan
                  // asks for — the number that says "am I on track".
                  label: _weekPlannedLoad > 0
                      ? 'TSS week (of $_weekPlannedLoad)'
                      : 'TSS week',
                  value: _weekLoad.toString(),
                  icon: Icons.calendar_view_week_outlined,
                  color: colorScheme.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: 'CTL',
                  value: _wellness?.ctl?.toStringAsFixed(1) ?? '—',
                  icon: Icons.trending_up,
                  color: colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  label: 'ATL',
                  value: _wellness?.atl?.toStringAsFixed(1) ?? '—',
                  icon: Icons.speed_outlined,
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SectionCard(
            icon: Icons.event_available_outlined,
            title: "Today's training",
            child: _PlannedTraining(
              events: _todaysPlan,
              emptyLabel: connected
                  ? 'Nothing planned for today — rest day.'
                  : 'Connect your Intervals.icu account to see your plan.',
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            icon: Icons.event_outlined,
            title: "Tomorrow's training",
            child: _PlannedTraining(
              events: _tomorrowsPlan,
              emptyLabel: connected
                  ? 'Nothing planned for tomorrow yet.'
                  : 'Connect your Intervals.icu account to see your plan.',
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            icon: Icons.person_outline,
            title: 'Athlete',
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(connected ? Icons.link : Icons.link_off),
              title: Text(
                connected
                    ? (_session.athleteName ?? 'Connected')
                    : 'Not connected',
              ),
              subtitle: Text(
                connected
                    ? 'Synced with Intervals.icu'
                    : 'Connect your Intervals.icu account in Profile',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _describeStatus(bool connected) {
    if (!connected) return 'Not connected to Intervals.icu';
    if (_activities.isEmpty) return 'No workout logged today';
    final names = _activities
        .map((a) => a.name ?? a.type ?? 'Activity')
        .join(', ');
    return names;
  }
}


/// Renders the planned sessions for one day, or why there are none.
class _PlannedTraining extends StatelessWidget {
  const _PlannedTraining({required this.events, required this.emptyLabel});

  final List<LocalEvent> events;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (events.isEmpty) {
      return Text(
        emptyLabel,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final event in events) ...[
          if (event != events.first) const Divider(height: 20),
          Text(
            event.name ?? event.type ?? 'Planned session',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            _describe(event),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  static String _describe(LocalEvent event) {
    final parts = <String>[
      if (event.type != null) event.type!,
      if (event.indoor) 'indoor',
      if (event.plannedTime != null) _formatDuration(event.plannedTime!),
      if (event.plannedDistance != null && event.plannedDistance! > 0)
        '${(event.plannedDistance! / 1000).toStringAsFixed(1)} km',
      if (event.plannedLoad != null) '${event.plannedLoad} TSS',
    ];
    return parts.isEmpty ? 'No target set' : parts.join(' · ');
  }

  static String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }
}
