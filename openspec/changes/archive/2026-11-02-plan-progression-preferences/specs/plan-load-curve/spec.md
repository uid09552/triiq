# Spec Delta

## MODIFIED Requirements

### Requirement: Proposed load curve
The system SHALL propose a target TSS for every plan week as a ramp from the athlete's baseline weekly load, where each week's proposal is at most the previous week's proposal times (1 + ramp). The ramp SHALL be set by a slider from 0% to 15% in 1% steps, default 10%, saved in the goal and labelled as a default. By default every 4th week (weeks 4, 8, 12, …) SHALL be held at the previous week's proposal (0% increase); a switch SHALL turn this hold off. The proposal MUST NOT insert recovery dips by default and MUST also respect the CTL-ramp limit and the weekly hours budget. Changing the ramp or the hold SHALL redraw the proposal immediately while each week keeps its share of the proposal.

#### Scenario: Ramp with hold weeks
- **WHEN** the baseline is 300 TSS, the ramp is 10%, the hold is on and the plan has 8 weeks with no other limit active
- **THEN** the proposed weeks are 330, 363, 399, 399, 439, 483, 531 and 531 TSS (rounded)

#### Scenario: Hold off
- **WHEN** the hold switch is off and the plan has 4 weeks from 300 TSS at 10%
- **THEN** the proposed weeks are 330, 363, 399 and 439 TSS

#### Scenario: Slider
- **WHEN** the athlete sets the ramp slider to 5%
- **THEN** the proposal is redrawn at +5% a week, a week the athlete had dragged to 90% stays at 90% of its new proposal, and the goal stores 5%

#### Scenario: Hours budget limits the ramp
- **WHEN** the proposed load for week 5 needs more hours than the weekly budget
- **THEN** week 5 and later are held at the budget's load and shown as limited by hours

#### Scenario: No baseline
- **WHEN** there is too little history and the goal has no baseline load
- **THEN** the system asks for a baseline instead of drawing a curve
