# Design

## Context

Thresholds live in Intervals.icu `SportSettings` (`ftp`, `indoorFtp`, `lthr`, `maxHr`, `thresholdPace`, zone lists as % of threshold), read at connect via `getAthlete` and exposed through `IntervalsSession.settingsForSport`. The write endpoint is `SportApi.updateSettings(athleteId, id, recalcHrZones, sportSettings)`. Serialization uses `include_if_null: false` (`build.yaml`), so only non-null fields are sent — but whether the server treats the PUT as a partial update is unverified. Curves, model fits and the cache come from `performance-curves`. Plan sessions written by TriIQ use % of FTP / threshold pace, so they follow a threshold change automatically. See proposal.md.

## Goals / Non-Goals

**Goals:** conservative, explainable suggestions for ride FTP, run threshold pace and swim CSS; a confirmed, reversible single-field write.

**Non-Goals:** editing zone boundaries; LTHR/max-HR suggestions; indoor-FTP handling beyond leaving it untouched; dated threshold history; rewriting past load.

## Decisions

1. **Live gate first.** A live test reads the Ride settings, sends a `SportSettings` with only `id` and `ftp` (current value + 1), reads back, asserts every other field is unchanged, then restores the original. If any field changes, stop and report: the fallback would be read-modify-write of the full object, which is a design change needing review (it risks clobbering fields the generated model doesn't know).
2. **Rules are pure Dart** in `lib/evaluation/threshold_suggestions.dart` over (curve periods, settings, now, dismissals) → `List<ThresholdSuggestion>` (sport, field, current, candidate, direction, basis text, efforts used). Thresholds: +3 % up, −5 % down with a maximal effort ≤ 30 days old, efforts ≤ 90 days. Kept as named constants, not in `okf-rules` (agent-only knowledge vs. engine rules stay separate).
3. **"Maximal effort"** for a decrease: an activity in the last 30 days whose value at the reference duration is within 2 % of that activity's own curve at the period's best — i.e. the athlete actually went hard. For ride: any 20-min+ effort within 5 % of the season best over that duration. Conservative by design; tuned with fixtures.
4. **Run threshold pace** = best sustained pace for ~40-60 min from the pace curve (use the 60-min point if present, else the 40-min point scaled by 1.02 — note: a heuristic, labelled as such in the basis text). Swim CSS from 400/200 m as specified.
5. **Writer** `SportSettingsService.updateThreshold(sport, field, value, {recalcHrZones})` builds a minimal `SportSettings(id, <field>)`, calls `updateSettings`, then re-fetches the athlete so `settingsForSport` and the model card reflect the new value. Undo calls the same with the previous value captured before the write.
6. **Zone preview** computed locally from the zone percentage lists × old/new threshold; no server call.
7. **Dismissals** in shared preferences keyed by sport+direction, storing the dismissed candidate and date.
8. **Agent**: a read tool returning current suggestions, and a UI hand-off (like plan proposals) that opens the confirm sheet; no write tool.

## Risks / Trade-offs

- [PUT is a full replace] → decision 1 gates the write; nothing ships without it.
- [Wrong suggestions erode trust] → conservative thresholds, the efforts used are listed in the sheet, dismiss for 30 days.
- [Indoor FTP diverges] → left untouched and mentioned in the sheet when set.
- [Changing FTP shifts zones for upcoming planned sessions] → stated in the sheet; this is the intended effect.
- [Live test writes to the real account] → it restores the original value in a `tearDown`, and runs only with `INTERVALS_API_KEY`.

## Migration Plan

No schema change. Rollback: remove the UI; any thresholds written stay in Intervals.icu (athlete can undo there).

## Open Questions

- Run threshold heuristic (decision 4) may need tuning against real data; fixtures from the live account should drive it.
