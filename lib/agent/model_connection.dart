import 'package:dio/dio.dart';

import 'llm_model_entry.dart';
import 'ollama_connection.dart';
import 'openai_connection.dart';

/// The free "does this entry work?" check behind Settings' **Test** and
/// **Load models**: lists the models the server offers, without spending a
/// token. Claude: `GET api.anthropic.com/v1/models`; Ollama: `/api/tags`;
/// OpenAI-compatible: `GET {base}/models`.
///
/// Throws [OpenAiConnectionException] (its [LlmFailureKind] says why) on
/// any failure, so the caller can word it and record it in the entry's
/// health the same way for every provider. The key goes only to the
/// entry's own host (for Ollama only to Ollama Cloud over https).
Future<List<String>> testModelConnection(
  LlmModelEntry entry, {
  String? apiKey,
  Dio? dio,
}) async {
  final key = apiKey?.trim() ?? '';
  switch (entry.provider) {
    case LlmProvider.claude:
      if (key.isEmpty) {
        throw const OpenAiConnectionException(
          LlmFailureKind.notConfigured,
          'No API key.',
        );
      }
      return _fetchClaudeModels(key, dio);
    case LlmProvider.ollama:
      try {
        return await fetchOllamaModels(
          baseUrl: entry.effectiveBaseUrl,
          apiKey: key,
        );
      } on OllamaConnectionException catch (error) {
        final status = RegExp(
          r'responded with (\d+)',
        ).firstMatch(error.message)?.group(1);
        throw OpenAiConnectionException(
          error.message.startsWith('Rejected')
              ? LlmFailureKind.unauthorized
              : switch (int.tryParse(status ?? '')) {
                  404 => LlmFailureKind.notFound,
                  429 => LlmFailureKind.rateLimited,
                  final s? when s >= 500 => LlmFailureKind.server,
                  _ => LlmFailureKind.unreachable,
                },
          error.message,
        );
      }
    case LlmProvider.openai:
      return fetchOpenAiModels(
        baseUrl: entry.effectiveBaseUrl,
        apiKey: key,
        dio: dio,
      );
  }
}

Future<List<String>> _fetchClaudeModels(String key, Dio? dio) async {
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
      'https://${LlmModelEntry.claudeHost}/v1/models',
      queryParameters: const {'limit': 100},
      options: Options(
        headers: {'x-api-key': key, 'anthropic-version': '2023-06-01'},
      ),
    );
    return parseOpenAiModelList(response.data);
  } on DioException catch (error) {
    final status = error.response?.statusCode;
    // Never include the request headers: they carry the key.
    throw OpenAiConnectionException(
      switch (status) {
        401 || 403 => LlmFailureKind.unauthorized,
        404 => LlmFailureKind.notFound,
        429 => LlmFailureKind.rateLimited,
        final s? when s >= 500 => LlmFailureKind.server,
        _ => LlmFailureKind.unreachable,
      },
      status != null
          ? 'Server responded with $status.'
          : 'Could not reach the server.',
      status: status,
    );
  }
}
