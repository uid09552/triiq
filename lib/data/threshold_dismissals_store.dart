import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../evaluation/performance_curves.dart' show CurveSport;
import '../evaluation/threshold_suggestions.dart';

/// Threshold suggestions the athlete dismissed, per sport and direction —
/// nothing secret, so this is ordinary `shared_preferences`, same pattern
/// as [NotificationSettings](../notifications/notification_settings.dart).
/// [threshold_suggestions.dart]'s own dismissal-retrigger rule (30 days, or
/// a further 3% move) decides whether a stored dismissal still applies;
/// this class only persists and reads them back.
class ThresholdDismissalsStore extends ChangeNotifier {
  ThresholdDismissalsStore._();

  static final ThresholdDismissalsStore instance = ThresholdDismissalsStore._();

  @visibleForTesting
  factory ThresholdDismissalsStore.forTesting() = ThresholdDismissalsStore._;

  static const _key = 'threshold_dismissals';

  /// Keyed by `'<sport>|<direction>'`.
  Map<String, ThresholdDismissal> _dismissals = {};
  bool isLoaded = false;

  static String _storageKey(CurveSport sport, ThresholdDirection direction) =>
      '${sport.name}|${direction.name}';

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        _dismissals = decoded.map(
          (key, value) {
            final v = value as Map<String, dynamic>;
            return MapEntry(
              key,
              ThresholdDismissal(
                candidateValue: (v['candidate'] as num).toDouble(),
                at: DateTime.fromMillisecondsSinceEpoch(v['at'] as int),
              ),
            );
          },
        );
      }
    } catch (error) {
      debugPrint('ThresholdDismissalsStore: cannot read stored value: $error');
    } finally {
      isLoaded = true;
      notifyListeners();
    }
  }

  /// All current dismissals, keyed as [evaluateThresholdSuggestions] wants.
  Map<(CurveSport, ThresholdDirection), ThresholdDismissal> get all => {
    for (final sport in CurveSport.values)
      for (final direction in ThresholdDirection.values)
        if (_dismissals[_storageKey(sport, direction)] case final d?)
          (sport, direction): d,
  };

  Future<void> dismiss(
    CurveSport sport,
    ThresholdDirection direction,
    double candidateValue,
  ) async {
    _dismissals = {
      ..._dismissals,
      _storageKey(sport, direction): ThresholdDismissal(
        candidateValue: candidateValue,
        at: DateTime.now(),
      ),
    };
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode(
          _dismissals.map(
            (key, d) => MapEntry(key, {
              'candidate': d.candidateValue,
              'at': d.at.millisecondsSinceEpoch,
            }),
          ),
        ),
      );
    } catch (error) {
      debugPrint('ThresholdDismissalsStore: cannot persist: $error');
    }
  }
}
