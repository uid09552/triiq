# Spec Delta

## Purpose

Shows whether the athlete is getting faster: their best efforts over every duration per sport, compared across periods, with the model thresholds Intervals.icu fits from them.

## ADDED Requirements

### Requirement: Performance screen
The system SHALL offer a Performance screen reachable from Statistics, with a sport picker (Ride, Run, Swim) and a metric picker limited to the metrics that sport has data for (power, pace, heart rate).

#### Scenario: Run without running power
- **WHEN** the athlete picks Run and Intervals.icu returns no run power curve
- **THEN** Power is not offered and Pace is selected

### Requirement: Duration curve chart
The system SHALL chart the selected curve on a logarithmic x-axis — duration for power and heart rate, distance for pace (Intervals.icu keys pace curves by distance) — with labelled axes and units (W, min/km, min/100 m, bpm), comparing this season with last season. Pace SHALL be drawn so that faster is higher. Tapping a point SHALL show the duration, the value and the date of the session that set it, and offer to open that session.

#### Scenario: Comparing seasons
- **WHEN** the athlete opens Ride → Power with data in both seasons
- **THEN** both curves are drawn on one chart with a legend, and the axes read "Duration" and "Power (W)"

#### Scenario: Opening the source session
- **WHEN** the athlete taps the 5-minute point of this season's curve
- **THEN** the readout shows the value and date, and opening it shows that activity's detail screen

#### Scenario: One season missing
- **WHEN** last season has no data for the selected sport and metric
- **THEN** this season is drawn alone and the legend says last season has no data

### Requirement: Key durations table
The system SHALL show the best value at fixed key points (power and HR: 5 s, 1 min, 5 min, 20 min, 60 min; run pace: 400 m, 1 km, 5 km, 10 km, 21.1 km; swim pace: 100, 200, 400, 1500 m) for each compared period with the difference between them, leaving a cell empty when the period has no effort that long.

#### Scenario: No long effort
- **WHEN** this season has no ride longer than 40 minutes
- **THEN** the 60 min cell for this season is empty, not zero

### Requirement: Model card
The system SHALL show the model values Intervals.icu fits to the current season's curve where returned (power: FTP, CP, W', Pmax; pace: critical speed, D'), and SHALL compare power FTP with the settings FTP and pace critical speed with the settings threshold pace, showing the difference in absolute and percent terms. This card SHALL NOT change any setting.

#### Scenario: Model above settings
- **WHEN** the model FTP is 262 W and the sport settings FTP is 252 W
- **THEN** the card shows both and "+10 W (+4%)"

#### Scenario: No model returned
- **WHEN** the curve response has no model fit
- **THEN** the card says no model is available and shows the settings value alone

### Requirement: Fetching and caching
The system SHALL fetch curves when the Performance screen opens and no cached copy exists for the sport and periods, store them locally, render from the cache on later opens and offline, and refetch after a sync that added activities. A failed fetch SHALL show an error with retry and keep any cached data visible.

#### Scenario: Offline after first open
- **WHEN** the athlete opens Performance again without a network
- **THEN** the cached curves render and nothing is requested

#### Scenario: New activity synced
- **WHEN** a sync adds an activity for Ride
- **THEN** the next open of Ride curves fetches fresh data

### Requirement: Agent access
The chat agent SHALL be able to read curves, key durations and the model-versus-settings gap through a read-only tool, per sport, metric and period.

#### Scenario: Am I faster than last year
- **WHEN** the athlete asks whether their 20-minute power improved on last season
- **THEN** the agent answers from the tool's key durations and names the sessions that set them
