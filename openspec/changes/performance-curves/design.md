# Design

## Context

The generated client exposes `listAthletePowerCurves` / `listAthletePaceCurves` / `listAthleteHRCurves` (`aktivitten_api.dart`) taking `type` (sport) and `curves` (period specs such as `s0`, `s1`, `42d`, `r.<from>.<to>`). Power and HR curves carry `secs[]`, `values[]`, `activity_id[]` (power also `watts_per_kg[]` and `powerModels[]`: FTP, CP, W', Pmax). Pace curves are keyed by `distance[]` (metres) with `values[]` in seconds and carry `paceModels[]` (critical speed, D'). The generated methods require `f1`/`f2`/`f3` filter lists, and the models are generated with `disallow_unrecognized_keys`, so any new server field breaks deserialization. Thresholds come from `IntervalsSession.settingsForSport`. Charts are hand-rolled `CustomPainter`s; `MetricLineChart` is index-based (one value per label), not suited to a log-time axis. Activity streams are cached in SQLite as a JSON blob per key (`activity_streams`) — the pattern to reuse. Live tests in `test/sync_live_test.dart` already catch spec/deserialization bugs (`openapi.json` has local fixes). See proposal.md.

## Goals / Non-Goals

**Goals:** season-over-season curves per sport and metric; source-session drill-down; model vs settings gap; offline after first open; agent read access.

**Non-Goals:** changing thresholds (→ `threshold-updates`); custom date ranges in the UI (only fixed periods for now); power-duration modelling of our own; comparing with other athletes.

## Decisions

0. **Fetch raw JSON through the client's `dio`** (`GET /api/v1/athlete/0/{power|pace|hr}-curves.json?type=..&curves=s0,s1,42d`) and parse it defensively, as `personalBests` does with `icu_achievements`. Alternative: the generated `listAthlete*Curves` — rejected for the mandatory filter lists and the brittle strict deserialization.
1. **One fetch per (sport, metric) with all periods**: `curves=s0,s1,42d`. Fewer calls, consistent model fits. Store the response JSON in a new table `performance_curves` (key `sport|metric`, data, fetched_at) — same blob pattern as `activity_streams`; schema bump to the next version (v5, or v6 if `okf-import` lands first).
2. **Staleness**: the cache row stores the newest cached activity id of that sport family at fetch time; it is stale when the newest one now differs (a new activity was synced). `synced_at` is not used — it changes on every re-sync even without new activities. Checked on open; no work during sync itself.
3. **Parse to a small domain model** (`CurvePeriod { label, points: [(secs or metres, value, activityId)], model? }`) in `lib/evaluation/performance_curves.dart`, pure Dart, so the screen, table and agent tool share one interpretation. Pace curves (run and swim) are keyed by distance; the parser exposes distance points for them.
4. **New `DurationCurveChart`** in `lib/widgets/charts/`: log10 x-axis with fixed tick labels (time: 5s, 30s, 1m, 5m, 20m, 1h, 2h; distance: 100 m … 21 km; swim: 50 … 1500 m), y-axis title and unit, multiple series, drag readout. Pace is plotted as speed internally (so faster = higher) and labelled in pace units. Alternative: extend `MetricLineChart` — rejected, its index-based x-axis would need a rewrite and risk the existing screens. Axis title/unit support is written so `chart-readability` can later reuse it.
5. **Key durations** use the curve point at exactly that duration (or distance). If the curve has no such point, the cell stays empty — no interpolation, so no invented efforts.
6. **Model gap** compares `powerModels` FTP with `SportSettings.ftp`, and `paceModels` critical speed with `SportSettings.thresholdPace` (both m/s). The model used is the first one returned for the current season. Threshold derivation beyond the model lives in `threshold-updates`.
7. **Agent tool `get_performance_curve(sport, metric)`** returns periods, key durations with activity ids/dates, and the model gap. Read-only.
8. **Live test** for each of the three endpoints and sports the account has, asserting deserialization succeeds; fix `openapi.json` locally (and document under CLAUDE.md's list) if the spec is wrong, as with `skyline_chart_bytes`.

## Risks / Trade-offs

- [Spec/response mismatch on curve endpoints] → live test first (task 1.1); `listActivityPaceCurves` is already generated as `void`, a sign the curve schemas may be loose.
- [Large responses: one point per second up to many hours] → keep raw JSON but downsample points for painting (log-spaced buckets, ~200 points).
- [Season boundaries confuse athletes] → legend shows the actual date ranges returned.
- [Run pace curves include downhill/GPS spikes] → show as Intervals.icu returns them; no filtering of our own.

## Migration Plan

Additive table, empty on upgrade. Rollback: ignore the table.

## Open Questions

- Whether to offer W/kg as a toggle on power curves (data is there; UI choice). Default: W, with W/kg in the readout.
