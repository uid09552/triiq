import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../data/repositories/plans_repository.dart';
import '../plan/load_curve.dart';
import '../plan/plan_adaptation.dart';
import '../plan/plan_models.dart';

/// Where a proposal is in its life. Only [pending] and [failed] can still
/// be applied.
enum ProposalState { pending, applying, applied, dismissed, stale, failed }

/// A change the agent suggested and the athlete has not (yet) applied.
/// Tools create these — the model never writes anything itself — and the
/// chat shows each as a card with Apply / Dismiss.
sealed class PlanProposal {
  PlanProposal({
    required this.summary,
    required this.fingerprint,
    this.adaptation,
  });

  late final String id;

  /// One line saying what the proposal changes, for the card and for the
  /// note the agent gets about what the athlete did with it.
  final String summary;

  /// The goal-and-plan state the proposal was made from ([PlanProposals]
  /// refuses to apply it once that has changed).
  final String fingerprint;

  /// The plan drift this proposal answers, when it came from the
  /// adaptation rules rather than the agent's own idea.
  final Adaptation? adaptation;

  /// Shared by every proposal for the same situation (see [Adaptation.key]).
  String? get key => adaptation?.key;

  ProposalState state = ProposalState.pending;

  /// Why the last apply failed, or why it was refused.
  String? error;

  bool get canApply =>
      state == ProposalState.pending || state == ProposalState.failed;
}

/// A reshaped load graph, length or sport mix: [goal] is the saved goal
/// with the edit made.
class CurveProposal extends PlanProposal {
  CurveProposal({
    required super.summary,
    required super.fingerprint,
    required this.goal,
    required this.limits,
    required this.weeks,
    required this.changedWeeks,
    super.adaptation,
  });

  final Goal goal;

  /// What the mini graph on the card is drawn within.
  final CurveLimits limits;
  final int weeks;

  /// 0-based weeks whose load the proposal changes.
  final Set<int> changedWeeks;
}

/// A plan to generate from [goal] — applying it opens the plan preview.
class PlanDraftProposal extends PlanProposal {
  PlanDraftProposal({
    required super.summary,
    required super.fingerprint,
    required this.goal,
    this.limits,
    this.weeks,
  });

  final Goal goal;
  final CurveLimits? limits;
  final int? weeks;
}

/// Move a plan session to [to], or take it out of the plan when [to] is
/// null.
class SessionChangeProposal extends PlanProposal {
  SessionChangeProposal({
    required super.summary,
    required super.fingerprint,
    required this.sessionId,
    required this.name,
    required this.sport,
    required this.from,
    this.to,
    this.missed = false,
    super.adaptation,
  });

  final int sessionId;
  final String name;
  final String sport;
  final DateTime from;
  final DateTime? to;

  /// A past session nothing was done for: the one past session that may
  /// still be moved or let go.
  final bool missed;

  bool get isRemoval => to == null;
}

/// Swap the dates of two plan sessions, e.g. today's intervals with
/// tomorrow's Z2 on a low-readiness day.
class SessionSwapProposal extends PlanProposal {
  SessionSwapProposal({
    required super.summary,
    required super.fingerprint,
    required this.first,
    required this.second,
    super.adaptation,
  });

  final PlanSession first;
  final PlanSession second;
}

/// What the athlete did with a proposal, for the agent's next turn.
class ProposalOutcome {
  const ProposalOutcome(this.id, this.summary, this.state, [this.detail]);

  final String id;
  final String summary;
  final ProposalState state;
  final String? detail;

  String describe() {
    final what = switch (state) {
      ProposalState.applied => 'was applied by the athlete',
      ProposalState.dismissed => 'was dismissed by the athlete',
      ProposalState.stale =>
        'could not be applied: the goal or plan changed after it was made',
      ProposalState.failed =>
        'failed to apply${detail == null ? '' : ': $detail'}',
      ProposalState.pending || ProposalState.applying => 'is still pending',
    };
    return 'Proposal $id ($summary) $what.';
  }
}

/// The proposals of this app run, by id. Shared by the agent's tools (which
/// register them) and the chat (which applies or dismisses them); kept in
/// memory only — a restart drops them, and the agent is told nothing was
/// applied.
class PlanProposals extends ChangeNotifier {
  PlanProposals({Future<String> Function()? fingerprint, this.onKeyDismissed})
    : _fingerprint = fingerprint ?? defaultFingerprint;

