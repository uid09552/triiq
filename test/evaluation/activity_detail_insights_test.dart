import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/planned_items.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/data/repositories/events_repository.dart';
import 'package:triiq/data/repositories/plans_repository.dart';
import 'package:triiq/data/repositories/wellness_repository.dart';
import 'package:triiq/evaluation/new_training.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/evaluation/session_streams.dart';
import 'package:triiq/plan/knowledge.dart';
import 'package:triiq/screens/activities/activity_detail_screen.dart';
import 'package:triiq/screens/insights/insights_card.dart';
import 'package:triiq/util/dates.dart';

void main() {
  late Directory dir;
  late AppDatabase database;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dir = await Directory.systemTemp.createTemp('triiq_detail_insights');
    database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
  });

  tearDown(() async {
    await database.close();
    await dir.delete(recursive: true);
  });

  testWidgets('today\'s session shows insights and counts as seen',
      (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final now = DateTime.now();
    final today = isoDate(now);
    final ride = LocalActivity(
      id: 'i7',
      date: today,
      type: 'Ride',
      name: 'Long ride',
      movingTime: 3600,
      distance: null,
      trainingLoad: 120,
      raw: {
        'id': 'i7',
        'start_date_local': '${today}T07:00:00',
        'icu_achievements': [
          {'type': 'BEST_POWER', 'watts': 320, 'secs': 300},
        ],
      },
      syncedAt: now,
    );
    final activities = ActivitiesRepository(database: database);
    final planned = PlannedItemsRepository(
      events: EventsRepository(database: database),
      plans: PlansRepository(database: database),
      copyEvents: () async => true,
    );
    await tester.runAsync(() => activities.upsertAll([ride]));

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: ActivityDetailScreen(
          activity: ride,
          streams: ActivityStreamsRepository(
            database: database,
            fetch: (_) async => const SessionStreams(series: {}, intervals: []),
          ),
          plannedItems: planned,
          insights: SessionInsightsLoader(
            activities: activities,
            planned: planned,
            wellness: WellnessRepository(database: database),
            knowledge: KnowledgeRepository(
              loadAsset: () async => File('docs/okf.md').readAsStringSync(),
            ),
          ),
        ),
      ),
    );
    for (var i = 0; i < 12; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 40)),
      );
      await tester.pump();
    }

    expect(find.byKey(const ValueKey('insights')), findsOneWidget);
    expect(find.byKey(const ValueKey('insights-recovery')), findsOneWidget);
    expect(find.textContaining('320 W'), findsOneWidget);
    expect(
      await tester.runAsync(() => SeenSessionsStore().seenToday()),
      {'i7'},
    );
  });
}
