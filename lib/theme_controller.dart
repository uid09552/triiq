import 'package:flutter/material.dart';

/// The selectable app themes. [developer] is a terminal-style theme
/// (black background, monospace, phosphor-green on amber/cyan accents).
enum AppThemeChoice { system, light, dark, developer }

/// Holds the user's chosen theme, shared across the app so Settings can
/// change it and TriiqApp can react.
///
/// TODO: persist this choice (e.g. shared_preferences) instead of only
/// holding it in memory for the lifetime of the app.
class ThemeController extends ChangeNotifier {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  AppThemeChoice _choice = AppThemeChoice.system;

  AppThemeChoice get choice => _choice;

  /// [ThemeMode] to hand to MaterialApp. Developer is a dark-brightness
  /// theme supplied as the dark theme, so it maps to [ThemeMode.dark].
  ThemeMode get mode => switch (_choice) {
    AppThemeChoice.system => ThemeMode.system,
    AppThemeChoice.light => ThemeMode.light,
    AppThemeChoice.dark || AppThemeChoice.developer => ThemeMode.dark,
  };

  void setChoice(AppThemeChoice choice) {
    if (_choice == choice) return;
    _choice = choice;
    notifyListeners();
  }
}
