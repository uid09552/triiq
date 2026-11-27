# Spec Delta

## Purpose

Shapes a training plan around the goal's event date, so the athlete reaches the event fresh: the block ends in the event week, tapers before it, keeps race day free, and the app and agent make the countdown and taper visible.

## ADDED Requirements

### Requirement: Plan ends in the event week
When a goal has an event date and no explicitly chosen plan length, the system SHALL make the plan run from its start week up to and including the week that contains the event, provided that is between 2 and 16 weeks.

#### Scenario: Event seven weeks out
- **WHEN** the plan starts on Monday 2 November 2026 and the event is on Sunday 20 December 2026
- **THEN** the plan has 7 weeks and its last week is 14-20 December

#### Scenario: Event more than 16 weeks out
- **WHEN** the event is 24 weeks after the start week
- **THEN** the plan has 16 weeks, has no taper, and the preview says a plan ending with the taper can be generated once the event is at most 16 weeks away

### Requirement: Plan length must not pass the event
The system SHALL reject a goal whose explicitly chosen plan length would place plan weeks after the week containing the event, with a message naming the latest allowed length.

#### Scenario: Chosen length too long
- **WHEN** the event is in the 6th week from the start and the athlete chooses 8 weeks
- **THEN** the goal is rejected with a message that the plan can be at most 6 weeks

### Requirement: Taper weeks
When the plan's last week contains the event, the system SHALL make the last weeks a taper, with the number of weeks set per goal type in the training knowledge. Each taper week's proposed load SHALL be the last pre-taper week's load times that week's taper factor from the training knowledge.

#### Scenario: Long-distance taper
- **WHEN** a long-distance goal with taper weeks 2 and factors 0.7 and 0.5 has a last pre-taper week of 600 TSS
- **THEN** the second-to-last week is proposed at 420 TSS and the event week at 300 TSS

#### Scenario: Short-event taper
- **WHEN** a short-event goal has taper weeks 1 and factor 0.6 and a last pre-taper week of 400 TSS
- **THEN** only the event week tapers, proposed at 240 TSS

#### Scenario: No event
- **WHEN** the goal has no event date
- **THEN** no week is a taper week

### Requirement: Taper keeps intensity
A taper week SHALL still contain the sport's interval session, shortened in proportion to the week's load, and SHALL shorten the long session by more than the week's load reduction. Taper sessions SHALL come from taper templates in the training knowledge.

#### Scenario: Interval session in taper
- **WHEN** a taper week is generated for a run goal
- **THEN** it contains one interval session with at least one work repeat at the build weeks' work intensity

### Requirement: Race week
In the week containing the event, the system SHALL place no session on the event day or after it, and SHALL place one short openers session on the day before the event when that day is a training day.

#### Scenario: Saturday openers
- **WHEN** the event is on Sunday and Saturday is a training day
- **THEN** Saturday has one openers session, and Sunday has no plan session

#### Scenario: Midweek event
- **WHEN** the event is on a Wednesday
- **THEN** no sessions are placed Wednesday to Sunday of that week

### Requirement: Taper in the load graph
The load graph SHALL label taper weeks and the event week, SHALL NOT raise the weekly-increase or CTL-ramp warning for a taper week, and SHALL still let the athlete set each taper week to 80-120% of its proposed load.

#### Scenario: Taper drop is not flagged
- **WHEN** the plan's taper weeks are well below the previous week's load
- **THEN** no warning is shown for those weeks and they are labelled "Taper" and "Race week"

### Requirement: Race countdown
While the saved plan has an event date in the future, Today SHALL show the number of days until the event, and on the event day SHALL show that it is race day.

#### Scenario: Countdown
- **WHEN** today is 27 November 2026 and the plan's event is on 20 December 2026
- **THEN** Today shows "Race in 23 days"

### Requirement: Agent knows the taper
The training agent's plan information SHALL include each week's phase (build, recovery, taper, race week) and the days until the event, so it can explain why load drops before the event.

#### Scenario: Asking about the drop
- **WHEN** the athlete asks the agent why the last two weeks are lighter
- **THEN** the plan data the agent reads marks those weeks as taper and race week and gives the days until the event
