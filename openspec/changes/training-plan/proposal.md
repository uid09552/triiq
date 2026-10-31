# Proposal

## Why

"Train now" proposes one session at a time with no memory of where the athlete is in a build. Athletes training for a target (e.g. a long-distance event) need a periodised block, a way to see it on their calendars, and sessions that follow the 80/20 intensity split instead of whatever the model improvises each time.

## What Changes

- Add a **goal** (target type such as long distance, optional event date, available days and weekly hours) that a training plan is generated for.
- Add a deterministic **plan engine** that builds a 4-week block (build, build+, peak, recovery). Each week has the same session types — Z2 base, one interval session, one long session — and week load, long-session length and interval volume change between weeks. Weekly load is derived from the athlete's recent cached TSS/CTL, with a ramp-rate cap.
- Check every generated week against the 80/20 split and surface the result.
- Expose the engine to the chat agent as a tool, and let the agent write session detail (step syntax) for each slot; the athlete previews and confirms before anything is written.
- Write confirmed plan sessions to Intervals.icu as planned workouts, tagged so a plan can be found, replaced or removed later.
- Add sessions to the athlete's calendar: directly to the device calendar on Android (which Google Calendar syncs), the existing pre-filled Google Calendar link as the fallback elsewhere.
- Extend `docs/okf.md` with a **Training knowledge** section (phase rules, week multipliers, session templates per goal in machine-readable blocks), bundled as an asset so the engine and the agent read the same source.
- New **Plan** screen (More → Training plan): block timeline, current week highlighted, per-week targets vs. actual.

## Capabilities

### New Capabilities
- `training-plan`: goals, 4-week block generation, 80/20 validation, plan persistence, writing/replacing/removing plan sessions in Intervals.icu, the Plan screen.
- `training-knowledge`: structured training rules and session templates inside `docs/okf.md`, and how the app and agent read them.
- `calendar-export`: putting planned sessions on the athlete's calendar (device calendar on Android, link fallback elsewhere).

### Modified Capabilities

None (no specs exist yet under `openspec/specs/`).

## Impact

- Code: new `lib/plan/` (engine, models, repository), `lib/screens/plan/`, new agent tool(s) in `lib/agent/tools`, `lib/util/calendar_export.dart`, `IntervalsWorkoutService` (date other than today, tags, bulk create/delete), SQLite schema v3 (`plans`, `plan_sessions`), l10n strings (en, de).
- Dependencies: a device-calendar plugin; Android calendar read/write permissions in `AndroidManifest.xml`.
- Docs: `docs/okf.md` (new knowledge section, status matrix, plan docs); `pubspec.yaml` asset entry.
- Related: closes two "Known gaps" (pick another day for created workouts; edit draft before create).
