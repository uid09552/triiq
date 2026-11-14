import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/app.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/navigation/navigation_layout.dart';
import 'package:triiq/navigation/shell_tab.dart';
import 'package:triiq/screens/calendar/calendar_screen.dart';
import 'package:triiq/screens/chat/chat_screen.dart';
import 'package:triiq/screens/more/customize_navigation_sheet.dart';
import 'package:triiq/screens/plan/plan_screen.dart';
import 'package:triiq/screens/sync/sync_screen.dart';
import 'package:triiq/widgets/main_navigation.dart';
import 'package:triiq/widgets/main_shell.dart';

void main() {
  setUp(() {
    // Past the first-run flow (covered in onboarding_test.dart).
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    MainNavigation.instance.debugReset();
  });

  NavigationBar bar(WidgetTester tester) =>
      tester.widget(find.byKey(const ValueKey('nav-bar')));

  List<String> labels(WidgetTester tester) => [
    for (final d in bar(tester).destinations)
      (d as NavigationDestination).label,
  ];

  /// Lets the screens' loads on the shared database finish, so they don't
  /// hold its lock into the next test.
  Future<void> drain(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }
    // Unmount, then let debounce timers run out.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 10));
  }

  /// Not pumpAndSettle: Today's loading spinner never settles.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> pumpShell(
    WidgetTester tester,
    NavigationLayout layout, {
    Size size = const Size(412, 915),
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
            child: MainShell(layout: layout),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('openCalendar selects the Calendar tab and shows the date', (
    tester,
  ) async {
    await tester.pumpWidget(const TriiqApp());
    await tester.pump();

    final items = NavigationLayout.instance.barWithMore;
    expect(bar(tester).selectedIndex, items.indexOf(MainNavigation.todayTab));

    MainNavigation.instance.openCalendar(DateTime(2027, 3, 10, 15));
    await tester.pump();
    await tester.pump();

    expect(
      bar(tester).selectedIndex,
      items.indexOf(MainNavigation.calendarTab),
    );
    // The breadcrumb: 2027 › March.
    expect(find.text('2027'), findsOneWidget);
    expect(find.text('March'), findsOneWidget);
    expect(MainNavigation.instance.calendarFocus!.date, DateTime(2027, 3, 10));
    await drain(tester);
  });

  testWidgets('the bar is built from the layout; the app opens on its first '
      'item', (tester) async {
    final layout = NavigationLayout.forTesting();
    await layout.moveToMore('today');
    await layout.moveToMore('insights');
    await layout.pinToBar('plan');
    await layout.shift('chat', -1);
    await pumpShell(tester, layout);

    expect(labels(tester), ['Chat', 'Calendar', 'Plan', 'More']);
    expect(bar(tester).selectedIndex, 0);
    expect(find.byType(ChatScreen), findsOneWidget);
    // Built lazily: the Plan tab only once it is shown.
    expect(find.byType(PlanScreen, skipOffstage: false), findsNothing);
    await drain(tester);
  });

  testWidgets('the selection follows its item when the bar is reordered, and '
      'falls back to More when it leaves the bar', (tester) async {
    final layout = NavigationLayout.forTesting();
    await pumpShell(tester, layout);
    await tester.tap(find.byKey(const ValueKey('nav-calendar')));
    await tester.pump();
    expect(bar(tester).selectedIndex, 1);

    await layout.shift('calendar', 1);
    await tester.pump();
    expect(labels(tester), ['Today', 'Chat', 'Calendar', 'Insights', 'More']);
    expect(bar(tester).selectedIndex, 2);
    expect(find.byType(CalendarScreen), findsOneWidget);

    await layout.moveToMore('calendar');
    await tester.pump();
    expect(labels(tester), ['Today', 'Chat', 'Insights', 'More']);
    expect(bar(tester).selectedIndex, 3);
    expect(tester.takeException(), isNull);
    // More now lists Calendar.
    expect(find.byKey(const ValueKey('more-calendar')), findsOneWidget);
    await drain(tester);
  });

  testWidgets('a destination in the bar is selected; one in More is pushed '
      'from wherever the athlete is', (tester) async {
    final layout = NavigationLayout.forTesting();
    await layout.moveToMore('chat');
    await layout.pinToBar('sync');
    await pumpShell(tester, layout);

    // Sync is a tab now: selected, not pushed.
    MainNavigation.instance.openTab('sync');
    await settle(tester);
    expect(labels(tester)[bar(tester).selectedIndex], 'Sync');
    expect(find.byType(SyncScreen), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);

    // Chat lives in More: its page is pushed, with a back button.
    MainNavigation.instance.openTab(MainNavigation.chatTab);
    await settle(tester);
    expect(find.byType(ChatScreen), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await settle(tester);
    expect(find.byType(ChatScreen), findsNothing);
    expect(labels(tester)[bar(tester).selectedIndex], 'Sync');
    await drain(tester);
  });

  testWidgets('openCalendar opens the Calendar page at the date when the '
      'Calendar lives in More', (tester) async {
    final layout = NavigationLayout.forTesting();
    await layout.moveToMore('calendar');
    await pumpShell(tester, layout);

    MainNavigation.instance.openCalendar(DateTime(2027, 3, 10));
    await settle(tester);
    expect(find.byType(CalendarScreen), findsOneWidget);
    // Its stored level and date are read first; the asked-for date wins.
    for (var i = 0; i < 4; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }
    expect(find.text('2027'), findsOneWidget);
    expect(find.text('March'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
    await drain(tester);
  });

  testWidgets('a pinned More page is a tab with one top bar, its own title '
      'and the profile button', (tester) async {
    final layout = NavigationLayout.forTesting();
    await layout.moveToMore('insights');
    await layout.pinToBar('plan');
    await pumpShell(tester, layout);

    await tester.tap(find.byKey(const ValueKey('nav-plan')));
    await tester.pump();
    await tester.pump();
    expect(find.byType(PlanScreen), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Training plans'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byType(ProfileButton),
      ),
      findsOneWidget,
    );
    expect(find.byType(BackButton), findsNothing);

    // Back on a core tab, the shell's top bar is back.
    await tester.tap(find.byKey(const ValueKey('nav-today')));
    await tester.pump();
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Today')),
      findsOneWidget,
    );
    await drain(tester);
  });

  testWidgets('long-pressing the bar and More\'s top-right button open the '
      'arranger', (tester) async {
    final layout = NavigationLayout.forTesting();
    await pumpShell(tester, layout);

    await tester.longPress(find.byKey(const ValueKey('nav-chat')));
    await settle(tester);
    expect(find.byType(CustomizeNavigationSheet), findsOneWidget);
    // A tap on a destination still just switches.
    Navigator.of(tester.element(find.byType(CustomizeNavigationSheet))).pop();
    await settle(tester);
    expect(find.byType(CustomizeNavigationSheet), findsNothing);
    expect(bar(tester).selectedIndex, 0);

    await tester.tap(find.byKey(const ValueKey('nav-more')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('customize-nav-button')));
    await settle(tester);
    expect(find.byType(CustomizeNavigationSheet), findsOneWidget);
    await drain(tester);
  });

  testWidgets('the bar exposes the arranger as its long-press action', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final layout = NavigationLayout.forTesting();
    await pumpShell(tester, layout);
    final node = tester.getSemantics(
      find
          .ancestor(
            of: find.byKey(const ValueKey('nav-bar')),
            matching: find.byType(Semantics),
          )
          .first,
    );
    expect(
      node.getSemanticsData().hasAction(SemanticsAction.longPress),
      isTrue,
    );
    node.owner!.performAction(node.id, SemanticsAction.longPress);
    await settle(tester);
    expect(find.byType(CustomizeNavigationSheet), findsOneWidget);
    handle.dispose();
    await drain(tester);
  });

  for (final locale in const [Locale('en'), Locale('de')]) {
    testWidgets('five items with long labels fit at 360 dp and 2x text '
        '(${locale.languageCode}, light, dark, Developer)', (tester) async {
      final layout = NavigationLayout.forTesting();
      await layout.moveToMore('today');
      await layout.moveToMore('chat');
      await layout.pinToBar('events');
      await layout.pinToBar('memory');
      final errors = <String>[];
      final previous = FlutterError.onError;
      FlutterError.onError = (d) => errors.add(d.exceptionAsString());
      try {
        for (final theme in [
          ThemeData.light(),
          ThemeData.dark(),
          ThemeData(
            brightness: Brightness.dark,
            fontFamily: 'monospace',
            navigationBarTheme: const NavigationBarThemeData(height: 64),
          ),
        ]) {
          await pumpShell(
            tester,
            layout,
            size: const Size(360, 740),
            textScale: 2,
            locale: locale,
            theme: theme,
          );
          await tester.pump(const Duration(milliseconds: 300));
        }
        expect(labels(tester), hasLength(5));
        await drain(tester);
      } finally {
        FlutterError.onError = previous;
      }
      expect(errors, isEmpty);
    });
  }
}
