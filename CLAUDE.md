# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Responding

Keep replies to the user short — a few lines, no preamble or recap of work
already shown in tool output. Token cost matters here. Lead with the result;
add detail only where it changes a decision (a failure, a risk, a choice that
needs input). Thoroughness belongs in the code and in docs/okf.md, not in
chat.

## Project

Flutter app `triiq` (Dart SDK ^3.11.5).

**Full app specification, architecture, and user docs: [docs/okf.md](docs/okf.md).** Read that first for anything beyond the commands and dev-workflow notes below — this file stays intentionally short and operational; okf.md is the source of truth for "what the app is and how it's built."

## Commands

```bash
flutter pub get                 # install deps
flutter run                     # run on connected device/emulator
flutter analyze                 # static analysis (must be 0 errors; generated client emits only info-level constant_identifier_names lints)
flutter test                    # run all tests
flutter test test/widget_test.dart --plain-name "test name"   # run a single test
flutter test --dart-define=INTERVALS_API_KEY=<key>            # also run the live Intervals.icu suite (test/sync_live_test.dart); without the key those tests skip
dart run build_runner build --delete-conflicting-outputs      # regenerate *.g.dart (json_serializable/copy_with) after editing lib/client/intervalls
```

`test/flutter_test_config.dart` points the shared database at a temp file for every test, so tests need no `triiq.db` or SQLite setup of their own (tests that build their own `AppDatabase.atPath(...)` are unaffected).

No backend/server in this repo — it's Flutter-only. **Supported targets are Android and Windows.** `ios/` and `web/` still exist and build, but are not actively targeted; Linux and macOS were removed (regenerate with `flutter create --platforms=linux,macos .` if they are ever wanted back).

`.claude/launch.json` defines a `triiq-web` config (`flutter run -d web-server --web-port 8765`) for previewing in the Browser pane.

## Dev-workflow notes

- `lib/client/intervalls/` is **generated**, do not hand-edit — see [docs/okf.md](docs/okf.md) for what it is. Regenerating (needs a JDK 17+ on `PATH`):

  ```bash
  java -jar openapi-generator-cli-<version>.jar generate \
    -i openapi.json \
    -g dart-dio \
    -o openapi-generator-out \
    --additional-properties=pubName=intervalls_client,pubLibrary=intervalls_client,serializationLibrary=json_serializable
  ```

  (`openapi-generator-out/` and the jar are gitignored.) Jar: download from `https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/<version>/openapi-generator-cli-<version>.jar` (get `<version>` from that path's `maven-metadata.xml`). Then copy the generated `lib/` contents over `lib/client/intervalls/`, rewrite `package:intervalls_client/` → `package:triiq/client/intervalls/` throughout, and run `dart run build_runner build --delete-conflicting-outputs`.

  **`openapi.json` carries local fixes** — re-download the spec from
  intervals.icu and you reintroduce these bugs; the live tests in
  `test/sync_live_test.dart` catch them:

  - `skyline_chart_bytes` (`Activity`, `ActivityWithIntervals`): declared
    upstream as an `array` of `string/byte`, but the API sends a single
    base64 string (Jackson serialises Java `byte[]` that way). Every
    `listActivities` call died in deserialization. Now `{"type": "string",
    "format": "byte"}`.
  - `workout_doc` (4 schemas incl. `Event`, `Workout`): its
    `additionalProperties` were non-nullable `object`, but the blob routinely
    contains nulls, killing every `listEvents` call. Now `nullable: true`.

  **Exception to reapply after regenerating**: `upload_activity_request.dart`, `upload_activity_streams_csv_request.dart`, `upload_wellness_request.dart` need hand-patched `fromJson`/`toJson` (they wrap a `MultipartFile`, which the generator can't (de)serialize as JSON — the stock generated code fails to compile). Drop `@JsonSerializable(...)` from the class (keep `@CopyWith()`), and replace the `fromJson`/`toJson` bodies with `throw UnsupportedError(...)`.

- `build.yaml` (repo root) — `json_serializable` builder options for the codegen above.
- `analysis_options.yaml` — excludes `lib/client/intervalls/src/model/*.g.dart` from the analyzer.
- **Running on Windows**: these plugins need symlink support — if `flutter run`/`flutter build` complains, enable Developer Mode (`start ms-settings:developers`).
