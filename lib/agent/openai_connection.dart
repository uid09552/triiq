import 'dart:convert';

import 'package:dio/dio.dart';

/// Why a request to an LLM server failed, in terms the athlete can act on.
/// Shared by the connection test in Settings and the runtime error mapping
/// (`describeError`), so both read the same way.
enum LlmFailureKind {
  /// 401 / 403: the server did not accept the API key (or wants one).
  unauthorized,

  /// 404: the URL or the model is wrong.
  notFound,

  /// 429: rate limit or quota exhausted.
  rateLimited,

  /// 5xx: the server itself is failing.
  server,

  /// The server rejected the tool definitions the agent depends on.
  toolsRejected,

  /// No answer at all: wrong host/port, server down, offline, TLS failure.
  unreachable,

  /// The server answered, but not with an OpenAI-style response.
  invalidResponse,

  /// The model entry is incomplete (no key, no URL, no model name) — found
  /// before anything was sent.
  notConfigured,

  /// The athlete has not agreed to data going to this entry's host; nothing
  /// was sent.
  noConsent,

  /// The request was cancelled on our side.
  cancelled,

  /// The model refused on content policy / safety grounds.
  refused,

  /// The conversation is longer than the model's context window.
  contextTooLong,

  /// Any other 4xx the request itself caused.
  badRequest,
}

/// Thrown by [fetchOpenAiModels] when the server can't be reached or
/// rejects the request.
class OpenAiConnectionException implements Exception {
  const OpenAiConnectionException(this.kind, this.message, {this.status});

  final LlmFailureKind kind;

  /// A short English description for logs; the UI localizes by [kind].
  final String message;

  /// The HTTP status, when the server answered.
  final int? status;

  @override
  String toString() => message;
}

/// What is wrong with an OpenAI-compatible base URL, if anything.
enum OpenAiUrlProblem {
  /// Nothing entered.
  empty,

  /// Not an absolute `http(s)://host…` URL.
  invalid,

  /// A scheme other than http/https.
  badScheme,

  /// `user:password@` in the URL: it would be stored and exported in clear.
  credentialsInUrl,

  /// `http://` to a host outside the athlete's own network: prompts and
  /// health data would cross the internet unencrypted.
  httpPublicHost,
}

/// Checks [url] as an OpenAI-compatible base URL. `null` means usable.
///
/// Rule: `https://` is accepted for any host; plain `http://` only for
/// localhost, private/LAN addresses and local names (see [isLocalHost]).
OpenAiUrlProblem? checkOpenAiBaseUrl(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return OpenAiUrlProblem.empty;
  final uri = Uri.tryParse(trimmed);
  // `localhost:1234/v1` parses as scheme "localhost" without an authority.
  if (uri == null || !uri.hasScheme || !uri.hasAuthority || uri.host.isEmpty) {
    return OpenAiUrlProblem.invalid;
  }
  final scheme = uri.scheme.toLowerCase();
  if (scheme != 'http' && scheme != 'https') return OpenAiUrlProblem.badScheme;
  if (uri.userInfo.isNotEmpty) return OpenAiUrlProblem.credentialsInUrl;
  if (scheme == 'http' && !isLocalHost(uri.host)) {
    return OpenAiUrlProblem.httpPublicHost;
  }
  return null;
}

/// Whether [url] is a usable base URL (see [checkOpenAiBaseUrl]).
bool isValidOpenAiBaseUrl(String url) => checkOpenAiBaseUrl(url) == null;

/// Whether the server at [url] is on the athlete's own machine or network —
/// loopback, a private (RFC 1918) or link-local address, a single-label or
/// `.local`/`.lan`/`.home.arpa`/`.internal` name. Such a server is treated
/// as a local model: the consent text says the data stays on the network,
/// the system prompt adds the small-model hints, and plain `http://` is
/// allowed. Anything else — including a public IP — is a third party.
bool isLocalServerUrl(String url) {
  final uri = Uri.tryParse(url.trim());
  return uri != null && uri.hasAuthority && isLocalHost(uri.host);
}

/// The hostname of [url] for display (consent text), or the trimmed input.
String serverHostOf(String url) {
  final uri = Uri.tryParse(url.trim());
  return uri != null && uri.host.isNotEmpty ? uri.host : url.trim();
}

