import 'package:flutter/widgets.dart';

/// Whether the app is currently in the foreground, tracked independently of
/// any one widget's lifetime so background-only notification decisions
/// (e.g. "the agent finished a reply, but only tell the user if they've
/// switched away") can be made from plain Dart code.
///
/// Registered once in `main()`, before `runApp`.
class AppLifecycleTracker extends WidgetsBindingObserver {
  AppLifecycleTracker._();

  static final AppLifecycleTracker instance = AppLifecycleTracker._();

  bool isForeground = true;

  void start() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    isForeground = state == AppLifecycleState.resumed;
  }
}
