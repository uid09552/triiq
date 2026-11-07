import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A round gauge: a fine tick scale around the edge that lights up as the
/// value grows, inside it a soft gradient arc with a glow and a round knob at
/// its tip, and [child] in the middle for the figure and an indicator.
///
/// Shared by the weekly-target rings and the readiness score so the app has
/// one look for "how far along am I" — painted by hand, like its charts, with
/// no package. The value animates when it changes.
class GaugeRing extends StatelessWidget {
  const GaugeRing({
    super.key,
    required this.progress,
    required this.color,
    required this.size,
    this.strokeWidth = 7,
    this.child,
    this.dim = false,
    this.animate = true,
  });

  /// 0..1; anything outside is clamped (a 150 % target is a full ring).
  final double progress;
  final Color color;
  final double size;
  final double strokeWidth;

  /// Content centred inside the ring.
  final Widget? child;

  /// A muted ring for "no data yet".
  final bool dim;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final target = progress.clamp(0.0, 1.0);

    Widget paint(double value) => CustomPaint(
      size: Size.square(size),
      painter: GaugePainter(
        progress: value,
        color: dim ? scheme.outline : color,
        track: scheme.outlineVariant,
        bezel: scheme.outlineVariant,
        knob: scheme.surface,
        strokeWidth: strokeWidth,
      ),
      child: Center(child: child),
    );

    return SizedBox(
      width: size,
      height: size,
      child: animate
          ? TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: target),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => paint(value),
            )
          : paint(target),
    );
  }
}

/// Paints [GaugeRing]; public so a test can read what was drawn.
class GaugePainter extends CustomPainter {
  GaugePainter({
    required this.progress,
    required this.color,
    required this.track,
    required this.bezel,
    required this.knob,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color track;
  final Color bezel;
  final Color knob;
  final double strokeWidth;

  static const _start = -math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outer = math.min(size.width, size.height) / 2;

    // A hairline bezel just inside the edge.
    canvas.drawCircle(
      center,
      outer - 0.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = bezel.withValues(alpha: 0.45),
    );

    final arcRadius = outer - strokeWidth / 2 - 3.5;
    final rect = Rect.fromCircle(center: center, radius: arcRadius);

    // The arc's track: quiet, so the value is what you see.
    canvas.drawCircle(
      center,
      arcRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = track.withValues(alpha: 0.35),
    );

    // Tick scale inside the arc; the ticks up to the value light up.
    final ticks = outer < 40 ? 36 : 48;
    final tickOuter = arcRadius - strokeWidth / 2 - 2.5;
    final tickLen = math.max(2.0, outer * 0.06);
    final lit = (progress * ticks).floor();
    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.4;
    for (var i = 0; i < ticks; i++) {
      final a = _start + 2 * math.pi * i / ticks;
      final dir = Offset(math.cos(a), math.sin(a));
      tickPaint.color = i < lit
          ? color.withValues(alpha: 0.85)
          : track.withValues(alpha: 0.55);
      canvas.drawLine(
        center + dir * tickOuter,
        center + dir * (tickOuter - tickLen),
        tickPaint,
      );
    }

    if (progress <= 0) return;
    final sweep = 2 * math.pi * progress;

    // Glow under the arc.
    canvas.drawArc(
      rect,
      _start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 2
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // The arc itself: fades in from the start, full colour at the tip.
    // A full ring is one solid colour so the seam doesn't show.
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    if (progress >= 0.995) {
      arc.color = color;
    } else {
      arc.shader = SweepGradient(
        startAngle: 0,
        endAngle: sweep,
        colors: [color.withValues(alpha: 0.5), color],
        transform: const GradientRotation(_start),
      ).createShader(rect);
    }
    canvas.drawArc(rect, _start, sweep, false, arc);

    // A round knob at the tip, ringed in the value's colour.
    if (progress < 0.995) {
      final tip =
          center +
          Offset(math.cos(_start + sweep), math.sin(_start + sweep)) *
              arcRadius;
      canvas.drawCircle(tip, strokeWidth * 0.32 + 0.6, Paint()..color = knob);
      canvas.drawCircle(
        tip,
        strokeWidth * 0.32 + 0.6,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(GaugePainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.track != track ||
      old.bezel != bezel ||
      old.knob != knob ||
      old.strokeWidth != strokeWidth;
}
