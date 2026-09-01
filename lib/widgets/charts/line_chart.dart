import 'package:flutter/material.dart';

/// One line on a [MetricLineChart]. `null` entries are gaps — a day with no
/// wellness record is not a zero, and joining across it would draw a slope
/// that never happened.
class ChartSeries {
  const ChartSeries({
    required this.label,
    required this.color,
    required this.values,
    this.fill = false,
  });

  final String label;
  final Color color;
  final List<double?> values;

  /// Shade the area under the line — for the one series that carries the
  /// chart (CTL under ATL, say).
  final bool fill;
}

/// A tappable multi-series line chart, painted by hand for the same reason
/// [SimpleBarChart] is.
///
/// All series share one y-scale, so they must be commensurable (CTL/ATL/TSB
/// are; CTL and heart rate are not — give those separate charts).
class MetricLineChart extends StatelessWidget {
  const MetricLineChart({
    super.key,
    required this.series,
    required this.labels,
    this.selectedIndex,
    this.onSelect,
    this.labelEvery = 7,
    this.zeroLine = false,
  });

  final List<ChartSeries> series;

  /// One x-axis label per data point; only every [labelEvery]-th is drawn.
  final List<String> labels;

  final int? selectedIndex;
  final ValueChanged<int>? onSelect;
  final int labelEvery;

  /// Draw a rule at y = 0 — meaningful for TSB and ramp rate, which cross it.
  final bool zeroLine;

  int get _length =>
      series.fold(0, (max, s) => s.values.length > max ? s.values.length : max);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final length = _length;

    return LayoutBuilder(
      builder: (context, constraints) {
        void handleTap(Offset position) {
          if (length == 0 || onSelect == null) return;
          final step = constraints.maxWidth / length;
          onSelect!((position.dx / step).floor().clamp(0, length - 1));
        }

        return GestureDetector(
          onTapDown: (details) => handleTap(details.localPosition),
          onHorizontalDragUpdate: (details) =>
              handleTap(details.localPosition),
          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _LineChartPainter(
              series: series,
              labels: labels,
              selected: selectedIndex,
              labelEvery: labelEvery,
              zeroLine: zeroLine,
              gridColor: colorScheme.outlineVariant,
              selectionColor: colorScheme.onSurfaceVariant,
              labelStyle: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.series,
    required this.labels,
    required this.selected,
    required this.labelEvery,
    required this.zeroLine,
    required this.gridColor,
    required this.selectionColor,
    required this.labelStyle,
  });

  final List<ChartSeries> series;
  final List<String> labels;
  final int? selected;
  final int labelEvery;
  final bool zeroLine;
  final Color gridColor;
  final Color selectionColor;
  final TextStyle labelStyle;

  static const _labelHeight = 16.0;
  static const _axisWidth = 34.0;

  @override
  void paint(Canvas canvas, Size size) {
    final length = series.fold<int>(
      0,
      (max, s) => s.values.length > max ? s.values.length : max,
    );
    if (length == 0) return;

    var min = double.infinity;
    var max = -double.infinity;
    for (final s in series) {
      for (final value in s.values) {
        if (value == null) continue;
        if (value < min) min = value;
        if (value > max) max = value;
      }
    }
    if (min == double.infinity) return;
    if (zeroLine) {
      if (min > 0) min = 0;
      if (max < 0) max = 0;
    }
    if ((max - min).abs() < 1e-9) {
      // A flat line would divide by zero; give it a little room either side.
      min -= 1;
      max += 1;
    }
    // Breathing room so the extremes don't sit on the frame.
    final padding = (max - min) * 0.08;
    min -= padding;
    max += padding;

    final chartWidth = size.width - _axisWidth;
    final chartHeight = size.height - _labelHeight;
    double x(int i) => _axisWidth + (length == 1 ? chartWidth / 2 : chartWidth * i / (length - 1));
    double y(double value) =>
        chartHeight - ((value - min) / (max - min)) * chartHeight;

    // Gridlines with their values on the left.
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i <= 2; i++) {
      final value = max - (max - min) * i / 2;
      final lineY = y(value);
      canvas.drawLine(
        Offset(_axisWidth, lineY),
        Offset(size.width, lineY),
        gridPaint,
      );
      _text(canvas, _formatAxis(value), Offset(0, lineY - 6), labelStyle);
    }

    if (zeroLine && min < 0 && max > 0) {
      canvas.drawLine(
        Offset(_axisWidth, y(0)),
        Offset(size.width, y(0)),
        Paint()
          ..color = gridColor
          ..strokeWidth = 1.5,
      );
    }

    for (final s in series) {
      final path = Path();
      final fillPath = Path();
      var started = false;
      for (var i = 0; i < s.values.length; i++) {
        final value = s.values[i];
        if (value == null) {
          started = false;
          continue;
        }
        final point = Offset(x(i), y(value));
        if (!started) {
          path.moveTo(point.dx, point.dy);
          fillPath
            ..moveTo(point.dx, chartHeight)
            ..lineTo(point.dx, point.dy);
          started = true;
        } else {
          path.lineTo(point.dx, point.dy);
          fillPath.lineTo(point.dx, point.dy);
        }
        if (i == s.values.length - 1) {
          fillPath.lineTo(point.dx, chartHeight);
        }
      }

      if (s.fill) {
        canvas.drawPath(
          fillPath..close(),
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                s.color.withValues(alpha: 0.28),
                s.color.withValues(alpha: 0.02),
              ],
            ).createShader(Rect.fromLTWH(0, 0, size.width, chartHeight)),
        );
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

    final selectedIndex = selected;
    if (selectedIndex != null && selectedIndex < length) {
      final selectionX = x(selectedIndex);
      canvas.drawLine(
        Offset(selectionX, 0),
        Offset(selectionX, chartHeight),
        Paint()
          ..color = selectionColor.withValues(alpha: 0.4)
          ..strokeWidth = 1,
      );
      for (final s in series) {
        if (selectedIndex >= s.values.length) continue;
        final value = s.values[selectedIndex];
        if (value == null) continue;
        canvas.drawCircle(
          Offset(selectionX, y(value)),
          3.5,
          Paint()..color = s.color,
        );
      }
    }

    for (var i = 0; i < labels.length && i < length; i++) {
      if (i % labelEvery != 0 && i != length - 1) continue;
      final painter = _textPainter(labels[i], labelStyle);
      painter.paint(
        canvas,
        Offset(
          (x(i) - painter.width / 2).clamp(
            _axisWidth,
            size.width - painter.width,
          ),
          size.height - _labelHeight + 2,
        ),
      );
    }
  }

  static String _formatAxis(double value) => value.abs() >= 100
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);

  void _text(Canvas canvas, String text, Offset offset, TextStyle style) =>
      _textPainter(text, style).paint(canvas, offset);

  TextPainter _textPainter(String text, TextStyle style) => TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout();

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.series != series ||
      oldDelegate.selected != selected ||
      oldDelegate.labels != labels;
}

/// The colour key under a [MetricLineChart] — a dot and a label per series.
class ChartLegend extends StatelessWidget {
  const ChartLegend({super.key, required this.series});

  final List<ChartSeries> series;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        for (final s in series)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: s.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(s.label, style: theme.textTheme.bodySmall),
            ],
          ),
      ],
    );
  }
}
