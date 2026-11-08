import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/client/intervalls/intervalls_client.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/evaluation/performance_curves.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/activities/activity_detail_screen.dart';
import 'package:triiq/screens/statistics/performance_screen.dart';
import 'package:triiq/widgets/charts/duration_curve_chart.dart';

/// Serves canned responses per sport/metric; counts fetches.
class _FakeCurves implements PerformanceCurvesRepository {
  _FakeCurves(this.responses, {this.cachedResponses = const {}});

  final Map<(CurveSport, CurveMetric), Map<String, dynamic>> responses;
  final Map<(CurveSport, CurveMetric), Map<String, dynamic>> cachedResponses;
  bool fail = false;
  bool stale = true;
  final fetched = <(CurveSport, CurveMetric)>[];

  @override
  Future<PerformanceCurves?> cached(
    CurveSport sport,
    CurveMetric metric,
  ) async {
    final json = cachedResponses[(sport, metric)];
    return json == null
        ? null
        : PerformanceCurves.fromJson(sport, metric, json);
  }

  @override
  Future<bool> isStale(CurveSport sport, CurveMetric metric) async => stale;

  @override
  Future<PerformanceCurves> load(
    CurveSport sport,
    CurveMetric metric, {
    bool force = false,
  }) async {
    fetched.add((sport, metric));
    if (fail) throw Exception('offline');
    return PerformanceCurves.fromJson(
      sport,
      metric,
      responses[(sport, metric)] ?? {'list': <Object>[]},
    );
  }
}

class _FakeActivities extends ActivitiesRepository {
  _FakeActivities(this.byId);

  final Map<String, LocalActivity> byId;

  @override
  Future<LocalActivity?> getById(String id) async => byId[id];
}

Map<String, dynamic> _ride() => {
  'list': [
    {
      'id': 's0',
      'start_date_local': '2026-01-01T00:00:00',
      'end_date_local': '2026-12-31T00:00:00',
      'secs': [5, 60, 300, 1200],
      'values': [880, 420, 312, 268],
      'activity_id': ['i1', 'i2', 'i3', 'i3'],
      'powerModels': [
        {'ftp': 262, 'criticalPower': 270, 'wPrime': 18400, 'pMax': 950},
      ],
    },
    {
      'id': 's1',
      'secs': [5, 60, 300, 1200, 3600],
      'values': [905, 401, 298, 259, 236],
    },
    {'id': '42d', 'secs': <int>[], 'values': <int>[]},
  ],
  'activities': {
    'i3': {
      'id': 'i3',
      'start_date_local': '2026-10-12T07:00:00',
      'name': 'VO2 day',
    },
  },
};

Map<String, dynamic> _runPace() => {
  'list': [
    {
      'id': 's0',
      'distance': [400, 1000, 5000],
      'values': [80, 210, 1150],
      'paceModels': [
        {'criticalSpeed': 4.2, 'dPrime': 180},
      ],
    },
  ],
};

SportSettings _settings(String sport) => sport == 'Ride'
    ? SportSettings(ftp: 252)
    : SportSettings(thresholdPace: 4.0);

