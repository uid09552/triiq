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

// Six weeks from 300 TSS propose 330, 363, 399, 439, 483, 531. Their bands
// span 265..635, so the axis runs 200..700 in 100-TSS ticks.
const _plot = 240 - 34 - 24; // default height minus paddings
const _pxPerTss = _plot / 500;

void main() {
  group('LoadCurveController', () {
    test('sets TSS on the 5-TSS grid inside the week band', () {
      final c = LoadCurveController(limits: _limits, weeks: 4);

      expect(c.dragTss(3, 360), isTrue);
      expect(c.targets[3], closeTo(360, 1e-9));
      expect((c.factors[3] * 100).round(), 82);
      expect(c.dragTss(3, 361), isFalse, reason: 'still 360 on the grid');

      c.dragTss(3, 1000);
      expect(c.targets[3], closeTo(525, 1e-9), reason: 'floor5(1.2 x 439.2)');
      c.dragTss(3, 0);
      expect(c.targets[3], closeTo(355, 1e-9), reason: 'ceil5(0.8 x 439.2)');
    });

    test('steps add to the current TSS and snap', () {
      final c = LoadCurveController(limits: _limits, weeks: 3)..stepTss(1, 25);
      expect(c.targets[1], closeTo(390, 1e-9), reason: '363 + 25, snapped');
      c.stepTss(1, -5);
      expect(c.targets[1], closeTo(385, 1e-9));
    });

    test('one undo entry per drag, and only when it moved', () {
      final c = LoadCurveController(limits: _limits, weeks: 4)
        ..beginDrag(2)
        ..endDrag();
      expect(c.canUndo, isFalse);

      c
        ..beginDrag(2)
        ..dragTss(2, 380)
        ..dragTss(2, 350)
        ..endDrag();
      expect(c.targets[2], closeTo(350, 1e-9));
      c.undo();
      expect(c.factors[2], 1.0);
      expect(c.canUndo, isFalse);
    });

    test('reset back to the exact proposal, and undo of a reset', () {
      final c = LoadCurveController(limits: _limits, weeks: 3)
        ..stepTss(0, 10)
        ..stepTss(2, -10);
      final edited = c.factors;

      c.reset();
      expect(c.isDefault, isTrue);
      expect(c.targets, proposeCurve(_limits, 3).loads);
      c.undo();
      expect(c.factors, edited);
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

    test('a TSS-set week keeps its share when the baseline changes', () {
      final c = LoadCurveController(limits: _limits, weeks: 2)
        ..dragTss(0, 300);
      final share = c.factors[0];

      c.update(
        limits: const CurveLimits(
          baseline: 400,
          rampCap: 0.10,
          maxCtlRamp: 7,
          recoveryThreshold: 0.9,
        ),
        weeks: 3,
      );

      expect(c.factors[0], share, reason: 'not re-snapped to 5%');
      expect(c.factors.skip(1), [1.0, 1.0]);
      expect(c.targets[0], closeTo(440 * share, 1e-9));
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

    testWidgets('the axis is in TSS', (tester) async {
      await pump(tester);

      expect(find.byType(LoadCurveEditor), findsOneWidget);
      // The axis is painted; its range shows in the semantics values.
      expect(
        tester.getSemantics(week(2)).getSemanticsData().value,
        '399 TSS',
      );
    });

    testWidgets('dragging is relative: up by 60 TSS from anywhere',
        (tester) async {
      var changes = 0;
      final c = await pump(tester, onChanged: () => changes++);
      // Press near the bottom of week 3's column, far from its point.
      final bottom =
          tester.getBottomLeft(week(2)) +
          Offset(tester.getSize(week(2)).width / 2, -30);

      await dragFrom(tester, bottom, -60 * _pxPerTss);

      expect(c.targets[2], closeTo(460, 1e-9));
      expect(c.factors.where((f) => f != 1.0), hasLength(1));
      expect(changes, 1);
      expect(find.text('Week 3 · 460 TSS · 115%'), findsOneWidget);
    });

    testWidgets('a drag far above stops at the top of the band',
        (tester) async {
      final c = await pump(tester);

      await dragFrom(tester, tester.getCenter(week(3)), -400);

      expect(c.targets[3], closeTo(525, 1e-9));
    });

    testWidgets('the label and warning update while dragging', (tester) async {
      final c = await pump(tester);
      final gesture = await tester.startGesture(tester.getCenter(week(4)));
      for (var i = 0; i < 8; i++) {
        await gesture.moveBy(const Offset(0, -10));
        await tester.pump();
      }

      // Not lifted yet: controller, selection label and warning are live.
      expect(c.targets[4], closeTo(575, 1e-9));
      expect(c.flags[4], contains(WeekLimit.weeklyIncrease));
      expect(find.text('Week 5 · 575 TSS · 119%'), findsOneWidget);
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

      await dragFrom(tester, tester.getCenter(week(1)), 20);
      expect(c.targets[1], lessThan(363));
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

    testWidgets('tap selects; buttons and arrow keys step by 5 TSS, Shift 25',
        (tester) async {
      final c = await pump(tester);

      await tester.tap(week(1));
      await tester.pump();
      expect(c.selected, 1);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(c.targets[1], closeTo(375, 1e-9), reason: '363 -> 370 -> 375');

      await tester.tap(find.byTooltip('Decrease by 5 TSS'));
      await tester.pump();
      expect(c.targets[1], closeTo(370, 1e-9));

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(c.targets[1], closeTo(395, 1e-9));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(c.selected, 2);
      expect(c.targets[2], closeTo(395, 1e-9), reason: '399.3 - 5 = 394.3, snapped');
    });

    testWidgets('undo restores the week a drag moved', (tester) async {
      final c = await pump(tester);
      final before = c.targets[5];

      await dragFrom(tester, tester.getCenter(week(5)), 80 * _pxPerTss);
      expect(c.targets[5], closeTo(450, 1e-9));

      await tester.tap(find.byTooltip('Undo'));
      await tester.pump();
      expect(c.targets[5], before);
    });

    testWidgets('reset asks first', (tester) async {
      final c = await pump(tester);
      c.stepTss(0, -20);
      await tester.pump();

      await tester.tap(find.widgetWithText(TextButton, 'Reset'));
      await tester.pumpAndSettle();
      expect(find.text('Reset the load curve?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(c.isDefault, isFalse);

      await tester.tap(find.widgetWithText(TextButton, 'Reset'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Reset'));
      await tester.pumpAndSettle();
      expect(c.isDefault, isTrue);
    });

    testWidgets('every week is a screen-reader slider in TSS', (tester) async {
      final handle = tester.ensureSemantics();
      final c = await pump(tester);

      final data = tester.getSemantics(week(2)).getSemanticsData();
      expect(data.label, 'Week 3, 100% of proposal');
      expect(data.value, '399 TSS');
      expect(data.increasedValue, '405 TSS');
      expect(data.hasAction(SemanticsAction.increase), isTrue);

      tester.semantics.decrease(
        find.semantics.byLabel('Week 3, 100% of proposal'),
      );
      await tester.pump();
      expect(c.targets[2], closeTo(395, 1e-9));
      handle.dispose();
    });

    testWidgets('paints in light and dark without errors', (tester) async {
      for (final theme in [ThemeData.light(), ThemeData.dark()]) {
        final c = await pump(tester, theme: theme);
        c.stepTss(1, 40);
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('read-only: no drag, no controls', (tester) async {
      tester.view.physicalSize = const Size(800, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final c = LoadCurveController(limits: _limits, weeks: 6);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: LoadCurveEditor(
              controller: c,
              readOnly: true,
              highlight: const {3},
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('load-week-2')), findsNothing);
      expect(find.byTooltip('Undo'), findsNothing);
      await tester.dragFrom(const Offset(300, 120), const Offset(0, -80));
      await tester.pump();
      expect(c.isDefault, isTrue);
    });
  });
}
