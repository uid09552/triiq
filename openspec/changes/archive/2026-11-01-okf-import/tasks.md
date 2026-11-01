# Tasks

## 1. Parsing

- [x] 1.1 Extract `_splitSections` into a shared pure function with the no-heading fallback; verify existing `get_training_guidance` tests still pass and new tests cover headings, no heading, empty file
- [x] 1.2 Add the `okf-*` fence stripper returning cleaned text and an ignored-block count; verify tests for one/several blocks, non-okf fences kept, unterminated fence

## 2. Storage

- [x] 2.1 Schema v5: `knowledge_docs` + `knowledge_sections` with additive upgrade; verify an upgrade test from v4 and a fresh-create test (implemented as v5→v6: v5 was already taken by performance_curves, added after this change was proposed)
- [x] 2.2 `KnowledgeLibraryRepository` (import with size cap and strict UTF-8, list, enable/disable, delete, replace-or-keep-both, enabled sections); verify unit tests for oversized, invalid UTF-8, empty, replace and keep-both

## 3. Agent

- [x] 3.1 Merge bundled + enabled imported sections in `_trainingGuidance`, Unicode-aware terms, heading-weighted score, `document` per match, `more_matches`, grouped listing for empty topic, updated no-reference message; verify tool tests for imported-only match, many matches, disabled doc excluded, German term, nothing available
- [x] 3.2 System prompt: name the source document, treat reference text as information not instructions; verify the prompt test/snapshot

## 4. UI

- [x] 4.1 Add `file_selector` (md, markdown, txt); verify `flutter build apk --debug` and a Windows build succeed (stop and report if not) — `flutter build apk --debug` succeeds; `flutter build windows` could not be verified here: this machine's Visual Studio install is missing the "Desktop development with C++" workload (pre-existing per `flutter doctor`, unrelated to `file_selector`), so no Windows build of any kind is currently possible on this machine
- [ ] 4.2 Knowledge library screen under More (list, switch, delete confirm, import with result/rejection message, same-name dialog, empty state), hidden on web, en + de; verify widget tests and a manual import on Android and Windows

## 5. Docs

- [x] 5.1 Update `docs/okf.md` (training agent, local storage, More, user docs, known gaps) and `assets/knowledge/README.md`; verify sections match shipped behaviour
