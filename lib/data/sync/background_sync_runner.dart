import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../notifications/notification_service.dart';
import '../../notifications/notification_settings.dart';
import '../intervals_session.dart';
import '../repositories/sync_state_repository.dart';
import 'sync_service.dart';
import 'sync_settings.dart';

/// How one background run ended. The `name` is what Settings shows as the
/// last result.
enum BackgroundSyncOutcome {
  /// Turned off in Settings.
  disabled,

  /// Never connected (no key stored) — nothing to sync, not a failure.
  notConnected,

  /// The cache was refreshed recently enough that no request was made.
  skippedFresh,

  success,

  /// Intervals.icu rejected the key; only the athlete can fix this.
  authRejected,

  /// Network or server trouble; the next night tries again.
  failed,
}

/// One nightly run: sync the current week into the cache, unless that is
/// pointless (disabled, not connected, cache already fresh), and record how
/// it went. Free of Flutter plugins so it runs in WorkManager's isolate and
/// in tests alike — the pieces that touch the outside world are injected.
class BackgroundSyncRunner {
  BackgroundSyncRunner({
    required this.ensureConnected,
    required this.lastSyncedAt,
    required this.sync,
    required this.notify,
    required this.settings,
    this.syncEvents,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  /// The real wiring, as used by the background isolate.
  factory BackgroundSyncRunner.live() {
    final session = IntervalsSession.instance;
    return BackgroundSyncRunner(
      ensureConnected: () async {
        if (!session.isConnected) await session.restore();
        return session.isConnected
            ? RestoreFailure.none
            : session.lastRestoreFailure;
      },
      lastSyncedAt: () async =>
          (await SyncStateRepository().get('activities'))?.lastSyncedAt,
      sync: () => SyncService().syncTodayWindow().then((_) {}),
      syncEvents: () => SyncService().syncEventsHorizon().then((_) {}),
      notify: ({required bool reconnectNeeded}) async {
        await NotificationSettings.instance.load();
        if (!NotificationSettings.instance.enabled) return;
        final notifications = NotificationService.instance;
        await notifications.init();
        await notifications.showSyncProblem(reconnectNeeded: reconnectNeeded);
      },
      settings: SyncSettings.instance,
    );
  }

  /// Connects the session if it isn't yet; says why when it still isn't.
  final Future<RestoreFailure> Function() ensureConnected;

  /// When the cache was last refreshed, or `null` if never.
  final Future<DateTime?> Function() lastSyncedAt;

  /// Fetches the current week (see `SyncService.todayWindow`).
  final Future<void> Function() sync;

  /// Fetches the Events horizon (a month back to a year ahead) after the
  /// week, so the Events list is current every morning.
  final Future<void> Function()? syncEvents;

  final Future<void> Function({required bool reconnectNeeded}) notify;
  final SyncSettings settings;
  final DateTime Function() _now;

  /// A cache refreshed within this long ago (by the app being open, say) is
  /// not fetched again — the run would only spend battery for nothing.
  static const freshFor = Duration(hours: 6);

  /// Consecutive failures after which the athlete is told, once.
  static const notifyAfterFailures = 3;

  Future<BackgroundSyncOutcome> run() async {
    await settings.load();
    if (!settings.backgroundSyncEnabled) return BackgroundSyncOutcome.disabled;

    final last = await lastSyncedAt();
    if (last != null && _now().difference(last) < freshFor) {
      return _record(BackgroundSyncOutcome.skippedFresh);
    }

    final connection = await ensureConnected();
    switch (connection) {
      case RestoreFailure.none:
        break;
      case RestoreFailure.noKey:
        return BackgroundSyncOutcome.notConnected;
      case RestoreFailure.rejected:
        return _authRejected();
      case RestoreFailure.network:
        return _failed();
    }

    try {
      await sync();
      await syncEvents?.call();
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 401 || status == 403) return _authRejected();
      return _failed();
    } catch (error) {
      debugPrint('BackgroundSyncRunner: sync failed: $error');
      return _failed();
    }
    return _record(BackgroundSyncOutcome.success);
  }

  Future<BackgroundSyncOutcome> _record(
    BackgroundSyncOutcome outcome, {
    bool failed = false,
  }) async {
    await settings.recordBackgroundRun(outcome.name, failed: failed);
    return outcome;
  }

  Future<BackgroundSyncOutcome> _failed() async {
    final outcome = await _record(BackgroundSyncOutcome.failed, failed: true);
    // `==`, not `>=`: told once when the streak reaches the threshold, then
    // quiet until a success resets the count.
    if (settings.backgroundFailures == notifyAfterFailures) {
      await notify(reconnectNeeded: false);
    }
    return outcome;
  }

  Future<BackgroundSyncOutcome> _authRejected() async {
    // Tell the athlete the first time only; a key that stays revoked would
    // otherwise produce the same notification every night.
    final alreadyTold =
        settings.backgroundLastResult == BackgroundSyncOutcome.authRejected.name;
    final outcome = await _record(
      BackgroundSyncOutcome.authRejected,
      failed: true,
    );
    if (!alreadyTold) await notify(reconnectNeeded: true);
    return outcome;
  }
}
