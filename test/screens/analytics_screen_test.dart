import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/statistics/analytics_screen.dart';
import 'package:triiq/util/dates.dart';

LocalActivity _act(int daysAgo, String type, int load, {bool steady = false}) {
  final date = isoDate(DateTime.now().subtract(Duration(days: daysAgo)));
  return LocalActivity(
    id: '$type$daysAgo',
    date: date,
    type: type,
    name: null,
    movingTime: steady ? 5400 : 3000,
    distance: null,
    trainingLoad: load,
    raw: {
      'icu_hr_zone_times': [2400, 600, 300, 100, 50],
      if (steady) 'icu_efficiency_factor': 1.4 + daysAgo * -0.002,
      if (steady) 'decoupling': 4.0,
    },
    syncedAt: DateTime.now(),
  );
}

void main() {
  testWidgets('shows all four analytics sections from cached activities', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await ActivitiesRepository().upsertAll([
        for (var d = 1; d < 60; d += 2) _act(d, 'Ride', 60, steady: d % 4 == 1),
        for (var d = 2; d < 60; d += 3) _act(d, 'Run', 40),
        for (var d = 3; d < 60; d += 7) _act(d, 'Swim', 30),
      ]);
    });
    await tester.binding.setSurfaceSize(const Size(420, 2600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: AnalyticsScreen(),
      ),
    );
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }

    expect(find.text('Fitness by sport'), findsOneWidget);
    expect(find.text('Where your load comes from'), findsOneWidget);
    expect(find.text('Intensity distribution'), findsOneWidget);
    expect(find.text('Load safety'), findsOneWidget);
    expect(find.text('Aerobic base'), findsOneWidget);
    expect(find.text('Efficiency factor'), findsOneWidget);
    expect(find.textContaining('Decoupling'), findsWidgets);
    expect(tester.takeException(), isNull);

    // The weekly/monthly switch sits behind the intensity card's options.
    expect(find.text('Monthly'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('chart-options')).at(1));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Monthly'));
    await tester.pump();
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
    expect(tester.takeException(), isNull);
  });
}
