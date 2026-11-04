import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/models/local_wellness.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/data/repositories/wellness_repository.dart';
import 'package:triiq/screens/today/tile_metric.dart';
import 'package:triiq/screens/today/tile_spark.dart';
import 'package:triiq/widgets/stat_tile.dart';

class _Wellness implements WellnessRepository {
  _Wellness(this.rows);

  final List<LocalWellness> rows;

  @override
  Future<List<LocalWellness>> getRange(String a, String b) async =>
      [for (final r in rows) if (r.date.compareTo(a) >= 0 && r.date.compareTo(b) <= 0) r];

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Activities implements ActivitiesRepository {
  _Activities(this.rows);

  final List<LocalActivity> rows;

  @override
  Future<List<LocalActivity>> getRange(String a, String b) async =>
      [for (final r in rows) if (r.date.compareTo(a) >= 0 && r.date.compareTo(b) <= 0) r];

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

LocalWellness w(String date, double ctl, double atl, [double? ramp]) => LocalWellness(
  date: date, ctl: ctl, atl: atl, ctlLoad: null, atlLoad: null,
  rampRate: ramp, raw: const {}, syncedAt: DateTime(2026),
);

LocalActivity a(String date, int load) => LocalActivity(
  id: '$date$load', date: date, type: 'Run', name: 'x', movingTime: 3600,
  distance: null, trainingLoad: load, raw: const {}, syncedAt: DateTime(2026),
);

void main() {
  group('trend rules', () {
    test('noise inside the band is flat, real moves are up or down', () {
      expect(trendBetween(60, 60.4), StatTrend.flat);
      expect(trendBetween(60, 62.5), StatTrend.up);
      expect(trendBetween(60, 57), StatTrend.down);
      expect(trendBetween(0, 0.3), StatTrend.flat);
    });

    test('line trend uses the value a week earlier and skips gaps', () {
      final rising = [for (var i = 0; i < 14; i++) 50.0 + i];
      expect(lineTrend(rising), StatTrend.up);
      expect(lineTrend([null, 50, null, 50.2]), StatTrend.flat);
      expect(lineTrend([50, null, null]), isNull);
    });

    test('load trend compares the last 7 days with the 7 before', () {
      expect(loadTrend([...List.filled(7, 20.0), ...List.filled(7, 60.0)]), StatTrend.up);
      expect(loadTrend([...List.filled(7, 60.0), ...List.filled(7, 20.0)]), StatTrend.down);
      expect(loadTrend(List.filled(5, 1.0)), isNull);
    });

    test('weekly trend ignores the unfinished current week', () {
      // Finished weeks 300 → 400 (up); the partial current week is tiny.
      expect(weeklyTrend([0, 0, 0, 300, 400, 20]), StatTrend.up);
      expect(weeklyTrend([300, 400]), isNull);
    });
  });

  test('loader builds all six series from the cache', () async {
    final today = DateTime(2026, 5, 20);
    String d(int ago) {
      final x = today.subtract(Duration(days: ago));
      return '${x.year}-${x.month.toString().padLeft(2, '0')}-${x.day.toString().padLeft(2, '0')}';
    }

    final loader = TileSparkLoader(
      wellness: _Wellness([
        for (var i = 13; i >= 0; i--) w(d(i), 50.0 + (13 - i), 60.0, 3.0 + (13 - i) * 0.5),
      ]),
      activities: _Activities([
        for (var i = 13; i >= 0; i--) a(d(i), i < 7 ? 80 : 30),
      ]),
      clock: () => today,
    );
    final m = await loader.load();
    expect(m.keys, containsAll(TileMetric.values));
    expect(m[TileMetric.ctl]!.trend, StatTrend.up);
    expect(m[TileMetric.ctl]!.values.length, 14);
    expect(m[TileMetric.atl]!.trend, StatTrend.flat);
    expect(m[TileMetric.form]!.trend, StatTrend.up); // ctl−atl: −10 → +3
    expect(m[TileMetric.tssToday]!.trend, StatTrend.up);
  });

  group('StatTile', () {
    Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: SizedBox(width: 190, child: child)));

    testWidgets('compact tile draws the sparkline and trend arrow', (t) async {
      await t.pumpWidget(wrap(StatTile(
        label: 'CTL', value: '62', icon: Icons.trending_up, compact: true,
        sparkValues: const [50, 52, 55, 60, 62], trend: StatTrend.up,
      )));
      expect(find.byKey(const ValueKey('tile-spark')), findsOneWidget);
      expect(find.byKey(const ValueKey('tile-trend-up')), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('no spark data or one point: nothing extra', (t) async {
      await t.pumpWidget(wrap(const StatTile(label: 'CTL', value: '62', compact: true)));
      expect(find.byKey(const ValueKey('tile-spark')), findsNothing);
      await t.pumpWidget(wrap(const StatTile(
        label: 'CTL', value: '62', compact: true, sparkValues: [1], trend: StatTrend.flat,
      )));
      expect(find.byKey(const ValueKey('tile-spark')), findsNothing);
    });

    testWidgets('a flat series (all equal) still paints without error', (t) async {
      await t.pumpWidget(wrap(const StatTile(
        label: 'ATL', value: '40', compact: true,
        sparkValues: [40, 40, 40, 40], trend: StatTrend.flat,
      )));
      expect(find.byKey(const ValueKey('tile-trend-flat')), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });
}
