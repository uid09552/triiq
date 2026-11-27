# Proposal

## Why

The plan is fixed once it has been taken. Session evaluation can already show that an activity was cut short or went too hard, and plan-vs-actual load is on the Plan screen, but nothing acts on it. A missed interval session simply disappears, a sick week is followed by the full planned ramp, and a hard session stays on a day when the athlete's body says no. The athlete has to notice this and ask the agent. Real coaching adapts the remaining days, and the pieces for it (session matching, move/remove actions, proposal cards with Apply/Dismiss) already exist.

## What Changes

- **Detection**, run after each sync and when Today opens, covering three situations:
  - **Missed session**: a past plan session in the current plan week with no matching activity (same day, same sport family).
  - **Load off target**: a completed plan week whose actual load is under 80 % or over 120 % of its target.
  - **Readiness conflict** (when `daily-readiness` is present): status Caution/Back off with a hard plan session today.
- **Suggestions as cards on Today**, each with **Apply** / **Dismiss**, reusing the chat's proposal model:
  - Missed interval/long session → move it to a free training day later this week that keeps hard days apart, or let it go when no day fits. A missed Z2 session → let it go.
  - Week under target → lower next week's load so the ramp restarts from what was actually done. Week over target → hold next week at its target rather than ramping further.
  - Readiness conflict → swap today's hard session with the next easy session this week, or move it to the next free day.
- Nothing changes until **Apply**. Applying uses the existing plan actions, so sessions already sent to Intervals.icu are moved or removed there too. **Dismiss** is remembered so the same suggestion doesn't return.
- The agent can create the same suggestions in chat ("I missed Tuesday, what now?") through the same rules, so chat and Today agree.
- en + de strings; docs/okf.md.

## Capabilities

### New Capabilities
- `plan-adaptation`: detecting where the athlete has drifted from the saved plan and proposing confirmed adjustments to the rest of it.

### Modified Capabilities

None.

## Impact

- New pure module `lib/plan/plan_adaptation.dart` (detection + suggestion rules) over the saved plan, cached activities and (optional) readiness.
- `lib/agent/plan_proposals.dart`: a session-swap proposal next to the existing move/remove and curve proposals; proposals are no longer created only by chat tools.
- `lib/plan/plan_actions.dart`: an atomic swap of two sessions (two moves, with an upstream rollback on failure).
- Today screen (suggestion cards), shared preferences (dismissed suggestion keys), agent tool + system prompt.
- Depends on `daily-readiness` only for the readiness trigger; the other two triggers ship without it.
