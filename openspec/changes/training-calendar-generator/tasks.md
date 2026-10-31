# Tasks

## 0. Prerequisite

- [ ] 0.1 Finish or archive the `training-plan` change so `openspec/specs/training-plan/spec.md` exists; verify the MODIFIED delta here has a base

## 1. Models and knowledge

- [x] 1.1 Extend `Goal` with `weeks` (2–16, default 8 / weeks-to-event), `sportMix`, `loadFactors`, add `Triathlon` to `Goal.sports`, validation (range, mix totals 100, 5% steps); verify JSON round-trip and loading an old goal without the new fields
- [x] 1.2 In `docs/okf.md` knowledge: `maxWeeklyIncrease` 0.10, `recoveryThreshold` 0.9, swim base/interval templates for each goal; verify `KnowledgeRepository` tests parse them and a missing swim template raises `MissingTemplateException`

## 2. Engine

- [x] 2.1 Add `proposeCurve` (steady ramp with weekly-increase, CTL and hours ceilings); verify 300 TSS / 10% / 4 weeks → 330, 363, 399, 439 and the hours-limited case
- [x] 2.2 Make `PlanEngine.generate` take weeks + factors, use adjusted targets, derive recovery phase from the 90% rule, flag over-cap weeks without clamping; verify tests for 8-week plan, manual dip → recovery templates, 120% → warning kept
- [x] 2.3 Split week load by sport mix and build per-sport slots; verify default mix on 400 TSS ≈ 60/200/140 within 5 points, 0% sport gets no sessions, single-sport goal unchanged
- [x] 2.4 Multi-sport placement (≤2/day, long Ride/Run on different days) with `notEnoughDays` failure; verify tests over 3–7 day sets
- [x] 2.5 Store weeks, mix, factors and proposed curve in `plans.meta`; verify a pre-change plan row still loads

## 3. UI

- [x] 3.1 `LoadCurveController` (factors, selection, undo stack, reset) and a pure `flagWeeks()` shared with the engine; verify unit tests for snap/clamp, undo and flags matching engine output
- [x] 3.2 `LoadCurveEditor` painting (axis 80–120%, 100% line, proposal vs adjusted lines, TSS labels, warning colour); verify golden-free widget test reads labels and colours via semantics/finders in light and dark
- [x] 3.3 Drag interaction: column hit-testing, relative drag, 5% snap with haptic, floating label, horizontal scroll when columns < 40 dp; verify widget tests: relative drag 100→110%, clamp at 120%, 16 weeks at 360 px scrolls and vertical drag changes one week only
- [ ] 3.4 Precision and a11y: tap-select with ±5% buttons, arrow keys on Windows, per-week semantics slider, undo, reset confirmation; verify widget tests for keys, undo and semantics actions, and a manual drag check on an Android device and on Windows with mouse
- [x] 3.5 Goal editor: weeks field, Triathlon option, Swim/Bike/Run percentage controls with live total; verify invalid total blocks save (widget test)
- [x] 3.6 Plan setup flow: goal → curve editor → generate → existing preview sheet; verify cancel still writes nothing
- [ ] 3.7 Plan screen calendar grid (Mon–Sun rows, sport colours, target vs planned, per-sport TSS); verify widget test and manual check in light/dark on Android and Windows
- [x] 3.8 en + de strings for all new labels and warnings; verify `flutter analyze` is clean

## 4. Agent and docs

- [x] 4.1 Extend the `generate_training_plan` tool arguments with `weeks`, `sport_mix`, `load_factors`; verify bad values return an `error` string
- [x] 4.2 Update `docs/okf.md` plan user docs, status matrix and known gaps (taper, bricks not covered); verify the section matches the shipped behaviour
