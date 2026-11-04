import '../intervals_session.dart';
import '../pending_writes.dart';
import '../models/local_activity.dart';
import '../models/local_event.dart';
import '../models/local_wellness.dart';
import '../repositories/activities_repository.dart';
import '../repositories/events_repository.dart';
import '../repositories/sync_state_repository.dart';
import '../repositories/wellness_repository.dart';
import 'sync_scope.dart';
import 'sync_settings.dart';

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
    Future<bool> Function()? copyEvents,
  }) : _copyEvents = copyEvents ?? SyncSettings.readCopyIntervalsEvents,
       _session = session ?? IntervalsSession.instance,
       _wellnessRepository = wellnessRepository ?? WellnessRepository(),
       _activitiesRepository = activitiesRepository ?? ActivitiesRepository(),
       _eventsRepository = eventsRepository ?? EventsRepository(),
       _syncStateRepository = syncStateRepository ?? SyncStateRepository();

  /// Whether planned events are copied from Intervals.icu (Settings → Calendar).
  final Future<bool> Function() _copyEvents;
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

  /// Only one sync talks to Intervals.icu at a time, app-wide. Each screen
  /// holds its own [SyncService], so a pull-to-refresh landing on top of the
  /// background auto-sync (or of another screen's fetch) would otherwise
  /// fire the same three requests twice over. Static, because separate
  /// instances share nothing else.
  static final Map<String, Future<SyncResult>> _inFlight = {};
  static Future<void> _queue = Future<void>.value();

  /// Fetches [oldest]..[newest], joining a fetch of that same range that is
  /// already running and otherwise queueing behind whatever is — never
  /// racing it.
  Future<SyncResult> syncRange(DateTime oldest, DateTime newest) {
    final key = '${_formatDate(oldest)}..${_formatDate(newest)}';
    final running = _inFlight[key];
    if (running != null) return running;

    // A predecessor's failure is its own caller's problem, not this call's,
    // so the queue only waits for it to finish either way.
    final future = _queue.then((_) => _fetchRange(oldest, newest));
    _inFlight[key] = future;
    _queue = future.then((_) {}, onError: (_) {});
    return future.whenComplete(() => _inFlight.remove(key));
  }

  Future<SyncResult> _fetchRange(DateTime oldest, DateTime newest) async {
    final client = _session.client;
    final athleteId = _session.athleteId;
    if (client == null || athleteId == null) {
      throw StateError('Not connected to Intervals.icu.');
    }

    // Send what was changed offline first, so the events fetched below
    // already reflect it.
    await PendingWritesService.instance.flush();

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

    // Planned calendar entries, unless the athlete switched copying off —
    // then the cached ones are left as they are (hidden, not deleted).
    // `format` completes the `/events{format}` path; empty means the
    // default JSON representation.
    final copyEvents = await _copyEvents();
    var eventRecords = const <LocalEvent>[];
    if (copyEvents) {
      final eventsResponse = await client.getVeranstaltungenApi().listEvents(
        id: athleteId,
        format: '',
        oldest: oldestStr,
        newest: newestStr,
      );
      final waitingDeletes = await PendingWritesService.instance
          .pendingDeleteIds();
      eventRecords = (eventsResponse.data ?? const [])
          .map(LocalEvent.fromApi)
          .where((e) => !waitingDeletes.contains(e.id))
          .toList();
      await _eventsRepository.replaceRange(oldestStr, newestStr, eventRecords);
    }

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
    // Not fetched means not known to be fresh: turning copying back on
    // then syncs these dates instead of trusting a stale cache.
    if (copyEvents) {
      await _syncStateRepository.recordSync(
        'events',
        oldest: oldestStr,
        newest: newestStr,
      );
    }

    return SyncResult(
      wellnessCount: wellnessRecords.length,
      activitiesCount: activityRecords.length,
      eventsCount: eventRecords.length,
    );
  }

  /// How far the Events list looks back and ahead. A year ahead covers the
  /// season's races; a month back keeps recent notes and illness markers.
  static const eventsLookBack = Duration(days: 30);
  static const eventsLookAhead = Duration(days: 365);

  static const _eventsHorizonScope = 'events_horizon';

  /// Fetches every calendar entry from a month ago to a year ahead and
  /// replaces the cached range — the daily background job's events sync.
  ///
  /// Independent of the "copy planned events" setting: Events is its own
  /// feature, and workouts the setting hides stay hidden because
  /// `PlannedItemsRepository` filters on it when reading.
  Future<int> syncEventsHorizon() async {
    final client = _session.client;
    final athleteId = _session.athleteId;
    if (client == null || athleteId == null) {
      throw StateError('Not connected to Intervals.icu.');
    }
    final today = DateTime.now();
    final oldest = _formatDate(today.subtract(eventsLookBack));
    final newest = _formatDate(today.add(eventsLookAhead));
    final response = await client.getVeranstaltungenApi().listEvents(
      id: athleteId,
      format: '',
      oldest: oldest,
      newest: newest,
    );
    final waitingDeletes = await PendingWritesService.instance
        .pendingDeleteIds();
    final records = (response.data ?? const [])
        .map(LocalEvent.fromApi)
        .where((e) => !waitingDeletes.contains(e.id))
        .toList();
    await _eventsRepository.replaceRange(oldest, newest, records);
    await _syncStateRepository.recordSync(
      _eventsHorizonScope,
      oldest: oldest,
      newest: newest,
    );
    return records.length;
  }

  /// [syncEventsHorizon] unless it already ran within [maxAge] — what
  /// opening the Events screen wants.
  Future<void> syncEventsHorizonIfStale({
    Duration maxAge = const Duration(hours: 1),
  }) async {
    if (!_session.isConnected) return;
    final last = (await _syncStateRepository.get(_eventsHorizonScope))
        ?.lastSyncedAt;
    if (last != null && DateTime.now().difference(last) < maxAge) return;
    await syncEventsHorizon();
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

  /// The span Today's pull-to-refresh covers: the whole current month, so
  /// the Calendar's month view and the month-based statistics come back
  /// fresh from the same round-trip — widened to [todayWindow] when the
  /// current week or tomorrow spills past a month boundary.
  static (DateTime, DateTime) monthWindow([DateTime? now]) {
    final today = now ?? DateTime.now();
    final (weekStart, weekEnd) = todayWindow(today);
    final firstOfMonth = DateTime(today.year, today.month, 1);
    // Day 0 of the next month is the last day of this one.
    final lastOfMonth = DateTime(today.year, today.month + 1, 0);
    return (
      weekStart.isBefore(firstOfMonth) ? weekStart : firstOfMonth,
      weekEnd.isAfter(lastOfMonth) ? weekEnd : lastOfMonth,
    );
  }

  /// Fetches [monthWindow] unconditionally.
  Future<SyncResult> syncMonthWindow() {
    final (oldest, newest) = monthWindow();
    return syncRange(oldest, newest);
  }

  /// How often a pull-to-refresh may actually hit the network, and how long
  /// the gesture waits for it before giving up.
  static const refreshMinGap = Duration(seconds: 10);
  static const refreshTimeout = Duration(seconds: 10);

  static DateTime? _lastRefreshAt;

  /// A pull-to-refresh over [oldest]..[newest]: at most one fetch per
  /// [refreshMinGap] across the whole app, never running alongside another
  /// sync (see [syncRange]), and abandoned after [refreshTimeout] so the
  /// gesture can't hang on a connection that never answers. Returns whether
  /// it fetched — a refresh the throttle skipped is not an error, and the
  /// caller can still re-read the cache.
  ///
  /// Abandoning is only about the waiting: the request itself carries on and
  /// its rows still land in the cache, where the next load picks them up.
  Future<bool> refreshRange(DateTime oldest, DateTime newest) async {
    if (!_session.isConnected) return false;

    final last = _lastRefreshAt;
    if (last != null && DateTime.now().difference(last) < refreshMinGap) {
      return false;
    }
    // Stamped before the fetch, not after: a refresh that fails or times
    // out still counts, so repeated pulls can't hammer a dead connection.
    _lastRefreshAt = DateTime.now();

    await syncRange(oldest, newest).timeout(refreshTimeout);
    return true;
  }

  /// What pull-to-refresh on Statistics runs: [refreshRange] over the
  /// current month.
  Future<bool> refreshMonthWindow() {
    final (oldest, newest) = monthWindow();
    return refreshRange(oldest, newest);
  }

  /// What pull-to-refresh on Today runs: [refreshRange] over just today, so
  /// the gesture stays fast instead of racing [refreshTimeout] against a
  /// whole month of wellness/activities/events.
  Future<bool> refreshDayWindow() {
    final today = DateTime.now();
    return refreshRange(today, today);
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

  /// Fetches the whole calendar month containing [date] — what a change
  /// written upstream (a workout just created on Intervals.icu) needs, so
  /// the Calendar's month cache shows it without waiting for a background
  /// sync.
  Future<SyncResult> syncMonth(DateTime date) {
    final firstOfMonth = DateTime(date.year, date.month, 1);
    // Day 0 of the next month is the last day of this one.
    final lastOfMonth = DateTime(date.year, date.month + 1, 0);
    return syncRange(firstOfMonth, lastOfMonth);
  }

  /// How long a cached range counts as fresh when a screen is reopened.
  static const staleAfter = Duration(minutes: 1);

  /// Fetches [oldest]..[newest] unless the cache was refreshed less than
  /// [maxAge] ago — what switching to the Calendar tab wants: data that is
  /// current on arrival, without a round-trip every time the tab is
  /// bounced.
  Future<void> syncRangeIfStale(
    DateTime oldest,
    DateTime newest, {
    Duration maxAge = staleAfter,
  }) async {
    if (!_session.isConnected) return;

    final state = await _syncStateRepository.get('activities');
    final lastSyncedAt = state?.lastSyncedAt;
    if (lastSyncedAt != null &&
        DateTime.now().difference(lastSyncedAt) < maxAge) {
      return;
    }

    await syncRange(oldest, newest);
  }

  /// Fetches [oldest]..[newest], but only if that whole span already falls
  /// inside what's been synced before — what navigating the Calendar wants,
  /// so revisiting a month already looked at doesn't re-hit the network.
  Future<void> syncRangeIfMissing(DateTime oldest, DateTime newest) async {
    if (!_session.isConnected) return;

    final oldestStr = _formatDate(oldest);
    final newestStr = _formatDate(newest);
    final state = await _syncStateRepository.get('activities');
    final covered =
        state != null &&
        oldestStr.compareTo(state.oldest) >= 0 &&
        newestStr.compareTo(state.newest) <= 0;
    if (covered) return;

    await syncRange(oldest, newest);
  }

  static String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
