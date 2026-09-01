import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The user's chosen app language: System (follows the device locale),
/// English, or German. Same shape as [ThemeController] — an in-memory
/// singleton `ChangeNotifier` — but persisted, since a language choice
/// resetting on every restart would be far more annoying than a theme
/// reverting to System.
class LocaleController extends ChangeNotifier {
  LocaleController._();

  static final LocaleController instance = LocaleController._();

  @visibleForTesting
  factory LocaleController.forTesting() = LocaleController._;

  static const _localeKey = 'locale.language_code';

  /// The languages TriIQ ships translations for. `null` means "System".
  static const supportedLocales = [Locale('en'), Locale('de')];

  Locale? _locale;
  bool isLoaded = false;

  /// `null` means "follow the system locale" — `MaterialApp.locale` accepts
  /// that directly.
  Locale? get locale => _locale;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_localeKey);
      _locale = code == null ? null : Locale(code);
    } catch (error) {
      debugPrint('LocaleController: cannot read stored locale: $error');
    } finally {
      isLoaded = true;
      notifyListeners();
    }
  }

  /// Pass `null` for "System".
  Future<void> setLocale(Locale? locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (locale == null) {
        await prefs.remove(_localeKey);
      } else {
        await prefs.setString(_localeKey, locale.languageCode);
      }
    } catch (error) {
      debugPrint('LocaleController: cannot persist locale: $error');
    }
  }
}
