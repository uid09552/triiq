import 'package:dio/dio.dart';

import 'llm_settings.dart';

/// Thrown when an Ollama server/API can't be reached or rejects the request.
class OllamaConnectionException implements Exception {
  const OllamaConnectionException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Hits Ollama's `/api/tags` — supported by both a local/self-hosted server
/// and Ollama Cloud — to confirm [baseUrl]/[apiKey] actually work, and to
/// list the models actually available there instead of guessing from a
/// static suggestion list.
///
/// An empty (but successful) list is a real result, not a failure: a
/// reachable server with nothing pulled yet. Only an unreachable server or
/// a rejected request throws.
/// Whether [url] is Ollama Cloud over https — the only place the stored
/// Ollama API key may be sent.
bool isOllamaCloudUrl(String url) {
  final uri = Uri.tryParse(url.trim());
  return uri != null &&
      uri.scheme == 'https' &&
      uri.host.toLowerCase() == LlmSettings.ollamaCloudHost;
}

/// Whether [url] is unencrypted `http://` — fine for a server on the
/// athlete's own network, worth a warning anywhere else.
bool isPlainHttpUrl(String url) =>
    Uri.tryParse(url.trim())?.scheme.toLowerCase() == 'http';

Future<List<String>> fetchOllamaModels({
  required String baseUrl,
  String? apiKey,
}) async {
  final trimmedUrl = baseUrl.trim();
  if (trimmedUrl.isEmpty) {
    throw const OllamaConnectionException('No server URL set.');
  }

  final dio = Dio(
    BaseOptions(
      baseUrl: trimmedUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        // The key is an Ollama Cloud key: it never goes to any other host,
        // and never over plain http.
        if (apiKey != null &&
            apiKey.trim().isNotEmpty &&
            isOllamaCloudUrl(trimmedUrl))
          'Authorization': 'Bearer ${apiKey.trim()}',
      },
    ),
  );

  try {
    final response = await dio.get<Map<String, dynamic>>('/api/tags');
    final data = response.data ?? const {};
    final models =
        (data['models'] as List<dynamic>? ?? const [])
            .map((entry) {
              final map = entry as Map<String, dynamic>;
              return (map['model'] ?? map['name']) as String?;
            })
            .whereType<String>()
            .toSet()
            .toList()
          ..sort();
    return models;
  } on DioException catch (error) {
    final status = error.response?.statusCode;
    if (status == 401 || status == 403) {
      throw const OllamaConnectionException('Rejected — check the API key.');
    }
    throw OllamaConnectionException(
      status != null
          ? 'Server responded with $status.'
          : (error.message ?? 'Could not reach the server.'),
    );
  }
}
