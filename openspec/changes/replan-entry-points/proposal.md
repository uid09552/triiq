# Proposal

## Why

"Change Training" — opening Train Now preselected on a session to find an
alternative — already exists, but only on two of the three screens that show
a planned session. Calendar's day detail and the full planned-workout detail
screen both offer it; the Plan screen's week grid does not, so tapping a
session there (including the current week's) opens a bottom sheet with no
way to replan it. On the Today screen, the replan option is one navigation
further away than it needs to be: the "Today's Training" card always opens
the full detail screen first, even for a TriIQ plan session, where the
quicker bottom sheet (as Calendar uses) would do.

## What Changes

- **Plan screen week grid**: tapping a session tile opens the same bottom
  sheet as today, now with a **Change Training** action that opens Train
  Now preselected on that session (as Calendar's day detail already does)
  — for any session in the grid, not only the current week.
- **Today screen's planned-training cards** ("Today's Training" and
  "Tomorrow's Training"): tapping a TriIQ plan session opens the bottom
  sheet directly, with **Change Training** right there, instead of first
  opening the full detail screen. A synced Intervals.icu event (not a TriIQ
  plan session) keeps opening the full detail screen, matching how Calendar
  already treats that case.
- No change to Train Now itself, or to Calendar's existing behavior.

## Capabilities

### Modified Capabilities
- `train-now`: adds where "Change Training" is reachable from — the Plan
  screen's week grid (new) and the Today screen's planned-training cards
  for TriIQ plan sessions (now direct, without the detail screen).

## Impact

- `lib/screens/plan/plan_session_sheet.dart`: `showPlanSessionSheetFor`
  (the `PlanSession` variant, used only by the Plan screen) gains the same
  `onChange` wiring `showPlanSessionSheetForEvent` already has, converting
  the session to a `LocalEvent` via `PlannedItemsRepository.toLocalEvent`.
- `lib/screens/today/today_screen.dart`: `_PlannedTraining`'s tap handler
  branches on `event.isPlanSession` — the sheet for a plan session, the
  existing full-screen navigation otherwise.
- No data model, sync, or Train Now screen changes; `openChangeTraining`
  and `TrainNowScreen` are reused as they are.
- docs/okf.md: note the Plan screen and Today entry points alongside the
  existing Calendar one.
