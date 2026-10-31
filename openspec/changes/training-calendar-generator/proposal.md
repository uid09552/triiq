# Proposal

## Why

The `training-plan` change generates a fixed 4-week, single-sport block whose load shape comes from hard-coded multipliers. Triathletes need a plan over a chosen number of weeks, split across swim, bike and run, and a way to see and shape the weekly load before sessions are generated — without losing the safety of a sensible default progression.

## What Changes

- **Number of weeks**: the athlete picks the plan length (2–16 weeks, default 8; defaults to the weeks until the event date when one is set and it fits).
- **Proposed load curve**: the engine proposes a weekly TSS per week as a steady ramp from the athlete's baseline, increasing by at most 10% per week by default (user-adjustable cap). No recovery weeks are inserted by default.
- **Load graph editor**: a chart with one point per week. The y axis is the share of the *proposed* weekly TSS, 100% = proposal, adjustable per week between 80% and 120% by dragging; the absolute TSS is shown alongside. Weeks pushed above the ramp cap or the hours budget are flagged, not blocked. A "reset to proposal" action restores the default. Dragging is the main input: press anywhere in a week's column and drag up/down, the line follows live, snaps to 5% with a haptic tick and a label showing %, TSS and change vs. last week; ±5% buttons, arrow keys (Windows), a screen-reader slider and undo cover precise and accessible editing.
- **Triathlon sport mix**: a new `triathlon` sport option with editable percentages of weekly load for Swim / Bike / Run (must total 100%, default 15 / 50 / 35). Each week's TSS is split by these shares into per-sport sessions.
- **Training calendar**: the Plan screen gains a week-by-week calendar grid (Mon–Sun) showing generated sessions coloured by sport, with per-week target vs. planned TSS.
- **Generation** uses the edited curve and mix; the existing preview → confirm → write-to-Intervals.icu path is reused unchanged.
- Swim session templates are added to the training knowledge in `docs/okf.md`; default `maxWeeklyIncrease` changes from 0.15 to 0.10.

## Capabilities

### New Capabilities
- `plan-load-curve`: plan length, proposed steady-ramp weekly load, the per-week 80–120% load graph editor and its warnings.
- `triathlon-sport-mix`: swim/bike/run load percentages, splitting weekly load into per-sport sessions, swim templates, and the calendar grid's sport colouring.

### Modified Capabilities
- `training-plan` (from the not-yet-archived `training-plan` change): "Four-week block generation" becomes N-week generation driven by the load curve; "Ramp-rate cap" default becomes 10% and over-cap weeks set by the athlete are flagged instead of reduced; "Plan screen" gains the calendar grid.

## Impact

- Depends on the `training-plan` change; archive it (or apply its remaining tasks) first so this delta has a base spec.
- Code: `lib/plan/plan_engine.dart` (N weeks, curve input, sport split), `plan_models.dart` (`Goal` gains `weeks`, `sportMix`; `triathlon` sport), `knowledge.dart` (swim templates, rules), new `lib/widgets/charts/load_curve_editor.dart`, `lib/screens/plan/` (goal editor, plan screen grid), l10n (en, de).
- Persistence: curve overrides and sport mix stored in `Goal` (SharedPreferences) and in `plans.meta` JSON — no SQLite schema change.
- Docs: `docs/okf.md` training knowledge (swim templates, 10% default), plan user docs.
