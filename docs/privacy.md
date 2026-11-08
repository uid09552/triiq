# Privacy & data

TriIQ is built so that **you** keep control: no backend, no account, no
tracking. This page is the app's privacy notice; the same information is in the
app under **Settings → Data & privacy → Consent & your rights**, next to the switches that apply it.

## Who is responsible

TriIQ runs entirely on your device and has no server: the developer does not
receive, store or process your data. The data TriIQ handles is yours; the
services you connect (Intervals.icu, an AI provider, OpenStreetMap) each
process what they receive under their own privacy terms and are responsible
for it. Questions or requests: open an issue at
[github.com/uid09552/triiq](https://github.com/uid09552/triiq).

## What data is processed

| Category | Examples | Note |
|---|---|---|
| Activities and routes | Sessions, durations, power, pace, GPS tracks | From Intervals.icu |
| **Health data** | Heart rate, HRV, resting heart rate, sleep, weight, how you feel (fatigue, soreness) | A special category of personal data under the GDPR (Art. 9) |
| Profile | Name, picture, thresholds, goals, plans, trainer memory | From Intervals.icu and what you enter |
| Credentials | Intervals.icu, Claude and Ollama keys | OS secure storage |

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

## Legal basis

- **Syncing with Intervals.icu** happens because you connected your account
  and use the app for that purpose.
- **Sending data to an AI provider** happens **only with your explicit
  consent** (GDPR Art. 6(1)(a) and, for health data, Art. 9(2)(a)). The AI
  trainer stays off until you agree — in **Settings → Data & privacy → Consent & your rights**, or
  when TriIQ asks the first time you use it — and you can **withdraw consent
  at any time** with the same switch; the AI features then switch off at
  once. The date you agreed is kept on the device.
- **Map tiles** are fetched only to show the route map you opened. They are
  requested from OpenStreetMap, which sees your IP address and the area
  shown. **Settings → Data & privacy → Consent & your rights → Load map tiles** switches that off;
  routes are then drawn without a map.

## Transfers outside the EU/EEA

Some recipients may process data outside the EU/EEA — for example an AI
provider in the USA. What they receive is covered by their own privacy terms.
A self-hosted Ollama server on your own network keeps the data with you.

## How long data is kept

On your device, until **you** delete it: with **Delete all data** in
Settings → Data & privacy → Consent & your rights, by restoring a backup over it, or by uninstalling
the app. Data already sent to Intervals.icu or an AI provider is kept by them
under their own rules; TriIQ cannot delete it for you.

## Your rights and how to use them

| Right | How |
|---|---|
| Access and portability | **Settings → Data & privacy → Backup** exports everything stored on the device as one JSON file |
| Rectification | Correct the data in Intervals.icu; the next sync updates the device |
| Erasure | **Settings → Data & privacy → Consent & your rights → Delete all data** removes the local database, all saved keys and every setting, and disconnects Intervals.icu. To remove your data at Intervals.icu or an AI provider, use their account tools |
| Withdraw consent / object | Switch **Send my data to the AI provider** off; disconnect Intervals.icu in Profile; switch map tiles off |
| Complaint | You can complain to your data protection supervisory authority |

## Security

Keys are kept in the operating system's secure storage, never in the backup
file or the database. All network traffic to Intervals.icu, Anthropic, Ollama
Cloud and OpenStreetMap is https; a self-hosted Ollama over plain `http://`
is possible on your own network and Settings warns that it is unencrypted.

## Children

TriIQ is not directed at children and does not knowingly process their data.

## Changes to this notice

The notice changes with the app; the date of each change is in the project's
release notes.

## Backup and restore

**Settings → Data & privacy → Backup** writes one JSON file with your synced data, plans,
knowledge library and settings (share sheet on Android, save dialog on
Windows). **Restore** replaces the local data after you confirm, in one
transaction. Keys and the LLM connection settings are never part of a backup,
so a backup file can't redirect the trainer to another server; reconnect
Intervals.icu after restoring on a new device.

## Offline changes

Changes made while Intervals.icu is unreachable are queued on the device and
sent later — always to the account they were made for. Disconnecting in
Profile clears the queue.
