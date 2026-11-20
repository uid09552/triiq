import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/calendar/month_goals_peek.dart';
import 'package:triiq/screens/calendar/year_calendar_view.dart';
import 'package:triiq/screens/settings/year_goals_settings.dart';

LocalActivity _a(String date, String type, double km, {int minutes = 60}) =>
    LocalActivity(
      id: '$date$type$km',
      date: date,
      type: type,
      name: null,
      movingTime: minutes * 60,
      distance: km * 1000,
      trainingLoad: 50,
      raw: const {},
      syncedAt: DateTime(2026),
    );

Map<String, List<LocalActivity>> _byDate(List<LocalActivity> list) {
  final map = <String, List<LocalActivity>>{};
  for (final a in list) {
    (map[a.date] ??= []).add(a);
  }
  return map;
}

void main() {
  final activities = _byDate([
    _a('2026-01-10', 'Run', 100),
    _a('2026-02-05', 'Run', 60),
    _a('2026-02-12', 'Ride', 200, minutes: 300),
    _a('2026-02-20', 'Swim', 3, minutes: 60),
    _a('2026-03-01', 'Run', 50),
  ]);

  test('month sums, share of a twelfth and cumulative progress', () {
    final goals = YearGoalsSettings.forTesting()..runKm = 1200;
    final stats = monthSportStats(activities, DateTime(2026, 2), goals);
    final run = stats.firstWhere((s) => s.sport == 'run');
    expect(run.monthKm, 60);
    expect(run.monthHours, 1);
    // 1200 / 12 = 100 km a month; 60 km is 60 %.
    expect(run.shareOfMonthlyGoal, 60);
    expect(run.cumulativeShare[0], closeTo(100 / 1200, 1e-9));
    expect(run.cumulativeShare[1], closeTo(160 / 1200, 1e-9));
    expect(run.cumulativeShare[2], closeTo(210 / 1200, 1e-9));

    final ride = stats.firstWhere((s) => s.sport == 'cycle');
    expect(ride.monthKm, 200);
    expect(ride.monthHours, 5);
    expect(ride.shareOfMonthlyGoal, isNull);
    expect(stats.map((s) => s.sport), ['swim', 'cycle', 'run']);
  });

  testWidgets('holding a month in the year view floats its stats', (t) async {
    final goals = YearGoalsSettings.forTesting()..runKm = 1200;
    await t.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: SingleChildScrollView(
            child: YearCalendarView(
              year: 2026,
              activitiesByDate: activities,
              onOpenMonth: (_) {},
              yearGoals: goals,
              today: () => DateTime(2026, 11, 20),
            ),
          ),
        ),
      ),
    );
    expect(find.byKey(const ValueKey('month-peek-run')), findsNothing);

    final gesture = await t.startGesture(
      t.getCenter(find.byKey(const ValueKey('year-month-2'))),
    );
    await t.pump(const Duration(milliseconds: 700));
    expect(find.text('February 2026'), findsOneWidget);
    expect(find.byKey(const ValueKey('month-peek-run')), findsOneWidget);
    expect(find.byKey(const ValueKey('month-peek-cycle')), findsOneWidget);
    expect(find.byKey(const ValueKey('month-peek-swim')), findsOneWidget);
    expect(find.text('60% of the monthly share (100 km)'), findsOneWidget);
    expect(
      find.text('By the end of February: 13% of the 1,200 km year goal'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('month-peek-chart-run')), findsOneWidget);
    // No goal for ride: no share, no chart.
    expect(find.byKey(const ValueKey('month-peek-chart-cycle')), findsNothing);

    await gesture.up();
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('month-peek-run')), findsNothing);
  });

  testWidgets('without goals the peek says how to get the comparison', (
    t,
  ) async {
    await t.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: MonthGoalsPeek(
            month: DateTime(2026, 5),
            activitiesByDate: activities,
            goals: YearGoalsSettings.forTesting(),
          ),
        ),
      ),
    );
    expect(find.text('No swim, ride or run this month.'), findsOneWidget);
    expect(
      find.text('Set year goals in Settings to compare against them.'),
      findsOneWidget,
    );
  });
}
