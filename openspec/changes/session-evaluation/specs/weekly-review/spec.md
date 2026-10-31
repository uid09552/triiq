# Spec Delta

## Purpose

Summarises a training week against its plan so the athlete sees compliance, intensity distribution and load trend, and what to adjust next.

## ADDED Requirements

### Requirement: Weekly compliance
The system SHALL show, per day and for the week, planned versus completed sessions, time and load, and a compliance percentage.

#### Scenario: Missed session
- **WHEN** a planned session has no matching completed activity
- **THEN** it appears as missed in the week and reduces the compliance figure

### Requirement: Weekly 80/20 distribution
The system SHALL show the week's low/moderate/high time split as a bar and flag deviation from 80/20, and SHALL state when sessions lack zone data.

#### Scenario: Too much moderate
- **WHEN** moderate-intensity time exceeds the tolerance
- **THEN** the split is flagged with the actual percentages

### Requirement: Load trend
The review SHALL show the week's load against recent weeks and the CTL/ATL/Form change over the week.

#### Scenario: Load up
- **WHEN** the week's load is above the 4-week average
- **THEN** the review shows the difference and the CTL change

### Requirement: Next-week note
The review SHALL offer a short next-week recommendation, clearly labelled as inference, that the athlete can open in Chat.

#### Scenario: Recommendation shown
- **WHEN** the review is generated and an LLM provider is configured
- **THEN** a labelled recommendation appears; without a provider the figures still show and the note is omitted

### Requirement: Offline operation
The review SHALL be computed from the local cache and work offline for synced weeks.

#### Scenario: Airplane mode
- **WHEN** the athlete opens the review for a synced week with no network
- **THEN** all figures render
