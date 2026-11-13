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
  static const _briefingEnabledKey = 'notifications.morning_briefing';
  static const _briefingHourKey = 'notifications.morning_briefing_hour';
  static const _briefingMinuteKey = 'notifications.morning_briefing_minute';
  static const _weeklyReviewEnabledKey = 'notifications.weekly_review';
  static const _weeklyReviewWeekdayKey = 'notifications.weekly_review_weekday';
  static const _weeklyReviewHourKey = 'notifications.weekly_review_hour';
  static const _weeklyReviewMinuteKey = 'notifications.weekly_review_minute';
  static const _weeklyReviewCommentKey = 'notifications.weekly_review_comment';

  static const defaultReminderTime = TimeOfDay(hour: 7, minute: 0);
  static const defaultWeeklyReviewTime = TimeOfDay(hour: 19, minute: 0);

  /// [DateTime.sunday].
  static const defaultWeeklyReviewWeekday = DateTime.sunday;

  /// Master switch: sync-complete and agent-reply notifications, and a
  /// prerequisite for the daily reminder. Only meaningful once the OS
  /// permission has also been granted — see `NotificationService.requestPermission`.
  bool enabled = false;
  bool dailyReminderEnabled = false;

  /// Whether opening the app shows today's new sessions with their
  /// analysis. On by default; independent of OS notifications.
  bool insightsPopupEnabled = true;
  TimeOfDay dailyReminderTime = defaultReminderTime;

  /// A morning notification with today's session, readiness and form,
  /// composed from the cache and re-armed after each sync.
  bool morningBriefingEnabled = false;
  TimeOfDay morningBriefingTime = defaultReminderTime;

  /// A weekly notification reviewing the week against its plan, composed
  /// from the cache like the morning briefing. Off by default.
  bool weeklyReviewEnabled = false;

  /// [DateTime.monday]..[DateTime.sunday].
  int weeklyReviewWeekday = defaultWeeklyReviewWeekday;
  TimeOfDay weeklyReviewTime = defaultWeeklyReviewTime;

  /// Adds one sentence from the configured LLM provider. Off by default.
  bool weeklyReviewTrainerComment = false;
  bool isLoaded = false;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      enabled = prefs.getBool(_enabledKey) ?? false;
      dailyReminderEnabled = prefs.getBool(_dailyReminderEnabledKey) ?? false;
      insightsPopupEnabled = prefs.getBool(_insightsPopupKey) ?? true;
      morningBriefingEnabled = prefs.getBool(_briefingEnabledKey) ?? false;
      morningBriefingTime = TimeOfDay(
        hour: prefs.getInt(_briefingHourKey) ?? defaultReminderTime.hour,
        minute: prefs.getInt(_briefingMinuteKey) ?? defaultReminderTime.minute,
      );
      weeklyReviewEnabled = prefs.getBool(_weeklyReviewEnabledKey) ?? false;
      final weekday = prefs.getInt(_weeklyReviewWeekdayKey);
      weeklyReviewWeekday =
          weekday != null &&
              weekday >= DateTime.monday &&
              weekday <= DateTime.sunday
          ? weekday
          : defaultWeeklyReviewWeekday;
      weeklyReviewTime = TimeOfDay(
        hour:
            prefs.getInt(_weeklyReviewHourKey) ?? defaultWeeklyReviewTime.hour,
        minute:
            prefs.getInt(_weeklyReviewMinuteKey) ??
            defaultWeeklyReviewTime.minute,
      );
      weeklyReviewTrainerComment =
          prefs.getBool(_weeklyReviewCommentKey) ?? false;
      dailyReminderTime = TimeOfDay(
        hour: prefs.getInt(_dailyReminderHourKey) ?? defaultReminderTime.hour,
        minute:
            prefs.getInt(_dailyReminderMinuteKey) ?? defaultReminderTime.minute,
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

  Future<void> setMorningBriefingEnabled(bool value) async {
    if (value == morningBriefingEnabled) return;
    morningBriefingEnabled = value;
    notifyListeners();
    await _writeBool(_briefingEnabledKey, value);
  }

  Future<void> setMorningBriefingTime(TimeOfDay time) async {
    if (time == morningBriefingTime) return;
    morningBriefingTime = time;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_briefingHourKey, time.hour);
      await prefs.setInt(_briefingMinuteKey, time.minute);
    } catch (error) {
      debugPrint('NotificationSettings: cannot persist briefing time: $error');
    }
  }

  Future<void> setWeeklyReviewEnabled(bool value) async {
    if (value == weeklyReviewEnabled) return;
    weeklyReviewEnabled = value;
    notifyListeners();
    await _writeBool(_weeklyReviewEnabledKey, value);
  }

  Future<void> setWeeklyReviewWeekday(int weekday) async {
    if (weekday == weeklyReviewWeekday ||
        weekday < DateTime.monday ||
        weekday > DateTime.sunday) {
      return;
    }
    weeklyReviewWeekday = weekday;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_weeklyReviewWeekdayKey, weekday);
    } catch (error) {
      debugPrint('NotificationSettings: cannot persist review day: $error');
    }
  }

  Future<void> setWeeklyReviewTime(TimeOfDay time) async {
    if (time == weeklyReviewTime) return;
    weeklyReviewTime = time;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_weeklyReviewHourKey, time.hour);
      await prefs.setInt(_weeklyReviewMinuteKey, time.minute);
    } catch (error) {
      debugPrint('NotificationSettings: cannot persist review time: $error');
    }
  }

  Future<void> setWeeklyReviewTrainerComment(bool value) async {
    if (value == weeklyReviewTrainerComment) return;
    weeklyReviewTrainerComment = value;
    notifyListeners();
    await _writeBool(_weeklyReviewCommentKey, value);
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
