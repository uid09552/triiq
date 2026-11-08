import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/models/local_wellness.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/statistics/insight_previews.dart';
import 'package:triiq/screens/statistics/insights_grid.dart';
import 'package:triiq/util/dates.dart';

final _today = DateTime(2026, 11, 8); // a Sunday

LocalActivity _act(int daysAgo, String type, String name, {int load = 60}) {
  final date = isoDate(_today.subtract(Duration(days: daysAgo)));
  return LocalActivity(
    id: 'a$daysAgo$type',
    date: date,
    type: type,
    name: name,
    movingTime: 3600,
    distance: 30000,
    trainingLoad: load,
    raw: {'id': 'a$daysAgo$type', 'icu_joules': 1500000},
    syncedAt: DateTime(2026, 11, 1),
  );
}

LocalWellness _well(int daysAgo, {double ctl = 60, double atl = 66}) {
  final date = isoDate(_today.subtract(Duration(days: daysAgo)));
  return LocalWellness(
    date: date,
    ctl: ctl + (59 - daysAgo) * 0.1,
    atl: atl,
    ctlLoad: null,
    atlLoad: null,
    rampRate: null,
    raw: {
      'id': date,
      'hrv': 60 + daysAgo % 7,
      'restingHR': 48,
      'sleepSecs': 7.5 * 3600,
    },
    syncedAt: DateTime(2026, 11, 1),
  );
}

class _Source extends InsightPreviewSource {
  _Source(this.data);

  final InsightPreviewData data;
  int loads = 0;

  @override
  Future<InsightPreviewData> load() async {
    loads++;
    return data;
  }
}

InsightPreviewData _full() => InsightPreviewData(
  today: _today,
  wellness: [for (var i = 59; i >= 0; i--) _well(i)],
  activities: [
    for (var i = 0; i < 80; i += 2)
      _act(i, i % 4 == 0 ? 'Ride' : 'Run', 'Session $i'),
  ],
);

InsightPreviewData _empty() =>
    InsightPreviewData(today: _today, wellness: const [], activities: const []);

Widget _app(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: Scaffold(
    body: Padding(padding: const EdgeInsets.all(16), child: child),
  ),
);

Future<void> _hold(WidgetTester tester, String id, {int ms = 650}) async {
  final g = await tester.startGesture(
    tester.getCenter(find.byKey(ValueKey('insights-$id'))),
  );
  await tester.pump(Duration(milliseconds: ms));
  await tester.pump(const Duration(milliseconds: 300));
  _gesture = g;
}

TestGesture? _gesture;

Future<void> _release(WidgetTester tester) async {
  await _gesture!.up();
  await tester.pump();
}

