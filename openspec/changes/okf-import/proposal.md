# Proposal

## Why

The chat agent's coaching knowledge comes from one Markdown file (`assets/knowledge/training-philosophy.md`) that has to be dropped into the source tree and compiled into the app. An athlete can't add swim technique notes, taper guides or articles they trust without rebuilding, so the agent answers those topics from general model knowledge instead of the athlete's own references.

## What Changes

- **Knowledge library** under More: import one or more Markdown files from the device, list them (title, source file, section count, imported date), turn each on or off, and delete it.
- **Import** splits a file into sections at level-1 `#` headings (the same rule the bundled reference uses) and stores them locally. Files with no `#` heading become one section titled after the file. Fenced `okf-rules` / `okf-goal` / `okf-template` blocks are ignored and the import says so — imported knowledge never changes plan generation.
- **`get_training_guidance`** searches the bundled reference plus every enabled imported document, scores headings and body, returns the top matches with the title of the document each came from, and lists the rest by title.
- Size cap per file; oversized or non-text files are rejected with a reason.
- en + de strings; docs updated.

## Capabilities

### New Capabilities
- `knowledge-library`: importing, managing and searching athlete-supplied coaching documents for the chat agent.

### Modified Capabilities

None. `training-knowledge` (plan rules and templates read by the engine) is unchanged — this change is agent-only by decision.

## Impact

- Code: new `lib/data/repositories/knowledge_library_repository.dart`, SQLite schema bump (v5: `knowledge_docs`, `knowledge_sections`), `_trainingGuidance` in `lib/agent/tools/training_data_tools.dart`, new screen under `lib/screens/knowledge/`, entry in `more_screen.dart`, system prompt wording, l10n (en, de).
- Dependency: a file picker plugin (`file_selector`) for Android and Windows.
- Platforms: Android and Windows. Web has no local database, so the library is hidden there and the agent falls back to the bundled reference only.
- Docs: `docs/okf.md` (agent, local storage, More, known gaps).
