# Spec Delta

## MODIFIED Requirements

### Requirement: Load graph editor
The system SHALL show the plan weeks as a graph with one adjustable point per week. The value axis SHALL be in TSS, scaled to the plan's lowest and highest allowed week load. Each week SHALL show its allowed band, 80% to 120% of that week's proposed TSS, and the proposal SHALL be drawn as a dashed line through the weeks' proposed TSS. Each point SHALL be adjustable within its band; values SHALL be multiples of 5 TSS, the band edges rounded inwards to the nearest multiple of 5. A week at its untouched proposal keeps the exact proposed value. The week's share of the proposal SHALL be visible while adjusting. A reset action SHALL restore all weeks to their proposed TSS.

#### Scenario: Lower a week
- **WHEN** the athlete drags week 4, proposed at 439 TSS, down to 360 TSS
- **THEN** week 4's target becomes 360 TSS, the label shows 82% of the proposal, and the axis labels are TSS values

#### Scenario: Clamp
- **WHEN** the athlete drags a point above 120% of its proposed TSS
- **THEN** the point stops at the top of that week's band

#### Scenario: Adjustments survive regeneration of the proposal
- **WHEN** the baseline changes after a sync and the proposal is recomputed
- **THEN** each week keeps its share of the proposal and its TSS follows the new proposal

### Requirement: Dragging a week's point
The system SHALL let the athlete adjust a week by pressing anywhere in that week's column and dragging vertically. The point MUST move relative to the drag (not jump to the touch position), and the line MUST redraw continuously while dragging. Values SHALL snap to 5-TSS steps, and each step crossed SHALL give a selection haptic on devices that support it. While dragging, a label SHALL show the week number, TSS, share of the proposal and change versus the previous week. Each week's touch target MUST be at least 40 logical pixels wide. When the weeks do not fit, the graph SHALL scroll horizontally, with horizontal gestures scrolling and vertical gestures adjusting.

#### Scenario: Relative drag
- **WHEN** week 3 is at 399 TSS and the athlete presses near the bottom of its column and drags up by the height of 60 TSS
- **THEN** week 3 becomes 460 TSS (snapped to 5), not the value under the initial touch

#### Scenario: Live feedback
- **WHEN** the athlete is dragging week 5
- **THEN** the line, the week's TSS and share, and the over-cap warning colour update before the finger is lifted

#### Scenario: Many weeks on a phone
- **WHEN** a 16-week plan is shown on a 360-pixel-wide screen
- **THEN** each column is at least 40 pixels wide, the graph scrolls horizontally, and a vertical drag in a column adjusts only that week

### Requirement: Precise and accessible adjustment
The system SHALL let the athlete tap a week to select it and adjust it by ±5 TSS buttons, by arrow keys on Windows (±5 TSS, with Shift ±25 TSS), and through a screen-reader slider per week announcing week, TSS and share of the proposal. Every step SHALL stay within the week's band. The last drag or step SHALL be undoable, and reset SHALL ask for confirmation when any week differs from its proposal.

#### Scenario: Keyboard on Windows
- **WHEN** week 2 is selected at 363 TSS and the athlete presses Shift+up arrow
- **THEN** week 2 becomes 390 TSS (363 + 25, snapped to the nearest multiple of 5)

#### Scenario: Undo
- **WHEN** the athlete drags week 6 down by 40 TSS and taps undo
- **THEN** week 6 returns to its previous TSS
