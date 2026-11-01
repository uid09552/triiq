import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../evaluation/performance_curves.dart';

/// One period's curve on a [DurationCurveChart].
class CurveSeries {
  const CurveSeries({
    required this.label,
    required this.color,
    required this.points,
  });

  final String label;
  final Color color;

  /// Sorted by x. Drawn as is — downsample before handing them over.
  final List<CurvePoint> points;
}

/// Best efforts against duration (or distance), on a log x-axis so 5 s and
/// 2 h both get room. Painted by hand like the other charts.
///
/// The y-value of a point is [plotValue] — watts and bpm as they are, pace
/// as speed so faster sits higher; [formatY] turns it back into the unit on
/// the axis (a pace string for pace).
class DurationCurveChart extends StatelessWidget {
  const DurationCurveChart({
    super.key,
    required this.series,
    required this.metric,
    required this.ticks,
    required this.formatX,
    required this.formatY,
    required this.xTitle,
    required this.yTitle,
    this.selectedX,
    this.onSelect,
  });

  final List<CurveSeries> series;
  final CurveMetric metric;

  /// x-values (seconds or metres) that get a label, where in range.
  final List<double> ticks;
  final String Function(double x) formatX;
  final String Function(double y) formatY;
  final String xTitle;
  final String yTitle;

  /// The x-value the readout is on, if any.
  final double? selectedX;

  /// Called with the x of the nearest point under a tap or drag.
  final ValueChanged<double>? onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final labelStyle = theme.textTheme.labelSmall!.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = _CurvePainter(
          series: series,
          metric: metric,
          ticks: ticks,
          formatX: formatX,
          formatY: formatY,
          xTitle: xTitle,
          yTitle: yTitle,
          selectedX: selectedX,
          gridColor: colorScheme.outlineVariant.withValues(alpha: 0.5),
          selectionColor: colorScheme.onSurface,
          labelStyle: labelStyle,
        );
        void select(Offset position) {
          final x = painter.nearestX(position.dx, constraints.biggest);
          if (x != null) onSelect?.call(x);
        }

        return Semantics(
          label: '$yTitle / $xTitle',
          child: GestureDetector(
            onTapDown: onSelect == null ? null : (d) => select(d.localPosition),
            onHorizontalDragUpdate: onSelect == null
                ? null
                : (d) => select(d.localPosition),
            child: CustomPaint(size: constraints.biggest, painter: painter),
          ),
        );
      },
    );
  }
}

class _CurvePainter extends CustomPainter {
  _CurvePainter({
    required this.series,
    required this.metric,
    required this.ticks,
    required this.formatX,
    required this.formatY,
    required this.xTitle,
    required this.yTitle,
    required this.selectedX,
    required this.gridColor,
    required this.selectionColor,
    required this.labelStyle,
  }) {
    for (final s in series) {
      for (final p in s.points) {
        final y = plotValue(metric, p);
        _minX = math.min(_minX, p.x);
        _maxX = math.max(_maxX, p.x);
        _minY = math.min(_minY, y);
        _maxY = math.max(_maxY, y);
      }
    }
    if (_minY.isFinite) {
      if ((_maxY - _minY).abs() < 1e-9) {
        _minY -= 1;
        _maxY += 1;
      }
      final padding = (_maxY - _minY) * 0.08;
      _minY -= padding;
      _maxY += padding;
    }
  }

  final List<CurveSeries> series;
  final CurveMetric metric;
  final List<double> ticks;
  final String Function(double x) formatX;
  final String Function(double y) formatY;
  final String xTitle;
  final String yTitle;
  final double? selectedX;
  final Color gridColor;
  final Color selectionColor;
  final TextStyle labelStyle;

  double _minX = double.infinity;
  double _maxX = -double.infinity;
  double _minY = double.infinity;
  double _maxY = -double.infinity;

  static const _axisWidth = 46.0;
  static const _yTitleWidth = 14.0;
  static const _labelHeight = 16.0;
  static const _xTitleHeight = 14.0;

  bool get _hasData => _minX.isFinite && _maxX > 0;

  Rect _plot(Size size) => Rect.fromLTRB(
    _yTitleWidth + _axisWidth,
    4,
    size.width - 4,
    size.height - _labelHeight - _xTitleHeight,
  );

  double _x(double value, Rect plot) {
    final lo = math.log(_minX);
    final hi = math.log(_maxX);
    if (hi - lo < 1e-9) return plot.center.dx;
    return plot.left + (math.log(value) - lo) / (hi - lo) * plot.width;
  }

