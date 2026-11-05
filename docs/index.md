# TriIQ

**An endurance and triathlon training companion for
[Intervals.icu](https://intervals.icu) — with an AI trainer, and without a
backend.** Built with Flutter for Android and Windows.

!!! abstract "The goal: no backend, full control of your data"
    There is **no TriIQ server, no TriIQ account and no tracking**. Your
    training data is cached in a database on your own device. The app only
    talks to services you choose and own:

    - **[Intervals.icu](https://intervals.icu)** for your activities, planned
      workouts and wellness data;
    - **the LLM of your choice** for the AI trainer — any model you run
      yourself with **[Ollama](https://ollama.com)** (on your machine or your
      home network), Ollama Cloud, or **Anthropic's Claude API** with your own
      key.

    Your keys stay in the operating system's secure storage, and you can
    export or restore everything as one JSON file at any time.
    → [Privacy & data](privacy.md)

## What it does

<div class="grid cards" markdown>

-   :material-view-dashboard-outline: **Today**

    Readiness score from HRV, resting HR, sleep, form and how you feel; load
    tiles with sparklines and trends; today's and tomorrow's sessions; a
    multi-day fatigue warning.

-   :material-calendar-month-outline: **Training plans & calendar**

    2–16-week plans for run, ride or triathlon with a draggable load curve,
    taper and race week; month and week calendar; long-press a day to propose
    or delete training.

-   :material-robot-outline: **AI trainer**

    A tool-calling agent over your local data that explains your training,
    proposes sessions ("Train now") and plan changes for you to apply, and
    remembers your preferences.

-   :material-chart-line: **Analysis**

    Session evaluation against the plan, streams and intervals, route map,
    power / pace / HR curves, threshold suggestions, weekly review, brick
    analysis.

-   :material-flag-checkered: **Season**

    Fitness forecast with form on race day, race calendar with conflict check,
    race predictor with pacing and fuelling, illness / injury mode.

-   :material-cellphone-arrow-down: **Android extras**

    Home-screen widget with weekly target rings, morning briefing
    notification, nightly background sync, offline queue for changes.

</div>

German and English are supported.

## Start here

- [Getting started](getting-started.md) — install, connect Intervals.icu, pick
  an LLM.
- [Features](features.md) — a tour of the screens.
- [AI trainer](ai-trainer.md) — providers, what it can and cannot do.
- [Privacy & data](privacy.md) — where data lives and where it goes.
- [Releases](releases.md) — download builds, versioning.
- [Development](development.md) — build, test, contribute.
- [Specification](okf.md) — the complete app specification, architecture
  and training rules.

!!! warning "Not medical advice"
    TriIQ is not affiliated with Intervals.icu. Training suggestions come from
    rules and an AI model — check them against how you feel and consult a
    professional when in doubt.
