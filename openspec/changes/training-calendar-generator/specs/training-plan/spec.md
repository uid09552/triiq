# Spec Delta

## MODIFIED Requirements

### Requirement: Four-week block generation
The system SHALL generate a plan of the chosen number of weeks (see `plan-load-curve`) whose weekly targets come from the load curve. Every non-recovery week MUST contain the same session types per sport: Z2 base sessions, one interval session and one long session (swim has no long session). A recovery week, as defined by the load curve, MUST have lower total load and a shortened long session.

#### Scenario: Block generated from history
- **WHEN** the athlete has at least 4 weeks of cached activity history, chooses 8 weeks and requests a plan starting next Monday
- **THEN** the plan contains 8 weeks whose targets match the load curve derived from their recent weekly load

#### Scenario: Too little history
- **WHEN** fewer than 4 weeks of load history are cached
- **THEN** the system asks the athlete for a baseline weekly load or hours instead of generating from invented numbers

### Requirement: Ramp-rate cap
The system SHALL cap the *proposed* week-over-week load increase and projected CTL ramp to a user-adjustable limit with a default of 10% per week, and SHALL label the default as a default rather than a universal safe value. Weeks the athlete raises above the cap in the load graph SHALL be kept and flagged, not reduced.

#### Scenario: Proposal would exceed cap
- **WHEN** the unconstrained proposal for a week exceeds the configured cap
- **THEN** the proposal for that week is reduced to the cap and the plan shows that it was limited

#### Scenario: Athlete overrides cap
- **WHEN** the athlete sets a week to 120% of its proposal and that exceeds the cap
- **THEN** the generated week uses the athlete's target and shows an over-cap warning

### Requirement: Plan screen
The system SHALL show the current plan as a timeline and a weekly calendar grid (see `triathlon-sport-mix`) with the current week highlighted, target versus actual load per week, and each week's intensity split.

#### Scenario: Mid-block view
- **WHEN** the athlete opens the Plan screen in week 2 of an 8-week plan
- **THEN** week 2 is highlighted, week 1 shows actual versus target load, and weeks 3–8 show targets only
