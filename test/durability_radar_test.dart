import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/evaluation/durability.dart';
import 'package:triiq/evaluation/performance_curves.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/statistics/durability_screen.dart';
import 'package:triiq/widgets/charts/radar_chart.dart';

Widget _app(Widget home, {ThemeData? theme, double textScale = 1}) =>
    MaterialApp(
      theme: theme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: home,
    );

const _src = DurabilitySource(id: 'a1', name: 'Long ride', date: '2026-10-20');

/// Fresh 400 W everywhere; 1,000 kJ keeps 90 % at 5 s..1 h; 2,000 kJ is
/// missing at 1 h and 5 s; 3,000 kJ has nothing at all.
DurabilityResult _result() => DurabilityResult(
  sport: CurveSport.ride,
  metric: CurveMetric.power,
  points: const [5, 60, 300, 1200, 3600],
  fresh: const DurabilityLevel(
    label: '',
    workAfter: 0,
    values: [400, 400, 400, 400, 400],
  ),
  fatigued: const [
    DurabilityLevel(
      label: '1000',
      workAfter: 1000,
      values: [360, 360, 360, 360, 360],
      sources: [_src, _src, _src, _src, _src],
    ),
    DurabilityLevel(
      label: '2000',
      workAfter: 2000,
      values: [null, 340, 368, 340, null],
      sources: [null, _src, _src, _src, null],
    ),
    DurabilityLevel(
      label: '3000',
      workAfter: 3000,
      values: [null, null, null, null, null],
    ),
  ],
  candidates: 3,
  analysed: 3,
  failed: 0,
  days: 180,
);

class _FakeLoader extends DurabilityLoader {
  _FakeLoader(this.result);
  final DurabilityResult result;
  @override
  Future<DurabilityResult> load(
    CurveSport sport,
    int days, {
    void Function(int done, int total)? onProgress,
  }) async => result;
}

Future<void> _open(
  WidgetTester tester, {
  DurabilityResult? result,
  ThemeData? theme,
  double textScale = 1,
  Size size = const Size(360, 2000),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    _app(
      DurabilityScreen(loader: _FakeLoader(result ?? _result())),
      theme: theme,
      textScale: textScale,
    ),
  );
  await tester.pumpAndSettle();
}

RadarChart _radar(WidgetTester tester) =>
    tester.widget<RadarChart>(find.byType(RadarChart));

