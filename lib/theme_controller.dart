import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The selectable app themes. [developer] is a terminal-style theme
/// (black background, monospace, phosphor-green on amber/cyan accents).
enum AppThemeChoice { system, light, dark, developer }

/// Holds the user's chosen theme, shared across the app so Settings can
/// change it and TriiqApp can react.
///
/// The choice is persisted in shared_preferences; call [load] at startup.
class ThemeController extends ChangeNotifier {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  @visibleForTesting
  factory ThemeController.forTesting() = ThemeController._;

  static const _key = 'theme.choice';

  AppThemeChoice _choice = AppThemeChoice.system;

  AppThemeChoice get choice => _choice;

  /// [ThemeMode] to hand to MaterialApp. Developer is a dark-brightness
  /// theme supplied as the dark theme, so it maps to [ThemeMode.dark].
  ThemeMode get mode => switch (_choice) {
    AppThemeChoice.system => ThemeMode.system,
    AppThemeChoice.light => ThemeMode.light,
    AppThemeChoice.dark || AppThemeChoice.developer => ThemeMode.dark,
  };

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_key);
      _choice = AppThemeChoice.values.firstWhere(
        (c) => c.name == name,
        orElse: () => AppThemeChoice.system,
      );
    } catch (error) {
      debugPrint('ThemeController: cannot read stored theme: $error');
    } finally {
      notifyListeners();
    }
  }

  Future<void> setChoice(AppThemeChoice choice) async {
    if (_choice == choice) return;
    _choice = choice;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, choice.name);
    } catch (error) {
      debugPrint('ThemeController: cannot persist theme: $error');
    }
  }
}
