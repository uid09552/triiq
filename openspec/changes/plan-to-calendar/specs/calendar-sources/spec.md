# Spec Delta

## Purpose

Decides which planned items TriIQ shows (its own plan sessions, and Intervals.icu's planned events), and lets the athlete choose whether each side is copied to the other.

## ADDED Requirements

### Requirement: Calendar sync settings
Settings SHALL have a Calendar section with two independent switches, both on by default and persisted: **Send plan to Intervals.icu** and **Copy planned events from Intervals.icu**.

#### Scenario: Defaults
- **WHEN** the app is installed fresh
- **THEN** both switches are on

#### Scenario: Persisted
- **WHEN** the athlete turns copying off and restarts the app
- **THEN** the switch is still off

### Requirement: Copying planned events from Intervals.icu
When **Copy planned events from Intervals.icu** is off, sync (manual, automatic and background) MUST NOT fetch planned events, and Calendar, Today and Statistics MUST NOT show cached Intervals.icu events. Cached events SHALL be kept, not deleted. Turning the switch on SHALL show cached events again and sync the current month. Completed activities are not affected.

#### Scenario: Copy off
- **WHEN** copying is off and the athlete syncs
- **THEN** no events request is made, and the Calendar shows only TriIQ plan sessions and completed activities

#### Scenario: Copy back on
- **WHEN** the athlete turns copying on again
- **THEN** previously cached events reappear and the current month's events are synced

### Requirement: Merged planned items
Calendar, Today ("planned tomorrow", planned TSS of the week) and Statistics (planned load per week) SHALL read planned items from one source: the current plan's sessions plus, when copying is on, Intervals.icu planned events. A plan session that has an Intervals.icu event SHALL appear once. When the synced event exists, its date and load SHALL be used, so a move made in Intervals.icu shows. A plan session without an event SHALL be shown from the plan.

#### Scenario: No duplicates
- **WHEN** a plan session was sent to Intervals.icu and events are copied
- **THEN** the Calendar shows that session once

#### Scenario: Local-only session
- **WHEN** sending is off and the plan has a session on Thursday
- **THEN** Thursday shows the session marked as a TriIQ plan session, and Today counts it in the week's planned TSS

### Requirement: Plan sessions in the Calendar
The Calendar SHALL mark TriIQ plan sessions so they are distinguishable from Intervals.icu events, and SHALL show their sport, name, duration and TSS. Tapping one SHALL show its steps and whether it was sent to Intervals.icu. The Calendar SHALL refresh when a plan is taken, removed or changed, without a restart.

#### Scenario: Open a plan session
- **WHEN** the athlete taps a TriIQ plan session in the Calendar day detail
- **THEN** its steps and its sent / not sent status are shown

### Requirement: Opening the Calendar at a date
The app SHALL let any screen switch the main view to the Calendar tab focused on a given date, keeping the bottom navigation in sync.

#### Scenario: From the Plan screen
- **WHEN** Take as plan finishes on the Plan screen (opened from More)
- **THEN** the Plan screen closes, the bottom navigation shows Calendar selected, and the Calendar shows the plan's first week
