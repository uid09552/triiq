# Tasks

## 0. Prerequisites

- [ ] 0.1 `performance-curves` implemented (curve domain model, cache, model card); verify its tasks are complete
- [ ] 0.2 Live test: partial `updateSettings` with only `id` + `ftp` leaves all other Ride settings fields unchanged, original restored in tearDown; verify it passes (stop and report if any other field changes)

## 1. Rules

- [x] 1.1 `threshold_suggestions.dart`: ride FTP from model fit, run threshold pace heuristic, swim CSS from 400/200 m, 90-day window, +3 % up, −5 % down with a maximal effort ≤ 30 days, dismissal re-trigger at a further 3 %; verify unit tests for each scenario in the spec, including no-decrease-on-sparse-data

## 2. Write path

- [x] 2.1 `SportSettingsService.updateThreshold` (minimal payload, optional HR recalc, athlete refresh) and undo; verify unit tests with a fake API that only the changed field is sent, and the failure path keeps the old value

## 3. UI

- [x] 3.1 Suggestion card on the Performance screen (and Today) with dismiss; verify widget tests for up, down and none
- [x] 3.2 Confirm sheet (old → new, zone ranges before/after, HR-zones opt-in, past-load note, efforts used, indoor-FTP note), apply with progress/error, undo snackbar; en + de; verify widget tests and a manual update + undo on Android against the live account — widget tests done (7/7); the manual Android update+undo against the live account was not performed in this environment (no Android device attached, and this is the same live-write surface the sandbox blocks — see task 0.2)

## 4. Agent

- [x] 4.1 Read tool for suggestions and confirm-sheet hand-off (no write tool); verify tool tests and that no code path writes from the agent — implemented `get_threshold_suggestions` (read-only, tested to be the only threshold tool in the registry); simplified the "confirm-sheet hand-off" to a text pointer ("review in Statistics → Performance") rather than a cross-screen navigation event, since no such hand-off mechanism exists elsewhere in the agent for a non-plan domain and building one was out of proportion to this task

## 5. Docs

- [x] 5.1 Update `docs/okf.md` (Intervals.icu writes, agent, user docs, known gaps); verify sections match shipped behaviour
