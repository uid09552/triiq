# Design

## Context

- **Proposal:** `proposeCurve(CurveLimits, weeks)` ramps every week by `rampCap` (from `Goal.maxWeeklyIncrease` or the knowledge default 0.10), held down by CTL/hours ceilings. `flagWeeks` warns on athlete-set weeks.
- **Editing:** `LoadCurveController` edits in TSS (band 80–120%). The Plan screen's `_CurveCard` shows the editor. The ramp is a free-text field in `GoalEditorScreen`.
- **Engine:** `PlanEngine._weekEntries` splits load by the goal profile's slot shares (`GoalProfile.slots`). Placement is `_chooseDays` (one session a day, long on the last chosen day, intervals furthest from it) for one sport, and `_placeMultiSport` (cost-based, ≤ `maxSessionsPerDay` = 2, weekend bonus for longs) for triathlon.
- **Agent:** `PlanAssistantTools` reads and proposes on top of `PlanService.curve`.

## Goals / Non-Goals

**Goals:**
- One pure place (`proposeCurve`) decides the hold weeks, so the graph, the engine, the agent and tests agree.
- Preferences are hard where possible, and soft fallback (with a note) where the week can't satisfy them. No silent dropping.

**Non-Goals:**
- Per-sport ramps; a configurable hold interval other than 4; recovery dips by default.
- Time-of-day preferences; preferences per individual week.

## Decisions

1. **Hold rule in `CurveLimits`:** new `holdEvery` (int, 0 = off, default 4, from the knowledge rule `holdEveryWeeks` and `Goal.holdEvery4th`). In `proposeCurve`, a week with `(i + 1) % holdEvery == 0` proposes `previous` instead of `previous·(1+ramp)`, then ceilings apply as usual.
   - A hold week isn't a recovery week (no 10% drop), so it uses build templates.
   - `flagWeeks` is unchanged: it measures the ramp against the last non-recovery week and exempts weeks at or below their proposal.
2. **Ramp slider on the curve card.** A `Slider` (0–15, 1% divisions) with a live `planCurveRampValue` label, and a `SwitchListTile` "Hold every 4th week".
   - On change, build a new goal (`maxWeeklyIncrease`, `holdEvery4th`), recompute `PlanService.curve`, call `controller.update(limits, weeks)` (factors keep their share), and save the goal. Saving is debounced to `onChangeEnd` for the slider.
   - The goal editor's increase text field is removed; its CTL-ramp field stays.
3. **`Goal` additions (JSON, all optional):**
   - `holdEvery4th: bool = true`
   - `slotShares: Map<String,int>?` (`z2`, `intervals`, `long` → %; `null` = template)
   - `longDays: Map<String,int>` (sport → weekday; single sport keyed by its sport)
   - `intervalDays: Set<int>`
   - `maxSessionsPerDay: int?` (null → 2 triathlon / 1 single)
   
   `validate` checks the shares total 100 in 5% steps, preferred days are training days, the two long days differ, and maxPerDay ∈ {1, 2}. The editor clears preferences whose day was unticked before validating.
4. **Shares in the engine:** `_weekEntries` uses `goal.slotShares` (→ fractions) instead of `profile.slots[s].share` when set. Counts still come from the profile. Swim renormalises over z2 + intervals as now.
5. **Placement:** preferences live only in the cost-based placement (`_placeByCost`, formerly `_placeMultiSport`), with `maxPerDay` from the goal. As implemented, a single-sport goal with **no** preferences and no per-day limit set keeps the original `_chooseDays`, so existing plans place exactly as before; any preference (or a per-day limit) sends it through the cost-based path too.
   - Preferences become costs: a long session on its preferred day −200, elsewhere +0; an interval session on a preferred interval day −100. Same-sport intervals and long on one day are forbidden.
   - After placement, a `PlanWeek.notes` list records unmet preferences (`longDayUnavailable(sport)`, `intervalDayUnavailable`), and the week card shows them.
   - Existing single-sport behaviour without preferences is kept by the default costs: long on the latest available day, intervals furthest from it. A regression test pins the old 3-day result (Tue intervals / Thu Z2 / Sat long).
   - Rejected: keeping two placement algorithms. Preferences would have to be implemented twice.
6. **Agent:** `get_training_plan` adds `ramp_percent`, `hold_every_4th`, `session_mix_percent` and `preferences`. `propose_load_curve` accepts `ramp_percent` (0–15, integer) and `hold_every_4th`, applied to `base` before the curve is computed. Same error style as the other arguments.

## Risks / Trade-offs

- [Existing tests assert an uninterrupted ramp, e.g. 330/363/399/439] → update them to the hold-on numbers, and add a hold-off case.
- [Cost-based placement changes single-sport results subtly] → regression tests for 3, 4 and 7 days without preferences match today's outputs.
- [Slider spam re-running `PlanService.curve`] → it reads the cache. Recompute on change, save on `onChangeEnd`.
- [Mix sliders interact: total ≠ 100 while dragging] → same pattern as the triathlon sport mix: live total, save blocked until 100.

## Migration Plan

Old goals: `holdEvery4th` defaults to true. This changes their proposal from week 4 on, which is intended and covered in the docs. The other new fields are empty and mean "template / no preference". No data migration.

## Open Questions

None blocking.
