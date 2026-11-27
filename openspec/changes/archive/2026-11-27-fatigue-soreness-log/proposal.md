# Proposal

## Why

Readiness already reads fatigue and muscle soreness (1-4, from each day's
Intervals.icu Wellness record) to decide Ready/Caution/Back off, but TriIQ
has no way to set them — the athlete has to open Intervals.icu itself. The
natural moment to ask is right where an activity already is: on its detail
screen, whether it just synced or the athlete is looking back at an old one.

## What Changes

- **Manual entry, any activity**: the activity detail screen gets a
  "How did it feel?" action that sets that day's fatigue and soreness
  (1-4 each, matching the existing scale) and writes them to Intervals.icu's
  Wellness record for that date via a partial update (only those two fields
  change). Always available, on any activity, old or new. Shows the day's
  current values if already set, editable.
- **Optional auto-prompt for new activities**: a Settings toggle, on by
  default, controls whether the same dialog pops up by itself the first
  time a *recent* activity's detail screen is opened (its date is today or
  yesterday), but only when that day has no fatigue/soreness yet. Shown at
  most once per activity, tracked locally, independent of whether the
  athlete fills it in or dismisses it. This setting is independent of the
  manual action, which stays available either way.
- Successful writes refresh the local wellness cache so Readiness and the
  Readiness screen reflect the new values immediately, without a full sync.
- en + de strings; docs/okf.md.

## Capabilities

### New Capabilities
- `fatigue-soreness-log`: setting an activity day's fatigue and soreness
  from TriIQ, manually or via an optional new-activity prompt, and writing
  them to Intervals.icu's Wellness record.

### Modified Capabilities

None.

## Impact

- `lib/client/intervalls/src/api/wellness_api.dart`'s existing
  `updateWellness` (partial `PUT .../wellness/{date}`) is reused as-is; no
  client regeneration needed.
- `lib/data/repositories/wellness_repository.dart`'s existing `upsertAll`
  caches the server's response locally after a successful write.
- New: a small write-through service (Intervals.icu first, then the local
  cache, erroring without touching the cache on failure — the same order
  `plan_actions.dart` already uses for upstream writes) and a dialog for
  entering fatigue/soreness.
- New: a Settings toggle for the auto-prompt (own small settings store,
  alongside `SyncSettings`/`ThresholdDismissalsStore`) and a local store of
  activity ids already prompted (same shape as
  `ThresholdDismissalsStore`).
- `lib/screens/activities/activity_detail_screen.dart` becomes stateful to
  show the auto-prompt on first build when it applies, and gets the manual
  action.
- Depends on an Intervals.icu connection (no local-only mode; Wellness only
  exists upstream) and feeds the existing readiness evaluation
  (`lib/evaluation/readiness.dart`), unchanged itself.
