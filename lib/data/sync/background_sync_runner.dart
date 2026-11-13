import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../l10n/app_localizations.dart';
import '../../locale_controller.dart';
import '../../notifications/morning_briefing.dart';
import '../../notifications/weekly_review_notification.dart';
import '../../notifications/notification_service.dart';
import '../../notifications/notification_settings.dart';
import '../../util/dates.dart';
import '../home_widget_data.dart';
import '../intervals_session.dart';
import '../models/local_event.dart';
import '../repositories/activities_repository.dart';
import '../repositories/events_repository.dart';
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

  /// Network or server trouble; the next scheduled run tries again.
  failed,
}

/// What the cache held for the parts a background run can change and the
/// athlete cares about: completed activities in the synced week, and
/// planned sessions from today on. Taken before and after a run, so a
/// notification is shown only when something actually arrived.
@immutable
class BackgroundSnapshot {
  const BackgroundSnapshot({
    this.activityIds = const {},
    this.sessions = const {},
  });

  final Set<String> activityIds;

  /// Planned session id → a fingerprint of the fields the athlete sees, so
  /// an edited session counts as changed but a mere re-fetch does not.
  final Map<String, String> sessions;

  /// The fingerprint [sessions] stores for [event].
  static String fingerprint(LocalEvent event) => [
    event.date,
    event.category,
    event.type,
    event.name,
    event.description,
    event.plannedLoad,
    event.plannedTime,
    event.plannedDistance,
    event.indoor,
  ].join('\u0001');

  /// What is new in [after] compared with this snapshot. Removed sessions
  /// are not counted: a deletion is no reason to wake the athlete.
  BackgroundChanges changesTo(BackgroundSnapshot after) => BackgroundChanges(
    newActivities: after.activityIds.difference(activityIds).length,
    changedSessions: after.sessions.entries
        .where((e) => sessions[e.key] != e.value)
        .length,
  );
}

/// The result of [BackgroundSnapshot.changesTo].
@immutable
class BackgroundChanges {
  const BackgroundChanges({
    required this.newActivities,
    required this.changedSessions,
  });

  final int newActivities;

  /// New or edited planned sessions.
  final int changedSessions;

  bool get any => newActivities > 0 || changedSessions > 0;
}

