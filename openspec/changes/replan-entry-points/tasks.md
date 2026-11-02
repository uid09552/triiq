# Tasks

## 1. Plan screen week grid

- [x] 1.1 In `lib/screens/plan/plan_session_sheet.dart`, give `showPlanSessionSheetFor` the same `onChange: () => openChangeTraining(context, PlannedItemsRepository.toLocalEvent(s))` wiring `showPlanSessionSheetForEvent` already has (import `../../data/planned_items.dart`); verify `flutter analyze` is clean and the sheet opened from `plan_screen.dart`'s week grid shows the **Change Training** button for a session in the current week and in another week.
- [x] 1.2 Add a widget test (e.g. in `test/plan/plan_screen_test.dart`) that taps a session tile in the week grid, finds the `change-training` key button in the opened sheet, taps it, and verifies a `TrainNowScreen` is pushed with that session preselected; verify with `flutter test test/plan/plan_screen_test.dart`.

## 2. Today screen planned-training cards

- [x] 2.1 In `lib/screens/today/today_screen.dart`, change `_PlannedTraining`'s `onTap` to call `showPlanSessionSheetForEvent(context, event)` when `event.isPlanSession`, keeping the existing `Navigator.push(... PlannedWorkoutDetailScreen ...)` for every other event; verify `flutter analyze` is clean.
- [x] 2.2 Add a widget test for `TodayScreen` (or a focused test of `_PlannedTraining` if it's made testable) covering both branches: a TriIQ plan session opens the bottom sheet with **Change Training**, and a synced Intervals.icu event still opens `PlannedWorkoutDetailScreen`; verify with `flutter test` on the new/updated test file.

## 3. Docs

- [x] 3.1 Update docs/okf.md's Train Now section to list the Plan screen's week grid and Today's planned-training cards alongside Calendar's day detail as places **Change Training** is reachable from; verify by re-reading the updated section for accuracy.

## 4. Verification

- [x] 4.1 Run `flutter analyze` and `flutter test` for the full suite and verify both are clean.
