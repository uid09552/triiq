import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/more/more_screen.dart' show moreEntries;
import '../widgets/main_navigation.dart';

/// Why a move was refused (or that it went through).
enum NavMoveResult {
  ok,

  /// Nothing to do (already there, or an unknown id).
  unchanged,

  /// The bar already holds [NavigationLayout.maxBar] items besides More.
  barFull,

  /// The bar would drop below [NavigationLayout.minBar] items besides More.
  barMinimum,
}

/// What the bottom navigation bar shows, in which order, and the order of
/// everything else on the More tab — the athlete's arrangement, plain
/// `shared_preferences`, same pattern as `TodayLayoutSettings`.
///
/// Every arrangeable id (the core tabs Today, Calendar, Chat, Insights and
/// every available More entry) lives in exactly one of [bar] and [more].
/// More itself is not part of either list: it is always the bar's last
/// item and cannot be moved. The bar holds [minBar]–[maxBar] items besides
/// More.
class NavigationLayout extends ChangeNotifier {
  NavigationLayout._({List<String>? known}) : _knownOverride = known {
    final d = defaultsFor(this.known);
    _bar = d.bar;
    _more = d.more;
  }

  static final NavigationLayout instance = NavigationLayout._();

  /// [known] replaces the catalogue (default: [defaultKnown]).
  @visibleForTesting
  factory NavigationLayout.forTesting({List<String>? known}) =>
      NavigationLayout._(known: known);

  static const barPref = 'nav.bar';
  static const morePref = 'nav.more';

  static const moreId = MainNavigation.moreTab;

  /// The tabs the bar had before it became configurable, in that order.
  static const coreIds = [
    MainNavigation.todayTab,
    MainNavigation.calendarTab,
    MainNavigation.chatTab,
    MainNavigation.insightsTab,
  ];

  /// Items besides More the bar must / may hold: 3–5 slots in all.
  static const minBar = 2;
  static const maxBar = 4;

  /// Every arrangeable id on this platform: the core tabs, then the More
  /// entries in their shipped order (the knowledge library is not on web).
  static List<String> defaultKnown() => [
    ...coreIds,
    for (final e in moreEntries)
      if (e.available) e.id,
  ];

  /// The shipped layout: the core tabs in the bar, More entries in More.
  static ({List<String> bar, List<String> more}) defaultsFor(
    List<String> known,
  ) {
    final bar = [
      for (final id in coreIds)
        if (known.contains(id)) id,
    ].take(maxBar).toList();
    return (
      bar: bar,
      more: [
        for (final id in known)
          if (!bar.contains(id)) id,
      ],
    );
  }

  /// A stored arrangement from any app version as a valid one: unknown and
  /// duplicate ids are dropped (the bar wins a duplicate); ids new in this
  /// version join the bar when they are a core tab and there is room, else
  /// More (core tabs at its top, other entries at its end); a bar over
  /// [maxBar] spills its tail onto More's top, one under [minBar] takes
  /// More's first core tabs, then its first entries. Nothing stored → the
  /// defaults.
  static ({List<String> bar, List<String> more}) normalize(
    List<String>? storedBar,
    List<String>? storedMore,
    List<String> known,
  ) {
    if (storedBar == null && storedMore == null) return defaultsFor(known);
    final seen = <String>{};
    final bar = [
      for (final id in storedBar ?? defaultsFor(known).bar)
        if (id != moreId && known.contains(id) && seen.add(id)) id,
    ];
    final more = [
      for (final id in storedMore ?? const <String>[])
        if (id != moreId && known.contains(id) && seen.add(id)) id,
    ];
    var coreInsert = 0;
    for (final id in known) {
      if (seen.contains(id)) continue;
      if (coreIds.contains(id)) {
        if (bar.length < maxBar) {
          bar.add(id);
        } else {
          more.insert(coreInsert++, id);
        }
      } else {
        more.add(id);
      }
    }
    if (bar.length > maxBar) {
      more.insertAll(0, bar.sublist(maxBar));
      bar.removeRange(maxBar, bar.length);
    }
    while (bar.length < minBar && more.isNotEmpty) {
      final core = more.where(coreIds.contains);
      final pick = core.isNotEmpty ? core.first : more.first;
      more.remove(pick);
      bar.add(pick);
    }
    return (bar: bar, more: more);
  }

