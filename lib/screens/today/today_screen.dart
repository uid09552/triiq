import 'package:flutter/material.dart';

import '../../data/intervals_session.dart';
import '../../data/models/local_activity.dart';
import '../../data/models/local_wellness.dart';
import '../../data/repositories/activities_repository.dart';
import '../../data/repositories/wellness_repository.dart';
import '../../data/sync/sync_service.dart';
import '../../widgets/section_card.dart';
import '../../widgets/stat_tile.dart';

/// Today's training, key load metrics (TSS/CTL/ATL), and athlete info.
///
/// On first load (and whenever the Intervals.icu connection changes), this
/// fetches+caches today's data if it isn't already in the local SQLite
/// cache, then always reads from the cache for display.
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

  bool _loading = true;
  String? _error;
  LocalWellness? _wellness;
  List<LocalActivity> _activities = const [];

  static String get _today {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

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

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _syncService.syncTodayIfMissing();
      final wellness = await _wellnessRepository.getByDate(_today);
      final activities = await _activitiesRepository.getByDate(_today);
      if (!mounted) return;
      setState(() {
        _wellness = wellness;
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
    final colorScheme = Theme.of(context).colorScheme;
    final connected = _session.isConnected;

    final todaysLoad = _activities.isEmpty
        ? null
        : _activities.fold<int>(
            0,
            (sum, activity) => sum + (activity.trainingLoad ?? 0),
          );

    return RefreshIndicator(
      onRefresh: _load,
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
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(
                          Icons.directions_bike_outlined,
                          color: Colors.white,
                          size: 28,
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