void main() {
  setUp(() {
    // A phone.
  });

  Future<void> pump(WidgetTester tester, InsightPreviewSource source) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(InsightsGrid(previewSource: source)));
  }

  testWidgets('holding a tile shows the peek, letting go hides it', (
    tester,
  ) async {
    await pump(tester, _Source(_full()));
    expect(find.byKey(const ValueKey('hold-preview')), findsNothing);

    await _hold(tester, 'explorer');
    expect(find.byKey(const ValueKey('hold-preview')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('insight-preview-explorer')),
      findsOneWidget,
    );
    expect(find.text('Release to close · tap to open'), findsOneWidget);

    await _release(tester);
    expect(find.byKey(const ValueKey('hold-preview')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a quick tap opens the screen and shows no peek', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _app(
        InsightsGrid(
          previewSource: _Source(_full()),
          destinations: [
            InsightsDestination(
              id: 'explorer',
              group: InsightsGroup.fitness,
              icon: Icons.analytics_outlined,
              label: (l) => l.analysisTitle,
              builder: (_) => const Scaffold(body: Text('Opened')),
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('insights-explorer')));
    await tester.pumpAndSettle();
    expect(find.text('Opened'), findsOneWidget);
    expect(find.byKey(const ValueKey('hold-preview')), findsNothing);
  });

  testWidgets('a touch that turns into a drag shows no peek', (tester) async {
    await pump(tester, _Source(_full()));
    final g = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('insights-explorer'))),
    );
    await g.moveBy(const Offset(0, -60));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.byKey(const ValueKey('hold-preview')), findsNothing);
    await g.up();
  });

  testWidgets('every destination has a peek that builds with data', (
    tester,
  ) async {
    await pump(tester, _Source(_full()));
    for (final d in insightsDestinations) {
      await _hold(tester, d.id);
      expect(
        find.byKey(ValueKey('insight-preview-${d.id}')),
        findsOneWidget,
        reason: d.id,
      );
      await _release(tester);
      expect(find.byKey(const ValueKey('hold-preview')), findsNothing);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('every destination has a peek that copes with no data at all', (
    tester,
  ) async {
    await pump(tester, _Source(_empty()));
    for (final d in insightsDestinations) {
      await _hold(tester, d.id);
      expect(find.byKey(ValueKey('insight-preview-${d.id}')), findsOneWidget);
      await _release(tester);
    }
    expect(tester.takeException(), isNull);
  });

  group('what the peeks say', () {
    testWidgets('fitness: CTL, ATL and form', (tester) async {
      await pump(tester, _Source(_full()));
      await _hold(tester, 'analytics');
      expect(find.text('CTL'), findsWidgets);
      expect(find.text('ATL'), findsWidgets);
      expect(find.text('Form'), findsOneWidget);
      await _release(tester);
    });

    testWidgets('metric explorer: this week against the average', (
      tester,
    ) async {
      await pump(tester, _Source(_full()));
      await _hold(tester, 'explorer');
      expect(find.text('This week'), findsOneWidget);
      expect(find.text('Average'), findsOneWidget);
      await _release(tester);
    });

    testWidgets('heatmap, wellness, compare and review show figures', (
      tester,
    ) async {
      await pump(tester, _Source(_full()));
      await _hold(tester, 'heatmap');
      expect(find.text('Active days'), findsOneWidget);
      await _release(tester);
      await _hold(tester, 'wellness');
      expect(find.text('Resting HR'), findsOneWidget);
      expect(find.text('48 bpm'), findsOneWidget);
      await _release(tester);
      await _hold(tester, 'compare');
      expect(find.text('Last 4 weeks'), findsWidgets);
      expect(find.text('Δ'), findsOneWidget);
      await _release(tester);
      await _hold(tester, 'weekly-review');
      expect(find.text('Week before'), findsOneWidget);
      await _release(tester);
      await _hold(tester, 'activities');
      expect(find.text('Session 0'), findsOneWidget);
      await _release(tester);
    });

    testWidgets('curves without a cached curve say how to get one', (
      tester,
    ) async {
      await pump(tester, _Source(_full()));
      await _hold(tester, 'curves');
      expect(find.text('Open it once to load your curves.'), findsOneWidget);
      await _release(tester);
    });

    testWidgets('no data says so, in words', (tester) async {
      await pump(tester, _Source(_empty()));
      await _hold(tester, 'analytics');
      expect(find.text('No data yet. Sync to fill this in.'), findsOneWidget);
      await _release(tester);
    });

    testWidgets('durability counts the long rides', (tester) async {
      await pump(tester, _Source(_full()));
      await _hold(tester, 'durability');
      expect(find.text('Rides over 1,000 kJ (12 weeks)'), findsOneWidget);
      await _release(tester);
    });
  });

  testWidgets('the peek stays on screen: above the tile when there is room, '
      'below when there is not, inside the margins on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // The grid at the top of the screen has no room above: the card goes below.
    await tester.pumpWidget(
      _app(InsightsGrid(previewSource: _Source(_full()))),
    );
    await _hold(tester, 'analytics');
    final tile = tester.getRect(
      find.byKey(const ValueKey('insights-analytics')),
    );
    final card = tester.getRect(
      find.byKey(const ValueKey('insight-preview-analytics')),
    );
    expect(card.top, greaterThan(tile.bottom));
    expect(card.left, greaterThanOrEqualTo(12));
    expect(card.right, lessThanOrEqualTo(320 - 12));
    await _release(tester);

    // The same grid lower down has room above.
    await tester.pumpWidget(
      _app(
        Column(
          children: [
            const SizedBox(height: 280),
            InsightsGrid(previewSource: _Source(_full())),
          ],
        ),
      ),
    );
    await _hold(tester, 'analytics');
    final low = tester.getRect(
      find.byKey(const ValueKey('insights-analytics')),
    );
    final lowCard = tester.getRect(
      find.byKey(const ValueKey('insight-preview-analytics')),
    );
    expect(lowCard.bottom, lessThan(low.top));
    await _release(tester);
    expect(tester.takeException(), isNull);
  });
}
