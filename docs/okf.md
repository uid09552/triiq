---
format: OKF (Open Knowledge Format) — a single plain-text, version-controlled
  knowledge file combining app specification, architecture, and user docs.
  Kept in Markdown so it's readable by humans and tools without a special
  parser. See CLAUDE.md for day-to-day dev commands; this file is "what the
  app is and how it's built," not "how to build it."
name: TriIQ
tagline: AI training-analysis app for endurance athletes
status: early skeleton — see the status matrix below
updated: 2026-08-30
stack: Flutter (Dart) + LangChain.dart, no custom backend
---

# TriIQ — Open Knowledge Format

## 1. Specification

### What it is

TriIQ is a client-only mobile/desktop app that connects an athlete's
[Intervals.icu](https://intervals.icu) training data to an LLM (Claude, or
Ollama — Ollama Cloud by default, or a local/self-hosted server), so the
athlete can:

- see today's training and load metrics at a glance,
- browse a calendar of planned vs. completed training,
- review long-term statistics (training stress, volume),
- chat with an AI agent about their own data — progress, readiness, and
  training-plan questions.

### Design principles

- **No custom backend.** The app talks directly to Intervals.icu and to
  whichever LLM provider the user configures. There is no TriIQ-operated
  server in the loop.
- **Local-first.** Training data fetched from Intervals.icu is cached in a
  local SQLite database, so screens read from disk and the app stays usable
  (for previously-synced data) without a live connection.
- **LLM-agnostic.** The user picks Claude or Ollama in Settings; the agent
  layer is provider-agnostic via LangChain.dart, and
  `lib/agent/chat_model_factory.dart` is the only file that names either
  provider.
- **The generated API client is a dependency, not hand-written code.**
  `lib/client/intervalls/` is produced from `openapi.json` and should be
  regenerated, not edited (two documented exceptions aside — see CLAUDE.md).

### External dependencies

