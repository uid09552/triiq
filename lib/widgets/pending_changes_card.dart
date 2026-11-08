import 'package:flutter/material.dart';

import '../data/pending_writes.dart';
import '../l10n/app_localizations.dart';

/// Shows changes made offline that haven't reached Intervals.icu yet, and
/// the ones it rejected. Draws nothing when the queue is empty.
class PendingChangesCard extends StatelessWidget {
  PendingChangesCard({super.key, PendingWritesService? service})
    : service = service ?? PendingWritesService.instance;

  final PendingWritesService service;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        if (service.pending == 0 && service.failed == 0) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            key: const ValueKey('pending-card'),
            color: scheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (service.pending > 0) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.cloud_off_outlined,
                          color: scheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.pendingTitle(service.pending),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: scheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                        TextButton(
                          key: const ValueKey('pending-send'),
                          onPressed: service.flush,
                          child: Text(l10n.pendingSyncNow),
                        ),
                      ],
                    ),
                    Text(
                      l10n.pendingSubtitle,
                      style: TextStyle(color: scheme.onSecondaryContainer),
                    ),
                  ],
                  if (service.failed > 0)
                    Row(
                      children: [
                        Icon(Icons.error_outline, color: scheme.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(l10n.pendingFailedTitle(service.failed)),
                        ),
                        TextButton(
                          key: const ValueKey('pending-retry'),
                          onPressed: service.retryFailed,
                          child: Text(l10n.pendingRetry),
                        ),
                        TextButton(
                          key: const ValueKey('pending-discard'),
                          onPressed: service.discardFailed,
                          child: Text(l10n.pendingDiscard),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
