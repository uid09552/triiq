import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/evaluation/load_heatmap.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/statistics/heatmap_views.dart';
import 'package:triiq/screens/statistics/load_heatmap_screen.dart';
import 'package:triiq/widgets/charts/chart_theme.dart';

LocalActivity _act(String id, String date, int tss) => LocalActivity(
  id: id,
  date: date,
  type: 'Ride',
  name: id,
  movingTime: 3600,
  distance: 30000,
  trainingLoad: tss,
  raw: const {},
  syncedAt: DateTime(2026),
);

final _today = DateTime(2026, 11, 7);

LoadHeatmap _year() => buildLoadHeatmap(
  [
    _act('a', '2026-10-20', 90),
    _act('b', '2026-06-02', 40),
    _act('c', '2025-11-10', 120),
  ],
  from: DateTime(2025, 11, 8),
  to: _today,
);

class _Repo extends ActivitiesRepository {
  @override
  Future<List<LocalActivity>> getRange(String oldest, String newest) async => [
    _act('a', '2026-10-20', 90),
    _act('b', '2026-11-02', 50),
  ];
}

/// [child] at a 360 dp phone's card width (360 − 2 × 16 padding).
Widget _phone(Widget child, {double textScale = 1}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: MediaQuery(
    data: MediaQueryData(
      size: const Size(360, 2400),
      textScaler: TextScaler.linear(textScale),
    ),
    child: Scaffold(
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: 328, child: child),
        ),
      ),
    ),
  ),
);

void main() {
  group('HeatmapGridLayout.fit', () {
    test('a year on a 360 dp phone: weeks as rows, no sideways scroll', () {
      final l = HeatmapGridLayout.fit(328, 53);
      expect(l.vertical, isTrue);
      expect(l.scrolls, isFalse);
      expect(
        HeatmapGridLayout.monthLabelWidth(1) +
            7 * (l.cell + HeatmapGridLayout.gap),
        lessThanOrEqualTo(328),
      );
      expect(l.cell, inInclusiveRange(10, 22));
    });

    test('a wide window keeps the contribution-graph columns', () {
      final l = HeatmapGridLayout.fit(1000, 53);
      expect(l.vertical, isFalse);
      expect(l.scrolls, isFalse);
      expect(
        HeatmapGridLayout.weekdayLabelWidth(1) +
            53 * (l.cell + HeatmapGridLayout.gap),
        lessThanOrEqualTo(1000),
      );
    });

    test('tiny width with large text falls back to scrolling', () {
      final l = HeatmapGridLayout.fit(100, 53, textScale: 2);
      expect(l.scrolls, isTrue);
    });
  });

  group('heatmap views at phone width', () {
    for (final scale in [1.0, 1.3, 2.0]) {
      testWidgets('grid fits 328 px at ${scale}x text', (tester) async {
        await tester.binding.setSurfaceSize(const Size(360, 2400));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        DateTime? picked;
        await tester.pumpWidget(
          _phone(
            HeatmapGridView(
              heatmap: _year(),
              selected: null,
              onSelect: (d) => picked = d,
            ),
            textScale: scale,
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.byType(Scrollable), findsOneWidget); // the page only
        final last = tester.getRect(
          find.byKey(const ValueKey('hm-2026-11-07')),
        );
        expect(last.right, lessThanOrEqualTo(328));
        await tester.tap(find.byKey(const ValueKey('hm-2026-10-20')));
        expect(picked, DateTime(2026, 10, 20));
      });
    }

    testWidgets('months view: a calendar per month, no overflow', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        _phone(
          HeatmapMonthsView(
            heatmap: _year(),
            selected: null,
            onSelect: (_) {},
            scale: HeatScale.viridis,
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Nov 2025'), findsOneWidget);
      expect(find.text('Oct 2026'), findsOneWidget);
      expect(find.byKey(const ValueKey('hm-2026-06-02')), findsOneWidget);
    });

    testWidgets('matrix view: week and weekday totals', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final heatmap = _year();
      await tester.pumpWidget(
        _phone(
          HeatmapMatrixView(heatmap: heatmap, selected: null, onSelect: (_) {}),
        ),
      );
      expect(tester.takeException(), isNull);
      // 2026-10-20 and 2025-11-10 are Tuesday / Monday; 2026-06-02 a Tuesday.
      expect(HeatmapMatrixView.weekdayTotals(heatmap), [
        120,
        130,
        0,
        0,
        0,
        0,
        0,
      ]);
      expect(find.text('${heatmap.totalTss}'), findsWidgets);
      expect(find.byKey(const ValueKey('hm-2026-10-20')), findsOneWidget);
    });
  });

  group('style persistence', () {
    test('saves and loads style and scale', () async {
      SharedPreferences.setMockInitialValues({});
      expect((await HeatmapPrefs.load()).style, HeatmapStyle.grid);
      await const HeatmapPrefs(
        style: HeatmapStyle.matrix,
        scale: HeatScale.viridis,
      ).save();
      final loaded = await HeatmapPrefs.load();
      expect(loaded.style, HeatmapStyle.matrix);
      expect(loaded.scale, HeatScale.viridis);
    });

    testWidgets('the screen opens in the stored style and saves a change', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({HeatmapPrefs.styleKey: 'months'});
      await tester.binding.setSurfaceSize(const Size(420, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: LoadHeatmapScreen(repository: _Repo(), today: _today),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('hm-layout-months')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('chart-options')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('hm-style-matrix')));
      await tester.pumpAndSettle();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(HeatmapPrefs.styleKey), 'matrix');
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('hm-layout-matrix')), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Busiest weekday')), findsOneWidget);
    });
  });
}
