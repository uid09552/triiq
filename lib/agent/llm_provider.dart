/// Which LLM backend a model entry talks to.
enum LlmProvider {
  /// Anthropic's hosted Claude API. Needs an API key; costs money per call.
  claude,

  /// Ollama — defaults to Ollama Cloud (`ollama.com`), which needs an API
  /// key, same shape as Claude. Pointed at a local/self-hosted server
  /// instead, no key is needed. Either way the model must support tool
  /// calling, or the agent can't read any training data.
  ollama,

  /// Any OpenAI-compatible chat-completions server: OpenAI itself, Azure-
  /// style proxies, OpenRouter, LM Studio, vLLM, llama.cpp, LiteLLM… The
  /// key is optional (local servers need none). On a local/private URL it
  /// counts as a local model, anywhere else as a third-party cloud service.
  openai,
}
