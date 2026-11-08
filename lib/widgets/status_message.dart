import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' show DatabaseException;

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
