# threshold-updates Specification

## Purpose

Keeps the athlete's thresholds current: suggests an updated ride FTP, run threshold pace or swim CSS when the performance curves show it has moved, and writes it to Intervals.icu only after the athlete confirms.

## Requirements

### Requirement: Deriving thresholds
The system SHALL derive a candidate threshold per sport from the current season's curves: ride FTP from the model fit Intervals.icu returns, run threshold pace from the pace curve, and swim CSS as `(t400 - t200) / 2` per 100 m from the 400 m and 200 m bests. A candidate SHALL only be derived from efforts within the last 90 days, and swim CSS only when both bests fall in that window.

#### Scenario: Swim CSS
- **WHEN** the 400 m best is 6:00 and the 200 m best is 2:50, both within 90 days
- **THEN** the candidate CSS is 1:35 per 100 m

#### Scenario: Old efforts only
- **WHEN** the run pace curve's relevant efforts are all older than 90 days
- **THEN** no run candidate is derived

### Requirement: When to suggest
The system SHALL suggest an increase when a candidate beats the settings threshold by at least 3 %, and a decrease, worded as "likely dropped", only when the candidate is at least 5 % worse and is based on at least one maximal effort within the last 30 days. Missing or sparse data SHALL never produce a decrease suggestion.

#### Scenario: Increase
- **WHEN** settings FTP is 252 W and the candidate is 262 W
- **THEN** an increase suggestion is shown

#### Scenario: Small gap
- **WHEN** settings FTP is 252 W and the candidate is 256 W
- **THEN** no suggestion is shown; the gap still appears on the model card

#### Scenario: No recent hard efforts
- **WHEN** the athlete has only easy sessions in the last 30 days and the season curve is below settings
- **THEN** no decrease is suggested

### Requirement: Confirming an update
Before writing, the system SHALL show the current and new value, the absolute zone ranges before and after, an opt-in to also recalculate HR zones, and that past activities keep their load. Nothing SHALL be written until the athlete confirms.

#### Scenario: Reviewing
- **WHEN** the athlete opens an FTP suggestion from 252 W to 262 W
- **THEN** the sheet shows each power zone's watt range at 252 W and at 262 W and the HR-zone option unticked

### Requirement: Writing to Intervals.icu
On confirmation the system SHALL update only the changed threshold field in the matching Intervals.icu sport settings, refresh the athlete's settings in the app, and report success or the error. The write path SHALL NOT ship unless a live test has shown that updating one field leaves the other settings fields unchanged.

#### Scenario: Successful update
- **WHEN** the athlete confirms 262 W
- **THEN** Intervals.icu's Ride FTP becomes 262 W, its other settings are unchanged, and the model card shows no gap

#### Scenario: Write fails
- **WHEN** the update request fails
- **THEN** the app keeps the old value, says the update failed, and the suggestion stays

### Requirement: Undo
After a successful update the system SHALL offer to restore the previous value, writing it back the same way.

#### Scenario: Undoing
- **WHEN** the athlete taps Undo after updating FTP to 262 W
- **THEN** Intervals.icu's FTP returns to 252 W

### Requirement: Dismissing
The athlete SHALL be able to dismiss a suggestion; the same sport and direction SHALL NOT be suggested again for 30 days unless the candidate moves a further 3 % beyond the dismissed value.

#### Scenario: Dismissed then exceeded
- **WHEN** a 262 W suggestion was dismissed and a week later the candidate is 271 W
- **THEN** a new suggestion is shown

### Requirement: Agent role
The chat agent SHALL be able to read suggestions and explain them, and MAY open the confirm sheet, but SHALL NOT write thresholds itself.

#### Scenario: Asking about FTP
- **WHEN** the athlete asks whether their FTP is still right
- **THEN** the agent explains the current suggestion from its figures and offers to open the confirm sheet
