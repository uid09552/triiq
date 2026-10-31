# Spec Delta

## Purpose

Keeps the local cache fresh without the athlete opening the app, while spending as little battery and data as possible.

## ADDED Requirements

### Requirement: Nightly whole-week sync
When enabled on Android and Intervals.icu is connected, the system SHALL sync wellness, activities and planned events for the current Monday-Sunday week once per day, in the user's chosen nightly window, even if the app is closed.

#### Scenario: App closed overnight
- **WHEN** the nightly window arrives and the device meets the constraints
- **THEN** the cache holds the current week's data without the app being opened

#### Scenario: Sunday
- **WHEN** the run happens on a Sunday
- **THEN** the range is extended to include Monday so tomorrow's session is cached

### Requirement: Battery and network efficiency
The scheduled sync MUST run at most once per day, MUST require a network connection, MUST NOT run while the battery is low, and MUST skip the fetch when the cache for that range was already refreshed within the last few hours.

#### Scenario: Low battery
- **WHEN** the window arrives with the battery low
- **THEN** the run is deferred by the OS and no network request is made

#### Scenario: Already fresh
- **WHEN** the app was opened and synced an hour before the window
- **THEN** the scheduled run makes no request

### Requirement: Immediate sync on open
When the app opens or returns to the foreground, the system SHALL immediately sync today's wellness, activities and planned events, without waiting for any timer, and show cached data meanwhile.

#### Scenario: Open after a ride
- **WHEN** the athlete opens the app after finishing an activity
- **THEN** today's data is fetched at once and the new activity appears without pull-to-refresh

#### Scenario: Offline open
- **WHEN** the app opens with no network
- **THEN** cached data is shown and the failure does not blank any screen

### Requirement: Auth and failure handling
A background run MUST use the stored key, MUST NOT delete the key on a network error, and SHALL record its outcome. After three consecutive failures the system SHALL notify the athlete once.

#### Scenario: Rejected key
- **WHEN** Intervals.icu answers 401/403 during a background run
- **THEN** the run records the failure, notifies the athlete that reconnecting is needed, and does not retry in a loop

### Requirement: User control and status
Settings SHALL provide an on/off toggle (default on after the first successful connect) and show the last background run's time and result.

#### Scenario: Disabled
- **WHEN** the athlete turns the toggle off
- **THEN** the scheduled work is cancelled and no further background runs occur

### Requirement: Unsupported platforms
On platforms without background scheduling (Windows, web) the system SHALL hide the toggle and rely on foreground sync only.

#### Scenario: Windows
- **WHEN** Settings → Sync opens on Windows
- **THEN** no background option is shown and a note explains sync happens while the app is open
