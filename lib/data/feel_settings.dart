import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Whether opening a recent activity automatically offers to set that day's
/// fatigue/soreness — nothing secret, so plain `shared_preferences`, same
/// shape as [SyncSettings](sync/sync_settings.dart).
class FeelSettings extends ChangeNotifier {
  FeelSettings._();

  static final FeelSettings instance = FeelSettings._();

  @visibleForTesting
  factory FeelSettings.forTesting() = FeelSettings._;

  static const _promptOnNewActivityKey = 'feel.prompt_on_new_activity';

  /// Whether a recent, never-opened activity with nothing set yet shows the
  /// fatigue/soreness dialog automatically. The manual action on any
  /// activity's detail screen stays available either way.
  bool promptOnNewActivity = true;

  bool isLoaded = false;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      promptOnNewActivity = prefs.getBool(_promptOnNewActivityKey) ?? true;
    } catch (error) {
      debugPrint('FeelSettings: cannot read stored settings: $error');
    } finally {
      isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> setPromptOnNewActivity(bool enabled) async {
    if (enabled == promptOnNewActivity) return;
    promptOnNewActivity = enabled;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_promptOnNewActivityKey, enabled);
    } catch (error) {
      debugPrint(
        'FeelSettings: cannot persist $_promptOnNewActivityKey: $error',
      );
    }
  }
}
