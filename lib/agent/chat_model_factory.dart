import 'package:langchain_anthropic/langchain_anthropic.dart';
import 'package:langchain_core/chat_models.dart';
import 'package:langchain_core/tools.dart';
import 'package:langchain_ollama/langchain_ollama.dart';

import 'llm_settings.dart';
import 'ollama_connection.dart';

/// Thrown when the selected provider has no usable configuration yet.
class LlmNotConfiguredException implements Exception {
  const LlmNotConfiguredException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// The athlete has not agreed to their data being sent to the AI provider
/// (Settings → Privacy & data). Every path to a provider stops here: the
/// consent is enforced where requests are made, not only in the UI.
class AiConsentRequiredException extends LlmNotConfiguredException {
  const AiConsentRequiredException()
    : super(
        'The AI trainer needs your consent before your data can be sent to '
        'the provider. Allow it in Settings → Privacy & data.',
      );
}

/// Builds the LangChain chat model for the athlete's current provider
/// choice, with [tools] bound as its default options.
///
/// This is the only place either provider is named: everything above it —
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
          'switch to Ollama.',
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
  }
}
