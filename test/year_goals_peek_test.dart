import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/settings/year_goals_progress.dart';
import 'package:triiq/screens/settings/year_goals_settings.dart';

class _NoActivities extends ActivitiesRepository {
  @override
  Future<List<Never>> getRange(String from, String to) async => const [];
}

void main() {
  testWidgets('holding the year goals line floats the details', (t) async {
    final settings = YearGoalsSettings.forTesting()
      ..swimKm = 50
      ..runKm = 500;
    await t.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: YearGoalsProgress(
              compact: true,
              settings: settings,
              activities: _NoActivities(),
              now: DateTime(2026, 7, 1),
            ),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('year-goal-swim')), findsNothing);

    final gesture = await t.startGesture(
      t.getCenter(find.byKey(const ValueKey('year-goals-line'))),
    );
    await t.pump(const Duration(milliseconds: 700));
    // Goal, distance so far and how far behind, for each goal.
    expect(find.byKey(const ValueKey('year-goal-swim')), findsOneWidget);
    expect(find.byKey(const ValueKey('year-goal-run')), findsOneWidget);
    expect(find.text('0 / 50 km'), findsOneWidget);
    expect(find.text('0 / 500 km'), findsOneWidget);
    expect(find.textContaining('behind'), findsWidgets);

    await gesture.up();
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('year-goal-swim')), findsNothing);
  });
}