| Dependency | Purpose | Auth |
|---|---|---|
| [Intervals.icu API](https://intervals.icu/api/v1/docs.html) (`openapi.json`) | Source of truth for activities, wellness, workouts | HTTP Basic: username `API_KEY`, password = the user's Intervals.icu API key |
| LLM provider (Claude API, or Ollama — Ollama Cloud by default, or a local/self-hosted server) | Powers the chat/agent | Claude: API key. Ollama Cloud: API key (`ollama.com/settings/keys`). Local Ollama: none |

### Status matrix

| Area | Status |
|---|---|
| Navigation shell (top bar, bottom nav) | ✅ Implemented |
| Intervals.icu connection (Profile) | ✅ Implemented — API key is auth-tested against Intervals.icu, then persisted to secure storage and restored on relaunch |
| Local SQLite cache + sync | ✅ Implemented (Today auto-sync, manual Sync screen, nightly background sync on Android) |
| Today screen | ✅ Real data once connected — a compact **header tile** (date badge, today's status — "Ready to train" until something is logged, or "Train with care" / "Take it easy today" in the readiness colour when readiness says Caution / Back off, so the header and the readiness card never disagree, done-vs-planned TSS / time / session count with a hairline progress bar, the refresh button and a ⋯ button; **long-press** or ⋯ opens quick actions: sync now, Train now, log fatigue & soreness, open the calendar on Intervals.icu, customize Today), a readiness card (a 0–100 score ring in the status colour, Ready / Caution / Back off from HRV, resting HR, sleep, form and fatigue/soreness against your own baselines, with small tinted pills for each signal's value plus CTL with its weekly trend, and a detail screen and a hint on hard-session days), six load tiles (TSS today/week, CTL, ATL, Form, Ramp), each with a tiny sparkline inside and a trend arrow (rising / steady / falling: CTL/ATL/Form/Ramp against a week earlier, TSS today as the last 7 days vs the 7 before, TSS week as the last finished week vs the one before), each tappable through to its own chart; optional a slim stacked bar of this week's total training hours (swim/ride/run/other, against the summed targets) above per-sport weekly target rings (swim/cycle/run, set in Settings); activities and planned sessions tappable through to full detail |
| Athlete details | ✅ Implemented — profile picture, location/age, body stats and per-sport thresholds (FTP, LTHR, max HR, threshold pace) from the live Intervals.icu athlete record |
| Activities screen | ✅ Implemented — every cached activity, filterable by sport (from Statistics), tap through to detail with an evaluation against the plan, the streams over time with intervals, "Ask the trainer" and "Open in Intervals.icu"; insights (personal bests, efficiency trend, recovery hint); Weekly review in More |
| New-training pop-up | ✅ Implemented — after the open-time sync, today's sessions not yet seen pop up once (one page each, **OK** marks them seen); switchable in Settings → Notifications |
| Calendar screen | ✅ Implemented — month/week views of TriIQ plan sessions, Intervals.icu planned events (copying switchable in Settings) and completed activities from the cache, colour-coded, tap-through to detail; completed activities in the day list show a small trending-up/down icon when their efficiency factor (Intervals.icu EF) is ≥2% above/below the mean of the previous ≤8 same-sport sessions in the last 42 days (needs ≥3, ≥20 min; otherwise no icon — `lib/evaluation/performance_trend.dart`) |
| Statistics screen | ✅ Implemented — CTL/ATL trend, completed-vs-planned load per week, week/month/year volume and a per-sport breakdown, all from the cache; **Performance** sub-screen (content centred and capped at 840 px on wide windows; the model card shows FTP / CP / W′ / Pmax and the settings value as tiles across its width, with the model-vs-settings gap beneath) with power/pace/HR curves per sport (season vs season, key efforts, model fit vs settings), fetched on open and cached; **threshold suggestions** (derived ride FTP / run / swim threshold pace, Review/Dismiss, a confirm sheet that writes the one changed field to Intervals.icu on Apply, with Undo) |
| Fatigue early warning | ✅ Implemented — a Today card (and `get_fatigue_warning`) when HRV, resting HR, sleep, form, CTL ramp or the fatigue/soreness scores stay off on enough of the last 5 days: **watch** (two signals) or **warning** (three, or HRV/resting HR plus a load or feel signal); "Ask the trainer" or "Not now" (hidden for the day unless it worsens) |
| Morning briefing | ✅ Implemented (Android/iOS) — Settings → Notifications: a notification at a chosen time with today's sessions, readiness (only if the watch data is already in), fatigue level, illness note and form/CTL; prepared from the last sync and re-armed after syncs, plan changes and the nightly background sync |
| Training analytics (Statistics → Training analytics) | ✅ Implemented — all from the local cache, maths in `lib/evaluation/training_analytics.dart`: **fitness by sport** (CTL or ATL per swim/ride/run from each sport's own daily TSS with the 42/7-day model, 180 days of warm-up, plus the total) and a stacked weekly **where your load comes from** chart with per-sport shares; **intensity distribution** (weekly/monthly share of easy / threshold / hard zone time via `intensityOf`, labelled polarized / pyramidal / threshold-heavy / high-intensity with Treff's polarization index, needs ≥ 1 h of zone time); **load safety** (acute:chronic load ratio 7 d/28 d — safe 0.8–1.3, risky ≤ 1.5, too fast above; CTL ramp rate — safe ≤ 5/week, risky ≤ 8; Foster monotony and strain over 7 days — safe ≤ 1.5, risky ≤ 2); **aerobic base** (EF and Pa:HR decoupling for ride/run sessions ≥ 60 min with ≥ 70 % easy zone time, EF least-squares trend per month, decoupling < 5 % solid / 5–10 % developing / > 10 % drifting) |
| Compare (Statistics → Compare, or "Compare with…" on a run/ride's page) | ✅ Implemented — running and cycling only; maths in `lib/evaluation/compare.dart`. **Activities tab**: pick two activities of the same sport; one chart per stream (power, heart rate, speed/pace, cadence, altitude) overlays both on a shared **distance** or **time** axis (blue = A, orange = B; distance is unavailable when either lacks a `distance` stream, fetched on demand by `ActivityStreamsRepository.loadForCompare`), both **courses on one map** in the two colours, and a side-by-side table of the same figures. A shared **tracker**: touching the chart moves a labelled dot for each activity on the map (the position of each at that distance/time), and tapping the map moves the chart's cursor to the nearest point of the closest course; switching axis keeps the tracker on the same moment. **Periods tab**: this block against the previous block of 7/14/28/56 days for runs or rides — sessions, distance, time, elevation, load, pace/speed, power, heart rate, EF, decoupling, easy share with the change between them, plus cumulative distance/time/load by day for both blocks |
| Readiness signals (long-press the readiness card, or the options icon on its detail screen) | ✅ Implemented — choose which of HRV, resting HR, sleep, form and fatigue/soreness count toward readiness (`ReadinessSettings`, `lib/evaluation/readiness_settings.dart`, stored on the device in `shared_preferences` as the switched-off signals; at least one stays on). A switched-off signal is rated `excluded`: it moves neither the status nor the 0–100 score, its pill disappears from the card, and the detail screen lists it greyed as "Not used". `ReadinessService` applies the choice everywhere it is used — Today, the detail screen, the morning briefing, plan adjustments — and the `get_readiness` tool reports only `signals_used` (naming `signals_switched_off`) so the trainer does not base readiness advice on them |
| Durability (Statistics → Performance → Durability, rides and runs) | ✅ Implemented — how much of your fresh power or pace is left after a lot of work. Intervals.icu only serves two predefined fatigued curves, so the levels are computed in `lib/evaluation/durability.dart` from the sessions' own streams: for rides the best 5 s / 1 min / 5 min / 20 min / 1 h power of efforts that *started after* 1,000 / 2,000 / 3,000 kJ of work, for runs the fastest 1 / 3 / 5 / 10 km after 10 / 20 / 30 km already run, taken across the most recent long sessions (rides ≥ 1,000 kJ or 1.5 h, runs ≥ 10 km; last 90/180/365 days, at most 40 sessions, streams fetched once and cached). The fresh reference is the season curve (else last 42 days) from the Performance curves; the screen plots all levels, shows the value and the share kept per point, and says how many sessions it was based on |
| Wellness trends (Statistics → Wellness trends, or "Longer trends" on the readiness screen) | ✅ Implemented — HRV, resting HR, sleep (hours) and weight over 30/90/180/365 days from the wellness cache (`lib/evaluation/wellness_trends.dart`): the daily values, a 7-day trailing average that carries through missing days, a shaded band of the usual range (mean ± 1 SD over the period, needs 14 values), and latest / 7-day average / change against a week earlier with a below / within / above-range note. Metrics can be hidden in the options sheet; a metric with no data has no card |
| Best efforts (Statistics → Performance → Best efforts, rides and runs) | ✅ Implemented — the best 5 s / 1 min / 5 min / 20 min power (rides) or fastest 1 / 5 / 10 km (runs) of every session over the last year, from Intervals.icu's per-activity curves (`activity-power-curves` / `activity-pace-curves`, `lib/evaluation/best_efforts.dart`; cached 6 h in SQLite, the last copy used offline). One line of the best per 30-day window (12 windows) with a second line of the best of the 90 days up to each, for the effort chosen in the options sheet, and a table of the last 30 days against the best of the 90 days before them with the change (green better, red worse; for pace a lower time is better). The pace response is not documented, so it is parsed defensively and not yet checked against the live API |
| Load heatmap (Statistics → Load heatmap) | ✅ Implemented — a calendar grid of daily TSS (one square per day, a column per week, Monday first, scrolled to the latest week), coloured in five steps against the 90th percentile of training days (`lib/evaluation/load_heatmap.dart`); last 12 months, this year or last year, all sports or swim / ride / run; tap a day for its TSS and sessions; total load, training days, longest streak and busiest week below |
| Effort profile (activity page, runs and rides) | ✅ Implemented — from the streams the session diagram already loaded (shared in-flight, no extra download): the **variability index** (Intervals.icu's figure for rides, else normalized over average from the stream; steady ≤ 1.05, some surges ≤ 1.15, very variable beyond), a **histogram** of time at power (25 W bands, 50 W for big sprints) or pace (0.25 m/s bands) with a tap readout and the time not pedalling or stopped, and an **interval table** with duration, power or pace, heart rate, **drift** inside the interval (second half against first, intervals of 2 min or more) and **fade** against the first work interval (`lib/evaluation/activity_extras.dart`) |
| Privacy & data (Settings → Privacy & data) | ✅ Implemented — the in-app privacy notice (what is processed incl. health data, where it is stored, recipients, transfers outside the EU/EEA, legal basis, retention, rights, contact; mirrored in `docs/privacy.md`) with the controls that apply it: **AI consent** (`PrivacySettings`, `lib/data/privacy_settings.dart`, stored with the date on the device) — a configured provider is *not usable* until the athlete agrees, `LlmSettings.isConfigured` requires it, a consent card appears in Chat and Settings, and withdrawing switches the AI off at once; **map tiles** from OpenStreetMap can be switched off (routes then draw without a map); **Delete all data** (`DataEraser`: every table emptied, saved keys and preferences removed, Intervals.icu disconnected). Export is Settings → Backup |
| Offline-first write queue | ✅ Implemented — moving or deleting a sent session, deleting a planned workout, and sending a plan to Intervals.icu while it is unreachable are applied locally at once and stored (SQLite v8 `pending_writes`), replayed in order before every sync, with a "N changes waiting to sync" card on Today and Sync (Send now / Retry / Discard). "Replace with alternative" too: offline it shows the new session at once and queues create-new + delete-old (a retry never creates twice) |
| Home-screen widget (Android) | ✅ Implemented, not yet device-tested — today's planned sessions (two lines, "+N"), completed TSS, form and CTL/ATL, and a ring per sport with a weekly target (swim/ride/run, percent and hours done of the target; the ring stops at 100 %); resizable from 4×1 (one row: session + form) and 2×2 (session + form) up to 4×2 (adds the details) and 4×3+ (adds the target rings), with a layout chosen per size; tap opens the app; refreshed at start, after syncs, on plan changes and after the nightly background sync |
| Trainer memory (More → Trainer memory) | ✅ Implemented — standing preferences ("no hard sessions on Fridays", "swim only mornings") kept on the device and added to the trainer's context every turn; add/remove them in the app, or the trainer saves/removes one via `remember_preference` / `forget_preference` only when you ask it to (marked "saved by the trainer"). Prompt-level: the plan engine does not enforce them |
| Backup (Settings → Backup) | ✅ Implemented — export synced data, plans, knowledge library and settings as one JSON file (share sheet on phones, save dialog on desktop), restore on another device; secrets are never included |
| Season (More → Season) | ✅ Implemented — **fitness forecast** (CTL/ATL/form projected from the planned sessions, with "form on race day" per race), **season timeline** (build / taper / race / recovery blocks across all `RACE_A/B/C` events and the goal's event date, with a conflict check), the **illness / injury mode** card, and the **race predictor** |
| Race predictor | ✅ Implemented — finish time per leg from the pace curves (Riegel) and power curve (race-intensity fraction + physics model), a CTL / race-day-form allowance, a pacing plan and a fuelling plan; swim/ride/run presets from 5 km to 140.6 |
| Illness / injury mode | ✅ Implemented — a `SICK` / `INJURED` Intervals.icu event reshapes the plan: rest (sick) or cross-training (injury), then a graded return ramp; shown on Today and Season, applied only after confirming |
| Route map (activity detail) | ✅ Implemented — outdoor runs and rides show their GPS track on a still `flutter_map` map (start green, finish red) in Activities → detail only; tap for a full-screen map you can pan and zoom. The track is fetched once (`latlng` stream, thinned to ≤ 1200 points) and cached; indoor/virtual rides, other sports and activities without GPS show nothing |
| Brick / transition tracking | ✅ Implemented — a bike→run or swim→bike pair on one day gets a card on Activity detail: transition time, how fast the legs settled, early speed/HR cost |
| Chat screen | ✅ Talks to the agent — streams replies, renders them as formatted markdown (incl. tables), shows which tool is running, starter questions on the empty state, **New chat** to start over; reads the training plan and proposes graph, plan and session changes as cards you **Apply** or **Dismiss** |
| "Train now" | ✅ Implemented — shows today's planned sessions; **Find alternative** (today's session as reference, replace it or add alongside) or **Propose training** when nothing is planned; the agent uses the last 7 days of TSS/CTL/ATL plus the day's done/other-planned TSS and the next day's planned TSS. **Change training** (Calendar plan-session sheet, planned-workout detail) opens it on that session's day with the session preselected |
| Create a planned workout on Intervals.icu | ✅ Implemented — "Create in Intervals.icu" turns the proposal into a structured workout on today's calendar, after a preview |
| Appearance (system/light/dark/developer theme) | ✅ Implemented — Settings → Appearance, applies instantly, persisted |
| Settings — LLM provider | ✅ Implemented — provider, models, Ollama URL, Claude key and Ollama key, all persisted; live Ollama model list + connection test |
| LangChain agent | ✅ Implemented — tool-calling loop over the local cache (`lib/agent`) |
| Knowledge library | ✅ Implemented — More → Knowledge library (Android/Windows): import Markdown/text documents, searched by `get_training_guidance` alongside the optional bundled reference, each match naming its source document; `okf-*` blocks stripped on import so imported text never reaches the plan engine |
| MCP server/client | ❌ Not started — the agent calls its tools in-process instead |
| Training-plan calculation | ✅ Implemented — More → Training plan: goal (Run, Ride or Triathlon with a swim/bike/run mix), 2-16 weeks, a draggable load graph on a TSS axis (80-120% of a proposed +10%/week ramp), a Monday-Sunday calendar per week; a **taper and race week** when the plan ends at the goal's event, with a race countdown on Today; deterministic engine (`lib/plan`) decides every number and date, including a swim **technique session** every other build/peak week; its content (a short description plus the detailed, set-by-set text) is then written by the athlete's configured LLM provider when one is set up, `lib/plan/session_content.dart`, falling back to plain deterministic text otherwise or on any failure; **Take as plan** saves locally and opens the Calendar, sending to Intervals.icu is optional (Settings → Calendar); **plan adjustments** on Today (missed sessions, a week far off its target load, hard sessions on low-readiness days) as Apply / Dismiss cards (`lib/plan/plan_adaptation.dart`) |
| LLM credential persistence | ✅ Implemented — Claude key in the OS vault, the rest in shared preferences |
| Notifications | ✅ Implemented on Android/iOS (incl. daily reminder) and Windows (sync/agent only, no reminder); no-op on web |
| Web platform | ⚠️ Local storage unsupported (SQLite has no web backend wired up yet); UI renders fine |

## 2. Architecture

### Layers

```
 UI (lib/screens, lib/widgets)
   │  reads/writes via
   ▼
 Data layer (lib/data)
   │  IntervalsSession (auth/session + athlete record)
   │  SyncService (orchestrates fetch + cache)
   │  IntervalsWorkoutService (the one upward write: create a planned workout)
   │  Repositories (SQLite CRUD)
   ▼
 Generated API client (lib/client/intervalls) ──▶ Intervals.icu (HTTPS)

 Chat screen ──▶ TrainingAgent (lib/agent)
                   │
                   ├─▶ LangChain chat model ──▶ Claude API / Ollama server
                   │
                   └─▶ TrainingDataTools ──┬─▶ Repositories ──▶ SQLite cache
                                           └─▶ SyncService ──▶ Intervals.icu
```

Today's screens call into `lib/data/`, never into `lib/client/intervalls/`
directly — that keeps the generated client swappable and the SQLite cache as
the single read path for the UI.

### Navigation

`MainShell` (`lib/widgets/main_shell.dart`) is a `Scaffold` with:
- a top `AppBar` whose right-corner avatar button — the athlete's own
  Intervals.icu profile picture once connected, their initial otherwise —
  pushes `ProfileScreen` (connect/disconnect Intervals.icu, link to
  Settings);
- a bottom `NavigationBar` with five destinations, kept alive via
  `IndexedStack`: **Today**, **Calendar**, **Chat**, **Statistics**, **More**.
- **More** is the submenu: Profile, Settings, **Sync**, **Training plan**, plus a disabled
  placeholder for gear.

### Session & sync

- `IntervalsSession` (`lib/data/intervals_session.dart`) is a singleton
  `ChangeNotifier` holding the authenticated `IntervallsClient` plus athlete
  id/name once `connect(apiKey)` succeeds. `connect` is the auth test: it
  builds a client with the given key and calls `getAthleteProfile(id: '0')`
  (the "current athlete" alias) — an actual data fetch, not just a
  request-shape check. Only on success is the key handed to
  `SecureKeyStore` (see **Credential storage** below). `restore()` runs once
  at app startup (fire-and-forget from `main.dart`, after
  `WidgetsFlutterBinding.ensureInitialized()`): it reads any saved key and
  re-runs the same auth test. A key Intervals.icu actively rejects (401/403 —
  revoked or regenerated) is deleted rather than left stale, but a network
  error is *not* treated as a bad key: the key is kept and retried next
  launch, so starting the app offline doesn't cost the user a re-entry.
  `isRestoring` lets the UI (Profile, Today) show a neutral "checking"
  state instead of flashing "not connected" first. `disconnect()` clears
  both the in-memory session and the stored key.
- Once connected, the session also loads the **full athlete record**
  (`getAthlete(id: '0')` → `WithSportSettings`) into `IntervalsSession.athlete`:
  profile picture, city/country, date of birth, current weight and resting
  HR, and the per-sport settings (FTP, indoor FTP, W', LTHR, max HR,
  threshold pace, zones). It is deliberately best-effort — a failure logs and
  leaves the session connected, because none of it is needed to sync.
  `athleteAvatarUrl` resolves the picture (Intervals.icu returns either an
  absolute URL or a site-relative path) and `settingsForSport('Ride')` looks
  up one sport's settings. `AthleteAvatar` (`lib/widgets/athlete_avatar.dart`)
  renders it anywhere an avatar is shown — app bar, Today, athlete details —
  falling back to the athlete's initial.
- `SyncService` (`lib/data/sync/sync_service.dart`) fetches
  `listWellnessRecords` / `listActivities` for a date range and upserts them
  via the repositories. `SyncScope` is `today | month | year | all`, each
  anchored on today's date (`all` uses a fixed 2000-01-01 start — Intervals.icu
  just returns whatever exists in range).
- Planned calendar entries (`listEvents`) are synced alongside wellness and
  activities, into an `events` table. They are written with
  `EventsRepository.replaceRange`, not upserted: a coach reshuffling the week
  *deletes* sessions upstream, and a plain upsert would leave those ghosts
  cached forever.
- The **Today** screen syncs `SyncService.todayWindow()` — Monday..Sunday of
  the current week, extended to tomorrow when today is Sunday. One round-trip
  covers the week's TSS total and tomorrow's session. On open (and on any
  connection change) it uses `syncTodayWindowIfMissing()`, a no-op once
  today's wellness row is cached; pull-to-refresh and the refresh button in
  the header use `refreshMonthWindow()`, which widens the range to the whole
  current month (`SyncService.monthWindow()` — the month, extended when the
  current week or tomorrow spills past its edges). The Calendar and
  Statistics tabs stay alive next to Today in the shell's `IndexedStack`, so
  a refresh that actually fetched also calls
  `AutoSyncService.notifyCacheChanged()` and both reload from the freshly
  filled cache instead of showing last hour's month. A failed fetch does not
  blank the screen — it falls through to the cache and shows the error
  alongside.
- **Pull-to-refresh is bounded** (`refreshRange()`, used by Today and
  Statistics): at most one fetch per `SyncService.refreshMinGap` (10s)
  app-wide, and the gesture stops waiting after `refreshTimeout` (10s)
  rather than spinning on a connection that never answers. The request it
  gave up on carries on in the background and its rows still land in the
  cache for the next load. A throttled-away refresh is not an error: it
  returns `false`, the screen re-reads the cache, and nothing is announced
  to the other tabs.
- **No two syncs run at once.** Every screen holds its own `SyncService`,
  so `syncRange()` coordinates through static state: a request for a range
  already in flight joins that fetch instead of issuing a second one, and a
  request for a different range queues behind whatever is running. Without
  it, a pull-to-refresh landing on top of the background auto-sync would
  fire the same three requests twice over.
- The **Calendar** screen syncs the range it is showing. Navigating between
  months uses `syncRangeIfMissing()` (a month already looked at is free);
  *switching to the tab* uses `syncRangeIfStale()`, which refetches unless
  the cache was refreshed within `SyncService.staleAfter` (1 minute), so
  arriving on the calendar shows current data without a round-trip per tab
  bounce; the refresh button in the header always refetches. The screen
  learns it became visible from the `active` flag `MainShell` passes it —
  `IndexedStack` keeps it alive, so nothing else would tell it.
- `AutoSyncService` (`lib/data/sync/auto_sync_service.dart`) keeps an open
  app fresh: while it's in the foreground it re-syncs the **current month**
  on a timer, throttled to `SyncSettings.autoSyncIntervalMinutes` (Settings →
  Sync, default 5). It stops while backgrounded — there's no reliable way to
  wake a closed app on this schedule; closed-app refreshes are the nightly
  background sync below. It's a `ChangeNotifier` as well as a
  `WidgetsBindingObserver`, because the screens `IndexedStack` keeps alive
  (Today, Calendar, Statistics) don't re-run their own load on a tab switch
  and need telling when fresh data landed behind their back.
- **Opening the app syncs today at once.** On start, on every resume and —
  for a cold start, where the saved key is still being checked — the moment
  the session connects, `AutoSyncService.syncToday()` fetches today's
  wellness, activities and events, ignoring the interval and stale
  throttles (it still joins an identical fetch in flight). It does not stamp
  the month throttle, because today alone doesn't refresh the month.
- **Nightly background sync (Android).** `lib/data/sync/background_sync.dart`
  registers one WorkManager periodic job (24 h period, 3 h flex, so it runs
  between about 02:00 and 05:00 local time) with `NetworkType.connected` and
  `requiresBatteryNotLow`. `BackgroundSyncRunner` (the testable core, wired
  to real storage by `BackgroundSyncRunner.live()` in the background
  isolate) syncs `SyncService.todayWindow()` — the Monday–Sunday week, plus
  Monday when today is Sunday — unless the cache was refreshed within the
  last 6 hours, in which case it makes no request. It restores the stored
  key itself; a network error keeps the key, a 401/403 does not. Outcomes
  and a consecutive-failure counter go to `SyncSettings` (Settings → Sync
  shows the last run and result). The athlete is notified once after three
  failures in a row, and once when the key is rejected; the job always
  reports success to WorkManager so a dead network or revoked key is retried
  the next night, not with backoff. The toggle is in Settings → Sync
  (default on) and registration is re-applied at every launch
  (`ExistingPeriodicWorkPolicy.keep`, so reopening the app never pushes the
  schedule back). **Windows and web have no closed-app wake**: the toggle is
  replaced by a note and sync stays foreground-only.
- **Coming back to the app** is the moment staleness is most visible (the
  athlete just finished a ride and opened TriIQ), so `didChangeAppLifecycleState`
  re-syncs the current month whenever the last sync is older than
  `AutoSyncService.resumeStaleAfter` (5 minutes) — independently of a longer
  configured interval. On a cold start the in-memory timestamp is empty, so
  the check falls back to `SyncStateRepository`'s `last_synced_at`: relaunching
  inside the window doesn't cost a fetch the interval has already ruled out.
- **Creating a workout** from Train now writes upstream and then pulls back
  down the whole month the session landed in (`SyncService.syncMonth`), plus
  the Today window when that reaches past the month's edge, and calls
  `AutoSyncService.notifyCacheChanged()` so the live Today and Calendar
  screens reload from the cache instead of waiting for the next timer tick.
- The **Sync** screen (More → Sync) exposes the same scopes as manual
  buttons, showing the cached activities date range from `SyncStateRepository`.

### The training agent

`lib/agent/` is the chat brain: a LangChain.dart chat model, a set of tools
over the local cache, and the loop that lets the model call them until it can
answer.

| File | Role |
|---|---|
| `llm_settings.dart` | The provider choice, model names, Ollama URL, and both API keys, persisted and shared with Settings |
| `chat_model_factory.dart` | Builds the provider's `BaseChatModel` with the tools bound. **The only file that names Claude or Ollama** |
| `ollama_connection.dart` | `fetchOllamaModels()` — hits `/api/tags` to test a URL/key and list real models. Used by Settings, not by the agent path |
| `system_prompt.dart` | The standing instructions, plus the per-message runtime context block |
| `tools/training_data_tools.dart` | The seven tools the model can call |
| `training_agent.dart` | The tool-calling loop and the event stream the Chat screen renders |

**Why the loop is hand-written.** LangChain.dart 0.9 ships an
`AgentExecutor`, but it drives a `BaseActionAgent` and the concrete
implementations of that were provider-tied and are no longer in the package.
Running the loop directly is ~40 lines, keeps the conversation in native
`ChatMessage`s (so each provider's own tool-call format is used instead of a
stringified scratchpad), and lets partial replies stream to the UI. It stops
after `maxIterations` (8) model turns and carries at most 40 messages of
history, never cutting a tool result away from the assistant turn that asked
for it — both providers reject an orphaned tool result.

**The tools read the cache, not the API.** Answering a question costs no
Intervals.icu round-trips and works offline. `sync_from_intervals` is the
exception, and the model is told to reach for it only when
`get_athlete_context` shows the dates it needs aren't cached;
`get_performance_curve` also fetches, but only the first time a sport/metric
is asked for or after a newer activity of that sport was synced.

| Tool | Returns |
|---|---|
| `get_athlete_context` | Today's date, athlete identity, cached date ranges, and current thresholds per sport |
| `get_daily_metrics` | Per day: CTL, ATL, TSB, ramp rate, resting HR, HRV, sleep, weight, subjective scores |
| `get_plan_adjustments` | The current plan adjustments (missed sessions, week load, readiness conflicts) as **proposals** — the same keyed cards Today shows, so one Apply resolves both |
| `get_readiness` | Today's readiness status, its reasons, each signal's value / baseline / rating and the missing-data state — computed by the same rules as the readiness row on Today (`lib/evaluation/readiness.dart`) |
| `get_activities` | Completed sessions with load, IF, HR, power, decoupling, RPE and time per intensity domain |
| `get_planned_workouts` | Calendar entries: prescribed workouts, races, notes, illness markers |
| `get_training_summary` | Weekly/monthly aggregates: completed vs planned load, per-sport totals, intensity split, CTL/ATL/TSB |
| `get_training_guidance` | Matching sections of the optional bundled reference and every enabled document the athlete imported under More → Knowledge library, each tagged with the document it came from |
| `get_performance_curve` | Best efforts per duration (power, HR) or distance (pace) for one sport — this season, last season, last 42 days — at fixed key points with the session that set each, the model fit (FTP/CP/W'/Pmax or critical speed/D') and its gap to the settings threshold. Fetches from Intervals.icu only when nothing is cached or a newer activity of that sport arrived |
| `get_threshold_suggestions` | Current ride FTP / run / swim threshold-pace suggestions: current and candidate value, percent change, direction and what it's based on. Read-only — the agent explains a suggestion and points the athlete to Statistics → Performance to review and apply it; it cannot apply or dismiss one itself |
| `sync_from_intervals` | Fetches a date range into the cache |
| `get_training_plan` | The saved goal, the load graph per week (proposed/target TSS, share, allowed range, phase, limits exceeded) and the current plan's weeks and sessions with their `session_id` |
| `generate_training_plan` | A plan built by the engine from the goal (and any weeks / load factors / sport mix passed) — plus a **proposal** to take it |
| `propose_load_curve` | A **proposal** for the load graph: week TSS or percent (inside each week's band), recovery weeks, plan length, sport mix, weekly increase (`ramp_percent`), hold weeks, reset — with the resulting graph, or an error naming the allowed range |
| `propose_session_change` | A **proposal** to move a plan session to another date in the plan, or remove it (today onwards only) |
| `get_session_template` | The template behind a plan session, and the block rules |

**Proposals, not writes.** The three proposing tools never change
anything: they register a proposal (`lib/agent/plan_proposals.dart`, in
memory for this app run) and return its `proposal_id`. The agent loop then
emits an `AgentProposal` event and the chat shows a card. Only the athlete's
**Apply** makes the change, through `PlanActions` (`lib/plan/plan_actions.dart`)
— Intervals.icu first, the local plan on success — or, for a plan, the same
preview → **Take as plan** flow as the Plan screen. Each proposal records a
fingerprint of the goal and plan it was made from; if either changed since,
Apply refuses it as out of date. What the athlete did with each proposal is
prepended to their next message so the model builds on the real state.

Threshold suggestions follow the same never-from-chat rule by a different
route: `get_threshold_suggestions` is read-only, and there is no agent tool
that writes a threshold — only the Performance screen's confirm sheet
(**Apply**) does, through `SportSettingsService`
(`lib/data/sport_settings_service.dart`). It's the first TriIQ write that
changes Intervals.icu *settings* rather than calendar data, so the payload
is deliberately minimal (only the one changed field) — see Statistics →
Performance above for the full flow and why that's safe.

Thresholds are a case worth calling out: they aren't cached in their own
right, but every activity carries the FTP/LTHR/max-HR/pace and zone
boundaries that were in force when it was analysed, so the newest activity
per sport *is* the athlete's current setup — no extra API call needed.

Tool results are JSON with nulls and empty collections stripped: an activity
has ~180 possible fields and shipping the empty ones would cost more context
than the data. Bad arguments (a malformed date, a range longer than the tool
returns) come back as an `error` string rather than an exception, because a
sentence is something the model can read and retry around. Every tool caps
its range, and `get_activities` caps its row count, so one call can't blow
the context window.

**Intensity distribution** is the one derived figure. Intervals.icu reports
time-in-zone against the athlete's own 3–7 zone setup; the tools fold that
into the three-domain model the training reference uses (low / moderate /
high), preferring power zone times, then heart rate, then pace. Sessions
with no zone data at all are counted separately rather than silently
dropped, and a bucket where nothing had zone data says the distribution
can't be checked — an 80/20 answer computed from load alone would be
invented.

#### The system prompt

Two system messages per request. The first, `trainingAgentSystemPrompt`, is
fixed and deliberately about *epistemics* rather than physiology:

- **Never state a number that didn't come from a tool** in this
  conversation — no estimates, no remembered examples, no filling gaps with
  typical values.
- **Call `get_athlete_context` first.** Never assume today's date or the
  athlete's thresholds.
- **Ask for the smallest range**, and prefer the summary tool over raw
  activities.
- **Name the gaps** — missing wellness days, rides without power, sessions
  without zone times — rather than answering as if they weren't there.
- **Read the metrics carefully**: CTL is context, not a target; TSB is not
  an overtraining diagnostic; ramp rate has no universally safe value; load
  isn't comparable across sports; a single day of HRV means little, and only
  a convergence of signals over several days does.
- **Answer short**: lead with the answer, then the evidence with units and
  dates, one recommendation, inference labelled as inference.
- **Boundaries**: not a doctor; symptoms, suspected injury, disordered
  eating or low energy availability go to a professional.

The physiology itself is *not* in the prompt — it lives in
`assets/knowledge/training-philosophy.md` (an optional, user-supplied asset
that is not in the repository; see `assets/knowledge/README.md`) and/or
whatever the athlete imported under More → Knowledge library — reached
through `get_training_guidance`. That keeps it editable without touching
code, and keeps a long reference off every single request, which matters
most for the small local models Ollama users run. With neither installed
nor imported, the tool says so and mentions where to import one. Every match
carries the title of the document it came from, and the prompt tells the
model to name it (especially an imported one, so the athlete can tell it's
their own material) and to treat the returned text as information to read,
never as instructions — imported documents are athlete-supplied and
therefore untrusted the same way any other tool result is.

The second message, `buildRuntimeContext`, is regenerated per message and
carries today's date and weekday, the athlete identity, whether Intervals.icu
is connected, which ranges are cached, and the active provider/model. On
Ollama it appends a note to keep tool arguments strict — small local models
drift there far more than Claude does.

### Credential storage

`SecureKeyStore` (`lib/data/secure_key_store.dart`) wraps
`flutter_secure_storage` and is the only place a secret is written. One named
secret per instance: `intervals_api_key` for Intervals.icu, `claude_api_key`
for the Claude API, `ollama_api_key` for Ollama Cloud. Non-secrets — the
provider choice, model names, the Ollama URL — go to `shared_preferences`
instead (`LlmSettings`), because encrypting a hostname buys nothing and the
vault is the thing most likely to be unavailable.
Each platform gets the OS credential vault rather than a file or shared
preferences, and the ciphertext is bound to this app and this OS user:

| Platform | Backend |
|---|---|
| Android | `EncryptedSharedPreferences` — AES-256-GCM under an Android Keystore key (`encryptedSharedPreferences: true`; off by default in the plugin, which would otherwise use its own older scheme). App backup is disabled (`android:allowBackup="false"` plus `res/xml/data_extraction_rules.xml`) because a Keystore-encrypted blob restored onto another device cannot be decrypted anyway |
| Windows | Credential Manager (`CredWriteW`), DPAPI-encrypted under the logged-in Windows account |
| iOS | Keychain, `kSecClassGenericPassword`, with `first_unlock_this_device` accessibility (readable after the first unlock since boot, never migrated to another device) and `synchronizable: false` (no iCloud Keychain) |
| Web | **nothing is persisted** — see below |

Reads, writes and deletes never throw. A vault can be unavailable, locked, or
hold ciphertext that no longer decrypts (Keystore reset); all of those surface
as "nothing stored",
because the recovery is always the same — ask the user for the key again.

On **web** the key is held in memory for the lifetime of the tab and nothing
is written to browser storage. Browsers have no keychain equivalent:
`flutter_secure_storage`'s web backend AES-GCM-encrypts the value into
`localStorage` but stores the raw AES key in `localStorage` beside it, so
anything that can read one can read the other — obfuscation, not storage
security, against XSS, a malicious extension, or anyone with devtools open.
A `HttpOnly` cookie would be the real answer, but that needs a backend to set
it and the app talks to Intervals.icu directly. Profile's help text changes
to say so when `IntervalsSession.remembersApiKey` is false.

### Ollama: cloud vs. local, and the connection test

`LlmSettings.defaultOllamaBaseUrl` is `https://ollama.com` (Ollama Cloud),
not a local server — `isOllamaCloud` checks the URL's host and is what
Settings and `isConfigured` key off of. Cloud needs the API key from
`ollama.com/settings/keys` (Settings has a "Get a key" link straight there,
shown only when `isOllamaCloud`); pointed at a local/self-hosted server
instead, no key is needed and `isConfigured` doesn't require one.

Unlike Claude — whose only cheap way to validate a key is spending tokens on
a real message, so its key just gets saved unconditionally — Ollama's
`/api/tags` is a free connectivity check. `fetchOllamaModels()`
(`ollama_connection.dart`) calls it, so Settings can:
- **test before saving**: pressing "Save key" tests first and only persists
  the key if `/api/tags` succeeds — a bad key is never stored, same
  principle as `IntervalsSession.connect`;
- **list real models**: a successful test replaces the static suggestion
  chips (`LlmSettings.ollamaModelSuggestions`, headlined by the default,
  `gpt-oss:120b`) with whatever the server actually reports, via
  `map['model']`/`map['name']` from each entry in the response;
- **"Test connection"**: a separate button runs the same check without
  saving anything, for a local server (no key to save) or to refresh the
  model list later. Settings also fires this silently (no error surfaced)
  once on open if a connection already looks configured, so a returning
  visit shows live models without the user pressing anything.

An empty-but-200 response (server reachable, nothing pulled yet) is treated
as success, not failure — the distinction that matters here is "reachable"
vs. "not", not "has models".

### Sync verification

`test/sync_live_test.dart` runs the real thing against the live Intervals.icu
API — connect, sync, then read back out of SQLite rather than trusting the
in-memory result — and covers the full-history "Everything" sync. It skips
unless a key is passed, so plain `flutter test` stays offline:

```bash
flutter test --dart-define=INTERVALS_API_KEY=<key>
```

Sync is verified working on Windows: a full-history sync of the test account
pulled 586 activities and 413 wellness records into SQLite, and re-syncing a
range updates rows in place rather than duplicating them (primary keys are the
activity id and the wellness date).

### Local storage

SQLite via `sqflite` (Android native) + `sqflite_common_ffi` +
`sqlite3_flutter_libs` (Windows). Schema v2 (`wellness`, `activities`,
`events`, `sync_state`); v1 caches upgrade in place by creating `events`
empty. See `lib/data/db/app_database.dart`
for the storage-path logic (desktop: `./triiq.db` in the process's working
directory; mobile: app documents directory; web: unsupported, throws).

Schema (version 1):

```sql
CREATE TABLE wellness (
  date TEXT PRIMARY KEY,     -- ISO day, e.g. 2026-08-30
  ctl REAL,
  atl REAL,
  ctl_load REAL,
  atl_load REAL,
  ramp_rate REAL,
  raw TEXT NOT NULL,         -- full Wellness API response as JSON
  synced_at INTEGER NOT NULL
);

CREATE TABLE activities (
  id TEXT PRIMARY KEY,
  date TEXT NOT NULL,        -- start_date_local, truncated to the day
  type TEXT,
  name TEXT,
  moving_time INTEGER,
  distance REAL,
  training_load INTEGER,     -- Intervals.icu's TSS-equivalent for the activity
  raw TEXT NOT NULL,         -- full Activity API response as JSON
  synced_at INTEGER NOT NULL
);
CREATE INDEX idx_activities_date ON activities(date);

CREATE TABLE sync_state (
  scope TEXT PRIMARY KEY,        -- 'wellness' | 'activities'
  oldest_synced TEXT NOT NULL,
  newest_synced TEXT NOT NULL,
  last_synced_at INTEGER NOT NULL
);
```

Later versions add tables without migrating data (each upgrade creates the
new table empty): `events` (v2), `plans` / `plan_sessions` (v3),
`activity_streams` (v4), `performance_curves` (v5: one row per
`sport|metric` holding the raw curves response, the newest cached activity
id of that sport at fetch time — a different newest id means stale — and
`fetched_at`) and `knowledge_docs` / `knowledge_sections` (v6: the knowledge
library — see below). Curves are fetched with a raw `GET
/api/v1/athlete/0/{power,pace,hr}-curves.json?type=…&curves=s0,s1,42d`
through the client's `dio` rather than the generated `listAthlete*Curves`,
which demand three filter lists and deserialize strictly.

Every cached row keeps the full API response in `raw` (JSON), so new UI
features can read additional fields without a schema migration — only
promote a field to its own column when it needs to be queried/filtered on.

**Knowledge library** (`knowledge_docs`, `knowledge_sections`, v6) holds the
athlete's imported coaching documents, nothing from Intervals.icu: one row
per document (`title`, `file_name`, `imported_at`, `enabled`, `byte_size`)
and one row per heading-delimited section (`doc_id`, `position`, `title`,
`body`), split once at import (`lib/agent/knowledge_sections.dart`,
`splitGuidanceSections` — shared with the bundled-reference loader so both
follow the same heading rule) so search stays cheap. `okf-*` fenced blocks
are stripped at import (`stripOkfFences`) and never stored: imported
documents are agent-only and can never reach the plan engine. See
`lib/data/repositories/knowledge_library_repository.dart` and the Training
agent and More sections below.

### Theming

`lib/app.dart` defines one Material 3 theme spec — built twice, for
`Brightness.light` and `Brightness.dark` — from a single seeded
`ColorScheme` and shared component styling (rounded cards/inputs/nav
bar/buttons). UI code should pull colors from `Theme.of(context).colorScheme`
rather than hardcoding `Colors.*`.

Which one is active is controlled by `ThemeController`
(`lib/theme_controller.dart`), a singleton `ChangeNotifier` holding a
`AppThemeChoice` (`system` | `light` | `dark` | `developer`, default `system`; `developer` is a terminal-style theme — black, monospace, green/amber/cyan, square corners — served as the dark theme). `TriiqApp`
wraps `MaterialApp` in a `ListenableBuilder` on it, so changing the mode
(from Settings → Appearance) re-themes the whole app immediately. The choice is persisted
in shared_preferences (`theme.choice`) and loaded at startup in `main.dart`.

### App icon

`assets/icon/` holds the source design — hand-authored SVG, not a
third-party asset:
- `icon.svg` / `icon.png` (1024×1024, full-bleed) — a white heartbeat/pulse
  glyph on the same `primary` → `tertiary` diagonal gradient
  (`#6750E4` → `#F45B8D`) used for the hero cards on Today/Profile. Used as
  the source for iOS, Windows, and web.
- `icon_foreground.svg` / `icon_foreground.png` (1024×1024, transparent) —
  the same glyph scaled down so it stays inside Android's adaptive-icon
  safe zone (the center ~66%, since circular launcher masks crop the most).
  Paired with `adaptive_icon_background: "#6750E4"` (solid, not the
  gradient — Android's parallax effect on adaptive-icon layers reads badly
  with gradients, so this is a deliberate simplification for that platform
  only).

Platform assets (Android `mipmap`/`drawable` + `colors.xml`, iOS
`AppIcon.appiconset`, Windows `app_icon.ico`, web `icons/` +
`favicon.png` + `manifest.json`) are generated, not hand-edited — from the
PNGs, via [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons)
(config lives under the `flutter_launcher_icons:` key in `pubspec.yaml`).
The PNGs are rendered from the SVGs with `sharp` (Node; a local install,
not a project dependency — no Dart-ecosystem SVG rasterizer was available).
There's no `macos/` or `linux/` platform folder in this project currently,
so those icon targets are skipped; re-run `dart run flutter_launcher_icons`
after any of:
- editing `assets/icon/*.svg` (re-render to PNG first — see below),
- adding those platform folders back,
- `flutter create .` regenerating platform folders (it resets icons to the
  Flutter default).

To re-render the PNGs after editing an SVG (from the repo root, with Node
available):

```bash
node -e "
const sharp = require('sharp');
sharp('assets/icon/icon.svg', {density: 384}).resize(1024,1024).png().toFile('assets/icon/icon.png');
sharp('assets/icon/icon_foreground.svg', {density: 384}).resize(1024,1024).png().toFile('assets/icon/icon_foreground.png');
"
dart run flutter_launcher_icons
```

(`npm install sharp` first, in whatever directory you run that from — it
doesn't need to be inside this repo.)

### Notifications

`lib/notifications/` — sync completion, agent replies, and a daily training
reminder. Same per-platform-backend pattern as `SecureKeyStore`, because no
single plugin covers this app's platforms:

- `notification_service.dart` — `NotificationService.instance` picks the
  backend at construction: `flutter_local_notifications` on Android/iOS
  (all three notification kinds, including the daily reminder — scheduled
  through the OS alarm system via `zonedSchedule`, so it fires even with the
  app closed); `local_notifier` on Windows (immediate notifications only —
  sync/agent — since there's no reliable way to wake a *closed* desktop app
  on a schedule without native work well beyond this feature's weight); a
  no-op elsewhere (web). `supportsScheduledReminder` tells the UI whether to
  offer the reminder toggle at all.
  - The daily reminder's "local time" is a `tz.Location` built from
    `DateTime.now().timeZoneOffset` at init, **not** a real IANA zone —
    `flutter_timezone`, the obvious package for that, currently fails to
    build on Android under this project's AGP version (a
    project-evaluation-order clash in its Gradle setup). A fixed offset is
    wrong only in the narrow window right as DST flips, self-correcting on
    the next app start, which is an acceptable trade against a dependency
    that doesn't build. Worth revisiting if a fixed version resolves it.
- `notification_settings.dart` — `NotificationSettings.instance`
  (`ChangeNotifier` + `shared_preferences`, same shape as the
  non-secret half of `LlmSettings`): whether notifications are enabled at
  all, and the daily reminder's enabled flag + time.
- `app_lifecycle_tracker.dart` — a `WidgetsBindingObserver` registered in
  `main()`, so `isForeground` is readable from plain Dart code. The agent-
  reply notification only fires when this is `false` — otherwise the reply
  is already visible in the chat bubble and a notification would just be
  noise.
- Settings → **Notifications**: the master toggle calls
  `requestPermission()` (the actual OS prompt on Android 13+/iOS; a no-op
  `true` elsewhere) before persisting `enabled`; a denied prompt leaves the
  toggle off with an explanatory SnackBar. The daily-reminder sub-toggle and
  time picker only render when both `enabled` and
  `supportsScheduledReminder` are true.
- Trigger points: `SyncScreen._run()` fires `showSyncComplete` after a
  manual sync; `ChatScreen._finish()` fires `showAgentReply` when a reply
  completes without error, the app isn't foreground, and notifications are
  enabled.

Android manifest additions this needed: `POST_NOTIFICATIONS` (the
permission the runtime prompt is asking about), `RECEIVE_BOOT_COMPLETED`
plus `flutter_local_notifications`'s two receivers (so the reminder alarm
survives a reboot), and `android/app/build.gradle.kts` needed
`isCoreLibraryDesugaringEnabled = true` + a `coreLibraryDesugaring`
dependency (`flutter_local_notifications` requires it). The reminder is
scheduled `inexactAllowWhileIdle` specifically to avoid needing
`SCHEDULE_EXACT_ALARM`, a user-granted special permission that's overkill
for a training reminder's precision needs.

Not yet done: Windows build untested (Android is — a debug APK with this
feature builds and the manifest/Gradle changes above are what made it
work); iOS untested on either count, consistent with iOS's general status
in this repo (builds, isn't a focus).

### Activities

`lib/screens/activities/` — the full activity list and the detail view,
both reading straight from the SQLite cache (no separate network call).

- `activities_screen.dart` — `ActivitiesScreen`: `ActivitiesRepository.getAll()`
  (added alongside the existing `getByDate`/`getRange`), most recent first,
  rendered as `ListTile` rows rather than a literal `DataTable` — a table
  widget doesn't fit this app's card/list visual language or a phone
  width, and a `ListTile` row (icon, name, date · distance · duration,
  trailing TSS) carries the same information at a glance. Tapping a row
  pushes `ActivityDetailScreen`.
- `activity_detail_screen.dart` — `ActivityDetailScreen(activity: LocalActivity)`.
  `LocalActivity` only promotes a handful of fields to SQLite columns (see
  Local storage); this screen needs far more (HR, power, elevation, zone
  times), so it calls `LocalActivity.toActivity()` — `Activity.fromJson(raw)`
  — to get the *entire* API response back as a typed `Activity`, rather than
  either widening the schema or hand-parsing JSON keys. `_StatGrid` builds
  its tiles from whichever of those fields are actually non-null (a swim
  has no power, a strength session has no distance), and `_ZoneTimeChart`
  is a small hand-rolled horizontal-bar widget — this app has no charting
  package, and one bar shape didn't justify adding one — fed from
  `icuZoneTimes` (self-labelled) falling back to `icuHrZoneTimes` (plain
  seconds-per-zone, labelled generically Z1..Zn) when present.
  - **Open in Intervals.icu**: `launchUrl('https://intervals.icu/activities/{id}',
    mode: LaunchMode.externalApplication)` via `url_launcher`. Deliberately
    `externalApplication`, not the default: that mode hands the link to the
    OS the same way tapping it anywhere else would, so it opens the
    Intervals.icu app if one's installed and registered for that link
    (Android App Links / iOS Universal Links), and the browser otherwise —
    this app doesn't need to know which.
  - **Fatigue & soreness**: a button next to Open in Intervals.icu opens
    `showFeelDialog` (`feel_dialog.dart`) — two 1-4 fields, "1 good, 4 bad",
    prefilled from the activity's day's cached wellness when already set.
    Saving calls `WellnessActions.setFeel`, a partial `PUT
    /wellness/{date}` that only touches those two fields, then refreshes
    the local wellness cache from the response so Readiness picks it up
    without a resync. Needs an Intervals.icu connection (Wellness lives only
    there); the button is disabled otherwise. Settings → **Fatigue &
    soreness** (`FeelSettings`, on by default) controls whether this dialog
    also opens by itself the first time a *recent* (today or yesterday)
    activity's detail screen opens, when that day has nothing set yet —
    shown at most once per activity (`FeelPromptStore`, the ids already
    prompted), regardless of whether it's saved or cancelled. Turning that
    setting off only stops the automatic prompt; the button keeps working.
- Reached from **More → Activities**, from tapping any activity in Today's
  "Today's activities" card (`_TodayActivities` in `today_screen.dart`), and
  from a sport row on Statistics, which passes `ActivitiesScreen(initialType:
  ...)` to open the list filtered to that sport. The filter is in-memory over
  the cached rows and shows as a chip under the app-bar title; clearing the
  chip goes back to every sport.
- `activity_icons.dart` — shared formatting/icon helpers (`activityTypeIcon`,
  `formatIsoDate`, `formatDurationSecs`, `formatDistanceMeters`) used by
  both screens and by Today, so the three don't drift.
- **Insights** (`lib/evaluation/insights.dart`, `lib/screens/insights/`).
  `personalBests(raw)` reads `icu_achievements` defensively (unknown shapes
  are dropped, a power best needs its duration); `efficiencyTrend` compares
  an easy session's `icu_efficiency_factor` with the median of the same
  sport's easy sessions over the last 42 days (needs ≥ 4);
  `recoveryHint` maps TSS to hours via the knowledge `recoveryHours` bands,
  adds 12 h when form is below `recoveryFormPenaltyBelow`, caps at 72 h and
  flags a conflict when recovery runs past 10:00 tomorrow and tomorrow's
  planned session is hard (only for today's session).
  `SessionInsightsLoader` gathers the inputs; `InsightsCard` renders them
  under the diagram on `ActivityDetailScreen`, which also marks today's
  session as seen.
- **New-training pop-up.** `AutoSyncService.openSyncDone` fires after the
  today-sync run on start, connect and resume (not after periodic syncs).
  `NewTrainingTrigger` (wrapping `MainShell`) then asks
  `NewTrainingInsights.unseenToday()` — today's activities minus
  `SeenSessionsStore` (prefs `insights.seen`, today's ids only, reset on a
  new day) — and, if any and the shell's route is current, shows
  `NewTrainingSheet`: one page per session, newest first, with the
  evaluation and insights. Closing it marks every shown session as seen.
  **Details** opens the activity; **Find alternative** (recovery conflict)
  opens Train Now for tomorrow (`TrainNowScreen(today: ...)`).

### Charts

There is no charting package. The shapes the app needs all live in
`lib/widgets/charts/`:

- `SimpleBarChart` (`bar_chart.dart`) — vertical bars with an optional
  translucent "ghost" bar behind each one for a target, tap/drag selection,
  and an x-label every n-th bar. Used for daily TSS (42 bars, weekly labels)
  and weekly completed-vs-planned load.
- `MetricLineChart` (`line_chart.dart`) — one or more series on a shared
  y-scale, with gridlines and their values, an optional filled area under
  the lead series, an optional rule at zero (Form and ramp rate cross it),
  and selection. `null` entries are **gaps, not zeroes**: a day with no
  wellness record is not a day of zero fitness, and joining across it would
  draw a slope that never happened. `ChartLegend` renders the key.
- `DurationCurveChart` (`duration_curve_chart.dart`) — performance curves on
  a **log** x-axis (duration for power/HR, distance for pace) with fixed
  ticks, axis titles with units, several periods as series, and tap/drag
  selection that snaps to the nearest point. Pace is plotted as speed so
  faster sits higher and labelled back as min/km or min/100 m. Points are
  thinned to ~200 log-spaced buckets (`downsampleLog`) before painting.

A package would be a dependency, a theme to fight and a licence to check for
something that is a few dozen lines of `CustomPainter` either way. Both take
their colours from the active `ColorScheme`, so they follow the app theme
(and dark mode) without a second palette to maintain. The older
`_ZoneTimeChart` on the activity detail screen predates these and stays
where it is — it's a horizontal one-off.

### Load metric screens

Every tile on Today opens something:

| Tile | Opens | Shows |
|---|---|---|
| TSS today | `TssHistoryScreen` | 42 daily bars, completed against planned, with total / avg per day / avg per week |
| TSS week | `WeeklyLoadScreen` | 12 weekly bars, completed against planned, this week's total, 12-week average, 4-week trend |
| CTL, ATL, Form, Ramp | `MetricHistoryScreen(metric:)` | the metric over 30/90/365 days as a line (CTL and ATL charted against each other), with current / change / average / low–high, and a plain-language note on what the metric does and doesn't say |

`MetricHistoryScreen` is one screen for four metrics (`LoadMetric`), and Form
is derived (`CTL - ATL`) rather than stored — Intervals.icu doesn't return a
TSB field. The range picker changes only what is charted; nothing on these
screens fetches, so they are instant and work offline.

### Creating workouts on Intervals.icu

`IntervalsWorkoutService` (`lib/data/intervals_workout_service.dart`) is the
only place in the app that *creates* something upstream — everything else
syncs downwards — which is why it sits apart from `SyncService`. It POSTs an
`EventEx` (`category: WORKOUT`, today's date at local midnight, sport, name,
description, duration, load) via `createEvent(upsertOnUid: false)`.

The workout itself goes in `description` in Intervals.icu's **native step
syntax** (`- 15m 60%`, `3x`, …), which Intervals.icu parses server-side into
a structured workout; anything it can't parse it keeps as the session's
description, so an odd line degrades to a note instead of failing the
request. The app deliberately does not try to validate that syntax locally.

Getting there from a prose proposal is two steps, in `TrainNowScreen`:

1. `workoutStructuringPrompt` (`lib/agent/workout_draft_parser.dart`) asks
   the *same* agent conversation to re-express what it just proposed as one
   JSON object, with the workout in step syntax. A second turn rather than
   part of the original prompt: the athlete reads the prose first and only
   pays for this if they decide to keep it.
2. `parseWorkoutDraft` locates the JSON object in the reply — models wrap it
   in prose or a code fence more often than not, so it scans for the
   outermost `{…}`, tracking brace depth and ignoring braces inside strings —
   and returns `null` rather than a guess when there's nothing usable.

The draft is then shown in full (name, targets, every line of the workout)
in a bottom sheet before anything is written: creating an entry in someone's
training log isn't undoable from this app, and the step syntax is the
agent's work, not the athlete's. After a successful create, the Today window
is re-synced so the new session appears immediately.

## 3. User documentation

### Connecting your Intervals.icu account

1. Tap the profile icon (top-right).
2. Find your API key on intervals.icu under Settings.
3. Paste it into **Intervals.icu API key** and tap **Connect**. This
   validates the key live against Intervals.icu (an actual data fetch, not
   just a format check) and shows your athlete name once successful. Only a
   working key is saved — a rejected one is never written to storage.
4. Once connected, the key is remembered in your operating system's own
   credential store (Keystore-encrypted storage on Android, Credential
   Manager on Windows) across app
   restarts — the app re-validates it on every launch and reconnects
   automatically. **Disconnect** clears both the session and the saved key.
   In the browser build the key is only kept for that tab: browsers have no
   comparable secure store, so you re-enter it after a reload.

### Charts

The hand-painted charts in `lib/widgets/charts` are interactive. Line charts
(`MetricLineChart`: CTL/ATL/form history, Statistics, readiness) and the
session stream chart zoom by pinch, double tap (3×, again to reset) or
Ctrl + mouse wheel; the y-scale refits to the visible window, one finger
scrubs a tooltip and pans once zoomed, and a button resets. Every series gets
a dashed **Ø average** line over the visible window (streams also show their
averages above the chart); curves are monotone-smoothed. Bar charts draw a
dashed Ø line at the mean. The shared zoom/pan logic is `chart_viewport.dart`.

**Activity chart.** The session diagram on an activity (`StreamChart`) has
labelled axes: the first selected stream on the left, the second on the
right (round tick values, in the stream's colour), a time axis, dashed Ø
lines, a peak marker and a crosshair with a time chip. Zoom with pinch,
double tap, Ctrl + wheel or the +/− buttons; an overview strip under the
chart shows the window and moves it by tap or drag. Tapping a detected
interval zooms to it, and a 10 s / 30 s smoothing switch calms noisy power
(averages and the readout always use the raw samples).

### Events

More → **Events** lists races (A/B/C), notes, holidays, sick/injured markers,
targets and season starts from a month back to a year ahead
(`lib/screens/events`). The **+** button and tapping an entry open the editor
(type, name, date, optional end date for holiday/sick/injured/target, sport for
races, description); the trash button deletes. Intervals.icu is the source of
truth: `IntervalsEventService` (`lib/data/intervals_event_service.dart`)
creates/updates/deletes there via `createEvent` / `updateEvent` / `deleteEvent`
and mirrors the result into the `events` cache. `SyncService.syncEventsHorizon()`
refetches that whole span (independent of "Copy planned events"); the
**nightly background sync** runs it after the week sync
(`BackgroundSyncRunner.syncEvents`), opening the screen refreshes it when
older than an hour, and pull-to-refresh forces it.

### Deleting planned sessions

Deleting a planned session (the trash button in the Calendar day list, the
detail screen, or the long-press on a day / Today's training) removes it
everywhere (`planned_workout_actions.dart`): on Intervals.icu (already gone
counts as deleted), in the event cache, and in the TriIQ plan — a plan
session, or the plan session an Intervals.icu event was created from, so it
cannot reappear as a local-only session. A plan session that was sent needs a
connection; one that only lives in TriIQ can always be deleted. Afterwards
the affected day is refetched from Intervals.icu (`syncRange(day, day)`), so
the cache matches the calendar upstream.

### Ask the trainer

Every "Ask the trainer" entry point hands Chat a `ChatTopic` through
`askTrainer()` (`lib/screens/chat/ask_trainer.dart`): the topic's context goes
to the agent as system context, its **draft** lands in the Chat input field
ready to send or edit (never sent for the athlete), and the shell switches to
the Chat tab. Entry points: an activity's evaluation, the weekly review,
the readiness card, a Today tile's long-press sheet, and the Analysis
screen's app-bar button (period, filters and per-metric statistics as
context).

### Analysis

More → **Analysis** (`lib/screens/analysis`) is a Power BI–style workbench over
the cached data. Selectors: period (30/90 days, 6 months, 1 year, this year,
custom range), sport (all/swim/ride/run — filters the activity metrics),
resolution (day/week), rolling average (off/7/14/28 buckets), min/max
markers, a ±1 σ band, and the metrics to chart (TSS, hours, distance, CTL,
ATL, form, ramp rate, HRV, resting HR, sleep). Each metric is its own graph on
one **shared x-axis**: zoom/pan (pinch, +/−, Ctrl+wheel) moves all graphs
together (one `ChartViewport`), and tapping a point puts the crosshair at the
same moment in every graph and lists all values in a card on top. Per graph:
Ø, min and max with dates, σ, and Δ first→last (`series_stats.dart`).
Activity metrics are summed per bucket (0 on rest days); wellness metrics are
averaged (gap when missing). Week buckets start on Monday.

### Year goals

Settings → **Year goals**: a yearly distance goal (km) per sport (swim, ride,
run), stored by `YearGoalsSettings` (`shared_preferences`; blank = no goal).
Right under the fields, and on Today as the "Year goals" section (switchable
and reorderable; "Show on Today" in the same Settings card), a progress bar
per sport shows km so far against the goal with a tick where an even pace
would be today, the percentage, how far ahead/behind that pace is, and the
year-end projection at the current pace (`YearGoalsProgress`). It counts the
calendar year's activities cached on the device, so sync the year (Settings →
Sync) for complete numbers.

### Today

**Weekly-target rings.** Long-pressing a ring opens a sheet
(`week_activities_sheet.dart`) listing this week's activities of that sport
(date, duration, distance, TSS); the "All sports" chip widens it, and a row
opens the activity.

**Load tiles.** The six tiles (TSS today / week, CTL, ATL, form, ramp rate) are
compact `StatTile`s (`compact: true`): icon badge beside label and figure,
animated value changes, soft hover/press states. Resting a mouse on a tile
opens a floating graph card automatically (`HoverPreview` +
`MetricPreview`: 14 daily-load bars, 8 weekly bars, or a 30-day filled line
with its Ø). Long-press (touch) opens a sheet with the plain-language
explanation, the zoomable graph, "Show history" and "Open in Intervals.icu".

**Customize / delete.** The "Customize Today" button at the bottom opens a
sheet (`customize_today_sheet.dart`) to drag the sections below the hero
(readiness, adjustments, load tiles, weekly targets, threshold suggestions,
activities, today's/tomorrow's training, athlete) into any order and switch
each off; stored by `TodayLayoutSettings` (`shared_preferences`). Long-pressing
today's planned training — or the selected day's card in the Calendar —
offers to delete all of that day's Intervals.icu planned sessions
(`confirmAndDeleteDaysWorkouts`); TriIQ plan sessions are left to the Plan
screen.

Shows today's date's cached data: a hero card with today's date and a
summary of today's activity/activities (or "Ready to train" if none), a
readiness row, six load tiles, a "Today's activities" card, today's and tomorrow's planned
training, and an athlete card. Pull to refresh (or the refresh button in the
hero) re-syncs the whole current month, so the Calendar and Statistics tabs
are current too when you switch to them. Repeating the gesture is cheap: it
never starts a second fetch next to one already running, does nothing at all
within 10 seconds of the last one, and stops waiting after 10 seconds if the
network doesn't answer. The first time this screen loads after connecting,
it automatically fetches and caches today's data if it isn't already stored
locally.

**The tiles.** TSS today and TSS week each show what was planned underneath
("of 420"); CTL, ATL, Form and Ramp each show how far they've moved since
the same day last week. Tap any of them for the chart behind it — daily TSS
bars, weekly completed-vs-planned bars, or the metric's own curve over 30,
90 or 365 days with a note explaining what it means. Nothing there fetches,
so it all works offline.

**Weekly targets.** Below the tiles, a ring per sport (swim/cycle/run) with
a weekly target set in Settings → Weekly targets, each showing this week's
achieved training time against that target — percentage in the middle,
hours below ("3.0 / 2.0 h"), coloured the same way the rest of the app
colours that sport, and switching to a "done" colour once the target is
met or passed (the ring itself never overshoots a full circle). A sport
with no target shows no ring, and the whole row disappears when no sport
has a target, or when **Show on Today** is off in Settings. Achieved time
comes from this week's already-cached activities (the same ones behind
the TSS-week tile), so it works offline and needs no training plan.

**Plan adjustments.** When the saved plan and what you did drift apart, a
**Plan adjustments** card lists suggestions, each with **Apply** and
**Dismiss**. Nothing changes until you apply one:

- **Missed session** (an earlier day this week with no activity of that
  sport): an interval or long session can be **caught up** on the earliest
  later training day this week that isn't full and doesn't sit next to
  another hard day. If no day fits, or for a Z2 session, the suggestion is to
  **let it go**, which removes it from the plan (and from Intervals.icu if it
  was sent).
- **Week far off target** (the week that just ended came in under 80 % or
  over 120 % of its target): next week's load-graph share drops so the ramp
  restarts from what you actually did, or so it doesn't climb past last
  week's target. It stays within the graph's 80-120 % band, and the card
  says when the 80 % floor held it up. The week's sessions change when you
  regenerate the plan.
- **Low readiness on a hard day** (Caution or Back off with intervals or a
  long session today): swap it with the next Z2 session this week, or move it
  to the next fitting day.

A dismissed suggestion stays dismissed, even after a restart. A suggestion
disappears by itself once it no longer applies, for example when a late
watch upload shows you did the session after all. The chat's trainer offers
the same cards when you say you missed something.

**Readiness.** The row above the tiles says **Ready**, **Caution** or **Back
off** for today and why ("Due to HRV, Sleep"). It is worked out on the
device from today's Intervals.icu wellness record: HRV and resting HR against
your own normal over the previous 60 days (a signal needs at least 14 days of
values before it counts), last night's sleep, form (CTL − ATL) and the
fatigue/soreness you logged — from an activity's detail screen (see
Activities above) or directly in Intervals.icu. Any back-off signal, or two cautions, means Back
off; one caution means Caution. If your watch writes its own readiness
figure, the detail screen shows it next to the status but doesn't use it.
Without a wearable you get "No wellness data" (and a status from form
alone); before today's data has arrived, "Waiting for today's data". Tap the
row for each signal's value, normal range and rating and a 30-day HRV /
resting-HR trend. When the status isn't Ready and today has an interval or
long session, a **Consider an easier day** card appears; **Ask the trainer**
opens the chat with the question filled in. Nothing changes the plan by
itself. The thresholds are defaults in §5.1, not medical advice.

**The athlete card** shows your Intervals.icu profile picture and, once your
sport settings have loaded, your ride and run FTP. Tap it for the full
athlete view: picture, where you are, your age, your latest weight, resting
HR and HRV, and your thresholds per sport — FTP, indoor FTP, W', LTHR, max
HR and threshold pace. Each row says where the number came from: your
current Intervals.icu sport settings, or the most recent activity that was
analysed with it.

Tap any activity in "Today's activities" for its full detail view — see
Activities below. Tap a planned session in "Today's training" or
"Tomorrow's training" for its own detail view (`PlannedWorkoutDetailScreen`
— prescribed duration/distance/TSS and the workout description, the
not-yet-happened counterpart to an activity's detail screen). That screen
also offers **Add to Google Calendar** (pre-filled, all-day unless the
session has a time of day) and **Delete**, which removes it from
Intervals.icu after a confirmation.

If Intervals.icu isn't connected and/or no LLM provider is configured yet, a
**Finish setting up** card appears with a button straight to Profile and/or
Settings — so a first launch isn't just a wall of "not connected" labels.

### Calendar

Toggle between **Month** and **Week** views. Each day shows a tiny icon per
session — tertiary-coloured for Intervals.icu planned events, secondary for
TriIQ plan sessions, primary for completed activities — reading planned
items from `PlannedItemsRepository` (`lib/data/planned_items.dart`: the
current plan's sessions plus, when Settings → Calendar copies them, the
cached `events`; a sent session shows once, as its synced event) and
completed ones from `activities`. Today and Statistics read planned load
from the same source. A plan session in the day list says whether it was
sent to Intervals.icu and opens its steps; it is managed on the Plan screen
(no delete here). Data is read from the local cache the same
way Today does, syncing the visible range from Intervals.icu if it isn't
cached yet, and refetching it when it has gone stale (see the sync notes
above; the header's refresh button forces it). On Today, **long-pressing the "nothing planned" line** of today's (or tomorrow's) training offers *Propose training* — Train now for that day — and opens it. **Sick and injured days, holidays, notes, races, targets and season starts** (Intervals.icu events) are shown on every day they cover — an icon in the month cell (sick/injured days tinted), a line in the week view, a row on the day card (tap to edit) — whatever the "copy planned events" setting. **Long-press a day** (cell or day card) for a sheet with **Propose training**, **Add event** (a second menu picks the kind — sick, injured, holiday, note, race A/B/C, target, season start — and opens the event editor with that day and kind preset) — Train now for that day, so the created session lands on it (future days and today) — next to *Delete day's training*. The day card is slim: the date (with a Today pill) and done-vs-planned TSS with a hairline progress bar, then one compact row per session — duration and load on every row, a check on a planned session a same-sport activity covers. Tap a day to see its planned
and completed sessions below the grid/list; tap one of those to open its
full detail (`PlannedWorkoutDetailScreen` or `ActivityDetailScreen`).

Planned sessions carry a **delete** button in that day list, and the same
action sits on their detail screen — both go through
`confirmAndDeletePlannedWorkout` (`lib/screens/activities/planned_workout_actions.dart`):
a confirmation dialog, then `IntervalsWorkoutService.deletePlannedWorkout`
(the API's `others: false`, so a session created as part of a plan doesn't
take the rest of the batch with it), then `EventsRepository.deleteById` and
`AutoSyncService.notifyCacheChanged()` so every live screen drops it without
a refetch. Completed activities have no delete: they are a record of what
happened, not a plan to change.

### Chat

Ask the training agent about your own data — "how was last week", "am I
recovered enough for intervals tomorrow", "is my intensity distribution
actually 80/20". It answers from the locally cached Intervals.icu data,
reading it through tools rather than guessing: while it works, a line under
the transcript names what it's doing ("Reading your daily load and
wellness…"), and the reply streams in as the model writes it.

Set up a provider in **Settings → LLM provider** first; until then the
screen says so, with an **Open Settings** button straight there. What the
agent can see is limited to what's been synced, so sync the range you want
to ask about (it will offer to sync a missing range itself when connected).
Replies render as formatted markdown — headings, lists, and tables with
borders and bold headers — rather than raw source. An empty chat offers a
few starter questions you can tap instead of typing.

The agent can also work on your **training plan**: ask "what's on this
week?", "make week 4 a recovery week", "move Saturday's long ride to
Sunday" or "build me a 10-week triathlon plan". It reads the plan first,
then **proposes** the change — a card under its reply shows what would
change (a small load graph with the changed weeks highlighted, or the
session's old → new date) with **Apply** and **Dismiss**. Nothing changes
until you tap Apply: a graph change is saved into your goal (the Plan
screen updates at once), a session move or removal also changes it in
Intervals.icu when it is there (that needs a connection and **Send plan to
Intervals.icu** on), and a plan opens the plan preview, where you take it.
A card made before you edited the graph or plan says it is out of date
instead of overwriting your edit; a failed apply shows why and offers
**Retry**. Proposals last until the app restarts.

**New chat** (top right of the transcript) clears the conversation and the
agent's own memory of it, after asking — the next question starts from
scratch. Conversation history lives in memory only either way: it's gone
when the app restarts.

### Train now

From Today, tap **Train now**. If anything is planned for today — a TriIQ
plan session or (when copied) an Intervals.icu event — it is shown first
under **Planned today**: sport, name, duration, TSS, where it comes from
(*TriIQ plan* with a sent / only-in-TriIQ icon, or *Intervals.icu*) and its
steps (long ones collapse; **Show all steps**). With two or more, tap one
to choose which you want an alternative for. The main button then reads
**Find alternative**: sport, duration and intensity start from the chosen
session (you can change them), and the agent gets that session as its
reference — aim for a similar training effect and load, unless your recent
load says otherwise. With nothing planned the button reads **Propose
training** and works as before.

**Change Training** reaches the same screen, preselected on one specific
session, from wherever that session is shown: Calendar's day detail, the
Plan screen's week grid (any week, not just the current one), and Today's
own "Today's Training" / "Tomorrow's Training" cards. For a TriIQ plan
session, these open straight into a quick sheet with **Change Training**
right there; a synced Intervals.icu event on Today still opens the fuller
planned-workout screen first, which also has the button.

Otherwise, pick a sport (run/ride/swim), duration and
intensity (recovery/endurance/intervals), then **Propose training**. This
sends the same [training agent](#the-training-agent) a prompt built from
those choices, instructed to check the last 7 days of TSS/CTL/ATL/ramp rate
with its own tools before proposing — so a fatigued week gets a lighter
prescription, not a canned template. The proposal streams in as markdown,
same rendering as Chat; **Ask again** re-runs it. Needs an LLM provider
configured, same as Chat.

Once a session has been proposed there are two ways to keep it:

- **Create in Intervals.icu** puts it on today's calendar as a real planned
  workout. The agent first converts what it proposed into Intervals.icu's
  workout syntax, and you get to see the whole thing — name, sport, duration,
  estimated TSS and every step — before anything is written; **Create** does
  it, anything else cancels. Intervals.icu turns those steps into a
  structured workout, and whatever it can't parse stays as the description.
  Afterwards the app re-syncs, so the session appears on Today and Calendar
  straight away. Needs Intervals.icu connected.

  For an alternative, the preview also asks **Replace today's session**
  (default) or **Add alongside**. Replacing a TriIQ plan session changes
  that session in place — same plan, week and date — so the Plan screen
  and Calendar show the new one; if it was in Intervals.icu, the new
  workout is created there and the old event deleted (this needs a
  connection and **Send plan to Intervals.icu** on, otherwise it is
  refused rather than leave the old one behind). A session that is only in
  TriIQ is changed locally, also offline. Replacing an Intervals.icu event
  creates the new workout, then deletes the old one; if that delete fails
  you are told both now exist. When the agent's workout has no TSS, the
  session keeps its old TSS, marked as estimated. **Add alongside** leaves
  the planned session as it is.
- **Add to Google Calendar** opens a pre-filled event in your browser
  instead, for when you just want it in your day.

### Statistics

Everything over a window you choose — 30 days, 90 days or a year:

- **Fitness trend** — your CTL and ATL curves against each other.
- **Completed vs planned** — one bar per week, actual load in front of the
  planned load behind it. Tap a bar for that week's numbers.
- **Volume** — distance and time for this week, this month and this year to
  date.
- **By sport** — sessions, time, distance and load per sport over the
  window, with each sport's share of your total training time. Tap a sport
  to open the Activities list filtered to it (rows for activities with no
  type don't open anything — there is nothing to filter by).

It all reads the local cache, so the range picker is instant and works
offline; pull to refresh to re-sync the current month first. If a chart is
empty, the range simply hasn't been synced yet — use **More → Sync** to
fetch more history.

**Performance** (the card at the top of Statistics) answers "am I getting
faster?". Pick Ride, Run or Swim and a metric — power and heart rate are
your best average over every duration, pace your fastest time over every
distance (running power only shows if you have any). The chart compares
this season, last season and the last 42 days on a log axis; tap or drag it
to read the value at a point, with the date and name of the session that
set it and **Open session**. **Key efforts** lists 5 s / 1 min / 5 min /
20 min / 60 min (run pace: 400 m … half marathon; swim: 100 … 1500 m) per
season with the change; an empty cell means no effort that long, nothing is
interpolated. **Model fit** shows what Intervals.icu fits to this season
(FTP, CP, W', Pmax — or critical speed and D' for pace) next to the
threshold in your Intervals.icu settings, and the gap.

Curves are fetched from Intervals.icu the first time you open a sport and
metric, then kept on the device: they are fetched again only once a newer
activity of that sport has been synced (or with the refresh button). A
failed fetch keeps the saved curves on screen with **Retry**.

**Threshold suggestions**, above the sport/metric picker, turns that gap
into something you can act on. From the cached curves it derives a
candidate ride FTP (this season's power-curve model fit), run threshold
pace (your best ~60-minute effort, or the ~40-minute effort scaled toward a
sustainable pace when that's all there is) and swim CSS (`(t400 − t200) /
2` per 100 m from your 400 m and 200 m bests) — only ever from efforts in
the last 90 days. A card appears when a candidate beats your current
setting by 3% or more (raise it), or when the last 42 days' own data is at
least 5% below it (**likely dropped**) — never from missing or sparse data.
**Dismiss** hides it for 30 days, unless the underlying number moves a
further 3% in the meantime, in which case it comes back. **Review** opens a
sheet with the current and new value, the zone ranges each implies, an
opt-in to also recalculate HR zones, and a note that past activities keep
their recorded load; nothing is sent until you tap **Apply**. A failed
update keeps the old value and says so; a successful one offers **Undo**,
which writes the previous value back the same way. The write itself sends
only the one changed field — proven safe by a live test
(`test/sync_live_test.dart`) that checks Intervals.icu treats the request
as a partial update, not a full replace, before this shipped. The same
cards (minus Review/Dismiss specifics) appear on Today when a suggestion
exists. Indoor FTP is never touched; the sheet says so when you have one
set.

### More

Submenu for Profile, Settings, **Sync**, **Activities**, **Training
plan**, **Weekly review** and **Knowledge library** (hidden on web), plus a
disabled placeholder for gear.

**Knowledge library** (More, Android/Windows only) lets you import your own
Markdown or plain-text coaching documents — swim sets, taper notes, articles
you trust — from the device's file picker, so the chat agent can search them
alongside (or instead of) the bundled reference, without a rebuild. **Import**
(toolbar) splits each file into sections at `#` headings, the same rule the
bundled reference follows; a file with none becomes one section named after
the file. The result says how many sections were added and how many
structured (`okf-*`) blocks were dropped — those never affect your plan,
only the chat's reference material. A file over 512 KB, not valid UTF-8, or
empty is rejected with the reason and nothing changes. Importing a file with
the same name as an existing document asks **Replace** or **Keep both**
(suffixing the new one with the import date). Each document in the list
shows its title, source file, section count and import date, with a switch
to turn it off (kept, just not searched) and a delete button (confirms
first). An empty library explains what it's for. On web there's no local
database yet, so the entry is hidden and the agent uses the bundled
reference only.

**Weekly review** (More) takes one week at a time (arrows to move): each
day's planned and done sessions with missed ones marked, the share of
planned sessions done and the planned versus done TSS, the week's 80/20
split with a flag when easy time is below the tolerance (and how many
sessions had no zone data), the load against the 4-week average and the
CTL / ATL / form change. It is computed from the cache and works offline.
With an LLM provider set up, a short **Next week** note from the trainer
follows, labelled as an inference; **Discuss in Chat** carries the week's
figures over.

### Season, forecast, race predictor, illness mode and bricks

**More → Season** has three cards. *Fitness forecast* runs the standard 42-day
CTL / 7-day ATL model forward from the last synced values over the planned
sessions (TriIQ plan sessions and Intervals.icu events; empty days are rest),
and — beyond the last planned session, where the calendar is empty — assumes you keep training at your current fitness (daily load = CTL) so fitness does not decay to zero; it says from which date. It states **form on race day** for every upcoming race with a plain-language
reading (still loaded / balanced / fresh / fading). *Season timeline* lays out
each race (Intervals.icu `RACE_A/B/C`, plus the training goal's event date as an
A race): a taper before it (A 14 d, B 7 d, C 2 d), the race day and a recovery
after it (10 / 5 / 2 d), with build between. The **conflict check** flags two A
races under 42 days apart, a race inside another's taper or recovery window,
two races on one day, and a race inside a logged illness / injury. *Race
predictor* opens the predictor.

**Race predictor** (`lib/season/race_predictor.dart`). Run and swim times come from your
best efforts on the pace curves (Riegel, exponent 1.06; open-water +3 % in a
triathlon). The ride finds the duration at which the power curve's best
effort, scaled by a race fraction (97 % up to 1 h, 72 % by 6+ h, a further
−7 % in a triathlon), produces the speed that takes that long (CdA 0.32, Crr
0.005, 9 kg bike, climbing work from elevation gain). The run after a ride is
3–12 % slower. Past ~1.5 h an allowance of up to 15 % applies when CTL is far
below what the event needs, plus 1–1.5 % for arriving very loaded or very
rested. Legs without curve data are named, never guessed. The **pacing plan**
starts 3–5 % easier and (≤ 12 km) finishes slightly faster; the **fuelling
plan** gives carbs/fluid/sodium per hour by duration (0 under ~45 min up to 85 g/h
over 3 h), the day-before and pre-race carbs per kg, and an intake schedule
(bike every 20 min, run every 30). It is a model estimate, not a promise.

**Illness / injury mode** (`lib/season/illness_mode.dart`). Log a `SICK` or `INJURED`
event in More → Events (with an end date once it is over). While it lasts and
for a graded return afterwards (3 / 7 / 14 / 21 days by length, ×1.5 for an
injury) TriIQ proposes: **sick** — rest instead of every planned session;
**injured** — the affected sport becomes easy cross-training (45 TSS/h);
**return** — load climbs linearly from 50 % to 100 %, hard sessions in the first
half become easy. Races are never touched. Nothing happens until you press
*Apply* (Today banner or Season); changes go upstream to Intervals.icu first
and fail safe. The chat agent can read the proposals (`get_health_status`) but
not apply them.

**Bricks** (`lib/season/brick_analysis.dart`). A bike→run or swim→bike on the same day,
with the second starting within 45 min of the first ending, is a brick.
Activity detail shows the transition time, and for bike→run — from the run's
stream — how long the legs took to reach 95 % of steady speed, the first 10
min against the rest, and the heart-rate cost per speed early on, as a
good / decent / rough verdict with reasons (e.g. a hard bike). Chat tools:
`get_fitness_forecast`, `get_health_status`, `get_race_prediction`, `get_bricks`.

### Trainer memory and backup

**Trainer memory** (`lib/agent/agent_memory.dart`, More → Trainer memory). Up to 30
short preferences (200 characters each, duplicates ignored) in shared
preferences. Every chat turn gets them as a system block of *preferences, not
instructions*: the trainer respects them when suggesting or changing
training, says so when one shapes an answer, and flags a clash with safety or
the data instead of ignoring it. The trainer saves one only when you state or
ask for it, says it did, and it appears in the list tagged "saved by the
trainer"; you can delete any item or all of them. It is advice-level: the plan
engine and adaptation rules do not enforce a preference (set training days
and long/interval days in the goal for that).

**Backup** (`lib/data/backup/`, Settings → Backup). *Export* writes one JSON file
(`format: triiq-backup`, `version: 1`) with the tables wellness, activities,
sync_state, events, plans, plan_sessions, knowledge_docs and knowledge_sections,
plus the settings stored in shared preferences (goal, targets, theme, language,
trainer memory, …) — except the LLM connection settings (`llm.*`: provider, server URL,
models), which are device setup and must never be redirected by a backup file; optionally the re-fetchable chart caches (activity
streams, performance curves). Excluded always: the Intervals.icu key and the
AI keys (OS vault) and device-runtime keys (background-sync status). On
phones the file goes to the share sheet (Drive, Files, mail); on desktop to a
save dialog. *Restore* validates the file (format, version not newer than the
app, core tables present, only plain values), shows what it holds, and after
confirmation **replaces** the synced data, plans and knowledge library in one
database transaction — a bad row rolls everything back. Unknown columns from
a newer schema are skipped. Settings are applied afterwards; restart the app
to pick them up, and reconnect Intervals.icu (Profile) on the new device.

### Offline queue and home-screen widget

**Offline queue** (`lib/data/pending_writes.dart`). `QueuedWorkoutWriter` wraps the
Intervals.icu writer. When a delete or move cannot reach the server (no
network, timeout, no connection) it is stored and the caller carries on — the
local plan or cache already shows the change. Plan sends are queued too
(`PlanWriter` reports them as `queued`, not failed); at send time the queued
create re-reads the plan session, so a session moved or deleted meanwhile is
sent as it is now, or dropped. `PendingWritesService.flush()` runs before every
sync (so the fetch that follows reflects it), stops at the first write that
still cannot reach the server, retries a rejected write up to 5 times (4xx
other than 408/429 fails at once) and then parks it as *failed* for Retry or
Discard. A 404 on delete/move counts as done. Events with a delete waiting are
kept out of sync results so they don't reappear. Not queued: replacing a
session with an alternative and Train Now's create — they need the created
event back, so they still ask for a connection.

**Home-screen widget** (Android; `lib/data/home_widget_data.dart`,
`TriiqWidgetProvider.kt`, `res/layout/triiq_widget.xml`). Long-press the home
screen → Widgets → TriIQ. It shows today's planned workouts, what was done
(TSS), form (CTL − ATL) with CTL/ATL, and the update time; tapping opens the
app. Flutter writes the strings through the `home_widget` plugin; the native
provider only lays them out.

### Fatigue early warning and morning briefing

**Fatigue early warning** (`lib/evaluation/fatigue_warning.dart`). Where
readiness rates one day, this asks whether the same signals have stayed off.
Over the last 5 days a signal *fires* when: HRV is more than 1 SD below your
60-day baseline, or resting HR 4+ bpm above it, on 3 days; sleep is under 6.5 h
on 3 nights; form is −25 or lower on 3 days; CTL ramps 8+/week on 2 days; or
fatigue/soreness is rated 3–4 on 2 days. Days with no value (a wearable's 0)
don't count, and a signal needs 3 days of data (HRV/resting HR also 14 days
of baseline). **Warning** — three signals, or HRV/resting HR together with a
load or feel signal; **watch** — two signals, or HRV/resting HR alone on four
days. One bad night never triggers it.

**Morning briefing** (`lib/notifications/morning_briefing.dart`). Enable under
Settings → Notifications (needs notifications on; Android/iOS). Android/iOS can
only fire a pre-written notification, so the text is a snapshot of the cache
when it was armed — at app start, after every sync, on plan changes and after
the nightly background sync. It lists the day's planned workouts, readiness
(only when today's wearable data is already in and the briefing is for
today), the fatigue level, a note if you are logged sick or injured, and form
with CTL.

The work **intervals** under the session diagram are collapsed ("Intervals (n)"); tap the header to open the list, tap an interval to zoom the diagram to it.

### Route map

The activity detail of an outdoor run or ride (`hasRouteMap`: run or ride
family, not virtual / trainer / treadmill) shows a **Route** card after the
session diagram: the GPS track from Intervals.icu's `latlng` stream drawn with
`flutter_map` over OpenStreetMap tiles (© OpenStreetMap contributors shown on
the map). The card's map is a still picture so it never steals the page
scroll; tapping opens a full-screen map with pan and zoom. The track is
fetched the first time (not as part of sync), thinned to ≤ 1200 points and
cached in SQLite beside the diagram streams (`route:<id>`; an activity with
no GPS is remembered as empty). **Moving the mouse (or dragging a finger) over the session diagram marks the same moment on the map** with a highlighted dot — the track is stored with the elapsed seconds of each point (`time` stream), and a track cached before that is fetched once more. Offline, or without GPS, the card simply
doesn't appear. Tiles come from `tile.openstreetmap.org` with the app's
user agent; that server is for light use, so if TriIQ is distributed widely
point `_tileUrl` in `route_card.dart` at a tile provider with an API key.

### Releases

`.github/workflows/android-release.yml` builds the signed Android APK and
publishes it as a GitHub release.

- **Merge to `main`** → automatic **pre-release**, tagged
  `v<version>-rc<short commit hash>` (e.g. `v0.9.0-rc1a2b3c4`). `<version>` is the
  `x.y.z` of `version:` in `pubspec.yaml` (now `0.9.0+1`); bump it there to start
  a new line. Put `[skip release]` in the merge commit message to skip it.
- **Your own tag** (`git tag v1.0.0 && git push origin v1.0.0`) → a release for
  exactly that tag, built with that version; a tag containing `-` is a
  pre-release.
- **Manual run** of the workflow → only an APK artifact, no tag or release.

**Clean-up:** `.github/workflows/cleanup-prereleases.yml` runs daily (03:17 UTC) and
deletes the automatic `v<x.y.z>-rc<hash>` pre-releases published more than 3 days ago,
together with their tags — the newest one always stays, however old. Pre-releases you tagged yourself (e.g. `v1.0.0-beta1`) and
normal releases are never touched. Run it by hand to try it — "dry run" (the default for
manual runs) only lists what it would delete.

The APK's version name is the tag without the `v`; its version code is the
workflow run number. Signing secrets: see the header of the workflow.

### Swim steps: `m` is minutes, `mtr` is metres

In Intervals.icu's step syntax a bare `m` after a number is **minutes**; metres are
`mtr`. A swim written as `- 300m Warm up` is read as five hours (a 30-minute session
came out as 19 h). The structuring prompt and the plan-content prompt now tell the model
to write swim distances as `mtr`, and as a safety net `fixSwimDistanceUnits`
(`lib/data/intervals_steps.dart`) rewrites `300m` → `300mtr` for swims — when the
description is parsed (Train now / the trainer) and again right before any workout is
created in Intervals.icu — but only when reading the `m` as minutes would make the steps
add up to far more than the session's duration (or, without a duration, when a single step
would be 100+ minutes). Minute-based swims (the plan engine's templates) and paces such as
`1:45/100m` are never touched, and `mtr` is never converted twice.

### Where data lives, and where keys go

- **Database**: on Android/iOS in the app's documents folder; on Windows in the per-user
  app-data folder (`getApplicationSupportDirectory`, e.g. `%APPDATA%\…\triiq\triiq.db`).
  Earlier versions wrote `triiq.db` into the working directory, which depends on how the
  app is started (a shortcut can make it the read-only install folder); on first start the
  old file is moved over once, and an existing database is never overwritten.
- **Keys**: Intervals.icu, Claude and Ollama keys are kept in the OS vault. The **Ollama
  key is an Ollama Cloud key and is only ever sent to `https://ollama.com`** — never to a
  self-hosted server and never over plain http (saving a key for another server URL is
  refused with an explanation).
- **Plain http**: on Android cleartext is allowed only so a self-hosted Ollama server on
  your own network (`http://192.168.…:11434`) works
  (`res/xml/network_security_config.xml`); Intervals.icu, Anthropic, Ollama Cloud and
  OpenStreetMap stay https-only. Settings warns under the server URL when it is `http://`.
- **Offline writes belong to an account**: each queued write is tagged with the
  Intervals.icu athlete it was made for (the connected one, or the last one connected on
  this device). Without a known account nothing is queued and the error shows; a write for
  another account is dropped instead of sent; disconnecting in Profile clears the queue.
- **Charts** select on touch-down, so a quick tap no longer waits ~300 ms for the
  double-tap (zoom) window.

### Training plan

**More → Training plan.** Set a **goal** first: target (long distance or
short event), sport (Run, Ride or **Triathlon**), training days, weekly
hours, an optional event date, and the **plan length** (2-16 weeks; by
default 8, or the weeks up to and including the event week; a chosen length
can't run past the event, and an event in the starting week is too close
for a new plan). For triathlon, set the **sport
mix** — each sport's share of the weekly load in 5% steps, totalling 100%
(default Swim 15 / Bike 50 / Run 35). A sport at 0% gets no sessions.

**Weekly load** is a graph with one point per week on a **TSS axis**. The
dashed line is the proposed load: a ramp from your recent weekly load (mean
of the last 4 weeks), held flat when it would need more than your weekly
hours or raise CTL faster than the ramp limit. Set the **weekly increase**
with the slider above the graph (0–15%, default 10%); with **Hold every 4th
week** on (the default) weeks 4, 8, 12… keep the previous week's load
instead of ramping. Both redraw the proposal at once and are saved in the
goal; weeks you dragged keep their share of the new proposal. No recovery
dips are added for you. Each week has a shaded band — 80% to 120% of its
proposal — that it can be moved within.

**Taper and race week.** When the plan ends in the event week, its last
weeks step down from the last build week — two weeks at 70% and 50% for
long distance, one at 60% for a short event — and the graph labels them
**Taper** and **Race** (no ramp or CTL warning for the drop; you can still
move them 80-120%). Taper weeks keep the interval session, shorter, and cut
the long session most. In the race week nothing is planned on the event day
or after it, and the day before gets short **Race openers** when it is a
training day. Today shows **Race in N days** while the plan is active. An
event more than 16 weeks away gets a 16-week block without a taper, and the
load graph says when a taper block can be made.

The goal editor also sets the **session mix** — Z2 / Intervals / Long
shares of each sport's weekly load (5% steps, total 100%; by default the
goal type's mix, with a button to go back to it). An interval session never
grows beyond what its template's repeats allow, and a hard mix shows up in
the week's 80/20 warning. **Preferences**: a long-session day per sport
(long ride and long run on different days), preferred interval days, and the
most sessions per day (1 or 2). Unticking a training day drops the
preferences on it. Placement uses preferred days when they are free; when a
week can't, its card says which preference it missed.

- **Drag** anywhere in a week's column, up or down. The point moves with
  your finger (it doesn't jump to it), snaps to 5 TSS with a small
  vibration, and a label shows the week, TSS, share of the proposal and the
  change from the week before. On a phone with many weeks the graph scrolls
  sideways; a sideways swipe scrolls, an up/down drag edits.
- **Tap** a week to select it, then use **−/+** (5 TSS each) or the arrow
  keys on Windows (5 TSS, Shift 25 TSS; left/right to change week).
  **Undo** reverts the last change; **Reset** (after a confirmation) puts
  every week back on the proposal.
- A week more than 10% below the week before it becomes a **recovery
  week** (recovery sessions, shorter long session).
- A week you push above the weekly ramp, the CTL ramp limit or your hours
  turns red and says which; it is a warning, not a block. Returning to the
  proposal after a dip is not counted as a jump.

The graph is saved into the goal (as each week's share of the proposal) as
you edit it, so a sync that changes your baseline moves the TSS with it.
**Generate plan** builds exactly what the graph shows and opens a preview
of every session; nothing is saved until you tap **Take as plan**. That
stores the plan in TriIQ, closes the Plan screen and opens the **Calendar**
tab at the plan's first week, where the sessions show straight away
(marked *TriIQ plan*). With **Send plan to Intervals.icu** on (Settings →
Calendar) they are then created there in the background; a snackbar
reports the result and offers **Retry** for any that failed. Planning works
without an Intervals.icu connection: enter a typical weekly load in the
goal and the plan stays in TriIQ. Each plan week then shows its target against planned
(or done) TSS, the load per sport for triathlon, the 80/20 split, any
warnings, and a **Monday-Sunday row** of its sessions as sport-coloured
tiles (minutes and TSS; tap one for its steps). Triathlon weeks hold at
most two sessions a day by default (your limit if you set one) with the long ride and long run on different days;
with few training days Z2 sessions are dropped first.

**AI-authored session content.** Every number — date, sport, slot, minutes,
load — is always the deterministic engine's; separately, each session's
name and description (a short one-line summary, shown next to the name
where the preview and the week grid otherwise show only it, and a detailed
set-by-set description, as today) are written by whichever LLM provider
you've configured in Settings → LLM provider (Claude or Ollama). No
provider configured, a slow or failing one, or a response that doesn't
parse: generation still succeeds, and the affected sessions keep the
engine's own plain text instead — nothing about plan generation requires an
LLM. In a swim-including plan, the swim Z2 session on every other build/
build_plus/peak week is a **technique session** (named drills — catch-up
drill, fingertip drag, bilateral breathing, high-elbow catch — instead of
plain effort percentages); which weeks get one is always the engine's
choice, never the model's.

### Activities

Every cached activity, most recent first — filtered to one sport when you
arrive from a sport row on Statistics, with a chip you can clear to see the
rest. Tap one for distance, duration,
TSS, elevation, heart rate, power, calories (whichever of those the
activity actually has), and a time-in-zone chart when zone data is
present. **Open in Intervals.icu** at the bottom goes to that activity's
full page on intervals.icu — for what this screen doesn't show (the map,
power curves, comments).

**Evaluation.** Above the time series, the session is judged against the
planned session it matches (same day and sport; of several, the nearest in
duration): **On target**, **Too hard**, **Too easy** or **Cut short**, always
with the figures behind it — e.g. "45 of 60 planned minutes", or "planned
easy, but 33% of the time was above the first threshold (limit 25%)" — and
planned versus actual minutes and TSS. The intensity split folds the zone
times into low / moderate / high (the same folding the agent uses); without
zone times it says the split can't be assessed rather than guess. Aerobic
decoupling is shown only for a steady session of an hour or more. All of
this is code (`lib/evaluation/session_evaluator.dart`); thresholds follow
the 80/20 rule in the training knowledge. **Ask the trainer** opens Chat
with the session and its evaluation attached (shown as an "About: …" chip,
not as a message).

**Over time.** The power, heart-rate, speed, cadence and altitude streams
are fetched from Intervals.icu the first time you open an activity and
cached in SQLite (`activity_streams`), so later opens work offline. Toggle
streams with the chips; each is drawn on its own scale, work intervals are
shaded, and pressing or dragging shows every stream's value at that moment.
Long rides are downsampled before painting. Detected intervals are listed
with duration and average power / HR / pace. A manual entry without
streams says so; a failed fetch offers **Retry**. A planned session's detail
screen shows **Done: …** with planned versus actual when an activity
matched it.

**Insights.** Below the diagram: new personal bests from this session (with
the previous best when known), for an easy session its efficiency against
your recent easy sessions of the same sport ("+4% vs. the last 6 weeks", or
too few sessions to say), and for today's session roughly how long recovery
takes. When that runs into a hard session planned for tomorrow, **Find
alternative** opens Train now for tomorrow.

**New training pop-up.** When you open the app and the sync brings in a
session from today you haven't looked at, it pops up once: one page per
session (swipe between them) with its evaluation and insights. **OK** closes
it and it won't show again; opening the session's detail counts too. Turn it
off under Settings → Notifications.

### Settings

- **Appearance**: pick System, Light, or Dark. Applies instantly across the
  whole app; resets to System on restart (not persisted yet).
- **Notifications**: the master toggle prompts for the OS notification
  permission (Android 13+/iOS) and, once granted, turns on sync-completion
  and training-agent-reply notifications. With it on and on a platform that
  supports scheduling (Android/iOS — not Windows), a **daily training
  reminder** toggle and time picker appear underneath.
- **Sync**: how often the open app refreshes the current month, and (Android)
  the **nightly background sync** switch. With it on, TriIQ refreshes the
  current week once a night, even when closed — only with a network and a
  battery that isn't low — and shows when it last ran and how it went. Opening
  the app always fetches today straight away. On Windows the app only syncs
  while it is open.
- **Calendar**: two independent switches, both on by default.
  **Send plan to Intervals.icu** — off keeps taken plans in TriIQ only;
  turning it back on offers to send the current plan's upcoming sessions
  that aren't there yet. **Copy planned events from Intervals.icu** — off
  stops every sync (manual, automatic, nightly) from fetching planned events
  and hides the cached ones (they are kept, not deleted); Calendar, Today
  and Statistics then show only TriIQ plan sessions and completed
  activities. Turning it on shows them again and syncs the current month.
- **Weekly targets**: an independent weekly training-time goal, in hours,
  for swim, cycle and run — set any or all of them, or leave a field blank
  for no target on that sport. **Show on Today** controls whether the
  rings appear on Today at all, separately from the targets themselves.
  Both persist across restarts.
- **LLM provider**: choose Claude or Ollama, and configure it.
  - **Claude** needs an API key from `console.anthropic.com`. It's stored in
    your OS credential vault (same place as the Intervals.icu key) and sent
    only to Anthropic; usage is billed to your own Anthropic account.
  - **Ollama** defaults to Ollama Cloud (`https://ollama.com`), which needs
    an API key — **Get a key** next to the field opens
    `ollama.com/settings/keys`. Pressing **Save key** tests the connection
    first and only stores it if that succeeds; the model field's suggestion
    chips then switch from generic defaults to whatever's actually
    available on your account. Point the server URL at a local/self-hosted
    instance instead (e.g. `http://localhost:11434`) and no key is needed —
    use **Test connection** to check reachability and list its models the
    same way. Either way the model must support tool calling, or the agent
    can't read your training data at all; the default is `gpt-oss:120b`.
  All of this is remembered across restarts, and changing it takes effect on
  your next message.

### Sync

Manually pull a range of history into the local cache:

| Option | Range |
|---|---|
| Today | today only |
| This month | 1st of the current month → today |
| This year | Jan 1 of the current year → today |
| Everything (initial sync) | 2000-01-01 → today |

Each run shows how many wellness/activity records were synced, and the
card at the top shows the currently cached date range.

## 4. Known gaps / next steps

- Persist the Appearance choice (the LLM settings now persist; this one
  still resets to System on restart).
- Threshold suggestions: the ride FTP down-suggestion and the "within 90
  days" window lean on the `42d`/`s0` curve periods Intervals.icu exposes
  rather than a precise custom rolling window (no per-effort date is tied
  to a model fit); the run ~40-minute-effort fallback's 1.02 scaling factor
  is a heuristic that may need tuning against real data; zone-percentage
  semantics in the confirm sheet's before/after table are inferred from the
  settings model, not confirmed against a live account.
- Knowledge library: Markdown/plain-text only (no PDF/DOCX/HTML import);
  search is keyword/heading scoring, not semantic; documents don't sync
  across devices or back up anywhere but the device's own SQLite file; no
  in-app editing, only import/enable/disable/delete.
- The workout step syntax sent by **Create in Intervals.icu** is written by
  the model and validated only server-side: if Intervals.icu can't parse a
  line it silently keeps it as description text instead of a step. A local
  parser (or reading back `push_errors` from the created event) would tell
  the athlete which it was.
- "Train now" workouts always land on *today* (plan sessions have their own
  dates and can be moved in the plan preview).
- Plan sessions can't be written to the phone's own calendar yet: the
  `device_calendar` plugin (3.9.0) fails to build under this project's
  Android Gradle Plugin (no `namespace`), the same problem as
  `flutter_timezone`. Each session's sheet offers **Add to Google Calendar**
  (a pre-filled link) instead.
- Training plans: one event per goal (no B/C races or mini-tapers, no
  post-race recovery week), no brick sessions, one ramp cap for all sports. Swim templates use % of threshold
  swim pace and the engine's own TSS estimate, which is rougher than for
  ride and run. Sessions can't be edited individually in the week calendar
  (only moved in the preview).
- AI-authored session content: like the step syntax **Create in
  Intervals.icu** writes, a technique session's drill text isn't parsed back
  against Intervals.icu's own step syntax, only sanity-checked locally (field
  length, roughly one line per 10 planned minutes). The short description
  shows in the generate-time preview and the week grid's accessibility label;
  the Calendar's day view still shows a plan session's name only — reaching
  it there would need a lookup back to the session's own row, not just the
  synced Intervals.icu event. Regenerating a session's content (e.g. after
  switching provider) needs regenerating the whole plan; a single already-
  sent session can't be re-authored on its own.
- Persist chat history, so a conversation survives an app restart.
- Expose the agent's tools over MCP as well as in-process, so an external
  client (Claude Desktop, an editor) could query the same cache. The tool
  layer is already a clean seam for it — `TrainingDataTools` has no Flutter
  dependency beyond loading the reference asset.
- No token/cost accounting: a Claude conversation bills the user's own
  account with nothing in the UI saying how much.
- Local SQLite storage on web (needs a wasm-backed `sqflite` variant).
- Web has no local cache: `sqflite` needs a wasm-backed implementation
  there, so sync is Android/Windows only (see Sync & local cache).
- Revisit `flutter_timezone` for the daily reminder once a version exists
  that builds under this project's AGP — the fixed-offset workaround in
  `NotificationService` is fine but not exact across a DST change.
- No background sync on Windows (same missing closed-app wake as the daily
  reminder below); the nightly job is Android only.
- No daily-reminder scheduling on Windows (see Notifications) — would need
  real background-wake support, e.g. a Task Scheduler entry, which is a
  separate, heavier piece of work.

## 5. Training knowledge

The rules and session templates the plan engine (`lib/plan/`) and the chat
agent (`get_session_template`) read. This file is bundled as an app asset; the
parser (`KnowledgeRepository`) reads **only** fenced blocks whose info string
is `okf-rules`, `okf-goal` or `okf-template`. Everything else here is prose
for humans. Each block is one JSON object (valid YAML as well). A block that
fails to parse is skipped and reported; the engine falls back to built-in
defaults rather than generate from half a rule set.

The numbers below are **defaults, not universal truths** — the multipliers,
the ramp limits and the tolerance are starting points the athlete can
override (per-goal ramp limits are editable on the Plan screen). Physiology
background lives in the optional training reference (`assets/knowledge/`); this section only holds what the
engine needs to be deterministic.

### 5.1 Block rules

A plan runs 2-16 weeks (default 8, or the weeks up to and including the
event week; see **Taper and race week** under 5.3). Every
non-recovery week has the same session types per sport (Z2 base, one interval
session, one long session; swim has no long session); only the volume
changes. The engine **proposes** a ramp from the athlete's baseline
weekly load (the mean of the last 4 completed weeks): each week is at most
`maxWeeklyIncrease` above the one before, and also held below `maxCtlRamp`
(projected CTL gain per week) and the weekly hours budget; every
`holdEveryWeeks`th week (default 4) keeps the previous week's load when the
goal keeps the hold on. No recovery dips
are inserted; the athlete shapes the curve in the load graph (80-120% of the
proposal per week), and a week below `recoveryThreshold` of the week before
it is built from recovery templates. `weekPhases`/`weekMultipliers` describe
the classic 4-week shape for the agent's explanations; the curve does not use
them. `lowIntensityTarget` is the
80/20 share of time spent at low intensity, `lowIntensityTolerance` how far
below it a week may fall before it is flagged (more easy time than the target
is not a problem). `recoveryHours` maps a session's TSS to recovery hours
(`[upTo, hours]`, `null` = above the last band); `recoveryFormPenaltyBelow`
adds 12 h when form (CTL − ATL) is below it. `readiness` holds the daily
readiness thresholds, each pair `[caution, back off]`: `hrvSd` (standard
deviations below the HRV baseline), `restingHrBpm` (bpm above the resting-HR
baseline), `sleepHoursCaution` (caution only), `form`, and the baseline
window (`baselineDays`, `minBaselineDays`). Fatigue or soreness at 4, the
worst of Intervals.icu's 1-4 scale, is a caution.

```okf-rules
{
  "weekPhases": ["build", "build_plus", "peak", "recovery"],
  "weekMultipliers": [1.0, 1.08, 1.15, 0.6],
  "maxWeeklyIncrease": 0.10,
  "maxCtlRamp": 7.0,
  "lowIntensityTarget": 0.8,
  "lowIntensityTolerance": 0.05,
  "minHistoryWeeks": 4,
  "recoveryThreshold": 0.9,
  "holdEveryWeeks": 4,
  "recoveryHours": [[50, 12], [100, 24], [200, 36], [null, 48]],
  "recoveryFormPenaltyBelow": -20,
  "taper": {
    "long_distance": [0.7, 0.5],
    "short_event": [0.6]
  },
  "readiness": {
    "hrvSd": [1, 2],
    "restingHrBpm": [5, 10],
    "sleepHoursCaution": 6,
    "form": [-20, -30],
    "baselineDays": 60,
    "minBaselineDays": 14
  }
}
```

### 5.2 Goals

A goal splits a week's load between its session slots. `count` is how many
sessions of that slot per week; `share` is the slot's fraction of the week's
load (shares sum to 1). When the athlete has fewer training days than
sessions, Z2 sessions are dropped first.

```okf-goal
{
  "id": "long_distance",
  "label": "Long distance",
  "slots": {
    "z2": { "count": 2, "share": 0.30 },
    "intervals": { "count": 1, "share": 0.30 },
    "long": { "count": 1, "share": 0.40 }
  }
}
```

```okf-goal
{
  "id": "short_event",
  "label": "Short event (speed)",
  "slots": {
    "z2": { "count": 2, "share": 0.30 },
    "intervals": { "count": 1, "share": 0.40 },
    "long": { "count": 1, "share": 0.30 }
  }
}
```

### 5.3 Session templates

One template per goal, slot and phase. Duration is **derived**, not stored:
`slot load share x week load / tssPerHour`. `lowShare` is the fraction of the
session's time at low intensity (Z1-Z2) and feeds the 80/20 check. `steps` are
a structure the engine turns into Intervals.icu step syntax:

- `{"kind": "fixed", "minutes": 10, "pct": 60}` — a fixed step;
- `{"kind": "fill", "pct": 68}` — takes whatever time is left;
- `{"kind": "repeat", "work": {...}, "rest": {...}, "min": 3, "max": 8}` — as
  many work/rest pairs as fit the remaining time, between `min` and `max`.

`pct` is a number, or `{"Ride": .., "Run": ..}` when the same effort needs a
different figure per sport (Ride: % of FTP; Run: % of threshold pace).
`sports` lists the Intervals.icu sports a template is for; without it a
template serves Ride and Run. Swim templates say `"sports": ["Swim"]` and use
% of threshold swim pace (CSS).

```okf-template
{
  "id": "long_distance.z2",
  "goal": "long_distance", "slot": "z2",
  "phases": ["build", "build_plus", "peak", "recovery", "taper"],
  "name": "Z2 endurance",
  "tssPerHour": 50, "lowShare": 1.0,
  "steps": [
    {"kind": "fixed", "minutes": 10, "pct": {"Ride": 55, "Run": 75}},
    {"kind": "fill", "pct": {"Ride": 68, "Run": 82}},
    {"kind": "fixed", "minutes": 5, "pct": {"Ride": 50, "Run": 70}}
  ]
}
```

```okf-template
{
  "id": "long_distance.intervals.build",
  "goal": "long_distance", "slot": "intervals",
  "phases": ["build"],
  "name": "Tempo-threshold intervals",
  "tssPerHour": 75, "lowShare": 0.5,
  "steps": [
    {"kind": "fixed", "minutes": 15, "pct": {"Ride": 55, "Run": 75}},
    {"kind": "repeat", "min": 3, "max": 5,
     "work": {"minutes": 8, "pct": {"Ride": 90, "Run": 95}},
     "rest": {"minutes": 4, "pct": {"Ride": 50, "Run": 70}}},
    {"kind": "fixed", "minutes": 10, "pct": {"Ride": 50, "Run": 70}}
  ]
}
```

```okf-template
{
  "id": "long_distance.intervals.build_plus",
  "goal": "long_distance", "slot": "intervals",
  "phases": ["build_plus"],
  "name": "Threshold intervals",
  "tssPerHour": 75, "lowShare": 0.5,
  "steps": [
    {"kind": "fixed", "minutes": 15, "pct": {"Ride": 55, "Run": 75}},
    {"kind": "repeat", "min": 3, "max": 5,
     "work": {"minutes": 10, "pct": {"Ride": 95, "Run": 98}},
     "rest": {"minutes": 4, "pct": {"Ride": 50, "Run": 70}}},
    {"kind": "fixed", "minutes": 10, "pct": {"Ride": 50, "Run": 70}}
  ]
}
```

```okf-template
{
  "id": "long_distance.intervals.peak",
  "goal": "long_distance", "slot": "intervals",
  "phases": ["peak"],
  "name": "Threshold and over-under intervals",
  "tssPerHour": 78, "lowShare": 0.5,
  "steps": [
    {"kind": "fixed", "minutes": 15, "pct": {"Ride": 55, "Run": 75}},
    {"kind": "repeat", "min": 3, "max": 5,
     "work": {"minutes": 12, "pct": {"Ride": 98, "Run": 100}},
     "rest": {"minutes": 4, "pct": {"Ride": 50, "Run": 70}}},
    {"kind": "fixed", "minutes": 10, "pct": {"Ride": 50, "Run": 70}}
  ]
}
```

```okf-template
{
  "id": "long_distance.intervals.recovery",
  "goal": "long_distance", "slot": "intervals",
  "phases": ["recovery"],
  "name": "Easy aerobic with short strides",
  "tssPerHour": 55, "lowShare": 0.9,
  "steps": [
    {"kind": "fixed", "minutes": 10, "pct": {"Ride": 55, "Run": 75}},
    {"kind": "fill", "pct": {"Ride": 65, "Run": 80}},
    {"kind": "repeat", "min": 4, "max": 6,
     "work": {"minutes": 1, "pct": {"Ride": 110, "Run": 105}},
     "rest": {"minutes": 2, "pct": {"Ride": 50, "Run": 70}}},
    {"kind": "fixed", "minutes": 5, "pct": {"Ride": 50, "Run": 70}}
  ]
}
```

```okf-template
{
  "id": "long_distance.long",
  "goal": "long_distance", "slot": "long",
  "phases": ["build", "build_plus", "peak", "recovery"],
  "name": "Long endurance",
  "tssPerHour": 58, "lowShare": 0.8,
  "steps": [
    {"kind": "fixed", "minutes": 15, "pct": {"Ride": 55, "Run": 75}},
    {"kind": "fill", "pct": {"Ride": 70, "Run": 84}},
    {"kind": "fixed", "minutes": 10, "pct": {"Ride": 50, "Run": 70}}
  ]
}
```

```okf-template
{
  "id": "short_event.z2",
  "goal": "short_event", "slot": "z2",
  "phases": ["build", "build_plus", "peak", "recovery", "taper"],
  "name": "Z2 endurance",
  "tssPerHour": 50, "lowShare": 1.0,
  "steps": [
    {"kind": "fixed", "minutes": 10, "pct": {"Ride": 55, "Run": 75}},
    {"kind": "fill", "pct": {"Ride": 68, "Run": 82}},
    {"kind": "fixed", "minutes": 5, "pct": {"Ride": 50, "Run": 70}}
  ]
}
```

```okf-template
{
  "id": "short_event.intervals",
  "goal": "short_event", "slot": "intervals",
  "phases": ["build", "build_plus", "peak"],
  "name": "VO2max intervals",
  "tssPerHour": 80, "lowShare": 0.55,
  "steps": [
    {"kind": "fixed", "minutes": 15, "pct": {"Ride": 55, "Run": 75}},
    {"kind": "repeat", "min": 4, "max": 8,
     "work": {"minutes": 3, "pct": {"Ride": 115, "Run": 108}},
     "rest": {"minutes": 3, "pct": {"Ride": 45, "Run": 65}}},
    {"kind": "fixed", "minutes": 10, "pct": {"Ride": 50, "Run": 70}}
  ]
}
```

```okf-template
{
  "id": "short_event.intervals.recovery",
  "goal": "short_event", "slot": "intervals",
  "phases": ["recovery"],
  "name": "Easy aerobic with short strides",
  "tssPerHour": 55, "lowShare": 0.9,
  "steps": [
    {"kind": "fixed", "minutes": 10, "pct": {"Ride": 55, "Run": 75}},
    {"kind": "fill", "pct": {"Ride": 65, "Run": 80}},
    {"kind": "repeat", "min": 4, "max": 6,
     "work": {"minutes": 1, "pct": {"Ride": 110, "Run": 105}},
     "rest": {"minutes": 2, "pct": {"Ride": 50, "Run": 70}}},
    {"kind": "fixed", "minutes": 5, "pct": {"Ride": 50, "Run": 70}}
  ]
}
```

```okf-template
{
  "id": "short_event.long",
  "goal": "short_event", "slot": "long",
  "phases": ["build", "build_plus", "peak", "recovery"],
  "name": "Long endurance",
  "tssPerHour": 58, "lowShare": 0.85,
  "steps": [
    {"kind": "fixed", "minutes": 15, "pct": {"Ride": 55, "Run": 75}},
    {"kind": "fill", "pct": {"Ride": 70, "Run": 84}},
    {"kind": "fixed", "minutes": 10, "pct": {"Ride": 50, "Run": 70}}
  ]
}
```

#### Swim (triathlon)

A triathlon plan gives swim a Z2 and an interval session per week (no long
swim); the shares of the goal's `z2` and `intervals` slots are renormalised
between the two.

```okf-template
{
  "id": "long_distance.swim.z2",
  "goal": "long_distance", "slot": "z2", "sports": ["Swim"],
  "phases": ["build", "build_plus", "peak", "recovery", "taper"],
  "name": "Aerobic swim",
  "tssPerHour": 40, "lowShare": 1.0,
  "steps": [
    {"kind": "fixed", "minutes": 5, "pct": 75},
    {"kind": "fill", "pct": 82},
    {"kind": "fixed", "minutes": 5, "pct": 72}
  ]
}
```

```okf-template
{
  "id": "long_distance.swim.intervals",
  "goal": "long_distance", "slot": "intervals", "sports": ["Swim"],
  "phases": ["build", "build_plus", "peak"],
  "name": "Threshold swim",
  "tssPerHour": 55, "lowShare": 0.55,
  "steps": [
    {"kind": "fixed", "minutes": 10, "pct": 75},
    {"kind": "repeat", "min": 4, "max": 10,
     "work": {"minutes": 3, "pct": 98},
     "rest": {"minutes": 1, "pct": 70}},
    {"kind": "fixed", "minutes": 5, "pct": 72}
  ]
}
```

```okf-template
{
  "id": "long_distance.swim.intervals.recovery",
  "goal": "long_distance", "slot": "intervals", "sports": ["Swim"],
  "phases": ["recovery"],
  "name": "Easy technique swim",
  "tssPerHour": 38, "lowShare": 0.9,
  "steps": [
    {"kind": "fixed", "minutes": 5, "pct": 75},
    {"kind": "fill", "pct": 80},
    {"kind": "repeat", "min": 4, "max": 6,
     "work": {"minutes": 1, "pct": 95},
     "rest": {"minutes": 1, "pct": 70}},
    {"kind": "fixed", "minutes": 5, "pct": 72}
  ]
}
```

```okf-template
{
  "id": "short_event.swim.z2",
  "goal": "short_event", "slot": "z2", "sports": ["Swim"],
  "phases": ["build", "build_plus", "peak", "recovery", "taper"],
  "name": "Aerobic swim",
  "tssPerHour": 40, "lowShare": 1.0,
  "steps": [
    {"kind": "fixed", "minutes": 5, "pct": 75},
    {"kind": "fill", "pct": 82},
    {"kind": "fixed", "minutes": 5, "pct": 72}
  ]
}
```

```okf-template
{
  "id": "short_event.swim.intervals",
  "goal": "short_event", "slot": "intervals", "sports": ["Swim"],
  "phases": ["build", "build_plus", "peak"],
  "name": "Speed swim",
  "tssPerHour": 60, "lowShare": 0.55,
  "steps": [
    {"kind": "fixed", "minutes": 10, "pct": 75},
    {"kind": "repeat", "min": 6, "max": 12,
     "work": {"minutes": 2, "pct": 103},
     "rest": {"minutes": 1, "pct": 70}},
    {"kind": "fixed", "minutes": 5, "pct": 72}
  ]
}
```

```okf-template
{
  "id": "short_event.swim.intervals.recovery",
  "goal": "short_event", "slot": "intervals", "sports": ["Swim"],
  "phases": ["recovery"],
  "name": "Easy technique swim",
  "tssPerHour": 38, "lowShare": 0.9,
  "steps": [
    {"kind": "fixed", "minutes": 5, "pct": 75},
    {"kind": "fill", "pct": 80},
    {"kind": "repeat", "min": 4, "max": 6,
     "work": {"minutes": 1, "pct": 95},
     "rest": {"minutes": 1, "pct": 70}},
    {"kind": "fixed", "minutes": 5, "pct": 72}
  ]
}
```

**Taper and race week.** When the goal has an event date and the plan's last
week contains it, the last weeks are a taper: `taper` in the rules lists, per
goal type, each taper week's load as a fraction of the last week before the
taper (two weeks at 70 % and 50 % for long distance, one at 60 % for a short
event). The interval session stays, shorter, so intensity is kept while
volume drops; taper templates carry `shareScale`, which scales a slot's share
of its sport's load before the sport is renormalised, so the long session
(0.6) shrinks more than the week. Z2 templates serve the taper unchanged. In
the event week nothing is placed on the event day or after it, and the day
before gets the short `openers` session when it is a training day.

```okf-template
{
  "id": "long_distance.intervals.taper",
  "goal": "long_distance", "slot": "intervals",
  "phases": ["taper"],
  "name": "Taper threshold intervals",
  "tssPerHour": 75, "lowShare": 0.55, "shareScale": 1.2,
  "steps": [
    {"kind": "fixed", "minutes": 15, "pct": {"Ride": 55, "Run": 75}},
    {"kind": "repeat", "min": 2, "max": 4,
     "work": {"minutes": 6, "pct": {"Ride": 98, "Run": 100}},
     "rest": {"minutes": 3, "pct": {"Ride": 50, "Run": 70}}},
    {"kind": "fixed", "minutes": 10, "pct": {"Ride": 50, "Run": 70}}
  ]
}
```

```okf-template
{
  "id": "long_distance.long.taper",
  "goal": "long_distance", "slot": "long",
  "phases": ["taper"],
  "name": "Taper endurance",
  "tssPerHour": 58, "lowShare": 0.85, "shareScale": 0.6,
  "steps": [
    {"kind": "fixed", "minutes": 15, "pct": {"Ride": 55, "Run": 75}},
    {"kind": "fill", "pct": {"Ride": 70, "Run": 84}},
    {"kind": "fixed", "minutes": 10, "pct": {"Ride": 50, "Run": 70}}
  ]
}
```

```okf-template
{
  "id": "short_event.intervals.taper",
  "goal": "short_event", "slot": "intervals",
  "phases": ["taper"],
  "name": "Taper VO2max intervals",
  "tssPerHour": 78, "lowShare": 0.6, "shareScale": 1.2,
  "steps": [
    {"kind": "fixed", "minutes": 15, "pct": {"Ride": 55, "Run": 75}},
    {"kind": "repeat", "min": 3, "max": 5,
     "work": {"minutes": 2, "pct": {"Ride": 115, "Run": 108}},
     "rest": {"minutes": 3, "pct": {"Ride": 45, "Run": 65}}},
    {"kind": "fixed", "minutes": 10, "pct": {"Ride": 50, "Run": 70}}
  ]
}
```

```okf-template
{
  "id": "short_event.long.taper",
  "goal": "short_event", "slot": "long",
  "phases": ["taper"],
  "name": "Taper endurance",
  "tssPerHour": 58, "lowShare": 0.85, "shareScale": 0.6,
  "steps": [
    {"kind": "fixed", "minutes": 15, "pct": {"Ride": 55, "Run": 75}},
    {"kind": "fill", "pct": {"Ride": 70, "Run": 84}},
    {"kind": "fixed", "minutes": 10, "pct": {"Ride": 50, "Run": 70}}
  ]
}
```

```okf-template
{
  "id": "long_distance.swim.intervals.taper",
  "goal": "long_distance", "slot": "intervals", "sports": ["Swim"],
  "phases": ["taper"],
  "name": "Taper threshold swim",
  "tssPerHour": 52, "lowShare": 0.6, "shareScale": 1.2,
  "steps": [
    {"kind": "fixed", "minutes": 10, "pct": 75},
    {"kind": "repeat", "min": 3, "max": 6,
     "work": {"minutes": 2, "pct": 98},
     "rest": {"minutes": 1, "pct": 70}},
    {"kind": "fixed", "minutes": 5, "pct": 72}
  ]
}
```

```okf-template
{
  "id": "short_event.swim.intervals.taper",
  "goal": "short_event", "slot": "intervals", "sports": ["Swim"],
  "phases": ["taper"],
  "name": "Taper race-pace swim",
  "tssPerHour": 55, "lowShare": 0.6, "shareScale": 1.2,
  "steps": [
    {"kind": "fixed", "minutes": 10, "pct": 75},
    {"kind": "repeat", "min": 3, "max": 6,
     "work": {"minutes": 2, "pct": 102},
     "rest": {"minutes": 1, "pct": 70}},
    {"kind": "fixed", "minutes": 5, "pct": 72}
  ]
}
```

```okf-template
{
  "id": "long_distance.openers",
  "goal": "long_distance", "slot": "intervals",
  "phases": ["openers"],
  "name": "Race openers",
  "tssPerHour": 55, "lowShare": 0.8,
  "steps": [
    {"kind": "fixed", "minutes": 12, "pct": {"Ride": 55, "Run": 75}},
    {"kind": "repeat", "min": 3, "max": 3,
     "work": {"minutes": 1, "pct": {"Ride": 105, "Run": 103}},
     "rest": {"minutes": 2, "pct": {"Ride": 50, "Run": 70}}},
    {"kind": "fixed", "minutes": 5, "pct": {"Ride": 50, "Run": 70}}
  ]
}
```

```okf-template
{
  "id": "short_event.openers",
  "goal": "short_event", "slot": "intervals",
  "phases": ["openers"],
  "name": "Race openers",
  "tssPerHour": 55, "lowShare": 0.8,
  "steps": [
    {"kind": "fixed", "minutes": 12, "pct": {"Ride": 55, "Run": 75}},
    {"kind": "repeat", "min": 3, "max": 3,
     "work": {"minutes": 1, "pct": {"Ride": 110, "Run": 105}},
     "rest": {"minutes": 2, "pct": {"Ride": 50, "Run": 70}}},
    {"kind": "fixed", "minutes": 5, "pct": {"Ride": 50, "Run": 70}}
  ]
}
```

