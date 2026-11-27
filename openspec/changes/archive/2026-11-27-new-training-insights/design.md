# Design

## Context

The building blocks already exist:
- `AutoSyncService` runs a today sync on cold start and resume, and notifies listeners when the cache changes.
- `SessionEvaluator` + `matchPlanned` give the verdict, reasons and split.
- `PlannedItemsRepository` knows tomorrow's planned sessions, with intent via `SessionEvaluator.intentOf`.
- `WellnessRepository` has CTL/ATL (form = CTL − ATL).
- The cached activity `raw` holds Intervals.icu fields, incl. `icu_achievements` and `icu_efficiency_factor`.
- Train Now can find an alternative for a planned session (today only).

## Goals / Non-Goals

**Goals:**
- Feedback at the moment of opening, once, never nagging.
- Every number is code or Intervals.icu's own figure; estimates are labelled.

**Non-Goals:**
- Push notifications for new sessions (background sync already notifies about sync, if at all).
- Our own best-effort computation from streams.
- Alternatives for days after tomorrow.

## Decisions

1. **Trigger after open-sync, not on every cache change.** `AutoSyncService` gets an `openSyncDone` stream (or callback), fired after the cold-start/resume today sync, whether it succeeded or failed (then the cache is used as is). `MainShell` listens, and only while it is the visible root route, so it never interrupts a pushed screen or a dialog. It asks `NewTrainingInsights.unseenToday()` and shows the sheet. A periodic sync while open doesn't trigger it (spec'd).
2. **Seen store.** `SeenSessionsStore` (SharedPreferences, key `insights.seen`) keeps `{date: 'YYYY-MM-DD', ids: [...]}` for **today only**. A different date means empty, so old ids never accumulate and yesterday's never-seen sessions are excluded by construction. OK / dismiss adds the shown ids. `ActivityDetailScreen` adds its id when the activity is today's.
3. **Insights as pure functions** (`lib/evaluation/insights.dart`):
   - **`personalBests(raw)`** parses `icu_achievements` defensively. It handles a list of maps with `type` / `secs` / `value` / `distance` / `previous` (or `prev_value`) keys, skips anything unrecognised, and returns typed `BestEffort(kind: power|pace|time, duration?, distance?, value, previous?)`. Unknown shapes give an empty list, never an exception. Task 1.1 includes checking a real payload in the live suite and adjusting the parser.
   - **`efficiencyTrend(activity, history)`**: the session counts as easy if its intent is easy or its low share is ≥ 0.8. History is the same sport family, easy, within the 42 days before, with an EF present. It needs ≥ 4 of them. It returns the median and the change in percent.
   - **`recoveryHint(tss, form, tomorrow)`**: hours from the knowledge rules (`recoveryHours`: `[{maxTss: 50, hours: 12}, {maxTss: 100, hours: 24}, {maxTss: 200, hours: 36}, {hours: 48}]`), +12 h when form < `recoveryFormPenaltyBelow` (−20), capped at 72. The conflict check: tomorrow has a planned session with hard intent, and the session end plus hours > tomorrow 10:00. It returns hours, the rule text and the conflicting event.
4. **Sheet**: a full-height modal bottom sheet. `PageView` with dots, a page per unseen session, newest first (by `start_date_local`). Each page reuses `IntensitySplitBar`, the verdict chip and reasons from the session analysis (extracted into small widgets), plus the PB list, EF line and recovery card. **Find alternative** pops the sheet and opens `TrainNowScreen` with `today: tomorrow`. Its existing `today` seam is promoted to a real "for date" parameter that only changes which planned items it loads and the created workout's date.
5. **Activity detail** gets an "Insights" card (PBs, EF trend, recovery hint only for today's session) under the evaluation card.
6. **Settings**: a `insightsPopupEnabled` flag in `NotificationSettings` (it already holds similar toggles), shown in the Notifications section.

## Risks / Trade-offs

- [`icu_achievements` shape differs from the assumption] → defensive parser, live check in the tasks, and the section is hidden when nothing parses.
- [Pop-up appears at a bad moment] → only after open-sync, only on the root route, and once per session.
- [The recovery rule reads as medical advice] → labelled as an estimate, with the rule and its knowledge source shown. Values are editable in `docs/okf.md`.
- [Train Now for tomorrow] → a small widening of Train Now's date. Replace/add logic is unchanged and uses that date.

## Migration Plan

New preference keys only. Rollback: remove the trigger; nothing else depends on it.

## Open Questions

None blocking.
