# Tasks

## 1. Load graph in TSS

- [x] 1.1 Controller: per-week TSS band, 5-TSS snapping, `dragTss`/`stepTss`, `_fit` clamps instead of 5% snap; verify unit tests: 360 TSS on a 439 proposal, clamp at band top, 363 + 25 → 390, stored factors keep their share after a baseline change
- [x] 1.2 Editor: TSS axis with nice ticks, per-week bands, dashed proposal line, TSS drag mapping, label `TSS · %`, ±5 TSS buttons, arrow ±5 / Shift ±25, semantics in TSS; update en/de strings; verify updated widget tests (relative drag +60 TSS → 460 — a 20-TSS drag is below the touch slop, clamp, scroll, keys, undo, semantics)

## 2. Settings and sync

- [x] 2.1 `SyncSettings.sendPlanToIntervals` / `copyIntervalsEvents` (persisted, default on) + static `readCopyIntervalsEvents`; `SyncService` skips events when off; verify tests: defaults, persistence, no events request when off
- [x] 2.2 Settings → Calendar section with both switches; copy on → sync current month; send on with unsent future sessions → confirm dialog → send only those; verify widget tests for both switches

## 3. Merged planned items

- [x] 3.1 `PlannedItemsRepository` (plan sessions as `LocalEvent`, de-dup by `intervals_event_id`, events only when copying on) and `LocalEvent.isPlanSession`; verify tests: no duplicate when sent, local-only session present, events hidden when copy off but still in the table
- [x] 3.2 Switch Calendar, Today (+ TSS history, weekly load), Statistics and the agent's `get_planned_workouts` reads to it; verify the existing tests still pass and Today counts a local-only session in the week's planned TSS

## 4. Take as plan and Calendar

- [x] 4.1 `PlanChanges` notifier, `MainNavigation` (tab + calendar focus) wired into `MainShell` and `CalendarScreen`; screens listen to `PlanChanges`; verify a widget test where `openCalendar(date)` selects the Calendar tab and focuses the date
- [x] 4.2 `PlanService.take`/`send`, the preview button labelled **Take as plan**, and the Plan screen flow (save → pop to root → Calendar at week 1 → background send when enabled, result snackbar with retry); verify plan-screen tests: cancel saves nothing, take with send off creates no events, take with send on creates them, sessions visible in the Calendar
- [x] 4.3 Calendar day detail: plan-session badge + sent icon, tap opens the shared session sheet with steps and status; verify a widget test

## 5. Docs

- [x] 5.1 Update `docs/okf.md` (load graph in TSS, Take as plan, Settings → Calendar, merged planned items, status matrix); verify it matches the behaviour
