# Spec Delta

## Purpose

Lets a triathlete split each plan week's load across swim, bike and run and see the result on a weekly training calendar.

## ADDED Requirements

### Requirement: Triathlon sport option
The system SHALL offer `Triathlon` as a goal sport alongside Run and Ride. A triathlon goal SHALL carry a sport mix of Swim, Bike and Run percentages of weekly TSS, each between 0% and 100% in 5% steps and totalling exactly 100%. The default mix SHALL be Swim 15%, Bike 50%, Run 35%.

#### Scenario: Default mix
- **WHEN** the athlete selects Triathlon for a new goal
- **THEN** the mix shows Swim 15%, Bike 50%, Run 35%

#### Scenario: Invalid total
- **WHEN** the athlete sets Swim 20%, Bike 50%, Run 35%
- **THEN** the goal cannot be saved and the editor shows the total is 105%

#### Scenario: Mix persisted
- **WHEN** the athlete saves Swim 10%, Bike 55%, Run 35% and restarts the app
- **THEN** the goal editor shows the saved mix and the next plan uses it

### Requirement: Per-sport weekly load
For a triathlon goal the system SHALL split each week's target TSS by the sport mix and build sessions per sport from that sport's templates, so the planned TSS per sport is within 5 percentage points of its share. A sport with a share above 0% SHALL get at least one session per week; a sport at 0% SHALL get none.

#### Scenario: Split applied
- **WHEN** a week targets 400 TSS with the default mix
- **THEN** the week plans about 60 TSS swim, 200 TSS bike and 140 TSS run

#### Scenario: Sport excluded
- **WHEN** Swim is set to 0%
- **THEN** no swim session is generated in any week

### Requirement: Session placement across sports
The system SHALL place a triathlon week's sessions on the goal's available days, at most two sessions per day, with the bike and run long sessions on different days. When there are more sessions than room, Z2 sessions SHALL be dropped first; the system SHALL report when the remaining sessions still do not fit instead of dropping more.

#### Scenario: Three days
- **WHEN** the goal has 3 available days and a triathlon week would need 10 sessions
- **THEN** Z2 sessions are dropped first (never a sport's last session), at most two sessions land on a day, and the long ride and long run are on different days

#### Scenario: Days cannot hold the kept sessions
- **WHEN** the sessions a week must keep do not fit the available days
- **THEN** generation reports that more days are needed and writes nothing

### Requirement: Swim templates
The training knowledge SHALL include swim session templates (base, intervals) for each goal type, in Intervals.icu step syntax, read by the engine the same way as run and ride templates.

#### Scenario: Missing swim template
- **WHEN** a triathlon plan needs a swim template that the knowledge does not define
- **THEN** generation fails with the missing-template error and no plan is produced

### Requirement: Training calendar grid
The Plan screen SHALL show each plan week as a Monday–Sunday row of the generated sessions, each labelled with sport, duration and TSS and coloured by sport, with the week's target versus planned TSS and, for triathlon, planned TSS per sport.

#### Scenario: Week row
- **WHEN** the athlete opens a generated triathlon plan
- **THEN** each week shows its sessions on their weekdays in sport colours and a per-sport TSS summary
