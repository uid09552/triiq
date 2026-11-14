import 'openai_connection.dart' show LlmFailureKind;

/// What to do after one model entry failed.
class FailoverDecision {
  const FailoverDecision({required this.failover, this.needsAttention = false});

  /// Try the next entry with the same request.
  final bool failover;

  /// The entry itself looks misconfigured (key, model name, tools): Settings
  /// flags it until it works again.
  final bool needsAttention;

  @override
  String toString() =>
      'FailoverDecision(failover: $failover, attention: $needsAttention)';
}

/// Which failures are worth retrying on the next model entry — a pure
/// table over [LlmFailureKind] (see `classifyLlmError` for how a raw
/// exception becomes one).
///
/// Fail over when another server may well succeed: it could not be reached
/// or timed out, throttled (429), is overloaded or failing (5xx, 529), or
/// this entry is unusable (no key, bad URL, the key or model was refused,
/// the model cannot use tools, the reply was not understood) — the last
/// group also flags the entry as needing attention.
///
/// Do not fail over when the same request would fail the same way
/// elsewhere and only cost money or time: the athlete cancelled, the model
/// refused on content policy, the conversation is longer than the context
/// window, some other 4xx the request itself caused, or an error the app
/// does not recognise (most likely a bug in our own code). Those surface
/// as they are.
class FailoverPolicy {
  const FailoverPolicy();

  FailoverDecision decide(LlmFailureKind? kind) => switch (kind) {
    LlmFailureKind.unreachable ||
    LlmFailureKind.rateLimited ||
    LlmFailureKind.server => const FailoverDecision(failover: true),
    LlmFailureKind.notConfigured ||
    LlmFailureKind.unauthorized ||
    LlmFailureKind.notFound ||
    LlmFailureKind.toolsRejected ||
    LlmFailureKind.invalidResponse => const FailoverDecision(
      failover: true,
      needsAttention: true,
    ),
    LlmFailureKind.noConsent => const FailoverDecision(failover: true),
    LlmFailureKind.cancelled ||
    LlmFailureKind.refused ||
    LlmFailureKind.contextTooLong ||
    LlmFailureKind.badRequest ||
    null => const FailoverDecision(failover: false),
  };
}
