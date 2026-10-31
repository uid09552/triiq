import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:shared_preferences/shared_preferences.dart';

/// The user's notification preferences — nothing secret, so this is
/// ordinary `shared_preferences`, same as the non-key parts of
/// [LlmSettings](../agent/llm_settings.dart).
class NotificationSettings extends ChangeNotifier {
  NotificationSettings._();

  static final NotificationSettings instance = NotificationSettings._();

  @visibleForTesting
  factory NotificationSettings.forTesting() = NotificationSettings._;

  static const _enabledKey = 'notifications.enabled';
  static const _dailyReminderEnabledKey = 'notifications.daily_reminder';
  static const _dailyReminderHourKey = 'notifications.daily_reminder_hour';
  static const _dailyReminderMinuteKey = 'notifications.daily_reminder_minute';
  static const _insightsPopupKey = 'insights.popup_enabled';

  static const defaultReminderTime = TimeOfDay(hour: 7, minute: 0);

  /// Master switch: sync-complete and agent-reply notifications, and a
  /// prerequisite for the daily reminder. Only meaningful once the OS
  /// permission has also been granted — see `NotificationService.requestPermission`.
  bool enabled = false;
  bool dailyReminderEnabled = false;

  /// Whether opening the app shows today's new sessions with their
  /// analysis. On by default; independent of OS notifications.
  bool insightsPopupEnabled = true;
  TimeOfDay dailyReminderTime = defaultReminderTime;
  bool isLoaded = false;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      enabled = prefs.getBool(_enabledKey) ?? false;
      dailyReminderEnabled = prefs.getBool(_dailyReminderEnabledKey) ?? false;
      insightsPopupEnabled = prefs.getBool(_insightsPopupKey) ?? true;
      dailyReminderTime = TimeOfDay(
        hour: prefs.getInt(_dailyReminderHourKey) ?? defaultReminderTime.hour,
        minute:
            prefs.getInt(_dailyReminderMinuteKey) ??
            defaultReminderTime.minute,
      );
    } catch (error) {
      debugPrint('NotificationSettings: cannot read stored settings: $error');
    } finally {
      isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> setEnabled(bool value) async {
    if (value == enabled) return;
    enabled = value;
    notifyListeners();
    await _writeBool(_enabledKey, value);
  }

  Future<void> setInsightsPopupEnabled(bool value) async {
    if (value == insightsPopupEnabled) return;
    insightsPopupEnabled = value;
    notifyListeners();
    await _writeBool(_insightsPopupKey, value);
  }

  Future<void> setDailyReminderEnabled(bool value) async {
    if (value == dailyReminderEnabled) return;
    dailyReminderEnabled = value;
    notifyListeners();
    await _writeBool(_dailyReminderEnabledKey, value);
  }

  Future<void> setDailyReminderTime(TimeOfDay time) async {
    if (time == dailyReminderTime) return;
    dailyReminderTime = time;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_dailyReminderHourKey, time.hour);
      await prefs.setInt(_dailyReminderMinuteKey, time.minute);
    } catch (error) {
      debugPrint('NotificationSettings: cannot persist reminder time: $error');
    }
  }

  Future<void> _writeBool(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (error) {
      debugPrint('NotificationSettings: cannot persist "$key": $error');
    }
  }
}
