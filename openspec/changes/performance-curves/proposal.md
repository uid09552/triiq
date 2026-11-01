# Proposal

## Why

TriIQ shows load (CTL/ATL/TSS) but can't answer "am I getting faster?". Intervals.icu already computes power, pace and HR duration curves with model fits (FTP, CP, W'), and the generated client has the endpoints (`listAthletePowerCurves`, `listAthletePaceCurves`, `listAthleteHRCurves`), but the app only reads per-activity `icu_achievements`.

## What Changes

- **Performance screen** (Statistics → Performance): sport picker (Ride / Run / Swim) and metric picker (Power / Pace / HR, as available for the sport).
- **Duration curve chart** on a log-time x-axis comparing this season with last season (and optionally the last 42 days), with axis titles, units and a tap readout naming the session that set the best and opening it.
- **Key durations table** (e.g. 5 s, 1 min, 5 min, 20 min, 60 min; swim by distance: 100 / 200 / 400 / 1500 m) with the season-over-season delta.
- **Model card**: Intervals.icu's fitted FTP / CP / W' / Pmax next to the threshold currently in the athlete's sport settings, showing the gap. Read-only here; updating is the `threshold-updates` change.
- **Fetch on open, cache locally**, refresh after a sync that brought new activities; works offline from the cache.
- **Agent tool** `get_performance_curve` (read-only).
- en + de strings; docs.

## Capabilities

### New Capabilities
- `performance-curves`: fetching, caching, charting and comparing duration curves and model fits per sport, and exposing them to the agent.

### Modified Capabilities

None.

## Impact

- Code: new `lib/evaluation/performance_curves.dart` (fetch + parse + cache), SQLite schema bump (table `performance_curves`), new log-time chart in `lib/widgets/charts/`, new `lib/screens/statistics/performance_screen.dart`, entry on `statistics_screen.dart`, tool in `lib/agent/tools/training_data_tools.dart`, l10n (en, de).
- API: the three athlete curve endpoints in `aktivitten_api.dart` (already generated). A live test guards their deserialization, as for activities and events.
- Docs: `docs/okf.md` (charts, statistics, agent, local storage).
- Follow-up: `threshold-updates` builds on the model card.
