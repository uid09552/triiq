# Spec Delta

## ADDED Requirements

### Requirement: Replan entry points
Wherever a single TriIQ plan session or Intervals.icu planned event is shown with a **Change Training** action, it SHALL open Train Now on that session's date with that session preselected, exactly as from Calendar's day detail. This action SHALL be reachable from the Plan screen's week grid for any session shown there, and from the Today screen's planned-training cards without requiring the full planned-workout detail screen first when the tapped item is a TriIQ plan session.

#### Scenario: Plan screen week grid
- **WHEN** the athlete taps a session tile in the Plan screen's week grid, in the current week or any other
- **THEN** the session's detail sheet shows a **Change Training** action that opens Train Now on that session's date, preselected on it

#### Scenario: Today's planned training, TriIQ plan session
- **WHEN** the athlete taps a TriIQ plan session on the Today screen's "Today's Training" or "Tomorrow's Training" card
- **THEN** the session's detail sheet opens directly, with **Change Training** available, without first opening the full planned-workout detail screen

#### Scenario: Today's planned training, synced Intervals.icu event
- **WHEN** the athlete taps a planned item on Today that is a synced Intervals.icu event rather than a TriIQ plan session
- **THEN** the full planned-workout detail screen opens, as it does today, and its own **Change Training** button still opens Train Now preselected on it
