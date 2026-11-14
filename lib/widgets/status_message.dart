import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' show DatabaseException;

import '../agent/chat_model_factory.dart'
    show LlmNotConfiguredException, classifyLlmError;
import '../agent/llm_gateway.dart' show AllModelsFailedException;
import '../agent/openai_connection.dart' show LlmFailureKind;
import '../l10n/app_localizations.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/sync/sync_screen.dart';

/// What can be done about a failure.
enum ErrorFix { retry, connect }

/// A failure in plain language: what happened, why, and what helps.
class FriendlyError {
  const FriendlyError({
    required this.icon,
    required this.title,
    required this.reason,
    required this.fix,
  });

  final IconData icon;
  final String title;
  final String reason;
  final ErrorFix fix;
}

/// Maps the exceptions the app actually meets to text an athlete can act
/// on: offline, a refused key, not connected, Intervals.icu down or
/// throttling, the local database, anything else.
FriendlyError describeError(Object error, AppLocalizations l10n) {
  if (error is AllModelsFailedException) {
    return FriendlyError(
      icon: Icons.cloud_off_outlined,
      title: l10n.llmErrAllFailedTitle,
      reason: describeAgentError(error, l10n),
      fix: ErrorFix.retry,
    );
  }
  // Plain network errors are worded as "offline" here (sync, Intervals.icu);
  // only errors from an LLM client get the AI-server wording.
  final genericNetwork =
      error is SocketException ||
      error is TimeoutException ||
      error is HttpException ||
      error is HandshakeException ||
      error is http.ClientException;
  final llm = genericNetwork ? null : classifyLlmError(error);
  if (llm != null) return describeLlmFailure(llm, l10n);
  if (error is DioException) {
    final status = error.response?.statusCode;
    if (status == 401 || status == 403) {
      return FriendlyError(
        icon: Icons.key_off_outlined,
        title: l10n.smRefusedTitle,
        reason: l10n.smRefusedReason,
        fix: ErrorFix.connect,
      );
    }
    if (status == 429) {
      return FriendlyError(
        icon: Icons.hourglass_bottom,
        title: l10n.smRateTitle,
        reason: l10n.smRateReason,
        fix: ErrorFix.retry,
      );
    }
    if (status != null && status >= 500) {
      return FriendlyError(
        icon: Icons.cloud_off_outlined,
        title: l10n.smServerTitle,
        reason: l10n.smServerReason,
        fix: ErrorFix.retry,
      );
    }
    if (status == null) return _offline(l10n);
  }
  if (error is SocketException ||
      error is TimeoutException ||
      error is HttpException) {
    return _offline(l10n);
  }
  if (error is StateError && error.message.contains('Not connected')) {
    return FriendlyError(
      icon: Icons.link_off,
      title: l10n.smNotConnectedTitle,
      reason: l10n.smNotConnectedReason,
      fix: ErrorFix.connect,
    );
  }
  if (error is DatabaseException) {
    return FriendlyError(
      icon: Icons.storage_outlined,
      title: l10n.smLocalTitle,
      reason: l10n.smLocalReason,
      fix: ErrorFix.retry,
    );
  }
  return FriendlyError(
    icon: Icons.error_outline,
    title: l10n.smGenericTitle,
    reason: l10n.smGenericReason,
    fix: ErrorFix.retry,
  );
}

/// An LLM-server failure (the OpenAI-compatible provider, or its connection
/// test) in plain language. Not the Intervals.icu wording: the key and
/// address it points at are the ones in Settings → LLM provider.
FriendlyError describeLlmFailure(LlmFailureKind kind, AppLocalizations l10n) {
  final (icon, title, reason) = switch (kind) {
    LlmFailureKind.unauthorized => (
      Icons.key_off_outlined,
      l10n.llmErrUnauthorizedTitle,
      l10n.llmErrUnauthorizedReason,
    ),
    LlmFailureKind.notFound => (
      Icons.search_off,
      l10n.llmErrNotFoundTitle,
      l10n.llmErrNotFoundReason,
    ),
    LlmFailureKind.rateLimited => (
      Icons.hourglass_bottom,
      l10n.llmErrRateTitle,
      l10n.llmErrRateReason,
    ),
    LlmFailureKind.server => (
      Icons.cloud_off_outlined,
      l10n.llmErrServerTitle,
      l10n.llmErrServerReason,
    ),
    LlmFailureKind.toolsRejected => (
      Icons.build_circle_outlined,
      l10n.llmErrToolsTitle,
      l10n.llmErrToolsReason,
    ),
    LlmFailureKind.unreachable => (
      Icons.wifi_off,
      l10n.llmErrUnreachableTitle,
      l10n.llmErrUnreachableReason,
    ),
    LlmFailureKind.invalidResponse => (
      Icons.error_outline,
      l10n.llmErrInvalidTitle,
      l10n.llmErrInvalidReason,
    ),
    LlmFailureKind.notConfigured => (
      Icons.settings_outlined,
      l10n.llmErrNotConfiguredTitle,
      l10n.llmErrNotConfiguredReason,
    ),
    LlmFailureKind.noConsent => (
      Icons.privacy_tip_outlined,
      l10n.llmErrNoConsentTitle,
      l10n.llmErrNoConsentReason,
    ),
    LlmFailureKind.cancelled => (
      Icons.cancel_outlined,
      l10n.llmErrCancelledTitle,
      l10n.llmErrCancelledReason,
    ),
    LlmFailureKind.refused => (
      Icons.block_outlined,
      l10n.llmErrRefusedTitle,
      l10n.llmErrRefusedReason,
    ),
    LlmFailureKind.contextTooLong => (
      Icons.notes_outlined,
      l10n.llmErrContextTitle,
      l10n.llmErrContextReason,
    ),
    LlmFailureKind.badRequest => (
      Icons.error_outline,
      l10n.llmErrBadRequestTitle,
      l10n.llmErrBadRequestReason,
    ),
  };
  return FriendlyError(
    icon: icon,
    title: title,
    reason: reason,
    // "Connect" would open Intervals.icu's Profile; the fix here is in
    // Settings → LLM provider, which the reason names.
    fix: ErrorFix.retry,
  );
}

