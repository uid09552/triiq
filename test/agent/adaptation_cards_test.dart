import 'package:flutter/material.dart' hide Adaptation;
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/agent/plan_proposals.dart';
import 'package:triiq/client/intervalls/intervalls_client.dart';
import 'package:triiq/data/intervals_workout_service.dart';
import 'package:triiq/evaluation/readiness.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/plan/knowledge.dart';
import 'package:triiq/plan/plan_actions.dart';
import 'package:triiq/plan/plan_adaptation.dart';
import 'package:triiq/plan/plan_models.dart';
import 'package:triiq/screens/chat/proposal_card.dart';

class _NoWorkouts implements PlannedWorkoutWriter {
  @override
  Future<Event> createPlannedWorkout(PlannedWorkoutDraft draft) async =>
      Event(id: 1);

  @override
  Future<void> updatePlannedWorkoutDate(String eventId, DateTime date) async {}

  @override
  Future<void> deletePlannedWorkout(String eventId) async {}
}

/// Records what the card asked for instead of touching a database.
class _RecordingActions extends PlanActions {
  _RecordingActions() : super(workouts: _NoWorkouts());

  final calls = <String>[];

  @override
  Future<void> swapSessions(int a, int b) async => calls.add('swap $a $b');

  @override
  Future<void> removeSession(int sessionId, {bool missed = false}) async =>
      calls.add('remove $sessionId missed=$missed');

  @override
  Future<void> moveSession(
    int sessionId,
    DateTime date, {
    bool missed = false,
  }) async => calls.add('move $sessionId ${date.day} missed=$missed');
}

PlanSession _s(int id, DateTime date, SessionSlot slot) => PlanSession(
  id: id,
  weekIndex: 0,
  date: date,
  slot: slot,
  templateId: 't',
  name: slot == SessionSlot.z2 ? 'Z2 run' : 'Threshold intervals',
  sport: 'Run',
  minutes: 60,
  load: 60,
  lowMinutes: 40,
  description: '',
);

void main() {
  late PlanProposals proposals;
  late _RecordingActions actions;
  final dismissedKeys = <String>[];

  setUp(() {
    dismissedKeys.clear();
    proposals = PlanProposals(
      fingerprint: () async => 'v1',
      onKeyDismissed: dismissedKeys.add,
    );
    actions = _RecordingActions();
  });

  Future<void> pump(WidgetTester tester, PlanProposal proposal) =>
      tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: ProposalCard(
              proposal: proposal,
              proposals: proposals,
              actions: actions,
            ),
          ),
        ),
      );

  final tue = _s(1, DateTime(2026, 11, 3), SessionSlot.intervals);
  final wed = _s(2, DateTime(2026, 11, 4), SessionSlot.intervals);
  final thu = _s(3, DateTime(2026, 11, 5), SessionSlot.z2);

  testWidgets('swap card: both sessions, reason, applies the swap', (
    tester,
  ) async {
    final p = proposals.registerAdaptation(
      SessionSwapProposal(
        summary: 'swap',
        fingerprint: 'v1',
        first: wed,
        second: thu,
        adaptation: ReadinessConflict(
          wed,
          ReadinessLevel.backOff,
          swapWith: thu,
        ),
      ),
    );
    await pump(tester, p);

    expect(find.text('Swap two sessions'), findsOneWidget);
    expect(find.text('Readiness: Back off.'), findsOneWidget);
    expect(find.textContaining('Threshold intervals · Wed'), findsOneWidget);
    expect(find.textContaining('Z2 run · Thu'), findsOneWidget);

    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(actions.calls, ['swap 2 3']);
    expect(p.state, ProposalState.applied);
  });

  testWidgets('let-it-go card for a missed session removes it as missed', (
    tester,
  ) async {
    final p = proposals.registerAdaptation(
      SessionChangeProposal(
        summary: 'let go',
        fingerprint: 'v1',
        sessionId: 1,
        name: tue.name,
        sport: 'Run',
        from: tue.date,
        missed: true,
        adaptation: MissedSession(tue, null),
      ),
    );
    await pump(tester, p);

    expect(find.text('Let it go'), findsOneWidget);
    expect(find.textContaining('Missed on Tue'), findsOneWidget);

    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(actions.calls, ['remove 1 missed=true']);
  });

  testWidgets('catch-up card moves the missed session', (tester) async {
    final to = DateTime(2026, 11, 6);
    final p = proposals.registerAdaptation(
      SessionChangeProposal(
        summary: 'move',
        fingerprint: 'v1',
        sessionId: 1,
        name: tue.name,
        sport: 'Run',
        from: tue.date,
        to: to,
        missed: true,
        adaptation: MissedSession(tue, to),
      ),
    );
    await pump(tester, p);

    expect(find.text('Catch up a missed session'), findsOneWidget);
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(actions.calls, ['move 1 6 missed=true']);
  });

  testWidgets('the agent\'s own removal keeps "Remove a session"', (
    tester,
  ) async {
    final p = proposals.register(
      SessionChangeProposal(
        summary: 'remove Z2 run on Thu',
        fingerprint: 'v1',
        sessionId: 3,
        name: thu.name,
        sport: 'Run',
        from: thu.date,
      ),
    );
    await pump(tester, p);

    expect(find.text('Remove a session'), findsOneWidget);
    expect(find.text('remove Z2 run on Thu'), findsOneWidget);
  });

  testWidgets('dismissing an adaptation reports its key', (tester) async {
    final p = proposals.registerAdaptation(
      SessionChangeProposal(
        summary: 'let go',
        fingerprint: 'v1',
        sessionId: 1,
        name: tue.name,
        sport: 'Run',
        from: tue.date,
        missed: true,
        adaptation: MissedSession(tue, null),
      ),
    );
    await pump(tester, p);

    await tester.tap(find.text('Dismiss'));
    await tester.pump();
    expect(dismissedKeys, ['missed:1']);
  });

  test('registering the same situation twice returns one proposal', () {
    SessionChangeProposal make() => SessionChangeProposal(
      summary: 'let go',
      fingerprint: 'v1',
      sessionId: 1,
      name: tue.name,
      sport: 'Run',
      from: tue.date,
      missed: true,
      adaptation: MissedSession(tue, null),
    );
    final a = proposals.registerAdaptation(make());
    final b = proposals.registerAdaptation(make());

    expect(identical(a, b), isTrue);

    proposals.retireAdaptations({});
    expect(a.canApply, isFalse);
  });
}
