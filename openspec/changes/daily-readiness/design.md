# Design

## Context

- `LocalWellness` promotes only CTL/ATL/ramp to columns. Everything else, including `hrv`, `restingHR`, `sleepSecs`, `sleepScore`, `readiness`, `fatigue` and `soreness`, sits in `raw` (the API JSON). `training_data_tools.dart` already reads these keys for the agent.
- `WellnessRepository.getRange(oldest, newest)` returns the cached rows for a date range. Wellness syncs with activities and events (`_syncScopes`) on open, on manual sync and nightly on Android.
- `athlete_detail_screen.dart` already digs the latest HRV out of wellness for display.
- §5.1 `okf-rules` already holds `recoveryFormPenaltyBelow: -20`.

## Goals / Non-Goals

**Goals:** one pure, testable rule set used by the tile, the detail screen, the agent tool and (later) `adaptive-replan`.

**Non-Goals:** a numeric readiness score; push notifications about readiness; writing anything to Intervals.icu; using readiness to change the plan automatically (that is `adaptive-replan`, and it still goes through Apply/Dismiss); HRV measurement in the app.

## Decisions

1. **Pure function over a window of records.** `Readiness evaluate(List<LocalWellness> last61Days, DateTime today, ReadinessRules rules)` in `lib/evaluation/readiness.dart`, in the style of `insights.dart` and `session_evaluator.dart`: no I/O, so every scenario becomes a unit test. A thin `ReadinessService` loads the window and the rules. *Alternative:* computing it in the widget. Rejected: the agent tool and replan need the same result.

2. **Status levels instead of a score.** Three levels with named reasons. A 0-100 number would suggest a precision that HRV/RHR z-scores don't have, and devices already produce their own numbers. We show the device figure but don't mix it in, so we never double-count the same HRV.

3. **Baseline = 60 days before today, excluding today**, with a minimum of 14 values. Mean ± SD for HRV, mean for resting HR. Only today's HRV is compared, not a 7-day rolling mean. Rolling HRV is better practice but hides the acute dip the athlete wants to see this morning. Recorded as a trade-off: the threshold is 1 SD, not 0.5, to limit day-to-day noise.

4. **Rules in the knowledge**, as a `readiness` object in the §5.1 `okf-rules` block (`hrvSd: [1, 2]`, `restingHrBpm: [5, 10]`, `sleepHoursCaution: 6`, `form: [-20, -30]`, `minBaselineDays: 14`, `baselineDays: 60`), parsed by `knowledge.dart` with defaults validated at load. The form caution value matches the existing `recoveryFormPenaltyBelow`. They stay separate keys so either can change on its own.

5. **Subjective scores**: Intervals.icu stores `fatigue` and `soreness` as 1-4. Task 1.1 confirms with the live suite which end is worst before the rule hard-codes it, so the rule reads "worst level" from a constant.

6. **Hard session** = a plan session whose slot is `intervals` or `long`, or an Intervals.icu planned event the existing `SessionEvaluator.intentOf` classifies as hard. That reuses the classifier rather than inventing a second one.

7. **Ask the trainer** opens the chat with a prefilled message ("My readiness is Caution (HRV low). Should I still do today's intervals?"). The agent then calls `get_readiness` and can propose session changes through the existing proposal cards.

8. **Tile placement**: a new full-width row above the six load tiles, because readiness answers a different question (today's body) than load (training history). The detail screen reuses the existing chart widgets for the 30-day trend.

## Risks / Trade-offs

- [Athletes without a wearable see little] → form is always rated, and the empty state explains what to connect, so the tile is never blank.
- [HRV sources differ (rMSSD vs SDNN, morning vs overnight)] → use `hrv` (rMSSD) only, never mix in `hrvSDNN`, and compare only to the athlete's own baseline.
- [Today's record syncs before the device uploads] → "waiting for today's data" state, and the tile refreshes on the next auto-sync like the other tiles.
- [Thresholds are generic] → in the knowledge, documented as defaults, not medical advice. The detail screen says so in one line.
