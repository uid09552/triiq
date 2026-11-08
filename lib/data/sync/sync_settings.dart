import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// How often the app is allowed to auto-sync the current month from
/// Intervals.icu while it's open — nothing secret, so plain
/// `shared_preferences`, same shape as [NotificationSettings](../../notifications/notification_settings.dart).
class SyncSettings extends ChangeNotifier {
  SyncSettings._();

  static final SyncSettings instance = SyncSettings._();

  @visibleForTesting
  factory SyncSettings.forTesting() = SyncSettings._;

  static const _autoSyncIntervalKey = 'sync.auto_interval_minutes';
  static const _backgroundEnabledKey = 'sync.background_enabled';
  static const _backgroundLastRunKey = 'sync.background_last_run';
  static const _backgroundLastResultKey = 'sync.background_last_result';
  static const _backgroundFailuresKey = 'sync.background_failures';
  static const _sendPlanKey = 'calendar.send_plan_to_intervals';
  static const _copyEventsKey = 'calendar.copy_intervals_events';

  static const defaultAutoSyncIntervalMinutes = 5;
  static const minAutoSyncIntervalMinutes = 1;
  static const maxAutoSyncIntervalMinutes = 60;

  /// The choices offered in Settings.
  static const autoSyncIntervalOptions = [1, 5, 15, 30, 60];

  int autoSyncIntervalMinutes = defaultAutoSyncIntervalMinutes;
  bool isLoaded = false;

  /// Whether the nightly background sync is on (Android only; the control is
  /// hidden elsewhere). On by default — it only ever runs once connected.
  bool backgroundSyncEnabled = true;

  /// When the last background run finished, and how it went (a
  /// `BackgroundSyncOutcome.name`). Written from the background isolate.
  DateTime? backgroundLastRunAt;
  String? backgroundLastResult;

  /// Consecutive background runs that failed; reset by a success.
  int backgroundFailures = 0;

  /// Whether a taken plan's sessions are also created in Intervals.icu.
  /// Off keeps plans in TriIQ only.
  bool sendPlanToIntervals = true;

  /// Whether sync fetches Intervals.icu's planned events into TriIQ. Off
  /// hides cached events (they stay in the database) and skips the request.
  bool copyIntervalsEvents = true;

  /// [copyIntervalsEvents] straight from storage, for code that runs without
  /// the loaded singleton (the background isolate's sync).
  static Future<bool> readCopyIntervalsEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_copyEventsKey) ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // The background isolate writes these from its own copy of the
      // preferences cache, so re-read from disk before trusting ours.
      await prefs.reload();
      backgroundSyncEnabled = prefs.getBool(_backgroundEnabledKey) ?? true;
      sendPlanToIntervals = prefs.getBool(_sendPlanKey) ?? true;
      copyIntervalsEvents = prefs.getBool(_copyEventsKey) ?? true;
      final lastRun = prefs.getInt(_backgroundLastRunKey);
      backgroundLastRunAt = lastRun == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lastRun);
      backgroundLastResult = prefs.getString(_backgroundLastResultKey);
      backgroundFailures = prefs.getInt(_backgroundFailuresKey) ?? 0;
      autoSyncIntervalMinutes =
          (prefs.getInt(_autoSyncIntervalKey) ?? defaultAutoSyncIntervalMinutes)
              .clamp(minAutoSyncIntervalMinutes, maxAutoSyncIntervalMinutes);
    } catch (error) {
      debugPrint('SyncSettings: cannot read stored settings: $error');
    } finally {
      isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> setAutoSyncIntervalMinutes(int minutes) async {
    final clamped = minutes.clamp(
      minAutoSyncIntervalMinutes,
      maxAutoSyncIntervalMinutes,
    );
    if (clamped == autoSyncIntervalMinutes) return;
    autoSyncIntervalMinutes = clamped;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_autoSyncIntervalKey, clamped);
    } catch (error) {
      debugPrint('SyncSettings: cannot persist auto-sync interval: $error');
    }
  }

  Future<void> setBackgroundSyncEnabled(bool enabled) async {
    if (enabled == backgroundSyncEnabled) return;
    backgroundSyncEnabled = enabled;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_backgroundEnabledKey, enabled);
    } catch (error) {
      debugPrint('SyncSettings: cannot persist background sync flag: $error');
    }
  }

  Future<void> setSendPlanToIntervals(bool enabled) =>
      _setFlag(enabled, sendPlanToIntervals, _sendPlanKey, (v) {
        sendPlanToIntervals = v;
      });

  Future<void> setCopyIntervalsEvents(bool enabled) =>
      _setFlag(enabled, copyIntervalsEvents, _copyEventsKey, (v) {
        copyIntervalsEvents = v;
      });

  Future<void> _setFlag(
    bool value,
    bool current,
    String key,
    void Function(bool) assign,
  ) async {
    if (value == current) return;
    assign(value);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (error) {
      debugPrint('SyncSettings: cannot persist $key: $error');
    }
  }

  /// Records the outcome of a background run. [failed] counts toward
  /// [backgroundFailures]; anything else resets it.
  Future<void> recordBackgroundRun(
    String result, {
    required bool failed,
  }) async {
    backgroundLastRunAt = DateTime.now();
    backgroundLastResult = result;
    backgroundFailures = failed ? backgroundFailures + 1 : 0;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        _backgroundLastRunKey,
        backgroundLastRunAt!.millisecondsSinceEpoch,
      );
      await prefs.setString(_backgroundLastResultKey, result);
      await prefs.setInt(_backgroundFailuresKey, backgroundFailures);
    } catch (error) {
      debugPrint('SyncSettings: cannot persist background run: $error');
    }
  }
}
