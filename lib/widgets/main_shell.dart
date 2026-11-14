import 'package:flutter/material.dart';

import '../data/sync/auto_sync_service.dart';
import '../l10n/app_localizations.dart';
import '../navigation/nav_items.dart';
import '../navigation/navigation_layout.dart';
import '../navigation/shell_tab.dart';
import '../onboarding/onboarding_screen.dart';
import '../onboarding/onboarding_settings.dart';
import '../screens/insights/new_training_trigger.dart';
import '../screens/more/customize_navigation_sheet.dart';
import 'main_navigation.dart';

/// From this width the bottom bar gives way to a navigation rail.
const railBreakpoint = 840.0;

/// From this width the rail shows its labels beside the icons.
const extendedRailBreakpoint = 1200.0;

/// App shell: top bar with the profile/settings entry point on the right,
/// bottom navigation on phones, a navigation rail on wide windows (Windows,
/// tablets). What the bar holds and in which order is the athlete's
/// [NavigationLayout]; More is always last.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.layout});

  /// Test seam (default: [NavigationLayout.instance]).
  final NavigationLayout? layout;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late final NavigationLayout _layout =
      widget.layout ?? NavigationLayout.instance;

  /// The selected item, by id — it follows the item when the bar is
  /// reordered.
  late String _selected = _layout.barWithMore.first;

  /// Whether the athlete (or a screen) chose a tab yet. Until then the app
  /// sits on the bar's first item, also once a stored layout has loaded.
  bool _navigated = false;

  /// Tabs built so far: each is built the first time it is shown, then
  /// kept alive by the `IndexedStack`.
  final _built = <String>{};

  final _navigation = MainNavigation.instance;

  @override
  void initState() {
    super.initState();
    _navigation.addListener(_onNavigate);
    _layout.addListener(_onLayout);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeOnboard());
  }

  /// A fresh install starts with the first-run flow, once.
  Future<void> _maybeOnboard() async {
    if (!await OnboardingSettings.instance.shouldShow() || !mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => const OnboardingScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _navigation.removeListener(_onNavigate);
    _layout.removeListener(_onLayout);
    super.dispose();
  }

  /// The bar changed. The selection stays on its item; an item moved out
  /// of the bar hands the selection to More, where it now lives.
  void _onLayout() {
    setState(() {
      if (!_navigated) {
        _selected = _layout.barWithMore.first;
      } else if (!_layout.isInBar(_selected)) {
        _selected = NavigationLayout.moreId;
      }
      _built.removeWhere((id) => !_layout.isInBar(id));
    });
  }

  /// Another screen asked for a destination (e.g. Take as plan →
  /// Calendar): its tab when it is in the bar, else its page on top.
  void _onNavigate() {
    final id = _navigation.requestedTab;
    if (id == null) return;
    if (_layout.isInBar(id)) {
      _navigated = true;
      if (id != _selected) setState(() => _selected = id);
    } else if (navItems.any((i) => i.id == id)) {
      Navigator.of(context)
        ..popUntil((route) => route.isFirst)
        ..push(navItem(id).route());
    }
  }

  void _select(List<String> items, int i) {
    _navigated = true;
    setState(() => _selected = items[i]);
  }

  void _customize() => showCustomizeNavigationSheet(context, _layout);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final items = _layout.barWithMore;
    var index = items.indexOf(_selected);
    if (index < 0) {
      index = items.length - 1;
      _selected = items[index];
    }
    _built.add(_selected);
    final selected = navItem(_selected);

    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= railBreakpoint;
    final extended = width >= extendedRailBreakpoint;
    final stack = IndexedStack(
      index: index,
      children: [
        for (final id in items)
          KeyedSubtree(
            key: ValueKey('tab-$id'),
            child: _built.contains(id)
                ? Builder(
                    builder: (context) => navItem(id).tabBody(
                      context,
                      active: id == _selected,
                      layout: _layout,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
      ],
    );
    final customizeHint = l10n.navCustomizeTitle;

    // Today's new sessions pop up after the open-time sync.
    return NewTrainingTrigger(
      openSyncDone: AutoSyncService.instance.openSyncDone,
      child: Scaffold(
        // A pinned More entry brings its own top bar (see ShellTabScope).
        appBar: selected.isCore
            ? AppBar(
                title: Text(selected.title(l10n)),
                actions: [
                  if (selected.id == NavigationLayout.moreId)
                    IconButton(
                      key: const ValueKey('customize-nav-button'),
                      tooltip: l10n.navCustomizeTitle,
                      icon: const Icon(Icons.swap_vert),
                      onPressed: _customize,
                    ),
                  const ProfileButton(),
                  const SizedBox(width: 12),
                ],
              )
            : null,
        body: wide
            ? Row(
                children: [
                  SafeArea(
                    right: false,
                    child: Semantics(
                      container: true,
                      onLongPressHint: customizeHint,
                      onLongPress: _customize,
                      child: GestureDetector(
                        excludeFromSemantics: true,
                        onLongPress: _customize,
                        child: NavigationRail(
                          key: const ValueKey('nav-rail'),
                          selectedIndex: index,
                          extended: extended,
                          labelType: extended
                              ? NavigationRailLabelType.none
                              : NavigationRailLabelType.all,
                          onDestinationSelected: (i) => _select(items, i),
                          destinations: [
                            for (final id in items)
                              NavigationRailDestination(
                                icon: Icon(navItem(id).icon),
                                selectedIcon: Icon(navItem(id).selectedIcon),
                                label: Text(navItem(id).label(l10n)),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: stack),
                ],
              )
            : stack,
        bottomNavigationBar: wide
            ? null
            : DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  // Long-press anywhere on the bar arranges it; screen
                  // readers get the same as the bar's long-press action.
                  child: Semantics(
                    container: true,
                    onLongPressHint: customizeHint,
                    onLongPress: _customize,
                    child: GestureDetector(
                      key: const ValueKey('nav-bar-long-press'),
                      excludeFromSemantics: true,
                      onLongPress: _customize,
                      child: NavigationBar(
                        key: const ValueKey('nav-bar'),
                        selectedIndex: index,
                        onDestinationSelected: (i) => _select(items, i),
                        destinations: [
                          for (final id in items)
                            NavigationDestination(
                              key: ValueKey('nav-$id'),
                              icon: Icon(navItem(id).icon),
                              selectedIcon: Icon(navItem(id).selectedIcon),
                              label: navItem(id).label(l10n),
                              // The labels are always shown; no tooltip, so
                              // a long-press is free to open the arranger.
                              tooltip: '',
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
