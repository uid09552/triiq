# Proposal

## Why

Sync only runs while the app is open, so opening it after a day away shows stale data and the athlete waits on a fetch. The athlete wants data refreshed automatically each night, cheaply for the battery, and today refreshed immediately whenever the app opens.

## What Changes

- Add a **daily background sync** on Android that refreshes the current Monday-Sunday week (plus tomorrow on Sundays), run by the OS scheduler under network and battery constraints.
- **On app open**, sync today's wellness, activities and events immediately (in addition to the existing stale-based month refresh).
- Settings → Sync: toggle the nightly sync, choose its time window; show last background run and result.
- Background run reuses the existing sync path (single-flight, cache writes, `replaceRange` for events) and posts no notification unless it fails repeatedly.
- Windows keeps foreground-only sync (no closed-app wake); documented, not changed.

## Capabilities

### New Capabilities
- `background-sync`: scheduled nightly whole-week sync on Android, battery/network constraints, immediate today-sync on app open, user controls and status.

### Modified Capabilities

None (no specs exist yet under `openspec/specs/`).

## Impact

- Code: new `lib/data/sync/background_sync.dart` (entry point + registration), `main.dart` (init, open-sync), `SyncSettings`, `settings_screen.dart`/`sync_screen.dart`, l10n (en, de), `AndroidManifest.xml`.
- Dependencies: a WorkManager Flutter plugin (Android).
- Docs: `docs/okf.md` Session & sync section (removes "not a background sync job"), known gaps.
