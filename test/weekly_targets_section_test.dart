import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/settings/weekly_targets_section.dart';
import 'package:triiq/screens/settings/weekly_targets_settings.dart';

void main() {
  late WeeklyTargetsSettings settings;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settings = WeeklyTargetsSettings.forTesting();
    await settings.load();
  });

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: WeeklyTargetsSection(settings: settings),
        ),
      ),
    );
  }

  testWidgets('entering a value saves it as the target', (tester) async {
    await pump(tester);

    await tester.enterText(
      find.byKey(const ValueKey('weekly-target-cycle')),
      '4.5',
    );
    await tester.pump();

    expect(settings.cycleHours, 4.5);
  });

  testWidgets('clearing a value unsets the target', (tester) async {
    await settings.setRunHours(3);
    await pump(tester);

    await tester.enterText(
      find.byKey(const ValueKey('weekly-target-run')),
      '',
    );
    await tester.pump();

    expect(settings.runHours, isNull);
  });

  testWidgets('toggling Show on Today flips the setting', (tester) async {
    await pump(tester);
    expect(settings.showOnToday, isTrue);

    await tester.tap(
      find.byKey(const ValueKey('weekly-target-show-on-today')),
    );
    await tester.pump();

    expect(settings.showOnToday, isFalse);
  });

  testWidgets('shows the stored values on open', (tester) async {
    await settings.setSwimHours(2.5);
    await pump(tester);

    final field = tester.widget<TextField>(
      find.byKey(const ValueKey('weekly-target-swim')),
    );
    expect(field.controller!.text, '2.5');
  });
}
