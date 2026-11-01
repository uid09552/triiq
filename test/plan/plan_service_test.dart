import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:langchain_core/chat_models.dart';
import 'package:triiq/agent/llm_settings.dart';
import 'package:triiq/plan/knowledge.dart';
import 'package:triiq/plan/plan_inputs.dart';
import 'package:triiq/plan/plan_models.dart';
import 'package:triiq/plan/plan_service.dart';
import 'package:triiq/plan/session_content.dart';

/// Skips the local cache entirely — these tests only care about the
/// generate()-time content pass, not history-derived baselines.
class _NoHistoryInputs extends PlanInputsLoader {
  @override
  Future<PlanInputs> load(DateTime planStart, {int weeks = 4}) async =>
      const PlanInputs(weeklyLoads: null, currentCtl: null);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PlanService service;
  late LlmSettings settings;

  Goal goal() => const Goal(
    targetType: 'long_distance',
    weekdays: {2, 4, 6},
    weeklyHours: 12,
    sport: 'Run',
    baselineWeeklyLoad: 300,
    weeks: 2,
  );

  setUp(() async {
    settings = LlmSettings.forTesting();
    await settings.setClaudeApiKey('sk-ant-test');
  });

  test('a successful AI response rewrites text but never the numbers',
      () async {
    service = PlanService(
      knowledge: KnowledgeRepository(
        loadAsset: () async => File('docs/okf.md').readAsStringSync(),
      ),
      inputs: _NoHistoryInputs(),
      content: SessionContentGenerator(
        settings: settings,
        chatCall: (settings, messages) async {
          final request = jsonDecode(messages.last.contentAsString) as List;
          return AIChatMessage.text(
            jsonEncode([
              for (final s in request)
                {
                  'index': s['index'],
                  'name': 'AI session ${s['index']}',
                  'short_description': 'AI short ${s['index']}.',
                  'description': '- AI detail ${s['index']}',
                },
            ]),
          );
        },
      ),
    );

    final before = await PlanService(
      knowledge: KnowledgeRepository(
        loadAsset: () async => File('docs/okf.md').readAsStringSync(),
      ),
      inputs: _NoHistoryInputs(),
      content: SessionContentGenerator(settings: LlmSettings.forTesting()),
    ).generate(goal(), today: DateTime(2026, 11, 2));

    final after = await service.generate(
      goal(),
      today: DateTime(2026, 11, 2),
    );

    expect(before.plan, isNotNull);
    expect(after.plan, isNotNull);
    final beforeSessions = before.plan!.sessions.toList();
    final afterSessions = after.plan!.sessions.toList();
    expect(afterSessions, hasLength(beforeSessions.length));

    for (var i = 0; i < afterSessions.length; i++) {
      final b = beforeSessions[i];
      final a = afterSessions[i];
      expect(a.name, 'AI session $i');
      expect(a.shortDescription, 'AI short $i.');
      expect(a.description, '- AI detail $i');
      // Every number stays exactly PlanEngine's, unconfigured-provider run.
      expect(a.date, b.date);
      expect(a.sport, b.sport);
      expect(a.slot, b.slot);
      expect(a.minutes, b.minutes);
      expect(a.load, b.load);
      expect(a.lowMinutes, b.lowMinutes);
      expect(a.techniqueFocus, b.techniqueFocus);
    }
  });
}
