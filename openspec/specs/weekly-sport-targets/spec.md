# weekly-sport-targets Specification

## Purpose

Lets the athlete set a personal weekly training-time goal for swim, cycle and run independently of any training plan, and shows progress toward each as a ring on Today, so "did I train enough this week, per sport" has a direct answer instead of only an overall TSS figure.

## Requirements

### Requirement: Per-sport weekly target setting
The system SHALL let the athlete set an independent weekly training-time target, in hours, for each of swim, cycle and run, persisted across restarts. A target left at zero or blank SHALL mean "no target" for that sport, not a target of zero hours.

#### Scenario: Setting a target
- **WHEN** the athlete enters 4 hours for cycle in Settings → Weekly targets
- **THEN** the value is saved and still shows 4 hours after an app restart

#### Scenario: Clearing a target
- **WHEN** the athlete clears the run target back to blank/0
- **THEN** run no longer counts as having a target, and its ring stops appearing on Today

### Requirement: Today visibility toggle
The system SHALL provide a single "Show on Today" switch, independent of the per-sport targets themselves, that controls whether the weekly-targets section appears on Today. Turning it off SHALL hide the section without clearing any target; turning it back on SHALL restore it.

#### Scenario: Hiding the rings
- **WHEN** the athlete turns "Show on Today" off while targets are still set
- **THEN** Today shows no weekly-targets section, and Settings still shows the saved targets

### Requirement: Weekly achievement per sport
For each sport with a target set, the system SHALL compute this week's achieved training time as the sum of moving time of this week's cached completed activities (Monday through today, local cache, no network fetch) whose type belongs to that sport, using the same type-to-sport grouping the rest of the app uses for icons and colours (e.g. a type containing "ride" or "bike" counts as cycle).

#### Scenario: Mixed activity types count once
- **WHEN** this week's cache has a `Ride` and a `VirtualRide` activity of 1 h and 30 min
- **THEN** the cycle ring's achieved time is 1 h 30 min

#### Scenario: Works offline
- **WHEN** the device has no network connection but this week's activities are already cached
- **THEN** the rings still show correct progress

### Requirement: Weekly target rings on Today
When the "Show on Today" toggle is on and at least one sport has a target set, Today SHALL show one ring per sport that has a target, each labelled with the sport, coloured with that sport's existing app colour, and showing achieved vs. target time (e.g. "3.2 / 4 h"). A sport with no target SHALL show no ring. When no sport has a target, the whole section SHALL NOT appear, regardless of the toggle.

#### Scenario: Two of three sports have targets
- **WHEN** swim has no target, cycle has a 4 h target and run has a 3 h target
- **THEN** Today shows exactly two rings: cycle and run

#### Scenario: Target met or exceeded
- **WHEN** the athlete has swum 3 h against a 2 h target
- **THEN** the swim ring shows as full (capped visually at 100%) with the actual hours and percentage (150%) in its label, in a colour that reads as "done" rather than "in progress"

#### Scenario: No targets set at all
- **WHEN** no sport has a weekly target configured
- **THEN** Today shows no weekly-targets section, even if "Show on Today" is on
