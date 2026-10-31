# Spec Delta

## Purpose

Lets the athlete shape what a plan week is made of (Z2, intervals, long endurance) and where its sessions fall (long and interval days, sessions per day).

## ADDED Requirements

### Requirement: Session mix
The goal SHALL hold shares of each sport's weekly load for Z2, Intervals and Long endurance, in 5% steps summing to 100%, defaulting to the goal type's template shares. The plan engine SHALL split each sport's weekly load by these shares (swim has no long session; its Z2 and interval shares are renormalised). The 80/20 check SHALL still flag weeks with too little easy time.

#### Scenario: More intervals
- **WHEN** the athlete sets Z2 20%, Intervals 50%, Long 30% for a 400-TSS run week
- **THEN** the interval session carries more of the week than with the template mix (up to what its template's repeats allow, so it is never stretched past a sensible length), Z2 carries less, and if easy time falls below the 80/20 tolerance the week is flagged

#### Scenario: Default mix
- **WHEN** a goal saved before this change is loaded
- **THEN** its mix shows the goal type's template shares and plans are unchanged

#### Scenario: Invalid total
- **WHEN** the shares add up to 95%
- **THEN** the goal cannot be saved and the editor shows the total

### Requirement: Long-session day
The goal SHALL let the athlete pick a preferred weekday for the long session, per sport for triathlon (Ride, Run) and one for a single-sport goal, chosen from the training days. Placement SHALL put the long session on that day when it is a training day and has room. Otherwise it SHALL fall back to the default placement and the week card SHALL note that the preference couldn't be met. The long ride and long run MUST still be on different days.

#### Scenario: Long ride Saturday, long run Sunday
- **WHEN** a triathlon goal prefers long ride Saturday and long run Sunday and both are training days
- **THEN** every week's long ride is on Saturday and long run on Sunday

#### Scenario: Same day for both
- **WHEN** both long sessions prefer Saturday
- **THEN** the editor shows that they must differ and does not save

#### Scenario: Preferred day removed
- **WHEN** the athlete later unticks Saturday as a training day
- **THEN** the Saturday preference is cleared and placement uses the default rule

### Requirement: Interval days
The goal SHALL let the athlete pick zero or more preferred weekdays for interval sessions, from the training days. Placement SHALL put interval sessions on those days first, never on the same day as a long session of the same sport, and SHALL fall back to the default (spread away from long sessions) for any that don't fit.

#### Scenario: Tuesday intervals
- **WHEN** intervals are preferred on Tuesday and the goal trains Tue/Thu/Sat
- **THEN** the interval session is on Tuesday every build week

### Requirement: Max sessions per day
The goal SHALL hold a maximum of sessions per day, 1 or 2 (default 2 for triathlon, 1 for one sport). Placement SHALL NOT exceed it. When the kept sessions don't fit, generation SHALL report that more days or a higher limit are needed.

#### Scenario: Triathlon with one session a day
- **WHEN** a triathlon goal with 5 training days is set to 1 session per day and a week needs 7 sessions
- **THEN** Z2 sessions are dropped first to fit 5; if the sessions a week must keep still exceed 5, generation reports it

### Requirement: Agent sees and proposes the settings
`get_training_plan` SHALL report the ramp, the hold setting, the session mix and the preferences. `propose_load_curve` SHALL accept `ramp_percent` (0–15) and `hold_every_4th` (true/false) as proposal edits, validated like the slider and switch.

#### Scenario: Agent proposes a gentler ramp
- **WHEN** the agent calls propose_load_curve with ramp_percent 6
- **THEN** the proposal's graph is drawn at +6% a week with the hold rule, and nothing is saved until the athlete applies it
