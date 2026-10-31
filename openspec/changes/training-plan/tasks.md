# Tasks

## 1. Training knowledge in okf.md

- [x] 1.1 Add a "Training knowledge" section to `docs/okf.md` with `okf-template`/rules blocks (week multipliers, 80/20 tolerance, long-distance and one other goal's templates); verify the section renders and blocks are valid YAML
- [x] 1.2 Register `docs/okf.md` as an asset in `pubspec.yaml`; verify `flutter analyze` is clean and the asset loads in a test
- [x] 1.3 Implement `KnowledgeRepository` parsing only fenced knowledge blocks with defaults fallback; verify unit tests for valid, missing-template and malformed-block cases

## 2. Plan engine

- [x] 2.1 Add `Goal`, `PlanWeek`, `PlanSession` models and goal persistence (SharedPreferences); verify round-trip test
- [x] 2.2 Implement `PlanEngine` (baseline from cached weekly load, multipliers, ramp cap, session slots on available days); verify tests: 4 weeks, recovery < others, cap applied, too-little-history returns a "need baseline" result
- [x] 2.3 Implement 80/20 split calculation and tolerance flag; verify tests for within, outside and insufficient-zone-data cases
- [x] 2.4 SQLite schema v3 with `plans`/`plan_sessions` and repository; verify v2→v3 upgrade test keeps existing data

## 3. Intervals.icu write path

- [x] 3.1 Generalise `IntervalsWorkoutService.createWorkout` to take a date and plan tag; verify existing Train-now flow still passes its tests
- [x] 3.2 Add bulk create with per-session result and delete-by-plan (future, not completed only); verify against a fake client plus, if a key is available, the live suite
- [ ] 3.3 Re-sync affected range and `notifyCacheChanged()` after write; verify new sessions appear in Calendar without restart

## 4. Agent integration

- [ ] 4.1 Add `generate_training_plan` and `get_session_template` tools to `training_data_tools.dart`; verify tool-output tests and that bad arguments return an `error` string
- [ ] 4.2 Add a session-detail prompt that fills slot steps in Intervals.icu syntax, reusing `parseWorkoutDraft`; verify parser tests for fenced and prose-wrapped replies

## 5. Plan UI

- [ ] 5.1 Goal editor and Plan screen (timeline, current week highlight, target vs actual, split) under More → Training plan, en + de strings; verify widget test and manual check in light/dark
- [ ] 5.2 Multi-session preview sheet with per-session date change, confirm/cancel; verify cancel writes nothing (test)
- [ ] 5.3 Regenerate/remove actions with confirmation; verify completed activities are untouched (test)

## 6. Calendar export

- [ ] 6.1 Add device-calendar plugin and Android permissions; verify `flutter build apk --debug` succeeds (stop and report if it does not)
- [ ] 6.2 Implement calendar picker, write/update/remove events with stored `calendar_event_id`, plain-text descriptions; verify on an Android device that no duplicate appears on re-export
- [ ] 6.3 Keep the Google Calendar link as non-Android fallback; verify `markdownToPlainText` tests cover descriptions

## 7. Docs

- [ ] 7.1 Update `docs/okf.md` status matrix, architecture, user docs and known gaps for plans and calendar export; verify the "Training-plan calculation" row and gap list are current
