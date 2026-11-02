import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:langchain_core/chat_models.dart';

import '../agent/chat_model_factory.dart';
import '../agent/llm_settings.dart';
import 'plan_models.dart';

/// Rewrites a generated plan's sessions' `name`, `shortDescription` and
/// `description` using the athlete's configured chat LLM provider — the
/// numbers (date, sport, slot, minutes, load, low-intensity minutes) are
/// never touched; they stay exactly what `PlanEngine` computed. When no
/// provider is configured, the call fails or times out, or the response
/// can't be matched back to a session, that session simply keeps the
/// deterministic content it already had.
class SessionContentGenerator {
  SessionContentGenerator({
    LlmSettings? settings,
    Future<AIChatMessage> Function(LlmSettings settings, List<ChatMessage>)?
    chatCall,
    Duration timeout = const Duration(seconds: 20),
  }) : _settings = settings ?? LlmSettings.instance,
       _chatCall =
           chatCall ??
           ((settings, messages) => createChatModel(settings).call(messages)),
       _timeout = timeout;

  final LlmSettings _settings;
  final Future<AIChatMessage> Function(LlmSettings, List<ChatMessage>)
  _chatCall;
  final Duration _timeout;

  static const maxShortDescriptionLength = 140;
  static const maxDescriptionLength = 2000;

  /// [plan] with as many sessions' content rewritten as the provider
  /// returned something usable for. Every other session, and the whole plan
  /// when nothing is configured or the call fails, is returned unchanged.
  Future<TrainingPlan> enrich(TrainingPlan plan) async {
    final sessions = plan.sessions.toList();
    if (!_settings.isConfigured || sessions.isEmpty) return plan;

    Map<int, _SessionContent> content;
    try {
      final reply = await _chatCall(_settings, [
        ChatMessage.system(_systemPrompt),
        ChatMessage.humanText(_userPrompt(sessions)),
      ]).timeout(_timeout);
      content = _parse(reply.contentAsString, sessions.length);
    } catch (error) {
      debugPrint('SessionContentGenerator: falling back to plain text: $error');
      return plan;
    }
    if (content.isEmpty) return plan;

    var index = 0;
    final rebuilt = <PlanWeek>[];
    for (final week in plan.weeks) {
      final sessions2 = <PlanSession>[];
      for (final session in week.sessions) {
        sessions2.add(_applied(session, content[index]));
        index++;
      }
      rebuilt.add(week.withSessions(sessions2));
    }
    return plan.copyWith(weeks: rebuilt);
  }

  PlanSession _applied(PlanSession session, _SessionContent? content) =>
      content == null
      ? session
      : session.copyWith(
          name: content.name,
          shortDescription: content.shortDescription,
          description: content.description,
        );

  static const _systemPrompt =
      'You write the content of endurance training sessions for a '
      'triathlon coaching app. You are given a JSON array describing plan '
      'sessions whose timing and numbers (sport, slot, phase, minutes, '
      'load, low-intensity share) are already fixed by a separate engine '
      'and MUST NOT be restated or contradicted. For each session, write: '
      '"name" (a short session title), "short_description" (one line, at '
      'most ${SessionContentGenerator.maxShortDescriptionLength} '
      'characters, summarising the session\'s purpose), and "description" '
      '(the detailed set-by-set content in Intervals.icu step syntax, '
      'at most ${SessionContentGenerator.maxDescriptionLength} characters — '
      'lines like "- 10m 70%" or "4x" / "  - 3m 95%" / "  - 1m 60%"). '
      'When a session has "technique_focus": true it is a swim technique '
      'session: build its description around named technique drills (e.g. '
      'catch-up drill, fingertip drag, bilateral breathing, high-elbow '
      'catch) instead of plain effort percentages. '
      'Reply with ONLY a JSON array, same length and order as the input, '
      'each element {"index": <int>, "name": <string>, '
      '"short_description": <string>, "description": <string>}. No prose, '
      'no markdown fences.';

  String _userPrompt(List<PlanSession> sessions) => jsonEncode([
    for (var i = 0; i < sessions.length; i++) _sessionFacts(i, sessions[i]),
  ]);

  Map<String, dynamic> _sessionFacts(int index, PlanSession s) => {
    'index': index,
    'sport': s.sport,
    'slot': s.slot.name,
    'minutes': s.minutes,
    'load': s.load,
    'low_intensity_minutes': double.parse(s.lowMinutes.toStringAsFixed(1)),
    'technique_focus': s.techniqueFocus,
  };

  /// Parses the model's reply into valid entries keyed by session index.
  /// Anything that doesn't parse, whose index is out of range, or whose
  /// fields fail [_isUsable] is simply left out — the caller falls back to
  /// the deterministic content for that session.
  Map<int, _SessionContent> _parse(String reply, int sessionCount) {
    final text = _stripFences(reply);
    final decoded = jsonDecode(text);
    if (decoded is! List) return const {};
    final result = <int, _SessionContent>{};
    for (final entry in decoded) {
      if (entry is! Map) continue;
      final index = entry['index'];
      if (index is! num) continue;
      final i = index.toInt();
      if (i < 0 || i >= sessionCount) continue;
      final name = entry['name'];
      final short = entry['short_description'];
      final description = entry['description'];
      if (name is! String || short is! String || description is! String) {
        continue;
      }
      if (!_isUsable(name, short, description)) continue;
      result[i] = _SessionContent(
        name: name.trim(),
        shortDescription: short.trim(),
        description: description.trim(),
      );
    }
    return result;
  }

  bool _isUsable(String name, String short, String description) {
    if (name.trim().isEmpty || short.trim().isEmpty) return false;
    if (short.length > maxShortDescriptionLength) return false;
    final body = description.trim();
    if (body.isEmpty || body.length > maxDescriptionLength) return false;
    // A sanity floor, not a real step-syntax parse: a believable detailed
    // description has at least roughly one line per 10 minutes planned.
    final lines = body.split('\n').where((l) => l.trim().isNotEmpty).length;
    return lines > 0;
  }

  /// The JSON array inside [text]: a bare reply, one in a code fence, or
  /// one wrapped in prose ("Here you go: [...] Hope that helps").
  String _stripFences(String text) {
    final trimmed = text.trim();
    final fence = RegExp(r'```[a-zA-Z]*\s*\n([\s\S]*?)\n\s*```');
    final inner = fence.firstMatch(trimmed)?.group(1)?.trim() ?? trimmed;
    final start = inner.indexOf('[');
    final end = inner.lastIndexOf(']');
    return start >= 0 && end > start ? inner.substring(start, end + 1) : inner;
  }
}

class _SessionContent {
  const _SessionContent({
    required this.name,
    required this.shortDescription,
    required this.description,
  });

  final String name;
  final String shortDescription;
  final String description;
}
