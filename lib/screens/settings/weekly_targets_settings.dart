import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Personal weekly training-time targets for swim/cycle/run, and whether
/// their progress rings show on Today — independent of any training plan.
/// Nothing secret, so this is ordinary `shared_preferences`, same pattern as
/// [NotificationSettings](../../notifications/notification_settings.dart).
class WeeklyTargetsSettings extends ChangeNotifier {
  WeeklyTargetsSettings._();

  static final WeeklyTargetsSettings instance = WeeklyTargetsSettings._();

  @visibleForTesting
  factory WeeklyTargetsSettings.forTesting() = WeeklyTargetsSettings._;

  static const _swimHoursKey = 'targets.swim_hours';
  static const _cycleHoursKey = 'targets.cycle_hours';
  static const _runHoursKey = 'targets.run_hours';
  static const _showOnTodayKey = 'targets.show_on_today';

  /// Weekly target in hours per sport; `null` means no target set. A value
  /// at or below 0 normalizes to `null` — "0 hours" isn't a target, it's
  /// the same as not setting one.
  double? swimHours;
  double? cycleHours;
  double? runHours;
  bool showOnToday = true;
  bool isLoaded = false;

  bool get hasAnyTarget =>
      swimHours != null || cycleHours != null || runHours != null;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      swimHours = _normalize(prefs.getDouble(_swimHoursKey));
      cycleHours = _normalize(prefs.getDouble(_cycleHoursKey));
      runHours = _normalize(prefs.getDouble(_runHoursKey));
      showOnToday = prefs.getBool(_showOnTodayKey) ?? true;
    } catch (error) {
      debugPrint('WeeklyTargetsSettings: cannot read stored settings: $error');
    } finally {
      isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> setSwimHours(double? hours) async {
    swimHours = _normalize(hours);
    notifyListeners();
    await _writeHours(_swimHoursKey, swimHours);
  }

  Future<void> setCycleHours(double? hours) async {
    cycleHours = _normalize(hours);
    notifyListeners();
    await _writeHours(_cycleHoursKey, cycleHours);
  }

  Future<void> setRunHours(double? hours) async {
    runHours = _normalize(hours);
    notifyListeners();
    await _writeHours(_runHoursKey, runHours);
  }

  Future<void> setShowOnToday(bool value) async {
    if (value == showOnToday) return;
    showOnToday = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_showOnTodayKey, value);
    } catch (error) {
      debugPrint(
        'WeeklyTargetsSettings: cannot persist "$_showOnTodayKey": $error',
      );
    }
  }

  Future<void> _writeHours(String key, double? hours) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (hours == null) {
        await prefs.remove(key);
      } else {
        await prefs.setDouble(key, hours);
      }
    } catch (error) {
      debugPrint('WeeklyTargetsSettings: cannot persist "$key": $error');
    }
  }

  static double? _normalize(double? hours) =>
      (hours == null || hours <= 0) ? null : hours;
}
