# Design

## Context

- `PlanEngine.generate()` (`lib/plan/plan_engine.dart`) is synchronous and
  explicitly documented as free of I/O: "every number in a plan comes from
  here, never from the language model, so a plan can be tested and explained."
  It returns a `TrainingPlan` of `PlanWeek`s of `PlanSession`s, each with
  `name`, `minutes`, `load`, `lowMinutes` and `description` (the rendered
  Intervals.icu step text), built from `SessionTemplate`s parsed out of
  `docs/okf.md`'s `okf-template` blocks (`lib/plan/knowledge.dart`).
- `PlanService.generate()` (`lib/plan/plan_service.dart`) is the only caller of
  `PlanEngine.generate()`, invoked once per explicit "Generate" tap on the Plan
  screen (`lib/screens/plan/plan_screen.dart:_generate`), already behind a busy
  spinner — not on every load-graph slider drag. That is where an async,
  possibly-slow enrichment step belongs.
- The chat agent already reaches whichever LLM the athlete configured through
  `createChatModel(settings, tools: tools)` (`lib/agent/chat_model_factory.dart`),
  which returns a provider-agnostic `BaseChatModel` and is the only place either
  provider (Claude, Ollama) is named. `LlmSettings.isConfigured` is already the
  agent's own "is there anything to call" check.
- Swim already has dedicated templates (`sports: ["Swim"]`) for `z2` and
  `intervals`, including a "recovery"-phase "Easy technique swim" variant that
  is just a lower-effort interval set, not drill content — there is no session
  today whose *content* is actually about technique.
- `PlanSession` is persisted via `PlansRepository`/`app_database.dart`
  (SQLite, currently version 6); additive schema changes have twice already
  bumped this version this project (performance-curves → 5, okf-import → 6).

## Goals / Non-Goals

**Goals:** plan generation keeps working, unchanged, for an athlete with no LLM
configured; the numbers in a plan are always the deterministic engine's, never
the model's; AI unavailability or failure degrades to today's behaviour, never
to a failed or blocked generation; the swim technique session is deterministic
in *when* it occurs so it's testable without an LLM, and only its *content*
depends on AI.

**Non-Goals:** AI involvement in the load curve, ramp, periodisation, or which
day a session falls on (all stay in `PlanEngine`, untouched); editing a
session's AI content after generation (the athlete can still only move/remove a
session, per `training-plan`'s existing scope); streaming or showing generation
progress session-by-session; a new settings screen for this feature — it reuses
the existing LLM provider settings as-is.

## Decisions

1. **The content pass lives in `PlanService`, not `PlanEngine`.** A new
   `SessionContentGenerator` (`lib/plan/session_content.dart`) takes the
   `TrainingPlan` `PlanEngine.generate()` already produced and returns a copy
   with `name`/`shortDescription`/`description` possibly rewritten, session by
   session. `PlanEngine` gains no new dependency and stays synchronous and
   I/O-free; its tests are untouched. `PlanService.generate()` calls the
   generator after `PlanEngine.generate()` succeeds, before returning.

2. **One LLM call per plan, not per session.** A plan can have ~40 sessions
   (8 weeks × ~5); one call per session would be slow and expensive. The
   generator builds one compact JSON array of every session's fixed facts
   (index, sport, slot, phase, minutes, load, low-intensity share,
   `techniqueFocus`) and the model's whole job is to return an equally-sized
   JSON array of `{index, name, short_description, description}`. The prompt
   states plainly that minutes/load are fixed and only content is wanted.

3. **Validate, don't trust.** The response is parsed as JSON; an entry is kept
   only if its `index` matches a real session, every field is a non-empty
   string within a length cap (`short_description` ≤ 140 chars, `description` ≤
   2000 chars), and `description` isn't suspiciously short for the session's
   minutes (a floor of roughly one line per 10 minutes planned — not a real
   parse of Intervals.icu step syntax, just a sanity floor). Any session whose
   entry is missing, malformed, or rejected keeps the deterministic content
   `PlanEngine` already gave it — unchanged from today. The whole call is
   wrapped in a single bounded timeout (a fixed budget, e.g. 20s); on timeout
   or any provider error, every session falls back and generation proceeds.
   *Alternative:* fail plan generation on a bad AI response. Rejected — an
   athlete without a reliable LLM must still get a plan, which is also why
   `LlmSettings.isConfigured` is checked first and the call is skipped
   entirely (straight to deterministic content) when nothing is configured.

4. **Swim technique sessions are an engine-level, deterministic flag.** In
   `PlanEngine._buildSessions`/`_addSessions`, the swim `z2` session (not
   `intervals`, which already carries the week's one hard swim effort) is
   marked `techniqueFocus: true` on alternating non-recovery, non-taper weeks
   (`weekIndex.isEven`, phase in `build`/`build_plus`/`peak`) when the goal
   trains swim at all. This needs no new knowledge-file schema and is covered
   by `PlanEngine` unit tests with no LLM involved, like every other placement
   rule. *Alternative:* let the AI decide which weeks get a technique session.
   Rejected per the athlete's own "Hybrid" choice — which sessions exist, and
   when, is the engine's job; only their content is the model's.

5. **Deterministic technique content is a small built-in drill set**, cycling
   through a handful of named drills (catch-up drill, fingertip drag, bilateral
   breathing, high-elbow catch) rendered into the existing step structure
   (`FixedStep`/`FillStep`/`RepeatStep`) as `description` lines, the same way
   `_renderSteps` already turns a template into text — so a technique session
   still looks coached even with no LLM configured, just without the variety
   an AI call adds.

6. **`PlanSession` gains `shortDescription` (non-null String) and
   `techniqueFocus` (bool, default false).** `shortDescription` always has a
   value: the deterministic fallback derives one from `name` (e.g. "$name ·
   ${minutes}min") so nothing in the UI needs a null check. SQLite schema moves
   to version 7 — `plan_sessions` gains two columns (`short_description` text,
   `technique_focus` integer), additive only, matching the project's existing
   migration style.

7. **UI changes are additive.** The week grid tile and Calendar day view, which
   today show only a session's name, add the short description beneath it. The
   existing session detail sheet (`plan_session_sheet.dart`) is unchanged —
   `description` already renders there in full, and will simply read better.

## Risks / Trade-offs

- [LLM latency on every "Generate" tap] → bounded timeout (Decision 3); the
  screen is already behind a busy spinner for this action, and a slow/failed
  call degrades to the same speed as today, not slower indefinitely.
- [Provider cost: a conversational chat model generating ~40 short texts per
  plan] → one call per plan (Decision 2), not per session or per regenerate-on
  every slider drag (plan generation already isn't called on drag — see
  Context); the existing agent already has this cost model for chat.
- [An athlete's workout description changing wording on every regenerate even
  when nothing about the plan changed] → acceptable; sessions already get a
  fresh Intervals.icu event on regenerate/replace per existing `training-plan`
  behaviour, and content, unlike the numbers, is explicitly not meant to be
  stable across plans.
- [Swim-only technique rotation reads as arbitrary] → documented in docs/okf.md
  next to the existing swim templates, same place the "Easy technique swim"
  recovery variant is already explained.
