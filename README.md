# TriIQ

> **The goal of TriIQ: no backend, full control of your data.**
> There is no TriIQ server, no TriIQ account and no tracking. Your training
> data is cached in a database on your own device. The app only talks to
> services you choose and own: **[Intervals.icu](https://intervals.icu)** for
> your training data, and **the LLM of your choice** for the AI trainer — any
> model you run yourself with **[Ollama](https://ollama.com)**, or **Anthropic's
> Claude API** with your own key. Your keys stay in the operating system's secure
> storage, and you can export or restore everything as a JSON file at any time.
> (The only other request is for map tiles from OpenStreetMap when you open a
> route map.)

An endurance and triathlon training companion for
[Intervals.icu](https://intervals.icu), built with Flutter for **Android** and
**Windows**.

TriIQ caches your Intervals.icu activities, planned workouts and wellness data
on the device and adds:

- **Today**: training load at a glance (TSS, CTL, ATL, form, ramp), today's
  sessions and planned workouts.
- **Training plans**: 2–16-week plans for run, ride or triathlon, with a load
  curve you can drag, a configurable weekly ramp with hold weeks, a sport and
  session mix, and preferences such as long sessions at the weekend.
- **Calendar**: month and week views of plan sessions, Intervals.icu events and
  completed activities.
- **Session analysis**: each workout is evaluated against its plan, with
  streams and intervals over time, personal bests, efficiency trend and a
  recovery hint. A one-time pop-up shows today's new sessions.
- **AI trainer chat**: a tool-calling agent over your local data, using Claude
  or Ollama, that can explain your training and propose plan changes for you
  to apply.
- **Train now**: an alternative to today's session, or a fresh proposal,
  created directly in Intervals.icu.

German and English are supported.

## Getting started

Requirements: Flutter (stable, Dart ≥ 3.11) and, for Android, the Android SDK
with JDK 17.

```bash
flutter pub get
flutter run
```

In the app, open **Profile** and enter your Intervals.icu API key (from
Intervals.icu → Settings → Developer). For the chat, choose a provider under
**Settings**: a Claude API key, or an Ollama server (local or cloud).

Credentials stay on the device: the Intervals.icu and Claude keys go to the OS
secure storage, other settings (including an Ollama key) to app preferences.
The app talks only to Intervals.icu and the LLM provider you choose.

### Optional training reference

The agent can quote from a Markdown training reference that you supply. See
[assets/knowledge/README.md](assets/knowledge/README.md).

## Development

```bash
flutter analyze
flutter test
flutter test --dart-define=INTERVALS_API_KEY=<key>   # also run the live API suite
```

- [docs/okf.md](docs/okf.md) is the full specification: architecture, user
  docs, and the training rules and session templates the plan engine reads.
- `lib/client/intervalls/` is generated from `openapi.json`. See
  [CLAUDE.md](CLAUDE.md) for how to regenerate it.
- `openspec/` holds the change proposals the features were built from.

### Releases

[`.github/workflows/android-release.yml`](.github/workflows/android-release.yml)
builds the release APK. Pushing a `v*` tag publishes it as a GitHub release.
Set the `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`,
`ANDROID_KEY_ALIAS` and `ANDROID_KEY_PASSWORD` secrets to sign it with your own
key.

## Disclaimer

TriIQ is not affiliated with Intervals.icu. It is not medical advice: training
suggestions come from rules and an AI model, so check them against how you
feel and consult a professional when in doubt.

## License

[MIT](LICENSE)
