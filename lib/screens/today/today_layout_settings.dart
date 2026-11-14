import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The sections on Today that can be reordered or removed. The setup banner,
/// pending changes and sync errors always stay on top.
enum TodaySection {
  /// Status, readiness, today's session(s) with one primary action, and a
  /// tomorrow strip (was: the header, `readiness` and `todaysTraining`).
  hero,

  /// Fatigue warning, plan adjustments, race countdown, threshold
  /// suggestions — only when they have something to say (was:
  /// `adjustments`, `thresholds`).
  attention,

  /// Hours per sport against targets, TSS against plan, sessions, and the
  /// year goals as one line (was: `weeklyTargets`, `yearGoals`).
  thisWeek,

  /// Mon–Sun dots: done / planned / missed / rest.
  weekRibbon,

  metrics,
  activities,
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
  static const _timeOfDayKey = 'today.time_of_day_order';
  static const _allTilesKey = 'today.all_load_tiles';

  /// The lean layout for new installs and "Reset layout": what to do today
  /// first, then the week, then the load tiles. The rest is one switch away
  /// in Customize Today.
  static const defaultOrder = [
    TodaySection.hero,
    TodaySection.attention,
    TodaySection.thisWeek,
    TodaySection.weekRibbon,
    TodaySection.metrics,
    TodaySection.activities,
    TodaySection.tomorrowsTraining,
    TodaySection.athlete,
  ];
  static const defaultHidden = {
    TodaySection.tomorrowsTraining,
    TodaySection.athlete,
  };

  /// Section names of earlier versions, and where they went. Several old
  /// sections merged into one new one; the first of them in the stored order
  /// decides its place.
  static const legacyNames = {
    'readiness': TodaySection.hero,
    'todaysTraining': TodaySection.hero,
    'adjustments': TodaySection.attention,
    'thresholds': TodaySection.attention,
    'weeklyTargets': TodaySection.thisWeek,
    'yearGoals': TodaySection.thisWeek,
  };

  /// The default orders earlier versions saved without the athlete
  /// touching them: the lean default, and every section in enum order.
  static const _legacyDefaultOrders = [
    [
      'readiness',
      'todaysTraining',
      'adjustments',
      'metrics',
      'activities',
      'weeklyTargets',
      'yearGoals',
      'thresholds',
      'tomorrowsTraining',
      'athlete',
    ],
    [
      'readiness',
      'adjustments',
      'metrics',
      'weeklyTargets',
      'yearGoals',
      'thresholds',
      'activities',
      'todaysTraining',
      'tomorrowsTraining',
      'athlete',
    ],
  ];

  /// Old sections whose content partly moved into a second new section, so
  /// that section stays visible when the old one was: the week's TSS against
  /// plan sat in today's training, the fatigue warning in readiness.
  static const _legacyAlsoShows = {
    'todaysTraining': TodaySection.thisWeek,
    'readiness': TodaySection.attention,
  };

  List<TodaySection> _order = List.of(defaultOrder);
  final Set<TodaySection> _hidden = {...defaultHidden};
  final Set<TodaySection> _collapsed = {};
  bool _timeOfDayOrder = false;
  bool _allLoadTiles = false;

  /// Every section, in display order (hidden ones included).
  List<TodaySection> get order => List.unmodifiable(_order);

  bool isVisible(TodaySection section) => !_hidden.contains(section);

  /// Whether the athlete folded [section] to its header.
  bool isCollapsed(TodaySection section) => _collapsed.contains(section);

  /// Opt-in: reorder by time of day (morning: today's session first;
  /// evening: today's result and tomorrow first).
  bool get timeOfDayOrder => _timeOfDayOrder;

