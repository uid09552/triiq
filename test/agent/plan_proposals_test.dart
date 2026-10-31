import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/agent/plan_proposals.dart';

void main() {
  late String state;
  late PlanProposals proposals;

  setUp(() {
    state = 'v1';
    proposals = PlanProposals(fingerprint: () async => state);
  });

  SessionChangeProposal move() => SessionChangeProposal(
    summary: 'move Long endurance to Sun 8 Nov',
    fingerprint: state,
    sessionId: 3,
    name: 'Long endurance',
    sport: 'Ride',
    from: DateTime(2026, 11, 7),
    to: DateTime(2026, 11, 8),
  );

  test('ids are unique and look-up works', () {
    final a = proposals.register(move());
    final b = proposals.register(move());

    expect(a.id, isNot(b.id));
    expect(proposals[a.id], same(a));
  });

  test('apply runs the change and records the outcome once', () async {
    final p = proposals.register(move());
    var runs = 0;

    final result = await proposals.apply(p.id, (_) async {
      runs++;
      return true;
    });

    expect(result, ProposalState.applied);
    expect(runs, 1);
    expect(p.canApply, isFalse);
    final outcomes = proposals.takeOutcomes();
    expect(outcomes.single.state, ProposalState.applied);
    expect(outcomes.single.describe(), contains('was applied'));
    expect(proposals.takeOutcomes(), isEmpty);

    await proposals.apply(p.id, (_) async => true);
    expect(runs, 1, reason: 'an applied proposal is not applied again');
  });

  test('a change made after the proposal makes it stale', () async {
    final p = proposals.register(move());
    state = 'v2';
    var ran = false;

    final result = await proposals.apply(p.id, (_) async => ran = true);

    expect(result, ProposalState.stale);
    expect(ran, isFalse);
    expect(proposals.takeOutcomes().single.describe(), contains('changed'));
  });

  test('dismiss changes nothing and is reported', () async {
    final p = proposals.register(move());
    var ran = false;

    proposals.dismiss(p.id);
    await proposals.apply(p.id, (_) async => ran = true);

    expect(p.state, ProposalState.dismissed);
    expect(ran, isFalse);
    expect(proposals.takeOutcomes().single.state, ProposalState.dismissed);
  });

  test('a failed apply can be retried', () async {
    final p = proposals.register(move());

    final first = await proposals.apply(
      p.id,
      (_) async => throw StateError('offline'),
    );
    expect(first, ProposalState.failed);
    expect(p.error, contains('offline'));
    expect(p.canApply, isTrue);

    final second = await proposals.apply(p.id, (_) async => true);
    expect(second, ProposalState.applied);
  });

  test('backing out of the apply leaves it pending', () async {
    final p = proposals.register(move());

    final result = await proposals.apply(p.id, (_) async => false);

    expect(result, ProposalState.pending);
    expect(proposals.takeOutcomes(), isEmpty);
  });
}