  final List<String>? _knownOverride;

  /// Every arrangeable id.
  List<String> get known => _knownOverride ?? defaultKnown();

  late List<String> _bar;
  late List<String> _more;

  /// The bar's items besides More, left to right.
  List<String> get bar => List.unmodifiable(_bar);

  /// What the bar shows: [bar], then More.
  List<String> get barWithMore => List.unmodifiable([..._bar, moreId]);

  /// Everything not in the bar, in More's order.
  List<String> get more => List.unmodifiable(_more);

  /// Whether [id] is a tab right now (More always is).
  bool isInBar(String id) => id == moreId || _bar.contains(id);

  bool get isDefault {
    final d = defaultsFor(known);
    return listEquals(d.bar, _bar) && listEquals(d.more, _more);
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedBar = prefs.getStringList(barPref);
      final storedMore = prefs.getStringList(morePref);
      final n = normalize(storedBar, storedMore, known);
      _bar = n.bar;
      _more = n.more;
      // Only an arrangement the athlete made is saved; a repaired one is
      // saved once so the repair doesn't run on every start.
      if ((storedBar != null || storedMore != null) &&
          (!listEquals(storedBar, n.bar) || !listEquals(storedMore, n.more))) {
        await _persist();
      }
    } catch (error) {
      debugPrint('NavigationLayout: cannot read stored layout: $error');
    }
    notifyListeners();
  }

  /// Puts [id] at [index] of the bar ([inBar]) or of More, from wherever it
  /// is. Refused when the bar would leave [minBar]–[maxBar].
  Future<NavMoveResult> place(
    String id, {
    required bool inBar,
    required int index,
  }) async {
    if (id == moreId || !known.contains(id)) return NavMoveResult.unchanged;
    final bar = List.of(_bar);
    final more = List.of(_more);
    final wasInBar = bar.remove(id);
    if (!wasInBar) more.remove(id);
    final target = inBar ? bar : more;
    if (inBar && !wasInBar && bar.length >= maxBar) {
      return NavMoveResult.barFull;
    }
    if (!inBar && wasInBar && bar.length < minBar) {
      return NavMoveResult.barMinimum;
    }
    target.insert(index.clamp(0, target.length), id);
    if (listEquals(bar, _bar) && listEquals(more, _more)) {
      return NavMoveResult.unchanged;
    }
    _bar = bar;
    _more = more;
    notifyListeners();
    await _persist();
    return NavMoveResult.ok;
  }

  /// Moves [id] one place towards the start ([delta] -1) or end (+1) of its
  /// own list.
  Future<NavMoveResult> shift(String id, int delta) {
    final inBar = _bar.contains(id);
    final list = inBar ? _bar : _more;
    final at = list.indexOf(id);
    if (at < 0) return Future.value(NavMoveResult.unchanged);
    final to = at + delta;
    if (to < 0 || to >= list.length) {
      return Future.value(NavMoveResult.unchanged);
    }
    return place(id, inBar: inBar, index: to);
  }

  /// From the bar to the top of More.
  Future<NavMoveResult> moveToMore(String id) =>
      place(id, inBar: false, index: 0);

  /// From More to the bar's end (just before More).
  Future<NavMoveResult> pinToBar(String id) =>
      place(id, inBar: true, index: _bar.length);

  Future<void> reset() async {
    final d = defaultsFor(known);
    _bar = d.bar;
    _more = d.more;
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(barPref, _bar);
      await prefs.setStringList(morePref, _more);
    } catch (error) {
      debugPrint('NavigationLayout: cannot persist layout: $error');
    }
  }

  /// Rewrites whatever a restored backup put under [barPref] / [morePref]
  /// as a valid arrangement for this version (see [normalize]).
  /// A value of the wrong type is dropped.
  static Future<void> sanitizeStored(SharedPreferences prefs) async {
    List<String>? read(String key) {
      final v = prefs.get(key);
      return v is List ? [for (final x in v) '$x'] : null;
    }

    final storedBar = read(barPref);
    final storedMore = read(morePref);
    if (storedBar == null && storedMore == null) {
      await prefs.remove(barPref);
      await prefs.remove(morePref);
      return;
    }
    final n = normalize(storedBar, storedMore, defaultKnown());
    await prefs.setStringList(barPref, n.bar);
    await prefs.setStringList(morePref, n.more);
  }
}
