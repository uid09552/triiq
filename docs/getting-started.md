# Getting started

## 1. Install

=== "Android"

    Download the latest `triiq-<version>.apk` from the
    [Releases page](https://github.com/uid09552/triiq/releases) and open it
    on your phone (allow installing from your browser or file manager when
    Android asks). Every merge to `main` publishes a release candidate
    (`v0.9.0-rc<hash>`); tagged versions are the stable ones.
    → [Releases](releases.md)

=== "Windows"

    Build it yourself for now (see [Development](development.md)):

    ```bash
    flutter build windows --release
    ```

    If the build complains about symlinks, enable Developer Mode
    (`start ms-settings:developers`).

## 2. Connect Intervals.icu

1. In Intervals.icu open **Settings → Developer** and copy your **API key**.
2. In TriIQ open the profile icon (top-right) → **Profile**, paste the key and connect.

The key is tested against Intervals.icu first and only then stored in the
OS vault. TriIQ syncs today on every app start, the current month in the
background while it is open, and (Android) every night.

## 3. Choose an LLM for the AI trainer

Open the profile icon (top-right) → **Settings → LLM provider**.

| Provider | What you need | Notes |
|---|---|---|
| **Ollama, self-hosted** | An Ollama server on your computer or home network, e.g. `http://192.168.1.20:11434` | No key. Plain `http://` is allowed on your own network (Settings shows a warning). |
| **Ollama Cloud** | `https://ollama.com` and an Ollama API key | The key is only ever sent to `https://ollama.com`. |
| **Claude** | An Anthropic API key | Pick the model in Settings. |

Tap **Test connection** to load the model list. Without a provider the app
works fully — only the chat, Train now proposals and AI-written plan content
need one.

## 4. First steps

- **Today** shows readiness, load and today's training. Long-press the header
  tile for quick actions (sync, Train now, log fatigue & soreness, …).
- **More → Training plan** builds a plan; **Take as plan** puts it in the
  calendar (sending it to Intervals.icu is optional, Settings → Calendar).
- **Chat** answers questions about your own data.
- **Settings → Notifications** turns on the morning briefing.
- **Settings → Backup** exports everything to a JSON file.
