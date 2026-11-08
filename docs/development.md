# Development

TriIQ is a Flutter app (Dart ≥ 3.11). Supported targets are **Android** and
**Windows**; `ios/` and `web/` still build but are not actively targeted.

## Build and run

```bash
flutter pub get
flutter run                     # on a connected device or emulator
flutter build apk --release     # Android
flutter build windows --release # Windows
```

## Checks

```bash
flutter analyze                 # must be 0 errors
flutter test                    # all tests
flutter test test/widget_test.dart --plain-name "test name"
flutter test --dart-define=INTERVALS_API_KEY=<key>   # also the live Intervals.icu suite
# "Log in with Intervals.icu": the OAuth client and redirect default to the registered
# app (client 1727); another build can set --dart-define=INTERVALS_CLIENT_ID=<id>
# and --dart-define=INTERVALS_REDIRECT_URI=<uri>
```

`test/flutter_test_config.dart` gives every test file its own temporary
database, so tests need no SQLite setup of their own.

## Generated Intervals.icu client

`lib/client/intervalls/` is generated from `openapi.json` with
openapi-generator (`dart-dio`) — don't edit it by hand. `openapi.json`
carries local fixes to the upstream spec; the steps to regenerate and the
fixes to keep are in [CLAUDE.md](https://github.com/uid09552/triiq/blob/main/CLAUDE.md).

## Where things are

| Path | What |
|---|---|
| `lib/screens/` | UI by screen |
| `lib/agent/` | AI trainer: system prompt, tools, memory, providers |
| `lib/plan/` | Plan engine, adaptation, actions |
| `lib/evaluation/` | Readiness, fatigue, session evaluation, curves |
| `lib/season/` | Forecast, season timeline, race predictor, illness mode, bricks |
| `lib/data/` | Database, repositories, sync, offline queue, backup |
| `docs/okf.md` | The full [specification](okf.md); section 5 is also read by the plan engine at runtime |
| `openspec/` | The change proposals the features were built from |

## Documentation site

This site is built with [MkDocs](https://www.mkdocs.org) and
[Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) from
`docs/` and published to GitHub Pages on every push to `main`:

```bash
pip install -r requirements-docs.txt
mkdocs serve        # http://127.0.0.1:8000
mkdocs build --strict
```

## Software Bill of Materials (SBOM)

The **SBOM** workflow (`.github/workflows/sbom.yml`) lists every package the app
is built from, as the **`triiq-sbom`** artifact of the run (Actions → SBOM → the
run → Artifacts):

| File | What |
|---|---|
| `triiq.cdx.json` | CycloneDX, for vulnerability and licence tooling |
| `triiq.spdx.json` | SPDX, for compliance and procurement |
| `dependencies.csv` | every Dart/Flutter package in `pubspec.lock` with version, direct / dev / transitive, source and content hash |

It runs when `pubspec.yaml`, `pubspec.lock` or `android/` change on `main`, on
pull requests that touch them, weekly, and on demand (Actions → SBOM → Run
workflow). The SBOM is generated with Syft from the repository and **checked
against `pubspec.lock`**: a scan that is empty or missing more than 10 % of the
lockfile fails the run (`tool/check_sbom.py`). `tool/pubspec_lock_to_csv.py`
writes the CSV and needs only Python 3.

Not covered: native Android libraries (the project keeps no Gradle lockfile, so
there is nothing exact to scan) and the Flutter engine.

