import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/models/local_wellness.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/data/repositories/wellness_repository.dart';
import 'package:triiq/evaluation/series_stats.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/analysis/analysis_data.dart';
import 'package:triiq/screens/analysis/analysis_screen.dart';
import 'package:triiq/widgets/charts/line_chart.dart';

LocalActivity _act(String date, String type, int load, {int secs = 3600}) =>
    LocalActivity(
      id: '$date$type',
      date: date,
      type: type,
      name: null,
      movingTime: secs,
      distance: 10000,
      trainingLoad: load,
      raw: const {},
      syncedAt: DateTime(2026, 1, 1),
    );

LocalWellness _well(String date, double ctl, double atl) => LocalWellness(
  date: date,
  ctl: ctl,
  atl: atl,
  ctlLoad: null,
  atlLoad: null,
  rampRate: null,
  raw: const {'hrv': 60},
  syncedAt: DateTime(2026, 1, 1),
);

class _FakeWellness extends WellnessRepository {
  _FakeWellness(this.records);
  final List<LocalWellness> records;
  @override
  Future<List<LocalWellness>> getRange(String oldest, String newest) async =>
      records;
}

class _FakeActivities extends ActivitiesRepository {
  _FakeActivities(this.records);
  final List<LocalActivity> records;
  @override
  Future<List<LocalActivity>> getRange(String oldest, String newest) async =>
      records;
}

void main() {
  group('series stats', () {
    test('summarises, ignoring gaps', () {
      final s = computeStats([2, null, 4, 6])!;
      expect(s.count, 3);
      expect(s.mean, 4);
      expect(s.min, 2);
      expect(s.minIndex, 0);
      expect(s.max, 6);
      expect(s.maxIndex, 3);
      expect(s.stdDev, closeTo(2, 1e-9));
      expect(s.change, 4);
      expect(computeStats([null, null]), isNull);
    });

    test('trailing mean averages the window and keeps empty gaps', () {
      expect(trailingMean([2, 4, 6, 8], 2), [2, 3, 5, 7]);
      expect(trailingMean([null, null, 3], 2), [null, null, 3]);
      expect(trailingMean([1, 2], 1), [1, 2]);
    });
  });

  group('buildAnalysisSeries', () {
    final activities = [
      _act('2026-10-26', 'Run', 50),
      _act('2026-10-26', 'Ride', 80),
      _act('2026-10-29', 'Run', 40),
    ];

    test('daily: sums activity metrics, zero on rest days, filters by sport', () {
      final all = buildAnalysisSeries(
        from: DateTime(2026, 10, 26),
        to: DateTime(2026, 10, 30),
        wellness: [_well('2026-10-27', 50, 60)],
        activities: activities,
      );
      expect(all.length, 5);
      expect(all.values[AnalysisMetric.tss], [130, 0, 0, 40, 0]);
      expect(all.values[AnalysisMetric.form]![1], -10);
      expect(all.values[AnalysisMetric.form]![0], isNull);
      expect(all.values[AnalysisMetric.hrv]![1], 60);

      final run = buildAnalysisSeries(
        from: DateTime(2026, 10, 26),
        to: DateTime(2026, 10, 30),
        wellness: const [],
        activities: activities,
        sport: 'run',
      );
      expect(run.values[AnalysisMetric.tss], [50, 0, 0, 40, 0]);
    });

    test('weekly buckets start on Monday and sum', () {
      final weekly = buildAnalysisSeries(
        from: DateTime(2026, 10, 28), // a Wednesday
        to: DateTime(2026, 11, 5),
        wellness: const [],
        activities: activities,
        weekly: true,
      );
      expect(weekly.dates.first, DateTime(2026, 10, 26));
      expect(weekly.values[AnalysisMetric.tss]![0], 130 + 40);
    });
  });

  testWidgets('graphs share one crosshair: tapping one shows the point', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final today = DateTime.now();
    String iso(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: AnalysisScreen(
          wellness: _FakeWellness([_well(iso(today), 55, 60)]),
          activities: _FakeActivities([_act(iso(today), 'Run', 70)]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // TSS, CTL, Form and HRV are on by default.
    expect(find.byType(MetricLineChart), findsNWidgets(4));
    expect(find.byKey(const ValueKey('analysis-selection')), findsNothing);

    await tester.tap(find.byType(MetricLineChart).first);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('analysis-selection')), findsOneWidget);

    // Switching a metric off removes its graph.
    await tester.tap(find.byKey(const ValueKey('analysis-metric-hrv')));
    await tester.pumpAndSettle();
    expect(find.byType(MetricLineChart), findsNWidgets(3));
  });
}
