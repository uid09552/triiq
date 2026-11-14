import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:langchain_core/chat_models.dart';
import 'package:langchain_core/prompts.dart';
import 'package:langchain_core/tools.dart';

import 'chat_model_factory.dart';
import 'failover_policy.dart';
import 'llm_settings.dart';
import 'model_health.dart';
import 'openai_connection.dart' show LlmFailureKind;

/// Builds the chat model for one entry (default: [createChatModelFor] with
/// the entry's stored key). Tests inject scripted models here.
typedef ChatModelBuilder =
    BaseChatModel Function(LlmModelEntry entry, List<ToolSpec> tools);

/// One entry that did not answer, and why.
class ModelAttemptFailure {
  const ModelAttemptFailure(this.entry, this.error, this.kind);

  final LlmModelEntry entry;
  final Object error;
  final LlmFailureKind? kind;

  @override
  String toString() => '${entry.label}: ${kind?.name ?? error}';
}

/// Every enabled entry was tried (or skipped) and none answered. Shown as
/// one message listing each entry and its reason.
class AllModelsFailedException implements Exception {
  const AllModelsFailedException(this.failures);

  final List<ModelAttemptFailure> failures;

  @override
  String toString() => 'No model answered — ${failures.join('; ')}';
}

/// What happens during one gateway call, in order.
sealed class LlmCallEvent {
  const LlmCallEvent();
}

/// [entry] is being asked now. Anything streamed before belongs to an
/// attempt that failed and is to be discarded.
class LlmAttemptStarted extends LlmCallEvent {
  const LlmAttemptStarted(this.entry);

  final LlmModelEntry entry;
}

/// A streamed piece of the current attempt's reply.
class LlmChunk extends LlmCallEvent {
  const LlmChunk(this.chunk);

  final ChatResult chunk;
}

/// [from] failed with a failover-worthy error; [to] is asked next.
class LlmFailedOver extends LlmCallEvent {
  const LlmFailedOver({
    required this.from,
    required this.to,
    required this.kind,
    required this.error,
  });

  final LlmModelEntry from;
  final LlmModelEntry to;
  final LlmFailureKind? kind;
  final Object error;
}

/// A finished one-shot call: the reply and which entry gave it.
class LlmReply {
  const LlmReply(this.entry, this.message);

  final LlmModelEntry entry;
  final AIChatMessage message;
}

/// The single entry point for every LLM call in the app — the chat agent,
/// the session-content generator, the weekly-review sentence. It walks the
/// athlete's model list in priority order and fails over:
///
/// * **Candidates**: enabled entries, in list order; entries cooling down
///   ([ModelHealth]) go to the back (tried only if nothing healthier
///   answers) and entries in `exclude` (failed earlier in this agent turn)
///   are left out. An entry whose host the athlete has not consented to is
///   skipped without sending anything.
/// * **Attempt**: the entry's model is built (an incomplete entry throws
///   before any request) and streamed. The first chunk must arrive within
///   [firstChunkTimeout] and each next one within [idleTimeout], so a dead
///   server costs a bounded wait rather than the SDK's 10-minute default.
/// * **Failure**: [classifyLlmError] + [FailoverPolicy] decide. A
///   non-failover error (cancelled, content refusal, context too long, our
///   own bug) is rethrown as is. A failover-worthy one is recorded in
///   [ModelHealth] and the next candidate is asked with the same messages.
/// * **All failed**: with one attempt its own error is rethrown (so a
///   single-model setup reads exactly as before); with several, an
///   [AllModelsFailedException] lists each entry and reason.
class LlmGateway {
  LlmGateway({
    LlmSettings? settings,
    ChatModelBuilder? buildModel,
    this.policy = const FailoverPolicy(),
    this.firstChunkTimeout = const Duration(seconds: 90),
    this.idleTimeout = const Duration(seconds: 60),
  }) : settings = settings ?? LlmSettings.instance,
       _buildModel = buildModel;

