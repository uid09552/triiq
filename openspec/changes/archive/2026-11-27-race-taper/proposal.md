# Proposal

## Why

A goal can carry an event date, but the plan engine only uses it to pick the plan length — and even then the block stops the week *before* the event week. Every week ramps or holds right up to race day, so a triathlete arrives at their A race fatigued. Peak and taper shaping is the biggest gap in the plan for a race-focused app (docs/okf.md, Known gaps).

## What Changes

- When the goal has an event date and the plan reaches it, the block **ends in the event week** (today it ends one week early) and its last weeks are a **taper**: load stepped down from the last build week while the interval session is kept (shorter), the long session shortened most.
- **Taper length by goal type** from the training knowledge (long distance 2 weeks, short event 1 week), with the step-down factors stored as `okf-rules`, so they can be tuned without code.
- **Race week**: no session on the event day; a short openers session the day before; nothing after the event in that week.
- The load graph labels taper weeks and race week, and the ramp/CTL warnings do not fire for them (a taper is a deliberate drop). Taper weeks can still be adjusted 80-120% like any other week.
- Validation: a chosen plan length that runs past the event is rejected; an event more than 16 weeks away gives a base block without a taper and says when the taper block will start.
- **Today countdown**: "Race in N days" while a plan with an event is active.
- The agent sees each week's phase and the days to the event, and explains the taper using the knowledge.
- en + de strings; docs/okf.md (block rules, plan user docs, known gaps).

## Capabilities

### New Capabilities
- `race-preparation`: shaping a plan around the goal's event date — taper weeks, race week, the countdown, and how the agent explains them.

### Modified Capabilities

None. The main `training-plan` spec still describes the original 4-week block and is being reworked by the in-flight `training-plan` / `training-calendar-generator` changes; race preparation is kept as its own capability so it does not collide with them.

## Impact

- `lib/plan/load_curve.dart` (taper phase, proposal and flags), `lib/plan/plan_engine.dart` (taper/race-week templates, event-day placement), `lib/plan/plan_models.dart` (`planWeeks`, validation), `lib/plan/knowledge.dart` + docs/okf.md §5 (new `okf-rules` keys and taper templates).
- Load graph and plan preview widgets (phase labels), Today screen (countdown), `lib/agent/tools/plan_assistant_tools.dart` (phase + event in plan output).
- No schema change: phase is derived from the goal and curve, not stored. Existing saved plans keep their sessions; only newly generated plans taper.
