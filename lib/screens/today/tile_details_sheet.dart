import 'package:flutter/material.dart';

import 'dart:convert';

import '../../agent/chat_handoff.dart';
import '../../data/intervals_session.dart';
import '../../l10n/app_localizations.dart';
import '../../util/intervals_links.dart';
import '../chat/ask_trainer.dart';
import 'tile_metric.dart';

/// Long-press on a Today tile: what the figure means, its recent graph, and
/// the ways on — the app's own history screen and, when connected, the same
/// figure on Intervals.icu.
Future<void> showTileDetailsSheet(
  BuildContext context, {
  required TileMetric metric,
  required String label,
  required String value,
  required Color color,
  required String intervalsPath,
  VoidCallback? onShowHistory,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext)!;
      final theme = Theme.of(sheetContext);
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(label, style: theme.textTheme.titleLarge),
                  const SizedBox(width: 12),
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                tileMetricExplainer(l10n, metric),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              MetricPreview(
                metric: metric,
                color: color,
                height: 130,
                interactive: true,
              ),
              const SizedBox(height: 8),
              if (onShowHistory != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.show_chart),
                  title: Text(l10n.tileShowHistory),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    onShowHistory();
                  },
                ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.chat_bubble_outline),
                title: Text(l10n.askTrainer),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  askTrainer(
                    context,
                    ChatTopic(
                      title: label,
                      context: jsonEncode({
                        'metric': metric.name,
                        'label': label,
                        'value': value,
                        'explanation': tileMetricExplainer(l10n, metric),
                        'note':
                            'Use get_training_load / readiness tools for the '
                            'history; the value is as shown on Today.',
                      }),
                      draft: l10n.tileChatDraft(label, value),
                    ),
                  );
                },
              ),
              if (IntervalsSession.instance.athleteId != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.open_in_new),
                  title: Text(l10n.openInIntervals),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    openInIntervals(context, intervalsPath);
                  },
                ),
            ],
          ),
        ),
      );
    },
  );
}
