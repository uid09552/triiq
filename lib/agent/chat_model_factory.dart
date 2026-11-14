import 'package:langchain_anthropic/langchain_anthropic.dart';
import 'package:langchain_core/chat_models.dart';
import 'package:langchain_core/tools.dart';
import 'package:langchain_ollama/langchain_ollama.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:openai_dart/openai_dart.dart'
    show
        ApiException,
        ConnectionException,
        OpenAIException,
        RequestTimeoutException;

import 'llm_settings.dart';
import 'ollama_connection.dart';
import 'openai_connection.dart';

/// Thrown when the selected provider has no usable configuration yet.
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

/// Builds the LangChain chat model for the athlete's current provider
/// choice, with [tools] bound as its default options.
///
/// This is the only place a provider is named: everything above it —
/// the agent loop, the tools, the chat UI — works against LangChain's
/// [BaseChatModel], so adding a provider means adding a case here.
///
/// Tools are bound to `defaultOptions` rather than passed per call, because
/// the agent talks to the model through the erased `BaseChatModel` type and
/// so cannot construct provider-specific options at the call site.
BaseChatModel createChatModel(
  LlmSettings settings, {
  List<ToolSpec> tools = const [],
}) {
  if (settings.needsConsent) throw const AiConsentRequiredException();
  switch (settings.provider) {
    case LlmProvider.claude:
      final apiKey = settings.claudeApiKey;
      if (apiKey == null || apiKey.isEmpty) {
        throw const LlmNotConfiguredException(
          'No Claude API key stored. Add one in Settings → LLM provider, or '
          'switch to Ollama or an OpenAI-compatible server.',
        );
      }
      return ChatAnthropic(
        apiKey: apiKey,
        defaultOptions: ChatAnthropicOptions(
          model: settings.claudeModel,
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
      final baseUrl = settings.ollamaBaseUrl.trim();
      if (baseUrl.isEmpty) {
        throw const LlmNotConfiguredException(
          'No Ollama server URL set. Add one in Settings → LLM provider.',
        );
      }
      if (settings.isOllamaCloud && !settings.hasOllamaApiKey) {
        throw const LlmNotConfiguredException(
          'No Ollama Cloud API key stored. Add one in Settings → LLM '
          'provider, or point the server URL at a local Ollama instance.',
        );
      }
      final ollamaApiKey = settings.ollamaApiKey;
      return ChatOllama(
        baseUrl: baseUrl,
        // Ollama Cloud authenticates like any other hosted API — a Bearer
        // token. Sent only to Ollama Cloud over https: a self-hosted or
        // plain-http server must never see the athlete's cloud key.
        headers: ollamaApiKey == null || !isOllamaCloudUrl(baseUrl)
            ? null
            : {'Authorization': 'Bearer $ollamaApiKey'},
        defaultOptions: ChatOllamaOptions(
          model: settings.ollamaModel,
          temperature: 0.2,
          // Tool results (a month of daily metrics, say) plus the system
          // prompt overrun Ollama's 2048-token default context, and what
          // falls out of the window is the data the answer was built on.
          numCtx: 16384,
          tools: tools,
        ),
      );

    case LlmProvider.openai:
      final problem = checkOpenAiBaseUrl(settings.openAiBaseUrl);
      if (problem != null) {
        throw LlmNotConfiguredException(switch (problem) {
          OpenAiUrlProblem.empty =>
            'No server URL set. Add one in Settings → LLM provider.',
          OpenAiUrlProblem.httpPublicHost =>
            'Plain http:// is only allowed for a server on your own network '
                '(localhost or a private address). Use https:// for '
                '${serverHostOf(settings.openAiBaseUrl)}.',
          OpenAiUrlProblem.credentialsInUrl =>
            'The server URL must not contain a user name or password. Put '
                'the key in the API key field instead.',
          _ =>
            'The server URL is not valid. Use the form '
                'https://host/v1 in Settings → LLM provider.',
        });
      }
      final model = settings.openAiModel.trim();
      if (model.isEmpty) {
        throw const LlmNotConfiguredException(
          'No model name set. Add one in Settings → LLM provider.',
        );
      }
      return ChatOpenAI(
        baseUrl: normalizeOpenAiBaseUrl(settings.openAiBaseUrl),
        // Sent to the configured server only; empty = no Authorization
        // header (local servers).
        apiKey: settings.openAiApiKey,
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

/// Classifies a failure from the OpenAI-compatible provider, or `null` when
/// [error] is not one (other providers' errors keep their own text).
///
/// 401/403 → key, 404 → URL or model, 429 → rate limit, 5xx → server, a 400
/// that complains about tools/functions → the server or model cannot do the
/// tool calling the agent needs, no response → unreachable.
LlmFailureKind? classifyLlmError(Object error) {
  if (error is OpenAiConnectionException) return error.kind;
  if (error is! OpenAIException) return null;
  if (error is ApiException) {
    final status = error.statusCode;
    if (status == 401 || status == 403) return LlmFailureKind.unauthorized;
    if (status == 404) return LlmFailureKind.notFound;
    if (status == 429) return LlmFailureKind.rateLimited;
    if (status >= 500) return LlmFailureKind.server;
    if (status == 400 || status == 422) {
      final text = '${error.message} ${error.code} ${error.param}'
          .toLowerCase();
      if (text.contains('tool') || text.contains('function')) {
        return LlmFailureKind.toolsRejected;
      }
    }
    return null;
  }
  if (error is ConnectionException || error is RequestTimeoutException) {
    return LlmFailureKind.unreachable;
  }
  return null;
}
