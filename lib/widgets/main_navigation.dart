import 'package:flutter/foundation.dart';

/// Lets any screen — including one pushed on top of the shell, like the
/// Plan screen — switch the main view's tab and point the Calendar at a
/// date. `MainShell` and `CalendarScreen` listen.
class MainNavigation extends ChangeNotifier {
  MainNavigation._();

  static final MainNavigation instance = MainNavigation._();

  static const todayTab = 0;
  static const calendarTab = 1;
  static const chatTab = 2;

  int? _requestedTab;

  /// The tab last asked for; the shell applies it and keeps its own index.
  int? get requestedTab => _requestedTab;

  /// The date the Calendar should show, with a sequence number so asking
  /// for the same date twice still moves it.
  ({DateTime date, int seq})? calendarFocus;
  int _seq = 0;

  void openCalendar(DateTime date) {
    _requestedTab = calendarTab;
    calendarFocus = (date: DateTime(date.year, date.month, date.day), seq: ++_seq);
    notifyListeners();
  }

  void openTab(int tab) {
    _requestedTab = tab;
    notifyListeners();
  }

  @visibleForTesting
  void debugReset() {
    _requestedTab = null;
    calendarFocus = null;
  }
}
