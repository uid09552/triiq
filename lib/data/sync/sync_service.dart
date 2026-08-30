import '../intervals_session.dart';
import '../models/local_activity.dart';
import '../models/local_event.dart';
import '../models/local_wellness.dart';
import '../repositories/activities_repository.dart';
import '../repositories/events_repository.dart';
import '../repositories/sync_state_repository.dart';
import '../repositories/wellness_repository.dart';
import 'sync_scope.dart';

class SyncResult {
  const SyncResult({
    required this.wellnessCount,
    required this.activitiesCount,
    required this.eventsCount,
  });

  final int wellnessCount;
  final int activitiesCount;

  /// Planned calendar entries (workouts, races, notes).
  final int eventsCount;
}

/// Fetches data from Intervals.icu for a date range and caches it locally.
class SyncService {
  SyncService({
    IntervalsSession? session,
    WellnessRepository? wellnessRepository,
    ActivitiesRepository? activitiesRepository,
    EventsRepository? eventsRepository,
    SyncStateRepository? syncStateRepository,
  }) : _session = session ?? IntervalsSession.instance,
       _wellnessRepository = wellnessRepository ?? WellnessRepository(),
       _activitiesRepository =
           activitiesRepository ?? ActivitiesRepository(),
       _eventsRepository = eventsRepository ?? EventsRepository(),
       _syncStateRepository =
           syncStateRepository ?? SyncStateRepository();

  final IntervalsSession _session;
  final WellnessRepository _wellnessRepository;
  final ActivitiesRepository _activitiesRepository;
  final EventsRepository _eventsRepository;
  final SyncStateRepository _syncStateRepository;

  /// Earliest date requested for [SyncScope.all]. Intervals.icu simply
  /// returns whatever records actually exist within the requested range.
  static final DateTime _earliestPossibleDate = DateTime(2000, 1, 1);

  Future<SyncResult> syncScope(SyncScope scope) {
    final today = DateTime.now();
    final (oldest, newest) = switch (scope) {
      SyncScope.today => (today, today),
      SyncScope.month => (DateTime(today.year, today.month, 1), today),
      SyncScope.year => (DateTime(today.year, 1, 1), today),
      SyncScope.all => (_earliestPossibleDate, today),
    };
    return syncRange(oldest, newest);
  }

  Future<SyncResult> syncRange(DateTime oldest, DateTime newest) async {
    final client = _session.client;
    final athleteId = _session.athleteId;
    if (client == null || athleteId == null) {
      throw StateError('Not connected to Intervals.icu.');
    }

    final oldestStr = _formatDate(oldest);
    final newestStr = _formatDate(newest);

    final wellnessResponse = await client.getWellnessApi().listWellnessRecords(
      id: athleteId,
      ext: '',
      oldest: oldestStr,
      newest: newestStr,
    );
    final wellnessRecords = (wellnessResponse.data ?? const [])
        .map(LocalWellness.fromApi)
        .toList();
    await _wellnessRepository.upsertAll(wellnessRecords);

    final activitiesResponse = await client.getAktivittenApi().listActivities(
      id: athleteId,
      oldest: oldestStr,
      newest: newestStr,
    );
    final activityRecords = (activitiesResponse.data ?? const [])
        .map(LocalActivity.fromApi)
        .toList();
    await _activitiesRepository.upsertAll(activityRecords);

    // Planned calendar entries. `format` completes the `/events{format}`
    // path; empty means the default JSON representation.
    final eventsResponse = await client.getVeranstaltungenApi().listEvents(
      id: athleteId,
      format: '',
      oldest: oldestStr,
      newest: newestStr,
    );
    final eventRecords = (eventsResponse.data ?? const [])
        .map(LocalEvent.fromApi)
        .toList();
    await _eventsRepository.replaceRange(oldestStr, newestStr, eventRecords);

    await _syncStateRepository.recordSync(
      'wellness',
      oldest: oldestStr,
      newest: newestStr,
    );
    await _syncStateRepository.recordSync(
      'activities',
      oldest: oldestStr,
      newest: newestStr,
    );
    await _syncStateRepository.recordSync(
      'events',
      oldest: oldestStr,
      newest: newestStr,
    );

    return SyncResult(
      wellnessCount: wellnessRecords.length,
      activitiesCount: activityRecords.length,
      eventsCount: eventRecords.length,
    );
  }

  /// The span the Today screen needs in one round-trip: the whole current
  /// week (for the week's TSS total) plus tomorrow (for tomorrow's planned
  /// session, which falls outside the week when today is Sunday).
  static (DateTime, DateTime) todayWindow([DateTime? now]) {
    final today = now ?? DateTime.now();
    final startOfWeek = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: today.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final tomorrow = DateTime(
      today.year,
      today.month,
      today.day,
    ).add(const Duration(days: 1));
    return (startOfWeek, tomorrow.isAfter(endOfWeek) ? tomorrow : endOfWeek);
  }

  /// Fetches [todayWindow] unconditionally — what pull-to-refresh wants.
  Future<SyncResult> syncTodayWindow() {
    final (oldest, newest) = todayWindow();
    return syncRange(oldest, newest);
  }

  /// Fetches [todayWindow], but only if today isn't already cached — what
  /// opening the Today screen wants, so revisiting the tab is free.
  Future<void> syncTodayWindowIfMissing() async {
    if (!_session.isConnected) return;

    final today = _formatDate(DateTime.now());
    final cached = await _wellnessRepository.getByDate(today);
    if (cached != null) return;

    await syncTodayWindow();
  }

  static String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
