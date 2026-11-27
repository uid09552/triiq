# Proposal

## Why

Activity detail shows totals and a zone bar only. Athletes can't see how a session actually unfolded (HR/power over time, intervals, drift) or whether it matched what was planned and the 80/20 intent, and can't ask the trainer about a specific session without retyping context.

## What Changes

- **Session detail diagrams**: time-series chart of power/HR/pace (and cadence/altitude if present), detected intervals highlighted, zone-time chart, from Intervals.icu activity streams fetched on demand and cached.
- **Session evaluation**: planned vs actual (duration, load, intensity), time-in-zone mapped to low/moderate/high, aerobic decoupling, and a verdict with the reasons shown.
- **Weekly review**: planned vs actual per day and week, compliance, 80/20 split bar, load trend, and a short "what to do next week" note.
- **Ask the trainer about this session**: opens Chat pre-loaded with the session (or week) as context.
- Evaluation numbers come from deterministic code; the agent only explains them.

## Capabilities

### New Capabilities
- `session-evaluation`: stream-based diagrams, interval highlights, planned-vs-actual and intensity/decoupling evaluation for one activity, and chat hand-off.
- `weekly-review`: per-week compliance, 80/20 distribution and load trend with a next-week note.

### Modified Capabilities

None (no specs exist yet under `openspec/specs/`).

## Impact

- Code: `activity_detail_screen.dart` and `planned_workout_detail_screen.dart`, new `lib/evaluation/`, new chart widget(s) in `lib/widgets/charts/`, a streams cache (SQLite schema bump), new Weekly review screen, `ChatScreen` pre-seeded entry, agent tool for evaluation results, l10n (en, de).
- API use: `getActivityStreams`, `getIntervals` (already in the generated client).
- Docs: `docs/okf.md` charts, activities, chat sections.
