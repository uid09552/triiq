import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/more/more_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/statistics/statistics_screen.dart';
import '../screens/today/today_screen.dart';
import 'athlete_avatar.dart';

/// App shell: top bar with the profile/settings entry point on the right,
/// bottom navigation for the five main sections.
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
  static const _calendarIndex = 1;

  List<Widget> get _screens => [
    const TodayScreen(),
    CalendarScreen(active: _index == _calendarIndex),
    const ChatScreen(),
    const StatisticsScreen(),
    const MoreScreen(),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: [
          IconButton(
            tooltip: l10n.profileAndSettingsTooltip,
            // The athlete's own picture once connected — the fastest way to
            // see at a glance which account the app is showing.
            icon: const AthleteAvatar(size: 34),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.today_outlined),
                selectedIcon: const Icon(Icons.today),
                label: l10n.navToday,
              ),
              NavigationDestination(
                icon: const Icon(Icons.calendar_month_outlined),
                selectedIcon: const Icon(Icons.calendar_month),
                label: l10n.navCalendar,
              ),
              NavigationDestination(
                icon: const Icon(Icons.chat_bubble_outline),
                selectedIcon: const Icon(Icons.chat_bubble),
                label: l10n.navChat,
              ),
              NavigationDestination(
                icon: const Icon(Icons.bar_chart_outlined),
                selectedIcon: const Icon(Icons.bar_chart),
                label: l10n.navStatistics,
              ),
              NavigationDestination(
                icon: const Icon(Icons.more_horiz),
                label: l10n.navMore,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
