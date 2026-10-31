import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/plan/load_curve.dart';
import 'package:triiq/plan/plan_models.dart';

void main() {
  const limits = CurveLimits(
    baseline: 300,
    rampCap: 0.10,
    maxCtlRamp: 7,
    recoveryThreshold: 0.9,
  );

  group('proposeCurve', () {
    test('ramps 10% a week from the baseline', () {
      final p = proposeCurve(limits, 4);

      expect(p.loads.map((l) => l.round()), [330, 363, 399, 439]);
      expect(p.limits, everyElement(WeekLimit.none));
    });

    test('the hours budget holds the curve at the budget and says so', () {
      final p = proposeCurve(
        const CurveLimits(
          baseline: 300,
          rampCap: 0.10,
          maxCtlRamp: 7,
          recoveryThreshold: 0.9,
          hoursCeilings: {'build': 420},
        ),
        6,
      );

      expect(p.loads.take(3).map((l) => l.round()), [330, 363, 399]);
      expect(p.loads.skip(3), everyElement(420));
      expect(p.limits.skip(3), everyElement(WeekLimit.hours));
    });

    test('the CTL ramp limit holds a week whose CTL would climb too fast', () {
      final p = proposeCurve(
        const CurveLimits(
          baseline: 300,
          rampCap: 0.10,
          maxCtlRamp: 1,
          recoveryThreshold: 0.9,
          ctl: 40,
        ),
        3,
      );

      expect(p.limits, everyElement(WeekLimit.ctlRamp));
      var ctl = 40.0;
      for (final load in p.loads) {
        final next = CurveLimits.nextCtl(ctl, load);
        expect(next - ctl, closeTo(1, 1e-9));
        ctl = next;
      }
    });
  });

  group('flagWeeks', () {
    final proposal = proposeCurve(limits, 4).loads;

    test('the proposal itself raises nothing', () {
      expect(
        flagWeeks(limits, proposal, proposal: proposal),
        everyElement(isEmpty),
      );
    });

    test('120% after a 100% week is above the ramp cap', () {
      final targets = [proposal[0], proposal[1], proposal[2] * 1.2, proposal[3]];
      final flags = flagWeeks(limits, targets, proposal: proposal);

      expect(flags[2], {WeekLimit.weeklyIncrease});
      expect(flags[1], isEmpty);
    });

    test('hours are checked per phase', () {
      const tight = CurveLimits(
        baseline: 300,
        rampCap: 0.10,
        maxCtlRamp: 7,
        recoveryThreshold: 0.9,
        hoursCeilings: {'build': 400, 'recovery': 250},
      );
      final flags = flagWeeks(tight, [330, 270], proposal: [330, 363]);

      expect(flags[0], isEmpty);
      expect(flags[1], {WeekLimit.hours});
    });
  });

  test('phasesFor: a week 10% below the one before is recovery', () {
    expect(phasesFor(limits, [330, 363, 399.3 * 1.1, 439.2 * 0.8]), [
      'build',
      'build',
      'build',
      'recovery',
    ]);
    expect(phasesFor(limits, [330, 300]), ['build', 'build']);
  });

  test('snapFactor snaps to 5% and clamps to 80-120%', () {
    expect(snapFactor(1.023), 1.0);
    expect(snapFactor(1.026), 1.05);
    expect(snapFactor(0.5), 0.8);
    expect(snapFactor(1.4), 1.2);
  });
}
