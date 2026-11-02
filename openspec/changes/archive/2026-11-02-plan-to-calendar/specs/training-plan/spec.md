# Spec Delta

## MODIFIED Requirements

### Requirement: Preview before writing
The system SHALL show every plan session (date, sport, duration, estimated load, steps) and MUST NOT save the plan, show it in the Calendar, or create anything in Intervals.icu or on a device calendar until the athlete taps **Take as plan**.

#### Scenario: Cancel
- **WHEN** the athlete dismisses the preview
- **THEN** nothing is saved, the Calendar is unchanged and no event is created

### Requirement: Writing plan sessions to Intervals.icu
On **Take as plan** the system SHALL save the plan locally, switch to the main Calendar tab at the plan's first week, and show the plan's sessions there immediately. When **Send plan to Intervals.icu** is on, the system SHALL then create each session as a planned workout on its own date in Intervals.icu, tagged as belonging to the plan, and SHALL re-sync the affected range. When the setting is off, nothing is sent and the sessions stay local.

#### Scenario: Take as plan, sending on
- **WHEN** the athlete takes a 4-week plan with sending on
- **THEN** the Calendar tab opens on week 1 with every session shown at once, and each session then also exists on its date in Intervals.icu

#### Scenario: Take as plan, sending off
- **WHEN** the athlete takes a plan with sending off
- **THEN** the sessions appear in the Calendar marked as TriIQ plan sessions and no Intervals.icu event is created

#### Scenario: Partial failure
- **WHEN** creating one session in Intervals.icu fails
- **THEN** the session stays in the Calendar as a local plan session, and the system reports which sessions were not sent and lets the athlete retry only those

#### Scenario: Sending turned on later
- **WHEN** the athlete turns sending on while a plan has local-only future sessions
- **THEN** the system offers to send those sessions, and sends only them on confirmation
