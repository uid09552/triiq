# Tasks

## 1. Plugin and Android setup

- [x] 1.1 Add WorkManager plugin and any manifest entries; verify `flutter build apk --debug` succeeds (stop and report if the AGP clashes)

## 2. Background run

- [x] 2.1 Implement the background entry point (init DB/key store/session, freshness skip, `syncTodayWindow`, record result); verify unit tests with fake session/sync for fresh-skip, success, network error and 401
- [ ] 2.2 Register/cancel the daily work with network + battery-not-low constraints and the nightly window; verify on a device via `adb shell dumpsys jobscheduler` that one periodic job exists and disappears when disabled
- [x] 2.3 Add failure counter and one-time notification after 3 failures; verify test that it resets on success and does not loop on 401

## 3. Open-sync

- [x] 3.1 Add immediate today-sync on cold start and resume in `AutoSyncService`, honouring single-flight; verify `today_window_test.dart`-style tests for resume and offline cases

## 4. Settings and docs

- [ ] 4.1 Settings → Sync toggle, last-run status, hidden on non-Android, en + de strings; verify widget test and manual check on Android and Windows
- [x] 4.2 Update `docs/okf.md` (Session & sync, status matrix, known gaps) to describe background sync and its Windows limit; verify the old "not a background sync job" wording is gone
