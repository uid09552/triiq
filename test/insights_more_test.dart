import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/more/more_screen.dart';
import 'package:triiq/screens/statistics/insights_grid.dart';

Widget _app(Widget home) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: Scaffold(body: home),
);

void main() {
  testWidgets('#47/#48 every analysis view is one tile on the Insights hub', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _app(const SingleChildScrollView(child: InsightsGrid())),
    );

    for (final label in [
      'Training analytics',
      'Metric explorer',
      'Load heatmap',
      'Performance curves',
      'Best efforts',
      'Durability',
      'Wellness trends',
      'Compare',
      'Weekly review',
      'Activities',
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    // Compact: the whole grid fits in the top third of a phone screen.
    final grid = tester.getRect(find.byKey(const ValueKey('insights-grid')));
    expect(grid.height, lessThan(800 / 3 + 40));
    expect(tester.takeException(), isNull);
  });

  test('no two destinations share a name or an id', () {
    final ids = insightsDestinations.map((d) => d.id).toList();
    expect(ids.toSet(), hasLength(ids.length));
    expect(
      insightsDestinations.map((d) => d.group).toSet(),
      InsightsGroup.values.toSet(),
    );
  });

  testWidgets('a tile opens its screen', (tester) async {
    await tester.pumpWidget(
      _app(
        InsightsGrid(
          destinations: [
            InsightsDestination(
              id: 'x',
              group: InsightsGroup.review,
              icon: Icons.star,
              label: (_) => 'Target',
              builder: (_) => const Scaffold(body: Text('opened')),
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('insights-x')));
    await tester.pumpAndSettle();
    expect(find.text('opened'), findsOneWidget);
  });

  testWidgets(
    '#49 More is grouped, without analysis, activities or placeholders',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_app(const MoreScreen()));

      expect(find.text('PLAN'), findsOneWidget);
      expect(find.text('TRAINER'), findsOneWidget);
      expect(find.text('DATA'), findsOneWidget);
      expect(find.text('Training plans'), findsOneWidget);
      expect(find.text('Sync'), findsOneWidget);
      for (final gone in [
        'Metric explorer',
        'Analysis',
        'Weekly review',
        'Activities',
        'Gear',
      ]) {
        expect(find.text(gone), findsNothing, reason: gone);
      }
      expect(find.textContaining('coming soon'), findsNothing);
    },
  );
}
