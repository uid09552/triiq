# Design

## Context

Charts are hand-rolled `CustomPainter` widgets (`SimpleBarChart`, `MetricLineChart`). Activity detail converts the cached `raw` JSON to a typed `Activity` and has a zone bar. Agent tools already fold zone times into low/moderate/high. The generated client has `getActivityStreams` and `getIntervals`. See proposal.md.

## Goals / Non-Goals

**Goals:** a stream chart that stays smooth on long rides; deterministic evaluation; reuse the existing intensity folding; chat hand-off.

**Non-Goals:** map view, power curves, editing intervals, comparing two activities.

## Decisions

1. **New `StreamChart` widget** in `lib/widgets/charts/` (multi-series over time, shaded bands, drag readout, theme colours), same approach as the existing charts. Alternative: add a charting package — rejected for the same reasons as in okf.md.
2. **Downsample before painting** (e.g. min-max bucket to ~600 points) so a 6-hour ride doesn't create tens of thousands of path points.
3. **Streams cached in a new SQLite table** (`activity_streams`: activity id, JSON blob, fetched_at), schema bump with empty-table upgrade. Fetched lazily; never in sync.
4. **`SessionEvaluator` in `lib/evaluation/`** is pure Dart over (activity, planned event?, streams?) and returns structured results (split, decoupling, deltas, verdict, reasons). The intensity-folding code is lifted out of the tools into a shared function used by both evaluator and tools.
5. **Planned↔actual matching:** same date and sport; if several, nearest duration. Unmatched stays unmatched (no guessing).
6. **Chat hand-off:** `ChatScreen` accepts an initial context payload (session/week summary JSON from the evaluator) injected into the runtime context, not shown as a user bubble.
7. **Next-week note** is an LLM call over evaluator output, labelled inference; figures never depend on it.

## Risks / Trade-offs

- [Large stream payloads] → fetch only needed types, cache once, downsample for paint.
- [Decoupling is meaningless on short/variable sessions] → compute only above a minimum steady duration, otherwise state not assessable.
- [Verdict thresholds look authoritative] → show the figures and thresholds' source (knowledge section) beside the verdict.

## Migration Plan

Additive schema bump (empty table). Rollback: ignore the table.

## Open Questions

- Which streams beyond power/HR/pace to expose first (cadence, altitude) — can ship incrementally without spec change.
