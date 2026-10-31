# Spec Delta

## Purpose

Lets the athlete ask the chat agent about their plan, reshape the load graph, generate the training calendar and move or remove sessions, with every change confirmed by the athlete before it happens.

## ADDED Requirements

### Requirement: Read the plan and load graph
The agent SHALL have a read-only tool that returns the saved goal, the load graph (per week: proposed TSS, percentage, target TSS, phase, warnings) and, when a plan exists, each plan week's target, planned and actual TSS, intensity split and sessions with date, sport, type, duration, TSS and status. Every number MUST come from the engine and the cache.

#### Scenario: Asking about this week
- **WHEN** the athlete asks "what's on this week?" while a plan is active
- **THEN** the agent calls the tool and answers with that week's sessions per day and its target versus actual TSS

#### Scenario: No goal yet
- **WHEN** no goal is saved
- **THEN** the tool reports that there is no goal, and the agent asks for the goal details instead of inventing a plan

### Requirement: Proposing load-graph changes
The agent SHALL be able to propose changes to the load graph: set one or more weeks to a percentage, make weeks recovery weeks, change the plan length, change the triathlon sport mix, or reset to the proposal. The tool SHALL apply the same bounds and validation as the graph editor (80–120% in 5% steps, 2–16 weeks, mix totalling 100%), and SHALL return the resulting curve with phases and warnings. It MUST NOT change the saved goal.

#### Scenario: Recovery week request
- **WHEN** the athlete says "make week 4 a recovery week"
- **THEN** the proposal sets week 4 to 80%, shows week 4 as a recovery week with its new TSS, and the saved graph is unchanged until the athlete applies it

#### Scenario: Out-of-range request
- **WHEN** the agent asks for week 2 at 140%
- **THEN** the tool returns an error naming the allowed range and no proposal is created

### Requirement: Proposing a plan
Generating a plan through the agent SHALL return a proposal for the plan built from the saved goal plus any pending graph changes the agent includes. Applying it SHALL open the existing plan preview, where the athlete creates the plan. Nothing is written to Intervals.icu before the athlete confirms there.

#### Scenario: Generate from chat
- **WHEN** the athlete applies a plan proposal from chat
- **THEN** the plan preview opens with the proposed sessions, and cancelling it writes nothing

### Requirement: Proposing session moves and removals
The agent SHALL be able to propose moving a session of the current plan to another date in the same plan, or removing it. Only future sessions that are not completed SHALL be eligible. Applying a move SHALL update the session's date locally and, if it exists in Intervals.icu, update that event's date. Applying a removal SHALL delete it locally and in Intervals.icu. Both SHALL re-sync the affected dates.

#### Scenario: Move a long ride
- **WHEN** the athlete applies a proposal to move Saturday's long ride to Sunday
- **THEN** the session is on Sunday in the plan, in Intervals.icu and in the Calendar tab after re-sync

#### Scenario: Past session
- **WHEN** the agent proposes moving a session dated before today
- **THEN** the tool returns an error and no proposal is created

#### Scenario: Upstream failure
- **WHEN** the Intervals.icu update fails
- **THEN** the local plan is left unchanged and the card shows the failure with a retry option

### Requirement: Confirmation in chat
The chat SHALL show each proposal as a card under the agent's reply. The card SHALL summarise the change: a read-only mini load graph with the changed weeks highlighted for graph and plan proposals, and a before/after line for session changes. It SHALL offer Apply and Dismiss. No proposal SHALL change the goal, the plan, the calendar or Intervals.icu until the athlete taps Apply.

#### Scenario: Dismiss
- **WHEN** the athlete taps Dismiss on a graph proposal
- **THEN** the saved graph is unchanged and the card shows it was dismissed

#### Scenario: Apply graph change
- **WHEN** the athlete taps Apply on a graph proposal
- **THEN** the saved goal's graph matches the proposal, the Plan screen shows it without a restart, and the change can be undone in the graph editor

### Requirement: Stale proposals
A proposal SHALL record the goal and plan state it was made from. Applying it SHALL be refused, with an explanation, when that state has changed since (graph edited, plan regenerated, session moved).

#### Scenario: Graph edited after proposal
- **WHEN** the athlete drags a week on the Plan screen and then taps Apply on an older graph proposal
- **THEN** nothing changes and the card says the proposal is out of date

### Requirement: Agent learns the outcome
On the athlete's next message the agent SHALL be told which proposals were applied, dismissed, refused as stale or failed. The agent MUST NOT describe a proposal as done before it is applied.

#### Scenario: Follow-up after apply
- **WHEN** the athlete applies a proposal and then asks "and now?"
- **THEN** the agent's context states the proposal was applied, and its answer builds on the new graph
