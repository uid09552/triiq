# Design

## Context

- `Goal.planWeeks` computes `daysUntilEvent ~/ 7` from the start Monday. That count excludes the event week (event on Sunday 20 Dec, start 2 Nov: 48 days → 6 weeks, ending 13 Dec), and an event under 2 weeks away falls back to the 8-week default, which runs past the event.
- `proposeCurve` ramps from the baseline at `rampCap` (with an optional hold every 4th week) under the CTL and hours ceilings. `phasesFor` knows only `build` and `recovery`, where recovery means a week below `recoveryThreshold` of the week before. `flagWeeks` checks every week against the ramp, CTL and hours limits.
- Templates (`okf-template`) are keyed by goal, slot and a `phases` list. The engine resolves `build`/`recovery`.
- Plan weeks are stored with their sessions; phase is not persisted.

## Goals / Non-Goals

**Goals:** a taper that falls out of the existing curve model, tunable from the knowledge, with no change to how saved plans are stored.

**Non-Goals:** multiple races or A/B/C priorities (one event per goal, as today); B-race mini-tapers; brick sessions; post-race recovery weeks; changing plans that are already saved.

## Decisions

1. **Taper is a third phase decided by position, not by load.** `phasesFor` stays load-based for build/recovery, but the last `taperWeeks` weeks of an event-ending plan are `taper` whatever their load, and the last of them is also flagged `raceWeek`. *Alternative:* infer taper from the load drop, the way recovery is inferred. Rejected: an athlete who drags a taper week up to 120% would turn it back into build, and the race-week rules have to apply whatever the load.

2. **Taper load is anchored to the last pre-taper week of the proposal.** `proposeCurve` builds the pre-taper weeks as it does today, then sets taper week *k* = `anchor × taperFactors[k]`. The athlete's 80-120% factor then multiplies the proposal as usual. Anchoring on the *proposal* rather than the athlete-adjusted week keeps the taper stable while the build weeks are being dragged. *Alternative:* anchor on the adjusted target. Rejected: dragging week 5 would silently move weeks 6-7.

3. **Knowledge keys** (docs/okf.md §5.1 `okf-rules`): `taper: {"long_distance": [0.7, 0.5], "short_event": [0.6]}`. The list length is the taper length, so there is no separate `taperWeeks` key that could disagree with it. A goal type missing from the map gets no taper, and the preview says so. New `okf-template`s with `phases: ["taper"]` for z2/intervals/long per goal, plus one `race.openers` template (about 25 min, 3×1 min at threshold-plus, `slot` "openers"). Templates are validated at load like the existing ones.

4. **Long session shortened more than the week.** In taper weeks the slot shares shift away from `long` (taper templates carry `shareScale`, for example long ×0.6, with the remainder spread over z2/intervals and renormalised). This keeps the change in the knowledge rather than in engine branches. *Alternative:* hard-code a long-session cap in the engine. Rejected because it can't be tuned.

5. **Race-week placement** is a filter on available days before `_placeByCost` runs: drop the event day and every later day of the week, then reserve the day before for openers when it is a training day. Sessions that no longer fit are dropped Z2-first, which is the rule that already exists for fewer days than sessions.

6. **`planWeeks` counts the event week inclusively**: `daysUntilEvent ~/ 7 + 1`, clamped to 2-16. Above 16, the plan is 16 weeks with no taper plus an info line. An event in the start week itself (count 1) is below the 2-week minimum, so validation says the event is too close for a new plan instead of falling back to the 8-week default as it does today. This changes the length of event-based plans by one week, which is intended (see the spec).

7. **Flags**: `flagWeeks` skips the weekly-increase and CTL checks for taper weeks and still applies the hours check. The week after the taper doesn't exist, so the ramp reference never resumes.

8. **Agent**: the plan tool output gains `phase` per week and `days_to_event`. The system prompt line about plans mentions the taper and points at `get_training_guidance("taper")`, a section that already exists.

## Risks / Trade-offs

- [Taper factors are opinionated] → kept in the knowledge with the source noted in §5 prose, and the athlete can still adjust each week 80-120%.
- [Short plans (2-3 weeks) are mostly taper] → acceptable for an athlete planning close to their race. The preview shows the phases so it isn't a surprise.
- [The main `training-plan` spec is stale and two in-flight changes touch the engine] → this change only adds a phase and a placement filter. Implement it after `training-calendar-generator` lands, or rebase onto it. Task 0.1 checks for this.
- [One-week length change for existing event goals] → only newly generated plans are affected, and saved plans keep their weeks.
