import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/navigation/app_destinations.dart';
import 'package:triiq/navigation/navigation_layout.dart';
import 'package:triiq/screens/chat/navigation_card.dart';
import 'package:triiq/screens/memory/memory_screen.dart';
import 'package:triiq/widgets/main_navigation.dart';

/// The app search and the trainer's Open button go to a page wherever the
/// athlete put it (the registry reads [NavigationLayout.instance]).
void main() {
  final layout = NavigationLayout.instance;
  final en = lookupAppLocalizations(const Locale('en'));

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    MainNavigation.instance.debugReset();
    await layout.reset();
  });

  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(body: child),
      ),
    );
    await tester.pump();
  }

  test('breadcrumbs follow the layout', () async {
    expect(destinationById('more.memory')!.path(en), 'More › Trainer memory');
    expect(destinationById('tab.chat')!.path(en), 'Chat');
    await layout.pinToBar('memory'); // refused: the bar is full
    await layout.moveToMore('chat');
    await layout.pinToBar('memory');
    expect(destinationById('more.memory')!.path(en), 'Trainer memory');
    expect(destinationById('tab.chat')!.path(en), 'More › Chat');
  });

  testWidgets('Open on a More page that lives in More pushes it', (
    tester,
  ) async {
    await pump(tester, const NavigationCard(destinationId: 'more.memory'));
    await tester.tap(find.byKey(const ValueKey('nav-card-more.memory')));
    await tester.pumpAndSettle();
    expect(find.byType(MemoryScreen), findsOneWidget);
    expect(MainNavigation.instance.requestedTab, isNull);
  });

  testWidgets('Open on a page pinned to the bar switches the shell to it', (
    tester,
  ) async {
    await layout.moveToMore('insights');
    await layout.pinToBar('memory');
    await pump(tester, const NavigationCard(destinationId: 'more.memory'));
    await tester.tap(find.byKey(const ValueKey('nav-card-more.memory')));
    await tester.pumpAndSettle();
    expect(find.byType(MemoryScreen), findsNothing);
    expect(MainNavigation.instance.requestedTab, 'memory');
  });

  testWidgets('a core tab moved into More is opened as a page', (tester) async {
    await layout.moveToMore('chat');
    await pump(tester, const NavigationCard(destinationId: 'tab.calendar'));
    await tester.tap(find.byKey(const ValueKey('nav-card-tab.calendar')));
    await tester.pump();
    expect(MainNavigation.instance.requestedTab, MainNavigation.calendarTab);

    MainNavigation.instance.debugReset();
    await layout.moveToMore('calendar');
    await tester.tap(find.byKey(const ValueKey('nav-card-tab.calendar')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(MainNavigation.instance.requestedTab, isNull);
    expect(find.byType(BackButton), findsOneWidget);
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Calendar')),
      findsOneWidget,
    );
    for (var i = 0; i < 4; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 10));
  });
}
