# Design

## Context

`training-plan` delivered `PlanEngine` (4 fixed phases × `weekMultipliers`, ceilings for weekly increase / CTL ramp / hours), a single-sport `Goal` (Run/Ride) in SharedPreferences, `plans`/`plan_sessions` in SQLite v3 (with a free-form `plans.meta` JSON column and a per-session `sport`), the Plan screen, preview sheet and Intervals.icu writer. Charts are hand-rolled in `lib/widgets/charts/` (`bar_chart.dart`, `line_chart.dart`); there is no draggable chart. See proposal.md for motivation.

## Goals / Non-Goals

**Goals:**
- Plan length, load shape and sport mix are athlete inputs; every number still comes from deterministic Dart.
- The default curve is a safe steady ramp (≤10%/week) the athlete only tweaks.
- Reuse the existing preview / confirm / write path unchanged.

**Non-Goals:**
- Automatic taper or race-peak shaping; brick sessions; per-sport ramp caps.
- Swim pace-zone calibration beyond what Intervals.icu already holds.
- Editing individual sessions in the calendar grid (date change stays in the preview sheet).

## Decisions

1. **Curve = proposal × per-week factor.** `LoadCurve { List<double> proposed; List<double> factors /*0.80–1.20*/ }`; `target[i] = proposed[i] * factors[i]`. Factors are stored, not absolute TSS, so a baseline change after sync re-scales the plan (spec'd). Alternative "% of previous week" was rejected by the user; it compounds edits and is hard to read.
2. **Proposal is a pure function** `proposeCurve(baseline, weeks, rampCap, ctl, hoursCeiling)`: `p[i] = min(p[i-1]·(1+cap), ctlCeiling, hoursCeiling)`, `p[-1] = baseline`. Existing ceiling code moves into it; the `weekMultipliers` rule is no longer used for the default (kept parseable for compatibility, ignored by the curve).
3. **Over-cap athlete edits warn, don't clamp.** The engine computes `WeekLimit` flags against adjusted targets but uses the athlete's target. Hard bounds are only the 80–120% factor range.
4. **Phase from the curve.** `recovery` when `target[i] < 0.90 · target[i-1]` (`recoveryThreshold`; 0.85 was too low — an 80% drag after a +10% week is only 12% down, so it never registered), else `build`. Keeps existing phase-keyed templates working; `build_plus`/`peak` templates stay for knowledge compatibility but are not selected by default.
5. **Triathlon as a sport with a mix.** `Goal.sport = 'Triathlon'` plus `sportMix: Map<String,int>` (Swim/Ride/Run percentages, Intervals.icu types). Engine splits week load by share, then runs the existing per-sport slot builder per sport (Swim: base + intervals; Ride/Run: base, intervals, long). Single-sport goals behave as a mix of 100%.
6. **Placement:** greedy over available days — long Ride and long Run first on different days (prefer weekend), then intervals not adjacent to longs of the same sport, then base; max 2 sessions/day. Failure returns a `PlanFailureKind.notEnoughDays` result rather than dropping sessions.
7. **Persistence without schema change.** `Goal` JSON gains `weeks`, `sportMix`, `loadFactors`; `plans.meta` stores the same plus the proposed curve at generation time so the Plan screen can show proposal vs. adjusted. Missing fields → defaults, so existing goals load.
8. **Graph widget:** new `LoadCurveEditor`, built in the same style as `line_chart.dart`. Y axis 80–120% with a 100% reference line; a faint dashed line for the proposal and a solid line for the adjusted curve; absolute TSS label above each point; warning-coloured points for flagged weeks.
   - *Gestures:* one `CustomPaint` inside a `SingleChildScrollView` (horizontal) when `columns × 40 dp > width`, otherwise columns stretch to fit. A `VerticalDragGestureRecognizer` on the plot wins vertical drags in the gesture arena while the scroll view keeps horizontal ones — no custom disambiguation needed. Hit-testing maps `dx` to a column, so the whole column is the target, not the small dot.
   - *Relative drag:* on drag start remember the column's factor; on update `factor = start − dy / pxPerPercent`, clamp 0.80–1.20, round to 0.05. On each change of the rounded value call `HapticFeedback.selectionClick()` (no-op on Windows).
   - *Feedback:* the dragged point grows and a floating label (week, %, TSS, Δ vs previous week) sits above it, clamped inside the chart; warning colour is recomputed from the same pure `flagWeeks()` the engine uses, so live and generated warnings cannot disagree.
   - *State:* `LoadCurveController` (`ChangeNotifier`) holds factors, selected week and an undo stack (one entry per drag end / step); the widget is stateless over it, which keeps widget tests simple.
   - *Precision/a11y:* tapped week shows ±5% buttons under the chart; `Focus` + `Shortcuts` map arrow up/down (and left/right to change selection) on Windows; each column has a `Semantics(slider: true, increasedValue/decreasedValue)` node.
   - Alternative considered: `fl_chart` with touch callbacks — rejected, it adds a dependency and its drag handling targets points, not columns; the app already hand-rolls charts.
9. **Calendar grid** is a plan-local widget (7 columns × N rows) in `lib/screens/plan/`, not the app's Calendar tab, so it can show plan drafts before they exist in Intervals.icu. Sport colours come from one map shared with existing sport icons.

## Risks / Trade-offs

- [10%/week steady ramp over 16 weeks ≈ 4.6× load] → the hours ceiling and CTL-ramp ceiling flatten it; the curve shows "limited by hours" so the athlete sees why.
- [No recovery weeks by default may read as advice to skip recovery] → editor hint mentions dipping a week to ~80%; defaults labelled as defaults.
- [Swim TSS estimates are less reliable] → templates use Intervals.icu's own load estimate after write; preview shows engine estimate labelled "estimated".
- [Greedy placement can fail on feasible inputs] → covered by tests on 3–7 day sets; error is explicit, not silent.
- [Depends on unarchived `training-plan`] → archive it before this change, or validation of the MODIFIED delta has no base.

## Migration Plan

Old goals load with `weeks = 8`, factors all 1.0, single-sport mix. Old 4-week plans in SQLite keep their sessions; `meta` without curve data renders without the proposal overlay. `maxWeeklyIncrease` default in `docs/okf.md` changes 0.15 → 0.10; per-goal overrides are kept.

## Open Questions

- (Resolved) The recovery threshold is a knowledge rule, `recoveryThreshold: 0.9`. Ramp warnings skip weeks at or below their proposal and measure from the last non-recovery week, so returning to the curve after a dip is not flagged.
