# Tasks

## 1. Insights (pure)

- [ ] 1.1 `personalBests(raw)` parsing `icu_achievements` defensively into `BestEffort`s; verify unit tests for power, distance and unknown shapes, and add a live-suite check that logs a real payload (adjust the parser if it differs)
- [x] 1.2 `efficiencyTrend` (easy detection, same sport family, 42 days, ≥ 4 sessions, median and %); verify tests for improving, too-few and non-easy cases
- [x] 1.3 Knowledge rules `recoveryHours` / `recoveryFormPenaltyBelow` in `docs/okf.md` + `recoveryHint` with the tomorrow-conflict check; verify tests: 40 TSS → 12 h no conflict, 180 TSS at form −25 with hard tomorrow → 48 h + conflict

## 2. Seen tracking and trigger

- [x] 2.1 `SeenSessionsStore` (today-only set, persisted) and `NewTrainingInsights.unseenToday()`; verify tests: seen survives restart, yesterday excluded, date roll-over clears
- [x] 2.2 `AutoSyncService` open-sync completion signal, and `MainShell` showing the sheet only on the root route; verify widget tests: sheet after open-sync with an unseen session, not after periodic sync, not when the switch is off, not twice

## 3. UI

- [x] 3.1 New-training sheet (pages per session, dots, details, verdict/reasons/split, PBs, EF, recovery card, OK marks seen, Details opens the activity, Find alternative opens Train Now for tomorrow); verify widget tests for one and two sessions and that OK marks all as seen
- [x] 3.2 Insights card on `ActivityDetailScreen` (+ marks today's session seen); Train Now accepts a target date; verify widget tests and that Train Now for tomorrow loads tomorrow's planned session
- [ ] 3.3 Settings switch (Notifications section), en + de strings; verify `flutter analyze` clean and a manual check on Android and Windows

## 4. Docs

- [x] 4.1 Update `docs/okf.md` (app-open pop-up, Activities insights, knowledge recovery rules, status matrix); verify it matches the behaviour
