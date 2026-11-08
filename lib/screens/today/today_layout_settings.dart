import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The sections on Today that can be reordered or removed. The hero, the
/// "Train now" button, the setup banner and sync errors always stay on top.
enum TodaySection {
  readiness,
  adjustments,
  metrics,
  weeklyTargets,
  yearGoals,
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
  static const _collapsedKey = 'today.collapsed_sections';

  /// The lean layout for new installs and "Reset layout": what to do today
  /// first, then the load tiles. The rest is one switch away in Customize
  /// Today.
  static const defaultOrder = [
    TodaySection.readiness,
    TodaySection.todaysTraining,
    TodaySection.adjustments,
    TodaySection.metrics,
    TodaySection.activities,
    TodaySection.weeklyTargets,
    TodaySection.yearGoals,
    TodaySection.thresholds,
    TodaySection.tomorrowsTraining,
    TodaySection.athlete,
  ];
  static const defaultHidden = {
    TodaySection.weeklyTargets,
    TodaySection.yearGoals,
    TodaySection.thresholds,
    TodaySection.tomorrowsTraining,
    TodaySection.athlete,
  };

  List<TodaySection> _order = List.of(defaultOrder);
  final Set<TodaySection> _hidden = {...defaultHidden};
  final Set<TodaySection> _collapsed = {};

  /// Every section, in display order (hidden ones included).
  List<TodaySection> get order => List.unmodifiable(_order);

  bool isVisible(TodaySection section) => !_hidden.contains(section);

  /// Whether the athlete folded [section] to its header.
  bool isCollapsed(TodaySection section) => _collapsed.contains(section);

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(_orderKey);
      if (stored != null) {
        _order = _normalize(stored);
        _hidden
          ..clear()
          ..addAll(_parse(prefs.getStringList(_hiddenKey)));
      } else if (prefs.getKeys().any((k) => !k.startsWith('today.'))) {
        // An existing install that never customized Today: keep the layout
        // it has always shown (every section, original order) rather than
        // hiding sections the athlete is used to.
        _order = List.of(TodaySection.values);
        _hidden.clear();
        await _persist();
      } else {
        _order = List.of(defaultOrder);
        _hidden
          ..clear()
          ..addAll(defaultHidden);
      }
      _collapsed
        ..clear()
        ..addAll(_parse(prefs.getStringList(_collapsedKey)));
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

  Future<void> setCollapsed(TodaySection section, bool collapsed) async {
    if (collapsed == isCollapsed(section)) return;
    collapsed ? _collapsed.add(section) : _collapsed.remove(section);
    notifyListeners();
    await _persist();
  }

  Future<void> reset() async {
    _order = List.of(defaultOrder);
    _hidden
      ..clear()
      ..addAll(defaultHidden);
    _collapsed.clear();
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_orderKey, [for (final s in _order) s.name]);
      await prefs.setStringList(_hiddenKey, [for (final s in _hidden) s.name]);
      await prefs.setStringList(_collapsedKey, [
        for (final s in _collapsed) s.name,
      ]);
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
  static List<TodaySection> _normalize(List<String> names) {
    final result = _parse(names).toSet().toList();
    for (final s in TodaySection.values) {
      if (!result.contains(s)) result.add(s);
    }
    return result;
  }
}
