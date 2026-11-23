import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/models/local_wellness.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/data/repositories/wellness_repository.dart';
import 'package:triiq/evaluation/energy_balance.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/statistics/energy_screen.dart';
import 'package:triiq/screens/statistics/insights_grid.dart';

LocalWellness well(String date, Map<String, dynamic> raw) => LocalWellness(
  date: date,
  ctl: null,
  atl: null,
  ctlLoad: null,
  atlLoad: null,
  rampRate: null,
  raw: raw,
  syncedAt: DateTime(2026),
);

LocalActivity act(String date, int kcal, {int carbs = 0}) => LocalActivity(
  id: '$date-$kcal',
  date: '${date}T07:00:00',
  type: 'Ride',
  name: 'Ride',
  movingTime: 3600,
  distance: null,
  trainingLoad: 60,
  raw: {'calories': kcal, 'carbs_used': carbs},
  syncedAt: DateTime(2026),
);

class _Wellness extends WellnessRepository {
  _Wellness(this.rows);
  final List<LocalWellness> rows;
  @override
  Future<List<LocalWellness>> getRange(String oldest, String newest) async =>
      rows;
}

class _Activities extends ActivitiesRepository {
  _Activities(this.rows);
  final List<LocalActivity> rows;
  @override
  Future<List<LocalActivity>> getRange(String oldest, String newest) async =>
      rows;
}

void main() {
  group('energy days', () {
    final days = energyDays(
      DateTime(2026, 11, 1),
      DateTime(2026, 11, 3),
      [
        well('2026-11-01', {'kcalConsumed': 2400, 'carbohydrates': 300.0}),
        well('2026-11-03', {'kcalConsumed': 1800, 'protein': 120.0}),
      ],
      [
        act('2026-11-01', 900, carbs: 120),
        act('2026-11-01', 300),
        act('2026-11-03', 1200),
      ],
    );

    test('one row per day, activities summed by day', () {
      expect(days, hasLength(3));
      expect(days[0].eatenKcal, 2400);
      expect(days[0].trainingKcal, 1200);
      expect(days[0].carbsUsedG, 120);
      expect(days[0].sessions, 2);
      expect(days[1].hasIntake, isFalse);
      expect(days[1].trainingKcal, 0);
    });

    test('intake averages skip days with nothing logged', () {
      final s = EnergySummary(days);
      expect(s.loggedDays, 2);
      expect(s.avgEatenKcal, 2100);
      expect(s.avgTrainingKcal, 800);
      expect(s.avgProteinG, 120);
      // 1200 > 1800 / 2 on the 3rd; 1200 is not > 2400 / 2 on the 1st.
      expect(s.heavyBurnDays, 1);
    });

    test('nothing logged and no training is empty', () {
      expect(
        EnergySummary(
          energyDays(DateTime(2026, 11, 1), DateTime(2026, 11, 2), [], []),
        ).isEmpty,
        isTrue,
      );
    });
  });

  Widget wrap(Widget child) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: child,
  );

  testWidgets('the screen shows averages, days and the care note', (t) async {
    await t.pumpWidget(
      wrap(
        EnergyScreen(
          today: DateTime(2026, 11, 3),
          wellness: _Wellness([
            well('2026-11-03', {'kcalConsumed': 1800}),
          ]),
          activities: _Activities([act('2026-11-03', 1200)]),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('1800 kcal'), findsOneWidget);
    expect(find.byKey(const ValueKey('energy-day-2026-11-03')), findsOneWidget);
    expect(find.byKey(const ValueKey('energy-heavy-burn')), findsOneWidget);
    expect(find.byKey(const ValueKey('energy-care-note')), findsOneWidget);
  });

  testWidgets('without data it explains where calories come from', (t) async {
    await t.pumpWidget(
      wrap(
        EnergyScreen(
          today: DateTime(2026, 11, 3),
          wellness: _Wellness(const []),
          activities: _Activities(const []),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('No calories logged'), findsOneWidget);
    expect(find.byKey(const ValueKey('energy-care-note')), findsOneWidget);
  });

  test('Energy is an Insights destination', () {
    expect(insightsDestinations.map((d) => d.id), contains('energy'));
  });
}
