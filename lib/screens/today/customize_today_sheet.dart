import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'today_layout_settings.dart';

String todaySectionLabel(AppLocalizations l10n, TodaySection section) =>
    switch (section) {
      TodaySection.hero => l10n.todaySectionHero,
      TodaySection.weekRibbon => l10n.todaySectionWeekRibbon,
      TodaySection.attention => l10n.todaySectionAttention,
      TodaySection.thisWeek => l10n.todayThisWeekTitle,
      TodaySection.metrics => l10n.todaySectionMetrics,
      TodaySection.activities => l10n.todaysActivities,
      TodaySection.tomorrowsTraining => l10n.tomorrowsTraining,
      TodaySection.athlete => l10n.titleAthlete,
    };

/// Bottom sheet to reorder Today's sections by dragging and remove (or
/// bring back) each with a switch.
Future<void> showCustomizeTodaySheet(
  BuildContext context,
  TodayLayoutSettings layout,
) => showModalBottomSheet<void>(
  context: context,
  useSafeArea: true,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => _CustomizeTodaySheet(layout: layout),
);

class _CustomizeTodaySheet extends StatelessWidget {
  const _CustomizeTodaySheet({required this.layout});

  final TodayLayoutSettings layout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return SafeArea(
      child: ListenableBuilder(
        listenable: layout,
        builder: (context, _) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.customizeTodayTitle,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  TextButton(
                    onPressed: layout.reset,
                    child: Text(l10n.customizeTodayReset),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.customizeTodayHelp,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
            SwitchListTile(
              key: const ValueKey('customize-time-of-day'),
              secondary: const Icon(Icons.schedule),
              title: Text(l10n.customizeTodayTimeOfDay),
              subtitle: Text(l10n.customizeTodayTimeOfDayHint),
              value: layout.timeOfDayOrder,
              onChanged: layout.setTimeOfDayOrder,
            ),
            SwitchListTile(
              key: const ValueKey('customize-all-tiles'),
              secondary: const Icon(Icons.grid_view_outlined),
              title: Text(l10n.customizeTodayAllTiles),
              value: layout.allLoadTiles,
              onChanged: layout.setAllLoadTiles,
            ),
            const Divider(height: 1),
            Flexible(
              child: ReorderableListView(
                shrinkWrap: true,
                onReorder: layout.move,
                children: [
                  for (final (index, section) in layout.order.indexed)
                    SwitchListTile(
                      key: ValueKey(section),
                      secondary: ReorderableDragStartListener(
                        index: index,
                        child: const Icon(Icons.drag_handle),
                      ),
                      title: Text(todaySectionLabel(l10n, section)),
                      value: layout.isVisible(section),
                      onChanged: (v) => layout.setVisible(section, v),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