/// One background run: sync the current week into the cache, unless that is
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
    this.afterSuccess,
    this.snapshot,
    this.notifyChanges,
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
      syncEvents: () {
        // The year-long events horizon is a big request: nightly runs fetch
        // it every time, as before; frequent runs at most every 6 hours
        // (the week's events still come with `sync` above).
        final service = SyncService();
        return SyncSettings.instance.backgroundSyncInterval ==
                BackgroundSyncInterval.nightly
            ? service.syncEventsHorizon().then((_) {})
            : service.syncEventsHorizonIfStale(
                maxAge: const Duration(hours: 6),
              );
      },
      snapshot: _liveSnapshot,
      notifyChanges: (changes) async {
        await NotificationSettings.instance.load();
        if (!NotificationSettings.instance.enabled) return;
        final l10n = await _backgroundL10n();
        final notifications = NotificationService.instance;
        await notifications.init();
        await notifications.showBackgroundUpdate(
          title: l10n.backgroundUpdateTitle,
          body: [
            if (changes.newActivities > 0)
              l10n.backgroundUpdateActivities(changes.newActivities),
            if (changes.changedSessions > 0)
              l10n.backgroundUpdateSessions(changes.changedSessions),
          ].join(' '),
        );
      },
      afterSuccess: () async {
        await HomeWidgetUpdater().update();
        await NotificationService.instance.init();
        await MorningBriefingScheduler().refresh();
        await WeeklyReviewScheduler().refresh();
      },
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

  static Future<BackgroundSnapshot> _liveSnapshot() async {
    final (oldest, newest) = SyncService.todayWindow();
    final activities = await ActivitiesRepository().getRange(
      isoDate(oldest),
      isoDate(newest),
    );
    // Hidden planned events (copying switched off) are no news either.
    final sessions = await SyncSettings.readCopyIntervalsEvents()
        ? await EventsRepository().getRange(
            isoDate(DateTime.now()),
            isoDate(DateTime.now().add(SyncService.eventsLookAhead)),
          )
        : const <LocalEvent>[];
    return BackgroundSnapshot(
      activityIds: {for (final a in activities) a.id},
      sessions: {
        for (final e in sessions)
          if (e.category == 'WORKOUT') e.id: BackgroundSnapshot.fingerprint(e),
      },
    );
  }

  /// The app's language in an isolate without a widget tree.
  static Future<AppLocalizations> _backgroundL10n() async {
    final controller = LocaleController.instance;
    await controller.load();
    final chosen = controller.locale ?? PlatformDispatcher.instance.locale;
    final code =
        LocaleController.supportedLocales.any(
          (l) => l.languageCode == chosen.languageCode,
        )
        ? chosen.languageCode
        : 'en';
    return lookupAppLocalizations(Locale(code));
  }

  /// Connects the session if it isn't yet; says why when it still isn't.
  final Future<RestoreFailure> Function() ensureConnected;

  /// When the cache was last refreshed, or `null` if never.
  final Future<DateTime?> Function() lastSyncedAt;

  /// Fetches the current week (see `SyncService.todayWindow`).
  final Future<void> Function() sync;

  /// Fetches the Events horizon (a month back to a year ahead) after the
  /// week, so the Events list is current every morning (frequent intervals
  /// throttle it, see [BackgroundSyncRunner.live]).
  final Future<void> Function()? syncEvents;

  /// Runs after a successful sync (refreshes the home-screen widget).
  final Future<void> Function()? afterSuccess;

  /// Reads what the cache holds now; taken before and after the fetch.
  /// Without it no "new data" notification is shown.
  final Future<BackgroundSnapshot> Function()? snapshot;

  /// Tells the athlete what arrived. Only called when something did, and
  /// the live wiring also checks the master notifications switch.
  final Future<void> Function(BackgroundChanges changes)? notifyChanges;

  final Future<void> Function({required bool reconnectNeeded}) notify;
  final SyncSettings settings;
  final DateTime Function() _now;

  /// Consecutive failures after which the athlete is told, once.
  static const notifyAfterFailures = 3;

  Future<BackgroundSyncOutcome> run() async {
    await settings.load();
    if (!settings.backgroundSyncEnabled) return BackgroundSyncOutcome.disabled;

    final last = await lastSyncedAt();
    // A cache refreshed this recently (by the open app, say) is not fetched
    // again — the run would only spend battery for nothing.
    final freshFor = settings.backgroundSyncInterval.freshFor;
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

    // Never synced before: this run is the first fill, not news.
    final before = last == null ? null : await _takeSnapshot();
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
    try {
      await afterSuccess?.call();
    } catch (error) {
      debugPrint('BackgroundSyncRunner: after-sync hook failed: $error');
    }
    final outcome = await _record(BackgroundSyncOutcome.success);
    await _notifyIfNew(before);
    return outcome;
  }

  Future<BackgroundSnapshot?> _takeSnapshot() async {
    if (snapshot == null || notifyChanges == null) return null;
    try {
      return await snapshot!();
    } catch (error) {
      debugPrint('BackgroundSyncRunner: snapshot failed: $error');
      return null;
    }
  }

  /// Notifies only when the fetch brought something new.
  Future<void> _notifyIfNew(BackgroundSnapshot? before) async {
    if (before == null) return;
    final after = await _takeSnapshot();
    if (after == null) return;
    final changes = before.changesTo(after);
    if (!changes.any) return;
    try {
      await notifyChanges!(changes);
    } catch (error) {
      debugPrint('BackgroundSyncRunner: new-data notification failed: $error');
    }
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
        settings.backgroundLastResult ==
        BackgroundSyncOutcome.authRejected.name;
    final outcome = await _record(
      BackgroundSyncOutcome.authRejected,
      failed: true,
    );
    if (!alreadyTold) await notify(reconnectNeeded: true);
    return outcome;
  }
}
