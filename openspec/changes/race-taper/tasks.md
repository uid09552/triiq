# Tasks

## 0. Prerequisites

- [ ] 0.1 Check the state of `training-plan` and `training-calendar-generator`: if either still has open engine/curve tasks, finish or rebase onto them first; verify `flutter test test/plan` passes on the base before starting

## 1. Knowledge

- [ ] 1.1 Add the `taper` map to the §5.1 `okf-rules` block and parse it in `lib/plan/knowledge.dart` (missing goal type means no taper, invalid factors are a load error); verify knowledge-loading unit tests for valid, missing and malformed maps
- [ ] 1.2 Add `taper` templates per goal and slot (with `shareScale`) and the `race.openers` template to docs/okf.md §5.3, with §5 prose on the taper rules; verify the template loader test accepts them and rejects an unknown phase

## 2. Plan length and validation

- [ ] 2.1 `Goal.planWeeks` counts the event week inclusively, clamps to 16 with a no-taper notice, and `validate` rejects a chosen length past the event and an event in the start week; verify unit tests for each scenario in the spec's length requirements

## 3. Curve and phases

- [ ] 3.1 Taper phase and race-week flag by position in `load_curve.dart`; `proposeCurve` anchors taper weeks on the last pre-taper proposal week; verify unit tests for the long-distance (600 → 420/300) and short-event (400 → 240) scenarios and a no-event goal
- [ ] 3.2 `flagWeeks` skips ramp/CTL checks for taper weeks but keeps the hours check; verify unit tests that a taper drop is unflagged and an over-budget taper week still is

## 4. Engine

- [ ] 4.1 Taper templates and slot-share scaling in `plan_engine.dart`; verify a test that a taper week keeps one interval session at build intensity and that the long session shrinks more than the week's load
- [ ] 4.2 Race-week day filter (no event day or later, openers the day before when it is a training day, Z2 dropped first); verify tests for a Sunday and a Wednesday event

## 5. UI

- [ ] 5.1 Load graph and plan preview label Taper / Race week and show the >16-week notice; en + de strings; verify widget tests
- [ ] 5.2 Today countdown ("Race in N days" / race day) from the saved plan's event date; en + de; verify widget tests for future, today and no event, plus a manual run on Android and Windows

## 6. Agent and docs

- [ ] 6.1 Plan tool output gains per-week `phase` and `days_to_event`, and the system prompt mentions the taper; verify tool tests on the JSON shape
- [ ] 6.2 Update docs/okf.md (status matrix, block rules, Training plan user docs, Known gaps: drop "no taper / race-peak shaping"); verify the sections match the shipped behaviour
