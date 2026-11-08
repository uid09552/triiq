import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/agent/llm_settings.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/onboarding/onboarding_screen.dart';
import 'package:triiq/onboarding/onboarding_settings.dart';
import 'package:triiq/screens/settings/weekly_targets_settings.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('shown once, on a fresh install', () {
    test('a fresh install shows it', () async {
      expect(
        await OnboardingSettings.forTesting().shouldShow(
          hasSavedKey: () async => false,
        ),
        isTrue,
      );
    });

    test('an install with settings or a saved key does not', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
      final s = OnboardingSettings.forTesting();
      expect(await s.shouldShow(hasSavedKey: () async => false), isFalse);

      SharedPreferences.setMockInitialValues({});
      expect(await s.shouldShow(hasSavedKey: () async => true), isFalse);
      // …and remembers it.
      expect(await s.shouldShow(hasSavedKey: () async => false), isFalse);
    });

    test('Today\'s own layout key does not count as "used before"', () async {
      SharedPreferences.setMockInitialValues({
        'today.section_order': ['readiness'],
      });
      expect(
        await OnboardingSettings.forTesting().shouldShow(
          hasSavedKey: () async => false,
        ),
        isTrue,
      );
    });
  });

  group('the flow', () {
    late WeeklyTargetsSettings targets;
    late LlmSettings llm;
    late List<String> connected;
    late bool consentAsked;

    Future<void> pump(WidgetTester tester) async {
      targets = WeeklyTargetsSettings.forTesting();
      llm = LlmSettings.forTesting();
      connected = [];
      consentAsked = false;
      tester.view.physicalSize = const Size(420, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => OnboardingScreen(
                        connect: (key) async => connected.add(key),
                        syncMonth: () async => 12,
                        athleteName: () => 'Alex',
                        targets: targets,
                        llm: llm,
                        settings: OnboardingSettings.forTesting(),
                        askConsent: (_) async => consentAsked = true,
                      ),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    Future<bool> done() async =>
        (await SharedPreferences.getInstance()).getBool(
          OnboardingSettings.doneKey,
        ) ??
        false;

    testWidgets('every step, completed', (tester) async {
      await pump(tester);
      expect(find.text('Welcome to TriIQ'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('onboarding-next')));
      await tester.pumpAndSettle();

      // Connect, then the month syncs with a visible result.
      expect(find.text('Connect Intervals.icu'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('onboarding-api-key')),
        'abc123',
      );
      await tester.tap(find.byKey(const ValueKey('onboarding-connect')));
      await tester.pumpAndSettle();
      expect(connected, ['abc123']);
      expect(find.text('Connected as Alex'), findsOneWidget);
      expect(find.byKey(const ValueKey('onboarding-synced')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('onboarding-next')));
      await tester.pumpAndSettle();

      // Training: no swimming, 6 h of riding.
      await tester.tap(find.byKey(const ValueKey('onboarding-sport-swim')));
      await tester.pump();
      await tester.enterText(
        find.byKey(const ValueKey('onboarding-hours-ride')),
        '6',
      );
      await tester.tap(find.byKey(const ValueKey('onboarding-next')));
      await tester.pumpAndSettle();
      expect(targets.swimHours, isNull);
      expect(targets.cycleHours, 6);
      expect(targets.runHours, 3);

      // AI: Claude with a key, then the consent question.
      await tester.tap(find.byKey(const ValueKey('onboarding-ai-claude')));
      await tester.pump();
      await tester.enterText(
        find.byKey(const ValueKey('onboarding-ai-key')),
        'sk-ant-test',
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('onboarding-next')));
      // The key goes to the OS vault: real I/O, outside the fake clock.
      for (var i = 0; i < 5; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 30)),
        );
        await tester.pump();
      }
      await tester.pumpAndSettle();
      expect(llm.provider, LlmProvider.claude);
      expect(llm.hasClaudeApiKey, isTrue);
      expect(consentAsked, isTrue);

      expect(find.text("You're set"), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('onboarding-finish')));
      await tester.pumpAndSettle();
      expect(find.text('open'), findsOneWidget);
      expect(await done(), isTrue);
    });

    testWidgets('every step can be skipped', (tester) async {
      await pump(tester);
      await tester.tap(find.byKey(const ValueKey('onboarding-next')));
      await tester.pumpAndSettle();
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byKey(const ValueKey('onboarding-skip-step')));
        await tester.pumpAndSettle();
      }
      expect(find.text("You're set"), findsOneWidget);
      expect(connected, isEmpty);
      expect(targets.hasAnyTarget, isFalse);
      expect(consentAsked, isFalse);
    });

    testWidgets('Skip setup leaves at once and is not shown again', (
      tester,
    ) async {
      await pump(tester);
      await tester.tap(find.byKey(const ValueKey('onboarding-skip-all')));
      await tester.pumpAndSettle();
      expect(find.text('open'), findsOneWidget);
      expect(await done(), isTrue);
      expect(
        await OnboardingSettings.forTesting().shouldShow(
          hasSavedKey: () async => false,
        ),
        isFalse,
      );
    });
  });
}
