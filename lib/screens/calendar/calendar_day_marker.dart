import 'package:flutter/material.dart';

import '../activities/activity_icons.dart';

/// A tiny colour-coded icon standing in for one planned or completed
/// session on a calendar cell — the activity's own icon, shrunk down.
class CalendarDayMarker extends StatelessWidget {
  const CalendarDayMarker({
    super.key,
    required this.type,
    required this.color,
    this.size = 14,
  });

  final String? type;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(activityTypeIcon(type), size: size * 0.65, color: Colors.white),
    );
  }
}
