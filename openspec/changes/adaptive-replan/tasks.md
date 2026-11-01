# Tasks

## 1. Rules

- [x] 1.1 `lib/plan/plan_adaptation.dart`: missed-session detection (current plan week, before today, any activity of the same sport family), stable keys and the dismissed filter; verify unit tests for the skipped, wrong-sport and last-week scenarios
- [x] 1.2 Rescheduling rule (hard-day spacing, max per day, training days only, let-it-go fallback) and the Z2 let-it-go rule; verify unit tests for free day, no day fits and Z2 missed
- [x] 1.3 Week-load rule (under 80 % / over 120 %, factor clamp with a floor note, taper weeks excluded); verify unit tests for the sick-week (500/250 → 440) and on-target scenarios

## 2. Actions and proposals

- [x] 2.1 `PlanActions.swapSessions` with rollback of the first move when the second fails upstream; verify unit tests with a fake Intervals.icu API for success and second-step failure
- [x] 2.2 `SessionSwapProposal` plus its card, and "Let it go" wording for removal proposals; en + de; verify widget tests for both cards

## 3. Today

- [x] 3.1 `AdaptationService` (runs after auto-sync and on Today open, registers proposals, drops ones that no longer hold) and persisted dismissals in shared preferences; verify unit tests that a late-synced activity removes its suggestion and a dismissed key survives a reload
- [ ] 3.2 Suggestion cards on Today with Apply / Dismiss, progress and error states; en + de; verify widget tests and a manual run on Android (move a session that was sent to Intervals.icu) and Windows

## 4. Readiness trigger

- [x] 4.1 After `daily-readiness` has landed: readiness-conflict rule (swap with the next Z2, else reschedule) wired into `AdaptationService`; verify unit tests for the swap and readiness-unavailable scenarios (skip and leave unchecked if `daily-readiness` is not implemented yet)

## 5. Agent and docs

- [x] 5.1 `get_plan_adjustments` tool registering the same proposals as Today (shared keys, one Apply resolves both), plus a system-prompt line; verify tool tests and that the agent has no path to apply
- [x] 5.2 Update docs/okf.md (status matrix, Today and Training plan user docs, training agent, Known gaps); verify the sections match the shipped behaviour
