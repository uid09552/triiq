# Spec Delta

## Purpose

Lets generated plan sessions carry AI-authored content — a short description and
detailed, coached set information, including dedicated swim technique sessions —
on top of the numbers the deterministic plan engine already computes, with a
fully deterministic fallback when no LLM provider is configured or generation
doesn't produce something usable.

## ADDED Requirements

### Requirement: Session content generation
Once `PlanEngine` has built a plan's weeks and sessions, the system SHALL run a
content-generation pass that, for each session, produces a short one-line
description and a detailed description (reps/duration/effort, in Intervals.icu
step syntax as today) suited to its sport, slot, phase and whether it is a
technique session. The pass SHALL use the athlete's configured chat LLM provider
(Claude or Ollama) when one is configured, and MUST NOT alter the session's
date, sport, slot, minutes, load or low-intensity minutes.

#### Scenario: Provider configured
- **WHEN** the athlete has a Claude or Ollama provider configured in Settings and generates a plan
- **THEN** every session shows a short description and a detailed description written for its content, and the session's minutes/load are unchanged from what the plan engine computed

#### Scenario: No provider configured
- **WHEN** no LLM provider is configured
- **THEN** plan generation still succeeds, each session gets a deterministic short description and the same step-list detailed description the engine produces today, and nothing in the UI asks the athlete to set up an LLM

#### Scenario: Generation fails or returns something unusable
- **WHEN** the configured provider errors, times out, or its response can't be parsed into the expected content for one or more sessions
- **THEN** plan generation still succeeds and the affected sessions fall back to the deterministic content; the rest of the plan is unaffected

### Requirement: Swim technique sessions
The plan engine SHALL deterministically mark some of a triathlon plan's swim
sessions as technique-focused, rotating across the plan's non-recovery weeks, so
a swim-including plan regularly includes a session aimed at technique rather
than only aerobic and threshold effort. The content-generation pass SHALL give a
technique-focused session content built around named technique drills (e.g.
catch-up drill, fingertip drag, bilateral breathing) instead of plain effort
intervals; the deterministic fallback SHALL use a fixed, built-in drill set when
no LLM content is available.

#### Scenario: Triathlon plan with several weeks
- **WHEN** a triathlon plan with a non-zero swim share runs 4 or more non-recovery weeks
- **THEN** at least one swim session in the plan is marked technique-focused, and its description names technique drills rather than only percentages

#### Scenario: Single-sport (non-swim) goal
- **WHEN** the goal's sport is Run or Ride (no swim sessions at all)
- **THEN** no session is marked technique-focused and nothing about generation changes

### Requirement: Short and detailed descriptions shown separately
Wherever the UI shows a generated session's name without its full detail today
(the week grid, Calendar day view), it SHALL also show the session's short
description. The full detailed description (the existing set-by-set text) SHALL
remain available exactly where it is today (the session detail sheet) and SHALL
still be what is sent to Intervals.icu on confirm.

#### Scenario: Week grid tile
- **WHEN** the athlete views a generated week
- **THEN** each session's tile shows its name and short description, and opening it shows the full detailed description

### Requirement: Content generation never blocks or changes the numbers
A failure, timeout or slow response from the configured LLM provider during
content generation MUST NOT prevent a plan from being generated, MUST NOT change
any session's date, sport, slot, minutes, load, or low-intensity minutes, and
MUST NOT be retried indefinitely — generation SHALL have a bounded time budget
after which any session still without content falls back to the deterministic
text.

#### Scenario: Slow provider
- **WHEN** the configured provider takes too long to answer
- **THEN** plan generation completes within a bounded time using the deterministic fallback for whichever sessions didn't get a timely response
