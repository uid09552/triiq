# Tasks

## 1. Data

- [ ] 1.1 Live tests fetching power / pace / HR curves (`s0,s1,42d`) per sport through the raw fetch and parsing them; verify the live suite passes
- [x] 1.2 Pure-Dart parser to `CurvePeriod` (duration and swim-distance points, activity ids, model fits) and key-duration lookup without interpolation; verify unit tests from captured fixtures including missing model and missing season
- [x] 1.3 `performance_curves` table (schema bump) + repository with staleness against newest cached activity per sport; verify upgrade test and that a second open makes no request

## 2. Chart

- [x] 2.1 `DurationCurveChart` (log x-axis, fixed ticks, axis titles and units, multiple series, pace plotted faster-is-higher, drag readout, downsampling); verify widget/golden tests for power, pace and swim distance axes

## 3. Screen

- [ ] 3.1 Performance screen (sport/metric pickers limited to available data, chart, legend with date ranges, key durations table, model card, loading/error/retry/offline states), entry on Statistics, en + de; verify widget tests and manual check in light/dark on Android and Windows
- [x] 3.2 Readout → open source activity detail; verify widget test with a fixture activity id

## 4. Agent

- [x] 4.1 `get_performance_curve(sport, metric)` tool (periods, key durations with dates and activity ids, model gap); verify tool tests and that it never writes

## 5. Docs

- [x] 5.1 Update `docs/okf.md` (charts, statistics, agent, local storage, status matrix); verify sections match shipped behaviour
