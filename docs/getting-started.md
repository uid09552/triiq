# Getting started

## 1. Install

=== "Android"

    Download the latest `triiq-<version>.apk` from the
    [Releases page](https://github.com/uid09552/triiq/releases) and open it
    on your phone (allow installing from your browser or file manager when
    Android asks). Every merge to `main` publishes a release candidate
    (`v0.9.6-rc<hash>`); tagged versions are the stable ones.
    → [Releases](releases.md)

=== "Windows"

    Build it yourself for now (see [Development](development.md)):

    ```bash
    flutter build windows --release
    ```

    If the build complains about symlinks, enable Developer Mode
    (`start ms-settings:developers`).

!!! tip "Guided setup"
    A fresh install starts with a short guide. You can run it again any time
    from **Settings → Guided setup**: it walks you through connecting
    Intervals.icu, syncing your history, weekly hours, year goals, races and
    events, and the AI trainer — with what you already set filled in. The
    steps below are the same things, by hand.

## 2. Connect Intervals.icu

**Easiest (Android, Windows):** open the profile icon (top-right) →
**Profile** → **Log in with Intervals.icu**. Your browser asks Intervals.icu
to let TriIQ in; agree and you are connected. TriIQ never sees your password.

**Or with an API key:**

1. In Intervals.icu open **Settings → Developer** and copy your **API key**.
2. In TriIQ open the profile icon (top-right) → **Profile**, paste the key and connect.

Either way the credential is tested against Intervals.icu first and only then
stored in the OS vault. TriIQ syncs today on every app start, the current month in the
background while it is open, and (Android) every night.

## 3. Choose an LLM for the AI trainer

Open the profile icon (top-right) → **Settings → AI trainer → Models**. The
list starts with one Claude entry; edit it (pencil), or **Add model** for
another provider.

| Provider | What you need | Notes |
|---|---|---|
| **Ollama, self-hosted** | An Ollama server on your computer or home network, e.g. `http://192.168.1.20:11434` | No key. Plain `http://` is allowed on your own network (Settings shows a warning). |
| **Ollama Cloud** | `https://ollama.com` and an Ollama API key | The key is only ever sent to `https://ollama.com`. |
| **Claude** | An Anthropic API key | Pick the model in Settings. |
| **OpenAI-compatible** | A base URL (default `https://api.openai.com/v1`), a model name and, if the server needs one, an API key | Works with OpenAI, OpenRouter, LM Studio, vLLM, llama.cpp, LiteLLM… `https://` for any host; `http://` only for `localhost` or your own network. **Load models** lists what the server offers. |

Tap **Test connection** to load the model list. Without a provider the app
works fully — only the chat, Train now proposals and AI-written plan content
need one.

You can add **several models** (say Claude, then Ollama Cloud, then LM Studio
on your PC) and order them by priority: the trainer uses the first one that
works and switches to the next when it is unreachable, rate-limited or
failing; the chat says when it switched and shows which model answered. Each
new third-party server asks for your consent first.

## 4. First steps

- **Today** shows readiness, load and today's training. Long-press the header
  tile for quick actions (sync, Train now, log fatigue & soreness, …).
- **More → Training plan** builds a plan; **Take as plan** puts it in the
  calendar (sending it to Intervals.icu is optional, Settings → Data & privacy → Calendar).
- **Chat** answers questions about your own data.
- **Settings → App → Notifications** turns on the morning briefing.
- **Settings → Data & privacy → Backup** exports everything to a JSON file.
