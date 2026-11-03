import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/settings/year_goals_progress.dart';
import 'package:triiq/screens/settings/year_goals_settings.dart';

LocalActivity _run(double metres) => LocalActivity(
  id: '$metres',
  date: '2026-03-01',
  type: 'Run',
  name: null,
  movingTime: 3600,
  distance: metres,
  trainingLoad: null,
  raw: const {},
  syncedAt: DateTime(2026, 3, 1),
);

class _FakeActivities extends ActivitiesRepository {
  _FakeActivities(this.records);
  final List<LocalActivity> records;

  @override
  Future<List<LocalActivity>> getRange(String oldest, String newest) async =>
      records;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('goals persist, blank and non-positive mean no goal', () async {
    final s = YearGoalsSettings.forTesting();
    await s.load();
    expect(s.hasAnyGoal, isFalse);
    expect(s.showOnToday, isTrue);

    await s.setRunKm(1000);
    await s.setCycleKm(0);
    await s.setShowOnToday(false);

    final fresh = YearGoalsSettings.forTesting();
    await fresh.load();
    expect(fresh.goalFor('run'), 1000);
    expect(fresh.goalFor('cycle'), isNull);
    expect(fresh.showOnToday, isFalse);
  });

  test('sums km per target sport and knows how much of the year passed', () {
    expect(yearSportKm([_run(10000), _run(5500)])['run'], closeTo(15.5, 1e-9));
    expect(yearElapsedFraction(DateTime(2026, 1, 1)), closeTo(1 / 365, 1e-9));
    expect(yearElapsedFraction(DateTime(2026, 12, 31)), 1);
  });

  testWidgets('progress shows km done against the goal and the pace', (
    tester,
  ) async {
    final settings = YearGoalsSettings.forTesting();
    await settings.setRunKm(1000);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: YearGoalsProgress(
            settings: settings,
            activities: _FakeActivities([_run(100000)]),
            now: DateTime(2026, 7, 2),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('100 / 1000 km'), findsOneWidget);
    expect(find.textContaining('behind pace'), findsOneWidget);
  });
}
