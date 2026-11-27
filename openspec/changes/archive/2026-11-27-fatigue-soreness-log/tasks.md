# Tasks

## 1. Wellness write path

- [x] 1.1 Add `WellnessActions` in `lib/data/wellness_actions.dart` with `Future<LocalWellness> setFeel({required String date, required int fatigue, required int soreness})`: calls `client.getWellnessApi().updateWellness(id: athleteId, date: date, wellness: Wellness(fatigue: fatigue, soreness: soreness))`, converts the response with `LocalWellness.fromApi`, caches it via `WellnessRepository.upsertAll`, calls `AutoSyncService.instance.notifyCacheChanged()`, and throws `StateError` when not connected (no client/athleteId); verify `flutter analyze` is clean.
- [x] 1.2 Add a unit test (`test/wellness_actions_test.dart`) covering: a connected call sends fatigue/soreness, caches the server's response, and notifies listeners; a disconnected call throws without touching the cache; verify with `flutter test test/wellness_actions_test.dart`.

## 2. Settings and prompt tracking

- [x] 2.1 Add `FeelSettings` in `lib/data/feel_settings.dart` (`ChangeNotifier`, `instance`/`forTesting()`, `SharedPreferences`-backed), one field `promptOnNewActivity` defaulting to `true`, following `SyncSettings`'s load/save shape; verify `flutter analyze` is clean.
- [x] 2.2 Add `FeelPromptStore` in `lib/data/feel_prompt_store.dart` (same shape as `ThresholdDismissalsStore`): persists the set of activity ids already auto-prompted, with `hasPrompted(String activityId)` and `recordPrompted(String activityId)`; verify `flutter analyze` is clean.
- [x] 2.3 Add unit tests (`test/feel_settings_test.dart`, `test/feel_prompt_store_test.dart`) for load defaults, persisting a change across a fresh `load()`, and `hasPrompted`/`recordPrompted` round-tripping; verify with `flutter test test/feel_settings_test.dart test/feel_prompt_store_test.dart`.

## 3. Feel dialog

- [x] 3.1 Add `showFeelDialog(BuildContext context, {required String date, int? initialFatigue, int? initialSoreness})` in `lib/screens/activities/feel_dialog.dart`: two `SegmentedButton<int>` rows (fatigue, soreness; 1-4, "1 good, 4 bad" labels), prefilled from the initial values when given, a Save button calling `WellnessActions.setFeel` and a Cancel that makes no call; add the new en+de l10n strings it needs; verify `flutter analyze` is clean.
- [x] 3.2 Add a widget test (`test/screens/activities/feel_dialog_test.dart`) covering: prefilled values show when given; Save calls `setFeel` with the selected values and closes; Cancel closes without calling it; verify with `flutter test test/screens/activities/feel_dialog_test.dart`.

## 4. Activity detail screen entry points

- [x] 4.1 Convert `ActivityDetailScreen` (`lib/screens/activities/activity_detail_screen.dart`) to a `StatefulWidget`; add a "How did it feel?" action, enabled only when connected, that opens `showFeelDialog` prefilled from the activity's day's cached wellness; verify `flutter analyze` is clean.
- [x] 4.2 In its `initState`, add the auto-prompt check: `FeelSettings.instance.promptOnNewActivity` is on, the activity's date is today or yesterday, `FeelPromptStore` has no record for its id, and the day's cached wellness has neither fatigue nor soreness set — then show `showFeelDialog` once and call `FeelPromptStore.recordPrompted` regardless of Save or Cancel; verify `flutter analyze` is clean.
- [x] 4.3 Add widget tests (in a new `test/screens/activities/activity_detail_screen_test.dart` or extending an existing one) covering: the manual action works on an old activity; a recent, never-opened activity with no wellness set auto-prompts once and not again on a second open; no auto-prompt when the day already has values, the toggle is off, or the activity is older than yesterday; the manual action is disabled/explains itself when not connected; verify with `flutter test` on that file.

## 5. Settings screen toggle

- [x] 5.1 Add a `SwitchListTile` for `FeelSettings.instance.promptOnNewActivity` to `lib/screens/settings/settings_screen.dart`, in its own small section alongside the sync/calendar sections, with new en+de l10n strings; verify `flutter analyze` is clean.
- [x] 5.2 Add a widget test for the Settings screen confirming the toggle flips `FeelSettings.instance.promptOnNewActivity` and the change persists across a reload; verify with `flutter test`.

## 6. Docs

- [x] 6.1 Update docs/okf.md to document the manual "How did it feel?" action, the new-activity auto-prompt and its Settings toggle, and that both feed the existing Readiness evaluation; verify by re-reading the updated section for accuracy.

## 7. Verification

- [x] 7.1 Run `flutter analyze` and `flutter test` for the full suite and verify both are clean (aside from any pre-existing, unrelated failure already present on `main`).
