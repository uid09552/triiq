# Spec Delta

## Purpose

Lets the athlete set a day's fatigue and muscle soreness (1-4) from any
activity in TriIQ and writes them to that day's Intervals.icu Wellness
record, so the Readiness evaluation always has them without a trip to
Intervals.icu itself.

## ADDED Requirements

### Requirement: Manual fatigue/soreness entry on any activity
The activity detail screen SHALL offer an action that lets the athlete set that activity's day's fatigue and soreness, each 1-4, prefilled with the day's current values when already set, available for any activity regardless of its date.

#### Scenario: Setting it for the first time
- **WHEN** the athlete opens an activity whose day has no fatigue/soreness yet and sets fatigue 2, soreness 1
- **THEN** Intervals.icu's Wellness record for that date is updated with fatigue 2 and soreness 1, no other wellness field changes, and the local cache reflects the new values

#### Scenario: Editing an already-set day
- **WHEN** the athlete opens a different activity on a day whose fatigue/soreness is already set and opens the action
- **THEN** the dialog shows the current values, and confirming new ones overwrites them the same way

### Requirement: Manual entry writes through, requiring a connection
Confirming a manual fatigue/soreness entry SHALL write both values to Intervals.icu's Wellness record for that date as a partial update that leaves every other wellness field unchanged, then update the local wellness cache from the response, and SHALL require an Intervals.icu connection.

#### Scenario: Not connected
- **WHEN** the athlete opens the action without an Intervals.icu connection
- **THEN** the action is disabled or explains the connection is needed, and nothing is written

### Requirement: Optional prompt for new activities
A Settings toggle, on by default, SHALL control whether opening a recent activity (dated today or yesterday) for the first time automatically shows the same fatigue/soreness dialog, when that day has no fatigue/soreness yet. The prompt SHALL show at most once per activity, whether the athlete fills it in or dismisses it, and SHALL NOT appear when the toggle is off or the day already has fatigue/soreness set. Turning the toggle off or on SHALL NOT affect the manual action's availability.

#### Scenario: New activity, toggle on, nothing set yet
- **WHEN** the athlete opens today's just-synced activity for the first time, the toggle is on, and today has no fatigue/soreness
- **THEN** the dialog shows automatically

#### Scenario: Reopening the same activity
- **WHEN** the athlete opens that same activity's detail screen again later
- **THEN** the dialog does not show automatically again, whether or not it was filled in the first time

#### Scenario: Day already has a value
- **WHEN** the athlete opens a second activity from today, after the first already set today's fatigue/soreness
- **THEN** the dialog does not show automatically for the second activity

#### Scenario: Toggle off
- **WHEN** the toggle is off and the athlete opens a brand-new activity for the first time
- **THEN** the dialog does not show automatically, and the manual action is still available

#### Scenario: Older activity
- **WHEN** the athlete opens an activity from a week ago for the first time
- **THEN** the dialog does not show automatically, regardless of the toggle
