import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Caps notifications nobody scheduled (a background sync found something
/// new): at most [perDay] a day and [perWeek] in seven days, and after
/// [ignoredBeforeBackoff] in a row that were never opened, at most one
/// every [backoffDays] days. Opening one resets the back-off. Scheduled
/// ones (reminder, briefing, weekly review) and a reply the athlete is
/// waiting for are not counted. No study fixes a right number; this errs
/// on the quiet side (issue #119).
class PushBudget {
  PushBudget({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  static final PushBudget instance = PushBudget();

  static const prefsKey = 'notifications.push_budget';
  static const perDay = 1;
  static const perWeek = 3;
  static const ignoredBeforeBackoff = 3;
  static const backoffDays = 2;

  final DateTime Function() _clock;

  Future<({List<DateTime> sent, int ignored})> _read() async {
    try {
      final raw = (await SharedPreferences.getInstance()).getString(prefsKey);
      if (raw == null) return (sent: <DateTime>[], ignored: 0);
      final j = jsonDecode(raw) as Map<String, dynamic>;
      return (
        sent: [
          for (final s in j['sent'] as List? ?? const [])
            if (DateTime.tryParse('$s') case final d?) d,
        ],
        ignored: (j['ignored'] as num?)?.toInt() ?? 0,
      );
    } catch (error) {
      debugPrint('PushBudget: cannot read: $error');
      return (sent: <DateTime>[], ignored: 0);
    }
  }

  Future<void> _write(List<DateTime> sent, int ignored) async {
    try {
      await (await SharedPreferences.getInstance()).setString(
        prefsKey,
        jsonEncode({
          'sent': [for (final d in sent) d.toIso8601String()],
          'ignored': ignored,
        }),
      );
    } catch (error) {
      debugPrint('PushBudget: cannot save: $error');
    }
  }

  /// Whether one more unscheduled push may go out now; when it may, it is
  /// counted (so call this right before showing it).
  Future<bool> take() async {
    final now = _clock();
    final state = await _read();
    final week = [
      for (final d in state.sent)
        if (now.difference(d) < const Duration(days: 7)) d,
    ];
    final today = week.where(
      (d) => now.difference(d) < const Duration(hours: 24),
    );
    if (today.length >= perDay || week.length >= perWeek) return false;
    if (state.ignored >= ignoredBeforeBackoff &&
        week.any(
          (d) => now.difference(d) < const Duration(days: backoffDays),
        )) {
      return false;
    }
    await _write([...week, now], state.ignored + 1);
    return true;
  }

  /// A notification was opened: the athlete wants these, reset back-off.
  Future<void> opened() async {
    final state = await _read();
    await _write(state.sent, 0);
  }
}
