import '../../agent/openai_connection.dart';
import '../../l10n/app_localizations.dart';

/// The message for a problem with the OpenAI-compatible base URL [url].
String openAiUrlProblemText(
  AppLocalizations l10n,
  OpenAiUrlProblem problem,
  String url,
) => switch (problem) {
  OpenAiUrlProblem.empty => l10n.openaiUrlEmpty,
  OpenAiUrlProblem.invalid ||
  OpenAiUrlProblem.badScheme => l10n.openaiUrlInvalid,
  OpenAiUrlProblem.credentialsInUrl => l10n.openaiUrlCredentials,
  OpenAiUrlProblem.httpPublicHost => l10n.openaiUrlHttpPublic(
    serverHostOf(url),
  ),
};
