# Proposal

## Why

The chat agent can preview a plan with `generate_training_plan` but cannot see the athlete's current plan, change the load graph, or act on the calendar. Today "make week 4 a recovery week" or "move Saturday's long ride to Sunday" needs the athlete to leave the chat and do it by hand. The agent should handle these requests while the athlete keeps control: nothing changes until they confirm.

## What Changes

- **Read the plan**: a new `get_training_plan` tool returns the saved goal, the load graph (proposal, per-week %, targets, phases, warnings) and the current plan's weeks with sessions per day, status and actual load.
- **Adjust the graph**: a new `propose_load_curve` tool takes edits (set week N to X%, mark weeks as recovery, plan length, triathlon sport mix, reset) and returns the resulting curve, computed by the engine with its warnings, as a **proposal**.
- **Generate the calendar**: `generate_training_plan` (extended by `training-calendar-generator`) now also returns a proposal. Confirming it opens the existing plan preview sheet, and the athlete creates the plan from there.
- **Move or remove sessions**: a new `propose_session_change` tool proposes moving a planned session to another date or removing it. Confirming applies it locally and in Intervals.icu (event update or delete) and re-syncs.
- **Confirmation in chat**: each proposal shows as a card under the agent's reply: a summary, a read-only mini load graph or before/after list, and **Apply** / **Dismiss**. Nothing is written until **Apply**. A proposal goes stale and refuses to apply if the goal or plan changed after it was made.
- The agent learns what the athlete did with a proposal (applied, dismissed, stale) on its next turn. The system prompt tells it that proposals are not applied changes.
- The Plan screen refreshes when a proposal is applied from chat.

## Capabilities

### New Capabilities
- `agent-plan-assistant`: the agent's read access to the plan and graph, the proposal tools, chat confirmation cards, applying and staleness, and feeding outcomes back to the agent.

### Modified Capabilities

None. This builds on `plan-load-curve`, `triathlon-sport-mix` and `training-plan` (from the not-yet-archived `training-calendar-generator` and `training-plan` changes) without changing their requirements. Edits made through the agent go through the same validation and limits.

## Impact

- Code: `lib/agent/tools/training_data_tools.dart` (3 new tools, extended plan tool), new `lib/agent/plan_proposals.dart` (proposal model + in-memory registry + apply), `lib/agent/training_agent.dart` (new `AgentProposal` event, outcome notes), `lib/agent/system_prompt.dart`, `lib/screens/chat/chat_screen.dart` (proposal cards), `LoadCurveEditor` read-only mode, `PlanWriter`/`IntervalsWorkoutService` (move = `updateEvent`), a plan-change notifier the Plan screen listens to, l10n (en, de).
- No schema change; proposals live in memory for the chat session.
- Docs: `docs/okf.md` chat and plan sections.
- Depends on `training-calendar-generator` being applied (it is, apart from device checks).
