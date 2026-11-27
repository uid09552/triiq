import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/agent/chat_starters.dart';
import 'package:triiq/agent/chat_transcript.dart';
import 'package:triiq/evaluation/fatigue_warning.dart';
import 'package:triiq/evaluation/fatigue_warning_service.dart';
import 'package:triiq/agent/llm_model_entry.dart';
import 'package:triiq/agent/llm_settings.dart';
import 'package:triiq/agent/plan_proposals.dart';
import 'package:triiq/agent/training_agent.dart';
import 'package:triiq/agent/usage.dart';
import 'package:triiq/data/backup/backup_service.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/plan/load_curve.dart';
import 'package:triiq/plan/plan_models.dart';
import 'package:triiq/screens/chat/chat_screen.dart';
import 'package:triiq/data/privacy_settings.dart';

/// An agent that plays a script instead of calling a model.
class _ScriptedAgent extends TrainingAgent {
  _ScriptedAgent(this.script) : super(settings: LlmSettings.forTesting());

  final Stream<AgentEvent> Function(String input) script;
  final restored = <({bool fromUser, String text})>[];

  @override
  Stream<AgentEvent> send(String input) => script(input);

  @override
  void restoreHistory(Iterable<({bool fromUser, String text})> turns) =>
      restored.addAll(turns);
}

/// No warning: keeps the banner from reading the database in these tests.
class _NoFatigue extends FatigueWarningService {
  @override
  Future<FatigueWarning> load() async =>
      const FatigueWarning(level: FatigueLevel.none, signals: [], window: 5);
}

const _entry = LlmModelEntry(
  id: 'm1',
  provider: LlmProvider.claude,
  model: 'claude-sonnet-4-5',
  name: 'Claude',
);

Goal _goal() =>
    Goal(targetType: 'fitness', weekdays: {1, 3, 5}, weeklyHours: 6);

