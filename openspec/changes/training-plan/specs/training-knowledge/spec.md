# Spec Delta

## Purpose

Defines the structured training knowledge — phase rules, load multipliers and session templates — that the plan engine and the chat agent read from one editable source.

## ADDED Requirements

### Requirement: Training knowledge section in okf.md
The system SHALL keep training rules and session templates in a dedicated section of `docs/okf.md`, in fenced machine-readable blocks, and SHALL bundle that file as an app asset.

#### Scenario: Edit without code change
- **WHEN** a week-load multiplier in the knowledge section is edited and the app is rebuilt
- **THEN** newly generated plans use the new multiplier with no Dart code changes

### Requirement: Session templates per goal and phase
The knowledge SHALL provide, for each goal type and block phase, session templates (type, sport, duration share, intensity zone, steps in Intervals.icu step syntax) from which the engine fills in concrete sessions.

#### Scenario: Template lookup
- **WHEN** the engine needs the interval session for the peak week of a long-distance goal
- **THEN** it finds exactly one matching template or reports a clear error naming the missing goal and phase

### Requirement: Malformed knowledge is non-fatal
The system SHALL ignore a malformed knowledge block, log which block failed, and fall back to built-in defaults rather than crash or generate nonsense.

#### Scenario: Broken block
- **WHEN** a template block fails to parse
- **THEN** plan generation still works from defaults and the athlete is told the knowledge file could not be fully read

### Requirement: Agent access
The chat agent SHALL be able to retrieve templates and rules through a tool, so answers about "why this session" cite the knowledge instead of inventing physiology.

#### Scenario: Asking about a session
- **WHEN** the athlete asks why Tuesday is an interval session
- **THEN** the agent answers from the plan's rules and template and states which block phase it belongs to
