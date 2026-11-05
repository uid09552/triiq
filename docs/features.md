# Features

A short tour. Every screen is described in detail in the
[specification's user documentation](okf.md#3-user-documentation).

## Today

- **Header tile** — date, status, done vs planned TSS, time and sessions, the
  refresh button; long-press or **⋯** for quick actions.
- **Readiness** — a 0–100 score ring (Ready / Caution / Back off) from HRV,
  resting HR, sleep, form and your fatigue/soreness against your own
  baselines, with a pill per signal and your fitness trend.
- **Fatigue early warning** — when the same signals stay off for several days.
- **Load tiles** — TSS today / week, CTL, ATL, form and ramp, each with a
  sparkline and trend arrow; tap for the chart, long-press for details.
- **Weekly targets** — hours per sport as rings, with a total bar.
- **Today's / tomorrow's training** — tap for details; long-press "nothing
  planned" to propose a session.
- **Plan adjustments** — missed sessions, a week off its target, hard
  sessions on low-readiness days, as Apply / Dismiss cards.

## Calendar

Month and week views of plan sessions, Intervals.icu events and completed
activities. The day card shows done vs planned load and a ✓ on covered
sessions. Long-press a day to **propose training** for it (Train now for that
day) or delete its sessions.

## Training plans

2–16 weeks for run, ride or triathlon. Drag the load curve, set the weekly
ramp and hold weeks, sport mix, long-session days and training days; taper and
race week when the plan ends at your event. A deterministic engine decides
every number; the LLM (when set up) writes the session texts.

## Train now

Proposes a session for today (or the day you long-pressed) from your recent
load — an alternative to the planned one, or a fresh one — and creates it in
Intervals.icu after you review it.

## Activities

Each workout is evaluated against its plan: verdict, intensity split,
decoupling, planned vs actual. The session diagram shows streams over time;
**intervals** are collapsed under it. Outdoor runs and rides get a **route
map** that follows the diagram cursor. Bricks (bike → run, swim → bike) get
their own card.

## Statistics & analysis

CTL/ATL trend, completed vs planned load, volume; **Performance**: power /
pace / HR curves per sport, key efforts, model fit and **threshold
suggestions** you can apply to Intervals.icu. **Analysis**: a linked
multi-graph workbench. **Weekly review** with a note from the trainer.

## Season

Fitness forecast with **form on race day**, a timeline of build / taper /
race / recovery across all A/B/C races with a **conflict check**, the **race
predictor** (finish time, pacing and fuelling plan) and **illness / injury
mode** (rest, cross-training and a graded return, applied only on confirm).

## Android extras

- **Home-screen widget**, resizable from 4×1 / 2×2 up to 4×3 with weekly
  target rings.
- **Morning briefing** notification with today's session, readiness and form.
- **Nightly background sync**.
- **Offline queue** — moves, deletes, plan sends and replacements made
  offline are sent later, for the same account only.
