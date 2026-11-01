# calendar-export Specification

## Purpose

Gets planned sessions into the athlete's own calendar so training sits next to the rest of their day, without a TriIQ backend or Google OAuth.

## Requirements

### Requirement: Device calendar on Android
On Android the system SHALL, after the athlete grants calendar permission and chooses a calendar, write plan sessions as events to that device calendar, with plain-text descriptions.

#### Scenario: Events created
- **WHEN** the athlete confirms "Add plan to calendar" and permission is granted
- **THEN** one event per session exists on its date in the chosen calendar, with title, duration and a plain-text step summary

#### Scenario: Permission denied
- **WHEN** the athlete denies calendar permission
- **THEN** nothing is written and the system offers the single-event link instead

### Requirement: Plain-text descriptions
Calendar event descriptions MUST be plain text; Markdown syntax SHALL NOT appear in them.

#### Scenario: Agent text with markdown
- **WHEN** a session description contains headings, bold or tables
- **THEN** the event description shows readable text with no literal `**`, `#` or `|`

### Requirement: No duplicates on re-export
The system SHALL remember which calendar event belongs to which plan session and update or remove it instead of creating a second one.

#### Scenario: Session moved
- **WHEN** a plan session's date changes and the plan is re-exported
- **THEN** the existing calendar event moves to the new date and no duplicate remains

### Requirement: Fallback outside Android
On platforms without device-calendar support the system SHALL offer the pre-filled Google Calendar link for a single session.

#### Scenario: Windows
- **WHEN** the athlete taps "Add to calendar" on Windows
- **THEN** the Google Calendar add-event page opens pre-filled for that session
