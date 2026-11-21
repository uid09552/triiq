import 'package:flutter/material.dart';

import '../activities/activity_icons.dart';

/// A tiny colour-coded icon standing in for one planned or completed
/// session on a calendar cell — the activity's own icon, shrunk down.
/// Which kind of session a marker stands for. Besides colour it differs in
/// shape, so the three read apart in greyscale: done = filled circle,
/// planned in Intervals.icu = outlined circle, TriIQ plan = outlined
/// rounded square.
enum MarkerKind { completed, planned, triiqPlan }

class CalendarDayMarker extends StatelessWidget {
  const CalendarDayMarker({
    super.key,
    required this.type,
    required this.color,
    this.size = 14,
    this.kind = MarkerKind.completed,
  });

  final MarkerKind kind;

  final String? type;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final filled = kind == MarkerKind.completed;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: filled ? color : null,
        shape: kind == MarkerKind.triiqPlan
            ? BoxShape.rectangle
            : BoxShape.circle,
        borderRadius: kind == MarkerKind.triiqPlan
            ? BorderRadius.circular(size * 0.3)
            : null,
        border: filled ? null : Border.all(color: color, width: 1.5),
      ),
      child: Icon(
        activityTypeIcon(type),
        size: size * 0.65,
        color: filled ? Colors.white : color,
      ),
    );
  }
}

/// The three marker kinds with their names, under a month grid.
class CalendarMarkerLegend extends StatelessWidget {
  const CalendarMarkerLegend({
    super.key,
    required this.done,
    required this.planned,
    required this.triiq,
    required this.l10n,
  });

  final Color done, planned, triiq;
  final ({String done, String planned, String triiq}) l10n;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall;
    Widget item(MarkerKind k, Color c, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CalendarDayMarker(type: null, color: c, size: 14, kind: k),
        const SizedBox(width: 4),
        Text(label, style: style),
      ],
    );
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 14,
        runSpacing: 4,
        children: [
          item(MarkerKind.completed, done, l10n.done),
          item(MarkerKind.planned, planned, l10n.planned),
          item(MarkerKind.triiqPlan, triiq, l10n.triiq),
        ],
      ),
    );
  }
}
