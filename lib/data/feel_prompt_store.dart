import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Activity ids the new-activity fatigue/soreness prompt has already shown
/// for — nothing secret, so plain `shared_preferences`, same pattern as
/// [ThresholdDismissalsStore](threshold_dismissals_store.dart). Recorded the
/// moment the dialog shows, whether the athlete saves or cancels it, so it
/// never shows twice for the same activity.
class FeelPromptStore extends ChangeNotifier {
  FeelPromptStore._();

  static final FeelPromptStore instance = FeelPromptStore._();

  @visibleForTesting
  factory FeelPromptStore.forTesting() = FeelPromptStore._;

  static const _key = 'feel_prompt.prompted_activity_ids';

  Set<String> _prompted = {};
  bool isLoaded = false;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        _prompted = (jsonDecode(raw) as List).cast<String>().toSet();
      }
    } catch (error) {
      debugPrint('FeelPromptStore: cannot read stored value: $error');
    } finally {
      isLoaded = true;
      notifyListeners();
    }
  }

  bool hasPrompted(String activityId) => _prompted.contains(activityId);

  Future<void> recordPrompted(String activityId) async {
    if (_prompted.contains(activityId)) return;
    _prompted = {..._prompted, activityId};
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(_prompted.toList()));
    } catch (error) {
      debugPrint('FeelPromptStore: cannot persist: $error');
    }
  }
}
