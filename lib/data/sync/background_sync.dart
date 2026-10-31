import 'dart:io';

import 'package:flutter/foundation.dart';
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
    // a revoked key or dead network would just burn battery. Tomorrow's run
    // is the retry.
    return true;
  });
}

/// Schedules (or cancels) the nightly sync that keeps the cache fresh while
/// the app is closed. Android only: Windows and web have no closed-app wake,
/// so there the app stays foreground-synced (see `AutoSyncService`).
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

  /// Makes the schedule match [SyncSettings.backgroundSyncEnabled]. Safe to
  /// call at every launch and after every toggle; never throws.
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
      if (!settings.backgroundSyncEnabled) {
        await manager.cancelByUniqueName(_uniqueName);
        return;
      }
      await manager.registerPeriodicTask(
        _uniqueName,
        _taskName,
        frequency: const Duration(hours: 24),
        flexInterval: windowLength,
        initialDelay: initialDelayFor(DateTime.now()),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
        ),
        // Keep: re-registering at every launch must not restart the period,
        // or an app opened daily would push the sync back forever.
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      );
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
