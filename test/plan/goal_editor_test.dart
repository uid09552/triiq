import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/plan/knowledge.dart';
import 'package:triiq/plan/plan_models.dart';
import 'package:triiq/screens/plan/goal_editor_screen.dart';

void main() {
  final knowledge = TrainingKnowledge.parse(
    File('docs/okf.md').readAsStringSync(),
  );

  Future<Goal? Function()> open(WidgetTester tester, Goal initial) async {
    tester.view.physicalSize = const Size(900, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Goal? popped;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              popped = await Navigator.of(context).push<Goal>(
                MaterialPageRoute(
                  builder: (_) =>
                      GoalEditorScreen(knowledge: knowledge, initial: initial),
                ),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return () => popped;
  }

  Future<void> save(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  const tri = Goal(
    targetType: 'long_distance',
    sport: Goal.triathlon,
    weekdays: {2, 4, 6, 7},
    weeklyHours: 10,
  );

  testWidgets('the session mix starts at the template; 95% blocks save', (
    tester,
  ) async {
    final popped = await open(tester, tri);

    expect(find.text('Z2: 30%'), findsOneWidget);
    expect(find.text('Long: 40%'), findsOneWidget);
    expect(find.text('Total 100%'), findsWidgets);

    final z2 = tester.widget<Slider>(
      find.byKey(const ValueKey('goal-slot-z2')),
    );
    z2.onChanged!(25);
    await tester.pump();
    expect(find.byKey(const ValueKey('goal-slots-total')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('goal-slots-total'))).data,
      'Total 95%',
    );

    await save(tester);
    expect(find.textContaining('adds up to 95%'), findsOneWidget);
    expect(popped(), isNull);
  });

  testWidgets('the long ride and long run need different days', (tester) async {
    final popped = await open(tester, tri);

    await tester.tap(find.byKey(const ValueKey('long-day-Ride-6')));
    await tester.tap(find.byKey(const ValueKey('long-day-Run-6')));
    await tester.pump();
    await save(tester);
    expect(find.textContaining('different days'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('long-day-Run-7')));
    await tester.tap(find.byKey(const ValueKey('interval-day-2')));
    await tester.pump();
    await save(tester);

    final goal = popped()!;
    expect(goal.longDays, {'Ride': 6, 'Run': 7});
    expect(goal.intervalDays, {2});
    expect(goal.slotShares, isNull, reason: 'template mix left untouched');
  });

  testWidgets('unticking a training day clears preferences on it', (
    tester,
  ) async {
    final popped = await open(
      tester,
      tri.copyWith(longDays: {'Ride': 6, 'Run': 7}, intervalDays: {2}),
    );

    // The Saturday training-day chip (first "Sat" is the day picker).
    await tester.tap(find.widgetWithText(FilterChip, 'Sat').first);
    await tester.pump();
    expect(find.byKey(const ValueKey('long-day-Ride-6')), findsNothing);

    await tester.tap(find.widgetWithText(FilterChip, 'Mon').first);
    await tester.pump();
    await save(tester);

    final goal = popped()!;
    expect(goal.weekdays, {1, 2, 4, 7});
    expect(goal.longDays, {'Run': 7});
    expect(goal.intervalDays, {2});
  });

  testWidgets('max sessions per day is stored', (tester) async {
    final popped = await open(tester, tri);

    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('per-day')),
        matching: find.text('1'),
      ),
    );
    await tester.pump();
    await save(tester);

    expect(popped()!.maxSessionsPerDay, 1);
  });
}
