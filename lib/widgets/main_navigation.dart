import 'package:flutter/foundation.dart';

/// Lets any screen — including one pushed on top of the shell, like the
/// Plan screen — open a main destination and point the Calendar at a date.
/// `MainShell` and `CalendarScreen` listen.
///
/// Destinations are named by id, not by position: the athlete arranges the
/// bottom bar (`NavigationLayout`), so "Chat" may be the second tab, the
/// fourth, or live in More. The shell resolves the id — it selects the tab
/// when the item is in the bar, and otherwise pushes its page.
class MainNavigation extends ChangeNotifier {
  MainNavigation._();

  static final MainNavigation instance = MainNavigation._();

  static const todayTab = 'today';
  static const calendarTab = 'calendar';
  static const chatTab = 'chat';
  static const insightsTab = 'insights';
  static const moreTab = 'more';

  String? _requestedTab;

  /// The destination last asked for; the shell applies it.
  String? get requestedTab => _requestedTab;

  /// The date the Calendar should show, with a sequence number so asking
  /// for the same date twice still moves it.
  ({DateTime date, int seq})? calendarFocus;
  int _seq = 0;

  void openCalendar(DateTime date) {
    _requestedTab = calendarTab;
    calendarFocus = (
      date: DateTime(date.year, date.month, date.day),
      seq: ++_seq,
    );
    notifyListeners();
  }

  /// Opens [id] (a core tab or a More entry id) wherever it lives.
  void openTab(String id) {
    _requestedTab = id;
    notifyListeners();
  }

  @visibleForTesting
  void debugReset() {
    _requestedTab = null;
    calendarFocus = null;
  }
}
