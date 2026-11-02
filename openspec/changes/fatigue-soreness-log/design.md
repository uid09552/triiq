# Design

## Context

Intervals.icu's Wellness record already has `fatigue`/`soreness` fields
(1-4, "1 good, 4 bad" — see `lib/l10n/app_en.arb`'s
`readinessSubjectiveValues`), and `lib/evaluation/readiness.dart` already
reads them from the cached `LocalWellness.raw` to compute Ready/Caution/Back
off. Nothing in TriIQ writes wellness today — `WellnessRepository` is
read-only, filled only by `SyncService._fetchRange`'s
`listWellnessRecords` call. The Intervals.icu client already has
`WellnessApi.updateWellness(id, date, wellness)`, a `PUT
/api/v1/athlete/{id}/wellness/{date}` that "only changes fields provided"
and returns the updated record — exactly a partial update, no client
regeneration needed.

`lib/screens/activities/activity_detail_screen.dart` (`ActivityDetailScreen`)
is the one place every completed activity, old or new, is already shown,
from Today, Calendar and `PlannedActualCard`. It is currently a
`StatelessWidget`.

See proposal.md for why; this covers how the write path, the two entry
points and the "once per activity" prompt tracking fit together.

## Goals / Non-Goals

**Goals:**
- One write path (Intervals.icu first, then the local cache) used by both
  the manual action and the auto-prompt, so they can never disagree.
- Reuse `WellnessRepository.upsertAll` and `updateWellness`'s own merge
  behavior instead of reading-then-merging wellness fields by hand.
- Keep the auto-prompt's "once per activity" and "day already set" rules
  simple enough to reason about without a server round trip beyond the one
  write itself.

**Non-Goals:**
- A local-only mode for activities without a connection — Wellness lives
  only in Intervals.icu, so the manual action simply requires a connection
  (mirrors how Train Now's "Create in Intervals.icu" disables itself
  offline).
- Changing `readiness.dart` itself; it already reads whatever is in the
  cache.
- Prompting for anything beyond fatigue/soreness (no mood, stress, etc.) —
  out of scope for this change.

## Decisions

- **New `WellnessActions` class** (`lib/data/wellness_actions.dart`) with
  `Future<LocalWellness> setFeel({required String date, required int
  fatigue, required int soreness})`: calls `client.getWellnessApi()
  .updateWellness(id: athleteId, date: date, wellness: Wellness(fatigue:
  fatigue, soreness: soreness))`, then `LocalWellness.fromApi(response)` and
  `WellnessRepository.upsertAll([...])`, then
  `AutoSyncService.instance.notifyCacheChanged()` so every screen listening
  for cache changes (Today, Readiness) picks it up without a resync.
  Throws when not connected; the caller decides how to show that.
  - Alternative considered: read the day's current `Wellness` first, merge
    fatigue/soreness locally, then PUT the whole record. Rejected —
    `updateWellness`'s own partial-update semantics make this unnecessary
    and avoid a race between the read and the write.
- **One dialog, two callers**: a `showFeelDialog(context, {required String
  date, int? initialFatigue, int? initialSoreness})` (in a new
  `lib/screens/activities/feel_dialog.dart`) with two `SegmentedButton<int>`
  rows (1-4 each, "1 good, 4 bad") and a save button that calls
  `WellnessActions.setFeel`. `ActivityDetailScreen`'s manual action and its
  own auto-prompt check both call this one function, so they can never
  drift apart.
- **`ActivityDetailScreen` becomes `StatefulWidget`**: its `initState`
  checks, once, whether to auto-show the dialog (see below); the manual
  action is a plain button that calls the same `showFeelDialog` on tap.
  - Alternative considered: a wrapper widget around the existing stateless
    screen, built fresh at each navigation site. Rejected — every call
    site would need updating, and the screen already has everything
    `initState` needs (`widget.activity`).
- **"New" activity = dated today or yesterday**: there is no "first synced
  at" timestamp on `LocalActivity` distinct from the activity's own date,
  so "recent" is approximated by the activity's own date rather than when
  it was pulled into the cache. This also means turning the toggle on for
  the first time does not resurrect a backlog of old, never-opened
  activities.
- **Prompted-activity tracking**: new `FeelPromptStore`
  (`lib/data/feel_prompt_store.dart`), a `SharedPreferences`-backed set of
  activity ids already auto-prompted — same shape as
  `ThresholdDismissalsStore`, including the `instance` /
  `forTesting()` pattern and `ChangeNotifier`. `initState` checks, in
  order: toggle on, activity date is today/yesterday, activity id not in
  the store, day's cached wellness has no fatigue/soreness — then shows
  the dialog and records the id in the store regardless of whether the
  athlete saves or cancels it.
- **New `FeelSettings`** (`lib/data/feel_settings.dart`), same
  `ChangeNotifier`/`SharedPreferences` shape as `SyncSettings`, one field
  `promptOnNewActivity` (default `true`). A small `SwitchListTile` section
  in Settings, next to the other sync/calendar sections.
  - Alternative considered: add the toggle to `SyncSettings`. Rejected —
    `SyncSettings` is about sync cadence and calendar copying; this is a
    different concern, and a dedicated store keeps it independently
    testable.

## Risks / Trade-offs

- Approximating "new" by the activity's own date (not a true
  first-synced-at marker) means an activity backfilled or corrected to an
  older date after sync would not auto-prompt even if genuinely new to the
  cache → Accepted: rare, and the manual action still covers it.
- The day-already-set check reads the local wellness cache, which could be
  briefly stale right after a sync race (another source sets today's
  wellness moments before the prompt's own check runs) → Accepted: at
  worst a redundant prompt once; saving again simply overwrites with the
  same partial-update semantics, no data loss.
- `ActivityDetailScreen` changing from stateless to stateful touches a
  widely-used screen → Mitigated by keeping `initState`'s added logic to
  the one auto-prompt check; its `build` method and existing behavior are
  otherwise unchanged.
