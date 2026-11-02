# Tasks

## 1. Data and replace path

- [x] 1.1 `PlansRepository.replaceSessionContent` and `raw['triiq_plan_slot']` in `PlannedItemsRepository.toLocalEvent`; verify a repository test that content changes while week, date and plan stay the same
- [x] 1.2 `PlanActions.replaceSession` for plan sessions (local only / sent: create then delete, refuse when sent but offline or sending off) and Intervals.icu events (create then delete, report "both exist" on a delete failure), then resync + `PlanChanges` + `notifyCacheChanged`; verify unit tests with a fake writer for each branch, including upstream failure leaving local data unchanged

## 2. Train Now UI

- [x] 2.1 Load today's planned sessions (with test seams) and show `PlannedSessionCard`s (sport, name, duration, TSS, source/sent, collapsible steps, selection when more than one); verify widget tests for none, one plan session, and two sessions
- [x] 2.2 Adaptive button (Find alternative / Propose training) and presets from the selected session; verify widget tests for labels and presets (sport, duration, intensity) and that edits after preset stick
- [x] 2.3 Alternative prompt with the reference session first; verify a test on the built prompt text (reference included, steps truncated, duration repeated)
- [x] 2.4 Preview with Replace / Add choice (alternatives only), wired to `PlanActions.replaceSession` or the existing create; verify widget tests: replace updates the plan session, add leaves it, failure shows the message; en + de strings, `flutter analyze` clean

## 3. Docs

- [x] 3.1 Update `docs/okf.md` (Train Now user docs, status matrix row); verify it matches the behaviour
