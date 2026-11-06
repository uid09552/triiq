import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/evaluation/activity_route.dart';
import 'package:triiq/evaluation/session_streams.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/compare/compare_screen.dart';
import 'package:triiq/util/dates.dart';

LocalActivity _act(String id, int daysAgo, double distance, int seconds) =>
    LocalActivity(
      id: id,
      date: isoDate(DateTime.now().subtract(Duration(days: daysAgo))),
      type: 'Run',
      name: 'Run $id',
      movingTime: seconds,
      distance: distance,
      trainingLoad: 50,
      raw: {'average_heartrate': 150, 'icu_zone_times': null},
      syncedAt: DateTime.now(),
    );

SessionStreams _streams(double mps, double hr) => SessionStreams(
  series: {
    'time': [for (var i = 0; i < 300; i++) i.toDouble()],
    'distance': [for (var i = 0; i < 300; i++) i * mps],
    'heartrate': List<double?>.filled(300, hr),
    'velocity_smooth': List<double?>.filled(300, mps),
  },
);

ActivityRoute _route(double lngOffset) => ActivityRoute(
  [for (var i = 0; i < 30; i++) RoutePoint(48 + i * 0.0003, 11 + lngOffset)],
  times: [for (var i = 0; i < 30; i++) i * 10.0],
);

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 15; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 60));
  }
}

void main() {
  final a = _act('a', 2, 3000, 1000);
  final b = _act('b', 1, 2800, 1100);

  Widget app() => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: CompareScreen(
      initialActivity: a,
      showTiles: false,
      streams: ActivityStreamsRepository(
        fetch: (id) async => id == 'a' ? _streams(3, 150) : _streams(2.8, 160),
      ),
      routes: ActivityRouteRepository(
        fetch: (id) async => id == 'a' ? _route(0) : _route(0.0001),
      ),
    ),
  );

  testWidgets('overlays two runs, shows both courses and a shared tracker', (
    tester,
  ) async {
    await tester.runAsync(() => ActivitiesRepository().upsertAll([a, b]));
    await tester.binding.setSurfaceSize(const Size(420, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(app());
    await _settle(tester);

    // First pick is preselected; no chart until the second is chosen.
    expect(find.text('Run a'), findsOneWidget);
    expect(find.byKey(const ValueKey('compare-map-card')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('pick-second')));
    await _settle(tester);
    await tester.tap(find.byKey(const ValueKey('pick-b')));
    await _settle(tester);

    expect(find.byKey(const ValueKey('compare-map-card')), findsOneWidget);
    expect(find.text('Side by side'), findsOneWidget);
    expect(find.byKey(const ValueKey('cmp-readout')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('cmp-readout'))).data,
      contains('Touch the chart'),
    );
    expect(find.byKey(const ValueKey('compare-tracker-a')), findsNothing);

    // Touching the chart moves the tracker on the readout and on the map.
    final chart = find.byKey(
      const ValueKey('cmp-chart-heartrate-CompareAxis.distance-a-b'),
    );
    expect(chart, findsOneWidget);
    await tester.tapAt(tester.getCenter(chart));
    await tester.pump();

    final readout = tester
        .widget<Text>(find.byKey(const ValueKey('cmp-readout')))
        .data!;
    expect(readout, contains('150 bpm'));
    expect(readout, contains('160 bpm'));
    expect(find.byKey(const ValueKey('compare-tracker-a')), findsOneWidget);
    expect(find.byKey(const ValueKey('compare-tracker-b')), findsOneWidget);

    // Switching to the time axis keeps the tracker.
    await tester.tap(find.byKey(const ValueKey('chart-options')));
    await _settle(tester);
    await tester.tap(find.text('Time'));
    await _settle(tester);
    await tester.tapAt(const Offset(5, 5));
    await _settle(tester);
    expect(find.byKey(const ValueKey('compare-tracker-a')), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('periods tab compares this block with the previous one', (
    tester,
  ) async {
    await tester.runAsync(
      () => ActivitiesRepository().upsertAll([
        _act('p1', 9, 8000, 2400),
        _act('c1', 1, 10000, 3000),
      ]),
    );
    await tester.binding.setSurfaceSize(const Size(420, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app());
    await _settle(tester);

    await tester.tap(find.text('Periods'));
    await _settle(tester);
    await tester.tap(find.byKey(const ValueKey('chart-options')));
    await _settle(tester);
    await tester.tap(find.text('Run').first);
    await _settle(tester);
    await tester.tap(find.text('7d'));
    await _settle(tester);
    await tester.tapAt(const Offset(5, 5));
    await _settle(tester);

    expect(find.text('This block'), findsWidgets);
    expect(find.text('Previous block'), findsWidgets);
    expect(find.text('+25%'), findsWidgets); // 8 km -> 10 km
    expect(tester.takeException(), isNull);
  });
}
