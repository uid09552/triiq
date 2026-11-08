import 'package:flutter/material.dart';

import 'gauge_ring.dart';

/// A circular progress ring for a single weekly sport target: a background
/// track, a progress arc visually capped at 100% so an over-achieved sport
/// never draws past a full circle, a percentage in the centre, and the
/// sport name plus an achieved/target line below.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.label,
    required this.percentLabel,
    required this.valueLabel,
    required this.progress,
    required this.color,
    required this.doneColor,
    this.size = 92,
    this.strokeWidth = 7,
    this.icon,
  });

  /// The sport's icon, shown inside the ring above the percentage — swapped
  /// for a check once the target is met.
  final IconData? icon;

  /// The sport name, shown below the ring.
  final String label;

  /// e.g. "150%" — shown centred inside the ring.
  final String percentLabel;

  /// e.g. "3.0 / 2.0 h" — shown below [label].
  final String valueLabel;

  /// achieved / target. May exceed 1.0; the arc itself is capped — see
  /// [cappedProgress].
  final double progress;

  /// Arc/text colour while the target hasn't been reached yet.
  final Color color;

  /// Arc/text colour once [progress] reaches 1.0 — the "done" signal,
  /// matching `_WeeklyGoalProgress`'s own accent switch on Today.
  final Color doneColor;

  final double size;
  final double strokeWidth;

  /// [progress] clamped to what the arc actually draws, so a 150% target
  /// still renders as a full ring rather than overshooting it.
  double get cappedProgress => progress.clamp(0.0, 1.0);

  /// Whether the target has been met or exceeded.
  bool get isDone => progress >= 1.0;

  /// The colour actually used for the arc and the percentage text.
  Color get ringColor => isDone ? doneColor : color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // "Swim: 1.2 / 2.0 h, 60 %" — one phrase rather than three fragments.
    return Semantics(
      container: true,
      label: '$label: $valueLabel, $percentLabel',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: GaugeRing(
              progress: cappedProgress,
              color: ringColor,
              size: size,
              strokeWidth: strokeWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null || isDone)
                    Icon(
                      isDone ? Icons.check_rounded : icon,
                      key: ValueKey(isDone ? 'ring-done' : 'ring-icon'),
                      size: 15,
                      color: ringColor,
                    ),
                  Text(
                    percentLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: ringColor,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            valueLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
