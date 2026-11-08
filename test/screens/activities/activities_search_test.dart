import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/activities/activities_screen.dart';
import 'package:triiq/screens/activities/activity_filter.dart';
import 'package:triiq/util/dates.dart';

LocalActivity act(
  String id,
  String date,
  String type,
  String name, {
  double km = 0,
  int minutes = 0,
  int? load,
  Map<String, Object?> raw = const {},
}) => LocalActivity(
  id: id,
  date: date,
  type: type,
  name: name,
  movingTime: minutes * 60,
  distance: km * 1000,
  trainingLoad: load,
  raw: {'id': id, ...raw},
  syncedAt: DateTime(2026, 11, 1),
);

void main() {
  final now = DateTime(2026, 11, 8); // a Sunday
  final all = [
    act(
      '1',
      '2026-11-07',
      'Run',
      'Sunday long run',
      km: 21,
      minutes: 110,
      load: 120,
    ),
    act(
      '2',
      '2026-11-03',
      'Ride',
      'Tempo ride',
      km: 60,
      minutes: 120,
      load: 90,
      raw: {'icu_average_watts': 210},
    ),
    act(
      '3',
      '2026-06-14',
      'Ride',
      'Long ride in June',
      km: 160,
      minutes: 330,
      load: 260,
      raw: {'device_watts': true},
    ),
    act('4', '2026-10-20', 'Swim', 'Pool', km: 3, minutes: 60, load: 50),
    act(
      '5',
      '2026-11-05',
      'VirtualRide',
      'Zwift race',
      km: 35,
      minutes: 60,
      load: 70,
    ),
  ];

  group('ActivityFilter', () {
    test('search matches the name, case-insensitively', () {
      final r = const ActivityFilter(query: 'LONG').apply(all, now: now);
      expect(r.map((a) => a.id), ['1', '3']);
    });

    test('this week, this month and a custom range', () {
      expect(
        const ActivityFilter(
          datePreset: DatePreset.thisWeek,
        ).apply(all, now: now).map((a) => a.id),
        ['1', '5', '2'],
      );
      expect(
        const ActivityFilter(
          datePreset: DatePreset.thisMonth,
        ).apply(all, now: now).length,
        3,
      );
      final june = ActivityFilter(
        datePreset: DatePreset.custom,
        customRange: DateTimeRange(
          start: DateTime(2026, 6, 1),
          end: DateTime(2026, 6, 30),
        ),
      );
      expect(june.apply(all, now: now).single.id, '3');
    });

    test('filters combine: rides with power over 50 km', () {
      final r = const ActivityFilter(
        type: 'Ride',
        minKm: 50,
        hasPower: true,
      ).apply(all, now: now);
      expect(r.map((a) => a.id), ['2', '3']);
      expect(
        const ActivityFilter(
          maxMinutes: 60,
        ).apply(all, now: now).map((a) => a.id),
        ['5', '4'],
      );
    });

    test('GPS: outdoor runs and rides, not the pool or Zwift', () {
      final r = const ActivityFilter(hasGps: true).apply(all, now: now);
      expect(r.map((a) => a.id).toSet(), {'1', '2', '3'});
    });

    test('sorts by distance, duration and load', () {
      ids(ActivitySort s) =>
          ActivityFilter(sort: s).apply(all, now: now).map((a) => a.id);
      expect(ids(ActivitySort.date).first, '1');
      expect(ids(ActivitySort.distance), ['3', '2', '5', '1', '4']);
      expect(ids(ActivitySort.duration).first, '3');
      expect(ids(ActivitySort.load).take(2), ['3', '1']);
    });
  });

  group('Activities screen', () {
    // Dates relative to today, so the screen's own clock agrees.
    final today = DateTime.now();
    String daysAgo(int d) => isoDate(today.subtract(Duration(days: d)));

    Future<void> pump(WidgetTester tester) async {
      await tester.runAsync(
        () => ActivitiesRepository().upsertAll([
          act('a', daysAgo(0), 'Run', 'Easy run', km: 8, minutes: 45, load: 40),
          act(
            'b',
            daysAgo(1),
            'Ride',
            'Long ride',
            km: 120,
            minutes: 240,
            load: 200,
          ),
          act(
            'c',
            daysAgo(200),
            'Run',
            'Long run',
            km: 25,
            minutes: 130,
            load: 150,
          ),
        ]),
      );
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const ActivitiesScreen(),
        ),
      );
      for (var i = 0; i < 6; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 30)),
        );
        await tester.pump();
      }
    }

    testWidgets('search narrows as you type, after a pause', (tester) async {
      await pump(tester);
      expect(find.text('Easy run'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('activity-search-toggle')));
      await tester.pump();
      await tester.enterText(
        find.byKey(const ValueKey('activity-search')),
        'long',
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Easy run'), findsOneWidget); // not yet
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Easy run'), findsNothing);
      expect(find.text('Long ride'), findsOneWidget);
      expect(find.text('Long run'), findsOneWidget);
      expect(find.text('2 activities'), findsOneWidget);
    });

    testWidgets('a date filter shows as a chip; clearing restores all', (
      tester,
    ) async {
      await pump(tester);
      await tester.tap(find.byKey(const ValueKey('activity-filter')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('date-last3Months')));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('Long run'), findsNothing);
      expect(find.byKey(const ValueKey('chip-date')), findsOneWidget);
      expect(find.text('2 activities'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('activity-clear-filters')));
      await tester.pumpAndSettle();
      expect(find.text('Long run'), findsOneWidget);
      expect(find.byKey(const ValueKey('activity-filter-chips')), findsNothing);
    });

    testWidgets('sort by load puts the hardest session first', (tester) async {
      await pump(tester);
      await tester.tap(find.byKey(const ValueKey('activity-filter')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('sort-load')));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      final names = tester
          .widgetList<ListTile>(find.byType(ListTile))
          .map((t) => (t.title as Text).data)
          .toList();
      expect(names, ['Long ride', 'Long run', 'Easy run']);
      expect(find.byKey(const ValueKey('chip-sort')), findsOneWidget);
    });
  });
}
