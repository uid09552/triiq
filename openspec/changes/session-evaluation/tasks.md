# Tasks

## 1. Evaluation core

- [ ] 1.1 Extract intensity folding (low/moderate/high) into a shared function used by agent tools; verify existing tool tests still pass
- [ ] 1.2 Implement `SessionEvaluator` (split, decoupling gating, planned-vs-actual, verdict + reasons); verify unit tests for easy-drifted, cut-short, no-zone-data and no-plan cases
- [ ] 1.3 Implement planned↔actual matching; verify tests for none, one, and several same-day candidates

## 2. Streams

- [ ] 2.1 SQLite table `activity_streams` + repository + lazy fetch via `getActivityStreams`/`getIntervals`; verify upgrade test and that a second open makes no request
- [ ] 2.2 Build `StreamChart` (multi-series, interval bands, drag readout, downsampling); verify golden/widget test and that a 6-hour synthetic stream paints under a set point count

## 3. Session screens

- [ ] 3.1 Add diagram, interval list, evaluation card to `ActivityDetailScreen` with loading/error/no-data states, en + de; verify widget tests and manual check in light/dark
- [ ] 3.2 Add planned-vs-actual to planned and activity detail; verify against a matched fixture
- [ ] 3.3 "Ask the trainer" hand-off: ChatScreen initial context; verify the context reaches the agent runtime message and shows no user bubble

## 4. Weekly review

- [ ] 4.1 Implement weekly aggregation (compliance, split, load trend) from the cache; verify unit tests including missed sessions and missing zone data
- [ ] 4.2 Weekly review screen (Statistics or More entry), 80/20 bar, labelled next-week note via the agent; verify offline rendering and no-provider behaviour

## 5. Docs

- [ ] 5.1 Update `docs/okf.md` (charts, activities, chat, status matrix) for streams, evaluation and review; verify sections match shipped behaviour
