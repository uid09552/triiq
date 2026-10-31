# Design

## Context

`AutoSyncService` already syncs the month on a foreground timer and on resume (`resumeStaleAfter` 5 min), and `SyncService` is single-flight with `replaceRange` for events. `todayWindow()` is the Monday-Sunday week (+Monday on Sundays). The reminder notification already uses OS alarms on Android. See proposal.md.

## Goals / Non-Goals

**Goals:** closed-app daily sync on Android; cheap; reuse existing sync code; immediate today-sync on open.

**Non-Goals:** sub-daily background polling; Windows/iOS background; push-style updates (Intervals.icu offers none to this client).

## Decisions

1. **WorkManager periodic work (24h, flexible window set to the night)** via a Flutter WorkManager plugin. Alternatives: `AlarmManager` exact alarms (needs special permission, wakes device more), foreground service (battery-heavy). WorkManager honours Doze and constraints.
2. **Constraints:** `NetworkType.connected`, `requiresBatteryNotLow`. Unmetered not required (payload is small); revisit if measured otherwise.
3. **The callback runs in a fresh isolate:** it initialises the DB, `SecureKeyStore`, `IntervalsSession.restore()` and calls `SyncService.syncTodayWindow()` — no UI singletons. Skip if `SyncStateRepository.last_synced_at` is within a configurable freshness window (default 6h).
4. **Open-sync:** on cold start and resume, `AutoSyncService` additionally calls `syncRefreshDay` (today only, bypassing the 5-min month gap but still honouring single-flight and the 10s `refreshMinGap`); the month refresh stays stale-based.
5. **Status:** last run time/result stored in `SyncSettings` (shared prefs; written from the background isolate, read on settings open).
6. **Failure counter** in prefs; notification via existing `NotificationService` after 3 consecutive failures, reset on success.

## Risks / Trade-offs

- [OEM battery savers kill/defer WorkManager] → show last run time so the athlete can see it; document.
- [Isolate init failure (plugins unavailable)] → record failure with reason; foreground sync still works.
- [Concurrent foreground + background writes] → SQLite writes are short; background skips if the cache is fresh; upserts are idempotent.
- [Plugin build break under this AGP] → verify `flutter build apk --debug` first; fallback is `android_alarm_manager_plus`.

## Migration Plan

Additive. On first launch after upgrade the toggle defaults on only once a connection exists; no data migration. Rollback: cancel the registered work on disable/uninstall.

## Open Questions

- Default nightly window (e.g. 02:00-05:00) — pick during implementation; does not change specs.
