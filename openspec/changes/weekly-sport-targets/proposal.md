# Proposal

## Why

Today already shows how hard the week has been (TSS, CTL/ATL/Form, load tiles) and, once a training plan is active, how far its planned load has been covered (`_WeeklyGoalProgress`). None of that answers the simpler question an athlete without — or alongside — a plan actually asks: "did I swim/bike/run enough this week?" There is no way to set a personal weekly volume goal per sport and see progress toward it at a glance.

## What Changes

- **Weekly sport targets** setting, under Settings: a weekly duration target (hours) for each of swim, cycle (bike/ride) and run, editable independently; leaving one at 0/blank means no target for that sport.
- **Three progress rings on Today** — one per sport with a target set — showing this week's completed training time against that target, colour-coded the same way the rest of the app colours swim/bike/run (`sportColor`). A sport with no target set shows no ring. The whole section is hidden when no target is set at all.
- **Show on Today** toggle in the same settings section: turns the ring row on/off independently of whether targets are set, so an athlete who sets targets only to track them in Settings isn't forced to see the ring row.
- Achieved time is read from the already-cached week's activities (same source as the load tiles and `_WeeklyGoalProgress`), grouped into swim/cycle/run the same way the rest of the app already groups activity types (`activityTypeIcon`/`sportColor`'s `contains('swim')`/`contains('ride'/'bike')`/`contains('run')`), so it works offline and needs no new sync scope.
- en + de strings; docs/okf.md.

**Assumption** (minor detail, not raised with the user): the target's unit is weekly **duration (hours)**, not distance or TSS — hours are the one unit that is meaningful and comparable across swim, bike and run, which distance and TSS are not (TSS already has its own tiles; this is a visually distinct, simpler "time in the water/saddle/on the road" goal).

## Capabilities

### New Capabilities
- `weekly-sport-targets`: a per-sport weekly training-time target the athlete sets, and its progress shown on Today as a ring per sport.

### Modified Capabilities

None.

## Impact

- New settings model `lib/screens/settings/weekly_targets_settings.dart` (`ChangeNotifier` + `shared_preferences`, same shape as `NotificationSettings`), with a new "Weekly targets" `SectionCard` on `SettingsScreen`.
- New reusable ring widget (e.g. `lib/widgets/progress_ring.dart`) and a new Today section built from the week's already-fetched `weekActivities` (`today_screen.dart`) — no new repository method, no new sync scope.
- docs/okf.md (Settings and Today sections) and en + de `.arb` strings.
- No DB schema change, no new Intervals.icu data: everything is derived from activities already cached for the TSS-week tile.
