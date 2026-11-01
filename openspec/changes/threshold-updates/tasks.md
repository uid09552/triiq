# Tasks

## 0. Prerequisites

- [ ] 0.1 `performance-curves` implemented (curve domain model, cache, model card); verify its tasks are complete
- [ ] 0.2 Live test: partial `updateSettings` with only `id` + `ftp` leaves all other Ride settings fields unchanged, original restored in tearDown; verify it passes (stop and report if any other field changes)

## 1. Rules

- [ ] 1.1 `threshold_suggestions.dart`: ride FTP from model fit, run threshold pace heuristic, swim CSS from 400/200 m, 90-day window, +3 % up, −5 % down with a maximal effort ≤ 30 days, dismissal re-trigger at a further 3 %; verify unit tests for each scenario in the spec, including no-decrease-on-sparse-data

## 2. Write path

- [ ] 2.1 `SportSettingsService.updateThreshold` (minimal payload, optional HR recalc, athlete refresh) and undo; verify unit tests with a fake API that only the changed field is sent, and the failure path keeps the old value

## 3. UI

- [ ] 3.1 Suggestion card on the Performance screen (and Today) with dismiss; verify widget tests for up, down and none
- [ ] 3.2 Confirm sheet (old → new, zone ranges before/after, HR-zones opt-in, past-load note, efforts used, indoor-FTP note), apply with progress/error, undo snackbar; en + de; verify widget tests and a manual update + undo on Android against the live account

## 4. Agent

- [ ] 4.1 Read tool for suggestions and confirm-sheet hand-off (no write tool); verify tool tests and that no code path writes from the agent

## 5. Docs

- [ ] 5.1 Update `docs/okf.md` (Intervals.icu writes, agent, user docs, known gaps); verify sections match shipped behaviour
