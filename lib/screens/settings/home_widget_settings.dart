import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Which blocks the Android home-screen widget shows. Nothing secret, so
/// ordinary `shared_preferences`, same pattern as
/// [WeeklyTargetsSettings](weekly_targets_settings.dart). All on by default.
class HomeWidgetSettings extends ChangeNotifier {
  HomeWidgetSettings._();

  static final HomeWidgetSettings instance = HomeWidgetSettings._();

  @visibleForTesting
  factory HomeWidgetSettings.forTesting() = HomeWidgetSettings._;

  static const _prefix = 'homewidget.show_';

  bool showSessions = true;
  bool showDone = true;
  bool showForm = true;
  bool showFitness = true;
  bool showRings = true;
  bool showUpdated = true;
  bool isLoaded = false;

  static const _blocks = [
    'sessions',
    'done',
    'form',
    'fitness',
    'rings',
    'updated',
  ];

  bool _get(String block) => switch (block) {
    'sessions' => showSessions,
    'done' => showDone,
    'form' => showForm,
    'fitness' => showFitness,
    'rings' => showRings,
    _ => showUpdated,
  };

  void _put(String block, bool value) {
    switch (block) {
      case 'sessions':
        showSessions = value;
      case 'done':
        showDone = value;
      case 'form':
        showForm = value;
      case 'fitness':
        showFitness = value;
      case 'rings':
        showRings = value;
      default:
        showUpdated = value;
    }
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final b in _blocks) {
        _put(b, prefs.getBool('$_prefix$b') ?? true);
      }
    } catch (error) {
      debugPrint('HomeWidgetSettings: cannot read stored settings: $error');
    } finally {
      isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> setShowSessions(bool v) => _set('sessions', v);
  Future<void> setShowDone(bool v) => _set('done', v);
  Future<void> setShowForm(bool v) => _set('form', v);
  Future<void> setShowFitness(bool v) => _set('fitness', v);
  Future<void> setShowRings(bool v) => _set('rings', v);
  Future<void> setShowUpdated(bool v) => _set('updated', v);

  Future<void> _set(String block, bool value) async {
    if (_get(block) == value) return;
    _put(block, value);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('$_prefix$block', value);
    } catch (error) {
      debugPrint('HomeWidgetSettings: cannot persist "$block": $error');
    }
  }
}
