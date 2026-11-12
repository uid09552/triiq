import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/screens/statistics/load_heatmap_screen.dart'
    show heatColor;
import 'package:triiq/widgets/charts/chart_theme.dart';
import 'package:triiq/widgets/charts/chart_viewport.dart';
import 'package:triiq/widgets/charts/line_chart.dart';

Widget _host(Widget child, {bool reduceMotion = false}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(
      size: const Size(400, 600),
      disableAnimations: reduceMotion,
    ),
    child: Scaffold(
      body: Center(child: SizedBox(width: 360, height: 240, child: child)),
    ),
  ),
);

List<ChartSeries> _series() => [
  ChartSeries(
    label: 'CTL',
    color: Colors.blue,
    values: [for (var i = 0; i < 60; i++) 40.0 + i / 2],
  ),
  ChartSeries(
    label: 'ATL',
    color: Colors.red,
    values: [for (var i = 0; i < 60; i++) 50.0 + (i % 7)],
  ),
];

List<String> _labels() => [for (var i = 0; i < 60; i++) 'd$i'];

void main() {
  group('ChartTheme', () {
    for (final brightness in Brightness.values) {
      test('derives from the ColorScheme ($brightness)', () {
        final scheme = ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: brightness,
        );
        final t = ChartTheme.fromColorScheme(scheme);
        expect(t.primary, scheme.primary);
        expect(t.grid, scheme.outlineVariant);
        expect(t.track, scheme.surfaceContainerHighest);
        expect(t.labelStyle.color, scheme.onSurfaceVariant);
        expect(t.seriesColor(0), scheme.primary);
        expect(t.seriesColor(t.categorical.length), scheme.primary);
        // The old public helper still gives the same colours.
        for (var level = 0; level <= 4; level++) {
          expect(heatColor(scheme, level), t.heatColorOf(level));
        }
        expect(t.heatRamp(HeatScale.viridis), hasLength(5));
      });
    }

    test('viridis: more load stands out further from the background', () {
      double contrast(ChartTheme t, int level) =>
          (t.heatColorOf(level, HeatScale.viridis).computeLuminance() -
                  t.surface.computeLuminance())
              .abs();
      for (final brightness in Brightness.values) {
        final t = ChartTheme.fromColorScheme(
          ColorScheme.fromSeed(seedColor: Colors.teal, brightness: brightness),
        );
        expect(contrast(t, 4), greaterThan(contrast(t, 1)));
      }
    });

    test('the Developer font reaches the axis labels', () {
      final t = ChartTheme.fromColorScheme(
        const ColorScheme.dark(),
        textTheme: const TextTheme(
          bodySmall: TextStyle(fontFamily: 'monospace'),
        ),
      );
      expect(t.labelStyle.fontFamily, 'monospace');
    });
  });

  group('MetricLineChart', () {
    testWidgets('entry animation runs, and not with reduced motion', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(MetricLineChart(series: _series(), labels: _labels())),
      );
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpAndSettle();

      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        _host(
          MetricLineChart(series: _series(), labels: _labels()),
          reduceMotion: true,
        ),
      );
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('mouse hover shows a crosshair without selecting', (
      tester,
    ) async {
      int? selected;
      await tester.pumpWidget(
        _host(
          MetricLineChart(
            series: _series(),
            labels: _labels(),
            onSelect: (i) => selected = i,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(
        location: tester.getCenter(find.byType(MetricLineChart)),
      );
      await mouse.moveBy(const Offset(10, 0));
      await tester.pump();
      expect(selected, isNull);
      expect(tester.takeException(), isNull);
      await mouse.removePointer();
    });

    testWidgets('overview brush zooms the shared viewport', (tester) async {
      final vp = ChartViewport();
      await tester.pumpWidget(
        _host(
          MetricLineChart(
            series: _series(),
            labels: _labels(),
            viewport: vp,
            overview: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(vp.isZoomed, isFalse);
      final strip = find.byKey(const ValueKey('chart-overview'));
      final r = tester.getRect(strip);
      await tester.dragFrom(
        Offset(r.left + r.width * 0.2, r.center.dy),
        Offset(r.width * 0.3, 0),
      );
      await tester.pump();
      expect(vp.isZoomed, isTrue);
      expect(vp.lo, greaterThan(5));
      expect(vp.hi, lessThan(40));
    });

    testWidgets('hold-and-drag brushes the plot when brushZoom is on', (
      tester,
    ) async {
      final vp = ChartViewport();
      await tester.pumpWidget(
        _host(
          MetricLineChart(
            series: _series(),
            labels: _labels(),
            viewport: vp,
            brushZoom: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final r = tester.getRect(find.byType(MetricLineChart));
      final g = await tester.startGesture(Offset(r.left + 100, r.center.dy));
      await tester.pump(const Duration(milliseconds: 600));
      await g.moveBy(const Offset(80, 0));
      await tester.pump();
      expect(find.byKey(const ValueKey('chart-brush')), findsOneWidget);
      await g.up();
      await tester.pump();
      expect(vp.isZoomed, isTrue);
      expect(find.byKey(const ValueKey('chart-brush')), findsNothing);
    });

    testWidgets('legend toggles a series out of the chart and its summary', (
      tester,
    ) async {
      final hidden = <String>{};
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: MetricLineChart(
                      series: _series(),
                      labels: _labels(),
                      hiddenSeries: hidden,
                      animate: false,
                    ),
                  ),
                  ChartLegend(
                    series: _series(),
                    hidden: hidden,
                    onToggle: (l) => setState(
                      () =>
                          hidden.contains(l) ? hidden.remove(l) : hidden.add(l),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.bySemanticsLabel(RegExp(r'ATL: latest')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('legend-ATL')));
      await tester.pump();
      expect(hidden, {'ATL'});
      expect(find.bySemanticsLabel(RegExp(r'ATL: latest')), findsNothing);
      expect(find.bySemanticsLabel(RegExp(r'CTL: latest')), findsOneWidget);
      expect(
        find.bySemanticsLabel('ATL: hidden. Tap to show.'),
        findsOneWidget,
      );
    });
  });
}
