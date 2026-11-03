import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Personal yearly distance goals (km) for swim/cycle/run, and whether their
/// progress card shows on Today. Plain `shared_preferences`, same pattern as
/// `WeeklyTargetsSettings`.
class YearGoalsSettings extends ChangeNotifier {
  YearGoalsSettings._();

  static final YearGoalsSettings instance = YearGoalsSettings._();

  @visibleForTesting
  factory YearGoalsSettings.forTesting() = YearGoalsSettings._;

  static const _swimKey = 'yeargoals.swim_km';
  static const _cycleKey = 'yeargoals.cycle_km';
  static const _runKey = 'yeargoals.run_km';
  static const _showOnTodayKey = 'yeargoals.show_on_today';

  /// Yearly distance goal in km per sport; `null` means no goal. A value at
  /// or below 0 normalizes to `null`.
  double? swimKm;
  double? cycleKm;
  double? runKm;
  bool showOnToday = true;
  bool isLoaded = false;

  bool get hasAnyGoal => swimKm != null || cycleKm != null || runKm != null;

  /// Goal for a canonical sport (`swim`, `cycle`, `run`).
  double? goalFor(String sport) => switch (sport) {
    'swim' => swimKm,
    'cycle' => cycleKm,
    'run' => runKm,
    _ => null,
  };

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      swimKm = _normalize(prefs.getDouble(_swimKey));
      cycleKm = _normalize(prefs.getDouble(_cycleKey));
      runKm = _normalize(prefs.getDouble(_runKey));
      showOnToday = prefs.getBool(_showOnTodayKey) ?? true;
    } catch (error) {
      debugPrint('YearGoalsSettings: cannot read stored settings: $error');
    } finally {
      isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> setSwimKm(double? km) async {
    swimKm = _normalize(km);
    notifyListeners();
    await _write(_swimKey, swimKm);
  }

  Future<void> setCycleKm(double? km) async {
    cycleKm = _normalize(km);
    notifyListeners();
    await _write(_cycleKey, cycleKm);
  }

  Future<void> setRunKm(double? km) async {
    runKm = _normalize(km);
    notifyListeners();
    await _write(_runKey, runKm);
  }

  Future<void> setShowOnToday(bool value) async {
    if (value == showOnToday) return;
    showOnToday = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_showOnTodayKey, value);
    } catch (error) {
      debugPrint('YearGoalsSettings: cannot persist show_on_today: $error');
    }
  }

  Future<void> _write(String key, double? km) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (km == null) {
        await prefs.remove(key);
      } else {
        await prefs.setDouble(key, km);
      }
    } catch (error) {
      debugPrint('YearGoalsSettings: cannot persist "$key": $error');
    }
  }

  static double? _normalize(double? km) => (km == null || km <= 0) ? null : km;
}
