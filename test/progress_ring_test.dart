import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/widgets/gauge_ring.dart';
import 'package:triiq/widgets/progress_ring.dart';

void main() {
  ringIndicatorTests();
  const color = Color(0xFF0277BD);
  const doneColor = Colors.teal;

  group('ProgressRing progress math', () {
    test('under target: not done, arc colour, uncapped progress', () {
      const ring = ProgressRing(
        label: 'Swim',
        percentLabel: '60%',
        valueLabel: '1.2 / 2.0 h',
        progress: 0.6,
        color: color,
        doneColor: doneColor,
      );

      expect(ring.isDone, isFalse);
      expect(ring.ringColor, color);
      expect(ring.cappedProgress, 0.6);
    });

    test('exactly at target: done, switches to the done colour', () {
      const ring = ProgressRing(
        label: 'Run',
        percentLabel: '100%',
        valueLabel: '3.0 / 3.0 h',
        progress: 1.0,
        color: color,
        doneColor: doneColor,
      );

      expect(ring.isDone, isTrue);
      expect(ring.ringColor, doneColor);
      expect(ring.cappedProgress, 1.0);
    });

    test(
      'over target: still done, arc capped at 1.0 instead of overshooting',
      () {
        const ring = ProgressRing(
          label: 'Swim',
          percentLabel: '150%',
          valueLabel: '3.0 / 2.0 h',
          progress: 1.5,
          color: color,
          doneColor: doneColor,
        );

        expect(ring.isDone, isTrue);
        expect(ring.ringColor, doneColor);
        expect(ring.cappedProgress, 1.0);
      },
    );
  });

  testWidgets('renders the sport, percentage and value labels', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProgressRing(
            label: 'Cycle',
            percentLabel: '150%',
            valueLabel: '3.0 / 2.0 h',
            progress: 1.5,
            color: color,
            doneColor: doneColor,
          ),
        ),
      ),
    );

    expect(find.text('Cycle'), findsOneWidget);
    expect(find.text('150%'), findsOneWidget);
    expect(find.text('3.0 / 2.0 h'), findsOneWidget);
  });
}

void ringIndicatorTests() {
  const color = Color(0xFF0277BD);
  testWidgets('the sport icon sits inside the ring until the target is met', (
    tester,
  ) async {
    Widget ring(double progress) => MaterialApp(
      home: Scaffold(
        body: ProgressRing(
          label: 'Swim',
          percentLabel: '${(progress * 100).round()}%',
          valueLabel: '1 / 2 h',
          progress: progress,
          color: color,
          doneColor: Colors.teal,
          icon: Icons.pool,
        ),
      ),
    );

    await tester.pumpWidget(ring(0.4));
    expect(find.byKey(const ValueKey('ring-icon')), findsOneWidget);
    expect(find.byKey(const ValueKey('ring-done')), findsNothing);

    await tester.pumpWidget(ring(1.0));
    expect(find.byKey(const ValueKey('ring-done')), findsOneWidget);
    expect(find.byKey(const ValueKey('ring-icon')), findsNothing);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('a gauge animates to its value and clamps overshoot', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GaugeRing(
            progress: 1.7,
            color: color,
            size: 80,
            child: Text('x'),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    final paint = tester.widget<CustomPaint>(
      find
          .descendant(
            of: find.byType(GaugeRing),
            matching: find.byType(CustomPaint),
          )
          .first,
    );
    expect((paint.painter! as GaugePainter).progress, 1.0);
  });
}
