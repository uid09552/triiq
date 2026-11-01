# Spec Delta

## Purpose

Turns the wellness data the athlete already syncs from Intervals.icu into a daily readiness status with reasons, measured against the athlete's own baselines, so they can see at a glance whether to train as planned or back off.

## ADDED Requirements

### Requirement: Personal baselines
The system SHALL compute each signal's baseline from the athlete's own cached wellness records over the 60 days before today: the mean and standard deviation for HRV and resting HR. A baseline SHALL only exist when that signal has values on at least 14 of those days.

#### Scenario: Enough history
- **WHEN** HRV is recorded on 40 of the last 60 days
- **THEN** an HRV baseline is computed from those 40 values

#### Scenario: Too little history
- **WHEN** resting HR is recorded on 10 of the last 60 days
- **THEN** resting HR shows "not enough history yet" and does not affect the status

### Requirement: Signal ratings
The system SHALL rate each of today's signals (HRV, resting HR, sleep, form, fatigue/soreness) as ok, caution or back off using thresholds from the training knowledge. Defaults: HRV 1 / 2 SD below baseline; resting HR 5 / 10 bpm above; sleep under 6 h (caution only); form below -20 / -30; fatigue or soreness at the worst level (caution only).

#### Scenario: Low HRV
- **WHEN** the HRV baseline is 62 ± 6 ms and today's HRV is 52 ms
- **THEN** HRV is rated caution

#### Scenario: Elevated resting HR
- **WHEN** the resting-HR baseline is 48 bpm and today's resting HR is 59 bpm
- **THEN** resting HR is rated back off

#### Scenario: Short sleep
- **WHEN** last night's sleep is 5 h 20 min
- **THEN** sleep is rated caution

### Requirement: Readiness status
The system SHALL combine the signal ratings into one status: Back off when any signal is back off or two or more are caution; Caution when exactly one is caution; Ready otherwise. The status SHALL be shown with the list of signals that caused it.

#### Scenario: Two cautions
- **WHEN** HRV and sleep are caution and all other signals are ok
- **THEN** the status is Back off, with HRV and sleep given as the reasons

#### Scenario: All ok
- **WHEN** every rated signal is ok
- **THEN** the status is Ready

### Requirement: Missing data
The system SHALL show "no wellness data" with a hint to connect a device in Intervals.icu when there are no wellness signals in the last 60 days, and "waiting for today's data" with the last recorded date when today's record has no HRV, resting HR or sleep. Form SHALL still be rated from load in both cases.

#### Scenario: Not synced yet
- **WHEN** the latest record with HRV is yesterday's and today's has only CTL and ATL
- **THEN** the tile shows "waiting for today's data", yesterday's date, and a status from form alone

### Requirement: Device readiness
When today's wellness record carries a readiness value from the athlete's device, the system SHALL show it next to the status, labelled as the device's figure, and SHALL NOT use it in the status.

#### Scenario: Device value present
- **WHEN** today's record has readiness 71
- **THEN** the detail screen shows "Device readiness 71" next to the status

### Requirement: Readiness on Today
Today SHALL show a readiness tile with the status and its top reason. Tapping it SHALL open a detail screen listing each signal with today's value, its normal range and rating, and a 30-day trend for HRV and resting HR.

#### Scenario: Opening the detail
- **WHEN** the athlete taps the readiness tile
- **THEN** the detail screen lists HRV, resting HR, sleep, form and subjective scores with values, ranges and ratings

### Requirement: Hard-session hint
When the status is Caution or Back off and today has a planned interval or long session, Today SHALL show a hint suggesting an easier day, with an action that opens the chat asking the trainer about today's session given the readiness. The system SHALL NOT change the plan by itself.

#### Scenario: Back off with intervals planned
- **WHEN** the status is Back off and today's plan has an interval session
- **THEN** Today shows the hint with "Ask the trainer", and the plan is unchanged

#### Scenario: Easy day planned
- **WHEN** the status is Caution and today's only session is Z2
- **THEN** no hint is shown

### Requirement: Agent readiness tool
The training agent SHALL have a read-only tool that returns today's readiness status, each signal's value, baseline and rating, and the missing-data state, computed by the same rules as the tile.

#### Scenario: Chat matches tile
- **WHEN** the tile shows Caution because of HRV and the athlete asks the agent whether to do intervals
- **THEN** the tool result gives status Caution with HRV as the reason
