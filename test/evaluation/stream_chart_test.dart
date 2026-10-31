import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/evaluation/session_streams.dart';
import 'package:triiq/widgets/charts/stream_chart.dart';

void main() {
  // Six hours at 1 Hz.
  final sixHours = SessionStreams(
    series: {
      'time': [for (var i = 0; i < 21600; i++) i.toDouble()],
      'watts': [for (var i = 0; i < 21600; i++) 180 + 60 * math.sin(i / 300)],
      'heartrate': [for (var i = 0; i < 21600; i++) 130 + (i % 600) / 20],
    },
    intervals: const [
      SessionInterval(start: 3600, end: 4200, type: 'WORK'),
      SessionInterval(start: 4200, end: 4500, type: 'RECOVERY'),
    ],
  );

  test('downsampling keeps the extremes and caps the points', () {
    final values = <double?>[for (var i = 0; i < 21600; i++) 100];
    values[12345] = 999; // a spike
    final points = downsample(values, 600);

    expect(points.length, lessThanOrEqualTo(1200));
    expect(points.any((p) => p.$1 == 12345 && p.$2 == 999), isTrue);
    expect(downsample(const [1, null, 3], 600), [(0, 1.0), (2, 3.0)]);
  });

  Future<void> pump(WidgetTester tester, Set<String> visible) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StreamChart(
            streams: sixHours,
            visible: visible,
            format: (t, v) => t == 'watts' ? '${v.round()} W' : '${v.round()} bpm',
          ),
        ),
      ),
    );
  }

  StreamChartPainter painter(WidgetTester tester) =>
      tester
              .widget<CustomPaint>(
                find.byKey(const ValueKey('stream-chart-paint')),
              )
              .painter!
          as StreamChartPainter;

  testWidgets('a 6-hour ride paints under the point budget', (tester) async {
    await pump(tester, {'watts', 'heartrate'});

    expect(painter(tester).pointCount, lessThanOrEqualTo(2 * 2 * 600));
    expect(painter(tester).intervals, hasLength(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('dragging shows every visible stream at that moment',
      (tester) async {
    await pump(tester, {'watts', 'heartrate'});

    final box = tester.getRect(find.byKey(const ValueKey('stream-chart-paint')));
    await tester.tapAt(Offset(box.left + box.width / 2, box.center.dy));
    await tester.pump();

    // Halfway through: 3:00:00 (index 10800 of 21600).
    expect(find.textContaining('3:00:0'), findsOneWidget);
    expect(find.textContaining(' W'), findsOneWidget);
    expect(find.textContaining(' bpm'), findsOneWidget);
  });

  testWidgets('a stream switched off is neither drawn nor read out',
      (tester) async {
    await pump(tester, {'heartrate'});

    expect(painter(tester).series.keys, ['heartrate']);
  });
}
