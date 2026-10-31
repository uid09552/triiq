# Spec Delta

## Purpose

Lets the athlete set a training target and receive a periodised 4-week block of planned sessions, checked against the 80/20 intensity split and placed on their Intervals.icu calendar.

## ADDED Requirements

### Requirement: Training goal
The system SHALL let the athlete define a goal with a target type (at least long distance), an optional event date, the weekdays available for training and a weekly hours budget, and SHALL persist it locally.

#### Scenario: Goal saved
- **WHEN** the athlete saves a goal with target "long distance", Tuesday/Thursday/Saturday available and 6 hours per week
- **THEN** the goal is stored and is used by the next plan generation after an app restart

#### Scenario: Event date in the past
- **WHEN** the athlete enters an event date earlier than today
- **THEN** the system rejects the goal and explains why

### Requirement: Four-week block generation
The system SHALL generate a 4-week block whose weeks are build, build-plus, peak and recovery. Every non-recovery week MUST contain the same session types: Z2 base sessions, one interval session and one long session. The recovery week MUST have lower total load and a shortened long session.

#### Scenario: Block generated from history
- **WHEN** the athlete has at least 4 weeks of cached activity history and requests a plan starting next Monday
- **THEN** the plan contains 4 weeks with target load per week derived from their recent weekly load, and week 4 has a lower target than weeks 1-3

#### Scenario: Too little history
- **WHEN** fewer than 4 weeks of load history are cached
- **THEN** the system asks the athlete for a baseline weekly load or hours instead of generating from invented numbers

### Requirement: Goal-specific session mix
The system SHALL vary session volume and intensity by goal type using the templates in the training knowledge, so a long-distance goal has proportionally longer long sessions and more Z2 than a short-event goal.

#### Scenario: Long-distance goal
- **WHEN** a plan is generated for a long-distance goal
- **THEN** the long session is the longest session of every week and interval work is lower-volume than for a short-event goal with the same weekly hours

### Requirement: Ramp-rate cap
The system SHALL cap week-over-week load increase and projected CTL ramp to a user-adjustable limit, and SHALL label the default as a default rather than a universal safe value.

#### Scenario: Peak week would exceed cap
- **WHEN** the unconstrained peak-week target exceeds the configured cap
- **THEN** the peak week is reduced to the cap and the plan shows that it was limited

### Requirement: 80/20 validation
The system SHALL compute the planned low-intensity share of each week and flag any week outside the 80/20 tolerance, and SHALL report when zone data is insufficient rather than assuming a split.

#### Scenario: Week within tolerance
- **WHEN** a generated week has about 80% of planned time in low intensity
- **THEN** the week shows its split and no warning

#### Scenario: Week outside tolerance
- **WHEN** a week's planned low-intensity share falls below the tolerance
- **THEN** the week is flagged and the athlete sees the actual share

### Requirement: Preview before writing
The system SHALL show every plan session (date, sport, duration, estimated load, steps) and MUST NOT create anything in Intervals.icu or on a calendar until the athlete confirms.

#### Scenario: Cancel
- **WHEN** the athlete dismisses the preview
- **THEN** no event is created and the plan remains a local draft

### Requirement: Writing plan sessions to Intervals.icu
On confirmation the system SHALL create each session as a planned workout on its own date in Intervals.icu, tagged as belonging to the plan, and SHALL re-sync the affected range.

#### Scenario: Plan confirmed
- **WHEN** the athlete confirms a 4-week plan
- **THEN** every session exists on its planned date in Intervals.icu and appears in the Calendar tab after re-sync

#### Scenario: Partial failure
- **WHEN** creating one session fails
- **THEN** the system reports which sessions were not created and lets the athlete retry only those

### Requirement: Replace or remove a plan
The system SHALL let the athlete regenerate or remove a plan, deleting only the not-yet-completed events it created and leaving completed activities and unrelated events untouched.

#### Scenario: Regenerate mid-block
- **WHEN** the athlete regenerates the plan in week 2
- **THEN** past and completed sessions are kept and only the future plan-tagged events are replaced

### Requirement: Plan screen
The system SHALL show the current block as a timeline with the current week highlighted, target versus actual load per week, and each week's intensity split.

#### Scenario: Mid-block view
- **WHEN** the athlete opens the Plan screen in week 2
- **THEN** week 2 is highlighted, week 1 shows actual versus target load, and weeks 3-4 show targets only
