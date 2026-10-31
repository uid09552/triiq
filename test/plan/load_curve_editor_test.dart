import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/plan/load_curve.dart';
import 'package:triiq/plan/load_curve_controller.dart';
import 'package:triiq/plan/plan_models.dart';
import 'package:triiq/widgets/charts/load_curve_editor.dart';

const _limits = CurveLimits(
  baseline: 300,
  rampCap: 0.10,
  maxCtlRamp: 7,
  recoveryThreshold: 0.9,
);

/// One 5% step in pixels at the default height (240 - 34 - 24 = 182 plot).
const _step = 182 * 0.05 / 0.4;

void main() {
  group('LoadCurveController', () {
    test('snaps, clamps and reports changes', () {
      final c = LoadCurveController(limits: _limits, weeks: 4);

      expect(c.drag(1, 1.07), isTrue);
      expect(c.factors[1], 1.05);
      expect(c.drag(1, 1.06), isFalse, reason: 'same 5% step');
      c.drag(1, 3);
      expect(c.factors[1], 1.2);
      c.drag(1, 0);
      expect(c.factors[1], 0.8);
    });

    test('one undo entry per drag, and only when it moved', () {
      final c = LoadCurveController(limits: _limits, weeks: 4)
        ..beginDrag(2)
        ..endDrag();
      expect(c.canUndo, isFalse);

      c
        ..beginDrag(2)
        ..drag(2, 0.95)
        ..drag(2, 0.85)
        ..endDrag();
      expect(c.factors[2], 0.85);
      c.undo();
      expect(c.factors[2], 1.0);
      expect(c.canUndo, isFalse);
    });

    test('steps, reset and undo of a reset', () {
      final c = LoadCurveController(limits: _limits, weeks: 3)
        ..step(0, 2)
        ..step(2, -1);
      expect(c.factors, [1.1, 1.0, 0.95]);

      c.reset();
      expect(c.isDefault, isTrue);
      c.undo();
      expect(c.factors, [1.1, 1.0, 0.95]);
    });

    test('flags match what the engine computes for the same targets', () {
      final c = LoadCurveController(
        limits: _limits,
        weeks: 4,
        factors: [1, 1, 1.2, 0.8],
      );
      final proposal = proposeCurve(_limits, 4).loads;
      final targets = [for (var i = 0; i < 4; i++) proposal[i] * c.factors[i]];

      expect(c.flags, flagWeeks(_limits, targets, proposal: proposal));
      expect(c.flags[2], {WeekLimit.weeklyIncrease});
      expect(c.phases[3], recoveryPhase);
    });

    test('a new baseline keeps the percentages', () {
      final c = LoadCurveController(limits: _limits, weeks: 2, factors: [0.9]);
      c.update(
        limits: const CurveLimits(
          baseline: 400,
          rampCap: 0.10,
          maxCtlRamp: 7,
          recoveryThreshold: 0.9,
        ),
        weeks: 3,
      );

      expect(c.factors, [0.9, 1.0, 1.0]);
      expect(c.targets[0], closeTo(440 * 0.9, 1e-9));
    });
  });

  group('LoadCurveEditor', () {
    Future<LoadCurveController> pump(
      WidgetTester tester, {
      int weeks = 6,
      double width = 800,
      ThemeData? theme,
      VoidCallback? onChanged,
    }) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final controller = LoadCurveController(limits: _limits, weeks: weeks);
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: LoadCurveEditor(
                controller: controller,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      );
      return controller;
    }

    Finder week(int i) => find.byKey(ValueKey('load-week-$i'));

    Future<void> dragFrom(
      WidgetTester tester,
      Offset start,
      double dy, {
      int moves = 6,
    }) async {
      final gesture = await tester.startGesture(start);
      for (var i = 0; i < moves; i++) {
        await gesture.moveBy(Offset(0, dy / moves));
        await tester.pump();
      }
      await gesture.up();
      await tester.pump();
    }

    testWidgets('dragging is relative: up two steps from anywhere is +10%',
        (tester) async {
      var changes = 0;
      final c = await pump(tester, onChanged: () => changes++);
      // Press near the bottom of week 3's column, far from its point.
      final bottom = tester.getBottomLeft(week(2)) +
          Offset(tester.getSize(week(2)).width / 2, -30);

      await dragFrom(tester, bottom, -2 * _step);

      expect(c.factors[2], 1.1);
      expect(c.factors.where((f) => f != 1.0), hasLength(1));
      expect(changes, 1);
      expect(find.text('Week 3 · 110% · 439 TSS'), findsOneWidget);
    });

    testWidgets('a drag far above stops at 120%', (tester) async {
      final c = await pump(tester);

      await dragFrom(tester, tester.getCenter(week(3)), -400);

      expect(c.factors[3], 1.2);
    });

    testWidgets('the label and warning update while dragging', (tester) async {
      final c = await pump(tester);
      final gesture = await tester.startGesture(tester.getCenter(week(4)));
      for (var i = 0; i < 8; i++) {
        await gesture.moveBy(const Offset(0, -_step / 2));
        await tester.pump();
      }

      // Not lifted yet: the controller, selection label and warning are live.
      expect(c.factors[4], 1.2);
      expect(c.flags[4], contains(WeekLimit.weeklyIncrease));
      expect(find.textContaining('Week 5 · 120%'), findsOneWidget);
      expect(find.textContaining('More than +10%'), findsOneWidget);
      await gesture.up();
    });

    testWidgets('16 weeks on a 360 px screen scroll; a vertical drag changes '
        'one week only', (tester) async {
      final c = await pump(tester, weeks: 16, width: 360);

      expect(find.byKey(const ValueKey('load-curve-scroll')), findsOneWidget);
      expect(
        tester.getSize(week(0)).width,
        greaterThanOrEqualTo(LoadCurveEditor.minColumnWidth),
      );

      await dragFrom(tester, tester.getCenter(week(1)), 2 * _step);
      expect(c.factors[1], 0.9);
      expect(c.factors.where((f) => f != 1.0), hasLength(1));

      // A horizontal swipe scrolls instead of editing.
      await tester.drag(
        find.byKey(const ValueKey('load-curve-scroll')),
        const Offset(-200, 0),
      );
      await tester.pumpAndSettle();
      expect(c.factors.where((f) => f != 1.0), hasLength(1));
      expect(tester.getTopLeft(week(0)).dx, lessThan(0));
    });

    testWidgets('tap selects; buttons and arrow keys step by 5%',
        (tester) async {
      final c = await pump(tester);

      await tester.tap(week(1));
      await tester.pump();
      expect(c.selected, 1);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(c.factors[1], 1.1);

      await tester.tap(find.byTooltip('Decrease by 5%'));
      await tester.pump();
      expect(c.factors[1], 1.05);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(c.selected, 2);
      expect(c.factors[2], 0.95);
    });

    testWidgets('undo restores the week a drag moved', (tester) async {
      final c = await pump(tester);

      await dragFrom(tester, tester.getCenter(week(5)), 3 * _step);
      expect(c.factors[5], 0.85);

      await tester.tap(find.byTooltip('Undo'));
      await tester.pump();
      expect(c.factors[5], 1.0);
    });

    testWidgets('reset asks first', (tester) async {
      final c = await pump(tester);
      c.step(0, -2);
      await tester.pump();

      await tester.tap(find.widgetWithText(TextButton, 'Reset'));
      await tester.pumpAndSettle();
      expect(find.text('Reset the load curve?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(c.factors[0], 0.9);

      await tester.tap(find.widgetWithText(TextButton, 'Reset'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Reset'));
      await tester.pumpAndSettle();
      expect(c.isDefault, isTrue);
    });

    testWidgets('every week is a screen-reader slider', (tester) async {
      final handle = tester.ensureSemantics();
      final c = await pump(tester);

      final node = tester.getSemantics(week(2));
      final data = node.getSemanticsData();
      expect(data.label, 'Week 3, 399 TSS');
      expect(data.value, '100%');
      expect(data.increasedValue, '105%');
      expect(data.hasAction(SemanticsAction.increase), isTrue);

      tester.semantics.decrease(find.semantics.byLabel('Week 3, 399 TSS'));
      await tester.pump();
      expect(c.factors[2], 0.95);
      handle.dispose();
    });

    testWidgets('paints in light and dark without errors', (tester) async {
      for (final theme in [ThemeData.light(), ThemeData.dark()]) {
        final c = await pump(tester, theme: theme);
        c.step(1, 4);
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    });
  });
}
