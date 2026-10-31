# Tasks

## 1. Apply path

- [x] 1.1 Add `updatePlannedWorkoutDate` to `PlannedWorkoutWriter`/`IntervalsWorkoutService` via `updateEvent` (date fields only); verify with a fake client test, and with the live suite when a key is available that the date changes and the steps survive
- [x] 1.2 Extend `PlanActions` (applyCurve, moveSession, removeSession; upstream first, local on success, resync, `PlanChanges`; `PlanChanges` and the screen listeners already exist); verify unit tests for success, upstream failure leaving local data unchanged, and past/completed sessions rejected
- [x] 1.3 Extract the generate → preview → Take as plan (→ Calendar, background send) flow from `PlanScreen` into a shared helper; verify existing plan-screen tests still pass

## 2. Proposals

- [x] 2.1 `PlanProposal` types, fingerprint, in-memory `PlanProposals` registry with apply/dismiss and states (pending, applied, dismissed, stale, failed); verify tests: apply after a goal edit is refused as stale, dismiss changes nothing
- [x] 2.2 `AgentProposal` event emitted by `TrainingAgent` when a tool result carries `proposal_id`; outcome queue prepended to the next user turn; verify agent-loop test with a fake model

## 3. Tools

- [x] 3.1 `get_training_plan` (goal, curve with phases and warnings, plan weeks, sessions with ids, actuals); verify tool tests for no goal, goal without plan, and active plan
- [x] 3.2 `propose_load_curve` (set_weeks, recovery_weeks, weeks, sport_mix, reset; errors on out-of-range values); verify "week 4 recovery" gives the bottom of its band and recovery phase, a TSS or 140% outside the band errors, TSS and percent both accepted, and the saved goal is unchanged
- [x] 3.3 `generate_training_plan` registers a `PlanDraftProposal`; verify the result has a `proposal_id` and the output stays backward compatible
- [x] 3.4 `propose_session_change` (move to date within plan, remove; future and not completed only); verify errors for past sessions, unknown ids and dates outside the plan
- [x] 3.5 System prompt rules for proposals; verify the prompt test or snapshot mentions that changes need the athlete's Apply

## 4. Chat UI

- [x] 4.1 `LoadCurveEditor` read-only mode with highlighted weeks; verify a widget test that drags do nothing and the controls are hidden
- [x] 4.2 `_ProposalCard` for curve, plan and session proposals with Apply/Dismiss and the state labels; applying a plan proposal opens the preview; verify widget tests: apply curve updates the saved goal, dismiss doesn't, stale shows the message, failure shows retry
- [ ] 4.3 en + de strings; verify `flutter analyze` is clean and a manual run on Android and Windows: ask for a recovery week, apply it, see the Plan screen update

## 5. Docs

- [x] 5.1 Update `docs/okf.md` (Chat and Training plan user docs, agent tools list, status matrix); verify they match the shipped tools and cards