  /// Show all six load tiles instead of the compact row of three.
  bool get allLoadTiles => _allLoadTiles;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(_orderKey);
      if (stored != null) {
        final migrated = migrate(stored, prefs.getStringList(_hiddenKey));
        _order = migrated.order;
        _hidden
          ..clear()
          ..addAll(migrated.hidden);
        if (migrated.changed) await _persist();
      } else if (prefs.getKeys().any(
        (k) => !k.startsWith('today.') && !k.startsWith('onboarding.'),
      )) {
        // An existing install that never customized Today: keep every
        // section it has always shown rather than hiding ones the athlete
        // is used to.
        _order = List.of(defaultOrder);
        _hidden.clear();
        await _persist();
      } else {
        _order = List.of(defaultOrder);
        _hidden
          ..clear()
          ..addAll(defaultHidden);
        // Saved right away, so settings chosen later (onboarding, targets)
        // don't make the next start look like an older install.
        await _persist();
      }
      _collapsed
        ..clear()
        ..addAll(_parse(prefs.getStringList(_collapsedKey)));
      _timeOfDayOrder = prefs.getBool(_timeOfDayKey) ?? false;
      _allLoadTiles = prefs.getBool(_allTilesKey) ?? false;
    } catch (error) {
      debugPrint('TodayLayoutSettings: cannot read stored layout: $error');
    }
    notifyListeners();
  }

  /// A stored order and hidden list, from any app version, as today's
  /// sections. Old sections map onto the ones they merged into (first one
  /// wins the place); a merged section is visible when any of its old ones
  /// was. Sections new in this version go to their default place relative
  /// to the sections before them in [defaultOrder]. [changed] says whether
  /// anything needed migrating (so it is saved once).
  @visibleForTesting
  static ({List<TodaySection> order, Set<TodaySection> hidden, bool changed})
  migrate(List<String> storedOrder, List<String>? storedHidden) {
    var changed = false;
    TodaySection? resolve(String name) {
      for (final s in TodaySection.values) {
        if (s.name == name) return s;
      }
      final legacy = legacyNames[name];
      if (legacy != null) changed = true;
      return legacy;
    }

    final order = <TodaySection>[];
    for (final name in storedOrder) {
      final s = resolve(name);
      if (s != null && !order.contains(s)) order.add(s);
    }
    // An order the athlete never changed (an earlier version's default)
    // takes this version's default order; only visibility carries over.
    if (_legacyDefaultOrders.any((o) => listEquals(o, storedOrder))) {
      order
        ..clear()
        ..addAll(defaultOrder);
      changed = true;
    }

    // Visibility: a section is shown when any stored name that maps to it
    // was shown. A name absent from the hidden list counts as shown.
    final hiddenNames = (storedHidden ?? const <String>[]).toSet();
    final shown = <TodaySection>{};
    final seen = <TodaySection>{};
    for (final name in storedOrder) {
      final s = resolve(name);
      if (s == null) continue;
      seen.add(s);
      if (!hiddenNames.contains(name)) {
        shown.add(s);
        if (_legacyAlsoShows[name] case final also?) shown.add(also);
      }
    }
    final hidden = {
      for (final s in seen)
        if (!shown.contains(s)) s,
    };

    // Sections this version added: after the default-order section that
    // precedes them and is already placed, or first.
    for (final s in defaultOrder) {
      if (order.contains(s)) continue;
      changed = true;
      final at = defaultOrder.indexOf(s);
      var insertAt = 0;
      for (var i = at - 1; i >= 0; i--) {
        final index = order.indexOf(defaultOrder[i]);
        if (index >= 0) {
          insertAt = index + 1;
          break;
        }
      }
      // New sections start visible.
      order.insert(insertAt, s);
    }
    return (order: order, hidden: hidden, changed: changed);
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

  Future<void> setTimeOfDayOrder(bool value) async {
    if (value == _timeOfDayOrder) return;
    _timeOfDayOrder = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setAllLoadTiles(bool value) async {
    if (value == _allLoadTiles) return;
    _allLoadTiles = value;
    notifyListeners();
    await _persist();
  }

  Future<void> reset() async {
    _order = List.of(defaultOrder);
    _hidden
      ..clear()
      ..addAll(defaultHidden);
    _collapsed.clear();
    _timeOfDayOrder = false;
    _allLoadTiles = false;
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
      await prefs.setBool(_timeOfDayKey, _timeOfDayOrder);
      await prefs.setBool(_allTilesKey, _allLoadTiles);
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
}

/// With [TodayLayoutSettings.timeOfDayOrder] on: in the morning the hero
/// (readiness and today's session) and what needs attention lead; in the
/// evening the hero (by then today's result), tomorrow and today's
/// activities. Around midday — or with the option off — [visible] as is.
List<TodaySection> contextualTodayOrder(
  List<TodaySection> visible,
  DateTime now, {
  required bool enabled,
}) {
  if (!enabled) return visible;
  final List<TodaySection> front;
  if (now.hour < 12) {
    front = const [TodaySection.hero, TodaySection.attention];
  } else if (now.hour >= 17) {
    front = const [
      TodaySection.hero,
      TodaySection.tomorrowsTraining,
      TodaySection.activities,
    ];
  } else {
    return visible;
  }
  return [
    for (final s in front)
      if (visible.contains(s)) s,
    for (final s in visible)
      if (!front.contains(s)) s,
  ];
}