/// The text for a failed chat/agent turn: friendly for an LLM-server
/// failure, the raw message otherwise (it is often what the athlete needs,
/// e.g. "connection refused", or which key is missing). When every model
/// entry failed, one line per entry with its reason.
String describeAgentError(Object error, AppLocalizations l10n) {
  if (error is AllModelsFailedException) {
    final lines = [
      for (final f in error.failures)
        '• ${l10n.llmErrEntryLine(f.entry.label, _shortReason(f.error, l10n))}',
    ];
    return '${l10n.llmErrAllFailedTitle}.\n${lines.join('\n')}';
  }
  if (error is LlmNotConfiguredException) return error.message;
  final kind = classifyLlmError(error);
  if (kind == null || kind == LlmFailureKind.badRequest) return '$error';
  final friendly = describeLlmFailure(kind, l10n);
  return '${friendly.title}. ${friendly.reason}';
}

/// One entry's reason in the "no model answered" list: the friendly title,
/// or the raw text when the failure is not one we recognise.
String _shortReason(Object error, AppLocalizations l10n) {
  final kind = classifyLlmError(error);
  if (kind == null) {
    final text = '$error';
    return text.length <= 120 ? text : '${text.substring(0, 119)}…';
  }
  return describeLlmFailure(kind, l10n).title;
}

/// The short reason for a model switch or an entry's status: "unreachable",
/// "rate limited"… (the friendly title).
String describeLlmFailureShort(LlmFailureKind? kind, AppLocalizations l10n) =>
    kind == null ? l10n.smGenericTitle : describeLlmFailure(kind, l10n).title;

FriendlyError _offline(AppLocalizations l10n) => FriendlyError(
  icon: Icons.wifi_off,
  title: l10n.smOfflineTitle,
  reason: l10n.smOfflineReason,
  fix: ErrorFix.retry,
);

/// The one way screens say "something is wrong" or "nothing here yet": an
/// icon, a short title, a plain reason and, where it helps, an action. For
/// an error the technical text sits behind an expandable "Details".
class StatusMessage extends StatelessWidget {
  const StatusMessage({
    super.key,
    required this.title,
    this.reason,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  }) : error = null,
       onRetry = null;

  /// An error, described with [describeError]. [onRetry] backs the Retry
  /// button; a missing or refused connection offers Profile instead.
  const StatusMessage.error({
    super.key,
    required Object this.error,
    this.onRetry,
    this.compact = false,
  }) : title = '',
       reason = null,
       icon = Icons.error_outline,
       actionLabel = null,
       onAction = null;

  /// Nothing to show yet: what is missing, and the way to get it (Sync).
  static Widget needsSync(
    BuildContext context, {
    Key? key,
    required String title,
    String? reason,
    IconData icon = Icons.inbox_outlined,
    bool compact = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return StatusMessage(
      key: key,
      title: title,
      reason: reason ?? l10n.smNeedHistory,
      icon: icon,
      compact: compact,
      actionLabel: l10n.smOpenSync,
      onAction: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const SyncScreen())),
    );
  }

  final String title;
  final String? reason;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// One row inside a card, instead of a centred block.
  final bool compact;

  final Object? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    var title = this.title, reason = this.reason, icon = this.icon;
    var actionLabel = this.actionLabel;
    var onAction = this.onAction;
    if (error case final e?) {
      final f = describeError(e, l10n);
      title = f.title;
      reason = f.reason;
      icon = f.icon;
      if (f.fix == ErrorFix.connect) {
        actionLabel = l10n.smOpenProfile;
        onAction = () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const ProfileScreen()));
      } else if (onRetry != null) {
        actionLabel = l10n.retryButton;
        onAction = onRetry;
      }
    }

    final iconColor = error != null ? scheme.error : scheme.onSurfaceVariant;
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final action = actionLabel == null || onAction == null
        ? null
        : (compact
              ? TextButton(
                  key: const ValueKey('status-action'),
                  onPressed: onAction,
                  child: Text(actionLabel),
                )
              : FilledButton.tonal(
                  key: const ValueKey('status-action'),
                  onPressed: onAction,
                  child: Text(actionLabel),
                ));
    final details = error == null
        ? null
        : Theme(
            data: theme.copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              key: const ValueKey('status-details'),
              tilePadding: EdgeInsets.zero,
              dense: true,
              title: Text(l10n.smDetails, style: theme.textTheme.labelMedium),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: SelectableText(
                    '$error',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          );

    if (compact) {
      return Semantics(
        container: true,
        liveRegion: error != null,
        child: Column(
          key: const ValueKey('status-message'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (reason != null) Text(reason, style: muted),
                      // Under the text, not beside it: a long German title
                      // and a button don't share a phone's width.
                      if (action != null)
                        Align(alignment: Alignment.centerLeft, child: action),
                    ],
                  ),
                ),
              ],
            ),
            ?details,
          ],
        ),
      );
    }
    return Semantics(
      container: true,
      liveRegion: error != null,
      child: Padding(
        key: const ValueKey('status-message'),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: iconColor),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (reason != null) ...[
              const SizedBox(height: 6),
              Text(reason, textAlign: TextAlign.center, style: muted),
            ],
            if (action != null) ...[const SizedBox(height: 16), action],
            if (details != null) ...[const SizedBox(height: 8), details],
          ],
        ),
      ),
    );
  }
}