CurveProposal _curve(String fingerprint) => CurveProposal(
  summary: 'Flatten week 3',
  fingerprint: fingerprint,
  goal: _goal(),
  limits: const CurveLimits(
    baseline: 300,
    rampCap: 0.1,
    maxCtlRamp: 5,
    recoveryThreshold: 0.8,
    ctl: 50,
    hoursCeilings: {'build': 400},
    holdEvery: 4,
    taperFactors: [0.7, 0.5],
  ),
  weeks: 8,
  changedWeeks: {2},
);

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LlmSettings.instance.load();
    await LlmSettings.instance.setProvider(LlmProvider.ollama);
    await LlmSettings.instance.setOllamaBaseUrl('http://localhost:11434');
    await PrivacySettings.instance.setAiConsent(true);
  });
  tearDown(() => PrivacySettings.instance.setAiConsent(false));

  group('the saved chat', () {
    test('a message survives a round trip, proposals included', () async {
      final live = PlanProposals(fingerprint: () async => 'fp1');
      final m = TranscriptMessage(fromUser: false, text: 'Here you go')
        ..answeredBy = 'Claude'
        ..toolsUsed.addAll(['get_activities', 'get_readiness'])
        ..navigations.add('plan')
        ..usage = const TurnUsage(
          inputTokens: 1200,
          outputTokens: 300,
          model: 'claude-sonnet-4-5',
          local: false,
        )
        ..dataAsOf = DateTime(2026, 11, 21, 9, 30);
      final p = live.register(_curve('fp1'));
      m.proposals.add(p);
      live.dismiss(p.id);

      final store = ChatStore();
      await store.save([TranscriptMessage(fromUser: true, text: 'Hi'), m]);

      final fresh = PlanProposals(fingerprint: () async => 'fp1');
      final back = await store.load(fresh);
      expect(back, hasLength(2));
      expect(back.first.fromUser, isTrue);
      final r = back.last;
      expect(r.text, 'Here you go');
      expect(r.answeredBy, 'Claude');
      expect(r.toolsUsed, ['get_activities', 'get_readiness']);
      expect(r.navigations, ['plan']);
      expect(r.usage!.totalTokens, 1500);
      expect(r.dataAsOf, DateTime(2026, 11, 21, 9, 30));
      final rp = r.proposals.single as CurveProposal;
      expect(rp.summary, 'Flatten week 3');
      expect(rp.state, ProposalState.dismissed);
      expect(rp.changedWeeks, {2});
      expect(rp.limits.holdEvery, 4);
      expect(rp.limits.taperFactors, [0.7, 0.5]);
      expect(fresh[rp.id], same(rp));
    });

    test(
      'a restored pending proposal can be applied once, if still fresh',
      () async {
        final live = PlanProposals(fingerprint: () async => 'fp1');
        final m = TranscriptMessage(fromUser: false, text: 'x')
          ..proposals.add(live.register(_curve('fp1')));
        await ChatStore().save([m]);

        final fresh = PlanProposals(fingerprint: () async => 'fp1');
        final back = await ChatStore().load(fresh);
        final p = back.single.proposals.single;
        expect(p.state, ProposalState.pending);
        var applied = 0;
        await fresh.apply(p.id, (_) async {
          applied++;
          return true;
        });
        expect(applied, 1);
        expect(p.state, ProposalState.applied);
      },
    );

    test('a restored proposal made from an older plan goes stale', () async {
      final live = PlanProposals(fingerprint: () async => 'old');
      final m = TranscriptMessage(fromUser: false, text: 'x')
        ..proposals.add(live.register(_curve('old')));
      await ChatStore().save([m]);

      final fresh = PlanProposals(fingerprint: () async => 'changed');
      final p = (await ChatStore().load(fresh)).single.proposals.single;
      var ran = false;
      final state = await fresh.apply(p.id, (_) async => ran = true);
      expect(state, ProposalState.stale);
      expect(ran, isFalse);
    });

    test('adaptation proposals and unreadable data are skipped', () async {
      expect(proposalFromJson({'kind': 'nope'}), isNull);
      expect(proposalFromJson('x'), isNull);
      SharedPreferences.setMockInitialValues({ChatStore.prefsKey: '{oops'});
      expect(
        await ChatStore().load(PlanProposals(fingerprint: () async => '')),
        isEmpty,
      );
    });

    test('only the newest messages are kept; clear removes it all', () async {
      final store = ChatStore();
      await store.save([
        for (var i = 0; i < ChatStore.maxMessages + 10; i++)
          TranscriptMessage(fromUser: i.isEven, text: 'm$i'),
      ]);
      final back = await store.load(PlanProposals(fingerprint: () async => ''));
      expect(back, hasLength(ChatStore.maxMessages));
      expect(back.last.text, 'm${ChatStore.maxMessages + 9}');
      await store.clear();
      expect(
        await store.load(PlanProposals(fingerprint: () async => '')),
        isEmpty,
      );
    });

    test('chat and usage stay out of backups', () {
      expect(BackupService.excludedPref(ChatStore.prefsKey), isTrue);
      expect(BackupService.excludedPref(UsageLedger.prefsKey), isTrue);
      expect(BackupService.excludedPref('goal'), isFalse);
    });
  });

  group('the chat screen', () {
    Future<void> pump(
      WidgetTester t, {
      required Stream<AgentEvent> Function(String) script,
      ChatStore? store,
      PlanProposals? proposals,
      List<_ScriptedAgent>? agents,
      StarterFacts facts = const StarterFacts(),
    }) async {
      t.view.physicalSize = const Size(800, 1600);
      t.view.devicePixelRatio = 2;
      addTearDown(t.view.reset);
      await t.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: ChatScreen(
              agentFactory: () {
                final a = _ScriptedAgent(script);
                agents?.add(a);
                return a;
              },
              store: store,
              proposals: proposals,
              syncedAt: () async => DateTime(2026, 11, 21, 8, 15),
              fatigueService: _NoFatigue(),
              starterFacts: () async => facts,
            ),
          ),
        ),
      );
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await t.pump();
    }

    testWidgets(
      'the empty chat offers starters from the data and intent chips',
      (t) async {
        final agents = <_ScriptedAgent>[];
        await pump(
          t,
          agents: agents,
          script: (_) => Stream.value(const AgentTextDelta('ok')),
          facts: StarterFacts(missedDate: DateTime(2026, 11, 17), form: -28),
        );
        expect(
          find.text("You missed Tuesday's session. Replan the week?"),
          findsOneWidget,
        );
        expect(find.text('Form is -28. Should I back off?'), findsOneWidget);
        expect(find.text('How was last week?'), findsNothing);
        expect(find.byKey(const ValueKey('chip-sick')), findsOneWidget);
        await t.tap(find.byKey(const ValueKey('chip-sick')));
        await t.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 60)),
        );
        await t.pump();
        expect(find.textContaining("I'm sick."), findsWidgets);
      },
    );

    testWidgets('without facts the generic starters stay', (t) async {
      await pump(t, script: (_) => const Stream.empty());
      expect(find.text('How was last week?'), findsOneWidget);
      expect(find.byKey(const ValueKey('starter-form')), findsNothing);
    });

    Future<void> ask(WidgetTester t, String text) async {
      await t.enterText(find.byKey(const ValueKey('chat-input')), text);
      await t.tap(find.byKey(const ValueKey('chat-send')));
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 60)),
      );
      await t.pump();
    }

    testWidgets('a reply that sets a calorie target gets the care note', (
      t,
    ) async {
      await pump(
        t,
        script: (_) => Stream.value(
          const AgentTextDelta('Aim for 1800 kcal per day to lean out.'),
        ),
      );
      await ask(t, 'Should I eat less?');
      expect(find.byKey(const ValueKey('diet-note')), findsOneWidget);
    });

    testWidgets('fuelling advice gets no care note', (t) async {
      await pump(
        t,
        script: (_) => Stream.value(
          const AgentTextDelta('Take 60-90 g carbs per hour on the long ride.'),
        ),
      );
      await ask(t, 'How should I fuel?');
      expect(find.byKey(const ValueKey('diet-note')), findsNothing);
    });


    Stream<AgentEvent> answer(String input) async* {
      yield const AgentModelAnswering(_entry);
      yield const AgentToolStarted('get_activities', {});
      yield const AgentToolFinished('get_activities', failed: false);
      yield const AgentToolStarted('propose_session_change', {});
      yield const AgentTextDelta('You rode 3 times.');
      yield const AgentUsage(
        TurnUsage(
          inputTokens: 2000,
          outputTokens: 1000,
          model: 'claude-sonnet-4-5',
          local: false,
        ),
      );
    }

    testWidgets('the conversation is saved and comes back after a restart', (
      t,
    ) async {
      await pump(t, script: answer);
      await ask(t, 'How was my week?');
      expect(find.text('You rode 3 times.'), findsOneWidget);

      // "Restart": a new screen over the same storage.
      await t.pumpWidget(const SizedBox());
      final agents = <_ScriptedAgent>[];
      await pump(t, script: answer, agents: agents);
      expect(find.text('How was my week?'), findsOneWidget);
      expect(find.text('You rode 3 times.'), findsOneWidget);

      // The next question reaches a model that knows the conversation.
      await ask(t, 'And last week?');
      expect(agents.single.restored, [
        (fromUser: true, text: 'How was my week?'),
        (fromUser: false, text: 'You rode 3 times.'),
      ]);
    });

    testWidgets('New chat forgets it for good', (t) async {
      await pump(t, script: answer);
      await ask(t, 'How was my week?');
      await t.tap(find.text('New chat'));
      await t.pumpAndSettle();
      await t.tap(find.widgetWithText(FilledButton, 'New chat'));
      await t.pumpAndSettle();
      final back = await t.runAsync(
        () => ChatStore().load(PlanProposals(fingerprint: () async => '')),
      );
      expect(back, isEmpty);
    });

    testWidgets('a reply says what it is based on, its model and its cost', (
      t,
    ) async {
      await pump(t, script: answer);
      await ask(t, 'How was my week?');
      // Only data tools count as sources; proposing is not one.
      expect(find.text('Based on: activities'), findsOneWidget);
      expect(find.byKey(const ValueKey('chat-answered-by')), findsOneWidget);
      expect(find.text('3.0k tokens · about \$0.021'), findsOneWidget);
      // One tap shows how fresh the data was.
      await t.tap(find.byKey(const ValueKey('chat-based-on')));
      await t.pump();
      expect(find.byKey(const ValueKey('chat-data-as-of')), findsOneWidget);
      expect(find.textContaining('last synced'), findsOneWidget);
    });

    testWidgets('a reply without tools says it used none of your data', (
      t,
    ) async {
      await pump(
        t,
        script: (_) async* {
          yield const AgentModelAnswering(_entry);
          yield const AgentTextDelta('Sleep matters.');
        },
      );
      await ask(t, 'Any tips?');
      expect(
        find.text('Based on nothing from your data: general advice'),
        findsOneWidget,
      );
    });

    testWidgets('words that call for a doctor get a card at once', (t) async {
      await pump(t, script: answer);
      await ask(t, 'I get chest pain on my long runs');
      expect(find.byKey(const ValueKey('red-flag-card')), findsOneWidget);
      expect(find.textContaining('Please get this checked'), findsOneWidget);
      expect(find.textContaining('chest pain or pressure'), findsOneWidget);
      // The trainer still answers; the card does not replace it.
      expect(find.text('You rode 3 times.'), findsOneWidget);

      // It is part of the saved chat, and the model's context skips it.
      await t.pumpWidget(const SizedBox());
      final agents = <_ScriptedAgent>[];
      await pump(t, script: answer, agents: agents);
      expect(find.byKey(const ValueKey('red-flag-card')), findsOneWidget);
      await ask(t, 'And now?');
      expect(agents.single.restored.map((e) => e.text), [
        'I get chest pain on my long runs',
        'You rode 3 times.',
      ]);
    });

    testWidgets('ordinary questions get no card', (t) async {
      await pump(t, script: answer);
      await ask(t, 'How was my week?');
      expect(find.byKey(const ValueKey('red-flag-card')), findsNothing);
    });

    testWidgets('a local model is free', (t) async {
      await pump(
        t,
        script: (_) async* {
          yield const AgentTextDelta('ok');
          yield const AgentUsage(
            TurnUsage(
              inputTokens: 400,
              outputTokens: 100,
              model: 'llama3',
              local: true,
            ),
          );
        },
      );
      await ask(t, 'hi');
      expect(find.text('500 tokens · local, free'), findsOneWidget);
    });

    testWidgets('Stop ends the reply and keeps what arrived', (t) async {
      final gate = StreamController<AgentEvent>();
      await pump(t, script: (_) => gate.stream);
      await t.enterText(find.byKey(const ValueKey('chat-input')), 'long one');
      await t.tap(find.byKey(const ValueKey('chat-send')));
      await t.pump();
      gate.add(const AgentTextDelta('Part one'));
      await t.pump();
      expect(find.byKey(const ValueKey('chat-stop')), findsOneWidget);
      await t.tap(find.byKey(const ValueKey('chat-stop')));
      await t.pump();
      expect(find.text('Part one'), findsOneWidget);
      expect(find.byKey(const ValueKey('chat-stopped')), findsOneWidget);
      expect(find.byKey(const ValueKey('chat-send')), findsOneWidget);
      unawaited(gate.close());
    });
  });
}
