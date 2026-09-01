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

  static const defaultAutoSyncIntervalMinutes = 5;
  static const minAutoSyncIntervalMinutes = 1;
  static const maxAutoSyncIntervalMinutes = 60;

  /// The choices offered in Settings.
  static const autoSyncIntervalOptions = [1, 5, 15, 30, 60];

  int autoSyncIntervalMinutes = defaultAutoSyncIntervalMinutes;
  bool isLoaded = false;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
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
}
