import 'dart:async' as dart_async;
import 'dart:io' show HandshakeException, HttpException, SocketException;

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart' as anthropic;
import 'package:http/http.dart' as http;
import 'package:langchain_anthropic/langchain_anthropic.dart';
import 'package:langchain_core/chat_models.dart';
import 'package:langchain_core/tools.dart';
import 'package:langchain_ollama/langchain_ollama.dart';
import 'package:langchain_openai/langchain_openai.dart'
    show ChatOpenAI, ChatOpenAIOptions;
import 'package:ollama_dart/ollama_dart.dart' as ollama;
import 'package:openai_dart/openai_dart.dart' as openai;

import 'llm_settings.dart';
import 'ollama_connection.dart';
import 'openai_connection.dart';

/// Thrown when a model entry has no usable configuration yet.
class LlmNotConfiguredException implements Exception {
  const LlmNotConfiguredException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// The athlete has not agreed to their data being sent to the AI provider
/// (Settings → Data & privacy → Consent & your rights). Every path to a provider stops here: the
/// consent is enforced where requests are made, not only in the UI.
class AiConsentRequiredException extends LlmNotConfiguredException {
  const AiConsentRequiredException()
    : super(
        'The AI trainer needs your consent before your data can be sent to '
        'the provider. Allow it in Settings → Data & privacy → Consent & your rights.',
      );
}

/// Builds the LangChain chat model for the athlete's *primary* model entry
/// (the single-model API), with [tools] bound. Every real call goes through
/// `LlmGateway`, which uses [createChatModelFor] per entry and fails over;
/// this stays for callers and tests that want exactly one model.
BaseChatModel createChatModel(
  LlmSettings settings, {
  List<ToolSpec> tools = const [],
}) {
  final entry = settings.primary;
  if (entry == null) {
    throw const LlmNotConfiguredException(
      'No model is set up. Add one in Settings → AI trainer.',
    );
  }
  if (!settings.isConsented(entry)) throw const AiConsentRequiredException();
  return createChatModelFor(
    entry,
    apiKey: settings.keyFor(entry),
    tools: tools,
  );
}

/// Builds the LangChain chat model for one model [entry] with [tools] bound
/// as its default options; [apiKey] is that entry's stored key.
///
/// This is the only place a provider's chat model is named: everything
/// above it — the gateway, the agent loop, the tools, the chat UI — works
/// against LangChain's [BaseChatModel], so adding a provider means adding a
/// case here (and to [classifyLlmError]).
///
/// Throws [LlmNotConfiguredException] for an incomplete entry, before
/// anything is sent. Tools are bound to `defaultOptions` rather than passed
/// per call, because the caller talks to the model through the erased
/// `BaseChatModel` type and so cannot construct provider-specific options.
BaseChatModel createChatModelFor(
  LlmModelEntry entry, {
  String? apiKey,
  List<ToolSpec> tools = const [],
}) {
  final key = apiKey?.trim() ?? '';
  final model = entry.model.trim();
  if (model.isEmpty) {
    throw const LlmNotConfiguredException(
      'No model name set. Add one in Settings → AI trainer.',
    );
  }
  switch (entry.provider) {
    case LlmProvider.claude:
      if (key.isEmpty) {
        throw const LlmNotConfiguredException(
          'No Claude API key stored. Add one in Settings → AI trainer, or '
          'use Ollama or an OpenAI-compatible server.',
        );
      }
      return ChatAnthropic(
        apiKey: key,
        defaultOptions: ChatAnthropicOptions(
          model: model,
          // Long enough for a table plus commentary; tool-call turns are far
          // shorter than this, so the ceiling only bites on the final answer.
          maxTokens: 4096,
          // The job is reading the athlete's numbers back accurately, not
          // producing varied prose.
          temperature: 0.2,
          tools: tools,
        ),
      );

    case LlmProvider.ollama:
      final baseUrl = entry.effectiveBaseUrl;
      if (baseUrl.isEmpty) {
        throw const LlmNotConfiguredException(
          'No Ollama server URL set. Add one in Settings → AI trainer.',
        );
      }
      if (entry.isOllamaCloud && key.isEmpty) {
        throw const LlmNotConfiguredException(
          'No Ollama Cloud API key stored. Add one in Settings → AI '
          'trainer, or point the server URL at a local Ollama instance.',
        );
      }
      return ChatOllama(
        baseUrl: baseUrl,
        // Ollama Cloud authenticates like any other hosted API — a Bearer
        // token. Sent only to Ollama Cloud over https: a self-hosted or
        // plain-http server must never see the athlete's cloud key.
        headers: key.isEmpty || !isOllamaCloudUrl(baseUrl)
            ? null
            : {'Authorization': 'Bearer $key'},
        defaultOptions: ChatOllamaOptions(
          model: model,
          temperature: 0.2,
          // Tool results (a month of daily metrics, say) plus the system
          // prompt overrun Ollama's 2048-token default context, and what
          // falls out of the window is the data the answer was built on.
          numCtx: 16384,
          tools: tools,
        ),
      );

    case LlmProvider.openai:
      final baseUrl = entry.effectiveBaseUrl;
      final problem = checkOpenAiBaseUrl(baseUrl);
      if (problem != null) {
        throw LlmNotConfiguredException(switch (problem) {
          OpenAiUrlProblem.empty =>
            'No server URL set. Add one in Settings → AI trainer.',
          OpenAiUrlProblem.httpPublicHost =>
            'Plain http:// is only allowed for a server on your own network '
                '(localhost or a private address). Use https:// for '
                '${serverHostOf(baseUrl)}.',
          OpenAiUrlProblem.credentialsInUrl =>
            'The server URL must not contain a user name or password. Put '
                'the key in the API key field instead.',
          _ =>
            'The server URL is not valid. Use the form '
                'https://host/v1 in Settings → AI trainer.',
        });
      }
      return ChatOpenAI(
        baseUrl: normalizeOpenAiBaseUrl(baseUrl),
        // Sent to the configured server only; empty = no Authorization
        // header (local servers).
        apiKey: key.isEmpty ? null : key,
        defaultOptions: ChatOpenAIOptions(
          model: model,
          // Reasoning models (o-series, gpt-5…) reject a temperature other
          // than their default, so it is left unset for them.
          temperature: _acceptsTemperature(model) ? 0.2 : null,
          tools: tools,
        ),
      );
  }
}

/// Whether [model] takes a custom `temperature`. OpenAI's reasoning models
/// (`o1`, `o3`, `o4-mini`, `gpt-5…`) answer 400 to anything but the default.
bool _acceptsTemperature(String model) {
  final name = model.toLowerCase().split('/').last;
  return !RegExp(r'^(o\d|gpt-5)').hasMatch(name);
}

/// Classifies a failure from any provider (or our own pre-flight checks)
/// into an [LlmFailureKind], or `null` when [error] is not an LLM failure
/// the app recognises — most likely a bug in our own code, which must not
/// be retried on another model.
///
/// 401/403 → key, 404 → URL or model, 408/timeouts/no answer → unreachable,
/// 413 or a "context length" 400 → context too long, 429 → rate limit, 5xx
/// (incl. Anthropic's 529 "overloaded") → server, a 400 that mentions
/// content policy → refused, one that complains about tools/functions →
/// the model cannot do the tool calling the agent needs, any other 4xx →
/// bad request; a cancelled request → cancelled.
LlmFailureKind? classifyLlmError(Object error) {
  if (error is OpenAiConnectionException) return error.kind;
  if (error is AiConsentRequiredException) return LlmFailureKind.noConsent;
  if (error is LlmNotConfiguredException) return LlmFailureKind.notConfigured;

  if (error is openai.OpenAIException) {
    return switch (error) {
      openai.ApiException() => _fromStatus(
        error.statusCode,
        '${error.message} ${error.code} ${error.param} ${error.type}',
      ),
      openai.ConnectionException() ||
      openai.RequestTimeoutException() ||
      openai.StreamException() => LlmFailureKind.unreachable,
      openai.AbortedException() => LlmFailureKind.cancelled,
      openai.ParseException() => LlmFailureKind.invalidResponse,
    };
  }
  if (error is anthropic.AnthropicException) {
    if (error is anthropic.ApiException) {
      return _fromStatus(error.statusCode, error.message);
    }
    if (error is anthropic.AbortedException) return LlmFailureKind.cancelled;
    // Its TimeoutException is not exported; anything else from the client
    // (request validation) is a problem with our request.
    if ('$error'.startsWith('TimeoutException')) {
      return LlmFailureKind.unreachable;
    }
    return null;
  }
  if (error is ollama.OllamaException) {
    return switch (error) {
      ollama.ApiException() => _fromStatus(error.statusCode, error.message),
      ollama.TimeoutException() ||
      ollama.StreamException() => LlmFailureKind.unreachable,
      ollama.AbortedException() => LlmFailureKind.cancelled,
      _ => null,
    };
  }
  if (error is http.ClientException ||
      error is SocketException ||
      error is HandshakeException ||
      error is HttpException ||
      error is dart_async.TimeoutException) {
    return LlmFailureKind.unreachable;
  }
  return null;
}

LlmFailureKind _fromStatus(int status, String message) {
  final text = message.toLowerCase();
  if (status == 401 || status == 403) return LlmFailureKind.unauthorized;
  if (status == 404) return LlmFailureKind.notFound;
  if (status == 408) return LlmFailureKind.unreachable;
  if (status == 413) return LlmFailureKind.contextTooLong;
  if (status == 429) return LlmFailureKind.rateLimited;
  if (status >= 500) return LlmFailureKind.server;
  if (_mentions(text, const [
    'context length',
    'context_length',
    'context window',
    'maximum context',
    'prompt is too long',
    'too many tokens',
  ])) {
    return LlmFailureKind.contextTooLong;
  }
  if (_mentions(text, const [
    'content policy',
    'content_policy',
    'content_filter',
    'content management policy',
    'safety system',
  ])) {
    return LlmFailureKind.refused;
  }
  if (text.contains('overloaded')) return LlmFailureKind.server;
  if ((status == 400 || status == 422) &&
      (text.contains('tool') || text.contains('function'))) {
    return LlmFailureKind.toolsRejected;
  }
  return LlmFailureKind.badRequest;
}

bool _mentions(String text, List<String> needles) => needles.any(text.contains);
