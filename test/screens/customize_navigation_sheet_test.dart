import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/navigation/navigation_layout.dart';
import 'package:triiq/navigation/okf_index.dart';
import 'package:triiq/screens/more/customize_navigation_sheet.dart';
import 'package:triiq/screens/more/more_screen.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    Size size = const Size(412, 1400),
    double textScale = 1,
    Locale locale = const Locale('en'),
    ThemeData? theme,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: Scaffold(body: child),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Finder row(String id) => find.byKey(ValueKey('nav-item-$id'));

  testWidgets('the buttons reorder, move to More and pin to the bar', (
    tester,
  ) async {
    final layout = NavigationLayout.forTesting();
    await pump(tester, CustomizeNavigationSheet(layout: layout));

    await tester.tap(find.byKey(const ValueKey('nav-up-chat')));
    await tester.pumpAndSettle();
    expect(layout.bar, ['today', 'chat', 'calendar', 'insights']);

    await tester.tap(find.byKey(const ValueKey('nav-toggle-insights')));
    await tester.pumpAndSettle();
    expect(layout.bar, ['today', 'chat', 'calendar']);
    expect(layout.more.first, 'insights');
    expect(find.byTooltip('Pin to bar'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('nav-toggle-plan')));
    await tester.pumpAndSettle();
    expect(layout.bar.last, 'plan');
    // The preview follows.
    final preview = tester.widget<NavigationBar>(
      find.byKey(const ValueKey('nav-preview')),
    );
    expect(
      [
        for (final d in preview.destinations)
          (d as NavigationDestination).label,
      ],
      ['Today', 'Chat', 'Calendar', 'Plan', 'More'],
    );
  });

  testWidgets('a move that breaks a limit is refused with a message', (
    tester,
  ) async {
    final layout = NavigationLayout.forTesting();
    await pump(tester, CustomizeNavigationSheet(layout: layout));

    await tester.tap(find.byKey(const ValueKey('nav-toggle-sync')));
    await tester.pumpAndSettle();
    expect(layout.isDefault, isTrue);
    expect(
      find.text(
        'The bottom bar is full (4 items plus More). Move an item to More '
        'first.',
      ),
      findsOneWidget,
    );

    await layout.moveToMore('insights');
    await layout.moveToMore('chat');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('nav-toggle-today')));
    await tester.pumpAndSettle();
    expect(layout.bar, ['today', 'calendar']);
    expect(
      find.text('The bottom bar needs at least 2 items besides More.'),
      findsOneWidget,
    );
    expect(
      find.text('Bottom bar: 2 of 4 places used besides More (at least 2)'),
      findsOneWidget,
    );
  });

  testWidgets('reset brings back the default and is off while it is the '
      'default', (tester) async {
    final layout = NavigationLayout.forTesting();
    await pump(tester, CustomizeNavigationSheet(layout: layout));
    TextButton reset() =>
        tester.widget(find.byKey(const ValueKey('nav-customize-reset')));
    expect(reset().onPressed, isNull);

    await layout.moveToMore('chat');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('nav-customize-reset')));
    await tester.pumpAndSettle();
    expect(layout.isDefault, isTrue);
  });

  Future<void> dragTo(WidgetTester tester, String id, Finder target) async {
    final handle = find.descendant(
      of: row(id),
      matching: find.byIcon(Icons.drag_handle),
    );
    final from = tester.getCenter(handle);
    final to = tester.getTopLeft(target);
    final gesture = await tester.startGesture(from);
    await tester.pump(const Duration(milliseconds: 100));
    const steps = 10;
    for (var i = 0; i < steps; i++) {
      await gesture.moveBy(Offset(0, (to.dy - from.dy) / steps));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await gesture.up();
    await tester.pumpAndSettle();
  }

  testWidgets('dragging reorders within the bar and moves items across the '
      'More header both ways', (tester) async {
    final layout = NavigationLayout.forTesting();
    await pump(tester, CustomizeNavigationSheet(layout: layout));

    // Insights onto Today's place: first in the bar.
    await dragTo(tester, 'insights', row('today'));
    expect(layout.bar.first, 'insights');

    // Calendar down into More.
    await dragTo(tester, 'calendar', row('season'));
    expect(layout.bar, isNot(contains('calendar')));
    expect(layout.more, contains('calendar'));

    // Sync up into the bar (there is room now).
    await dragTo(tester, 'sync', row('chat'));
    expect(layout.bar, contains('sync'));
    expect(layout.more, isNot(contains('sync')));
    expect(layout.bar.length, 4);
  });

  testWidgets('a screen reader moves items with the row\'s custom actions', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final layout = NavigationLayout.forTesting();
    await pump(tester, CustomizeNavigationSheet(layout: layout));

    SemanticsNode node(String label) {
      var n = tester.getSemantics(find.bySemanticsLabel(RegExp('^$label')));
      while ((n.getSemanticsData().customSemanticsActionIds ?? const [])
          .isEmpty) {
        n = n.parent!;
      }
      return n;
    }

    void perform(SemanticsNode n, String label) {
      final id = n.getSemanticsData().customSemanticsActionIds!.firstWhere(
        (id) => CustomSemanticsAction.getAction(id)!.label == label,
      );
      n.owner!.performAction(n.id, SemanticsAction.customAction, id);
    }

    final chat = node('Chat, In the bottom bar, position 3 of 4');
    final labels = [
      for (final id in chat.getSemanticsData().customSemanticsActionIds!)
        CustomSemanticsAction.getAction(id)!.label,
    ];
    expect(labels, containsAll(['Move up', 'Move down', 'Move to More']));

    perform(chat, 'Move up');
    await tester.pumpAndSettle();
    expect(layout.bar, ['today', 'chat', 'calendar', 'insights']);

    perform(node('Chat, In the bottom bar'), 'Move to More');
    await tester.pumpAndSettle();
    expect(layout.more.first, 'chat');

    perform(node('Season, In More'), 'Pin to bar');
    await tester.pumpAndSettle();
    expect(layout.bar.last, 'season');
    handle.dispose();
  });

  testWidgets('the sheet meets tap-target and label guidelines', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(
      tester,
      CustomizeNavigationSheet(layout: NavigationLayout.forTesting()),
    );
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });

  for (final locale in const [Locale('en'), Locale('de')]) {
    testWidgets('no overflow at 360 dp and 2x text '
        '(${locale.languageCode}, light, dark)', (tester) async {
      final layout = NavigationLayout.forTesting();
      await layout.moveToMore('today');
      await layout.pinToBar('knowledge');
      await layout.pinToBar('memory');
      final errors = <String>[];
      final previous = FlutterError.onError;
      FlutterError.onError = (d) => errors.add(d.toString());
      try {
        for (final theme in [ThemeData.light(), ThemeData.dark()]) {
          await pump(
            tester,
            Builder(
              builder: (context) => Center(
                child: FilledButton(
                  onPressed: () =>
                      showCustomizeNavigationSheet(context, layout),
                  child: const Text('open'),
                ),
              ),
            ),
            size: const Size(360, 740),
            textScale: 2,
            locale: locale,
            theme: theme,
          );
          await tester.tap(find.text('open'));
          await tester.pumpAndSettle();
          await tester.drag(
            find.byKey(const ValueKey('nav-customize-list')),
            const Offset(0, -1500),
          );
          await tester.pumpAndSettle();
        }
      } finally {
        FlutterError.onError = previous;
      }
      expect(errors, isEmpty);
    });
  }

  group('More follows the layout', () {
    testWidgets('it lists what is not in the bar, in order, with group '
        'headers while groups stay together', (tester) async {
      final layout = NavigationLayout.forTesting();
      await layout.moveToMore('calendar');
      await layout.pinToBar('season');
      await pump(
        tester,
        MoreScreen(layout: layout, okf: Future.value(OkfIndex.parse(''))),
      );
      expect(find.byKey(const ValueKey('more-season')), findsNothing);
      expect(find.byKey(const ValueKey('more-calendar')), findsOneWidget);
      expect(find.text('MAIN SECTIONS'), findsOneWidget);
      expect(find.text('PLAN'), findsOneWidget);
      double y(String id) => tester.getTopLeft(find.byKey(ValueKey(id))).dy;
      expect(y('more-calendar'), lessThan(y('more-plan')));

      // Mixing the groups: one plain list.
      await layout.place('memory', inBar: false, index: 0);
      await tester.pump();
      expect(find.text('MAIN SECTIONS'), findsNothing);
      expect(find.text('PLAN'), findsNothing);
      expect(y('more-memory'), lessThan(y('more-calendar')));
    });

    testWidgets('the default More looks as it did', (tester) async {
      await pump(
        tester,
        MoreScreen(
          layout: NavigationLayout.forTesting(),
          okf: Future.value(OkfIndex.parse('')),
        ),
      );
      expect(find.text('PLAN'), findsOneWidget);
      expect(find.text('TRAINER'), findsOneWidget);
      expect(find.text('DATA'), findsOneWidget);
      expect(find.text('MAIN SECTIONS'), findsNothing);
    });

    testWidgets('Settings › Navigation shows the bar and opens the arranger', (
      tester,
    ) async {
      final layout = NavigationLayout.forTesting();
      await pump(tester, NavigationSettingsTile(layout: layout));
      expect(
        find.text('Bottom bar now: Today · Calendar · Chat · Insights · More'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('settings-customize-nav')));
      await tester.pumpAndSettle();
      expect(find.byType(CustomizeNavigationSheet), findsOneWidget);
    });
  });
}
