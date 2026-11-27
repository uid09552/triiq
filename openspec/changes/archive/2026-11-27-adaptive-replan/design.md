# Design

## Context

- `PlanSession` stores `date`, `slot` (`z2`/`intervals`/`long`/recovery), `sport`, `load`, and `intervalsEventId` once it has been sent to Intervals.icu. A plan's weeks have targets, and the Plan screen already compares them with actual load.
- `session_evaluator.dart` has `sportFamily` and `matchPlanned`/`matchAll`, which match *Intervals.icu events* to activities by day and sport family.
- `PlanActions.moveSession` / `removeSession` handle the upstream event (delete and recreate, re-sync) and ping `PlanChanges`.
- `PlanProposals` (in memory) holds `CurveProposal`, `PlanDraftProposal` and `SessionChangeProposal` from chat tools, refuses stale ones via a goal/plan fingerprint, and reports outcomes back to the agent.
- `Goal.loadFactors` (0.8-1.2 per week) is how a week's load is changed, and applying a `CurveProposal` rewrites the goal and regenerates the plan's remaining weeks.

## Goals / Non-Goals

**Goals:** deterministic, testable rules; one path for applying changes (Today and chat); nothing written without Apply.

**Non-Goals:** editing a session's content or duration (sessions are still only moved or removed, see the Known gaps); re-generating the whole plan; adapting from session *quality* (too hard / cut short) beyond the week-load check; acting on weeks before the current one; notifications for suggestions.

## Decisions

1. **Pure rules module.** `List<Adaptation> adapt(TrainingPlan plan, Goal goal, List<LocalActivity> activities, Readiness? readiness, DateTime today, Set<String> dismissed)` in `lib/plan/plan_adaptation.dart`. Each `Adaptation` has a stable `key` (`missed:<sessionId>`, `load:<weekIndex>`, `readiness:<date>:<sessionId>`) for dismissal and dedup. No I/O, so every spec scenario is a unit test.

2. **Plan-session matching** reuses `sportFamily`. A plan session counts as done when *any* activity of its family is on its date. This is deliberately looser than the one-to-one `matchAll`: two plan sessions of the same sport on one day are rare (max 2 per day, and mostly different sports in triathlon), and a false "missed" is worse than a missed miss.

3. **Hard-day spacing** uses the plan's own slots: a day is hard when it has an `intervals` or `long` session. A candidate day must have no hard session the day before or after (within the plan) and must be below `goal.effectiveMaxPerDay`. Days outside `goal.weekdays` are never candidates.

4. **Week-load suggestion is a `CurveProposal`.** The new factor is `clamp((actual × (1 + rampCap)) / proposal[next], 0.8, 1.2)` for an under-target week, or `target[next] / proposal[next]` (holding its current factor, cancelling any upward drag) for an over-target week. That reuses the existing apply path, the mini graph on the card and the fingerprint staleness check. A taper week (from `race-taper`) is never the target of a load suggestion.

5. **New `SessionSwapProposal`** in `plan_proposals.dart`, applied by a new `PlanActions.swapSessions(a, b)`: move A to B's date, then B to A's date. If the second step fails, A is moved back and the error surfaces. *Alternative:* two separate move cards. Rejected: applying one and dismissing the other leaves two hard days in a row.

6. **"Let it go"** is a `SessionChangeProposal` with `to == null` (removal). It is worded "Let it go" on the card so it doesn't read as deleting training history. Completed activities are never touched. *Decided during apply:* removal really deletes the session from the plan and Intervals.icu. That lowers the week's planned load.

6a. **Missed sessions are the one past edit allowed.** `PlanActions` refuses any change to a session dated before today. `moveSession` / `removeSession` take `missed: true`, which lets a past session through only when no activity of its sport family is on its date, the session is in the current plan week, and a move lands later in that same week. Every other past edit is still refused.

6b. **Over-target "hold"** caps the next week at the over-target week's own target load: factor = `min(currentFactor, target[this] / proposal[next])`, floored at 0.8. When that is not below the current factor, there is no suggestion. Applying a load suggestion saves the goal's load graph like a chat curve proposal. The week's sessions change when the plan is regenerated, and the card says so.

7. **Today cards reuse the chat proposal cards.** `PlanProposals` gets a non-chat source: `AdaptationService` runs `adapt` after `AutoSyncService` finishes and on Today open, registers the proposals and drops ones whose key no longer appears (the "situation no longer holds" rule). Outcomes from Today are not fed to the agent's next turn, because that turn didn't make them.

8. **Dismissals persist** as a set of keys in shared preferences, pruned to keys from the current plan. Applied suggestions don't need storing: once applied, the situation is gone (the session moved, or the factor changed).

9. **Agent tool** `get_plan_adjustments` returns the current adaptations and registers them as chat proposals, so a chat card and a Today card for the same key are the same proposal object (one Apply resolves both).

## Risks / Trade-offs

- [Activity syncs late, e.g. a watch uploads in the evening] → suggestions vanish automatically when the activity arrives. Missed-session detection only looks at days before today, never today.
- [Moving sessions that are already in Intervals.icu means delete + recreate] → existing `moveSession` behaviour, already covered by its tests. A swap adds the rollback.
- [Readiness trigger depends on `daily-readiness`] → `readiness` is nullable, and task 4.1 runs only after that change has landed. The other triggers don't wait for it.
- [Too many cards] → at most one card per key, and cards only for the current week and the week just ended.
