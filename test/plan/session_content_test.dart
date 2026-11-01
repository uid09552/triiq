import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:langchain_core/chat_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/agent/llm_settings.dart';
import 'package:triiq/plan/knowledge.dart';
import 'package:triiq/plan/plan_models.dart';
import 'package:triiq/plan/session_content.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LlmSettings configured;
  late LlmSettings unconfigured;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    configured = LlmSettings.forTesting();
    await configured.load();
    await configured.setClaudeApiKey('sk-ant-test');

    SharedPreferences.setMockInitialValues({});
    unconfigured = LlmSettings.forTesting();
    await unconfigured.load();
  });

  PlanSession session({
    int weekIndex = 0,
    String sport = 'Run',
    SessionSlot slot = SessionSlot.z2,
    bool techniqueFocus = false,
  }) => PlanSession(
    weekIndex: weekIndex,
    date: DateTime(2026, 11, 2),
    slot: slot,
    templateId: 'long_distance.z2',
    name: 'Z2 endurance',
    sport: sport,
    minutes: 50,
    load: 42,
    lowMinutes: 50,
    description: '- 10m 60%\n- 35m 70%\n- 5m 55%',
    techniqueFocus: techniqueFocus,
  );

  TrainingPlan plan(List<PlanSession> sessions) => TrainingPlan(
    goalType: 'long_distance',
    sport: 'Run',
    startDate: DateTime(2026, 11, 2),
    baselineLoad: 300,
    weeks: [
      PlanWeek(
        index: 0,
        phase: 'build',
        startDate: DateTime(2026, 11, 2),
        targetLoad: 300,
        requestedLoad: 300,
        limit: WeekLimit.none,
        projectedCtlEnd: null,
        sessions: sessions,
        lowIntensityTarget: 0.8,
        lowIntensityTolerance: 0.05,
      ),
    ],
  );

  AIChatMessage reply(String text) => AIChatMessage.text(text);

  SessionContentGenerator generator(
    LlmSettings settings,
    Future<AIChatMessage> Function(LlmSettings, List<ChatMessage>) chatCall,
  ) => SessionContentGenerator(settings: settings, chatCall: chatCall);

  test('no provider configured: plan is returned unchanged, no call made',
      () async {
    var called = false;
    final g = generator(unconfigured, (settings, messages) async {
      called = true;
      return reply('[]');
    });

    final result = await g.enrich(plan([session()]));

    expect(called, isFalse);
    expect(result.sessions.single.name, 'Z2 endurance');
  });

  test('a valid response rewrites content but never the numbers', () async {
    final original = session();
    final g = generator(configured, (settings, messages) async {
      return reply(
        jsonEncode([
          {
            'index': 0,
            'name': 'Easy aerobic run',
            'short_description': 'Easy aerobic run, 50 minutes.',
            'description': '- 10m 60%\n- 35m 70%\n- 5m 55%\n(rewritten)',
          },
        ]),
      );
    });

    final result = await g.enrich(plan([original]));
    final s = result.sessions.single;

    expect(s.name, 'Easy aerobic run');
    expect(s.shortDescription, 'Easy aerobic run, 50 minutes.');
    expect(s.description, contains('(rewritten)'));
    // Numbers stay exactly PlanEngine's.
    expect(s.date, original.date);
    expect(s.sport, original.sport);
    expect(s.slot, original.slot);
    expect(s.minutes, original.minutes);
    expect(s.load, original.load);
    expect(s.lowMinutes, original.lowMinutes);
  });

  test('malformed JSON falls back to the deterministic content', () async {
    final original = session();
    final g = generator(configured, (settings, messages) async {
      return reply('not json at all');
    });

    final result = await g.enrich(plan([original]));

    expect(result.sessions.single.name, original.name);
    expect(result.sessions.single.description, original.description);
  });

  test('a response missing some sessions falls back only for those',
      () async {
    final a = session(weekIndex: 0, sport: 'Run');
    final b = session(weekIndex: 0, sport: 'Ride');
    final g = generator(configured, (settings, messages) async {
      return reply(
        jsonEncode([
          {
            'index': 0,
            'name': 'Easy run',
            'short_description': 'Easy run.',
            'description': '- 50m 70%',
          },
          // index 1 (the Ride session) is missing entirely.
        ]),
      );
    });

    final result = await g.enrich(plan([a, b]));
    final sessions = result.sessions.toList();

    expect(sessions[0].name, 'Easy run');
    expect(sessions[1].name, b.name, reason: 'kept its deterministic name');
  });

  test('an oversized field is rejected and that session falls back',
      () async {
    final original = session();
    final g = generator(configured, (settings, messages) async {
      return reply(
        jsonEncode([
          {
            'index': 0,
            'name': 'Easy run',
            'short_description': List.filled(500, 'x').join(),
            'description': List.filled(50, 'y').join(),
          },
        ]),
      );
    });

    final result = await g.enrich(plan([original]));

    expect(result.sessions.single.name, original.name);
  });

  test('a provider error falls back to deterministic content', () async {
    final original = session();
    final g = generator(configured, (settings, messages) async {
      throw Exception('connection refused');
    });

    final result = await g.enrich(plan([original]));

    expect(result.sessions.single.name, original.name);
  });

  test('a slow provider times out and falls back', () async {
    final original = session();
    final g = SessionContentGenerator(
      settings: configured,
      timeout: const Duration(milliseconds: 20),
      chatCall: (settings, messages) async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        return reply('[]');
      },
    );

    final result = await g.enrich(plan([original]));

    expect(result.sessions.single.name, original.name);
  });

  test('a technique-focus session is included in the prompt facts',
      () async {
    final technique = session(sport: 'Swim', techniqueFocus: true);
    String? sentPrompt;
    final g = generator(configured, (settings, messages) async {
      sentPrompt = messages.last.contentAsString;
      return reply('[]');
    });

    await g.enrich(plan([technique]));

    expect(sentPrompt, contains('"technique_focus":true'));
  });
}
