# train-now Specification

## Purpose

Train Now starts from what is planned for today: it shows today's sessions and helps the athlete find an alternative, or proposes a session when nothing is planned.

## Requirements

### Requirement: Today's planned training
Train Now SHALL show, above the proposal controls, every training session planned for today from the merged planned items (TriIQ plan sessions and, when copying is on, Intervals.icu events). Each card SHALL show sport, name, duration, TSS, its source (TriIQ plan or Intervals.icu, and for plan sessions whether it was sent), and its steps. Long step lists MAY be collapsed and expandable. With nothing planned, no card is shown.

#### Scenario: Plan session today
- **WHEN** the athlete opens Train Now on a day with a TriIQ plan long ride of 150 min / 145 TSS
- **THEN** a card shows "Long endurance", Ride, 150 min, 145 TSS, "TriIQ plan", and its steps

#### Scenario: Two sessions today
- **WHEN** today has a swim and a run planned
- **THEN** both cards are shown, and the first is selected for finding an alternative

#### Scenario: Nothing planned
- **WHEN** nothing is planned today
- **THEN** no planned card is shown

### Requirement: Adaptive main button
The main button SHALL read **Find alternative** when a session is planned today and **Propose training** otherwise. With more than one session today, the athlete SHALL be able to choose which one the alternative is for.

#### Scenario: Label with a plan
- **WHEN** a session is planned today
- **THEN** the button reads "Find alternative"

#### Scenario: Label without a plan
- **WHEN** nothing is planned today
- **THEN** the button reads "Propose training"

### Requirement: Alternative proposals
Finding an alternative SHALL send the agent the selected session (sport, name, duration, TSS, steps) as the reference. It SHALL ask for a session with a similar training effect and load, adjusted to the athlete's recent load data and the chosen sport, duration, intensity and custom instructions. Sport, duration and intensity SHALL be preset from the selected session and stay editable. The reply format (table, total TSS, rationale) SHALL be the same as for a new proposal.

#### Scenario: Presets
- **WHEN** the athlete selects a 60-minute run interval session
- **THEN** the sport is Run, the duration 60 minutes and the intensity Intervals, and the athlete can change them before asking

#### Scenario: Shorter alternative
- **WHEN** the athlete sets 30 minutes and taps Find alternative for a 90-minute ride
- **THEN** the prompt includes the planned ride as reference and asks for a 30-minute alternative

### Requirement: Replace or add
When an alternative is created, the preview SHALL offer **Replace today's session** (default) or **Add alongside**. Replacing SHALL:
- for a TriIQ plan session: update that session's sport, name, duration, TSS and steps in place (same plan, week and date). If the session is in Intervals.icu, create the new workout there and delete the old event. If sending is off or there is no connection, change it locally only.
- for an Intervals.icu event: create the new workout, then delete the old event.

Upstream changes SHALL happen before the local change. On failure, nothing local changes and the athlete is told. Adding SHALL behave as creating a workout does today. Afterwards Today, the Calendar and the Plan screen SHALL show the result without a restart.

#### Scenario: Replace a plan session
- **WHEN** the athlete replaces today's plan long ride with a 60-minute run alternative
- **THEN** the plan's session for today is the run (same week, same date), the old ride's Intervals.icu event is gone and the run's event exists, and the Plan screen's week shows the run

#### Scenario: Replace locally only
- **WHEN** sending to Intervals.icu is off and the athlete replaces a plan session
- **THEN** the plan session changes, and no Intervals.icu request is made

#### Scenario: Replace an Intervals.icu event
- **WHEN** the athlete replaces a coach-planned Intervals.icu event
- **THEN** the new workout is created and the old event is deleted, and Today shows only the new one

#### Scenario: Delete fails after create
- **WHEN** the new workout is created but deleting the old event fails
- **THEN** the athlete is told that both now exist, and can delete the old one from the Calendar

#### Scenario: Add alongside
- **WHEN** the athlete chooses Add alongside
- **THEN** the planned session is untouched and the alternative is created for today as an extra workout
