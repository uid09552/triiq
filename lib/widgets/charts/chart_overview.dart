import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'chart_theme.dart';
import 'chart_viewport.dart';
import 'line_chart.dart' show chartL10n;

/// The small "context" chart under a zoomable chart, D3 focus + context
/// style: the whole range as a thin line, with the visible window drawn on
/// top of it.
///
/// Drag across it to **brush** a new window (the chart above zooms to it),
/// drag inside the window to move it, tap to centre the window on a point.
/// Horizontal drags only, so a vertical page scroll that starts here still
/// scrolls the page.
class ChartOverview extends StatefulWidget {
  const ChartOverview({
    super.key,
    required this.viewport,
    required this.values,
    this.labels,
    this.color,
    this.height = 34,
  });

  final ChartViewport viewport;

  /// The series to sketch, usually the chart's lead series.
  final List<double?> values;

  /// One label per point, for what a screen reader says about the window.
  final List<String>? labels;
  final Color? color;
  final double height;

  @override
  State<ChartOverview> createState() => _ChartOverviewState();
}

enum _DragMode { brush, move }

class _ChartOverviewState extends State<ChartOverview> {
  _DragMode? _mode;
  double _anchor = 0;

  ChartViewport get _vp => widget.viewport;

  double _indexAt(double dx, double width) =>
      width <= 0 ? 0 : (dx / width).clamp(0.0, 1.0) * _vp.fullSpan;

  void _start(double dx, double width) {
    final i = _indexAt(dx, width);
    if (_vp.isZoomed && i >= _vp.lo && i <= _vp.hi) {
      _mode = _DragMode.move;
      _anchor = i - _vp.lo;
    } else {
      _mode = _DragMode.brush;
      _anchor = i;
    }
  }

  void _update(double dx, double width) {
    final i = _indexAt(dx, width);
    switch (_mode) {
      case _DragMode.move:
        final lo = i - _anchor;
        _vp.setRange(lo, lo + _vp.span);
      case _DragMode.brush:
        if ((i - _anchor).abs() < 1) return;
        _vp.setRange(math.min(i, _anchor), math.max(i, _anchor));
      case null:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final chart = ChartTheme.of(context);
    final l10n = chartL10n(context);
    final labels = widget.labels;
    return ListenableBuilder(
      listenable: _vp,
      builder: (context, _) {
        String? value;
        if (labels != null && labels.isNotEmpty) {
          final lo = _vp.lo.round().clamp(0, labels.length - 1);
          final hi = _vp.hi.round().clamp(0, labels.length - 1);
          value = l10n.a11yChartRange(labels[lo], labels[hi]);
        }
        return Semantics(
          container: true,
          label: l10n.chartOverview,
          value: value,
          child: SizedBox(
            height: widget.height,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return GestureDetector(
                  key: const ValueKey('chart-overview'),
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragStart: (d) =>
                      _start(d.localPosition.dx, width),
                  onHorizontalDragUpdate: (d) =>
                      _update(d.localPosition.dx, width),
                  onHorizontalDragEnd: (_) => _mode = null,
                  onTapUp: (d) {
                    if (_vp.isZoomed) {
                      _vp.centerOn(_indexAt(d.localPosition.dx, width));
                    }
                  },
                  child: CustomPaint(
                    size: Size(width, widget.height),
                    painter: _OverviewPainter(
                      values: widget.values,
                      lo: _vp.lo,
                      hi: _vp.hi,
                      fullSpan: _vp.fullSpan,
                      zoomed: _vp.isZoomed,
                      line: widget.color ?? chart.primary,
                      track: chart.track,
                      brush: chart.brush,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _OverviewPainter extends CustomPainter {
  _OverviewPainter({
    required this.values,
    required this.lo,
    required this.hi,
    required this.fullSpan,
    required this.zoomed,
    required this.line,
    required this.track,
    required this.brush,
  });

  final List<double?> values;
  final double lo;
  final double hi;
  final double fullSpan;
  final bool zoomed;
  final Color line;
  final Color track;
  final Color brush;

  @override
  void paint(Canvas canvas, Size size) {
    final frame = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(6),
    );
    canvas.drawRRect(frame, Paint()..color = track.withValues(alpha: 0.55));

    var min = double.infinity, max = -double.infinity;
    for (final v in values) {
      if (v == null) continue;
      min = math.min(min, v);
      max = math.max(max, v);
    }
    double x(num i) =>
        fullSpan <= 0 ? size.width / 2 : i / fullSpan * size.width;
    if (min != double.infinity) {
      if ((max - min).abs() < 1e-9) {
        min -= 1;
        max += 1;
      }
      const pad = 4.0;
      double y(double v) =>
          pad + (size.height - 2 * pad) * (1 - (v - min) / (max - min));
      final path = Path();
      final area = Path();
      var open = false;
      double? runStart;
      double lastX = 0;
      void closeArea() {
        if (runStart == null) return;
        area
          ..lineTo(lastX, size.height)
          ..lineTo(runStart!, size.height)
          ..close();
        runStart = null;
      }

      for (var i = 0; i < values.length; i++) {
        final v = values[i];
        if (v == null) {
          open = false;
          closeArea();
          continue;
        }
        final p = Offset(x(i), y(v));
        if (open) {
          path.lineTo(p.dx, p.dy);
          area.lineTo(p.dx, p.dy);
        } else {
          path.moveTo(p.dx, p.dy);
          area.moveTo(p.dx, size.height);
          area.lineTo(p.dx, p.dy);
          runStart = p.dx;
          open = true;
        }
        lastX = p.dx;
      }
      closeArea();
      canvas.save();
      canvas.clipRRect(frame);
      canvas.drawPath(area, Paint()..color = line.withValues(alpha: 0.12));
      canvas.drawPath(
        path,
        Paint()
          ..color = line.withValues(alpha: 0.8)
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke,
      );
      canvas.restore();
    }

    if (!zoomed) return;
    final left = x(lo), right = x(hi);
    // Dim what is outside the window, then frame the window itself.
    final dim = Paint()..color = track.withValues(alpha: 0.6);
    canvas.drawRect(Rect.fromLTRB(0, 0, left, size.height), dim);
    canvas.drawRect(Rect.fromLTRB(right, 0, size.width, size.height), dim);
    final window = RRect.fromRectAndRadius(
      Rect.fromLTRB(left, 0, right, size.height),
      const Radius.circular(4),
    );
    canvas.drawRRect(window, Paint()..color = brush.withValues(alpha: 0.12));
    canvas.drawRRect(
      window,
      Paint()
        ..color = brush.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    // Grip handles on both edges.
    final grip = Paint()
      ..color = brush
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (final edge in [left, right]) {
      canvas.drawLine(
        Offset(edge, size.height * 0.3),
        Offset(edge, size.height * 0.7),
        grip,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OverviewPainter old) =>
      old.lo != lo ||
      old.hi != hi ||
      old.values != values ||
      old.line != line ||
      old.track != track ||
      old.zoomed != zoomed;
}
