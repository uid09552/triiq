# Spec Delta

## Purpose

Keeps the saved training plan realistic as the week unfolds: detects missed sessions, weeks well off their target load and hard sessions on low-readiness days, and proposes adjustments that only take effect when the athlete applies them.

## ADDED Requirements

### Requirement: Missed-session detection
The system SHALL treat a plan session as missed when its date is before today, within the current plan week, and no cached activity on that date has the same sport family. Sessions in earlier weeks SHALL NOT be reported as missed.

#### Scenario: Interval session skipped
- **WHEN** Tuesday's run interval session has no run activity on Tuesday and today is Thursday of the same week
- **THEN** Tuesday's session is detected as missed

#### Scenario: Done on another sport
- **WHEN** Tuesday's planned run has only a ride activity on Tuesday
- **THEN** the run is detected as missed

#### Scenario: Last week
- **WHEN** a session from the previous plan week was not done
- **THEN** it is not reported

### Requirement: Rescheduling a missed hard session
For a missed interval or long session, the system SHALL suggest moving it to the earliest training day later in the same plan week that would not exceed the goal's sessions per day and is not directly before or after a day holding another interval or long session. When no day fits, it SHALL suggest letting the session go.

#### Scenario: Free day available
- **WHEN** Tuesday's intervals were missed, today is Wednesday, Thursday is a free training day and Saturday has the long run
- **THEN** the suggestion is to move the intervals to Thursday

#### Scenario: No day fits
- **WHEN** every remaining training day this week is next to another hard session or full
- **THEN** the suggestion is to let the session go

### Requirement: Missed easy session
For a missed Z2 or recovery session, the system SHALL suggest letting it go rather than moving it.

#### Scenario: Z2 missed
- **WHEN** Monday's Z2 ride was missed
- **THEN** the suggestion is to let it go, and no move is offered

### Requirement: Week load off target
After a plan week ends, the system SHALL compare its actual load with its target. Under 80 %, it SHALL suggest lowering the next week's load to at most the actual load plus the goal's weekly increase. Over 120 %, it SHALL suggest capping the next week at the ended week's target. The suggested load SHALL stay within the 80-120 % range of the proposal, and the card SHALL say when the floor limits it.

#### Scenario: Sick week
- **WHEN** week 3 had a target of 500 TSS and an actual of 250 TSS, the weekly increase is 10 % and week 4's proposal is 550 TSS
- **THEN** the suggestion sets week 4 to 80 % of its proposal (440 TSS) and says the 80 % floor kept it above 275 TSS

#### Scenario: Overreaching week
- **WHEN** week 3 had a target of 500 TSS and an actual of 650 TSS, and week 4 is targeted at 550 TSS on a proposal of 550 TSS
- **THEN** the suggestion sets week 4 to 500 TSS (factor 0.91)

#### Scenario: On target
- **WHEN** a week's actual load is 95 % of its target
- **THEN** no load suggestion is made

### Requirement: Readiness conflict
When the daily readiness status is Caution or Back off and today has an interval or long plan session, the system SHALL suggest swapping it with the next Z2 session later in the same week, or moving it to the next fitting day by the rescheduling rule when there is no Z2 session.

#### Scenario: Swap with tomorrow's Z2
- **WHEN** readiness is Back off, today has intervals and tomorrow has a Z2 run
- **THEN** the suggestion is to swap today's intervals with tomorrow's Z2 run

#### Scenario: Readiness unavailable
- **WHEN** no readiness status can be computed
- **THEN** no readiness suggestion is made

### Requirement: Suggestions need confirmation
The system SHALL show each suggestion on Today as a card with what it changes, Apply and Dismiss, and SHALL change the plan only when the athlete applies it. Applying SHALL also update sessions already written to Intervals.icu, and a failure SHALL leave the plan unchanged and show the error.

#### Scenario: Applying a move
- **WHEN** the athlete applies "Move intervals to Thursday" for a session that was sent to Intervals.icu
- **THEN** the session is on Thursday in both the plan and Intervals.icu

#### Scenario: Upstream failure during a swap
- **WHEN** the second move of a swap fails in Intervals.icu
- **THEN** the first move is reverted and the card shows the error

### Requirement: Dismissed suggestions stay dismissed
The system SHALL remember a dismissed suggestion and SHALL NOT show the same suggestion for the same session or week again, including after an app restart. A suggestion SHALL disappear without being dismissed once its situation no longer holds.

#### Scenario: After restart
- **WHEN** the athlete dismissed the missed-intervals suggestion and restarts the app
- **THEN** that suggestion is not shown again

#### Scenario: Session done late
- **WHEN** a missed session's suggestion is showing and an activity for it on that date then syncs
- **THEN** the suggestion disappears

### Requirement: Agent uses the same rules
The training agent SHALL be able to list the current suggestions and offer them in chat as proposal cards produced by the same rules, and SHALL NOT apply them itself.

#### Scenario: Asking in chat
- **WHEN** the athlete tells the agent they missed Tuesday's intervals
- **THEN** the agent offers the same move suggestion that Today shows, as a card to apply or dismiss
