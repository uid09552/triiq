# Design

## Context

`get_training_guidance` (`lib/agent/tools/training_data_tools.dart`) loads one asset string through the injectable `_loadTrainingGuidance`, splits it with `_splitSections` on level-1 headings, scores sections against ASCII search terms and returns the top 3 (body truncated to 4000 chars). SQLite is at schema v4 (`lib/data/db/app_database.dart`) with additive `onUpgrade` steps. No file picker dependency exists yet. Plan knowledge (`KnowledgeRepository`, `docs/okf.md` section 5) is a separate path and stays untouched. See proposal.md.

## Goals / Non-Goals

**Goals:** import and manage several Markdown documents at runtime; one search over bundled + imported sections with document attribution; keep the tool contract backwards-compatible for the agent.

**Non-Goals:** imported knowledge affecting plan generation; embeddings or semantic search; PDF/DOCX/HTML import; syncing the library across devices; editing documents in the app.

## Decisions

1. **Store sections, not files.** Tables `knowledge_docs` (id, title, file_name, imported_at, enabled, byte_size) and `knowledge_sections` (id, doc_id, position, title, body), schema v5, empty-table upgrade. Splitting once at import keeps search cheap and makes the section count visible. Alternative: store the raw file and split per query — simpler, but repeats work and hides malformed files until the agent asks.
2. **Reuse one splitter.** Lift `_splitSections` out of the tool into a shared pure function (e.g. `lib/agent/knowledge_sections.dart`) used by the asset loader and the importer, so bundled and imported files follow the same heading rule. Add the "no heading → one section named after the file" fallback there.
3. **Strip `okf-*` fences at import.** A small scanner drops fenced blocks whose info string starts with `okf-` and counts them; the count is reported. Prose and other code fences stay.
4. **Search scoring.** Keep the existing term extraction but make it Unicode-aware (`\p{L}\p{N}`) so German terms (`Schwelle`, `Erholung`) are searchable. Score = heading hits weighted above body hits; return top 3 in full, then up to 10 further titles as `more_matches`, each with `document`. Bundled sections carry the document title "Training reference". Existing keys (`topic`, `matches[].title`, `matches[].text`) stay so the prompt contract doesn't break; `document` is added per match.
5. **Source abstraction.** `_trainingGuidance` takes a `Future<List<GuidanceSection>> Function()` that merges the asset (if present) and enabled DB sections. Tests inject fixtures; no Flutter dependency enters the tool beyond what exists.
6. **File picking via `file_selector`** (Flutter team plugin, Android + Windows, extensions `md`, `markdown`, `txt`). Alternative: `file_picker` — larger surface and more permissions than needed. If `file_selector` fails to build under this project's AGP (as `device_calendar` did), stop and report rather than swap silently.
7. **Size cap 512 KB per file**, checked before decoding; strict UTF-8 decode, reject on failure. Large enough for a long guide, small enough that one book can't dominate search.
8. **Same-name re-import** asks replace / keep both; "keep both" suffixes the title with the import date.
9. **UI:** More → "Knowledge library" (`lib/screens/knowledge/knowledge_library_screen.dart`): list with switch and delete (confirm dialog), an Import action, an import result snackbar/sheet (sections added, blocks ignored, or rejection reason), an empty state that explains what imported knowledge is used for (chat only). Hidden on web (`kIsWeb`).
10. **System prompt** mentions that guidance may come from athlete-imported documents and that answers should name the document.

## Risks / Trade-offs

- [Imported text is untrusted and goes to the LLM] → it is returned as tool data, never system prompt; the system prompt states that reference text is information, not instructions.
- [Keyword search misses synonyms] → acceptable for now; `more_matches` titles let the agent ask for a section by name.
- [Plugin build failure on Android] → explicit verify step; stop and report.
- [Long sections bloat the tool reply] → keep the 4000-char truncation per match.

## Migration Plan

Schema v4 → v5 adds two empty tables. Rollback: older builds ignore the tables. The bundled asset keeps working unchanged.

## Open Questions

- None blocking. Showing which document an answer cited in the chat UI (beyond the agent naming it) can come later without a spec change.
