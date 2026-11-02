# Proposal

## Why

Plan sessions are entirely template-driven today: `description` is a flat list of
`%FTP`/`%pace` steps, identical in shape for the same goal/slot/phase every time,
and swim never gets a session aimed at technique — only "aerobic" and "threshold"
effort work (`docs/okf.md` 5.3). The athlete wants the Calendar's generated plan
to read like it was written by a coach: AI-authored session content, a swim
technique session worked in, and sessions that show a short description plus
detailed set information rather than a wall of percentages. The load-curve and
periodisation math (`PlanEngine`, `lib/plan/plan_engine.dart`) is tested and
working; only session *content* needs to stop being mechanical.

## What Changes

- A content-generation pass fills each session's short description and detailed
  set text once the deterministic engine has built the week, using whichever LLM
  provider the athlete already configured for chat (Claude or Ollama,
  `lib/agent/llm_settings.dart`). Without one configured — or if generation fails
  or returns something unusable — a session keeps today's plain, deterministic
  step list. Nothing about plan generation starts requiring an LLM.
- The engine decides, deterministically, which swim sessions in a plan are
  technique-focused (a rotation across non-recovery weeks) — not a free-form AI
  choice. The content layer (AI, or a canned fallback when AI isn't available)
  fills those sessions with drill-based content instead of plain aerobic swim.
- Every session's numbers — date, sport, slot, minutes, load, low-intensity
  minutes — stay exactly what `PlanEngine` computes today. The content pass only
  ever rewrites `name` and the two description fields below; it runs after
  `PlanEngine.generate()` returns, which stays synchronous and free of I/O.
- Each session gets a short, one-line description (shown wherever only the name
  is shown today) and keeps a detailed, set-by-set description — reps, duration,
  effort, and for a technique session the drill names — shown in the existing
  session detail sheet and sent to Intervals.icu as today.
- en + de strings; docs/okf.md.

## Capabilities

### New Capabilities

- `ai-session-content`: AI-authored (with a deterministic fallback) short
  descriptions and detailed set content for generated plan sessions, including
  swim technique sessions chosen deterministically by the plan engine.

### Modified Capabilities

None.

## Impact

- New module (`lib/plan/session_content.dart`) run from `PlanService.generate()`
  as an async post-processing pass over the `TrainingPlan` the pure
  `PlanEngine` returns — `PlanEngine` itself is unchanged in its I/O-free,
  synchronous contract apart from the new deterministic technique-session flag.
- `lib/plan/plan_engine.dart`: a deterministic rule marking some swim sessions
  technique-focused; `lib/plan/plan_models.dart`: a `shortDescription` field on
  `PlanSession` and a `techniqueFocus` flag; SQLite schema v6 → v7
  (`plan_sessions` gains a column) in `lib/data/db/app_database.dart`.
- `lib/agent/chat_model_factory.dart` reused unchanged to reach the athlete's
  configured provider for a one-shot (non-chat, non-tool) generation call.
- `lib/screens/plan/plan_session_sheet.dart` and the week/Calendar views that
  show a session's name gain the short description; the detail sheet keeps
  showing the full set text.
- docs/okf.md: Training plan section, status table, Known gaps.
