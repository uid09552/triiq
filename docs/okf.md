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
stack: Flutter (Dart), no custom backend
---

# TriIQ — Open Knowledge Format

## 1. Specification

### What it is

TriIQ is a client-only mobile/desktop app that connects an athlete's
[Intervals.icu](https://intervals.icu) training data to an LLM (Claude, or a
local/self-hosted model via Ollama), so the athlete can:

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
  layer (planned) is built to be provider-agnostic via LangChain.
- **The generated API client is a dependency, not hand-written code.**
  `lib/client/intervalls/` is produced from `openapi.json` and should be
  regenerated, not edited (two documented exceptions aside — see CLAUDE.md).

### External dependencies

| Dependency | Purpose | Auth |
|---|---|---|
| [Intervals.icu API](https://intervals.icu/api/v1/docs.html) (`openapi.json`) | Source of truth for activities, wellness, workouts | HTTP Basic: username `API_KEY`, password = the user's Intervals.icu API key |
| LLM provider (Claude API or a local Ollama server) | Powers the chat/agent | Claude: API key. Ollama: server URL, no key |

### Status matrix

| Area | Status |
|---|---|
| Navigation shell (top bar, bottom nav) | ✅ Implemented |
| Intervals.icu connection (Profile) | ✅ Implemented — API key is auth-tested against Intervals.icu, then persisted to secure storage and restored on relaunch |
| Local SQLite cache + sync | ✅ Implemented (Today auto-sync, manual Sync screen) |
| Today screen | ✅ Real data (TSS/CTL/ATL, today's activities) once connected |
| Calendar screen | 🚧 UI only — month/week toggle works, no real data wired |
| Statistics screen | 🚧 UI only — chart is a placeholder box |
| Chat screen | 🚧 UI only — echoes a static "not connected" reply, no LLM call |
| Appearance (light/dark/system theme) | ✅ Implemented — Settings → Appearance, applies instantly, in-memory only |
| Settings — LLM provider | 🚧 UI only — provider picker, nothing persisted |
| LangChain agent | ❌ Not started |
| MCP server/client | ❌ Not started |
| Training-plan calculation | ❌ Not started |
| LLM credential persistence | ❌ Not started — Claude/Ollama settings are in-memory only, lost on restart |
| Web platform | ⚠️ Local storage unsupported (SQLite has no web backend wired up yet); UI renders fine |

## 2. Architecture

### Layers

```
 UI (lib/screens, lib/widgets)
   │  reads/writes via
   ▼
 Data layer (lib/data)
   │  IntervalsSession (auth/session)
   │  SyncService (orchestrates fetch + cache)
   │  Repositories (SQLite CRUD)
   ▼
 Generated API client (lib/client/intervalls) ──▶ Intervals.icu (HTTPS)

 (planned, not yet built)
 Chat screen ──▶ LangChain agent ──▶ MCP client ──▶ same generated client ──▶ Intervals.icu
                                  └─▶ LLM provider (Claude API / Ollama)
```

Today's screens call into `lib/data/`, never into `lib/client/intervalls/`
directly — that keeps the generated client swappable and the SQLite cache as
the single read path for the UI.

### Navigation

`MainShell` (`lib/widgets/main_shell.dart`) is a `Scaffold` with:
- a top `AppBar` whose right-corner avatar button pushes `ProfileScreen`
  (connect/disconnect Intervals.icu, link to Settings);
- a bottom `NavigationBar` with five destinations, kept alive via
  `IndexedStack`: **Today**, **Calendar**, **Chat**, **Statistics**, **More**.
- **More** is the submenu: Profile, Settings, **Sync**, plus disabled
  placeholders for future features (training plans, gear).

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
  the header use `syncTodayWindow()`, which always refetches. A failed fetch
  does not blank the screen — it falls through to the cache and shows the
  error alongside.
- The **Sync** screen (More → Sync) exposes the same scopes as manual
  buttons, showing the cached activities date range from `SyncStateRepository`.

### Credential storage

`SecureKeyStore` (`lib/data/secure_key_store.dart`) wraps
`flutter_secure_storage` and is the only place a secret is written. One named
secret per instance, so the not-yet-persisted LLM credentials can reuse it.
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

Every cached row keeps the full API response in `raw` (JSON), so new UI
features can read additional fields without a schema migration — only
promote a field to its own column when it needs to be queried/filtered on.

### Theming

`lib/app.dart` defines one Material 3 theme spec — built twice, for
`Brightness.light` and `Brightness.dark` — from a single seeded
`ColorScheme` and shared component styling (rounded cards/inputs/nav
bar/buttons). UI code should pull colors from `Theme.of(context).colorScheme`
rather than hardcoding `Colors.*`.

Which one is active is controlled by `ThemeController`
(`lib/theme_controller.dart`), a singleton `ChangeNotifier` holding a
`ThemeMode` (`system` | `light` | `dark`, default `system`). `TriiqApp`
wraps `MaterialApp` in a `ListenableBuilder` on it, so changing the mode
(from Settings → Appearance) re-themes the whole app immediately. Unlike
`IntervalsSession`, this choice is **not** persisted yet — it resets to
`system` on restart.

## 3. User documentation

### Connecting your Intervals.icu account

1. Tap the profile icon (top-right) or **More → Profile**.
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

### Today

Shows today's date's cached data: a hero card summarizing today's
activity/activities (or "Ready to train" if none), TSS/CTL/ATL tiles, and
an athlete status card. Pull to refresh re-runs the sync check. The first
time this screen loads after connecting, it automatically fetches and
caches today's data if it isn't already stored locally.

### Calendar

Toggle between **Month** and **Week** views (currently placeholders —
no real Intervals.icu data wired in yet; will show planned vs. completed
trainings once implemented).

### Chat

A chat UI for asking the training agent about your data. Currently every
message gets a static "agent not connected yet" reply — no LLM or MCP
integration exists yet (see Status matrix).

### Statistics

Training-stress and volume overview (currently placeholders — chart is a
static box, volume tiles show `—`).

### More

Submenu for Profile, Settings, and **Sync**, plus disabled placeholders
for upcoming features (training plans, gear).

### Settings

- **Appearance**: pick System, Light, or Dark. Applies instantly across the
  whole app; resets to System on restart (not persisted yet).
- **LLM provider**: choose Claude or Ollama and enter the corresponding
  credential (Claude API key, or an Ollama server URL). Not persisted yet,
  and not wired to any agent yet.

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

- Persist the LLM provider settings (Claude API key / Ollama URL) and the
  Appearance choice. The Claude key should go through `SecureKeyStore` under
  its own name; the Ollama URL and Appearance are not secrets and can use
  ordinary preferences.
- Wire Calendar and Statistics to the local cache (they already have the
  repositories available; just not connected yet).
- Build the LangChain agent + MCP server/client, and connect the Chat
  screen and Settings' LLM provider choice to it.
- Local SQLite storage on web (needs a wasm-backed `sqflite` variant).
- Web has no local cache: `sqflite` needs a wasm-backed implementation
  there, so sync is Android/Windows only (see Sync & local cache).
