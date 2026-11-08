import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/data/feel_settings.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/settings/feel_settings_section.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> open(WidgetTester tester, FeelSettings settings) =>
      tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(body: FeelSettingsSection(settings: settings)),
        ),
      );

  testWidgets('toggling it flips and persists promptOnNewActivity', (
    tester,
  ) async {
    final settings = FeelSettings.forTesting();
    await settings.load();
    await open(tester, settings);

    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isTrue,
    );

    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();

    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );
    expect(settings.promptOnNewActivity, isFalse);

    final again = FeelSettings.forTesting();
    await again.load();
    expect(again.promptOnNewActivity, isFalse);
  });
}
