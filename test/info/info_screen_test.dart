import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/info/app_info.dart';
import 'package:triiq/info/sbom.dart';
import 'package:triiq/info/sbom_files.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/navigation/navigation_layout.dart';
import 'package:triiq/screens/info/info_screen.dart';
import 'package:triiq/screens/info/sbom_screen.dart';
import 'package:triiq/screens/more/more_screen.dart';
import 'package:triiq/screens/settings/settings_screen.dart';
import 'package:triiq/theme_controller.dart';

const _sample = '''
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.5",
  "metadata": {"component": {"name": "triiq", "version": "0.9.5+1"}},
  "components": [
    {"name": "http", "version": "1.6.0", "scope": "required",
     "purl": "pkg:pub/http@1.6.0",
     "hashes": [{"alg": "SHA-256", "content": "abc123"}],
     "properties": [
       {"name": "triiq:dependency", "value": "direct"},
       {"name": "triiq:source", "value": "hosted"}]},
    {"name": "flutter_lints", "version": "6.0.0", "scope": "optional",
     "properties": [
       {"name": "triiq:dependency", "value": "dev"},
       {"name": "triiq:source", "value": "hosted"}]},
    {"name": "meta", "version": "1.16.0",
     "properties": [
       {"name": "triiq:dependency", "value": "transitive"},
       {"name": "triiq:source", "value": "hosted"}]}
  ]
}
''';

class _Files implements SbomFiles {
  String? json;
  String? version;

  @override
  Future<String?> export(String json, {required String appVersion}) async {
    this.json = json;
    version = appVersion;
    return '/tmp/x.cdx.json';
  }
}

