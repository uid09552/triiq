# Design

## Context

The agent (`lib/agent/training_agent.dart`) runs a hand-written tool loop and emits `AgentTextDelta` / `AgentToolStarted` / `AgentToolFinished`. `ChatScreen` renders those events. Every tool in `TrainingDataTools` is read-only, and the system prompt says the agent writes nothing. The plan side exists: `GoalStore` (goal + `loadFactors`), `PlanEngine.limitsFor/generate`, the pure `load_curve.dart` (`proposeCurve`, `flagWeeks`, `phasesFor`, `snapFactor`), `PlanService`, `PlansRepository`, `PlanWriter` (create/delete) and `PlanPreviewSheet`. The generated client has `updateEvent`, but `PlannedWorkoutWriter` exposes only create and delete. See proposal.md for motivation.

## Goals / Non-Goals

**Goals:**
- The agent reads and proposes. The athlete applies. One code path applies a change, whether it starts from chat or from the Plan screen.
- Proposal numbers come from the same engine functions the UI uses.
- A proposal can't overwrite newer changes.

**Non-Goals:**
- Agent edits without confirmation; batch "apply all"; persisting proposals across app restarts.
- Editing a session's content (steps, duration). Only date moves and removals.
- Moving sessions outside the plan's date range.

## Decisions

1. **Proposals are data returned by tools, registered in memory.** The new `PlanProposals` registry (`lib/agent/plan_proposals.dart`) stores sealed `PlanProposal` values (`CurveProposal`, `PlanDraftProposal`, `SessionChangeProposal`) by id. The tool result includes `proposal_id` and a summary for the model. The agent loop emits a new `AgentProposal(proposal)` event after the tool finishes, and the chat renders it. Rejected alternative: having the model emit a special JSON block in its reply. Small Ollama models format it unreliably, and it would be unverifiable.
2. **Staleness by fingerprint.** Each proposal stores `baseFingerprint`, a hash of the goal JSON (incl. `loadFactors`) plus current plan id and session dates/statuses. Apply recomputes it and refuses on mismatch. Cheap, and covers edits from either screen.
3. **Apply path = `PlanActions`** (exists since `train-now-today-plan`, `lib/plan/plan_actions.dart`; extended here):
   - `applyCurve(goal edits)`: validate via `Goal.validate`, save via `GoalStore`, then notify.
   - `moveSession(id, date)`: `PlannedWorkoutWriter.updatePlannedWorkoutDate` (new, wraps `updateEvent` with only `start_date_local`), then the repo `updateSession`, then the existing resync (`PlanWriter._resyncAndNotify`).
   - `removeSession(id)`: delete upstream, then the repo `deleteSession`, then resync.
   Upstream runs first. On failure, local data is untouched and the card offers retry (spec'd). A move or removal of a session that is in Intervals.icu while offline or with sending off is refused (`ReplaceRefusedException`), as for Train Now. The Plan screen's own edits keep their direct path. `PlanChanges` (already exists, from `plan-to-calendar`) is pinged by every path; Plan, Calendar, Today and Statistics already listen to it.
4. **Graph edits as operations, not raw factor lists.** `propose_load_curve` args: `set_weeks: [{week, tss} | {week, percent}]`, `recovery_weeks: [n]` (→ bottom of the week's band), `weeks`, `sport_mix`, `reset`. They are applied in that order on top of the saved factors through a `LoadCurveController` (same TSS band and 5-TSS snapping as the graph, since `plan-to-calendar`). Values outside the band are an error, not a silent clamp, so the model learns. A recovery request that would not register as recovery (when the previous week is also low) is still applied, and the result shows the phase the engine computes. The tool reports, it doesn't guess.
5. **Plan proposal hands off to the preview.** `generate_training_plan` keeps its output. It also registers a `PlanDraftProposal` holding the goal (with any `load_factors` arguments) and its fingerprint. Apply re-runs `PlanService.generate` and opens `PlanPreviewSheet` from the chat via the root navigator, then follows the Plan screen's **Take as plan** flow (`PlanService.take`, Calendar opened via `MainNavigation`, background `send` when enabled). This logic is extracted from `_PlanScreenState._generate` into a shared helper so both callers share it.
6. **Cards.** The new `_ProposalCard` in chat: title, summary lines from the proposal, `LoadCurveEditor(readOnly: true)` for curve/plan proposals with changed weeks highlighted (new `highlight` set), a before→after row for sessions, and Apply/Dismiss. States: pending, applying, applied, dismissed, stale, failed(retry). The read-only editor ignores gestures and hides controls.
7. **Outcome feedback.** `TrainingAgent` keeps a queue of outcomes. On the next `send`, it prepends a short system-style note ("Proposal p3 (week 4 → 80%) was applied.") to the user turn. The system prompt gains rules: propose rather than claim, refer to proposals by what they change, and say the athlete must tap Apply.
8. **`get_training_plan`** reuses `PlanService.curve` and `PlansRepository.getCurrent` + `actualLoads`, and returns session ids so the agent can reference them in `propose_session_change`.

## Risks / Trade-offs

- [The model applies changes to the wrong week through off-by-one numbering] → tools use 1-based `week` everywhere, echo the week's start date, and the card shows dates, so the athlete sees what will change.
- [In-memory proposals vanish on restart] → acceptable. Cards for unknown ids show "expired" if chat history is ever persisted.
- [`updateEvent` partial-update semantics unverified] → send only the date fields, and cover it with the live suite (`--dart-define=INTERVALS_API_KEY`) before relying on it. Fallback is delete + recreate with the same tag.
- [Preview opened from chat while the Plan screen is also open] → both read from the repo after confirm, and the `PlanChanges` notifier reloads the Plan screen.
- [Prompt injection via activity names steering the agent to propose removals] → every change needs a tap, and session cards show exactly which session and date.

## Migration Plan

No data migration. Proposals are transient. Rollback: remove the new tools and the cards. Saved goals and plans stay valid.

## Open Questions

- Whether to also let the athlete type a reply like "yes" to apply the last proposal. Not in scope; tapping Apply is the only path.