void main() {
  Future<void> pump(
    WidgetTester tester,
    _FakeCurves repo, {
    ActivitiesRepository? activities,
  }) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: PerformanceScreen(
          repository: repo,
          activities: activities ?? _FakeActivities(const {}),
          settingsForSport: _settings,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('ride power: chart, key efforts, model gap', (tester) async {
    final repo = _FakeCurves({(CurveSport.ride, CurveMetric.power): _ride()});
    await pump(tester, repo);

    expect(find.text('Ride · Power'), findsOneWidget);
    expect(find.text('Last 42 days: no data'), findsOneWidget);
    expect(find.text('Key efforts'), findsOneWidget);
    expect(find.text('312 W'), findsOneWidget);
    expect(find.text('+14'), findsOneWidget, reason: '5 min: 312 vs 298');
    expect(find.text('236 W'), findsOneWidget, reason: 'last season 60 min');
    expect(
      find.text('Model 262 W vs settings 252 W: +10 W (+4%)'),
      findsOneWidget,
    );
  });

  testWidgets('model card: figures as tiles across the card width', (
    tester,
  ) async {
    final repo = _FakeCurves({(CurveSport.ride, CurveMetric.power): _ride()});
    await pump(tester, repo);

    final card = find.byKey(const ValueKey('model-FTP'));
    expect(card, findsOneWidget);
    expect(find.byKey(const ValueKey('model-CP')), findsOneWidget);
    expect(find.byKey(const ValueKey('model-gap')), findsOneWidget);
    // Several tiles sit side by side instead of one label/value row each.
    final ftp = tester.getTopLeft(find.byKey(const ValueKey('model-FTP')));
    final cp = tester.getTopLeft(find.byKey(const ValueKey('model-CP')));
    expect(cp.dy, ftp.dy);
    expect(cp.dx, greaterThan(ftp.dx));
    // And together they use the card's width.
    final gapBox = tester.getRect(find.byKey(const ValueKey('model-gap')));
    final lastTile = [
      for (final k in ['model-FTP', 'model-CP', "model-W'", 'model-Pmax'])
        if (tester.any(find.byKey(ValueKey(k))))
          tester.getRect(find.byKey(ValueKey(k))),
    ].map((r) => r.right).reduce((a, b) => a > b ? a : b);
    expect(lastTile, greaterThan(gapBox.left + gapBox.width * 0.6));
  });

  testWidgets('on a very wide window the content stays centred and capped', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(2000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = _FakeCurves({(CurveSport.ride, CurveMetric.power): _ride()});
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: PerformanceScreen(
          repository: repo,
          activities: _FakeActivities(const {}),
          settingsForSport: _settings,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final gap = tester.getRect(find.byKey(const ValueKey('model-gap')));
    expect(gap.width, lessThanOrEqualTo(840));
    expect(gap.center.dx, closeTo(1000, 2));
  });

  testWidgets('run without power offers pace, with critical speed', (
    tester,
  ) async {
    final repo = _FakeCurves({(CurveSport.run, CurveMetric.pace): _runPace()});
    await pump(tester, repo);
    // Sport and metric live behind the options icon.
    await tester.tap(find.byKey(const ValueKey('chart-options')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Run'));
    await tester.pumpAndSettle();

    expect(find.text('Run · Pace'), findsOneWidget);
    expect(find.text('Critical speed'), findsOneWidget);
    expect(find.text('3:30 /km'), findsOneWidget, reason: '1 km in 210 s');

    // Power for run came back empty in the fake, so after visiting it the
    // chip goes away and pace is selected again.
    await tester.tap(find.widgetWithText(ChoiceChip, 'Power'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ChoiceChip, 'Power'), findsNothing);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('Run · Pace'), findsOneWidget);
  });

  testWidgets('fresh cache makes no request', (tester) async {
    final repo = _FakeCurves(
      const {},
      cachedResponses: {(CurveSport.ride, CurveMetric.power): _ride()},
    )..stale = false;
    await pump(tester, repo);

    expect(repo.fetched, isEmpty);
    expect(find.text('312 W'), findsOneWidget);
  });

  testWidgets('failed fetch keeps the cached curves and offers retry', (
    tester,
  ) async {
    final repo = _FakeCurves(
      const {},
      cachedResponses: {(CurveSport.ride, CurveMetric.power): _ride()},
    )..fail = true;
    await pump(tester, repo);

    expect(find.textContaining("Couldn't load the curves"), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Retry'), findsOneWidget);
    expect(find.text('312 W'), findsOneWidget, reason: 'cached copy stays');
  });

  testWidgets('opening a session from the readout', (tester) async {
    final repo = _FakeCurves({(CurveSport.ride, CurveMetric.power): _ride()});
    final activity = LocalActivity(
      id: 'i3',
      date: '2026-10-12',
      type: 'Ride',
      name: 'VO2 day',
      movingTime: 3600,
      distance: 30000,
      trainingLoad: 90,
      raw: const {},
      syncedAt: DateTime(2026, 10, 12),
    );
    await pump(tester, repo, activities: _FakeActivities({'i3': activity}));

    // Select 20 min, which this season's ride i3 set.
    tester
        .widget<DurationCurveChart>(find.byType(DurationCurveChart))
        .onSelect!(1200);
    await tester.pumpAndSettle();
    expect(find.text('20m'), findsWidgets);
    expect(
      find.textContaining('268 W · Oct 12, 2026 · VO2 day'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(TextButton, 'Open session').first);
    await tester.pump();
    await tester.pump();
    expect(find.byType(ActivityDetailScreen), findsOneWidget);
  });
}
