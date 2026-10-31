# Design

## Context

- **Load graph:** `LoadCurveEditor`/`LoadCurveController` work in factors (0.80–1.20 of the proposal, 5% snap). `Goal.loadFactors` stores factors, and the engine multiplies them by the proposal.
- **Plan confirm:** `PlanScreen._generate` runs preview → `PlanService.confirm`, which saves the plan and then `PlanWriter.write` (create in Intervals.icu, resync). The plan only reaches the Calendar via synced events.
- **Planned-item reads:** every consumer reads `EventsRepository` (`LocalEvent`): Calendar, Today, its TSS history and weekly-load screens, Statistics, the agent's `get_planned_workouts`.
- **Sync:** `SyncService._fetchRange` always fetches wellness, activities and events.
- **Settings:** `SyncSettings` (singleton `ChangeNotifier`, shared preferences) holds the sync options. Settings → Sync renders them.
- **Navigation:** `MainShell` keeps the tabs in an `IndexedStack`, with a private `_index`.

## Goals / Non-Goals

**Goals:**
- One merged planned-items read path, so every screen agrees.
- Plans are useful without Intervals.icu. Turning a switch off never deletes data.
- The graph speaks TSS without changing what is stored (still factors).

**Non-Goals:**
- Two-way editing of plan sessions from the Calendar (moving or deleting there). The agent change covers moves.
- Pulling Intervals.icu events selectively (by category).
- Device-calendar export changes.

## Decisions

1. **The graph keeps factors in storage and edits in TSS.**
   - The controller gains `bandFor(i)`: `[ceil5(0.8·p), floor5(1.2·p)]`, falling back to the raw edges if the band rounds to empty. Snapping is `round5` clamped into the band.
   - `dragTss(i, tss)` and `stepTss(i, delta)` set `factor = snapped / p`.
   - `_fit` clamps stored factors instead of snapping them to 5%, so TSS-snapped factors survive. `Goal.validate` already checks only the range.
   - Rejected: storing absolute TSS. It would break "keeps its share when the baseline changes" (spec'd).
2. **Painter.**
   - The axis runs from the minimum lower edge to the maximum upper edge, padded and rounded to a "nice" step (25/50/100), with 4–6 labelled TSS ticks.
   - Per column it draws a translucent band rectangle, a dashed polyline through the proposals, and the solid adjusted line.
   - Drag maps `dy` to TSS with `range / plotHeight`.
   - The label reads `Week n · 420 TSS · 105%` plus the change from last week.
3. **Merged source: `PlannedItemsRepository`** (`lib/data/planned_items.dart`) has `getRange(from, to)` and `getByDate(day)` returning `List<LocalEvent>`.
   - It reads cached events only when copying is on.
   - It turns current-plan sessions into `LocalEvent`s: id `plan:<sessionId>`, category `WORKOUT`, sport, name, steps as description, load, minutes·60, and `raw['triiq_plan_session'] = id` plus `raw['sent']`.
   - De-dup: when copying is on, a session whose `intervals_event_id` matches a cached event id is dropped in favour of the event.
   - `LocalEvent.planSessionId` / `isPlanSession` getters read `raw`.
   - All the read-only consumers listed above switch to this repository. Delete paths (`planned_workout_actions`) keep using `EventsRepository`.
   - Rejected: writing plan sessions into the `events` table. Sync's `replaceRange` would wipe them, and their ownership would blur.
4. **Settings.**
   - `SyncSettings` gains `sendPlanToIntervals` and `copyIntervalsEvents` (both default true, persisted).
   - It adds a static `readCopyIntervalsEvents()` that reads the preferences directly, so the background isolate's `SyncService` honours the flag without the singleton.
   - When the flag is off, `_fetchRange` skips the events request, `replaceRange` and the `events` sync-state record, and returns `eventsCount: 0`.
   - The Settings screen gets a **Calendar** section with two `SwitchListTile`s.
   - Turning copying on runs `SyncService.syncRange` for the current month.
   - Turning sending on when the current plan has future sessions without an event id shows a dialog. "Send N sessions" calls `PlanWriter.write`, which already skips sessions that are `created`.
5. **Take as plan.**
   - `PlanService.take(draft, replacing)` saves the plan (status active), removes the replaced plan's upcoming sessions as today, and pings `PlanChanges`.
   - `PlanService.send(plan)` runs `PlanWriter.write` and is only called when `sendPlanToIntervals` is on.
   - `PlanScreen` calls `take`. It then captures the app-level `ScaffoldMessenger`, pops to the root route and calls `MainNavigation.instance.openCalendar(plan.startDate)`. If sending is on, it calls `send` without awaiting the UI, and the result snackbar lands on the root messenger.
   - The preview button label changes to **Take as plan**.
6. **Navigation.**
   - `MainNavigation` is a `ChangeNotifier` singleton with `tab` and `calendarFocus` (a date plus a sequence number, so the same date can be requested twice).
   - `MainShell` listens to it and sets `_index`. `CalendarScreen` listens to it, sets focused/selected date and reloads.
7. **Refresh.**
   - `PlanChanges` (a new `ChangeNotifier` singleton, in `lib/plan/plan_changes.dart`) is pinged by take, remove, retry/send and session status updates.
   - The Calendar, Today, Statistics and Plan screens listen to it, like `AutoSyncService`. The setting toggles also notify via `SyncSettings`.
8. **Day detail.** Plan sessions get a small "TriIQ plan" badge and an icon that shows whether they were sent. Tapping opens a sheet with the steps and the sent / not-sent status, reusing the plan screen's session sheet, which is extracted into `lib/screens/plan/plan_session_sheet.dart`.

## Risks / Trade-offs

- [The plan's first week is outside the cached/visible range] → `openCalendar` focuses that date, and the Calendar loads the range around it (plan sessions are local, so they show even without a sync).
- [Sending fails while the user is already in the Calendar] → the sessions stay visible as unsent, and the snackbar offers **Retry**, which calls `send` again.
- [Copy off hides events the athlete created directly in Intervals.icu] → that's the point of the switch. Its subtitle says so.
- [The agent change's `propose_load_curve` is percent-based] → noted in the proposal. Its spec gets updated before it is applied.

## Migration Plan

New preference keys default to the current behaviour (both on). Stored factors stay valid. No schema change.

## Open Questions

None blocking.
