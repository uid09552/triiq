# Privacy & data

TriIQ is built so that **you** keep control: no backend, no account, no
tracking.

## What is stored where

| What | Where |
|---|---|
| Activities, wellness, planned workouts, plans, knowledge library, caches | A SQLite database on the device — Android: app storage; Windows: the per-user app-data folder (`%APPDATA%\…\triiq\triiq.db`) |
| Intervals.icu, Claude and Ollama keys | The operating system's secure storage (the Android Keystore, the Windows credential store) |
| Settings (goal, targets, theme, trainer memory, …) | App preferences on the device |

Android's system backup is switched off for the app, because the encrypted
keys could not be decrypted on another device anyway.

## Who the app talks to

| Service | When | What is sent |
|---|---|---|
| **Intervals.icu** (https) | Sync, and when you create, move or delete planned workouts or apply a threshold | Your API key and the requests themselves |
| **Your LLM** (Claude / Ollama Cloud over https, or your own Ollama server) | Only when you use the chat, Train now or AI-written plan content | The conversation, including the results of the tools the trainer calls on your local data |
| **OpenStreetMap** tile servers (https) | Only when a route map is shown | Map tile requests |

Nothing else — no analytics, no crash reporting, no TriIQ server.

- The **Ollama key is only ever sent to `https://ollama.com`**, never to a
  self-hosted server and never over plain http.
- A **self-hosted Ollama over `http://`** works on your own network; Settings
  warns that prompts and data then travel unencrypted. Intervals.icu,
  Anthropic, Ollama Cloud and OpenStreetMap are https-only.

## Backup and restore

**Settings → Backup** writes one JSON file with your synced data, plans,
knowledge library and settings (share sheet on Android, save dialog on
Windows). **Restore** replaces the local data after you confirm, in one
transaction. Keys and the LLM connection settings are never part of a backup,
so a backup file can't redirect the trainer to another server; reconnect
Intervals.icu after restoring on a new device.

## Offline changes

Changes made while Intervals.icu is unreachable are queued on the device and
sent later — always to the account they were made for. Disconnecting in
Profile clears the queue.
