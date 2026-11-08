import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/data/sync/background_sync.dart';
import 'package:triiq/data/sync/sync_settings.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/settings/settings_screen.dart';

void main() {
  tearDown(() => BackgroundSync.debugSupported = null);

  Future<SyncSettings> pump(
    WidgetTester tester, {
    required bool supported,
    Map<String, Object> prefs = const {},
  }) async {
    SharedPreferences.setMockInitialValues(prefs);
    BackgroundSync.debugSupported = supported;
    final settings = SyncSettings.forTesting();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(body: BackgroundSyncControls(settings: settings)),
      ),
    );
    await tester.pumpAndSettle();
    return settings;
  }

  testWidgets('Android: a switch that turns the nightly sync off and on', (
    tester,
  ) async {
    final settings = await pump(tester, supported: true);

    expect(find.byType(SwitchListTile), findsOneWidget);
    expect(settings.backgroundSyncEnabled, isTrue);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(settings.backgroundSyncEnabled, isFalse);
    final stored = await SharedPreferences.getInstance();
    expect(stored.getBool('sync.background_enabled'), isFalse);
  });

  testWidgets('Android: shows how the last run went', (tester) async {
    await pump(
      tester,
      supported: true,
      prefs: {
        'sync.background_last_run': DateTime(
          2026,
          10,
          30,
          3,
          12,
        ).millisecondsSinceEpoch,
        'sync.background_last_result': 'success',
      },
    );

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.textContaining(l10n.backgroundResultSuccess), findsOneWidget);
    expect(find.text(l10n.backgroundSyncNoRun), findsNothing);
  });

  testWidgets('elsewhere: no switch, just why', (tester) async {
    await pump(tester, supported: false);

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.byType(SwitchListTile), findsNothing);
    expect(find.text(l10n.backgroundSyncUnsupported), findsOneWidget);
  });
}
