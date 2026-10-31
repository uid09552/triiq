import 'package:flutter/material.dart';

import '../../data/models/local_event.dart';
import '../../l10n/app_localizations.dart';
import '../activities/activity_icons.dart';

/// One session planned for today, as Train Now shows it: sport, name,
/// duration, TSS, where it comes from, and its steps (collapsed when long).
/// Tappable to select it when there is more than one.
class PlannedSessionCard extends StatefulWidget {
  const PlannedSessionCard({
    super.key,
    required this.event,
    this.selected = false,
    this.onTap,
  });

  final LocalEvent event;

  /// Highlighted as the session an alternative is for.
  final bool selected;
  final VoidCallback? onTap;

  /// Lines of steps shown before "Show all".
  static const collapsedLines = 6;

  @override
  State<PlannedSessionCard> createState() => _PlannedSessionCardState();
}

class _PlannedSessionCardState extends State<PlannedSessionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final e = widget.event;
    final color = sportColor(e.type, scheme);
    final minutes = (e.plannedTime ?? 0) ~/ 60;
    final steps = (e.description ?? '').trim();
    final lines = steps.isEmpty ? const <String>[] : steps.split('\n');
    final long = lines.length > PlannedSessionCard.collapsedLines;
    final shown = long && !_expanded
        ? lines.take(PlannedSessionCard.collapsedLines).join('\n')
        : steps;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: widget.selected
            ? BorderSide(color: scheme.primary, width: 2)
            : BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(activityTypeIcon(e.type), color: color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      e.name ?? e.type ?? l10n.plannedSessionFallback,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _SourceChip(event: e),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                [
                  if (e.type != null) e.type!,
                  if (minutes > 0 || e.plannedLoad != null)
                    l10n.planSessionMinutes(minutes, e.plannedLoad ?? 0),
                ].join(' · '),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              if (steps.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    shown,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                if (long)
                  TextButton(
                    onPressed: () => setState(() => _expanded = !_expanded),
                    child: Text(
                      _expanded ? l10n.showLessSteps : l10n.showAllSteps,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceChip extends StatelessWidget {
  const _SourceChip({required this.event});

  final LocalEvent event;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final plan = event.isPlanSession;
    return Tooltip(
      message: plan
          ? (event.planSessionSent
                ? l10n.planSessionSent
                : l10n.planSessionLocalOnly)
          : l10n.plannedSourceIntervals,
      child: Chip(
        visualDensity: VisualDensity.compact,
        avatar: plan
            ? Icon(
                event.planSessionSent
                    ? Icons.cloud_done_outlined
                    : Icons.cloud_off_outlined,
                size: 16,
                color: scheme.onSurfaceVariant,
              )
            : null,
        label: Text(
          plan ? l10n.planSessionBadge : l10n.plannedSourceIntervals,
        ),
      ),
    );
  }
}
