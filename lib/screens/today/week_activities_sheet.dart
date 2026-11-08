import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../data/models/local_activity.dart';
import '../../l10n/app_localizations.dart';
import '../activities/activity_detail_screen.dart';
import '../activities/activity_icons.dart';

/// Long-press on a weekly-target ring: this week's activities, the tapped
/// sport first and alone — "All sports" widens it — each opening its detail.
Future<void> showWeekActivitiesSheet(
  BuildContext context, {
  required String sportLabel,
  required String sport,
  required List<LocalActivity> weekActivities,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => _WeekActivitiesSheet(
      parentContext: context,
      sportLabel: sportLabel,
      sport: sport,
      weekActivities: weekActivities,
    ),
  );
}

class _WeekActivitiesSheet extends StatefulWidget {
  const _WeekActivitiesSheet({
    required this.parentContext,
    required this.sportLabel,
    required this.sport,
    required this.weekActivities,
  });

  final BuildContext parentContext;
  final String sportLabel;
  final String sport;
  final List<LocalActivity> weekActivities;

  @override
  State<_WeekActivitiesSheet> createState() => _WeekActivitiesSheetState();
}

class _WeekActivitiesSheetState extends State<_WeekActivitiesSheet> {
  bool _all = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).toString();

    final items = [
      for (final a in widget.weekActivities)
        if (_all || canonicalSport(a.type) == widget.sport) a,
    ]..sort((a, b) => b.date.compareTo(a.date));
    final seconds = items.fold<int>(0, (sum, a) => sum + (a.movingTime ?? 0));

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_all ? l10n.weekActivitiesAllSports : widget.sportLabel}'
                      ' · ${l10n.weekActivitiesThisWeek}',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  FilterChip(
                    label: Text(l10n.weekActivitiesAllSports),
                    selected: _all,
                    onSelected: (v) => setState(() => _all = v),
                  ),
                ],
              ),
            ),
            if (items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  '${items.length} · ${_duration(seconds)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.weekActivitiesEmpty),
              )
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final a in items)
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: sportColor(
                            a.type,
                            scheme,
                          ).withValues(alpha: 0.15),
                          child: Icon(
                            activityTypeIcon(a.type),
                            color: sportColor(a.type, scheme),
                            size: 20,
                          ),
                        ),
                        title: Text(a.name ?? a.type ?? l10n.activityFallback),
                        subtitle: Text(
                          [
                            _day(a.date, locale),
                            if (a.movingTime != null) _duration(a.movingTime!),
                            if (a.distance != null && a.distance! > 0)
                              '${(a.distance! / 1000).toStringAsFixed(1)} km',
                            if (a.trainingLoad != null)
                              '${a.trainingLoad} ${l10n.tssSuffix}',
                          ].join(' · '),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(widget.parentContext).push(
                            MaterialPageRoute(
                              builder: (_) => ActivityDetailScreen(activity: a),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String _day(String iso, String locale) {
    final d = DateTime.tryParse(iso);
    return d == null ? iso : DateFormat.MMMEd(locale).format(d);
  }

  static String _duration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    return h > 0 ? '$h h ${m.toString().padLeft(2, '0')} min' : '$m min';
  }
}
