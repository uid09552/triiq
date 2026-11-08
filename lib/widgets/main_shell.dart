import 'package:flutter/material.dart';

import '../data/sync/auto_sync_service.dart';
import '../l10n/app_localizations.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/insights/new_training_trigger.dart';
import '../screens/more/more_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/statistics/statistics_screen.dart';
import '../screens/today/today_screen.dart';
import 'athlete_avatar.dart';
import 'main_navigation.dart';
import 'responsive.dart';

/// From this width the bottom bar gives way to a navigation rail.
const railBreakpoint = 840.0;

/// From this width the rail shows its labels beside the icons.
const extendedRailBreakpoint = 1200.0;

/// App shell: top bar with the profile/settings entry point on the right,
/// bottom navigation for the five main sections on phones, a navigation rail
/// on wide windows (Windows, tablets).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  /// Position of the Calendar tab, which needs to know when it is the
  /// visible one — `IndexedStack` keeps every tab alive, so nothing else
  /// tells it that it came back on screen.
  static const _calendarIndex = MainNavigation.calendarTab;

  final _navigation = MainNavigation.instance;

  @override
  void initState() {
    super.initState();
    _navigation.addListener(_onNavigate);
  }

  @override
  void dispose() {
    _navigation.removeListener(_onNavigate);
    super.dispose();
  }

  /// Another screen asked for a tab (e.g. Take as plan → Calendar).
  void _onNavigate() {
    final tab = _navigation.requestedTab;
    if (tab != null && tab != _index) setState(() => _index = tab);
  }

  void _select(int i) => setState(() => _index = i);

  List<Widget> get _screens => [
    const TodayScreen(),
    CalendarScreen(active: _index == _calendarIndex),
    const ContentWidth(child: ChatScreen()),
    const StatisticsScreen(),
    const ContentWidth(maxWidth: 840, child: MoreScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final titles = [
      l10n.navToday,
      l10n.navCalendar,
      l10n.navChat,
      l10n.navStatistics,
      l10n.navMore,
    ];

    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= railBreakpoint;
    final extended = width >= extendedRailBreakpoint;
    final destinations = [
      _Dest(Icons.today_outlined, Icons.today, l10n.navToday),
      _Dest(
        Icons.calendar_month_outlined,
        Icons.calendar_month,
        l10n.navCalendar,
      ),
      _Dest(Icons.chat_bubble_outline, Icons.chat_bubble, l10n.navChat),
      _Dest(Icons.bar_chart_outlined, Icons.bar_chart, l10n.navStatistics),
      _Dest(Icons.more_horiz, Icons.more_horiz, l10n.navMore),
    ];
    final stack = IndexedStack(index: _index, children: _screens);

    // Today's new sessions pop up after the open-time sync.
    return NewTrainingTrigger(
      openSyncDone: AutoSyncService.instance.openSyncDone,
      child: Scaffold(
        appBar: AppBar(
          title: Text(titles[_index]),
          actions: [
            IconButton(
              tooltip: l10n.profileAndSettingsTooltip,
              // The athlete's own picture once connected — the fastest way to
              // see at a glance which account the app is showing.
              icon: const AthleteAvatar(size: 34),
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: wide
            ? Row(
                children: [
                  NavigationRail(
                    key: const ValueKey('nav-rail'),
                    selectedIndex: _index,
                    extended: extended,
                    labelType: extended
                        ? NavigationRailLabelType.none
                        : NavigationRailLabelType.all,
                    onDestinationSelected: _select,
                    destinations: [
                      for (final d in destinations)
                        NavigationRailDestination(
                          icon: d.icon,
                          selectedIcon: d.selectedIcon,
                          label: Text(d.label),
                        ),
                    ],
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
                  child: NavigationBar(
                    key: const ValueKey('nav-bar'),
                    selectedIndex: _index,
                    onDestinationSelected: _select,
                    destinations: [
                      for (final d in destinations)
                        NavigationDestination(
                          icon: d.icon,
                          selectedIcon: d.selectedIcon,
                          label: d.label,
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _Dest {
  const _Dest(this.outlined, this.filled, this.label);
  final IconData outlined, filled;
  final String label;
  Widget get icon => Icon(outlined);
  Widget get selectedIcon => Icon(filled);
}
