import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/agent/llm_settings.dart';
import 'package:triiq/data/data_eraser.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/privacy_settings.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/settings/ai_consent.dart';
import 'package:triiq/screens/settings/privacy_screen.dart';

Widget _app(Widget home) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: home,
);

Future<void> _settle(WidgetTester tester, {int rounds = 8}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 80));
  }
}

class _FakeEraser implements DataEraser {
  int calls = 0;
  Object? error;

  @override
  Future<void> eraseAll() async {
    calls++;
    if (error != null) throw error!;
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('PrivacySettings', () {
    test(
      'AI consent is off by default, recorded with a date, and persisted',
      () async {
        final a = PrivacySettings.forTesting();
        await a.load();
        expect(a.aiConsent, isFalse);
        expect(a.mapTiles, isTrue);

        final when = DateTime(2026, 11, 7, 9, 30);
        await a.setAiConsent(true, now: when);
        expect(a.aiConsent, isTrue);
        expect(a.aiConsentAt, when);

        final b = PrivacySettings.forTesting();
        await b.load(); // an app restart
        expect(b.aiConsent, isTrue);
        expect(b.aiConsentAt, when);

        await b.setAiConsent(false);
        final c = PrivacySettings.forTesting();
        await c.load();
        expect(c.aiConsent, isFalse);
      },
    );

    test('map tiles choice is persisted', () async {
      final a = PrivacySettings.forTesting();
      await a.setMapTiles(false);
      final b = PrivacySettings.forTesting();
      await b.load();
      expect(b.mapTiles, isFalse);
    });
  });

  group('the AI trainer needs consent', () {
    tearDown(() => PrivacySettings.instance.setAiConsent(false));

    test(
      'a configured provider is not usable until the athlete agrees',
      () async {
        final llm = LlmSettings.instance;
        await llm.load();
        await llm.setProvider(LlmProvider.ollama);
        await llm.setOllamaBaseUrl('http://localhost:11434');

        expect(llm.hasProvider, isTrue);
        expect(llm.needsConsent, isTrue);
        expect(llm.isConfigured, isFalse);

        await PrivacySettings.instance.setAiConsent(true);
        expect(llm.isConfigured, isTrue);
        expect(llm.needsConsent, isFalse);

        // Withdrawing switches it off again at once.
        await PrivacySettings.instance.setAiConsent(false);
        expect(llm.isConfigured, isFalse);
      },
    );

    test('a change of consent notifies listeners of the settings', () async {
      var notified = 0;
      LlmSettings.instance.addListener(() => notified++);
      await PrivacySettings.instance.setAiConsent(true);
      expect(notified, greaterThan(0));
    });

    test('test instances do not ask for the app\'s consent', () async {
      final llm = LlmSettings.forTesting();
      await llm.setProvider(LlmProvider.ollama);
      await llm.setOllamaBaseUrl('http://localhost:11434');
      expect(llm.isConfigured, isTrue);
      expect(llm.needsConsent, isFalse);
    });
  });

  group('delete all data', () {
    late Directory dir;
    late AppDatabase database;

    setUp(() async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      dir = await Directory.systemTemp.createTemp('triiq_privacy');
      database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
    });

    tearDown(() async {
      await database.close();
      await dir.delete(recursive: true);
    });

    test('every table is emptied, the schema stays', () async {
      final repo = ActivitiesRepository(database: database);
      await repo.upsertAll([
        LocalActivity(
          id: 'a',
          date: '2026-11-01',
          type: 'Run',
          name: 'x',
          movingTime: 60,
          distance: 100,
          trainingLoad: 1,
          raw: const {},
          syncedAt: DateTime(2026),
        ),
      ]);
      expect(await repo.getAll(), hasLength(1));

      final tables = await database.eraseAll();

      expect(tables, greaterThan(3));
      expect(await repo.getAll(), isEmpty);
      // Still usable afterwards.
      await repo.upsertAll([
        LocalActivity(
          id: 'b',
          date: '2026-11-02',
          type: 'Run',
          name: 'y',
          movingTime: 60,
          distance: 100,
          trainingLoad: 1,
          raw: const {},
          syncedAt: DateTime(2026),
        ),
      ]);
      expect(await repo.getAll(), hasLength(1));
    });

    test('preferences and the consent are wiped too', () async {
      SharedPreferences.setMockInitialValues({
        'privacy.ai_consent_at': DateTime(2026).toIso8601String(),
        'today.section_order': ['readiness'],
      });
      final privacy = PrivacySettings.forTesting();
      await privacy.load();
      expect(privacy.aiConsent, isTrue);

      await DataEraser(
        database: database,
        privacy: privacy,
        llm: LlmSettings.forTesting(),
      ).eraseAll();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys(), isEmpty);
      expect(privacy.aiConsent, isFalse);
    });
  });

  group('privacy screen', () {
    testWidgets('shows what is processed, recipients, rights and the choices', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(420, 4000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        _app(PrivacyScreen(privacy: PrivacySettings.forTesting())),
      );
      await tester.pump();

      expect(find.text('Privacy & data'), findsWidgets);
      expect(find.text('What is processed'), findsOneWidget);
      expect(find.text('Who receives data'), findsOneWidget);
      expect(find.text('Transfers outside the EU/EEA'), findsOneWidget);
      expect(find.text('Legal basis'), findsOneWidget);
      expect(find.text('Your rights'), findsOneWidget);
      expect(
        find.textContaining('special category under the GDPR'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('privacy-ai-consent')), findsOneWidget);
      expect(find.byKey(const ValueKey('privacy-map-tiles')), findsOneWidget);
    });

    testWidgets(
      'the AI switch asks first, records the consent and can withdraw it',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(420, 4000));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final privacy = PrivacySettings.forTesting();
        await tester.pumpWidget(
          _app(PrivacyScreen(privacy: privacy, llm: LlmSettings.forTesting())),
        );

        await tester.tap(find.byKey(const ValueKey('privacy-ai-consent')));
        await _settle(tester);
        expect(find.text('Allow AI processing?'), findsOneWidget);
        // Declining records nothing.
        await tester.tap(find.byKey(const ValueKey('ai-consent-no')));
        await _settle(tester);
        expect(privacy.aiConsent, isFalse);

        await tester.tap(find.byKey(const ValueKey('privacy-ai-consent')));
        await _settle(tester);
        await tester.tap(find.byKey(const ValueKey('ai-consent-yes')));
        await _settle(tester);
        expect(privacy.aiConsent, isTrue);
        expect(find.textContaining('Allowed on'), findsOneWidget);

        // Withdrawing needs no dialog.
        await tester.tap(find.byKey(const ValueKey('privacy-ai-consent')));
        await _settle(tester);
        expect(privacy.aiConsent, isFalse);
      },
    );

    testWidgets('map tiles can be switched off', (tester) async {
      await tester.binding.setSurfaceSize(const Size(420, 4000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final privacy = PrivacySettings.forTesting();
      await tester.pumpWidget(_app(PrivacyScreen(privacy: privacy)));
      await tester.tap(find.byKey(const ValueKey('privacy-map-tiles')));
      await _settle(tester);
      expect(privacy.mapTiles, isFalse);
    });

    testWidgets('delete asks for confirmation, then erases', (tester) async {
      await tester.binding.setSurfaceSize(const Size(420, 4000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final eraser = _FakeEraser();
      await tester.pumpWidget(
        _app(
          PrivacyScreen(privacy: PrivacySettings.forTesting(), eraser: eraser),
        ),
      );

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('privacy-erase')),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('privacy-erase')));
      await _settle(tester);
      expect(find.text('Delete all data?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await _settle(tester);
      expect(eraser.calls, 0);

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('privacy-erase')),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('privacy-erase')));
      await _settle(tester);
      await tester.tap(find.byKey(const ValueKey('erase-confirm')));
      await _settle(tester);
      expect(eraser.calls, 1);
      expect(find.textContaining('Close and reopen TriIQ'), findsOneWidget);
    });

    testWidgets('a failed erase says so', (tester) async {
      await tester.binding.setSurfaceSize(const Size(420, 4000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final eraser = _FakeEraser()..error = StateError('disk full');
      await tester.pumpWidget(
        _app(
          PrivacyScreen(privacy: PrivacySettings.forTesting(), eraser: eraser),
        ),
      );
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('privacy-erase')),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('privacy-erase')));
      await _settle(tester);
      await tester.tap(find.byKey(const ValueKey('erase-confirm')));
      await _settle(tester);
      expect(
        find.textContaining('Could not delete everything'),
        findsOneWidget,
      );
    });

    testWidgets('the full notice opens in the browser', (tester) async {
      await tester.binding.setSurfaceSize(const Size(420, 4000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      Uri? opened;
      await tester.pumpWidget(
        _app(
          PrivacyScreen(
            privacy: PrivacySettings.forTesting(),
            openUrl: (u) async {
              opened = u;
              return true;
            },
          ),
        ),
      );
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('privacy-open-web')),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('privacy-open-web')));
      await tester.pump();
      expect(opened, privacyNoticeUrl);
    });
  });

  testWidgets('the consent card names the provider and asks', (tester) async {
    final llm = LlmSettings.forTesting();
    await llm.setProvider(LlmProvider.claude);
    final privacy = PrivacySettings.forTesting();
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: AiConsentCard(settings: llm, privacy: privacy),
        ),
      ),
    );
    expect(find.text('The AI trainer needs your consent'), findsOneWidget);
    expect(find.textContaining('Claude (Anthropic)'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('ai-consent-review')));
    await _settle(tester);
    expect(
      find.textContaining('may process it outside the EU/EEA'),
      findsOneWidget,
    );
  });
}
