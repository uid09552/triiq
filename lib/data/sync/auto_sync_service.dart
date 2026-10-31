import 'dart:async';

import 'package:flutter/widgets.dart';

import '../intervals_session.dart';
import '../repositories/sync_state_repository.dart';
import 'sync_scope.dart';
import 'sync_service.dart';
import 'sync_settings.dart';

/// While the app is in the foreground, periodically re-syncs the current
/// month from Intervals.icu — throttled to
/// [SyncSettings.autoSyncIntervalMinutes] so it never hits the network more
/// often than the user allows. Stops while backgrounded: there's no reliable
/// way to wake a closed/backgrounded app on this schedule, and this is meant
/// to keep an open app fresh, not to be a background sync job.
///
/// Opening the app also syncs *today* straight away — wellness, activities
/// and planned events, ignoring the throttles — because that is when the
/// athlete is looking for the ride they just finished. On a cold start the
/// session is still being restored, so that sync fires when it connects.
///
/// Coming back to the app is the one moment where staleness is most likely
/// and most visible (the athlete just finished a ride and opened TriIQ), so
/// a resume re-syncs the current month whenever the last sync is more than
/// [resumeStaleAfter] old — independent of a longer configured interval.
///
/// A [ChangeNotifier] as well as a [WidgetsBindingObserver]: screens kept
/// alive by `IndexedStack` (Today, Calendar) don't re-run their own load on
/// every tab switch, so they listen here to know when fresh data landed in
/// the cache behind their back.
class AutoSyncService with WidgetsBindingObserver, ChangeNotifier {
  AutoSyncService._({
    SyncService? syncService,
    IntervalsSession? session,
    SyncStateRepository? syncStateRepository,
  }) : _syncService = syncService ?? SyncService(),
       _session = session ?? IntervalsSession.instance,
       _syncStateRepository = syncStateRepository ?? SyncStateRepository();

  static final AutoSyncService instance = AutoSyncService._();

  @visibleForTesting
  factory AutoSyncService.forTesting({
    required SyncService syncService,
    required IntervalsSession session,
    SyncStateRepository? syncStateRepository,
  }) = AutoSyncService._;

  final SyncService _syncService;
  final IntervalsSession _session;
  final SyncStateRepository _syncStateRepository;

  /// How stale the cache may be when the app comes back to the foreground
  /// before the current month is refetched.
  static const resumeStaleAfter = Duration(minutes: 5);

  Timer? _timer;
  DateTime? _lastSyncAt;
  bool _syncing = false;
  bool _syncingToday = false;
  bool _started = false;
  bool _wasConnected = false;

  void start() {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    SyncSettings.instance.addListener(_restartTimer);
    _session.addListener(_onSessionChanged);
    _wasConnected = _session.isConnected;
    unawaited(syncToday());
    _restartTimer();
  }

  /// The cold-start case: the app opened before the saved key was checked,
  /// so "open" only becomes syncable once the session connects.
  void _onSessionChanged() {
    final connected = _session.isConnected;
    if (connected && !_wasConnected) unawaited(syncToday());
    _wasConnected = connected;
  }

  /// Fetches just today, now. Not throttled by the configured interval (the
  /// whole point is that opening the app is fresh), but still joins any
  /// identical fetch in flight via `SyncService`. Failures are swallowed —
  /// the screens show the cache, and the timer or a pull-to-refresh retries.
  Future<void> syncToday() async {
    if (_syncingToday || !_session.isConnected) return;
    _syncingToday = true;
    try {
      await _syncService.syncScope(SyncScope.today);
      // Deliberately not `_lastSyncAt`: that throttles the month sync, which
      // today alone doesn't satisfy.
      notifyListeners();
    } catch (error) {
      debugPrint('AutoSyncService: today sync failed: $error');
    } finally {
      _syncingToday = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(syncToday());
      // Reopening the app: refresh sooner than a long configured interval
      // would, so the first screen isn't showing this morning's data.
      _restartTimer(minGap: resumeStaleAfter);
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  void _restartTimer({Duration? minGap}) {
    _timer?.cancel();
    unawaited(_maybeSync(minGap: minGap));
    _timer = Timer.periodic(
      Duration(minutes: SyncSettings.instance.autoSyncIntervalMinutes),
      (_) => _maybeSync(),
    );
  }

  /// Syncs the current month unless the last one was less than [minGap] ago
  /// (default: the user's configured interval).
  Future<void> _maybeSync({Duration? minGap}) async {
    if (_syncing || !_session.isConnected) return;

    final gap =
        minGap ??
        Duration(minutes: SyncSettings.instance.autoSyncIntervalMinutes);
    final last = _lastSyncAt ?? await _lastPersistedSync();
    if (last != null && DateTime.now().difference(last) < gap) return;

    _syncing = true;
    try {
      await _syncService.syncScope(SyncScope.month);
      _lastSyncAt = DateTime.now();
      notifyListeners();
    } catch (_) {
      // Best-effort background refresh — screen-level syncs already surface
      // their own errors, so a silent skip here just means "try again next
      // tick".
    } finally {
      _syncing = false;
    }
  }

  /// Announces that something other than the timer just refreshed the cache
  /// — a workout created upstream and pulled straight back down, say — so
  /// the long-lived screens reload from it. Counts as a sync for the
  /// throttle: the data is fresh either way.
  void notifyCacheChanged() {
    _lastSyncAt = DateTime.now();
    notifyListeners();
  }

  /// When a sync last ran, for the first check after a cold start — the
  /// in-memory timestamp is empty then, and relaunching the app inside the
  /// window shouldn't cost a fetch the interval has already ruled out.
  Future<DateTime?> _lastPersistedSync() async {
    try {
      final state = await _syncStateRepository.get('activities');
      return state?.lastSyncedAt;
    } catch (error) {
      // No database on this platform (web) — treat it as "never synced".
      debugPrint('AutoSyncService: cannot read sync state: $error');
      return null;
    }
  }
}
