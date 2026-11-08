import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/season/race_predictor.dart';

const runBests = [
  (metres: 1000.0, seconds: 180.0),
  (metres: 5000.0, seconds: 1200.0), // 20:00 5k
  (metres: 10000.0, seconds: 2500.0),
];
const swimBests = [(metres: 400.0, seconds: 360.0)];
const power = [
  (seconds: 60.0, watts: 500.0),
  (seconds: 300.0, watts: 330.0),
  (seconds: 1200.0, watts: 290.0),
  (seconds: 3600.0, watts: 265.0),
];

void main() {
  test('Riegel from the nearest effort', () {
    expect(predictFromBests(runBests, 5000), closeTo(1200, 0.01));
    // 20:00 5k → ~41:30 10k via Riegel from the closer 10k effort instead
    expect(predictFromBests(runBests, 10000), closeTo(2500, 0.01));
    final hm = predictFromBests(runBests, 21097.5)!;
    expect(hm, closeTo(2500 * 2.10975 * 1.0, 400)); // between 5300 and 5600
    expect(hm, greaterThan(5300));
    expect(predictFromBests(const [], 5000), isNull);
  });

  test('power curve interpolates and extrapolates', () {
    expect(powerAt(power, 3600), 265);
    expect(powerAt(power, 30), 500);
    final mid = powerAt(power, 600)!;
    expect(mid, inInclusiveRange(290, 330));
    expect(powerAt(power, 7200)!, closeTo(265 * 0.96, 0.5));
  });

  test('race fraction falls with duration and is lower in a triathlon', () {
    expect(raceFraction(1800), 0.97);
    expect(raceFraction(3 * 3600), lessThan(raceFraction(3600)));
    expect(raceFraction(3600, triathlon: true), lessThan(raceFraction(3600)));
  });

  test('ride speed rises with watts and falls with climbing', () {
    double v(double w, {double gain = 0}) => rideSpeed(
      watts: w,
      massKg: 80,
      cdA: 0.32,
      crr: 0.005,
      gainM: gain,
      metres: 40000,
    );
    expect(v(250), greaterThan(8)); // > 29 km/h
    expect(v(250), lessThan(14)); // < 50 km/h
    expect(v(300), greaterThan(v(250)));
    expect(v(250, gain: 800), lessThan(v(250)));
  });

  test('a 10k run prediction needs only run data', () {
    final p = predictRace(
      RaceSpec.run10k,
      const RaceInputs(runBests: runBests, ctl: 60),
    );
    expect(p.complete, isTrue);
    expect(p.totalSeconds, closeTo(2500, 5));
    expect(p.legs.single.steps.length, 3);
    expect(p.legs.single.steps.first.note, PacingNote.startControlled);
    expect(p.fueling.carbsPerHour, 0); // 42 min: water only
  });

  test('missing data is reported, not guessed', () {
    final p = predictRace(
      RaceSpec.olympic,
      const RaceInputs(runBests: runBests),
    );
    expect(p.complete, isFalse);
    expect(p.missing, containsAll(['Swim', 'Ride']));
    expect(p.legs.single.sport, 'Run');
  });

  test('a full 70.3 predicts three legs, off-bike run penalty and fuel', () {
    final inputs = RaceInputs(
      runBests: runBests,
      swimBests: swimBests,
      powerCurve: power,
      ftp: 270,
      ctl: 90,
      weightKg: 70,
    );
    final p = predictRace(RaceSpec.half70, inputs);
    expect(p.complete, isTrue);
    expect(p.legs.map((l) => l.sport), ['Swim', 'Ride', 'Run']);
    final hours = p.totalSeconds / 3600;
    expect(hours, inInclusiveRange(4.0, 6.5));
    final ride = p.legs[1];
    expect(ride.watts, lessThan(270));
    expect(ride.intensityFactor, inInclusiveRange(0.6, 0.95));
    final run = p.legs[2];
    expect(run.seconds, greaterThan(predictFromBests(runBests, 21097.5)!));
    expect(p.fueling.carbsPerHour, greaterThanOrEqualTo(70));
    expect(p.fueling.steps.any((s) => s.sport == 'Ride'), isTrue);
    expect(p.fueling.totalCarbsG, greaterThan(250));
    expect(p.fueling.dayBeforeCarbsG, 560);
  });

  test('low CTL and a loaded start slow a long race', () {
    final base = RaceInputs(
      runBests: runBests,
      swimBests: swimBests,
      powerCurve: power,
      ctl: 120,
    );
    final low = RaceInputs(
      runBests: runBests,
      swimBests: swimBests,
      powerCurve: power,
      ctl: 30,
      raceDayForm: -20,
    );
    final good = predictRace(RaceSpec.half70, base);
    final weak = predictRace(RaceSpec.half70, low);
    expect(good.slowdown, 1.0);
    expect(weak.slowdown, greaterThan(1.05));
    expect(weak.totalSeconds, greaterThan(good.totalSeconds * 1.05));
    expect(weak.legs[1].watts!, lessThan(good.legs[1].watts!));
  });

  test('short races ignore CTL', () {
    expect(raceSlowdown(totalSeconds: 1500, ctl: 5), 1.0);
  });
}
