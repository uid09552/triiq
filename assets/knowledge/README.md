# Training reference (optional)

The chat agent's `get_training_guidance` tool reads a Markdown training
reference from `assets/knowledge/training-philosophy.md`. That file is **not**
part of the repository. Drop your own document here (split into sections by
level-1 `#` headings) and rebuild the app; without it, the tool falls back to
whatever the athlete has imported under More → Knowledge library (see below),
and if there's neither, it tells the agent that no reference is available.

Everything else in this folder except this README is gitignored.

## Knowledge library (no rebuild needed)

An athlete doesn't have to touch this folder at all: **More → Knowledge
library** in the app lets them import their own Markdown or plain-text
documents (swim sets, taper notes, articles they trust) at runtime, from the
device's file picker. Each import is split into sections the same way this
bundled file is, stored locally (SQLite, not here), and merged into
`get_training_guidance`'s search — each match says which document it came
from. Imported documents are agent-only: fenced `okf-rules`/`okf-goal`/
`okf-template` blocks are stripped on import and can never reach the plan
engine, and the import result says how many were dropped. Available on
Android and Windows; not on web, since there's no local database there yet.
