import 'package:flutter/material.dart';

/// Holds the user's chosen theme mode (system/light/dark), shared across
/// the app so Settings can change it and TriiqApp can react.
///
/// TODO: persist this choice (e.g. shared_preferences) instead of only
/// holding it in memory for the lifetime of the app.
class ThemeController extends ChangeNotifier {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  void setMode(ThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }
}
