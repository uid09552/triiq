import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:langchain_core/chat_models.dart';
import 'package:langchain_core/prompts.dart';
import 'package:langchain_core/tools.dart';

import '../data/intervals_session.dart';
import 'chat_model_factory.dart';
import 'llm_settings.dart';
import 'plan_proposals.dart';
import 'system_prompt.dart';
import 'tools/training_data_tools.dart';

/// Something the agent did while answering, streamed to the UI as it
/// happens so a multi-step answer doesn't look like a hang.
sealed class AgentEvent {
  const AgentEvent();
}

/// A piece of the assistant's reply, as the model produces it.
class AgentTextDelta extends AgentEvent {
  const AgentTextDelta(this.text);

  final String text;
}

/// The model asked for data. Emitted before the tool runs.
class AgentToolStarted extends AgentEvent {
  const AgentToolStarted(this.name, this.arguments);

  final String name;
  final Map<String, dynamic> arguments;
}

/// The tool returned (or failed — [failed] says which).
class AgentToolFinished extends AgentEvent {
  const AgentToolFinished(this.name, {required this.failed});

  final String name;
  final bool failed;
}

/// A tool registered a change for the athlete to apply or dismiss. Emitted
/// right after that tool finished; the chat shows it as a card.
class AgentProposal extends AgentEvent {
  const AgentProposal(this.proposal);

  final PlanProposal proposal;
}

/// The training-analysis agent: a chat model, the training-data tools, and
/// the loop that lets the model call them until it can answer.
///
/// LangChain.dart 0.9 ships an `AgentExecutor`, but it expects a
/// `BaseActionAgent` whose only concrete implementations were provider-tied
/// and are no longer in the package. Driving the tool loop here is a couple
/// of dozen lines, keeps the conversation in native [ChatMessage]s (so
/// Claude's and Ollama's own tool-call formats are used rather than a
/// scratchpad of stringified steps), and lets us stream partial replies.
class TrainingAgent {
  TrainingAgent({
    LlmSettings? settings,
    IntervalsSession? session,
    TrainingDataTools? tools,
    DateTime Function()? clock,
    PlanProposals? proposals,
    BaseChatModel Function(LlmSettings settings, List<ToolSpec> tools)?
    chatModelFactory,
  }) : _settings = settings ?? LlmSettings.instance,
       _session = session ?? IntervalsSession.instance,
       _tools = tools ?? TrainingDataTools(),
       _clock = clock ?? DateTime.now,
       _proposals = proposals ?? PlanProposals.instance,
       _chatModelFactory =
           chatModelFactory ??
           ((settings, tools) => createChatModel(settings, tools: tools));

  final LlmSettings _settings;
  final IntervalsSession _session;
  final TrainingDataTools _tools;
  final DateTime Function() _clock;
  final PlanProposals _proposals;
  final BaseChatModel Function(LlmSettings, List<ToolSpec>) _chatModelFactory;

  /// How many model turns one question may take. Each tool round-trip costs
  /// one; the cap stops a confused model looping on the same call forever.
  static const maxIterations = 8;

  /// How many messages of history to carry. Tool results are bulky, so this
  /// is a message count rather than a turn count.
  static const maxHistoryMessages = 40;

  final List<ChatMessage> _history = [];

  /// The conversation so far, oldest first. Exposed for tests and for a
  /// future "resume conversation" feature; the UI keeps its own copy.
  @visibleForTesting
  List<ChatMessage> get history => List.unmodifiable(_history);

  /// Extra system context for every turn from now on (a session the
  /// athlete asked about), until [reset].
  String? attachedContext;

  void reset() {
    _history.clear();
    attachedContext = null;
  }

