import 'package:flutter/material.dart';

/// One bar: a value, an optional target drawn behind it, and the label that
/// goes under the axis.
class ChartBar {
  const ChartBar({
    required this.label,
    required this.value,
    this.target,
    this.highlighted = false,
  });

  final String label;
  final double value;

  /// Drawn as a translucent "ghost" bar behind [value] — planned load
  /// against completed load, for instance.
  final double? target;

  /// Marks the bar as the current period (today, this week): a tick under
  /// the axis, so "where am I" doesn't need counting from the right.
  final bool highlighted;
}

/// A tappable vertical bar chart, painted by hand.
///
/// This app deliberately has no charting package (see `_ZoneTimeChart` on
/// the activity detail screen for the same call): the two shapes it needs —
/// bars and lines — are a few dozen lines of [CustomPainter] each, and a
/// package would be a dependency, a theme to fight and a licence to check
/// for something already this small. [MetricLineChart] is the other half.
class SimpleBarChart extends StatelessWidget {
  const SimpleBarChart({
    super.key,
    required this.bars,
    this.selectedIndex,
    this.onSelect,
    this.labelEvery = 1,
    this.barColor,
    this.targetColor,
  });

  final List<ChartBar> bars;
  final int? selectedIndex;
  final ValueChanged<int>? onSelect;

  /// Draw an x-axis label every n-th bar — 42 daily labels don't fit, 6
  /// weekly ones do.
  final int labelEvery;

  final Color? barColor;
  final Color? targetColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        void handleTap(Offset position) {
          if (bars.isEmpty || onSelect == null) return;
          final barWidth = constraints.maxWidth / bars.length;
          onSelect!(
            (position.dx / barWidth).floor().clamp(0, bars.length - 1),
          );
        }

        return GestureDetector(
          onTapDown: (details) => handleTap(details.localPosition),
          onHorizontalDragUpdate: (details) =>
              handleTap(details.localPosition),
          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _BarChartPainter(
              bars: bars,
              selected: selectedIndex,
              barColor: barColor ?? colorScheme.primary,
              selectedBarColor: colorScheme.tertiary,
              targetColor:
                  (targetColor ?? colorScheme.tertiary).withValues(alpha: 0.3),
              tickColor: colorScheme.onSurface,
              labelEvery: labelEvery,
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

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({
    required this.bars,
    required this.selected,
    required this.barColor,
    required this.selectedBarColor,
    required this.targetColor,
    required this.tickColor,
    required this.labelEvery,
    required this.labelStyle,
  });

  final List<ChartBar> bars;
  final int? selected;
  final Color barColor;
  final Color selectedBarColor;
  final Color targetColor;
  final Color tickColor;
  final int labelEvery;
  final TextStyle labelStyle;

  static const _labelHeight = 16.0;
  static const _barGap = 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty) return;
    final chartHeight = size.height - _labelHeight;
    final slotWidth = size.width / bars.length;

    var maxValue = 0.0;
    for (final bar in bars) {
      if (bar.value > maxValue) maxValue = bar.value;
      final target = bar.target;
      if (target != null && target > maxValue) maxValue = target;
    }
    if (maxValue <= 0) maxValue = 1;

    double heightOf(double value) =>
        value <= 0 ? 0 : (value / maxValue) * (chartHeight - 4);

    for (var i = 0; i < bars.length; i++) {
      final bar = bars[i];
      final left = i * slotWidth + _barGap / 2;
      final width = slotWidth - _barGap;

      final target = bar.target;
      if (target != null && target > 0) {
        _drawBar(
          canvas,
          Rect.fromLTWH(
            left,
            chartHeight - heightOf(target),
            width,
            heightOf(target),
          ),
          targetColor,
        );
      }

      // The completed bar sits inside the planned one so both stay readable
      // when they're close in size.
      final valueWidth = target != null ? width * 0.56 : width;
      _drawBar(
        canvas,
        Rect.fromLTWH(
          left + (width - valueWidth) / 2,
          chartHeight - heightOf(bar.value),
          valueWidth,
          heightOf(bar.value),
        ),
        i == selected ? selectedBarColor : barColor,
      );

      if (bar.highlighted) {
        canvas.drawLine(
          Offset(left + width / 2, chartHeight + 2),
          Offset(left + width / 2, chartHeight + 6),
          Paint()
            ..color = tickColor
            ..strokeWidth = 1.5,
        );
      }

      if (i % labelEvery == 0 || i == bars.length - 1) {
        final textPainter = TextPainter(
          text: TextSpan(text: bar.label, style: labelStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          Offset(
            (left + width / 2 - textPainter.width / 2).clamp(
              0,
              size.width - textPainter.width,
            ),
            size.height - _labelHeight + 2,
          ),
        );
      }
    }
  }

  void _drawBar(Canvas canvas, Rect rect, Color color) {
    if (rect.height <= 0) return;
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        rect,
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
      ),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) =>
      oldDelegate.bars != bars ||
      oldDelegate.selected != selected ||
      oldDelegate.barColor != barColor;
}
