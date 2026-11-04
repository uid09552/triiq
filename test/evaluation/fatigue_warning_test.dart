import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_wellness.dart';
import 'package:triiq/evaluation/fatigue_warning.dart';
import 'package:triiq/util/dates.dart';

void main() {
  final today = DateTime(2026, 5, 20);

  /// 60 normal days (HRV ~60±3, RHR ~50±1, sleep 7.5 h, form ~0) then
  /// [recent] overrides for the last 5 days (index 0 = 4 days ago).
  List<LocalWellness> history({
    List<Map<String, dynamic>> recent = const [],
    List<(double ctl, double atl)> loads = const [],
  }) {
    final out = <LocalWellness>[];
    for (var i = 64; i >= 0; i--) {
      final d = today.subtract(Duration(days: i));
      final k = 4 - i; // 0..4 inside the window
      final inWindow = k >= 0;
      final o = inWindow && k < recent.length ? recent[k] : const {};
      final noise = inWindow ? 0.0 : (i % 3) - 1.0;
      final (ctl, atl) = inWindow && k < loads.length ? loads[k] : (50.0, 50.0);
      out.add(
        LocalWellness(
          date: isoDate(d),
          ctl: ctl, atl: atl, ctlLoad: null, atlLoad: null,
          rampRate: o['ramp'] as double?,
          raw: {
            'hrv': o['hrv'] ?? 60 + noise * 3,
            'restingHR': o['rhr'] ?? 50 + noise,
            'sleepSecs': o['sleep'] ?? 7.5 * 3600,
            if (o['fatigue'] != null) 'fatigue': o['fatigue'],
            if (o['soreness'] != null) 'soreness': o['soreness'],
          },
          syncedAt: DateTime(2026),
        ),
      );
    }
    return out;
  }

  test('a normal week is none', () {
    expect(evaluateFatigue(history(), today).level, FatigueLevel.none);
  });

  test('one bad night is not a trend', () {
    final w = evaluateFatigue(
      history(recent: [{}, {}, {}, {}, {'hrv': 40, 'rhr': 60, 'sleep': 5 * 3600}]),
      today,
    );
    expect(w.level, FatigueLevel.none);
  });

  test('HRV low three days running alone stays quiet', () {
    final w = evaluateFatigue(
      history(recent: [{}, {}, {'hrv': 45}, {'hrv': 44}, {'hrv': 46}]),
      today,
    );
    expect(w.firing.single.kind, FatigueSignalKind.hrvLow);
    expect(w.level, FatigueLevel.none);
  });

  test('HRV low four days + short sleep three days is a watch', () {
    final w = evaluateFatigue(
      history(recent: [
        {'hrv': 45}, {'hrv': 44, 'sleep': 5.5 * 3600},
        {'hrv': 46, 'sleep': 5.5 * 3600}, {'hrv': 45, 'sleep': 6 * 3600}, {},
      ]),
      today,
    );
    expect(w.firing.map((s) => s.kind), containsAll([FatigueSignalKind.hrvLow, FatigueSignalKind.sleepShort]));
    expect(w.level, FatigueLevel.watch);
  });

  test('HRV + resting HR + fatigue scores is a warning', () {
    final w = evaluateFatigue(
      history(recent: [
        {}, {},
        {'hrv': 44, 'rhr': 58, 'fatigue': 3},
        {'hrv': 45, 'rhr': 59, 'fatigue': 4},
        {'hrv': 43, 'rhr': 58, 'soreness': 3},
      ]),
      today,
    );
    expect(w.level, FatigueLevel.warning);
    expect(w.firing.length, greaterThanOrEqualTo(3));
  });

  test('physiology plus deep negative form is a warning', () {
    final w = evaluateFatigue(
      history(
        recent: [{}, {}, {'hrv': 44}, {'hrv': 45}, {'hrv': 43}],
        loads: [(60, 85), (60, 88), (60, 90), (60, 92), (60, 95)],
      ),
      today,
    );
    expect(w.level, FatigueLevel.warning);
  });

  test('deep form and a fast ramp without physiology is a watch', () {
    final w = evaluateFatigue(
      history(
        recent: [{}, {}, {'ramp': 9.0}, {'ramp': 10.0}, {'ramp': 9.5}],
        loads: [(60, 88), (60, 90), (60, 92), (60, 93), (60, 95)],
      ),
      today,
    );
    expect(w.level, FatigueLevel.watch);
  });

  test('too little data or baseline never fires', () {
    expect(evaluateFatigue(const [], today).level, FatigueLevel.none);
    final short = history().skip(55).toList(); // 10 days: no baseline
    expect(evaluateFatigue(short, today).signals.where((s) => s.physiological), isEmpty);
  });

  test('days with 0 (not measured) are ignored', () {
    final w = evaluateFatigue(
      history(recent: [{'hrv': 0}, {'hrv': 0}, {'hrv': 0}, {'hrv': 0}, {'hrv': 0}]),
      today,
    );
    expect(w.level, FatigueLevel.none);
  });
}
