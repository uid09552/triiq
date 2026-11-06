import 'package:flutter/material.dart';

import '../../data/models/local_activity.dart';
import '../../data/repositories/activities_repository.dart';
import '../../evaluation/compare.dart';
import '../../evaluation/session_evaluator.dart' show sportFamily;
import '../../l10n/app_localizations.dart';
import '../activities/activity_icons.dart';

/// Lets the athlete pick a run or ride to compare. When [family] is set only
/// that sport is listed (the second pick must match the first).
Future<LocalActivity?> pickActivity(
  BuildContext context, {
  required ActivitiesRepository repository,
  String? family,
  String? excludeId,
}) {
  return showModalBottomSheet<LocalActivity>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _PickerSheet(
      repository: repository,
      family: family,
      excludeId: excludeId,
    ),
  );
}

class _PickerSheet extends StatelessWidget {
  const _PickerSheet({
    required this.repository,
    required this.family,
    required this.excludeId,
  });

  final ActivitiesRepository repository;
  final String? family;
  final String? excludeId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.cmpPickTitle,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<LocalActivity>>(
                future: repository.getAll(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = [
                    for (final a in snap.data!)
                      if (isComparable(a) &&
                          a.id != excludeId &&
                          (family == null || sportFamily(a.type) == family))
                        a,
                  ].take(150).toList();
                  if (items.isEmpty) {
                    return Center(child: Text(l10n.cmpPickEmpty));
                  }
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final a = items[i];
                      return ListTile(
                        key: ValueKey('pick-${a.id}'),
                        leading: Icon(activityTypeIcon(a.type)),
                        title: Text(
                          a.name ?? a.type ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          [
                            a.date,
                            if (a.distance != null && a.distance! > 0)
                              formatDistanceMeters(a.distance!),
                            if (a.movingTime != null)
                              formatDurationSecs(a.movingTime!),
                          ].join(' · '),
                        ),
                        onTap: () => Navigator.of(context).pop(a),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
