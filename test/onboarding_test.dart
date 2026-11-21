import 'package:flutter/material.dart';
import 'package:triiq/onboarding/setup_checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/agent/llm_settings.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/onboarding/onboarding_screen.dart';
import 'package:triiq/data/sync/sync_scope.dart';
import 'package:triiq/data/sync/sync_service.dart';
import 'package:triiq/onboarding/onboarding_settings.dart';
import 'package:triiq/screens/settings/weekly_targets_settings.dart';
import 'package:triiq/screens/settings/year_goals_settings.dart';

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
    late YearGoalsSettings goals;
    late LlmSettings llm;
    late List<String> connected;
    late List<SyncScope> synced;
    late List<String?> eventsOpened;
    late bool consentAsked;

    Future<void> pump(
      WidgetTester tester, {
      bool guided = false,
      bool startConnected = false,
      void Function()? prepare,
      SetupFindings found = const SetupFindings(),
    }) async {
      targets = WeeklyTargetsSettings.forTesting();
      goals = YearGoalsSettings.forTesting();
      llm = LlmSettings.forTesting();
      connected = [];
      synced = [];
      eventsOpened = [];
      consentAsked = false;
      prepare?.call();
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
                        findings: (_) async => found,
                        athleteName: () => 'Alex',
                        targets: targets,
                        llm: llm,
                        settings: OnboardingSettings.forTesting(),
                        askConsent: (_) async => consentAsked = true,
                        guided: guided,
                        isConnected: () =>
                            startConnected || connected.isNotEmpty,
                        yearGoals: goals,
                        syncData: (scope) async {
                          synced.add(scope);
                          return const SyncResult(
                            wellnessCount: 300,
                            activitiesCount: 250,
                            eventsCount: 40,
                          );
                        },
                        addEvent: (_, category) async {
                          eventsOpened.add(category);
                          return true;
                        },
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

      // Sync more history: this year by default.
      expect(find.text('Sync your data'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('onboarding-sync-now')));
      await tester.pumpAndSettle();
      expect(synced, [SyncScope.year]);
      expect(
        find.text(
          'Synced: 250 activities, 300 wellness days, 40 calendar entries.',
        ),
        findsOneWidget,
      );
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

      // Year goals: only the sports chosen, blank = no goal.
      expect(find.byKey(const ValueKey('onboarding-goal-swim')), findsNothing);
      await tester.enterText(
        find.byKey(const ValueKey('onboarding-goal-ride')),
        '5000',
      );
      await tester.tap(find.byKey(const ValueKey('onboarding-next')));
      await tester.pumpAndSettle();
      expect(goals.cycleKm, 5000);
      expect(goals.runKm, isNull);

      // Events: a race, through the editor.
      await tester.tap(find.byKey(const ValueKey('onboarding-add-race')));
      await tester.pumpAndSettle();
      expect(eventsOpened, ['RACE_A']);
      expect(find.text('1 event added.'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('onboarding-next')));
      await tester.pumpAndSettle();

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

    testWidgets('the sync step explains Strava stubs and missing thresholds', (
      tester,
    ) async {
      await pump(
        tester,
        guided: true,
        startConnected: true,
        found: const SetupFindings(
          stravaActivities: 3,
          missingThresholds: ['Ride'],
        ),
      );
      await tester.tap(find.byKey(const ValueKey('onboarding-next')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('onboarding-next')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('onboarding-strava-hint')),
        findsNothing,
      );
      await tester.tap(find.byKey(const ValueKey('onboarding-sync-now')));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('3 activities come from Strava'),
        findsOneWidget,
      );
      expect(find.textContaining('No threshold set for: Ride'), findsOneWidget);
    });

    testWidgets('every step can be skipped', (tester) async {
      await pump(tester);
      await tester.tap(find.byKey(const ValueKey('onboarding-next')));
      await tester.pumpAndSettle();
      for (var i = 0; i < 6; i++) {
        await tester.tap(find.byKey(const ValueKey('onboarding-skip-step')));
        await tester.pumpAndSettle();
      }
      expect(find.text("You're set"), findsOneWidget);
      expect(connected, isEmpty);
      expect(synced, isEmpty);
      expect(eventsOpened, isEmpty);
      expect(goals.hasAnyGoal, isFalse);
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

    testWidgets('AI step: an OpenAI-compatible server needs no key', (
      tester,
    ) async {
      await pump(tester);
      // Welcome, then skip connect, sync, training, goals, events.
      await tester.tap(find.byKey(const ValueKey('onboarding-next')));
      await tester.pumpAndSettle();
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.byKey(const ValueKey('onboarding-skip-step')));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byKey(const ValueKey('onboarding-ai-openai')));
      await tester.pump();
      expect(
        find.byKey(const ValueKey('onboarding-openai-url')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('onboarding-ollama-url')), findsNothing);

      // A public http:// URL cannot be saved.
      await tester.enterText(
        find.byKey(const ValueKey('onboarding-openai-url')),
        'http://api.example.com/v1',
      );
      await tester.pump();
      expect(
        tester
            .widget<FilledButton>(find.byKey(const ValueKey('onboarding-next')))
            .onPressed,
        isNull,
      );

      await tester.enterText(
        find.byKey(const ValueKey('onboarding-openai-url')),
        'http://localhost:1234/v1',
      );
      await tester.enterText(
        find.byKey(const ValueKey('onboarding-openai-model')),
        'llama-3.1-8b',
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('onboarding-next')));
      for (var i = 0; i < 5; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 30)),
        );
        await tester.pump();
      }
      await tester.pumpAndSettle();
      expect(llm.provider, LlmProvider.openai);
      expect(llm.openAiBaseUrl, 'http://localhost:1234/v1');
      expect(llm.openAiModel, 'llama-3.1-8b');
      expect(llm.hasOpenAiApiKey, isFalse);
      expect(consentAsked, isTrue);
    });

    testWidgets('guided from Settings: what is set is kept by clicking Next', (
      tester,
    ) async {
      await pump(
        tester,
        guided: true,
        startConnected: true,
        prepare: () {
          targets
            ..cycleHours = 7
            ..runHours = 2.5;
          goals.runKm = 1200;
        },
      );
      expect(find.text('Guided setup'), findsOneWidget);
      expect(find.text('Step 1 of 8'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('onboarding-next')));
      await tester.pumpAndSettle();

      // Already connected: no key needed, Next is open.
      expect(find.text('Connected as Alex'), findsOneWidget);
      expect(find.byKey(const ValueKey('onboarding-synced')), findsNothing);
      for (var i = 0; i < 2; i++) {
        await tester.tap(find.byKey(const ValueKey('onboarding-next')));
        await tester.pumpAndSettle();
      }

      // Training is filled in from the weekly targets.
      expect(
        tester
            .widget<FilterChip>(
              find.byKey(const ValueKey('onboarding-sport-swim')),
            )
            .selected,
        isFalse,
      );
      expect(find.text('7'), findsOneWidget);
      expect(find.text('2.5'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('onboarding-next')));
      await tester.pumpAndSettle();

      // Year goals: the run goal is there.
      expect(find.text('1200'), findsOneWidget);
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byKey(const ValueKey('onboarding-next')));
        await tester.pumpAndSettle();
      }
      expect(find.text('Back to Settings'), findsOneWidget);
      expect(targets.swimHours, isNull);
      expect(targets.cycleHours, 7);
      expect(targets.runHours, 2.5);
      expect(goals.runKm, 1200);
      expect(goals.cycleKm, isNull);
      expect(connected, isEmpty);
      await tester.tap(find.byKey(const ValueKey('onboarding-finish')));
      await tester.pumpAndSettle();
      expect(find.text('open'), findsOneWidget);
    });

    testWidgets('sync and events need a connection', (tester) async {
      await pump(tester, guided: true);
      await tester.tap(find.byKey(const ValueKey('onboarding-next')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('onboarding-skip-step')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('onboarding-sync-offline')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('onboarding-sync-now')), findsNothing);
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byKey(const ValueKey('onboarding-skip-step')));
        await tester.pumpAndSettle();
      }
      expect(find.text('Races and events'), findsOneWidget);
      expect(find.byKey(const ValueKey('onboarding-add-race')), findsNothing);
    });
  });
}
