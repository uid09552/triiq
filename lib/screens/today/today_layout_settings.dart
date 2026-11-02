import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The sections on Today that can be reordered or removed. The hero, the
/// "Train now" button, the setup banner and sync errors always stay on top.
enum TodaySection {
  readiness,
  adjustments,
  metrics,
  weeklyTargets,
  thresholds,
  activities,
  todaysTraining,
  tomorrowsTraining,
  athlete,
}

/// Order and visibility of [TodaySection]s on Today — a personal layout,
/// plain `shared_preferences`, same pattern as `WeeklyTargetsSettings`.
class TodayLayoutSettings extends ChangeNotifier {
  TodayLayoutSettings._();

  static final TodayLayoutSettings instance = TodayLayoutSettings._();

  @visibleForTesting
  factory TodayLayoutSettings.forTesting() = TodayLayoutSettings._;

  static const _orderKey = 'today.section_order';
  static const _hiddenKey = 'today.hidden_sections';

  List<TodaySection> _order = List.of(TodaySection.values);
  final Set<TodaySection> _hidden = {};

  /// Every section, in display order (hidden ones included).
  List<TodaySection> get order => List.unmodifiable(_order);

  bool isVisible(TodaySection section) => !_hidden.contains(section);

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _order = _normalize(prefs.getStringList(_orderKey));
      _hidden
        ..clear()
        ..addAll(_parse(prefs.getStringList(_hiddenKey)));
    } catch (error) {
      debugPrint('TodayLayoutSettings: cannot read stored layout: $error');
    }
    notifyListeners();
  }

  Future<void> move(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final next = List.of(_order);
    next.insert(newIndex, next.removeAt(oldIndex));
    _order = next;
    notifyListeners();
    await _persist();
  }

  Future<void> setVisible(TodaySection section, bool visible) async {
    if (visible == isVisible(section)) return;
    visible ? _hidden.remove(section) : _hidden.add(section);
    notifyListeners();
    await _persist();
  }

  Future<void> reset() async {
    _order = List.of(TodaySection.values);
    _hidden.clear();
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_orderKey, [for (final s in _order) s.name]);
      await prefs.setStringList(_hiddenKey, [for (final s in _hidden) s.name]);
    } catch (error) {
      debugPrint('TodayLayoutSettings: cannot persist layout: $error');
    }
  }

  static Iterable<TodaySection> _parse(List<String>? names) sync* {
    for (final name in names ?? const <String>[]) {
      for (final s in TodaySection.values) {
        if (s.name == name) yield s;
      }
    }
  }

  /// Stored order first, then any section added by a later app version.
  static List<TodaySection> _normalize(List<String>? names) {
    final result = _parse(names).toSet().toList();
    for (final s in TodaySection.values) {
      if (!result.contains(s)) result.add(s);
    }
    return result;
  }
}
