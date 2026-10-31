# Spec Delta

## Purpose

Lets the athlete choose how many weeks a plan covers and shape the weekly load visually, starting from a proposed steady progression.

## ADDED Requirements

### Requirement: Plan length
The system SHALL let the athlete choose the number of plan weeks between 2 and 16. The default SHALL be 8, or the number of whole weeks until the event date when an event date is set and that number is within range.

#### Scenario: Default without event
- **WHEN** the athlete opens plan setup with no event date
- **THEN** the plan length is 8 weeks

#### Scenario: Event date sets length
- **WHEN** the goal's event date is 10 weeks after the plan start
- **THEN** the plan length defaults to 10 weeks

#### Scenario: Out of range
- **WHEN** the athlete enters 20 weeks
- **THEN** the system rejects the value and states the allowed range

### Requirement: Proposed load curve
The system SHALL propose a target TSS for every plan week as a steady ramp from the athlete's baseline weekly load, where each week's proposal is at most the previous week's proposal times (1 + ramp cap). The default ramp cap SHALL be 10% per week, user-adjustable, and labelled as a default. The proposal MUST NOT insert recovery weeks by default and MUST also respect the CTL-ramp limit and the weekly hours budget.

#### Scenario: Steady ramp
- **WHEN** the baseline is 300 TSS, the cap is 10% and the plan has 4 weeks with no other limit active
- **THEN** the proposed weeks are 330, 363, 399 and 439 TSS (rounded)

#### Scenario: Hours budget limits the ramp
- **WHEN** the proposed load for week 5 needs more hours than the weekly budget
- **THEN** week 5 and later are held at the budget's load and shown as limited by hours

#### Scenario: No baseline
- **WHEN** there is too little history and the goal has no baseline load
- **THEN** the system asks for a baseline instead of drawing a curve

### Requirement: Load graph editor
The system SHALL show the plan weeks as a graph with one adjustable point per week. The y axis SHALL be the share of that week's proposed TSS, 100% being the proposal, and each point SHALL be adjustable between 80% and 120% in 5% steps. The absolute TSS of each week SHALL be visible while adjusting. A reset action SHALL restore all weeks to 100%.

#### Scenario: Lower a week
- **WHEN** the athlete drags week 4 to 80%
- **THEN** week 4's target becomes 80% of its proposed TSS and the graph shows the new absolute TSS

#### Scenario: Clamp
- **WHEN** the athlete drags a point above 120%
- **THEN** the point stops at 120%

#### Scenario: Adjustments survive regeneration of the proposal
- **WHEN** the baseline changes after a sync and the proposal is recomputed
- **THEN** each week keeps its percentage and its absolute TSS follows the new proposal

### Requirement: Dragging a week's point
The system SHALL let the athlete adjust a week by pressing anywhere in that week's column and dragging vertically; the point MUST move relative to the drag (not jump to the touch position), and the line MUST redraw continuously while dragging. Values SHALL snap to 5% steps, and each step crossed SHALL give a selection haptic on devices that support it. While dragging, a label SHALL show the week number, percentage, absolute TSS and change versus the previous week. Each week's touch target MUST be at least 40 logical pixels wide; when the weeks do not fit, the graph SHALL scroll horizontally, with horizontal gestures scrolling and vertical gestures adjusting.

#### Scenario: Relative drag
- **WHEN** week 3 is at 100% and the athlete presses near the bottom of its column and drags up by two steps
- **THEN** week 3 becomes 110%, not the value under the initial touch

#### Scenario: Live feedback
- **WHEN** the athlete is dragging week 5
- **THEN** the line, the week's absolute TSS and the over-cap warning colour update before the finger is lifted

#### Scenario: Many weeks on a phone
- **WHEN** a 16-week plan is shown on a 360-pixel-wide screen
- **THEN** each column is at least 40 pixels wide, the graph scrolls horizontally, and a vertical drag in a column adjusts only that week

### Requirement: Precise and accessible adjustment
The system SHALL let the athlete tap a week to select it and adjust it by ±5% buttons, by arrow keys on Windows, and through a screen-reader slider per week announcing week, percentage and TSS. The last drag or step SHALL be undoable, and reset SHALL ask for confirmation when any week is not at 100%.

#### Scenario: Keyboard on Windows
- **WHEN** week 2 is selected and the athlete presses the up arrow twice
- **THEN** week 2 increases by 10 percentage points

#### Scenario: Undo
- **WHEN** the athlete drags week 6 from 100% to 85% and taps undo
- **THEN** week 6 returns to 100%

### Requirement: Warnings for athlete-set load
The system SHALL flag, without blocking, any week whose adjusted target exceeds the ramp cap over the last non-recovery week's adjusted target (unless the week is at or below its proposal), the CTL-ramp limit, or the hours budget for its phase, and SHALL state which limit is exceeded.

#### Scenario: Above ramp cap
- **WHEN** week 3 is set to 120% while week 2 is at 100%
- **THEN** week 3 is marked as above the 10% ramp cap and generation is still allowed

### Requirement: Recovery weeks from the curve
The system SHALL treat a week whose adjusted target is more than 10% below the previous week's target (below 90% of it; `recoveryThreshold` in the knowledge) as a recovery week and use recovery-phase session templates for it.

#### Scenario: Manual dip
- **WHEN** week 4 is set to 80% and week 3 to 110%
- **THEN** week 4 is generated with recovery templates and a shortened long session