  final LlmSettings settings;
  final ChatModelBuilder? _buildModel;
  final FailoverPolicy policy;
  final Duration firstChunkTimeout;
  final Duration idleTimeout;

  ModelHealth get health => settings.health;

  BaseChatModel _build(LlmModelEntry entry, List<ToolSpec> tools) =>
      _buildModel?.call(entry, tools) ??
      createChatModelFor(entry, apiKey: settings.keyFor(entry), tools: tools);

  /// The entries a call would try, in order.
  List<LlmModelEntry> candidates({Set<String> exclude = const {}}) {
    final enabled = [
      for (final e in settings.entries)
        if (e.enabled && !exclude.contains(e.id)) e,
    ];
    return [
      ...enabled.where((e) => !health.isCoolingDown(e.id)),
      ...enabled.where((e) => health.isCoolingDown(e.id)),
    ];
  }

  /// Streams one model call with failover. [prompt] gives the messages for
  /// an entry (the agent's runtime context names the model in use).
  Stream<LlmCallEvent> stream(
    List<ChatMessage> Function(LlmModelEntry entry) prompt, {
    List<ToolSpec> tools = const [],
    Set<String> exclude = const {},
  }) async* {
    final list = candidates(exclude: exclude);
    if (list.isEmpty) {
      throw const LlmNotConfiguredException(
        'No model is enabled. Add or switch on one in Settings → AI trainer.',
      );
    }
    final failures = <ModelAttemptFailure>[];
    var attempted = 0;
    for (var i = 0; i < list.length; i++) {
      final entry = list[i];
      // Checked per attempt: consent can be withdrawn mid-turn.
      if (!settings.isConsented(entry)) {
        failures.add(
          ModelAttemptFailure(
            entry,
            const AiConsentRequiredException(),
            LlmFailureKind.noConsent,
          ),
        );
        continue;
      }
      attempted++;
      yield LlmAttemptStarted(entry);
      try {
        final model = _build(entry, tools);
        await for (final chunk in _guarded(
          model.stream(PromptValue.chat(prompt(entry))),
        )) {
          yield LlmChunk(chunk);
        }
        health.recordSuccess(entry.id);
        return;
      } catch (error) {
        final kind = classifyLlmError(error);
        final decision = policy.decide(kind);
        if (!decision.failover) rethrow;
        debugPrint('LlmGateway: ${entry.label} failed ($kind): $error');
        health.recordFailure(
          entry.id,
          kind,
          needsAttention: decision.needsAttention,
        );
        failures.add(ModelAttemptFailure(entry, error, kind));
        final next = list.skip(i + 1).where(settings.isConsented).firstOrNull;
        if (next != null) {
          yield LlmFailedOver(from: entry, to: next, kind: kind, error: error);
        }
      }
    }
    if (attempted == 0) throw const AiConsentRequiredException();
    if (failures.length == 1) throw failures.single.error;
    throw AllModelsFailedException(failures);
  }

  /// One whole reply (no streaming to the caller), with failover.
  Future<LlmReply> invoke(
    List<ChatMessage> messages, {
    List<ToolSpec> tools = const [],
  }) async {
    LlmModelEntry? by;
    AIChatMessage? reply;
    await for (final event in stream((_) => messages, tools: tools)) {
      switch (event) {
        case LlmAttemptStarted(:final entry):
          by = entry;
          reply = null;
        case LlmChunk(:final chunk):
          reply = reply == null ? chunk.output : reply.concat(chunk.output);
        case LlmFailedOver():
          break;
      }
    }
    return LlmReply(by!, reply ?? AIChatMessage.text(''));
  }

  /// [source] with a bound on the wait for the first chunk and between
  /// chunks; cancelling the result cancels the request.
  Stream<T> _guarded<T>(Stream<T> source) async* {
    final iterator = StreamIterator(source);
    var first = true;
    try {
      while (await iterator.moveNext().timeout(
        first ? firstChunkTimeout : idleTimeout,
      )) {
        first = false;
        yield iterator.current;
      }
    } finally {
      unawaited(iterator.cancel());
    }
  }
}
