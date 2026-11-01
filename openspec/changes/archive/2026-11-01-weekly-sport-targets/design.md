# Design

## Context

- `today_screen.dart` already fetches `weekActivities` for the current Monday-Sunday week (`SyncService.todayWindow()` + `_activitiesRepository.getRange`) to compute `_weekLoad` (total TSS). The same list has everything needed for per-sport duration: `LocalActivity.type` and `movingTime`.
- `lib/screens/activities/activity_icons.dart` already has `activityTypeIcon(String? type)` and `sportColor(String? type, ColorScheme scheme)`, both normalizing on `type.toLowerCase().contains('swim' | 'ride'/'bike' | 'run')`. This is the de-facto canonical grouping used everywhere activities are shown (Statistics "By sport" groups by the *raw* type instead, which is intentionally finer-grained for that screen, but icons/colours already collapse `VirtualRide`, `GravelRide`, etc. into one bucket).
- Settings persistence precedent: `NotificationSettings` (`lib/notifications/notification_settings.dart`) — a `ChangeNotifier` singleton, `load()` reads `shared_preferences` once, each setter writes through and calls `notifyListeners()`. `SettingsScreen` composes sections as `SectionCard`s, each backed by its own small settings class so unrelated toggles don't rebuild each other.
- `_WeeklyGoalProgress` on Today already shows a plan-based weekly load bar (`LinearProgressIndicator`) with a primary/tertiary colour switch once the target is reached. No ring/arc widget exists yet anywhere in the app.

## Goals / Non-Goals

**Goals:** a simple, offline, per-sport weekly time goal independent of the training plan; a small reusable ring widget; a settings section matching existing conventions exactly.

**Non-Goals:** distance or TSS-based targets (hours only, see proposal's assumption); per-day pacing/reminders; editing the ring from Today (Settings is the only place to change a target); any new Intervals.icu sync or write-back; replacing or touching `_WeeklyGoalProgress` (that stays the plan-based bar it already is).

## Decisions

1. **Target unit = hours, stored as `double?` per sport.** `null`/unset (UI: blank field, not "0") means no target. Three keys, `targets.swim_hours`, `targets.cycle_hours`, `targets.run_hours`, plus `targets.show_on_today` (`bool`, default `true`), in `shared_preferences` — no new DB table, so nothing to migrate. *Alternative considered:* distance or weekly TSS per sport. Rejected: TSS already has the week tile and isn't swim/bike/run-comparable anyway (it's `trainingLoad`, already totalled across sports there); distance units differ per sport (km vs. m) and would need per-sport unit pickers for no real benefit over hours.

2. **New settings class `WeeklyTargetsSettings`** (`lib/screens/settings/weekly_targets_settings.dart`), same shape as `NotificationSettings`: singleton `instance`, `isLoaded`, `load()`, one setter per field (`setSwimHours`, `setCycleHours`, `setRunHours`, `setShowOnToday`), each setter short-circuiting on an unchanged value, notifying, then persisting. Settings screen gets a new `SectionCard` (icon `Icons.track_changes_outlined` or similar) with three numeric `TextField`s (one decimal place, empty = no target) and the "Show on Today" `SwitchListTile`, inserted after the Calendar section and before LLM provider — grouped with the other "what Today shows" toggles rather than buried at the end.

3. **Canonical sport grouping reused, not reinvented.** Add one small helper next to the existing ones, `String? canonicalSport(String? type)` in `activity_icons.dart`, returning `'swim'`/`'cycle'`/`'run'`/`null` using the exact same `contains` checks `activityTypeIcon`/`sportColor` already use, so a `VirtualRide` or `GravelRide` counts as cycle without a second classification scheme drifting out of sync with the icons/colours the athlete already associates with each sport. `sportColor` itself is reused directly for the ring colour (passing `'Ride'`/`'Run'`/`'Swim'` as a stand-in type string), so the ring colour always matches the rest of the app without a parallel colour table.

4. **Achieved time from the already-fetched `weekActivities`.** `today_screen.dart` already loads this list for `_weekLoad`; a small pure function `Map<String, int> weeklySportSeconds(List<LocalActivity> weekActivities)` (co-located with the new ring section widget) folds `movingTime` by `canonicalSport`. No new repository call, no new sync scope, works offline exactly like the load tiles.

5. **New `ProgressRing` widget** (`lib/widgets/progress_ring.dart`): a `CustomPainter`-backed circular arc (background track + progress arc, rounded `StrokeCap.round`), percentage visually capped at 100% so an over-achieved sport doesn't draw past a full circle, with a label/value below or centred (sport name + "x.x / y h"). Colour switches from the sport's accent to `colorScheme.tertiary` once `achieved >= target` — the same "done" signal `_WeeklyGoalProgress` already uses for its bar, kept consistent across the two weekly-progress UIs. Pure, stateless, no Flutter chart dependency, so it's trivially widget-testable (golden-free: assert on painted `CustomPaint` data isn't needed, assert on the rendered percentage/label text is enough).

6. **Placement on Today**: a new `SectionCard`-free row (rings read fine without the icon+title chrome `SectionCard` adds, same as `_MetricTiles`' tile grid) directly after `_MetricTiles` and before "Today's activities" — grouped with the other weekly load/metric information rather than down in the "today's/tomorrow's training" block where `_WeeklyGoalProgress` (a different, plan-based figure) already lives, so the two "weekly progress" UIs aren't shown back-to-back and confused for the same thing.

7. **Hiding rules**: the section widget itself returns `SizedBox.shrink()` when `!showOnToday` or when every target is unset — computed once in the row widget, not duplicated in `today_screen.dart`'s build method, so Today's build stays a flat list of sections like today.

## Risks / Trade-offs

- [Hours-only target excludes someone who thinks in distance] → documented as a deliberate default in docs/okf.md; distance/TSS targets are a clear, separable follow-up if asked for, not blocked by this design (same settings card, additional fields).
- [`canonicalSport`'s `contains` matching could mis-bucket an unusual Intervals.icu type] → it's the exact same matching already governing that activity's icon and colour everywhere else in the app, so a mis-bucket here is already a pre-existing mis-bucket the athlete would notice elsewhere too, not a new failure mode.
- [Week boundary mid-week edits] → targets changed mid-week apply retroactively to the week already in progress (simplest behaviour, matches how the plan's weekly load target also just reads "this week" live); not worth a "starts next week" rule for a manually-set personal goal.
