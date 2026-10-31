# Proposal

## Why

The load graph's value axis is a percentage of a proposal the athlete never sees as a number, so dragging feels abstract. Athletes think in TSS. A generated plan only reaches the main Calendar tab after a round-trip through Intervals.icu, so a plan is invisible without a connection and can't be kept TriIQ-only. And everything on Intervals.icu's calendar is always copied into TriIQ, whether the athlete wants it or not.

## What Changes

- **TSS axis**: the load graph's value axis is in TSS. Dragging a week sets its TSS directly in 5-TSS steps, within that week's 80–120% band of the proposal (shown as a shaded band per week). The proposal is drawn as a dashed ramp, and the percentage moves to the drag label. The ±buttons and arrow keys step 5 TSS (Shift+arrow: 25).
- **Take as plan**: the preview's confirm button becomes **Take as plan**. It saves the plan locally, switches the app to the main **Calendar** tab at the plan's first week, and shows the plan's sessions there right away, marked as TriIQ plan sessions. If sending to Intervals.icu is enabled, the sessions are then created there in the background, with a per-session result as today.
- **Settings → Calendar**, two separate switches:
  - **Send plan to Intervals.icu** (default on): off keeps plans local. Turning it on offers to send the current plan's not-yet-sent future sessions.
  - **Copy planned events from Intervals.icu** (default on): off stops syncing planned events from Intervals.icu. Calendar, Today and Statistics then show only TriIQ plan sessions and completed activities. Cached events are hidden, not deleted, and come back when the switch is turned on and synced.
- The Calendar, Today ("planned tomorrow", week planned TSS) and Statistics (planned load) read from one merged source of planned items: the TriIQ plan plus, when enabled, Intervals.icu events. A session that exists in both is shown once.

## Capabilities

### New Capabilities
- `calendar-sources`: the merged planned-items source, the two Settings switches, de-duplication, and how Calendar, Today and Statistics use it.

### Modified Capabilities
- `plan-load-curve` (from `training-calendar-generator`): the editor's value axis, drag units and step sizes change from percent to TSS.
- `training-plan` (from `training-plan`): "Preview before writing" and "Writing plan sessions to Intervals.icu" become local-first **Take as plan**, with sending to Intervals.icu controlled by the setting.

## Impact

- Code: `lib/widgets/charts/load_curve_editor.dart` and `LoadCurveController` (TSS snapping and axis), `plan_preview_sheet.dart`, `PlanService.confirm`, `PlanWriter`, new `lib/data/planned_items.dart`, `CalendarScreen` / day detail / markers, Today and Statistics planned values, `SyncService` (skip events when off), `SyncSettings` (two flags), `SettingsScreen`, `MainShell` (switch to the Calendar tab and focus a date from anywhere), l10n (en, de).
- No schema change: `plan_sessions` already has `intervals_event_id` and a status. A local-only session is `planned` without an event id.
- Interacts with the proposed `agent-training-calendar`: its `propose_load_curve` should take TSS values as well as percentages. Update that change's spec before applying it.
- Docs: `docs/okf.md` (plan, calendar, settings, sync).
