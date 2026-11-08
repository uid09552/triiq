import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/app.dart';
import 'package:triiq/screens/today/today_layout_settings.dart';
import 'package:triiq/widgets/section_card.dart';

void main() {
  // One app for every size: the full app shares one database per test file,
  // so it is pumped once and the window resized.
  testWidgets('phone, tablet and desktop widths', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    await tester.pumpWidget(const TriiqApp());
    await tester.pump();

    // Phone: bottom bar, one column.
    expect(find.byKey(const ValueKey('nav-bar')), findsOneWidget);
    expect(find.byKey(const ValueKey('nav-rail')), findsNothing);
    expect(find.byKey(const ValueKey('today-two-columns')), findsNothing);
    expect(tester.takeException(), isNull);

    // Tablet: a compact rail.
    tester.view.physicalSize = const Size(900, 1000);
    await tester.pump();
    expect(
      tester
          .widget<NavigationRail>(find.byKey(const ValueKey('nav-rail')))
          .extended,
      isFalse,
    );

    // Desktop 1280×800: extended rail, Today in two columns.
    tester.view.physicalSize = const Size(1280, 800);
    await tester.pump();
    expect(find.byKey(const ValueKey('nav-bar')), findsNothing);
    expect(
      tester
          .widget<NavigationRail>(find.byKey(const ValueKey('nav-rail')))
          .extended,
      isTrue,
    );
    expect(find.byKey(const ValueKey('today-two-columns')), findsOneWidget);
    expect(tester.takeException(), isNull);

    // The rail switches tabs; Insights lays its charts out two by two.
    await tester.tap(find.text('Insights').last);
    await tester.pump();
    expect(
      find.byKey(const ValueKey('responsive-two-columns')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  group('Today layout defaults', () {
    test('a new install gets the lean layout', () async {
      SharedPreferences.setMockInitialValues({});
      final layout = TodayLayoutSettings.forTesting();
      await layout.load();
      expect(layout.order.take(2), [
        TodaySection.readiness,
        TodaySection.todaysTraining,
      ]);
      for (final s in TodayLayoutSettings.defaultHidden) {
        expect(layout.isVisible(s), isFalse, reason: s.name);
      }
      expect(layout.isVisible(TodaySection.metrics), isTrue);
    });

    test('an existing install keeps every section', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
      final layout = TodayLayoutSettings.forTesting();
      await layout.load();
      expect(layout.order, TodaySection.values);
      expect(TodaySection.values.every(layout.isVisible), isTrue);
      // Remembered from now on, so a later load agrees.
      final again = TodayLayoutSettings.forTesting();
      await again.load();
      expect(again.order, TodaySection.values);
    });

    test('a saved layout is left alone', () async {
      SharedPreferences.setMockInitialValues({
        'today.section_order': ['athlete', 'readiness'],
        'today.hidden_sections': <String>[],
      });
      final layout = TodayLayoutSettings.forTesting();
      await layout.load();
      expect(layout.order.first, TodaySection.athlete);
      expect(layout.isVisible(TodaySection.athlete), isTrue);
    });

    test('folding persists; reset restores the lean default', () async {
      SharedPreferences.setMockInitialValues({});
      final layout = TodayLayoutSettings.forTesting();
      await layout.load();
      await layout.setCollapsed(TodaySection.todaysTraining, true);
      final again = TodayLayoutSettings.forTesting();
      await again.load();
      expect(again.isCollapsed(TodaySection.todaysTraining), isTrue);
      await again.reset();
      expect(again.isCollapsed(TodaySection.todaysTraining), isFalse);
      expect(again.isVisible(TodaySection.athlete), isFalse);
    });
  });

  testWidgets('a foldable section card hides its body on a header tap', (
    tester,
  ) async {
    var collapsed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => SectionCard(
              title: 'Today',
              collapsed: collapsed,
              onToggleCollapsed: () => setState(() => collapsed = !collapsed),
              child: const Text('body'),
            ),
          ),
        ),
      ),
    );
    expect(find.text('body'), findsOneWidget);
    await tester.tap(find.text('Today'));
    await tester.pump();
    expect(find.text('body'), findsNothing);
    expect(find.byKey(const ValueKey('section-fold')), findsOneWidget);
    await tester.tap(find.text('Today'));
    await tester.pump();
    expect(find.text('body'), findsOneWidget);
  });
}
