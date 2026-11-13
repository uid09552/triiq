import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'readiness.dart';

/// Which signals count toward readiness — the score, the status and what the
/// trainer is told. All five by default; the athlete can switch off the ones
/// they don't trust or don't measure. Stored on the device with plain
/// `shared_preferences` (the *switched-off* signals, so a signal added later
/// starts on), and listened to by Today, the detail screen and the
/// readiness service, which keeps them all in step.
class ReadinessSettings extends ChangeNotifier {
  ReadinessSettings._();

  static final ReadinessSettings instance = ReadinessSettings._();

  @visibleForTesting
  factory ReadinessSettings.forTesting() = ReadinessSettings._;

  static const _disabledKey = 'readiness.disabled_signals';
  static const _smoothingKey = 'readiness.smoothing_days';

  /// The smoothing windows the athlete can choose for HRV and resting HR.
  static const smoothingChoices = [3, 5];

  final Set<ReadinessSignalKind> _disabled = {};
  int? _smoothingDays;
  bool _loaded = false;

  /// The athlete's smoothing window for HRV and resting HR (3 or 5 days), or
  /// null to follow the training knowledge (`readiness.smoothingDays`,
  /// 3 by default).
  int? get smoothingDays => _smoothingDays;

  /// Sets the smoothing window; null goes back to the knowledge's default.
  Future<void> setSmoothingDays(int? days) async {
    await ensureLoaded();
    if (days != null && !smoothingChoices.contains(days)) {
      throw ArgumentError.value(
        days,
        'days',
        'must be one of $smoothingChoices',
      );
    }
    if (days == _smoothingDays) return;
    _smoothingDays = days;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      days == null
          ? await prefs.remove(_smoothingKey)
          : await prefs.setInt(_smoothingKey, days);
    } catch (error) {
      debugPrint('ReadinessSettings: cannot store smoothing: $error');
    }
  }

  /// The signals that count.
  Set<ReadinessSignalKind> get enabled => {
    for (final k in ReadinessSignalKind.values)
      if (!_disabled.contains(k)) k,
  };

  bool isEnabled(ReadinessSignalKind kind) => !_disabled.contains(kind);

  /// Reads the stored choice once; later calls return at once.
  Future<void> ensureLoaded() async {
    if (_loaded) return;
    await load();
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _disabled
        ..clear()
        ..addAll(_parse(prefs.getStringList(_disabledKey)));
      // Never persist "nothing counts".
      if (_disabled.length >= ReadinessSignalKind.values.length) {
        _disabled.clear();
      }
      final smoothing = prefs.getInt(_smoothingKey);
      _smoothingDays = smoothingChoices.contains(smoothing) ? smoothing : null;
    } catch (error) {
      debugPrint('ReadinessSettings: cannot read stored choice: $error');
    }
    _loaded = true;
    notifyListeners();
  }

  /// Turns [kind] on or off. The last signal that counts can't be turned
  /// off — readiness needs something to rate. Returns whether it changed.
  Future<bool> setEnabled(ReadinessSignalKind kind, bool on) async {
    await ensureLoaded();
    if (on == isEnabled(kind)) return false;
    if (!on && enabled.length <= 1) return false;
    on ? _disabled.remove(kind) : _disabled.add(kind);
    notifyListeners();
    await _persist();
    return true;
  }

  Future<void> reset() async {
    _disabled.clear();
    _loaded = true;
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_disabledKey, [
        for (final k in _disabled) k.name,
      ]);
    } catch (error) {
      debugPrint('ReadinessSettings: cannot store choice: $error');
    }
  }

  static Set<ReadinessSignalKind> _parse(List<String>? names) => {
    for (final name in names ?? const <String>[])
      ...ReadinessSignalKind.values.where((k) => k.name == name),
  };
}
