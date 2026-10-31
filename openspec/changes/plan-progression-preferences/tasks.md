# Tasks

## 1. Model and curve

- [x] 1.1 `Goal` fields (`holdEvery4th`, `slotShares`, `longDays`, `intervalDays`, `maxSessionsPerDay`) with JSON and validation (shares total, days among training days, distinct long days, max per day 1/2); verify round-trip, old-goal defaults and each validation error
- [x] 1.2 `CurveLimits.holdEvery` + knowledge rule `holdEveryWeeks: 4`; `proposeCurve` holds every 4th week; verify 8 weeks from 300 at 10% → 330, 363, 399, 399, 439, 483, 531, 531, hold off → uninterrupted ramp, hours ceiling still wins; update existing curve/engine/editor tests to the new numbers

## 2. Engine

- [x] 2.1 Use `goal.slotShares` in `_weekEntries` (swim renormalised); verify a 400-TSS run week at 20/50/30 gives about 200 TSS intervals and the 80/20 flag fires when it should
- [x] 2.2 Single cost-based placement for all goals with `maxPerDay`, long-day and interval-day costs, `PlanWeek.notes` for unmet preferences; verify regression tests (single sport 3/4/7 days without preferences match today), long ride Sat / long run Sun, Tuesday intervals, unavailable preference → note, 1-per-day triathlon fit/failure

## 3. UI

- [x] 3.1 Curve card: ramp slider (0–15%, label) and hold switch, live redraw via `controller.update`, save on change end; remove the goal editor's increase field; verify widget tests: slider to 5% redraws and saves, dragged week keeps its share, hold switch toggles week 4
- [x] 3.2 Goal editor: session-mix sliders with live total, long-day per sport, interval days, max per day; clearing preferences when a day is unticked; verify widget tests for save blocked at 95%, distinct long days, cleared preference
- [x] 3.3 Week card shows unmet-preference notes; en + de strings; verify `flutter analyze` clean and a widget test for the note

## 4. Agent and docs

- [x] 4.1 `get_training_plan` reports ramp/hold/mix/preferences; `propose_load_curve` accepts `ramp_percent` and `hold_every_4th`; verify tool tests (6% ramp proposal, invalid 20% errors, nothing saved)
- [x] 4.2 Update `docs/okf.md` (5.1 block rules + `holdEveryWeeks`, Training plan user docs, agent tools); verify it matches the behaviour