void main() {
  testWidgets('one axis per duration, one series per level', (tester) async {
    await _open(tester);
    final radar = _radar(tester);
    expect(radar.axes, ['5s', '1m', '5m', '20m', '1h']);
    expect(radar.series, hasLength(3));
    expect(radar.series[0].marker, isNot(radar.series[1].marker));
    expect(radar.series[0].dash, isNull);
    expect(radar.series[1].dash, isNotNull);
  });

  testWidgets('missing data is a gap (null), never 0', (tester) async {
    await _open(tester);
    final values = _radar(tester).series[1].values;
    expect(values[0], isNull);
    expect(values[4], isNull);
    expect(values[1], closeTo(0.85, 1e-9));
    expect(values.where((v) => v == 0), isEmpty);
    expect(_radar(tester).series[2].values.every((v) => v == null), isTrue);
  });

  testWidgets('runs use one axis per distance', (tester) async {
    final run = DurabilityResult(
      sport: CurveSport.run,
      metric: CurveMetric.pace,
      points: durabilityDistances,
      fresh: const DurabilityLevel(
        label: '',
        workAfter: 0,
        values: [240, 700, 1200, 2500],
      ),
      fatigued: const [
        DurabilityLevel(
          label: '10',
          workAfter: 10,
          values: [260, 780, 1300, 2800],
        ),
      ],
      candidates: 1,
      analysed: 1,
      failed: 0,
      days: 180,
    );
    await tester.binding.setSurfaceSize(const Size(360, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _app(DurabilityScreen(sport: CurveSport.run, loader: _FakeLoader(run))),
    );
    await tester.pumpAndSettle();
    expect(_radar(tester).axes, ['1 km', '3 km', '5 km', '10 km']);
  });

  testWidgets('legend toggle hides and shows a level', (tester) async {
    await _open(tester);
    expect(_radar(tester).hidden, isEmpty);
    await tester.tap(find.byKey(const ValueKey('radar-legend-After 2000 kJ')));
    await tester.pump();
    expect(_radar(tester).hidden, {'After 2000 kJ'});
    await tester.tap(find.byKey(const ValueKey('radar-legend-After 2000 kJ')));
    await tester.pump();
    expect(_radar(tester).hidden, isEmpty);
  });

  testWidgets('table is collapsed until toggled', (tester) async {
    await _open(tester);
    expect(find.text('Show table'), findsOneWidget);
    expect(find.textContaining('360 W 90%'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('durability-table-toggle')));
    await tester.pump();
    expect(find.text('Hide table'), findsOneWidget);
    expect(find.textContaining('360 W 90%'), findsWidgets);
    await tester.tap(find.byKey(const ValueKey('durability-table-toggle')));
    await tester.pump();
    expect(find.textContaining('360 W 90%'), findsNothing);
  });

  testWidgets('semantics summarise each level', (tester) async {
    final handle = tester.ensureSemantics();
    await _open(tester);
    expect(
      find.bySemanticsLabel(
        RegExp(
          r'After 1000 kJ: 5s 90 %, 1m 90 %, 5m 90 %, 20m 90 %, 1h 90 %\. '
          r'After 2000 kJ: 1m 85 %, 5m 92 %, 20m 85 %\. '
          r'After 3000 kJ: no data',
        ),
      ),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('tapping a vertex shows value, share and source; opens it', (
    tester,
  ) async {
    await _open(tester);
    expect(find.byKey(const ValueKey('radar-detail')), findsNothing);
    final box = tester.getRect(find.byKey(const ValueKey('radar-paint')));
    // Axis 2 (5 min) of 5 at 92 %: angle -90 + 144 degrees.
    final radius = (box.height / 2 - 44) * 0.92;
    final angle = (-90 + 144) * math.pi / 180;
    final p =
        box.center + Offset(radius * math.cos(angle), radius * math.sin(angle));
    await tester.tapAt(p);
    await tester.pump();
    expect(find.byKey(const ValueKey('radar-detail')), findsOneWidget);
    expect(find.textContaining('368 W'), findsOneWidget);
    expect(find.textContaining('92 % of fresh'), findsOneWidget);
    expect(find.textContaining('Long ride'), findsOneWidget);
    expect(find.text('Open session'), findsOneWidget);
  });

  testWidgets('tapping a gap axis says no data', (tester) async {
    await _open(tester);
    final box = tester.getRect(find.byKey(const ValueKey('radar-paint')));
    // Hide the other levels so only a gap is near the 5 s spoke.
    await tester.tap(find.byKey(const ValueKey('radar-legend-After 1000 kJ')));
    await tester.pump();
    await tester.tapAt(
      box.center + const Offset(0, -60),
    ); // along the 5 s spoke
    await tester.pump();
    expect(find.textContaining('5s, After 2000 kJ: no data'), findsOneWidget);
  });

  testWidgets('fits 360 dp at 2x text and in dark theme, no overflow', (
    tester,
  ) async {
    await _open(
      tester,
      theme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
      textScale: 2,
    );
    expect(find.byType(RadarChart), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('animation is skipped under reduced motion', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: _app(DurabilityScreen(loader: _FakeLoader(_result()))),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.byType(RadarChart), findsOneWidget);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('without a fresh curve the radar explains itself', (
    tester,
  ) async {
    final r = _result();
    await _open(
      tester,
      result: DurabilityResult(
        sport: r.sport,
        metric: r.metric,
        points: r.points,
        fresh: const DurabilityLevel(
          label: '',
          workAfter: 0,
          values: [null, null, null, null, null],
        ),
        fatigued: r.fatigued,
        candidates: 3,
        analysed: 3,
        failed: 0,
        days: 180,
      ),
    );
    expect(find.byType(RadarChart), findsNothing);
    expect(find.textContaining('season curve'), findsOneWidget);
  });
}
