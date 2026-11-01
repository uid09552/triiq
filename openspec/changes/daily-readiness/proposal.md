# Proposal

## Why

Wellness data (HRV, resting HR, sleep, the subjective scores) already syncs into the cache with each Intervals.icu wellness record, but only the chat agent reads it. On Today the athlete sees load (CTL/ATL/Form) and no sign of whether their body is recovered, so the most useful daily signal for deciding "go hard or back off" is hidden behind a chat question.

## What Changes

- A **daily readiness status** (Ready / Caution / Back off), computed on the device from today's wellness record against the athlete's own baselines: HRV and resting HR against their 60-day normal, last night's sleep, form (TSB) and the subjective fatigue/soreness scores. The status comes with the reasons behind it. There is no single 0-100 score.
- When the athlete's device writes a readiness value to Intervals.icu, it is shown alongside as the device's own figure.
- **Readiness tile on Today**, which opens a detail screen with each signal's value, its normal range and a 30-day trend for HRV and resting HR.
- **Hint** on Today when the status is Caution or Back off and today has a hard plan session (intervals or long), with **Ask the trainer** to open the chat on that question.
- States for missing data: no wellness at all (hint to connect a device in Intervals.icu), today not synced yet, and not enough history for a baseline (per signal).
- Thresholds live in the training knowledge (`okf-rules`), not in code.
- **Agent tool** `get_readiness` returning the same status and reasons, so chat answers match the tile.
- en + de strings; docs/okf.md.

## Capabilities

### New Capabilities
- `daily-readiness`: deriving a daily readiness status from synced wellness data and showing it on Today and to the agent.

### Modified Capabilities

None.

## Impact

- New pure module `lib/evaluation/readiness.dart` reading `WellnessRepository.getRange`, with no new sync scope (wellness already syncs).
- `lib/plan/knowledge.dart` + docs/okf.md §5.1 (readiness thresholds).
- Today screen (tile and hint), new readiness detail screen, `lib/agent/tools/training_data_tools.dart` (new tool) and the system prompt.
- No DB schema change: signals are read from `raw` on existing wellness rows.
- Used by the `adaptive-replan` change as a trigger.
