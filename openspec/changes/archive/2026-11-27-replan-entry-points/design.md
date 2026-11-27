# Design

## Context

Three screens already show a single planned session and, in two of them,
offer **Change Training**:
- Calendar day detail (`lib/screens/calendar/calendar_day_detail.dart`) calls
  `showPlanSessionSheetForEvent` for a TriIQ plan session, which wires
  `onChange: () => openChangeTraining(context, e)`; it navigates to
  `PlannedWorkoutDetailScreen` for anything else.
- `PlannedWorkoutDetailScreen` itself has a **Change Training** button that
  also calls `openChangeTraining`.
- The Plan screen's week grid (`lib/screens/plan/plan_screen.dart`,
  `_WeekCard._openSession`) calls `showPlanSessionSheetFor`, the
  `PlanSession` variant of the same sheet in `plan_session_sheet.dart`,
  which never wires `onChange` — no replan option exists there.
- The Today screen (`lib/screens/today/today_screen.dart`, `_PlannedTraining`)
  always pushes `PlannedWorkoutDetailScreen` on tap, regardless of whether
  the event is a TriIQ plan session, so the bottom sheet's quicker path is
  never used there.

`openChangeTraining(context, LocalEvent e)` only needs `e.id` and `e.date`;
it is already generic across TriIQ plan sessions and synced Intervals.icu
events. `PlannedItemsRepository.toLocalEvent(PlanSession s)` is the
existing, already-used conversion from a `PlanSession` to the same
`LocalEvent` shape Calendar and Today read (`id: 'plan:${s.id}'`), so Train
Now's `initialEventId` match (`items.indexWhere((e) => e.id ==
widget.initialEventId)`) works without changes to Train Now.

See proposal.md for why this gap exists and what the fix is at a product
level; this covers how it's wired.

## Goals / Non-Goals

**Goals:**
- Reuse `openChangeTraining`, `showPlanSessionSheetForEvent` and
  `PlannedItemsRepository.toLocalEvent` as they stand; no new widgets, no
  changes to Train Now or to the plan/sync data model.
- Keep the Plan screen's week grid and the Today screen's behavior
  consistent with how Calendar's day detail already treats plan sessions
  versus synced events.

**Non-Goals:**
- Restricting the Plan screen's new **Change Training** action to the
  current week only. Calendar's day detail already offers it for any day,
  and Train Now already supports planning for a date other than the real
  "today" via its `today` callback — the week grid should not be more
  restrictive than the screen it already works from.
- Changing how non-plan (synced Intervals.icu) events behave anywhere;
  they keep opening the full detail screen, as today.

## Decisions

- **Plan screen**: give `showPlanSessionSheetFor` (in
  `plan_session_sheet.dart`) the same `onChange` wiring
  `showPlanSessionSheetForEvent` already has, building the `LocalEvent` via
  `PlannedItemsRepository.toLocalEvent(s)`. This is a one-line addition to
  an existing function rather than a new parameter threaded through
  `plan_screen.dart`, since every `PlanSession` the sheet is opened for is a
  real training session (the conversion always sets `category: 'WORKOUT'`,
  so `isTraining` holds).
  - Alternative considered: add an `onChange` parameter to
    `showPlanSessionSheetFor` and have `plan_screen.dart` pass it. Rejected
    — `showPlanSessionSheetForEvent` doesn't take one either; wiring it
    unconditionally inside the function keeps both call sites symmetric and
    needs no change at the call site in `plan_screen.dart`.
- **Today screen**: `_PlannedTraining`'s `onTap` branches on
  `event.isPlanSession` — the bottom sheet (`showPlanSessionSheetForEvent`)
  for a plan session, the existing `PlannedWorkoutDetailScreen` push
  otherwise. This mirrors the split Calendar's day detail already makes
  between its two `_Row` loops (`plannedEvents.where((e) => e.isPlanSession)`
  vs. the rest), so Today's behavior is no longer the odd one out.
  - Alternative considered: always use the detail screen (status quo) —
    rejected per the user's choice to make the card offer it directly.
  - Alternative considered: use the bottom sheet for every event,
    including synced Intervals.icu ones — rejected because
    `showPlanSessionSheetForEvent`'s "sent"/"local only" chip is defined in
    terms of `planSessionSent`, which is meaningless for a non-plan event,
    and because this would drop the detail screen's delete action and
    planned-vs-actual comparison for synced events with no replacement for
    either; the plan-session case has neither concern.

## Risks / Trade-offs

- Today's plan-session cards lose the one-tap route to
  `PlannedWorkoutDetailScreen`'s delete action and planned-vs-actual
  comparison (the bottom sheet only offers Change Training and "Open in
  Google Calendar") → Accepted: this matches Calendar's day detail exactly,
  which has worked this way since the sheet was introduced; nothing here
  removes the detail screen itself, only this one shortcut to it for plan
  sessions.
- Extending the Plan screen's action to every week, not only the current
  one, lets the athlete start Train Now for a past or future session
  → Accepted: Calendar's day detail already allows this for any date,
  and Train Now's own prompt wording ("today", "right now") is an existing
  characteristic of `openChangeTraining`'s reuse elsewhere, not something
  this change introduces or needs to fix.
