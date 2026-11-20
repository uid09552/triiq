import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/plan/bodyweight_strength.dart';
import 'package:triiq/screens/today/train_now_screen.dart';

void main() {
  test('no equipment anywhere in the content', () {
    final text = bodyweightStrengthDescription({
      ...StrengthTarget.values,
    }, minutes: 45).toLowerCase();
    for (final word in [
      'dumbbell',
      'barbell',
      'kettlebell',
      'band ',
      'machine',
      'weight plate',
    ]) {
      expect(text, isNot(contains(word)), reason: word);
    }
  });

  test('a single sport gets only its own exercises plus warm-up and core', () {
    final swim = bodyweightExercises({StrengthTarget.swim}, minutes: 30);
    expect(swim.first.name, 'Warm-up');
    expect(swim.last.name, 'Dead bug');
    expect(swim.map((e) => e.name), contains('Push-ups'));
    expect(swim.map((e) => e.name), isNot(contains('Wall sit')));
    expect(swim, hasLength(6 + 2));
  });

  test('several sports take turns, the length sets the count', () {
    final both = bodyweightExercises({
      StrengthTarget.ride,
      StrengthTarget.run,
    }, minutes: 20);
    final names = both.map((e) => e.name).toList();
    expect(names, hasLength(4 + 2));
    expect(names[1], 'Bodyweight squat');
    expect(names[2], 'Single-leg calf raise');
    expect(bodyweightSets(20), 2);
    expect(bodyweightSets(45), 3);
  });

  test('name lists the chosen sports, all three read as plain strength', () {
    expect(
      bodyweightStrengthName({StrengthTarget.swim, StrengthTarget.run}),
      'Bodyweight strength · Swim + Run',
    );
    expect(
      bodyweightStrengthName({...StrengthTarget.values}),
      'Bodyweight strength',
    );
  });

  test('Train now asks for a bodyweight-only session for the sports', () {
    final prompt = TrainNowScreen.buildPrompt(
      intensityWord: 'a steady endurance',
      sport: bodyweightStrengthSport,
      minutes: 30,
      strengthTargets: {StrengthTarget.swim},
    );
    expect(prompt, contains('bodyweight-only strength session'));
    expect(prompt, contains('specific to swimming'));
    expect(prompt, contains('push-ups'));
    expect(prompt, contains('no equipment'));
    expect(prompt, isNot(contains('a steady endurance')));
    expect(prompt, contains('right now'));
  });
}
