# Proposal

## Why

The proposed load curve ramps at a fixed default of +10% every week. Athletes want to set the ramp themselves, and a steady ramp with no pause builds fatigue: holding the load flat every fourth week is a gentle, common middle ground between "never rest" and a full recovery week. The session mix (how much of the week is Z2, intervals and long endurance) comes from the goal template and can't be changed. Placement ignores habits like "long ride on Saturday, intervals on Tuesday".

## What Changes

- **Ramp slider**: the Weekly load card gets a slider for the weekly increase, 0–15% in 1% steps, default 10%. Moving it redraws the proposal straight away and saves into the goal. It replaces the free-text "Max weekly load increase" field in the goal editor.
- **Hold week**: by default every 4th week of the proposal is held at the previous week's TSS (0% increase), then the ramp continues. A switch on the same card turns it off. Weeks stay draggable as before; the hold only shapes the proposal.
- **Session mix**: the goal editor gets Z2 / Intervals / Long endurance sliders: shares of each sport's weekly load, 5% steps, summing to 100%, defaulting to the goal type's template shares. The engine uses them instead of the template shares. The 80/20 check keeps warning when the mix gets too hard.
- **Preferences** in the goal editor:
  - a preferred **long-session day** per sport (Ride / Run; single-sport goals have one);
  - preferred **interval day(s)**;
  - **max sessions per day** (1 or 2; triathlon defaults to 2, single sport to 1).
  
  Placement honours them when the days are available, and falls back to the current rules (and says so in the week card) when they can't be met.
- The agent's `get_training_plan` / `propose_load_curve` report the ramp and hold settings. `propose_load_curve` accepts `ramp_percent` and `hold_every_4th`.

## Capabilities

### New Capabilities
- `plan-preferences`: session-mix shares, long and interval day preferences, max sessions per day, and how placement uses them.

### Modified Capabilities
- `plan-load-curve` (from `training-calendar-generator`, refined by `plan-to-calendar`): "Proposed load curve" gains the ramp slider and the hold week.

## Impact

- **Code:**
  - `Goal` gains `holdEvery4th`, `slotShares`, `longDays`, `intervalDays` and `maxSessionsPerDay` (JSON, backward compatible); `maxWeeklyIncrease` is reused for the slider.
  - `CurveLimits` / `proposeCurve` get the hold rule; `PlanEngine` gets shares and placement.
  - `lib/screens/plan/plan_screen.dart` (curve card controls) and `goal_editor_screen.dart` change.
  - The agent tool arguments change, plus l10n (en, de).
- No schema change.
- **Behaviour change:** default proposals now hold weeks 4, 8, 12… flat. Tests and docs that assumed an uninterrupted ramp change. Saved load-graph factors keep applying to the new proposal (each week keeps its share).
- **Docs:** `docs/okf.md` (5.1 block rules, Training plan user docs, knowledge `holdEveryWeeks` rule).
