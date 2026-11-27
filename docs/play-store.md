# Google Play: release checklist and form answers

Draft answers for the Play Console, derived from what the app does
(see `docs/privacy.md`). Review before submitting; Google's forms change.
Issue #110.

## Technical requirements

| Requirement | Deadline | Status |
|---|---|---|
| Target API 36 | updates since 31 Aug 2026 | `android/app/build.gradle.kts` pins `targetSdk`/`compileSdk` to at least 36; the release workflow fails below 36 (`tool/check_android_release.sh`) |
| 16 KB page size | updates from 1 Feb 2027 | Checked on every release build by `tool/check_android_release.sh` (warns per native library). `sqlite3_flutter_libs` is the most likely offender; update it when the check warns |
| Edge-to-edge (no opt-out on API 36) | now | Flutter ≥ 3.27 draws edge-to-edge; Scaffold handles bars; every bottom sheet sets `useSafeArea: true`. Still to verify on an Android 16 device at 360 dp |
| Predictive back | now | No `WillPopScope` left; routes use `PopScope` |

## Data safety form

**Does the app collect or share user data?** It processes data on the
device. "Collected" in Play's sense means sent off the device by the
developer; TriIQ has no server. Data leaves the device only to services the
user configures (Intervals.icu, their chosen LLM provider, OpenStreetMap
tiles), at the user's request. Declare it conservatively:

| Data type | Collected | Shared | Purpose | Optional |
|---|---|---|---|---|
| Health info (heart rate, HRV, sleep, weight, feel) | Yes, sent to the user's LLM provider when they use the AI trainer | Yes, with that provider | App functionality | Yes (AI trainer is optional) |
| Fitness info (activities, training load) | Yes, as above; read from and written to Intervals.icu | Yes, as above | App functionality | No (core feature) |
| Location (approximate, from routes) | Route maps request tiles from OpenStreetMap; GPS tracks stay on device | No | App functionality | Yes |
| Personal info (name, picture) | Read from Intervals.icu | No | App functionality | No |
| App activity, diagnostics, identifiers | No | No | — | — |

- Data is encrypted in transit: yes (https; plain http only to a local
  server the user sets up, with a warning).
- Users can request deletion: yes — Settings → *Delete all data* removes
  everything on the device; data at Intervals.icu or an LLM provider is
  deleted there.

## Health apps declaration

- **Category**: fitness and training (activity tracking, training planning).
- **Health data accessed**: heart rate, HRV, resting heart rate, sleep,
  weight, subjective wellness, nutrition logged in Intervals.icu (read-only),
  all from the user's Intervals.icu account. No Health Connect access yet
  (see issue #122); when added, each data type needs its own justification.
- **Not a medical device**; it gives no diagnosis. The app and the AI trainer
  say so, and red-flag messages are referred to a doctor.
- **Use of health data**: shown to the user and, when they use the AI
  trainer, sent to the LLM provider they chose, after an explicit consent
  dialog.

## Content and policy notes

- The AI trainer is user-configured (bring your own key/model). AI-written
  text is labelled (see issue #119).
- No ads, no analytics, no in-app purchases.
