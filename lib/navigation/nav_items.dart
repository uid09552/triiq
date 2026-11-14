import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/more/more_screen.dart';
import '../screens/statistics/statistics_screen.dart';
import '../screens/today/today_screen.dart';
import '../widgets/main_navigation.dart';
import '../widgets/responsive.dart';
import 'navigation_layout.dart';
import 'shell_tab.dart';

/// One item the athlete can arrange: a core tab, a More entry, or More.
class NavItem {
  const NavItem({
    required this.id,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.title,
    this.entry,
  });

  final String id;
  final IconData icon;
  final IconData selectedIcon;

  /// The short name under the bar icon.
  final String Function(AppLocalizations l10n) label;

  /// The full name (More list, top bar, customize sheet).
  final String Function(AppLocalizations l10n) title;

  /// The More entry behind it; null for a core tab and More.
  final MoreEntry? entry;

  bool get isCore => entry == null;

  /// What the shell shows while this item is a tab. A More entry's page
  /// brings its own top bar (with the profile button added, see
  /// [ShellTabScope]); core tabs live under the shell's top bar.
  Widget tabBody(
    BuildContext context, {
    required bool active,
    NavigationLayout? layout,
  }) => switch (id) {
    MainNavigation.todayTab => const TodayScreen(),
    MainNavigation.calendarTab => CalendarScreen(active: active),
    MainNavigation.chatTab => const ContentWidth(child: ChatScreen()),
    MainNavigation.insightsTab => const StatisticsScreen(),
    MainNavigation.moreTab => ContentWidth(
      maxWidth: 840,
      child: MoreScreen(layout: layout),
    ),
    _ => ShellTabScope(child: entry!.builder(context)),
  };

  /// The page pushed when the item is opened from More (or asked for while
  /// it isn't in the bar): a More entry's own screen, or a core tab under a
  /// top bar with a back button.
  Route<void> route() => MaterialPageRoute<void>(
    builder: (context) => entry != null
        ? entry!.builder(context)
        : Scaffold(
            appBar: AppBar(title: Text(title(AppLocalizations.of(context)!))),
            body: tabBody(context, active: true),
          ),
  );
}

String _today(AppLocalizations l) => l.navToday;
String _calendar(AppLocalizations l) => l.navCalendar;
String _chat(AppLocalizations l) => l.navChat;
String _insights(AppLocalizations l) => l.navStatistics;
String _more(AppLocalizations l) => l.navMore;

/// The short bar label of each More entry (their titles are too long for a
/// five-item bar).
String _entryLabel(AppLocalizations l, String id) => switch (id) {
  'plan' => l.navShortPlan,
  'season' => l.navShortSeason,
  'events' => l.navShortEvents,
  'memory' => l.navShortMemory,
  'knowledge' => l.navShortKnowledge,
  'sync' => l.navShortSync,
  _ => moreEntries.firstWhere((e) => e.id == id).title(l),
};

/// Every item, core tabs first, then More, then the More entries.
final List<NavItem> navItems = [
  const NavItem(
    id: MainNavigation.todayTab,
    icon: Icons.today_outlined,
    selectedIcon: Icons.today,
    label: _today,
    title: _today,
  ),
  const NavItem(
    id: MainNavigation.calendarTab,
    icon: Icons.calendar_month_outlined,
    selectedIcon: Icons.calendar_month,
    label: _calendar,
    title: _calendar,
  ),
  const NavItem(
    id: MainNavigation.chatTab,
    icon: Icons.chat_bubble_outline,
    selectedIcon: Icons.chat_bubble,
    label: _chat,
    title: _chat,
  ),
  const NavItem(
    id: MainNavigation.insightsTab,
    icon: Icons.bar_chart_outlined,
    selectedIcon: Icons.bar_chart,
    label: _insights,
    title: _insights,
  ),
  const NavItem(
    id: MainNavigation.moreTab,
    icon: Icons.more_horiz,
    selectedIcon: Icons.more_horiz,
    label: _more,
    title: _more,
  ),
  for (final e in moreEntries)
    NavItem(
      id: e.id,
      icon: e.icon,
      selectedIcon: e.icon,
      label: (l) => _entryLabel(l, e.id),
      title: e.title,
      entry: e,
    ),
];

NavItem navItem(String id) => navItems.firstWhere((i) => i.id == id);

/// Opens [id] where it lives now: back to the shell and its tab when it is
/// in the bar, otherwise its page pushed on top (from More, search, the
/// trainer's Open button).
void openNavItem(BuildContext context, String id, {NavigationLayout? layout}) {
  final navigator = Navigator.of(context);
  if ((layout ?? NavigationLayout.instance).isInBar(id)) {
    navigator.popUntil((route) => route.isFirst);
    MainNavigation.instance.openTab(id);
  } else {
    navigator.push(navItem(id).route());
  }
}
