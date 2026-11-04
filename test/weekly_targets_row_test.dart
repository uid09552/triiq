import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/settings/weekly_targets_settings.dart';
import 'package:triiq/screens/today/weekly_targets_row.dart';
import 'package:triiq/widgets/progress_ring.dart';

LocalActivity _activity({required String type, required int movingTime}) =>
    LocalActivity(
      id: type,
      date: '2026-10-26',
      type: type,
      name: null,
      movingTime: movingTime,
      distance: null,
      trainingLoad: null,
      raw: const {},
      syncedAt: DateTime(2026, 10, 26),
    );

void main() {
  late WeeklyTargetsSettings settings;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settings = WeeklyTargetsSettings.forTesting();
    await settings.load();
  });

  Future<void> pump(
    WidgetTester tester, {
    List<LocalActivity> activities = const [],
  }) => tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
        body: WeeklyTargetsRow(
          weekActivities: activities,
          settings: settings,
        ),
      ),
    ),
  );

  testWidgets('hidden when no target is set at all', (tester) async {
    await pump(tester);

    expect(find.byType(ProgressRing), findsNothing);
  });

  testWidgets('hidden when Show on Today is off, even with targets set',
      (tester) async {
    await settings.setSwimHours(2);
    await settings.setShowOnToday(false);
    await pump(tester);

    expect(find.byType(ProgressRing), findsNothing);
  });

  testWidgets('shows one ring per sport that has a target', (tester) async {
    await settings.setCycleHours(4);
    await settings.setRunHours(3);
    await pump(
      tester,
      activities: [
        _activity(type: 'Ride', movingTime: 3600),
        _activity(type: 'Swim', movingTime: 1800),
      ],
    );

    expect(find.byType(ProgressRing), findsNWidgets(2));
  });

  testWidgets('achieved time sums across virtual/real variants of a sport',
      (tester) async {
    await settings.setCycleHours(2);
    await pump(
      tester,
      activities: [
        _activity(type: 'Ride', movingTime: 1800),
        _activity(type: 'VirtualRide', movingTime: 1800),
      ],
    );

    expect(
      find.descendant(
        of: find.byType(ProgressRing),
        matching: find.text('1.0 / 2.0 h'),
      ),
      findsOneWidget,
    );
    expect(find.text('50%'), findsOneWidget);
  });

  testWidgets('long-press on a ring lists that sport\'s week activities', (
    tester,
  ) async {
    await settings.setRunHours(3);
    await pump(
      tester,
      activities: [
        _activity(type: 'Run', movingTime: 3600),
        _activity(type: 'Ride', movingTime: 1800),
      ],
    );

    await tester.longPress(find.byType(ProgressRing));
    await tester.pumpAndSettle();

    expect(find.text('This week', skipOffstage: false), findsNothing);
    expect(find.textContaining('This week'), findsOneWidget);
    // Only the run is listed until "All sports" is switched on.
    expect(find.byType(ListTile), findsOneWidget);
    await tester.tap(find.byType(FilterChip));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsNWidgets(2));
  });

  testWidgets('hours bar sums every activity against the summed targets',
      (tester) async {
    await settings.setCycleHours(6);
    await settings.setRunHours(4);
    await pump(tester, activities: [
      _activity(type: 'Ride', movingTime: 3 * 3600),
      _activity(type: 'Run', movingTime: 3600 + 1800),
      _activity(type: 'Hike', movingTime: 1800), // not a target sport
    ]);

    expect(find.byKey(const ValueKey('weekly-hours-bar')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('weekly-hours-text'))).data,
      '5.0 / 10.0 h',
    );
  });

  testWidgets('hours bar sits above the rings', (tester) async {
    await settings.setRunHours(4);
    await pump(tester);

    final bar = tester.getTopLeft(find.byKey(const ValueKey('weekly-hours-bar')));
    final ring = tester.getTopLeft(find.byKey(const ValueKey('weekly-target-ring-run')));
    expect(bar.dy, lessThan(ring.dy));
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('weekly-hours-text'))).data,
      '0.0 / 4.0 h',
    );
  });

  testWidgets('hours bar copes with more done than planned', (tester) async {
    await settings.setRunHours(1);
    await pump(tester, activities: [_activity(type: 'Run', movingTime: 7200)]);
    expect(tester.takeException(), isNull);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('weekly-hours-text'))).data,
      '2.0 / 1.0 h',
    );
  });
}