  /// Answers [input], streaming text and tool activity as it goes.
  ///
  /// Throws [LlmNotConfiguredException] if no provider is set up; provider
  /// and network failures surface as whatever the provider threw, since the
  /// message ("401 unauthorized", "connection refused") is what the athlete
  /// needs to see.
  Stream<AgentEvent> send(String input) async* {
    final toolset = _tools.build();
    final model = _chatModelFactory(_settings, toolset);
    final byName = {for (final tool in toolset) tool.name: tool};

    _history.add(ChatMessage.humanText(_withOutcomes(input)));
    _trimHistory();

    final systemMessages = [
      ChatMessage.system(trainingAgentSystemPrompt),
      ChatMessage.system(await _runtimeContext()),
      if (attachedContext != null)
        ChatMessage.system(
          '# The athlete is asking about this\n\n$attachedContext',
        ),
    ];

    for (var iteration = 0; iteration < maxIterations; iteration++) {
      AIChatMessage? reply;

      await for (final chunk in model.stream(
        PromptValue.chat([...systemMessages, ..._history]),
      )) {
        reply = reply == null ? chunk.output : reply.concat(chunk.output);
        final text = _textOf(chunk.output);
        if (text.isNotEmpty) yield AgentTextDelta(text);
      }

      final message = reply ?? AIChatMessage.text('');
      _history.add(message);

      final toolCalls = message.toolCalls;
      if (toolCalls.isEmpty) return;

      for (final call in toolCalls) {
        yield AgentToolStarted(call.name, call.arguments);
        final (result, failed) = await _runTool(byName[call.name], call);
        _history.add(
          ChatMessage.tool(
            toolCallId: call.id,
            content: result,
            name: call.name,
          ),
        );
        yield AgentToolFinished(call.name, failed: failed);
        final proposal = failed ? null : _proposalIn(result);
        if (proposal != null) yield AgentProposal(proposal);
      }
      _trimHistory();
    }

    yield const AgentTextDelta(
      '\n\n_I ran out of steps while looking that up. Try asking about a '
      'narrower date range._',
    );
  }

  /// Runs one tool call. A thrown tool goes back to the model as an error
  /// payload rather than ending the turn — a bad date or an unreachable
  /// server is something the model can explain or retry around, and killing
  /// the conversation over it would lose the reply already streamed.
  Future<(String, bool)> _runTool(
    Tool? tool,
    AIChatMessageToolCall call,
  ) async {
    if (tool == null) {
      return (
        '{"error":"There is no tool called \\"${call.name}\\"."}',
        true,
      );
    }
    try {
      final output = await tool.invoke(tool.getInputFromJson(call.arguments));
      return (output.toString(), false);
    } catch (error) {
      debugPrint('TrainingAgent: tool "${call.name}" failed: $error');
      return ('{"error":${_jsonString('$error')}}', true);
    }
  }

  /// [input] with a note on what the athlete did with earlier proposals
  /// since the last turn, so the model never builds on a change that was
  /// dismissed or claims one it only suggested.
  String _withOutcomes(String input) {
    final outcomes = _proposals.takeOutcomes();
    if (outcomes.isEmpty) return input;
    final lines = outcomes.map((o) => '- ${o.describe()}').join('\n');
    return '[Since your last reply:\n$lines]\n\n$input';
  }

  /// The proposal a tool result announces with `proposal_id`, if any.
  PlanProposal? _proposalIn(String result) {
    if (!result.contains('proposal_id')) return null;
    try {
      final json = jsonDecode(result);
      final id = json is Map ? json['proposal_id'] : null;
      return id is String ? _proposals[id] : null;
    } catch (_) {
      return null;
    }
  }

  Future<String> _runtimeContext() async => buildRuntimeContext(
    now: _clock(),
    intervalsConnected: _session.isConnected,
    athleteName: _session.athleteName,
    athleteId: _session.athleteId,
    cachedRanges: await _tools.cachedRanges(),
    provider: _settings.provider,
    model: _settings.activeModel,
  );

  /// Drops the oldest messages once history outgrows the cap, without
  /// orphaning a tool result from the assistant turn that requested it —
  /// both providers reject a tool result whose call isn't in the history.
  void _trimHistory() {
    if (_history.length <= maxHistoryMessages) return;
    var cut = _history.length - maxHistoryMessages;
    while (cut < _history.length && _history[cut] is ToolChatMessage) {
      cut++;
    }
    _history.removeRange(0, cut);
  }

  static String _textOf(AIChatMessage message) => message.content
      .whereType<AIChatMessageTextBlock>()
      .map((block) => block.text)
      .join();

  static String _jsonString(String value) =>
      '"${value.replaceAll(r'\', r'\\').replaceAll('"', r'\"').replaceAll('\n', r'\n')}"';
}
