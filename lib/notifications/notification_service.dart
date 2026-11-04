import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Local notifications for sync completion, agent replies, and a daily
/// training reminder.
///
/// There's no single Flutter plugin that covers this app's platforms, so
/// the backend is chosen per platform, same pattern as
/// `SecureKeyStore`/`IntervalsSession`'s credential storage:
/// - **Android/iOS** — `flutter_local_notifications`. All three kinds,
///   including the daily reminder, which is scheduled through the OS
///   alarm/notification system so it still fires with the app closed.
/// - **Windows** — `local_notifier` (`flutter_local_notifications` has no
///   Windows backend at all). Immediate notifications only — sync-complete
///   and agent-reply. No daily reminder: there's no OS-level way to wake a
///   *closed* desktop app on a schedule without native work well beyond
///   what a "remind me" toggle warrants, so [supportsScheduledReminder] is
///   `false` here and Settings hides that control.
/// - **Everywhere else (web)** — no-op. The Web Notification permission
///   model doesn't fit this ask and wasn't part of it.
abstract class NotificationService {
  static final NotificationService instance = _create();

  static NotificationService _create() {
    if (kIsWeb) return _NoopNotificationService();
    if (Platform.isAndroid || Platform.isIOS) {
      return _MobileNotificationService();
    }
    if (Platform.isWindows) return _WindowsNotificationService();
    return _NoopNotificationService();
  }

  /// Sets up the backend. Safe to call once at startup; never throws.
  Future<void> init();

  /// Whether [scheduleDailyReminder] does anything on this platform.
  bool get supportsScheduledReminder;

  /// Prompts the OS notification permission dialog (Android 13+, iOS) and
  /// reports whether it was granted. On platforms with no such prompt
  /// (Windows, older Android) there's nothing to grant, so this returns
  /// `true` — the caller shouldn't block on it.
  Future<bool> requestPermission();

  Future<void> showSyncComplete({
    required int activities,
    required int wellness,
  });

  Future<void> showAgentReply(String preview);

  /// Tells the athlete the nightly background sync keeps failing. With
  /// [reconnectNeeded] it is because Intervals.icu rejected the stored key,
  /// which only they can fix.
  Future<void> showSyncProblem({required bool reconnectNeeded});

  Future<void> scheduleDailyReminder(TimeOfDay time);

  Future<void> cancelDailyReminder();

  /// Arms one notification at [at] with already-composed text, replacing
  /// the previous one. The text is a snapshot, so callers re-arm after each
  /// sync.
  Future<void> scheduleBriefing({
    required DateTime at,
    required String title,
    required String body,
  });

  Future<void> cancelBriefing();
}

String _syncProblemBody(bool reconnectNeeded) => reconnectNeeded
    ? 'Intervals.icu rejected your API key. Open TriIQ and reconnect.'
    : 'The nightly sync has failed several times in a row. '
          'Your data is still available offline.';

class _NoopNotificationService implements NotificationService {
  @override
  Future<void> init() async {}

  @override
  bool get supportsScheduledReminder => false;

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> showSyncComplete({
    required int activities,
    required int wellness,
  }) async {}

  @override
  Future<void> showAgentReply(String preview) async {}

  @override
  Future<void> showSyncProblem({required bool reconnectNeeded}) async {}

  @override
  Future<void> scheduleDailyReminder(TimeOfDay time) async {}

  @override
  Future<void> cancelDailyReminder() async {}

  @override
  Future<void> scheduleBriefing({
    required DateTime at,
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> cancelBriefing() async {}
}

class _MobileNotificationService implements NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Notification IDs. The reminder needs a fixed one so re-scheduling
  // replaces rather than stacks; sync/agent use a per-kind id since each
  // replaces its own previous "still there" notification rather than
  // piling up unread ones.
  static const _syncNotificationId = 1;
  static const _agentNotificationId = 2;
  static const _reminderNotificationId = 3;
  static const _syncProblemNotificationId = 4;
  static const _briefingNotificationId = 5;

  static const _syncDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'sync_channel',
      'Sync',
      channelDescription: 'Confirms when a manual sync finishes.',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
    iOS: DarwinNotificationDetails(),
  );

