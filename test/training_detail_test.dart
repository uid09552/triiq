import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/agent/training_detail.dart';
import 'package:triiq/agent/workout_draft_parser.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/today/train_now_screen.dart';

void main() {
  String prompt(TrainingDetail? detail, {String sport = 'Run'}) =>
      detail == null
      ? TrainNowScreen.buildPrompt(
          intensityWord: 'a steady endurance',
          sport: sport,
          minutes: 45,
        )
      : TrainNowScreen.buildPrompt(
          intensityWord: 'a steady endurance',
          sport: sport,
          minutes: 45,
          detail: detail,
        );

  group('prompt', () {
    test('detailed is the default and asks for exercises and set detail', () {
      final p = prompt(null);
      expect(p, equals(prompt(TrainingDetail.detailed)));
      expect(p, contains('detailed, coach-written session'));
      expect(p, contains('"## "'));
      expect(p, contains('"Exercise"'));
      expect(p, contains('"How"'));
      expect(p, contains('rest between'));
      expect(p, contains('coaching cue'));
      expect(p, contains('Propose a steady endurance Run session lasting'));
      expect(p, contains('add up to the requested duration'));
    });

    test('short keeps the compact two-column table', () {
      final p = prompt(TrainingDetail.short);
      expect(p, contains('one row per segment'));
      expect(p, contains('"Duration"'));
      expect(p, isNot(contains('coach-written')));
    });

    test('the exercises follow the sport', () {
      expect(prompt(null, sport: 'Run'), contains('A-skips'));
      expect(prompt(null, sport: 'Run'), contains('strides'));
      expect(prompt(null, sport: 'Ride'), contains('single-leg pedalling'));
      expect(prompt(null, sport: 'Swim'), contains('catch-up'));
      expect(prompt(null, sport: 'Swim'), contains('pull buoy'));
      expect(exerciseMenu('Triathlon'), contains('Warm-up drills'));
    });
  });

  group('structuring prompt', () {
    test('short is the original', () {
      expect(
        workoutStructuringPromptFor(TrainingDetail.short),
        workoutStructuringPrompt,
      );
    });

    test('detailed keeps the exercises, cues and rest as steps', () {
      final p = workoutStructuringPromptFor(TrainingDetail.detailed);
      expect(p, startsWith(workoutStructuringPrompt));
      expect(p, contains('own step'));
      expect(p, contains('coaching cue'));
      expect(p, contains('rest between repeats'));
      expect(p, contains('plain text'));
      // The swim unit rule still applies.
      expect(p, contains('mtr'));
    });
  });

  testWidgets('Train now offers Short and Detailed, Detailed first', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: const TrainNowScreen(),
      ),
    );
    await tester.pump();
    final control = find.byKey(const ValueKey('train-detail'));
    expect(control, findsOneWidget);
    expect(tester.widget<SegmentedButton<TrainingDetail>>(control).selected, {
      TrainingDetail.detailed,
    });
    expect(find.textContaining('Named exercises and drills'), findsOneWidget);
    await tester.tap(find.text('Short'));
    await tester.pump();
    expect(find.text('One compact table: a row per segment.'), findsOneWidget);
  });
}
