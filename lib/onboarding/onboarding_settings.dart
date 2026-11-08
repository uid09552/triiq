import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/intervals_session.dart';

/// Whether the first-run flow has been seen. Shown once, on a fresh install
/// only: an install that already has settings or a saved Intervals.icu key
/// is marked done without showing it.
class OnboardingSettings {
  OnboardingSettings._();

  static final OnboardingSettings instance = OnboardingSettings._();

  @visibleForTesting
  factory OnboardingSettings.forTesting() = OnboardingSettings._;

  static const doneKey = 'onboarding.done';

  /// Prefixes written by settings that load on every start of a fresh
  /// install too, so they don't count as "used before".
  static const _ownPrefixes = ['onboarding.', 'today.'];

  Future<bool> shouldShow({Future<bool> Function()? hasSavedKey}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(doneKey) ?? false) return false;
      final usedBefore = prefs.getKeys().any(
        (k) => !_ownPrefixes.any(k.startsWith),
      );
      final connectedBefore =
          await (hasSavedKey ?? IntervalsSession.instance.hasSavedKey)();
      if (usedBefore || connectedBefore) {
        await markDone();
        return false;
      }
      return true;
    } catch (error) {
      debugPrint('OnboardingSettings: cannot read: $error');
      return false;
    }
  }

  Future<void> markDone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(doneKey, true);
    } catch (error) {
      debugPrint('OnboardingSettings: cannot persist: $error');
    }
  }
}
