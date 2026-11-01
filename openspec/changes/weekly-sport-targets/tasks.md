# Tasks

## 1. Settings

- [x] 1.1 `canonicalSport(String? type)` helper in `lib/screens/activities/activity_icons.dart`, reusing `activityTypeIcon`/`sportColor`'s existing `contains('swim'|'ride'/'bike'|'run')` checks; verify unit tests for `Ride`, `VirtualRide`, `GravelRide`, `Run`, `VirtualRun`, `Swim` and an unmatched type (`null`)
- [x] 1.2 `WeeklyTargetsSettings` (`lib/screens/settings/weekly_targets_settings.dart`): `ChangeNotifier` singleton over `shared_preferences`, `double?` swim/cycle/run hour targets (blank/0 = unset) and `showOnToday` (default `true`), same `load()`/setter shape as `NotificationSettings`; verify unit tests for load defaults, persistence across a fresh `load()`, and 0/blank normalizing to unset
- [x] 1.3 "Weekly targets" `SectionCard` on `SettingsScreen`, inserted after Calendar: three numeric fields (swim/cycle/run hours, one decimal place, empty allowed) and the "Show on Today" switch; en + de; verify widget tests for entering/clearing a value and toggling the switch

## 2. Today

- [x] 2.1 `weeklySportSeconds(List<LocalActivity>)` pure function folding `movingTime` by `canonicalSport` over the week's activities; verify unit tests for mixed types (e.g. `Ride` + `VirtualRide` summing into one cycle total) and an empty list
- [x] 2.2 `ProgressRing` widget (`lib/widgets/progress_ring.dart`): `CustomPainter` arc, percentage capped visually at 100%, label with achieved/target and the sport's `sportColor`, switching to `colorScheme.tertiary` once achieved >= target; verify widget tests for under target, at/over target, and the capped-arc behaviour past 100%
- [x] 2.3 Weekly-targets row on Today (`today_screen.dart`), reusing the already-fetched `weekActivities`: one `ProgressRing` per sport with a target set, hidden when `showOnToday` is off or no target is set at all, placed after `_MetricTiles`; en + de; verify widget tests for zero targets (section hidden), one/two/three targets, and the toggle off case

## 3. Docs

- [x] 3.1 Update docs/okf.md (Settings section: new "Weekly targets" card; Today section: the ring row and what hides it); verify the sections match the shipped behaviour
