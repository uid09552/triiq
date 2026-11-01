# Tasks

## 1. Rules

- [ ] 1.1 Extend `test/sync_live_test.dart` to read a recent wellness record and confirm the `hrv`, `restingHR`, `sleepSecs`, `readiness`, `fatigue` and `soreness` keys and the fatigue/soreness scale direction; verify it passes with `--dart-define=INTERVALS_API_KEY` (stop and report if a key is missing or named differently)
- [x] 1.2 Add the `readiness` object to the §5.1 `okf-rules` block in docs/okf.md and parse it in `lib/plan/knowledge.dart`; verify knowledge unit tests for defaults and a malformed block
- [x] 1.3 `lib/evaluation/readiness.dart`: baselines (60 days, at least 14 values), signal ratings, status combination, missing-data states, device readiness passthrough; verify unit tests for every scenario in the spec

## 2. Today and detail screen

- [x] 2.1 `ReadinessService` plus the readiness tile row on Today (status, top reason, empty and waiting states), refreshed with the existing auto-sync; en + de; verify widget tests for Ready, Back off, no data and waiting
- [x] 2.2 Readiness detail screen (signal list with value, range and rating, device readiness, 30-day HRV/RHR trend, "defaults, not medical advice" note); en + de; verify widget tests
- [ ] 2.3 Hard-session hint with "Ask the trainer" opening the chat with the prefilled question; verify widget tests for hard vs Z2 days and a manual run on Android and Windows

## 3. Agent

- [x] 3.1 `get_readiness` tool in `training_data_tools.dart` and a system-prompt line to check it before advising on a hard session; verify tool tests that its output matches `evaluate` for the same records

## 4. Docs

- [x] 4.1 Update docs/okf.md (status matrix, Today user docs, training agent tools, readiness rules prose in §5); verify the sections match the shipped behaviour