  /// Told the key of every dismissed adaptation proposal, so the dismissal
  /// outlives the app run (`AdaptationService` wires it up).
  void Function(String key)? onKeyDismissed;

  static final PlanProposals instance = PlanProposals();

  final Future<String> Function() _fingerprint;
  final Map<String, PlanProposal> _byId = {};
  final List<ProposalOutcome> _outcomes = [];
  int _next = 0;

  /// The current goal-and-plan state, as proposals record it.
  Future<String> fingerprint() => _fingerprint();

  T register<T extends PlanProposal>(T proposal) {
    proposal.id = 'p${++_next}';
    _byId[proposal.id] = proposal;
    notifyListeners();
    return proposal;
  }

  PlanProposal? operator [](String id) => _byId[id];

  /// The live proposal for adaptation [key], if any.
  PlanProposal? byKey(String key) {
    for (final p in _byId.values) {
      if (p.key == key && (p.canApply || p.state == ProposalState.applying)) {
        return p;
      }
    }
    return null;
  }

  /// Registers an adaptation proposal unless one for the same key and
  /// plan state is already live — then that one is returned, so Today and
  /// the chat show the same card. A live one made from an older plan state
  /// is retired in favour of [proposal].
  T registerAdaptation<T extends PlanProposal>(T proposal) {
    final key = proposal.key!;
    final existing = byKey(key);
    if (existing is T && existing.fingerprint == proposal.fingerprint) {
      return existing;
    }
    if (existing != null && existing.state != ProposalState.applying) {
      existing.state = ProposalState.stale;
    }
    return register(proposal);
  }

  /// Retires live adaptation proposals whose situation is gone (their key
  /// is not in [live]) — quietly: nothing was refused, it just no longer
  /// applies.
  void retireAdaptations(Set<String> live) {
    var changed = false;
    for (final p in _byId.values) {
      final key = p.key;
      if (key != null && p.canApply && !live.contains(key)) {
        p.state = ProposalState.stale;
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  /// Applies [id] with [run], unless the goal or plan changed since it was
  /// made (then it turns [ProposalState.stale]). [run] does the actual
  /// change; return `false` from it when the athlete backed out (e.g.
  /// cancelled the plan preview) to leave the proposal pending.
  Future<ProposalState> apply(
    String id,
    Future<bool> Function(PlanProposal proposal) run,
  ) async {
    final p = _byId[id];
    if (p == null || !p.canApply) return p?.state ?? ProposalState.stale;
    if (await _fingerprint() != p.fingerprint) {
      return _finish(p, ProposalState.stale);
    }
    p.state = ProposalState.applying;
    p.error = null;
    notifyListeners();
    try {
      final done = await run(p);
      if (!done) {
        p.state = ProposalState.pending;
        notifyListeners();
        return p.state;
      }
      return _finish(p, ProposalState.applied);
    } catch (error) {
      p.error = '$error';
      return _finish(p, ProposalState.failed, '$error');
    }
  }

  void dismiss(String id) {
    final p = _byId[id];
    if (p == null || !p.canApply) return;
    final key = p.key;
    if (key != null) onKeyDismissed?.call(key);
    _finish(p, ProposalState.dismissed);
  }

  ProposalState _finish(PlanProposal p, ProposalState state, [String? detail]) {
    p.state = state;
    _outcomes.add(ProposalOutcome(p.id, p.summary, state, detail));
    notifyListeners();
    return state;
  }

  /// Outcomes not yet reported to the agent, oldest first; clears them.
  List<ProposalOutcome> takeOutcomes() {
    final taken = List.of(_outcomes);
    _outcomes.clear();
    return taken;
  }

  @visibleForTesting
  void debugClear() {
    _byId.clear();
    _outcomes.clear();
  }

  /// The saved goal (incl. its load graph) plus the current plan's sessions
  /// with their dates and status — anything a proposal could be out of date
  /// against.
  static Future<String> defaultFingerprint({
    GoalStore? goals,
    PlansRepository? plans,
  }) async {
    final goal = await (goals ?? GoalStore()).load();
    final plan = await (plans ?? PlansRepository()).getCurrent();
    return jsonEncode({
      'goal': goal?.toJson(),
      'plan': plan?.id,
      'sessions': [
        for (final s in plan?.sessions ?? const <PlanSession>[])
          [s.id, s.date.toIso8601String(), s.status.name, s.intervalsEventId],
      ],
    });
  }
}