/// Whether [host] (a name or IP literal) is local/private. See
/// [isLocalServerUrl].
bool isLocalHost(String host) {
  var h = host.trim().toLowerCase();
  if (h.startsWith('[') && h.endsWith(']')) h = h.substring(1, h.length - 1);
  if (h.isEmpty) return false;

  final v4 = _ipv4(h);
  if (v4 != null) {
    final a = v4[0];
    final b = v4[1];
    return a == 127 || // loopback
        a == 10 || // 10.0.0.0/8
        (a == 172 && b >= 16 && b <= 31) || // 172.16.0.0/12
        (a == 192 && b == 168) || // 192.168.0.0/16
        (a == 169 && b == 254); // link-local
  }
  if (h.contains(':')) {
    // IPv6 literal: loopback, unique-local fc00::/7, link-local fe80::/10.
    if (h == '::1') return true;
    final first = int.tryParse(h.split(':').first, radix: 16);
    if (first == null) return false;
    return (first & 0xfe00) == 0xfc00 || (first & 0xffc0) == 0xfe80;
  }
  if (h == 'localhost' || h.endsWith('.localhost')) return true;
  if (!h.contains('.')) return true; // single-label: only resolves on a LAN
  return h.endsWith('.local') ||
      h.endsWith('.lan') ||
      h.endsWith('.home.arpa') ||
      h.endsWith('.internal');
}

List<int>? _ipv4(String host) {
  final parts = host.split('.');
  if (parts.length != 4) return null;
  final nums = <int>[];
  for (final part in parts) {
    final n = int.tryParse(part);
    if (n == null || n < 0 || n > 255 || part.length > 3) return null;
    nums.add(n);
  }
  return nums;
}

/// [baseUrl] without whitespace and trailing slashes.
String normalizeOpenAiBaseUrl(String baseUrl) =>
    baseUrl.trim().replaceFirst(RegExp(r'/+$'), '');

/// Hits `GET {baseUrl}/models` — the OpenAI-style model listing that OpenAI,
/// OpenRouter, LM Studio, vLLM, llama.cpp's server and LiteLLM all serve —
/// to confirm the URL/key work and to list the models on offer.
///
/// The key (if any) goes only to [baseUrl], which has passed
/// [checkOpenAiBaseUrl]; an invalid URL throws before anything is sent.
/// [dio] is for tests.
Future<List<String>> fetchOpenAiModels({
  required String baseUrl,
  String? apiKey,
  Dio? dio,
}) async {
  final problem = checkOpenAiBaseUrl(baseUrl);
  if (problem != null) {
    throw OpenAiConnectionException(
      LlmFailureKind.unreachable,
      'Invalid server URL ($problem).',
    );
  }
  final base = normalizeOpenAiBaseUrl(baseUrl);
  final key = apiKey?.trim() ?? '';
  final client =
      dio ??
      Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
  try {
    final response = await client.get<Object?>(
      '$base/models',
      options: Options(
        headers: {if (key.isNotEmpty) 'Authorization': 'Bearer $key'},
      ),
    );
    return parseOpenAiModelList(response.data);
  } on DioException catch (error) {
    final status = error.response?.statusCode;
    final kind = switch (status) {
      401 || 403 => LlmFailureKind.unauthorized,
      404 => LlmFailureKind.notFound,
      429 => LlmFailureKind.rateLimited,
      final s? when s >= 500 => LlmFailureKind.server,
      _ => LlmFailureKind.unreachable,
    };
    // Never include the request headers: they carry the key.
    throw OpenAiConnectionException(
      kind,
      status != null
          ? 'Server responded with $status.'
          : 'Could not reach the server.',
      status: status,
    );
  }
}

/// The model ids in a `/models` response: `{"data": [{"id": "gpt-4o"}, …]}`.
/// Tolerates servers that use `models`, `name` or `model` instead. Sorted
/// and de-duplicated. An empty list is a valid answer (nothing loaded yet);
/// a body that is not a model listing throws.
List<String> parseOpenAiModelList(Object? body) {
  if (body is String) {
    try {
      body = jsonDecode(body);
    } on FormatException {
      // Falls through to the "not a model list" error below.
    }
  }
  Object? entries;
  if (body is Map) {
    entries = body['data'] ?? body['models'];
  } else if (body is List) {
    entries = body;
  }
  if (entries is! List) {
    throw const OpenAiConnectionException(
      LlmFailureKind.invalidResponse,
      'The server did not return a model list.',
    );
  }
  final ids = <String>{};
  for (final entry in entries) {
    final id = switch (entry) {
      String s => s,
      Map m => m['id'] ?? m['name'] ?? m['model'],
      _ => null,
    };
    if (id is String && id.trim().isNotEmpty) ids.add(id.trim());
  }
  return ids.toList()..sort();
}
