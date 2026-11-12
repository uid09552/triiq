import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'background_sync_runner.dart';
import 'sync_settings.dart';

const _taskName = 'triiq.nightlySync';
const _uniqueName = 'triiq.nightlySync.periodic';

/// WorkManager's entry point. Runs in its own isolate with none of the app's
/// singletons loaded, which is why [BackgroundSyncRunner.live] builds
/// everything from storage.
@pragma('vm:entry-point')
void backgroundSyncDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != _taskName) return true;
    try {
      final outcome = await BackgroundSyncRunner.live().run();
      debugPrint('Background sync: ${outcome.name}');
    } catch (error) {
      debugPrint('Background sync crashed: $error');
    }
    // Always "done": a false would make WorkManager retry with backoff, and
    // a revoked key or dead network would just burn battery. The next
    // scheduled run is the retry.
    return true;
  });
}

/// Schedules (or cancels) the periodic sync that keeps the cache fresh while
/// the app is closed — nightly by default, or every 15 min / 1 h / 6 h as
/// chosen in Settings ([BackgroundSyncInterval]). Android only: Windows,
/// iOS and web have no closed-app wake here, so there the app stays
/// foreground-synced (see `AutoSyncService`).
class BackgroundSync {
  BackgroundSync._();

  static final BackgroundSync instance = BackgroundSync._();

  /// Whether this platform can run work with the app closed.
  static bool get isSupported =>
      debugSupported ?? (!kIsWeb && Platform.isAndroid);

  /// Tests set this to exercise the Android-only UI on any host.
  @visibleForTesting
  static bool? debugSupported;

  /// The nightly window: the run happens between these local hours.
  static const windowStartHour = 2;
  static const windowLength = Duration(hours: 3);

  bool _initialized = false;

  /// The interval the registered job was last scheduled with, so [apply]
  /// can tell a changed choice (re-register) from a plain relaunch (keep).
  static const _scheduledIntervalKey = 'sync.background_scheduled_interval';

  /// Makes the schedule match [SyncSettings.backgroundSyncEnabled] and
  /// [SyncSettings.backgroundSyncInterval]. Safe to call at every launch and
  /// after every change; never throws.
  Future<void> apply() async {
    if (!isSupported) return;
    try {
      final settings = SyncSettings.instance;
      if (!settings.isLoaded) await settings.load();
      final manager = Workmanager();
      if (!_initialized) {
        await manager.initialize(backgroundSyncDispatcher);
        _initialized = true;
      }
      final prefs = await SharedPreferences.getInstance();
      if (!settings.backgroundSyncEnabled) {
        await manager.cancelByUniqueName(_uniqueName);
        await prefs.remove(_scheduledIntervalKey);
        return;
      }
      final interval = settings.backgroundSyncInterval;
      final scheduled = prefs.getString(_scheduledIntervalKey);
      // A job from before the interval choice existed was the nightly one.
      final changed =
          (scheduled ?? BackgroundSyncInterval.nightly.name) != interval.name;
      if (changed) {
        // `keep` below would otherwise leave the old period in place.
        await manager.cancelByUniqueName(_uniqueName);
      }
      final nightly = interval == BackgroundSyncInterval.nightly;
      await manager.registerPeriodicTask(
        _uniqueName,
        _taskName,
        frequency: interval.frequency,
        flexInterval: nightly ? windowLength : null,
        initialDelay: nightly ? initialDelayFor(DateTime.now()) : Duration.zero,
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
        ),
        // Keep: re-registering at every launch must not restart the period,
        // or an app opened daily would push the sync back forever. A changed
        // interval cancelled the old job above, so this registers afresh.
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      );
      await prefs.setString(_scheduledIntervalKey, interval.name);
    } catch (error) {
      debugPrint('BackgroundSync: could not update schedule: $error');
    }
  }

  /// WorkManager runs a periodic job in the *last* `flex` of each period.
  /// Starting the first period at the next window end (05:00) therefore
  /// makes the run eligible from 02:00 to 05:00 the day after, and every
  /// 24 hours from then on. Local time; a DST change moves it by an hour,
  /// which the window absorbs.
  @visibleForTesting
  static Duration initialDelayFor(DateTime now) {
    final windowEndHour = windowStartHour + windowLength.inHours;
    var periodStart = DateTime(now.year, now.month, now.day, windowEndHour);
    if (!periodStart.isAfter(now)) {
      periodStart = periodStart.add(const Duration(days: 1));
    }
    return periodStart.difference(now);
  }
}
