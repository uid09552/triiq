import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/widgets/markdown_reply.dart';
import 'package:triiq/widgets/workout_steps.dart';

const _detailedProposal = '''
*Builds aerobic endurance with some neuromuscular work; your ATL is low, so a steady load suits today.*

## Warm-up

| Exercise | How |
|---|---|
| **Leg swings** — 2 x 10 each side | Hold a wall; loose hips, full swing |
| **A-skips** — 3 x 20m, walk back | Tall posture, quick ground contact |

## Main set

| Exercise | How |
|---|---|
| **Steady run** — 25min | 82% threshold pace, nose-breathing |
| **Strides** — 5 x 20s, 40s walk | Relaxed fast, ~95%, drive the arms |

### Cool-down

- Easy jog 5min
- Calf stretch 2 x 30s

> Back off if the legs feel flat.

---

**Load:** about 55 TSS
**Why:** CTL 48, ATL 41 — room for a steady day.
''';

const _steps = '''
Builds threshold power with controlled recovery.
- 15m 60% Easy spin, high cadence
3x
  - 8m 100% Threshold interval, steady seat
  - 4m 55% Easy spin
- 10m 55%
''';

void main() {
  group('parseWorkoutText', () {
    test('notes, repeats, steps and their nesting', () {
      final lines = parseWorkoutText(_steps);
      expect(lines[0], isA<WorkoutNote>());
      final warm = lines[1] as WorkoutStep;
      expect(warm.amount, '15m');
      expect(warm.target, '60%');
      expect(warm.text, 'Easy spin, high cadence');
      expect((lines[2] as WorkoutRepeat).count, 3);
      final inner = lines[3] as WorkoutStep;
      expect(inner.level, 1);
      expect(inner.percent, 100);
      expect((lines[4] as WorkoutStep).text, 'Easy spin');
      expect((lines.last as WorkoutStep).level, 0);
    });

    test('swim distances, repeats on the step, pace targets', () {
      final lines = parseWorkoutText('''
- 300mtr Warm up, easy
- 4x50mtr Catch-up drill
- 200mtr 1:45/100m w/ paddles
- 20m 95% Pace
- 10m 85-90% Tempo''');
      final steps = lines.cast<WorkoutStep>();
      expect(steps[0].amount, '300mtr');
      expect(steps[0].target, isNull);
      expect(steps[1].amount, '4x50mtr');
      expect(steps[1].text, 'Catch-up drill');
      expect(steps[2].target, '1:45/100m');
      expect(steps[2].text, 'w/ paddles');
      expect(steps[3].target, '95% Pace');
      expect(steps[3].percent, 95);
      expect(steps[4].percent, 87.5);
    });

    test('text without steps is not structured', () {
      expect(
        hasWorkoutSteps(parseWorkoutText('Easy day, listen to the legs.')),
        isFalse,
      );
      expect(hasWorkoutSteps(parseWorkoutText(_steps)), isTrue);
    });

    test('intensity colours step up with the percentage', () {
      final scheme = ColorScheme.fromSeed(seedColor: Colors.teal);
      final colors = [
        for (final p in [40.0, 65.0, 85.0, 100.0, 115.0, 140.0])
          intensityColor(p, scheme),
      ];
      expect(colors.toSet().length, 6);
      expect(intensityColor(null, scheme), scheme.outline);
    });
  });

  Widget app(Widget child, {Brightness brightness = Brightness.light}) =>
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: brightness,
          ),
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      );

  group('WorkoutDescription', () {
    testWidgets('draws steps with durations, targets and repeat blocks', (
      tester,
    ) async {
      await tester.pumpWidget(app(const WorkoutDescription(text: _steps)));
      expect(find.byKey(const ValueKey('workout-steps')), findsOneWidget);
      expect(find.text('15m'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('3 ×'), findsOneWidget);
      expect(find.text('Threshold interval, steady seat'), findsOneWidget);
      expect(
        find.text('Builds threshold power with controlled recovery.'),
        findsOneWidget,
      );
    });

    testWidgets('a plain note is shown as it is', (tester) async {
      await tester.pumpWidget(
        app(const WorkoutDescription(text: 'Coach says: easy day.')),
      );
      expect(find.byKey(const ValueKey('workout-steps')), findsNothing);
      expect(find.text('Coach says: easy day.'), findsOneWidget);
    });

    testWidgets('fits a narrow phone at large text, light and dark', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      for (final b in Brightness.values) {
        await tester.pumpWidget(
          app(const WorkoutDescription(text: _steps), brightness: b),
        );
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('MarkdownReply', () {
    testWidgets('renders a detailed proposal with the app styling', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        app(const MarkdownReply(text: _detailedProposal)),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);

      // ## becomes a section heading, ### an upper-cased eyebrow.
      expect(find.text('Warm-up'), findsOneWidget);
      expect(find.text('Main set'), findsOneWidget);
      expect(find.text('COOL-DOWN'), findsOneWidget);
      // Table content, bullets and the callout are all there.
      expect(find.textContaining('Leg swings'), findsOneWidget);
      expect(find.textContaining('Strides'), findsOneWidget);
      expect(find.textContaining('Easy jog 5min'), findsOneWidget);
      expect(
        find.textContaining('Back off if the legs feel flat'),
        findsOneWidget,
      );
      expect(find.textContaining('about 55 TSS'), findsOneWidget);
    });

    testWidgets('numbered lists get badges, nested bullets are lighter', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          const MarkdownReply(
            text: '1. First\n2. Second\n\n- one\n  - nested\n',
          ),
        ),
      );
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('nested'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('survives dark mode and large text', (tester) async {
      tester.view.physicalSize = const Size(320, 1600);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(
        app(
          const MarkdownReply(text: _detailedProposal),
          brightness: Brightness.dark,
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
