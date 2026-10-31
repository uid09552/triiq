# Design

## Context

Existing pieces: the chat agent with in-process tools over the SQLite cache (`lib/agent`), `IntervalsWorkoutService` (creates one workout, today only, via native step syntax), a Google Calendar render-URL helper in `lib/util/calendar_export.dart`, hand-rolled bar/line charts, and `training-philosophy.md` (prose, 80/20 reference). `docs/okf.md` is the app spec. See proposal.md for motivation. The system prompt forbids stating numbers that did not come from a tool, so plan numbers must come from code the agent calls, not from the model.

## Goals / Non-Goals

**Goals:**
- Load and split numbers come from deterministic Dart, testable offline.
- LLM only writes session detail inside fixed slots; athlete confirms before any write.
- One editable knowledge source for engine and agent.

**Non-Goals:**
- Race-specific taper/peaking schedules (a later change).
- Auto-adaptation when sessions are skipped (later change).
- Google Calendar API / OAuth; Windows device-calendar writes.

## Decisions

1. **Deterministic `PlanEngine`, LLM fills detail.** Engine returns weeks with target load, session slots (type, day, duration, zone) and the 80/20 split. Exposed as an agent tool (`generate_training_plan`). Alternative: have the LLM generate the whole plan — rejected: unverifiable numbers, drifts on small Ollama models, conflicts with the epistemics rules.
2. **Week multipliers as knowledge, not code.** Defaults 1.00 / 1.08 / 1.15 / 0.60 live in the knowledge section and are overridable. Baseline = mean completed weekly load of the last 4 weeks from the cache. Ramp cap is a user setting with a stated default.
3. **Knowledge inside `docs/okf.md`** (user decision), as fenced blocks with a dedicated info string (e.g. ```okf-template) holding YAML/JSON. Bundled via a `pubspec` asset; parser scans only those blocks. Alternative was a separate file; chosen option keeps one document but mixes app docs with training content — parsing by info string keeps them separable.
4. **Persistence:** SQLite v3 adds `plans` and `plan_sessions` (plan id, week, date, type, duration, load, steps, `intervals_event_id`, `calendar_event_id`, status). Upgrade creates tables empty, same pattern as `events` in v2.
5. **Intervals.icu ownership:** plan events are created with a stable external id / tag per plan so regenerate and remove can find them; delete uses `others: false` per event. `IntervalsWorkoutService` is generalised to take a date and tag (closes the "always today" gap).
6. **Device calendar via a plugin on Android; link fallback elsewhere.** Alternatives: `.ics` export (manual, kept as possible later option), Google API + OAuth (needs a cloud project; against "no backend").
7. **Preview sheet reuses the existing draft-preview pattern** extended to a multi-session list with per-session edit of date.

## Risks / Trade-offs

- [Default multipliers/ramp cap read as medical advice] → label as defaults, editable, agent states they are defaults.
- [Intervals.icu silently keeps unparseable steps as description] → engine templates use only known-good step syntax; read back `push_errors` if available (known gap).
- [Device calendar plugin may not build under this AGP — precedent: `flutter_timezone`] → verify a debug APK builds before wiring UI; fallback is link/.ics.
- [Partial create leaves half a plan] → record per-session status, retry only failures.
- [okf.md edits break parsing] → malformed blocks fall back to defaults (spec'd).

## Migration Plan

Schema v2 → v3 creates empty tables; no data migration. Rollback: removing the plan feature leaves unused tables; Intervals.icu events remain and can be deleted by tag.

## Open Questions

- Default tolerance band for "80/20" (e.g. ±5 points) — decide when writing the knowledge block; does not alter specs.
