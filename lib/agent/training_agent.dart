import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:langchain_core/chat_models.dart';
import 'package:langchain_core/tools.dart';

import '../data/intervals_session.dart';
import 'chat_model_factory.dart';
import 'agent_memory.dart';
import 'llm_gateway.dart';
import 'llm_settings.dart';
import 'openai_connection.dart' show LlmFailureKind;
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

/// [entry] is being asked for the next part of the reply. Text streamed
/// after this belongs to that attempt; the last one before the turn ends is
/// the model that answered (the chat shows it under the reply).
class AgentModelAnswering extends AgentEvent {
  const AgentModelAnswering(this.entry);

  final LlmModelEntry entry;
}

/// [from] failed with a failover-worthy error ([reason]) and [to] is asked
/// with the same history instead. Any text streamed since the last
/// [AgentModelAnswering] belonged to the failed attempt and must be
/// discarded ([discardedText] says whether there was any). Safe because no
/// tool of the failed attempt ran: tools only run once a model call has
/// completed, and they are read-only or produce proposals the athlete
/// applies by hand.
class AgentModelSwitched extends AgentEvent {
  const AgentModelSwitched({
    required this.from,
    required this.to,
    required this.reason,
    this.discardedText = false,
  });

  final LlmModelEntry from;
  final LlmModelEntry to;
  final LlmFailureKind? reason;
  final bool discardedText;
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

/// A tool offered the athlete a way to an app page (`open_app_page`).
/// The chat shows it as a card; nothing navigates until it is tapped.
class AgentNavigation extends AgentEvent {
  const AgentNavigation(this.destinationId);

  final String destinationId;
}

/// The reply text an event stream adds up to, without the partial text of
/// an attempt that failed over ([AgentModelSwitched]) — so a screen never
/// shows the failed model's half sentence followed by the next model's
/// full answer. [answeredBy] is the entry of the last attempt.
class AgentReplyBuffer {
  String text = '';
  int _attemptStart = 0;
  LlmModelEntry? answeredBy;

  /// Folds [event] in; returns whether [text] changed.
  bool apply(AgentEvent event) {
    switch (event) {
      case AgentModelAnswering(:final entry):
        _attemptStart = text.length;
        answeredBy = entry;
        return false;
      case AgentTextDelta(text: final delta):
        text += delta;
        return delta.isNotEmpty;
      case AgentModelSwitched():
        final changed = text.length != _attemptStart;
        text = text.substring(0, _attemptStart);
        return changed;
      default:
        return false;
    }
  }
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
    AgentMemoryStore? memory,
    ChatModelBuilder? chatModelFactory,
    LlmGateway? gateway,
  }) : _settings = settings ?? LlmSettings.instance,
       _session = session ?? IntervalsSession.instance,
       _tools = tools ?? TrainingDataTools(),
       _clock = clock ?? DateTime.now,
       _proposals = proposals ?? PlanProposals.instance,
       _memory = memory ?? AgentMemoryStore.instance,
       _gateway =
           gateway ??
           LlmGateway(
             settings: settings ?? LlmSettings.instance,
             buildModel: chatModelFactory,
           );

  final LlmSettings _settings;
  final IntervalsSession _session;
  final TrainingDataTools _tools;
  final DateTime Function() _clock;
  final PlanProposals _proposals;
  final AgentMemoryStore _memory;
  final LlmGateway _gateway;

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
  /// Every model call goes through [LlmGateway]: it uses the
  /// highest-priority model entry that works and fails over to the next on
  /// a failover-worthy error, at the start of the turn or between tool
  /// rounds (see [AgentModelSwitched]). An entry that failed once in this
  /// turn is not asked again in it.
  ///
  /// Throws [LlmNotConfiguredException] if nothing is set up; with one
  /// model its failure surfaces as whatever the provider threw (the
  /// message — "401 unauthorized", "connection refused" — is what the
  /// athlete needs to see), with several an [AllModelsFailedException].
  Stream<AgentEvent> send(String input) async* {
    // Before anything is built or sent: no consent, no request — whatever
    // the screen that called us shows.
    if (_settings.blockedByConsent) throw const AiConsentRequiredException();
    final toolset = _tools.build();
    final byName = {for (final tool in toolset) tool.name: tool};

    _history.add(ChatMessage.humanText(_withOutcomes(input)));
    _trimHistory();

    final memoryBlock = await _memory.promptBlock();
    final cachedRanges = await _tools.cachedRanges();
    // The runtime context names the model in use, so it is built per entry.
    List<ChatMessage> promptFor(LlmModelEntry entry) => [
      ChatMessage.system(trainingAgentSystemPrompt),
      ChatMessage.system(_runtimeContext(entry, cachedRanges)),
      if (memoryBlock != null) ChatMessage.system(memoryBlock),
      if (attachedContext != null)
        ChatMessage.system(
          '# The athlete is asking about this\n\n$attachedContext',
        ),
      ..._history,
    ];
    final failedThisTurn = <String>{};

    for (var iteration = 0; iteration < maxIterations; iteration++) {
      AIChatMessage? reply;
      var streamedText = false;

      await for (final event in _gateway.stream(
        promptFor,
        tools: toolset,
        exclude: failedThisTurn,
      )) {
        switch (event) {
          case LlmAttemptStarted(:final entry):
            reply = null;
            streamedText = false;
            yield AgentModelAnswering(entry);
          case LlmChunk(:final chunk):
            reply = reply == null ? chunk.output : reply.concat(chunk.output);
            final text = _textOf(chunk.output);
            if (text.isNotEmpty) {
              streamedText = true;
              yield AgentTextDelta(text);
            }
          case LlmFailedOver(:final from, :final to, :final kind):
            // The failed attempt's partial reply (text, half a tool call)
            // is dropped: the next entry gets the same history.
            failedThisTurn.add(from.id);
            yield AgentModelSwitched(
              from: from,
              to: to,
              reason: kind,
              discardedText: streamedText,
            );
            reply = null;
            streamedText = false;
        }
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
        if (!failed) {
          for (final proposal in _proposalsIn(result)) {
            yield AgentProposal(proposal);
          }
          final navigation = _navigationIn(result);
          if (navigation != null) yield AgentNavigation(navigation);
        }
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
      return ('{"error":"There is no tool called \\"${call.name}\\"."}', true);
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

  /// The proposals a tool result announces: one with `proposal_id`, or
  /// several with `proposal_ids`.
  List<PlanProposal> _proposalsIn(String result) {
    if (!result.contains('proposal_id')) return const [];
    try {
      final json = jsonDecode(result);
      if (json is! Map) return const [];
      final ids = [
        json['proposal_id'],
        ...?(json['proposal_ids'] as List?),
      ].whereType<String>();
      return [for (final id in ids) ?_proposals[id]];
    } catch (_) {
      return const [];
    }
  }

  /// The page an `open_app_page` result offers, if any.
  static String? _navigationIn(String result) {
    if (!result.contains('navigation_id')) return null;
    try {
      final json = jsonDecode(result);
      if (json is! Map) return null;
      final id = json['navigation_id'];
      return id is String ? id : null;
    } catch (_) {
      return null;
    }
  }

  String _runtimeContext(
    LlmModelEntry entry,
    Map<String, String> cachedRanges,
  ) => buildRuntimeContext(
    now: _clock(),
    intervalsConnected: _session.isConnected,
    athleteName: _session.athleteName,
    athleteId: _session.athleteId,
    cachedRanges: cachedRanges,
    provider: entry.provider,
    model: entry.model,
    localModel: entry.isLocal,
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
