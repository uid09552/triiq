# Tasks

## 1. Model and schema

- [x] 1.1 Add `PlanSession.shortDescription` (non-null `String`) and `techniqueFocus` (`bool`, default `false`); update `copyWith`, equality-relevant call sites and every existing construction site; verify `flutter analyze` is clean
- [x] 1.2 SQLite schema v6 → v7: `plan_sessions` gains `short_description` (text, not null) and `technique_focus` (integer, default 0); additive `onUpgrade` step and matching `onCreate`; update `PlansRepository` mapping; verify a v6→v7 upgrade test keeps existing rows readable with sensible defaults

## 2. Deterministic swim technique sessions

- [x] 2.1 In `PlanEngine`, mark the swim `z2` session `techniqueFocus: true` on alternating non-recovery, non-taper weeks (`weekIndex.isEven`, phase build/build_plus/peak) whenever the goal trains swim; verify unit tests: a triathlon plan has at least one technique-focused swim session across 4+ weeks, a Run/Ride-only goal has none, a recovery or taper week never does
- [x] 2.2 Deterministic technique-content fallback: render a small built-in drill set (catch-up drill, fingertip drag, bilateral breathing, high-elbow catch, cycling through sessions) into the existing step structure for a `techniqueFocus` session, plus a deterministic `shortDescription` (derived from name/minutes) for every session; verify unit tests that a technique session's description names a drill and a plain session's output is unchanged from today

## 3. AI content pass

- [x] 3.1 `lib/plan/session_content.dart`: `SessionContentGenerator` taking a `BaseChatModel Function(LlmSettings)` (test seam, mirroring `TrainingAgent`'s `chatModelFactory`), building one prompt + JSON schema covering every session of a `TrainingPlan` (index, sport, slot, phase, minutes, load, low-intensity share, techniqueFocus) and returning a plan with `name`/`shortDescription`/`description` filled in; verify unit tests with a fake chat model for a full valid response
- [x] 3.2 Response validation and partial fallback: reject an entry with a bad index, an empty/oversized field, or a description too short for its minutes; sessions without a valid entry keep the deterministic content from task 2.2; verify unit tests for a malformed-JSON response, a response missing some sessions, and an oversized field
- [x] 3.3 Bounded timeout and provider-error handling around the whole call (single budget for the plan, not per session); skip the call entirely when `LlmSettings.isConfigured` is false; verify unit tests for a provider throwing and for a timeout, both falling back to deterministic content without failing generation
- [x] 3.4 Wire the generator into `PlanService.generate()` after `PlanEngine.generate()` succeeds; `PlanEngine` itself gets no new parameter or dependency; verify a `PlanService` test that a successful AI response changes session text but not `date`/`sport`/`slot`/`minutes`/`load`/`lowMinutes`

## 4. UI

- [x] 4.1 Show `shortDescription` under the name on the week grid session tile and the Calendar day view, wherever only the name is shown today; the detail sheet (`plan_session_sheet.dart`) is unchanged; en + de strings if any new label is needed; verify widget tests for the tile and a manual check on Android/Windows that a long short description doesn't overflow

  Scoped down during implementation: the Plan screen's actual week grid
  (`_SessionTile` in `plan_screen.dart`) is a small icon/minutes/load chip
  with no visible name today, only an accessibility label — added
  `shortDescription` there instead of a new visible line that wouldn't fit.
  The generate-time preview sheet (`plan_preview_sheet.dart`), which does
  show the name as visible text, got a visible short-description line.
  The Calendar day view reads synced Intervals.icu events (`LocalEvent`),
  not `PlanSession` directly, and has no `shortDescription` to show without
  a new per-session lookup; left unchanged and recorded in docs/okf.md's
  Known gaps rather than silently expanding this task's scope. No new
  strings were needed (no new user-facing label, just existing session data
  surfaced further).
- [x] 4.2 Update docs/okf.md: Training plan section (AI content, deterministic fallback, swim technique rotation), status table, Known gaps (e.g. content isn't regenerated for a session already sent to Intervals.icu until the plan itself regenerates); verify the sections match the shipped behaviour
