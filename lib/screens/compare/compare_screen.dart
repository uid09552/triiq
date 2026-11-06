import 'package:flutter/material.dart';

import '../../data/models/local_activity.dart';
import '../../data/repositories/activities_repository.dart';
import '../../evaluation/activity_route.dart';
import '../../evaluation/session_streams.dart';
import '../../l10n/app_localizations.dart';
import 'compare_activities_tab.dart';
import 'compare_periods_tab.dart';

/// Compare two runs or rides stream-on-stream and on the map, or this block
/// of training against the previous one. Opened from Statistics, or from an
/// activity's page with that activity already chosen as the first.
class CompareScreen extends StatelessWidget {
  const CompareScreen({
    super.key,
    this.initialActivity,
    this.activities,
    this.streams,
    this.routes,
    this.showTiles = true,
    this.today,
  });

  final LocalActivity? initialActivity;
  final ActivitiesRepository? activities;
  final ActivityStreamsRepository? streams;
  final ActivityRouteRepository? routes;
  final bool showTiles;
  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.cmpTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.cmpTabActivities),
              Tab(text: l10n.cmpTabPeriods),
            ],
          ),
        ),
        body: TabBarView(
          // Swiping would fight the chart's drag-to-track.
          physics: const NeverScrollableScrollPhysics(),
          children: [
            CompareActivitiesTab(
              initialA: initialActivity,
              activities: activities,
              streams: streams,
              routes: routes,
              showTiles: showTiles,
            ),
            ComparePeriodsTab(activities: activities, today: today),
          ],
        ),
      ),
    );
  }
}
