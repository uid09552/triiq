# Spec Delta

## Purpose

Shows how a single session unfolded and evaluates it against its plan and the 80/20 intent, using real data, with the numbers computed in code.

## ADDED Requirements

### Requirement: Time-series diagram
The activity detail screen SHALL show a time-series chart of the available streams (power, heart rate, pace/speed, and others when present), selectable per stream, with a tap/drag readout, and SHALL work offline once the streams were fetched.

#### Scenario: Ride with power and HR
- **WHEN** the athlete opens a ride that has power and heart-rate streams
- **THEN** both can be shown over time and dragging shows the values at that moment

#### Scenario: No stream data
- **WHEN** an activity has no streams (e.g. manual entry)
- **THEN** the chart area explains that no time-series data exists instead of rendering empty axes

### Requirement: On-demand stream fetch and cache
The system SHALL fetch streams only when the athlete opens the diagram, cache them locally, and show a loading and error state without blocking the rest of the screen.

#### Scenario: Second open
- **WHEN** the same activity is opened again
- **THEN** the chart renders from the cache with no network request

### Requirement: Interval highlighting
The system SHALL highlight intervals reported by Intervals.icu on the chart and list them with duration and average power/HR/pace.

#### Scenario: Structured workout
- **WHEN** an activity has detected intervals
- **THEN** each interval is a shaded band on the chart and a row in the list

### Requirement: Planned versus actual
When an activity matches a planned workout the same day and sport, the system SHALL show planned versus actual duration and load and the difference.

#### Scenario: Shorter than planned
- **WHEN** the athlete completed 45 of 60 planned minutes
- **THEN** the screen shows both values and the shortfall

### Requirement: Intensity evaluation
The system SHALL map time-in-zone to low/moderate/high, show the session's split, and compute aerobic decoupling when data allows. If zone or stream data is insufficient, it MUST say so rather than estimate.

#### Scenario: Easy session drifted
- **WHEN** a planned Z2 session has a high share of moderate-intensity time
- **THEN** the evaluation states the actual split and that the session exceeded its intended intensity

#### Scenario: No zone data
- **WHEN** the activity has no zone times
- **THEN** the intensity section says the split cannot be assessed

### Requirement: Verdict with reasons
The evaluation SHALL give a short verdict (on target, too hard, too easy, cut short) together with the figures it is based on.

#### Scenario: Verdict shown
- **WHEN** the evaluation completes
- **THEN** the verdict is displayed with the specific numbers that led to it

### Requirement: Ask the trainer
The screen SHALL provide an action that opens Chat with this session's data and evaluation supplied as context.

#### Scenario: Question about a session
- **WHEN** the athlete taps "Ask the trainer" on a session
- **THEN** Chat opens with that session referenced and the athlete can ask a follow-up without re-describing it
