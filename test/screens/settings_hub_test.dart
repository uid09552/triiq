import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/l10n/app_localizations_de.dart';
import 'package:triiq/l10n/app_localizations_en.dart';
import 'package:triiq/screens/settings/settings_screen.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pump(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        home: const SettingsScreen(),
      ),
    );
    await tester.pump();
  }

  test('every section belongs to exactly one group', () {
    for (final s in SettingsSection.values) {
      expect(
        SettingsGroup.values.where((g) => g.sections.contains(s)),
        hasLength(1),
        reason: s.name,
      );
    }
  });

  test('search finds settings in English and German', () {
    final en = AppLocalizationsEn(), de = AppLocalizationsDe();
    List<SettingsSection> find(String q, AppLocalizations l) => [
      for (final s in SettingsSection.values)
        if (s.matches(q, l)) s,
    ];
    expect(find('dark', en), [SettingsSection.appearance]);
    expect(find('dunkel', en), [SettingsSection.appearance]);
    expect(find('Wochenziele', de), contains(SettingsSection.weeklyTargets));
    expect(find('claude', de), [SettingsSection.ai]);
    expect(find('Datensicherung', de), [SettingsSection.backup]);
    expect(find('', en), isEmpty);
  });

  testWidgets('the hub fits one phone screen: four groups', (tester) async {
    await pump(tester);
    for (final g in SettingsGroup.values) {
      final tile = find.byKey(ValueKey('settings-group-${g.name}'));
      expect(tile, findsOneWidget);
      expect(tester.getRect(tile).bottom, lessThan(800));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('a group opens its page with its sections', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const ValueKey('settings-group-app')));
    await tester.pumpAndSettle();
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Weekly targets'), findsNothing);
  });

  testWidgets('searching jumps to the setting in two taps', (tester) async {
    await pump(tester, locale: const Locale('de'));
    await tester.enterText(
      find.byKey(const ValueKey('settings-search')),
      'muskelkater',
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('settings-group-app')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('settings-result-feel')));
    await tester.pumpAndSettle();
    expect(find.text('Müdigkeit & Muskelkater'), findsOneWidget);
    expect(find.text('Training'), findsOneWidget); // the page title

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('settings-search')),
      'xyz',
    );
    await tester.pump();
    expect(find.textContaining('Keine Einstellung'), findsOneWidget);
  });
}
