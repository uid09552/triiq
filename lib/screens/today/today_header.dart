import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';

/// The top tile of Today: a compact date badge, the day's status, a strip of
/// what has been done so far (TSS against plan, time, sessions) with a thin
/// progress line, and the refresh button — plus a "more" button and a
/// long-press that open the quick actions (sync, Train now, log how you feel,
/// open the calendar on Intervals.icu, customize Today).
class TodayHeader extends StatelessWidget {
  const TodayHeader({
    super.key,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.loading,
    required this.onRefresh,
    required this.onTrainNow,
    required this.onFeel,
    required this.onCustomize,
    this.onOpenIntervals,
    this.titleColor,
    this.statusChip,
    this.doneTss = 0,
    this.plannedTss = 0,
    this.doneSeconds = 0,
    this.sessions = 0,
  });

  final DateTime date;
  final String title;

  /// Tints the title, e.g. in the readiness colour when readiness advises
  /// caution.
  final Color? titleColor;

  /// A small sync-status line under the figures (see `SyncStatusChip`).
  final Widget? statusChip;
  final String subtitle;
  final bool loading;

  final VoidCallback onRefresh;
  final VoidCallback onTrainNow;
  final VoidCallback onFeel;
  final VoidCallback onCustomize;

  /// Null when not connected: there is no athlete page to open.
  final VoidCallback? onOpenIntervals;

  final int doneTss;
  final int plannedTss;
  final int doneSeconds;
  final int sessions;

  static String _duration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    return h > 0 ? '$h:${m.toString().padLeft(2, '0')} h' : '$m min';
  }

  Future<void> _showActions(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              key: const ValueKey('hero-action-sync'),
              leading: const Icon(Icons.sync),
              title: Text(l10n.heroSyncNow),
              onTap: () => Navigator.pop(context, 'sync'),
            ),
            ListTile(
              key: const ValueKey('hero-action-train'),
              leading: const Icon(Icons.fitness_center),
              title: Text(l10n.titleTrainNow),
              onTap: () => Navigator.pop(context, 'train'),
            ),
            ListTile(
              key: const ValueKey('hero-action-feel'),
              leading: const Icon(Icons.mood_outlined),
              title: Text(l10n.feelActionLabel),
              onTap: () => Navigator.pop(context, 'feel'),
            ),
            if (onOpenIntervals != null)
              ListTile(
                key: const ValueKey('hero-action-intervals'),
                leading: const Icon(Icons.open_in_new),
                title: Text(l10n.openInIntervals),
                onTap: () => Navigator.pop(context, 'intervals'),
              ),
            ListTile(
              key: const ValueKey('hero-action-customize'),
              leading: const Icon(Icons.tune),
              title: Text(l10n.customizeTodayTitle),
              onTap: () => Navigator.pop(context, 'customize'),
            ),
          ],
        ),
      ),
    );
    switch (choice) {
      case 'sync':
        onRefresh();
      case 'train':
        onTrainNow();
      case 'feel':
        onFeel();
      case 'intervals':
        onOpenIntervals?.call();
      case 'customize':
        onCustomize();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final hasStats = doneTss > 0 || plannedTss > 0 || sessions > 0;

    Widget chip(IconData icon, String text) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: scheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.labelMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    return Card(
      key: const ValueKey('today-header'),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onLongPress: () => _showActions(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat.MMM(locale).format(date).toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onPrimaryContainer,
                            fontSize: 9,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          '${date.day}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: scheme.onPrimaryContainer,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat.EEEE(locale).format(date).toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            color: titleColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('hero-more'),
                    onPressed: () => _showActions(context),
                    tooltip: l10n.heroMoreTooltip,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.more_horiz,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  // Doubles as the refresh affordance: pull-to-refresh is
                  // fine on a phone but awkward with a mouse on Windows.
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: loading
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          )
                        : IconButton(
                            key: const ValueKey('hero-refresh'),
                            onPressed: onRefresh,
                            tooltip: l10n.refreshTooltip,
                            visualDensity: VisualDensity.compact,
                            icon: Icon(Icons.refresh, color: scheme.primary),
                          ),
                  ),
                ],
              ),
              if (hasStats) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Wrap(
                    key: const ValueKey('hero-stats'),
                    spacing: 14,
                    runSpacing: 4,
                    children: [
                      chip(
                        Icons.bolt_outlined,
                        plannedTss > 0
                            ? l10n.dayCardLoadOfPlanned(doneTss, plannedTss)
                            : l10n.dayCardLoadDone(doneTss),
                      ),
                      if (doneSeconds > 0)
                        chip(Icons.timer_outlined, _duration(doneSeconds)),
                      if (sessions > 0)
                        chip(Icons.directions_run, l10n.heroSessions(sessions)),
                    ],
                  ),
                ),
                if (plannedTss > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 6, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        key: const ValueKey('hero-progress'),
                        minHeight: 3,
                        value: (doneTss / plannedTss).clamp(0.0, 1.0),
                        backgroundColor: scheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
              ],
              if (statusChip != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: statusChip,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
