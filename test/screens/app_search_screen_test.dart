import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/navigation/app_destinations.dart';
import 'package:triiq/navigation/okf_index.dart';
import 'package:triiq/screens/chat/navigation_card.dart';
import 'package:triiq/screens/more/more_screen.dart';
import 'package:triiq/screens/settings/settings_screen.dart';
import 'package:triiq/widgets/main_navigation.dart';

void main() {
  final okf = OkfIndex.parse(File('docs/okf.md').readAsStringSync());

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    MainNavigation.instance.debugReset();
  });

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    Locale locale = const Locale('en'),
    ThemeData? theme,
    Size size = const Size(400, 900),
    double textScale = 1,
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

  Future<void> search(WidgetTester tester, String query) async {
    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('more-search')),
        matching: find.byType(TextField),
      ),
      query,
    );
    await tester.pump();
  }

  testWidgets('a search lists matches with path and description, and '
      'clearing it brings the More list back', (tester) async {
    await pump(tester, MoreScreen(okf: Future.value(okf)));
    expect(find.text('Training plans'), findsOneWidget);

    await search(tester, 'durability');
    expect(
      find.byKey(const ValueKey('search-result-insights.durability')),
      findsOneWidget,
    );
    expect(find.text('Insights › Durability'), findsOneWidget);
    expect(
      find.text('How much power you keep once you are already fatigued.'),
      findsOneWidget,
    );
    expect(find.text('Training plans'), findsNothing);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    expect(find.text('Training plans'), findsOneWidget);
  });

  testWidgets('German titles and paths, matched by a German word', (
    tester,
  ) async {
    await pump(
      tester,
      MoreScreen(okf: Future.value(okf)),
      locale: const Locale('de'),
    );
    await search(tester, 'Ruhepuls');
    expect(find.text('Einblicke › Wellness-Trends'), findsOneWidget);
  });

  testWidgets('no match says so', (tester) async {
    await pump(tester, MoreScreen(okf: Future.value(okf)));
    await search(tester, 'xyzzyqq');
    expect(find.text('Nothing in the app matches “xyzzyqq”.'), findsOneWidget);
  });

  testWidgets('tapping a setting result opens its Settings page', (
    tester,
  ) async {
    await pump(tester, MoreScreen(okf: Future.value(okf)));
    await search(tester, 'dark mode');
    await tester.tap(
      find.byKey(const ValueKey('search-result-settings.appearance')),
    );
    await tester.pumpAndSettle();
    final screen = tester.widget<SettingsGroupScreen>(
      find.byType(SettingsGroupScreen),
    );
    expect(screen.group, SettingsGroup.app);
    expect(screen.focus, SettingsSection.appearance);
  });

  testWidgets('tapping a tab result switches the shell to that tab', (
    tester,
  ) async {
    await pump(tester, MoreScreen(okf: Future.value(okf)));
    await search(tester, 'calendar');
    await tester.tap(find.byKey(const ValueKey('search-result-tab.calendar')));
    await tester.pump();
    expect(MainNavigation.instance.requestedTab, MainNavigation.calendarTab);
  });

  testWidgets('tapping a pushed-screen result opens that screen', (
    tester,
  ) async {
    final target = AppDestination(
      id: 'test.target',
      icon: Icons.star,
      title: (_) => 'Target page',
      okfAnchor: 'More',
      open: (context) => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('target opened')),
        ),
      ),
    );
    await pump(tester, MoreScreen(destinations: [target]));
    await search(tester, 'target');
    await tester.tap(find.byKey(const ValueKey('search-result-test.target')));
    await tester.pumpAndSettle();
    expect(find.text('target opened'), findsOneWidget);
  });

  for (final (name, theme) in [
    ('light', ThemeData.light()),
    ('dark', ThemeData.dark()),
  ]) {
    testWidgets('results lay out at 360 dp and 2× text ($name)', (
      tester,
    ) async {
      await pump(
        tester,
        MoreScreen(okf: Future.value(okf)),
        theme: theme,
        size: const Size(360, 780),
        textScale: 2,
      );
      await search(tester, 'notifications');
      expect(tester.takeException(), isNull);
      expect(
        find.byKey(const ValueKey('search-result-settings.notifications')),
        findsOneWidget,
      );
    });
  }

  testWidgets('a result is one button for screen readers, with a hint', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(tester, MoreScreen(okf: Future.value(okf)));
    await search(tester, 'durability');
    final data = tester
        .getSemantics(
          find.byKey(const ValueKey('search-result-insights.durability')),
        )
        .getSemanticsData();
    expect(data.label, contains('Durability'));
    expect(data.label, contains('Insights › Durability'));
    expect(data.hint, 'Opens this page');
    expect(data.hasAction(SemanticsAction.tap), isTrue);
    handle.dispose();
  });

  group('chat navigation card', () {
    testWidgets('shows where it leads and opens the page only on tap', (
      tester,
    ) async {
      await pump(
        tester,
        const NavigationCard(destinationId: 'settings.appearance'),
      );
      expect(find.text('Settings › App › Appearance'), findsOneWidget);
      expect(find.byType(SettingsGroupScreen), findsNothing);

      await tester.tap(
        find.byKey(const ValueKey('nav-card-settings.appearance')),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<SettingsGroupScreen>(find.byType(SettingsGroupScreen))
            .focus,
        SettingsSection.appearance,
      );
    });

    testWidgets('is labelled for screen readers and fits 360 dp at 2× '
        'text in dark mode', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        const NavigationCard(destinationId: 'insights.durability'),
        theme: ThemeData.dark(),
        size: const Size(360, 780),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel('Open Durability'), findsOneWidget);
      final data = tester
          .getSemantics(find.bySemanticsLabel('Open Durability'))
          .getSemanticsData();
      expect(data.hint, contains('Insights › Durability'));
      expect(data.hasAction(SemanticsAction.tap), isTrue);
      handle.dispose();
    });

    testWidgets('an unknown id says the page is not available', (tester) async {
      await pump(tester, const NavigationCard(destinationId: 'gone'));
      expect(
        find.text("This page isn't available in this version of the app."),
        findsOneWidget,
      );
    });
  });
}
