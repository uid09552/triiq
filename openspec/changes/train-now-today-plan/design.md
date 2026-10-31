# Design

## Context

`TrainNowScreen` (`lib/screens/today/train_now_screen.dart`) shows sport, duration, intensity and custom-instruction controls, a **Propose training** button and the streamed proposal.
- `_createInIntervals` asks the agent to restructure the reply (`workoutStructuringPrompt` → `parseWorkoutDraft`), shows `_WorkoutPreviewSheet`, then `IntervalsWorkoutService.createPlannedWorkout` for today and re-syncs.
- Today's planned items come from `PlannedItemsRepository` (plan sessions as `LocalEvent` with `isPlanSession`, `planSessionId`, `planSessionSent`; Intervals.icu events otherwise).
- `PlansRepository.updateSession` only changes date, description, ids and status.
- Intervals.icu deletes go through `IntervalsWorkoutService.deletePlannedWorkout` + `EventsRepository.deleteById`.
- `SyncSettings.sendPlanToIntervals` and `PlanChanges` exist.

## Goals / Non-Goals

**Goals:**
- Train Now reflects today's plan and turns "find something else" into one tap.
- Replacing keeps the plan coherent (the same slot changes) and never leaves the calendar half-changed silently.

**Non-Goals:**
- Alternatives for days other than today; rebalancing the rest of the week after a swap.
- Editing the planned session's steps by hand.

## Decisions

1. **Source of today's sessions.** `PlannedItemsRepository.getByDate(today)`, filtered to `isTraining`, loaded in `initState` and reloaded on `PlanChanges` / `AutoSyncService` / `SyncSettings`.
   - The screen gets optional constructor seams (`plannedItems`, `workouts`, `plans`, `settings`) for tests, as done for `TodayScreen`.
   - `PlannedItemsRepository.toLocalEvent` also writes `raw['triiq_plan_slot']` so presets can use the slot.
2. **Card.** New `PlannedSessionCard` widget:
   - It shows a sport icon in sport colour, the name, `planSessionMinutes(minutes, tss)`, and a source chip (*TriIQ plan* plus a cloud icon, or *Intervals.icu*).
   - Steps are monospace, collapsed after 6 lines with "Show all". The card is selectable (radio-like border) when more than one is shown.
   - It is reused nowhere else for now. The Calendar keeps its own row.
3. **Presets from the selected session.**
   - Sport: `type` normalised (`VirtualRide` → Ride, etc.), else unchanged.
   - Duration: `plannedTime / 60`, clamped and rounded to the slider's range and step.
   - Intensity: from the slot (`intervals` → Intervals, `z2`/`long` → Endurance). Names with *recovery*/*easy* → Recovery. Endurance otherwise.
   - Presets apply when the selection changes. Later edits by the athlete stick.
4. **Prompt.** `_buildPrompt()` stays as is for a new proposal. For an alternative, it prepends:
   > Today I have this planned: <sport> "<name>", <min> min, ~<tss> TSS, steps:<steps>. I want an alternative instead of it: aim for a similar training effect and load unless my recent load says otherwise, then say why.
   
   Then come the usual sport, duration and intensity, the format rules, and custom instructions. The steps are truncated to about 1,500 characters.
5. **Replace path, `PlanActions.replaceSession`** (new, `lib/plan/plan_actions.dart`), with injected `PlannedWorkoutWriter`, `PlansRepository`, `EventsRepository` and the send flag:
   - **Plan session:**
     - If it was sent and sending is on and connected: create the new workout upstream, then delete the old event; a 404 on delete counts as gone.
     - If it was sent but sending is off or there's no connection: refuse with "connect or turn sending on". A local-only change would leave the old event upstream, which the calendar would then show twice.
     - Then `PlansRepository.replaceSessionContent(id, sport, name, minutes, load, description, intervalsEventId, status)`.
     - If it wasn't sent: local update only (status `planned`).
   - **Intervals.icu event:** create the new workout, then delete the old event and drop it from the cache. If the delete fails, report "both exist" (spec'd) and keep the new one.
   - Then re-sync today's month when anything went upstream, and ping `PlanChanges` and `AutoSyncService.notifyCacheChanged()`.
   - The new plan-session TSS/minutes come from the parsed draft (`durationSeconds`, `load`). If the draft has no load, the session keeps its old TSS and is marked estimated in the description footer. Low minutes are recomputed as minutes × 0.8 (unknown split) so the 80/20 check stays defined. That is noted as an assumption in the plan screen's split line ("estimated").
6. **Preview choice.** `_WorkoutPreviewSheet` gains a segmented **Replace today's session / Add alongside**, shown only for an alternative. The confirm returns the choice. **Add** keeps the current create path.

## Risks / Trade-offs

- [The draft carries no TSS] → keep the old TSS and mark it estimated, rather than invent one.
- [Replacing a sent plan session offline] → refused with a clear message, as above.
- [Small models ignore the reference session] → the prompt puts the reference first and repeats the target duration. The athlete still reviews the preview.
- [Multiple sessions today and replacing the wrong one] → the selected card is explicit, and the preview names the session being replaced.

## Migration Plan

No data migration. The extra `raw` key is ignored by older readers.

## Open Questions

None blocking.
