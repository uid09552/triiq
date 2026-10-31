# Spec Delta

## Purpose

Brings a fresh session's analysis to the athlete when they open the app, once, and adds personal bests, an aerobic-fitness marker and a recovery hint to session analysis.

## ADDED Requirements

### Requirement: New-training pop-up
When the app opens (cold start or return to the foreground) and today's sync has finished, the system SHALL show a sheet for every completed session dated today that the athlete has not yet seen. With several, it SHALL show one page per session, newest first, with a page indicator. Each page SHALL show name, sport, duration, TSS, the evaluation verdict with reasons and intensity split, and the insights available for it. It SHALL offer **OK** and **Details** (opens the activity screen).

#### Scenario: One new session
- **WHEN** the athlete opens the app after a ride synced today
- **THEN** a sheet shows that ride's details and analysis with OK and Details

#### Scenario: Two new sessions
- **WHEN** a swim and a run from today are unseen
- **THEN** the sheet has two pages, the most recent first

#### Scenario: Nothing new
- **WHEN** every session of today has been seen, or there is none
- **THEN** no sheet appears

### Requirement: Shown once, only for today
**OK** (or dismissing the sheet) SHALL mark every session it showed as seen, persisted across restarts. A session SHALL never pop up again once seen, nor on any day after the one it was done. Opening the activity from Activities SHALL also mark it seen.

#### Scenario: Reopen the app
- **WHEN** the athlete taps OK and opens the app again later that day
- **THEN** no sheet appears for those sessions

#### Scenario: Next day
- **WHEN** yesterday's session was never seen and the athlete opens the app today
- **THEN** it does not pop up

#### Scenario: Synced while open
- **WHEN** a session from today arrives by the periodic sync while the app is in use
- **THEN** it pops up at the next open or resume, not in the middle of use

### Requirement: Turning the pop-up off
Settings SHALL have a switch for the new-training pop-up, on by default. When off, no sheet appears; the insights stay on the activity screen.

#### Scenario: Off
- **WHEN** the switch is off and a new session from today is unseen
- **THEN** no sheet appears

### Requirement: Personal bests
The system SHALL list the best efforts Intervals.icu reports for an activity (for example best power over a duration, fastest time over a distance), with the previous best when it is reported. When none are reported, the section SHALL not appear.

#### Scenario: New 5-minute power best
- **WHEN** the activity reports a best 5-minute power of 310 W, previously 298 W
- **THEN** the pop-up and the activity screen show "Best 5 min power 310 W (was 298 W)"

### Requirement: Efficiency trend
For an easy session (planned easy, or at least 80% of its time at low intensity), the system SHALL show its efficiency factor and the change against the median efficiency factor of the same sport's easy sessions in the 6 weeks before it, but only when at least 4 such sessions exist; otherwise it SHALL say there is not enough history.

#### Scenario: Improving
- **WHEN** the session's efficiency factor is 1.56 and the 6-week median of 5 easy rides is 1.50
- **THEN** it shows "+4% against your 6-week median"

#### Scenario: Too few sessions
- **WHEN** only 2 earlier easy rides exist
- **THEN** it says there isn't enough history yet

### Requirement: Recovery hint
The system SHALL estimate a recovery time from the session's TSS and the athlete's current form (TSB), using rules from the training knowledge, and SHALL label it as an estimate with the rule shown. When tomorrow has a planned hard session and the estimate reaches into tomorrow's daytime, it SHALL say so and offer to find an alternative for tomorrow.

#### Scenario: Hard session, hard tomorrow
- **WHEN** today's session had 180 TSS, form is −25 and tomorrow plans intervals
- **THEN** the hint estimates about 48 hours and suggests an easier alternative for tomorrow

#### Scenario: Easy session
- **WHEN** today's session had 40 TSS
- **THEN** the hint estimates about 12 hours and nothing about tomorrow