  double _y(double value, Rect plot) =>
      plot.bottom - (value - _minY) / (_maxY - _minY) * plot.height;

  /// The x of the point nearest to [dx] on screen, across all series.
  double? nearestX(double dx, Size size) {
    if (!_hasData) return null;
    final plot = _plot(size);
    double? best;
    var bestGap = double.infinity;
    for (final s in series) {
      for (final p in s.points) {
        final gap = (_x(p.x, plot) - dx).abs();
        if (gap < bestGap) {
          bestGap = gap;
          best = p.x;
        }
      }
    }
    return best;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (!_hasData) return;
    final plot = _plot(size);
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    // Horizontal gridlines with their values.
    for (var i = 0; i <= 3; i++) {
      final value = _maxY - (_maxY - _minY) * i / 3;
      final y = _y(value, plot);
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);
      final painter = _textPainter(formatY(value));
      painter.paint(
        canvas,
        Offset(plot.left - painter.width - 4, y - painter.height / 2),
      );
    }

    // Vertical ticks at the fixed durations/distances that fall in range.
    for (final tick in ticks) {
      if (tick < _minX * 0.98 || tick > _maxX * 1.02) continue;
      final x = _x(tick, plot);
      canvas.drawLine(Offset(x, plot.top), Offset(x, plot.bottom), gridPaint);
      final painter = _textPainter(formatX(tick));
      painter.paint(
        canvas,
        Offset(
          (x - painter.width / 2).clamp(plot.left, size.width - painter.width),
          plot.bottom + 2,
        ),
      );
    }

    // Axis titles: x centred underneath, y rotated on the left.
    final xTitlePainter = _textPainter(xTitle);
    xTitlePainter.paint(
      canvas,
      Offset(
        plot.center.dx - xTitlePainter.width / 2,
        size.height - _xTitleHeight,
      ),
    );
    final yTitlePainter = _textPainter(yTitle);
    canvas
      ..save()
      ..translate(0, plot.center.dy + yTitlePainter.width / 2)
      ..rotate(-math.pi / 2);
    yTitlePainter.paint(canvas, Offset.zero);
    canvas.restore();

    for (final s in series) {
      if (s.points.isEmpty) continue;
      final path = Path();
      for (var i = 0; i < s.points.length; i++) {
        final p = s.points[i];
        final offset = Offset(_x(p.x, plot), _y(plotValue(metric, p), plot));
        i == 0
            ? path.moveTo(offset.dx, offset.dy)
            : path.lineTo(offset.dx, offset.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = s.color
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke,
      );
    }

    final selected = selectedX;
    if (selected != null && selected > 0) {
      final x = _x(selected, plot);
      canvas.drawLine(
        Offset(x, plot.top),
        Offset(x, plot.bottom),
        Paint()
          ..color = selectionColor.withValues(alpha: 0.4)
          ..strokeWidth = 1,
      );
      for (final s in series) {
        final point = _nearest(s.points, selected);
        if (point == null) continue;
        canvas.drawCircle(
          Offset(_x(point.x, plot), _y(plotValue(metric, point), plot)),
          3.5,
          Paint()..color = s.color,
        );
      }
    }
  }

  static CurvePoint? _nearest(List<CurvePoint> points, double x) {
    CurvePoint? best;
    var bestGap = double.infinity;
    for (final p in points) {
      final gap = (math.log(p.x) - math.log(x)).abs();
      if (gap < bestGap) {
        bestGap = gap;
        best = p;
      }
    }
    // Only mark a series that actually reaches this far.
    return bestGap < 0.05 ? best : null;
  }

  TextPainter _textPainter(String text) => TextPainter(
    text: TextSpan(text: text, style: labelStyle),
    textDirection: TextDirection.ltr,
  )..layout();

  @override
  bool shouldRepaint(covariant _CurvePainter oldDelegate) =>
      oldDelegate.series != series ||
      oldDelegate.selectedX != selectedX ||
      oldDelegate.metric != metric;
}

/// Tick positions for [sport] and [metric].
List<double> curveTicks(CurveSport sport, CurveMetric metric) {
  if (!metric.byDistance) return const [5, 30, 60, 300, 1200, 3600, 7200];
  if (sport == CurveSport.swim) return const [50, 100, 200, 400, 800, 1500];
  return const [100, 400, 1000, 5000, 10000, 21097.5, 42195];
}
