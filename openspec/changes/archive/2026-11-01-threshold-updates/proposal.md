# Proposal

## Why

Zones, TSS and every plan session written as % of FTP or % of threshold pace depend on the thresholds in the athlete's Intervals.icu sport settings. When those go stale, everything downstream is off, and TriIQ can only show the gap (`performance-curves` model card) — the athlete has to go to Intervals.icu to fix it.

## What Changes

- **Threshold suggestions** derived from the curves: ride FTP from Intervals.icu's model fit, run threshold pace from the pace curve, swim CSS from 400 m and 200 m bests (`(t400 - t200) / 2` per 100 m).
- Suggestions **up** when the derived value beats settings by ≥ 3 %; suggestions **down** ("likely dropped") only from recent maximal efforts with a ≥ 5 % gap — never from missing data.
- **Confirm sheet**: current → new value, the absolute zone ranges before and after, an opt-in "also recalculate HR zones", and the note that past activities keep their load; **Apply** writes to Intervals.icu, **Undo** restores the previous value.
- **Dismiss** a suggestion for 30 days.
- **Gate**: a live test first establishes that the settings update only changes the fields sent. If it does not, the change stops before any write path ships.
- Agent can explain a suggestion and open the confirm sheet; it never writes thresholds.
- en + de strings; docs.

## Capabilities

### New Capabilities
- `threshold-updates`: deriving threshold suggestions from performance curves and writing confirmed thresholds back to Intervals.icu sport settings.

### Modified Capabilities

None (`performance-curves` is still a change, not a main spec; this change depends on it).

## Impact

- Depends on: `performance-curves` (curve domain model, cache, model card).
- Code: new `lib/evaluation/threshold_suggestions.dart` (pure rules), write via `SportApi.updateSettings` in a new `lib/data/sport_settings_service.dart`, refresh of `IntervalsSession` athlete after write, suggestion card on the Performance screen (and Today when present), confirm sheet, agent tool hook, dismissal storage (shared preferences), l10n (en, de).
- External effect: changes the athlete's Intervals.icu zones and future load calculation — the first TriIQ write that alters settings rather than calendar data.
- Docs: `docs/okf.md` (agent, Intervals.icu writes, user docs, known gaps).