  static const _agentDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'agent_channel',
      'Training agent',
      channelDescription:
          'Lets you know when the training agent finishes a reply.',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
    iOS: DarwinNotificationDetails(),
  );

  static const _reminderDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'reminder_channel',
      'Daily reminder',
      channelDescription: 'Your daily training reminder.',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
    iOS: DarwinNotificationDetails(),
  );

  @override
  bool get supportsScheduledReminder => true;

  @override
  Future<void> init() async {
    if (_initialized) return;
    try {
      tz_data.initializeTimeZones();
      tz.setLocalLocation(_currentOffsetLocation());

      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_launcher_foreground'),
          iOS: DarwinInitializationSettings(
            // Deferred: we ask explicitly (Settings → Notifications), not
            // on first launch.
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      _initialized = true;
    } catch (error) {
      debugPrint('NotificationService: init failed: $error');
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      if (Platform.isAndroid) {
        final granted = await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
        // null means "no prompt needed" (pre-Android 13) — treat as granted.
        return granted ?? true;
      }
      if (Platform.isIOS) {
        final granted = await _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
        return granted ?? false;
      }
      return true;
    } catch (error) {
      debugPrint('NotificationService: permission request failed: $error');
      return false;
    }
  }

  @override
  Future<void> showSyncComplete({
    required int activities,
    required int wellness,
  }) async {
    await _show(
      _syncNotificationId,
      'Sync complete',
      'Synced $activities ${activities == 1 ? 'activity' : 'activities'}, '
          '$wellness wellness ${wellness == 1 ? 'record' : 'records'}.',
      _syncDetails,
    );
  }

  @override
  Future<void> showAgentReply(String preview) async {
    await _show(_agentNotificationId, 'Training agent', preview, _agentDetails);
  }

  @override
  Future<void> showSyncProblem({required bool reconnectNeeded}) async {
    await _show(
      _syncProblemNotificationId,
      'Sync problem',
      _syncProblemBody(reconnectNeeded),
      _syncDetails,
    );
  }

  Future<void> _show(
    int id,
    String title,
    String body,
    NotificationDetails details,
  ) async {
    if (!_initialized) return;
    try {
      await _plugin.show(id: id, title: title, body: body, notificationDetails: details);
    } catch (error) {
      debugPrint('NotificationService: show failed: $error');
    }
  }

  @override
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    if (!_initialized) return;
    try {
      await _plugin.zonedSchedule(
        id: _reminderNotificationId,
        scheduledDate: _nextInstanceOf(time),
        title: 'Training reminder',
        body: "Check today's plan in TriIQ.",
        notificationDetails: _reminderDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (error) {
      debugPrint('NotificationService: scheduling reminder failed: $error');
    }
  }

  @override
  Future<void> cancelDailyReminder() async {
    try {
      await _plugin.cancel(id: _reminderNotificationId);
    } catch (error) {
      debugPrint('NotificationService: cancelling reminder failed: $error');
    }
  }

  static const _briefingDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'briefing_channel',
      'Morning briefing',
      channelDescription: "Today's session, readiness and form.",
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      styleInformation: BigTextStyleInformation(''),
    ),
    iOS: DarwinNotificationDetails(),
  );

  @override
  Future<void> scheduleBriefing({
    required DateTime at,
    required String title,
    required String body,
  }) async {
    if (!_initialized) return;
    try {
      await _plugin.zonedSchedule(
        id: _briefingNotificationId,
        scheduledDate: tz.TZDateTime(
          tz.local,
          at.year,
          at.month,
          at.day,
          at.hour,
          at.minute,
        ),
        title: title,
        body: body,
        notificationDetails: _briefingDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (error) {
      debugPrint('NotificationService: scheduling briefing failed: $error');
    }
  }

  @override
  Future<void> cancelBriefing() async {
    try {
      await _plugin.cancel(id: _briefingNotificationId);
    } catch (error) {
      debugPrint('NotificationService: cancelling briefing failed: $error');
    }
  }

  tz.TZDateTime _nextInstanceOf(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// A `tz.Location` fixed at the device's current UTC offset, standing in
  /// for the real local IANA zone (e.g. `Europe/Berlin`).
  ///
  /// The obvious way to get that name is `flutter_timezone`, but its Android
  /// build currently fails under this project's AGP version (a
  /// project-evaluation-order clash from its Gradle setup, not anything
  /// specific to this app — see the Gradle failure log if revisiting this).
  /// A fixed offset is wrong only in the narrow window right as DST flips —
  /// self-correcting on the next app start — which is a fine trade for a
  /// "remind me around 7am" feature against pulling in a plugin that
  /// doesn't build.
  static tz.Location _currentOffsetLocation() => tz.Location(
    'Local',
    [tz.minTime],
    [0],
    [
      tz.TimeZone(
        DateTime.now().timeZoneOffset,
        isDst: false,
        abbreviation: 'LOCAL',
      ),
    ],
  );
}

class _WindowsNotificationService implements NotificationService {
  bool _initialized = false;

  @override
  bool get supportsScheduledReminder => false;

  @override
  Future<void> init() async {
    if (_initialized) return;
    try {
      await LocalNotifier.instance.setup(appName: 'TriIQ');
      _initialized = true;
    } catch (error) {
      debugPrint('NotificationService: init failed: $error');
    }
  }

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> showSyncComplete({
    required int activities,
    required int wellness,
  }) async {
    await _notify(
      'Sync complete',
      'Synced $activities ${activities == 1 ? 'activity' : 'activities'}, '
          '$wellness wellness ${wellness == 1 ? 'record' : 'records'}.',
    );
  }

  @override
  Future<void> showAgentReply(String preview) async {
    await _notify('Training agent', preview);
  }

  @override
  Future<void> showSyncProblem({required bool reconnectNeeded}) async {
    await _notify('Sync problem', _syncProblemBody(reconnectNeeded));
  }

  Future<void> _notify(String title, String body) async {
    if (!_initialized) return;
    try {
      await LocalNotification(title: title, body: body).show();
    } catch (error) {
      debugPrint('NotificationService: show failed: $error');
    }
  }

  @override
  Future<void> scheduleDailyReminder(TimeOfDay time) async {}

  @override
  Future<void> cancelDailyReminder() async {}

  @override
  Future<void> scheduleBriefing({
    required DateTime at,
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> cancelBriefing() async {}
}
