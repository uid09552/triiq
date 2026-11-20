import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/settings/home_widget_section.dart';
import 'package:triiq/screens/settings/home_widget_settings.dart';

void main() {
  testWidgets('toggling a block updates and persists the setting', (t) async {
    SharedPreferences.setMockInitialValues({});
    final settings = HomeWidgetSettings.forTesting();
    await t.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: HomeWidgetSection(settings: settings),
          ),
        ),
      ),
    );
    expect(settings.showRings, isTrue);
    await t.tap(find.byKey(const ValueKey('home-widget-rings')));
    await t.pump();
    expect(settings.showRings, isFalse);

    final fresh = HomeWidgetSettings.forTesting();
    await fresh.load();
    expect(fresh.showRings, isFalse);
    expect(fresh.showForm, isTrue);
  });
}
