import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/evaluation/performance_curves.dart';
import 'package:triiq/widgets/charts/duration_curve_chart.dart';

void main() {
  Future<List<double>> pump(
    WidgetTester tester, {
    required CurveSport sport,
    required CurveMetric metric,
    required List<CurvePoint> points,
  }) async {
    tester.view.physicalSize = const Size(800, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final selections = <double>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 600,
            height: 260,
            child: DurationCurveChart(
              series: [
                CurveSeries(
                  label: 'This season',
                  color: Colors.blue,
                  points: points,
                ),
              ],
              metric: metric,
              ticks: curveTicks(sport, metric),
              formatX: metric.byDistance
                  ? formatCurveDistance
                  : formatCurveDuration,
              formatY: metric.byDistance
                  ? (v) => formatPace(v, per: paceUnitMetres(sport))
                  : (v) => v.round().toString(),
              xTitle: metric.byDistance ? 'Distance' : 'Duration',
              yTitle: metric.byDistance ? 'Pace (min/km)' : 'Power (W)',
              onSelect: selections.add,
            ),
          ),
        ),
      ),
    );
    return selections;
  }

  testWidgets('power: duration axis, titles, tap selects a point', (
    tester,
  ) async {
    final selections = await pump(
      tester,
      sport: CurveSport.ride,
      metric: CurveMetric.power,
      points: const [
        CurvePoint(5, 880),
        CurvePoint(60, 420),
        CurvePoint(300, 312),
        CurvePoint(1200, 268),
        CurvePoint(3600, 236),
      ],
    );
    expect(tester.takeException(), isNull);
    expect(find.bySemanticsLabel('Power (W) / Duration'), findsOneWidget);

    await tester.tapAt(tester.getCenter(find.byType(DurationCurveChart)));
    expect(selections, hasLength(1));
    expect([5, 60, 300, 1200, 3600], contains(selections.single));
  });

  testWidgets('run pace: distance axis paints', (tester) async {
    await pump(
      tester,
      sport: CurveSport.run,
      metric: CurveMetric.pace,
      points: const [
        CurvePoint(400, 80),
        CurvePoint(1000, 210),
        CurvePoint(5000, 1150),
        CurvePoint(21100, 5400),
      ],
    );
    expect(tester.takeException(), isNull);
    expect(find.bySemanticsLabel('Pace (min/km) / Distance'), findsOneWidget);
  });

  testWidgets('swim distance axis and an empty curve paint', (tester) async {
    await pump(
      tester,
      sport: CurveSport.swim,
      metric: CurveMetric.pace,
      points: const [CurvePoint(100, 95), CurvePoint(400, 360)],
    );
    expect(tester.takeException(), isNull);

    await pump(
      tester,
      sport: CurveSport.swim,
      metric: CurveMetric.pace,
      points: const [],
    );
    expect(tester.takeException(), isNull);
  });

  test('ticks per sport and metric', () {
    expect(curveTicks(CurveSport.ride, CurveMetric.power), contains(1200));
    expect(curveTicks(CurveSport.swim, CurveMetric.pace), contains(1500));
    expect(curveTicks(CurveSport.run, CurveMetric.pace), contains(5000));
  });
}