Widget _app(
  Widget home, {
  Locale locale = const Locale('en'),
  ThemeData? theme,
}) => MaterialApp(
  theme: theme,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: locale,
  home: home,
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'triiq',
      packageName: 'app.triiq',
      version: '0.9.5',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  void size(WidgetTester tester, {double w = 400, double h = 1400}) {
    tester.view.physicalSize = Size(w, h);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('Info shows the version line, platform and the sections', (
    tester,
  ) async {
    size(tester);
    await tester.pumpWidget(_app(const InfoScreen()));
    await tester.pumpAndSettle();
    expect(find.text('TriIQ 0.9.5 (build 1)'), findsOneWidget);
    expect(find.text(platformName), findsWidgets);
    expect(find.text('Source code on GitHub'), findsOneWidget);
    expect(find.text('Consent & your rights'), findsOneWidget);
    expect(find.text('Open-source licenses'), findsOneWidget);
    expect(find.text('Software Bill of Materials (SBOM)'), findsOneWidget);
  });

  testWidgets('Info is localized to German', (tester) async {
    size(tester);
    await tester.pumpWidget(
      _app(const InfoScreen(), locale: const Locale('de')),
    );
    await tester.pumpAndSettle();
    expect(find.text('TriIQ 0.9.5 (Build 1)'), findsOneWidget);
    expect(find.text('Software-Stückliste (SBOM)'), findsOneWidget);
  });

  testWidgets('a platform without package info shows a note, not a crash', (
    tester,
  ) async {
    size(tester);
    await tester.pumpWidget(_app(InfoScreen(info: Future.value(null))));
    await tester.pumpAndSettle();
    expect(find.text('TriIQ (version unavailable)'), findsOneWidget);
  });

  test('version info text carries version, build, platform, locale and theme '
      'and nothing personal', () {
    final text = versionInfoText(
      info: const AppInfo(version: '0.9.5', build: '1'),
      locale: const Locale('de'),
      theme: AppThemeChoice.developer,
    );
    expect(text, contains('TriIQ 0.9.5'));
    expect(text, contains('Build: 1'));
    expect(text, contains('Platform: $platformName'));
    expect(text, contains('Locale: de'));
    expect(text, contains('Theme: developer'));
    expect(text.toLowerCase(), isNot(contains('key')));
  });

  testWidgets('Copy version info puts the text on the clipboard', (
    tester,
  ) async {
    size(tester);
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    final theme = ThemeController.forTesting();
    await tester.pumpWidget(_app(InfoScreen(theme: theme)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('info-copy')));
    await tester.pump();
    expect(copied, contains('TriIQ 0.9.5'));
    expect(copied, contains('Build: 1'));
    expect(copied, contains('Theme: system'));
    expect(find.text('Version info copied.'), findsOneWidget);
  });

  testWidgets('links open through the seam; a refusal says so', (tester) async {
    size(tester);
    final opened = <Uri>[];
    var allow = true;
    await tester.pumpWidget(
      _app(
        InfoScreen(
          openUrl: (u) async {
            opened.add(u);
            return allow;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('info-github')));
    await tester.tap(find.byKey(const ValueKey('info-releases')));
    expect(opened, [githubUrl, releasesUrl]);
    allow = false;
    await tester.tap(find.byKey(const ValueKey('info-license')));
    await tester.pump();
    expect(find.textContaining('Could not open'), findsOneWidget);
  });

  testWidgets("the licenses button opens Flutter's license page", (
    tester,
  ) async {
    size(tester);
    await tester.pumpWidget(_app(const InfoScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('info-licenses')));
    await tester.pumpAndSettle();
    expect(find.byType(LicensePage), findsOneWidget);
    expect(find.textContaining('0.9.5'), findsWidgets);
  });

  testWidgets('Settings ends with the version, a tap opens Info', (
    tester,
  ) async {
    size(tester, h: 900);
    await tester.pumpWidget(_app(const SettingsScreen()));
    await tester.pumpAndSettle();
    expect(find.text('TriIQ 0.9.5 (build 1) · $platformName'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('settings-version')));
    await tester.pumpAndSettle();
    expect(find.byType(InfoScreen), findsOneWidget);
  });

  testWidgets('Settings has an Info row', (tester) async {
    size(tester, h: 900);
    await tester.pumpWidget(_app(const SettingsScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('settings-info')));
    await tester.pumpAndSettle();
    expect(find.byType(InfoScreen), findsOneWidget);
  });

  testWidgets('More lists Info in the Data group and opens it', (tester) async {
    size(tester);
    final layout = NavigationLayout.forTesting();
    await tester.pumpWidget(_app(Scaffold(body: MoreScreen(layout: layout))));
    await tester.pumpAndSettle();
    final tile = find.byKey(const ValueKey('more-info'));
    expect(tile, findsOneWidget);
    expect(moreEntries.firstWhere((e) => e.id == 'info').group, MoreGroup.data);
    await tester.tap(tile);
    await tester.pumpAndSettle();
    expect(find.byType(InfoScreen), findsOneWidget);
  });

  group('SBOM screen', () {
    Future<void> open(
      WidgetTester tester, {
      Future<Sbom> Function()? load,
      SbomFiles? files,
      Future<bool> Function(Uri)? openUrl,
    }) async {
      size(tester, h: 900);
      await tester.pumpWidget(
        _app(
          SbomScreen(
            load: load ?? () async => Sbom.parse(_sample),
            files: files,
            openUrl: openUrl,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('summary, format and the not-covered note', (tester) async {
      await open(tester);
      expect(
        find.text('3 packages: 1 direct, 1 dev, 1 transitive'),
        findsOneWidget,
      );
      expect(
        find.text('Format: CycloneDX 1.5 · generated for TriIQ 0.9.5+1'),
        findsOneWidget,
      );
      expect(find.textContaining('Gradle'), findsOneWidget);
      expect(find.text('Dev'), findsOneWidget);
    });

    testWidgets('search filters the list', (tester) async {
      await open(tester);
      await tester.enterText(find.byKey(const ValueKey('sbom-search')), 'lint');
      await tester.pump();
      expect(
        find.byKey(const ValueKey('sbom-package-flutter_lints')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('sbom-package-http')), findsNothing);
      await tester.enterText(find.byKey(const ValueKey('sbom-search')), 'zzz');
      await tester.pump();
      expect(find.textContaining('No package matches'), findsOneWidget);
    });

    testWidgets('a package opens its details and the pub.dev link', (
      tester,
    ) async {
      final opened = <Uri>[];
      await open(
        tester,
        openUrl: (u) async {
          opened.add(u);
          return true;
        },
      );
      await tester.tap(find.byKey(const ValueKey('sbom-package-http')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('sbom-details')), findsOneWidget);
      expect(find.text('pkg:pub/http@1.6.0'), findsOneWidget);
      expect(find.text('abc123'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('sbom-pubdev')));
      expect(opened.single.toString(), 'https://pub.dev/packages/http');
    });

    testWidgets('export hands the JSON to the share / save mechanism', (
      tester,
    ) async {
      final files = _Files();
      await open(tester, files: files);
      await tester.tap(find.byKey(const ValueKey('sbom-export')));
      await tester.pumpAndSettle();
      expect(files.json, _sample);
      expect(files.version, '0.9.5+1');
      expect(find.textContaining('/tmp/x.cdx.json'), findsOneWidget);
    });

    testWidgets('a failing asset shows an error and Try again works', (
      tester,
    ) async {
      var calls = 0;
      await open(
        tester,
        load: () async {
          calls++;
          if (calls == 1) throw FlutterError('asset missing');
          return Sbom.parse(_sample);
        },
      );
      expect(find.byKey(const ValueKey('sbom-error')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('sbom-retry')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('sbom-summary')), findsOneWidget);
    });

    testWidgets('a broken document shows the error too', (tester) async {
      await open(tester, load: () async => Sbom.parse('nope'));
      expect(find.byKey(const ValueKey('sbom-error')), findsOneWidget);
    });

    testWidgets('the real bundled SBOM loads in the screen', (tester) async {
      size(tester, h: 900);
      await tester.pumpWidget(_app(const SbomScreen()));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('sbom-summary')), findsOneWidget);
    });
  });

  group('layout', () {
    for (final scale in [1.0, 2.0]) {
      for (final locale in ['en', 'de']) {
        testWidgets('Info, SBOM and Settings fit 360 dp at ${scale}x text '
            '($locale), light and dark', (tester) async {
          size(tester, w: 360, h: 800);
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.platformDispatcher.clearAllTestValues);
          for (final theme in [ThemeData.light(), ThemeData.dark()]) {
            Future<void> show(Widget w) async {
              await tester.pumpWidget(
                KeyedSubtree(
                  key: UniqueKey(), // a fresh navigator each time
                  child: _app(w, locale: Locale(locale), theme: theme),
                ),
              );
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
            }

            await show(const InfoScreen());
            await show(SbomScreen(load: () async => Sbom.parse(_sample)));
            final tile = find.byKey(const ValueKey('sbom-package-http'));
            await tester.scrollUntilVisible(
              tile,
              100,
              scrollable: find
                  .descendant(
                    of: find.byType(ListView),
                    matching: find.byType(Scrollable),
                  )
                  .first,
            );
            await tester.pumpAndSettle();
            await tester.tap(tile);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            await show(const SettingsScreen());
          }
        });
      }
    }

    testWidgets('tap targets are at least 48 dp', (tester) async {
      size(tester, w: 360, h: 1400);
      await tester.pumpWidget(_app(const InfoScreen()));
      await tester.pumpAndSettle();
      for (final key in [
        'info-copy',
        'info-licenses',
        'info-sbom',
        'info-github',
      ]) {
        final s = tester.getSize(find.byKey(ValueKey(key)));
        expect(s.height, greaterThanOrEqualTo(48), reason: key);
      }
    });
  });
}
