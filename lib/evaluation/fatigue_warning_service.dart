import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/wellness_repository.dart';
import '../plan/knowledge.dart';
import '../util/dates.dart';
import 'fatigue_warning.dart';

/// Reads the wellness window from the cache and rates the multi-day trend.
/// Baseline length follows the readiness rules so both agree on "normal".
class FatigueWarningService {
  FatigueWarningService({
    WellnessRepository? wellness,
    KnowledgeRepository? knowledge,
    DateTime Function()? clock,
  }) : _wellness = wellness ?? WellnessRepository(),
       _knowledge = knowledge ?? KnowledgeRepository(),
       _clock = clock ?? DateTime.now;

  final WellnessRepository _wellness;
  final KnowledgeRepository _knowledge;
  final DateTime Function() _clock;

  Future<FatigueWarning> load() async {
    final today = dateOnly(_clock());
    var rules = const FatigueRules();
    try {
      final r = (await _knowledge.load()).rules.readiness;
      rules = FatigueRules(
        baselineDays: r.baselineDays,
        minBaselineDays: r.minBaselineDays,
      );
    } catch (_) {
      // Defaults are fine when the knowledge can't be read.
    }
    final records = await _wellness.getRange(
      isoDate(today.subtract(Duration(days: rules.baselineDays + 1))),
      isoDate(today),
    );
    return evaluateFatigue(records, today, rules: rules);
  }
}

/// "Not now" for a warning: hidden for the rest of the day, and shown again
/// if the level gets worse.
class FatigueWarningDismissals {
  static const _key = 'fatigue_warning.dismissed';

  Future<void> dismiss(DateTime day, FatigueLevel level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, '${isoDate(day)}|${level.name}');
  }

  Future<bool> isDismissed(DateTime day, FatigueLevel level) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return false;
    final parts = raw.split('|');
    if (parts.length != 2 || parts[0] != isoDate(day)) return false;
    final dismissed = FatigueLevel.values.asNameMap()[parts[1]];
    return dismissed != null && level.index <= dismissed.index;
  }
}
