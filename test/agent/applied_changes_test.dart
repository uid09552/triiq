import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/agent/plan_proposals.dart';
import 'package:triiq/client/intervalls/intervalls_client.dart';
import 'package:triiq/data/intervals_workout_service.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/plan/plan_actions.dart';
import 'package:triiq/screens/plan/applied_changes_screen.dart';

class _NoWorkouts implements PlannedWorkoutWriter {
  @override
  Future<Event> createPlannedWorkout(PlannedWorkoutDraft draft) async =>
      Event(id: 1);
  @override
  Future<void> updatePlannedWorkoutDate(String eventId, DateTime date) async {}
  @override
  Future<void> deletePlannedWorkout(String eventId) async {}
}

class _Actions extends PlanActions {
  _Actions() : super(workouts: _NoWorkouts());
  final calls = <String>[];
  @override
  Future<void> moveSession(
    int sessionId,
    DateTime date, {
    bool missed = false,
  }) async => calls.add('move $sessionId ${date.day}');
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  SessionChangeProposal move() => SessionChangeProposal(
    summary: 'move Z2 run to Fri',
    fingerprint: 'v1',
    sessionId: 7,
    name: 'Z2 run',
    sport: 'Run',
    from: DateTime(2026, 11, 3),
    to: DateTime(2026, 11, 6),
  );

  test('an applied change is logged and survives a reload', () async {
    final log = AppliedChangesLog(clock: () => DateTime(2026, 11, 4, 9));
    var fp = 'v1';
    final proposals = PlanProposals(fingerprint: () async => fp)..log = log;
    final p = proposals.register(move());
    await proposals.apply(p.id, (_) async {
      fp = 'v2';
      return true;
    });
    expect(log.entries.single.summary, 'move Z2 run to Fri');
    expect(log.entries.single.revertible, isTrue);

    final again = AppliedChangesLog();
    await Future<void>.delayed(Duration.zero);
    await again.load();
    expect(again.entries.single.proposal['appliedFingerprint'], 'v2');
  });

  testWidgets('Revert in Plan → Changes moves the session back', (t) async {
    final log = AppliedChangesLog(clock: () => DateTime(2026, 11, 4, 9));
    var fp = 'v1';
    final proposals = PlanProposals(fingerprint: () async => fp)..log = log;
    final p = proposals.register(move());
    await t.runAsync(
      () => proposals.apply(p.id, (_) async {
        fp = 'v2';
        return true;
      }),
    );
    final actions = _Actions();
    await t.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: AppliedChangesScreen(
          log: log,
          proposals: PlanProposals(fingerprint: () async => fp)..log = log,
          actions: actions,
        ),
      ),
    );
    expect(find.text('move Z2 run to Fri'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('change-revert-0')));
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await t.pumpAndSettle();
    expect(actions.calls, ['move 7 3']);
    expect(log.entries.single.undone, isTrue);
    expect(find.byKey(const ValueKey('change-revert-0')), findsNothing);
  });

  testWidgets('Revert is refused once the plan changed since', (t) async {
    final log = AppliedChangesLog();
    var fp = 'v1';
    final proposals = PlanProposals(fingerprint: () async => fp)..log = log;
    final p = proposals.register(move());
    await t.runAsync(
      () => proposals.apply(p.id, (_) async {
        fp = 'v2';
        return true;
      }),
    );
    fp = 'v3';
    final actions = _Actions();
    await t.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: AppliedChangesScreen(
            log: log,
            proposals: PlanProposals(fingerprint: () async => fp),
            actions: actions,
          ),
        ),
      ),
    );
    await t.tap(find.byKey(const ValueKey('change-revert-0')));
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await t.pumpAndSettle();
    expect(actions.calls, isEmpty);
    expect(find.textContaining("Can't revert"), findsOneWidget);
  });
}
