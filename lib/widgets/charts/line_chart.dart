import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'chart_viewport.dart';

/// One line on a [MetricLineChart]. `null` entries are gaps — a day with no
/// wellness record is not a zero, and joining across it would draw a slope
/// that never happened.
class ChartSeries {
  const ChartSeries({
    required this.label,
    required this.color,
    required this.values,
    this.fill = false,
    this.strokeWidth = 2.2,
    this.opacity = 1,
    this.markExtremes = false,
    this.average = true,
  });

  final String label;
  final Color color;
  final List<double?> values;

  /// Shade the area under the line — for the one series that carries the
  /// chart (CTL under ATL, say).
  final bool fill;

  /// Line width; thin and translucent for a raw series under its rolling
  /// average.
  final double strokeWidth;
  final double opacity;

  /// Mark the lowest and highest point in view with labelled dots.
  final bool markExtremes;

  /// Whether this series gets a dashed average line (when the chart shows
  /// averages at all).
  final bool average;
}

/// A horizontal band across a [MetricLineChart], e.g. mean ± one standard
/// deviation.
class ChartBand {
  const ChartBand({required this.low, required this.high, required this.color});

  final double low;
  final double high;
  final Color color;
}

/// An interactive multi-series line chart, painted by hand for the same
/// reason [SimpleBarChart] is.
///
/// Pinch (or double tap, or Ctrl + wheel) zooms into the x-axis and the
/// y-scale refits to what is on screen; one finger scrubs a tooltip, or pans
/// once zoomed. Each series gets a dashed average line over the visible
/// window, and curves are smoothed monotonically so they never overshoot.
///
/// All series share one y-scale, so they must be commensurable (CTL/ATL/TSB
/// are; CTL and heart rate are not — give those separate charts).
class MetricLineChart extends StatefulWidget {
  const MetricLineChart({
    super.key,
    required this.series,
    required this.labels,
    this.selectedIndex,
    this.onSelect,
    this.labelEvery = 7,
    this.zeroLine = false,
    this.showAverage = true,
    this.smooth = true,
    this.zoomable = true,
    this.formatValue,
    this.viewport,
    this.band,
  });

  /// Share the zoom window with other charts so they pan and zoom together;
  /// the chart keeps its own when null.
  final ChartViewport? viewport;

  /// A shaded band behind the lines.
  final ChartBand? band;

  final List<ChartSeries> series;

  /// One x-axis label per data point; only every [labelEvery]-th is drawn
  /// (more as you zoom in).
  final List<String> labels;

  /// Externally controlled selection; when null the chart keeps its own.
  final int? selectedIndex;
  final ValueChanged<int>? onSelect;
  final int labelEvery;

  /// Draw a rule at y = 0 — meaningful for TSB and ramp rate, which cross it.
  final bool zeroLine;

  /// Dashed average line per series, over the visible window.
  final bool showAverage;
  final bool smooth;
  final bool zoomable;

  /// Formats axis, average and tooltip values.
  final String Function(double value)? formatValue;

  @override
  State<MetricLineChart> createState() => _MetricLineChartState();
}

class _MetricLineChartState extends State<MetricLineChart> {
  final _ownViewport = ChartViewport();
  int? _selected;

  ChartViewport get _viewport => widget.viewport ?? _ownViewport;

  int get _length => widget.series.fold(
    0,
    (max, s) => s.values.length > max ? s.values.length : max,
  );

  @override
  void initState() {
    super.initState();
    _viewport.setLength(_length);
  }

  @override
  void didUpdateWidget(MetricLineChart old) {
    super.didUpdateWidget(old);
    _viewport.setLength(_length);
  }

  @override
  void dispose() {
    _ownViewport.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ChartInteraction(
      viewport: _viewport,
      plotLeft: _LineChartPainter.axisWidth,
      zoomable: widget.zoomable,
      onSelectAt: (index) {
        setState(() => _selected = index);
        widget.onSelect?.call(index);
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          ListenableBuilder(
            listenable: _viewport,
            builder: (context, _) => CustomPaint(
              painter: _LineChartPainter(
                series: widget.series,
                labels: widget.labels,
                selected: widget.selectedIndex ?? _selected,
                labelEvery: widget.labelEvery,
                zeroLine: widget.zeroLine,
                showAverage: widget.showAverage,
                smooth: widget.smooth,
                lo: _viewport.lo,
                hi: _viewport.hi,
                zoomed: _viewport.isZoomed,
                band: widget.band,
                format: widget.formatValue ?? _LineChartPainter.formatAxis,
                gridColor: colorScheme.outlineVariant,
                selectionColor: colorScheme.onSurfaceVariant,
                bubbleColor: colorScheme.surfaceContainerHighest,
                bubbleBorder: colorScheme.outlineVariant,
                textColor: colorScheme.onSurface,
                surface: colorScheme.surface,
                labelStyle: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          if (widget.zoomable)
            Positioned(
              top: 0,
              right: 0,
              child: ZoomResetButton(viewport: _viewport),
            ),
        ],
      ),
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
    required this.showAverage,
    required this.smooth,
    required this.lo,
    required this.hi,
    required this.zoomed,
    this.band,
    required this.format,
    required this.gridColor,
    required this.selectionColor,
    required this.bubbleColor,
    required this.bubbleBorder,
    required this.textColor,
    required this.surface,
    required this.labelStyle,
  });

  final List<ChartSeries> series;
  final List<String> labels;
  final int? selected;
  final int labelEvery;
  final bool zeroLine;
  final bool showAverage;
  final bool smooth;
  final double lo;
  final double hi;
  final bool zoomed;
  final ChartBand? band;
  final String Function(double) format;
  final Color gridColor;
  final Color selectionColor;
  final Color bubbleColor;
  final Color bubbleBorder;
  final Color textColor;
  final Color surface;
  final TextStyle labelStyle;

  static const _labelHeight = 16.0;
  static const axisWidth = 34.0;
  static const _topPad = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final length = series.fold<int>(
      0,
      (max, s) => s.values.length > max ? s.values.length : max,
    );
    if (length == 0) return;

    final iLo = lo.floor().clamp(0, length - 1);
    final iHi = hi.ceil().clamp(0, length - 1);

    var min = double.infinity;
    var max = -double.infinity;
    for (final s in series) {
      for (var i = iLo; i <= iHi && i < s.values.length; i++) {
        final value = s.values[i];
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
    final padding = (max - min) * 0.1;
    min -= padding;
    max += padding;

    final plotBottom = size.height - _labelHeight;
    final plotHeight = plotBottom - _topPad;
    final plotWidth = size.width - axisWidth;
    final span = hi - lo;
    double x(num i) => span < 1e-9
        ? axisWidth + plotWidth / 2
        : axisWidth + (i - lo) / span * plotWidth;
    double y(double value) =>
        _topPad + plotHeight - ((value - min) / (max - min)) * plotHeight;

    // Gridlines with their values on the left.
    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    const gridSteps = 4;
    for (var i = 0; i <= gridSteps; i++) {
      final value = max - (max - min) * i / gridSteps;
      final lineY = y(value);
      canvas.drawLine(
        Offset(axisWidth, lineY),
        Offset(size.width, lineY),
        gridPaint,
      );
      _text(canvas, format(value), Offset(0, lineY - 6), labelStyle);
    }

    canvas.save();
    canvas.clipRect(
      Rect.fromLTRB(axisWidth - 1, 0, size.width, plotBottom + 1),
    );

    if (zeroLine && min < 0 && max > 0) {
      canvas.drawLine(
        Offset(axisWidth, y(0)),
        Offset(size.width, y(0)),
        Paint()
          ..color = gridColor
          ..strokeWidth = 1.5,
      );
    }

    final b = band;
    if (b != null) {
      final top = y(math.max(b.low, b.high)).clamp(_topPad, plotBottom);
      final bottom = y(math.min(b.low, b.high)).clamp(_topPad, plotBottom);
      canvas.drawRect(
        Rect.fromLTRB(axisWidth, top.toDouble(), size.width, bottom.toDouble()),
        Paint()..color = b.color.withValues(alpha: 0.12),
      );
    }

    for (final s in series) {
      // Contiguous runs of known values; a gap ends a run.
      final runs = <List<Offset>>[];
      var current = <Offset>[];
      final from = math.max(0, iLo - 1);
      final to = math.min(s.values.length - 1, iHi + 1);
      for (var i = from; i <= to; i++) {
        final value = s.values[i];
        if (value == null) {
          if (current.isNotEmpty) runs.add(current);
          current = [];
          continue;
        }
        current.add(Offset(x(i), y(value)));
      }
      if (current.isNotEmpty) runs.add(current);

      final line = Path();
      for (final run in runs) {
        _addRun(line, run);
      }

      if (s.fill) {
        final fill = Path();
        for (final run in runs) {
          if (run.length < 2) continue;
          final one = Path();
          _addRun(one, run);
          one
            ..lineTo(run.last.dx, plotBottom)
            ..lineTo(run.first.dx, plotBottom)
            ..close();
          fill.addPath(one, Offset.zero);
        }
        canvas.drawPath(
          fill,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                s.color.withValues(alpha: 0.32),
                s.color.withValues(alpha: 0.02),
              ],
            ).createShader(Rect.fromLTWH(0, _topPad, size.width, plotHeight)),
        );
      }

      // Soft glow under the stroke, then the line itself.
      if (s.opacity >= 1) {
        canvas.drawPath(
          line,
          Paint()
            ..color = s.color.withValues(alpha: 0.14)
            ..strokeWidth = s.strokeWidth + 3.8
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..style = PaintingStyle.stroke,
        );
      }
      canvas.drawPath(
        line,
        Paint()
          ..color = s.color.withValues(alpha: s.opacity)
          ..strokeWidth = s.strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke,
      );

      // Individual points once zoomed far enough to tell them apart.
      if (s.opacity >= 1 && plotWidth / math.max(1, span) > 14) {
        for (final run in runs) {
          for (final p in run) {
            canvas.drawCircle(p, 2.5, Paint()..color = s.color);
          }
        }
      }
    }

    if (showAverage) {
      final used = <double>[];
      for (final s in series.where((s) => s.average)) {
        var sum = 0.0;
        var n = 0;
        for (var i = iLo; i <= iHi && i < s.values.length; i++) {
          final v = s.values[i];
          if (v == null) continue;
          sum += v;
          n++;
        }
        if (n < 2) continue;
        final avg = sum / n;
        final lineY = y(avg);
        drawDashedLine(
          canvas,
          Offset(axisWidth, lineY),
          Offset(size.width, lineY),
          Paint()
            ..color = s.color.withValues(alpha: 0.75)
            ..strokeWidth = 1.2,
        );
        // Stagger labels that would sit on top of each other.
        var labelY = lineY - 13;
        while (used.any((u) => (u - labelY).abs() < 12)) {
          labelY += 12;
        }
        used.add(labelY);
        final painter = _textPainter(
          'Ø ${format(avg)}',
          labelStyle.copyWith(color: s.color, fontWeight: FontWeight.w700),
        );
        final rect = Rect.fromLTWH(
          size.width - painter.width - 8,
          labelY,
          painter.width + 6,
          painter.height + 1,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          Paint()..color = surface.withValues(alpha: 0.8),
        );
        painter.paint(canvas, rect.topLeft + const Offset(3, 0.5));
      }
    }

    for (final s in series.where((s) => s.markExtremes)) {
      int? lowI, highI;
      for (var i = iLo; i <= iHi && i < s.values.length; i++) {
        final v = s.values[i];
        if (v == null) continue;
        if (lowI == null || v < s.values[lowI]!) lowI = i;
        if (highI == null || v > s.values[highI]!) highI = i;
      }
      if (lowI == null || highI == null || lowI == highI) continue;
      for (final (i, above) in [(highI, true), (lowI, false)]) {
        final v = s.values[i]!;
        final p = Offset(x(i), y(v));
        canvas.drawCircle(p, 4, Paint()..color = surface);
        canvas.drawCircle(p, 3, Paint()..color = s.color);
        final tp = _textPainter(
          format(v),
          labelStyle.copyWith(color: s.color, fontWeight: FontWeight.w700),
        );
        tp.paint(
          canvas,
          Offset(
            (p.dx - tp.width / 2)
                .clamp(axisWidth, size.width - tp.width)
                .toDouble(),
            above ? math.max(0.0, p.dy - tp.height - 5) : p.dy + 5,
          ),
        );
      }
    }

    canvas.restore();

    final selectedIndex = selected;
    if (selectedIndex != null &&
        selectedIndex < length &&
        selectedIndex >= lo - 1e-9 &&
        selectedIndex <= hi + 1e-9) {
      final selectionX = x(selectedIndex);
      canvas.drawLine(
        Offset(selectionX, _topPad),
        Offset(selectionX, plotBottom),
        Paint()
          ..color = selectionColor.withValues(alpha: 0.45)
          ..strokeWidth = 1,
      );
      for (final s in series) {
        if (selectedIndex >= s.values.length) continue;
        final value = s.values[selectedIndex];
        if (value == null) continue;
        canvas.drawCircle(
          Offset(selectionX, y(value)),
          5,
          Paint()..color = surface,
        );
        canvas.drawCircle(
          Offset(selectionX, y(value)),
          3.5,
          Paint()..color = s.color,
        );
      }
      _bubble(canvas, size, selectionX, selectedIndex);
    }

    // X labels: the configured density, thinned out to fit when zoomed in.
    final visibleCount = (hi - lo) + 1;
    final fit = math.max(
      1,
      (visibleCount / math.max(1, plotWidth / 64)).ceil(),
    );
    final every = zoomed ? fit : labelEvery;
    for (var i = iLo; i <= iHi && i < labels.length; i++) {
      if (i % every != 0 && !(i == length - 1 && !zoomed)) continue;
      final painter = _textPainter(labels[i], labelStyle);
      painter.paint(
        canvas,
        Offset(
          (x(i) - painter.width / 2).clamp(
            axisWidth,
            size.width - painter.width,
          ),
          size.height - _labelHeight + 2,
        ),
      );
    }
  }

  /// A tooltip card: the point's label, then one coloured row per series.
  void _bubble(Canvas canvas, Size size, double selectionX, int index) {
    final spans = <InlineSpan>[
      if (index < labels.length)
        TextSpan(
          text: labels[index],
          style: labelStyle.copyWith(
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
    ];
    for (final s in series) {
      if (index >= s.values.length || s.values[index] == null) continue;
      if (spans.isNotEmpty) spans.add(const TextSpan(text: '\n'));
      spans
        ..add(
          TextSpan(
            text: '● ',
            style: labelStyle.copyWith(color: s.color),
          ),
        )
        ..add(
          TextSpan(
            text: '${s.label}  ${format(s.values[index]!)}',
            style: labelStyle.copyWith(color: textColor),
          ),
        );
    }
    if (spans.isEmpty) return;
    final painter = TextPainter(
      text: TextSpan(children: spans, style: labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    const pad = 8.0;
    final w = painter.width + pad * 2;
    final h = painter.height + pad * 2 - 2;
    var left = selectionX + 10;
    if (left + w > size.width) left = selectionX - 10 - w;
    left = left.clamp(axisWidth, math.max(axisWidth, size.width - w));
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, _topPad + 2, w, h),
      const Radius.circular(8),
    );
    canvas.drawShadow(Path()..addRRect(rect), Colors.black, 3, false);
    canvas.drawRRect(rect, Paint()..color = bubbleColor);
    canvas.drawRRect(
      rect,
      Paint()
        ..color = bubbleBorder
        ..style = PaintingStyle.stroke,
    );
    painter.paint(canvas, Offset(left + pad, _topPad + 2 + pad - 1));
  }

  /// Adds [points] to [path] as a polyline, or — when [smooth] — as a
  /// monotone cubic (Fritsch–Carlson): smooth, but it can't overshoot the
  /// data, so a curve never dips below a value that was never measured.
  void _addRun(Path path, List<Offset> points) {
    if (points.isEmpty) return;
    path.moveTo(points.first.dx, points.first.dy);
    if (points.length == 1) return;
    if (!smooth || points.length == 2) {
      for (final p in points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      return;
    }
    final n = points.length;
    final dx = [
      for (var i = 0; i < n - 1; i++) points[i + 1].dx - points[i].dx,
    ];
    final slope = [
      for (var i = 0; i < n - 1; i++)
        dx[i].abs() < 1e-9 ? 0.0 : (points[i + 1].dy - points[i].dy) / dx[i],
    ];
    final m = List<double>.filled(n, 0);
    m[0] = slope.first;
    m[n - 1] = slope.last;
    for (var i = 1; i < n - 1; i++) {
      m[i] = slope[i - 1] * slope[i] <= 0 ? 0 : (slope[i - 1] + slope[i]) / 2;
    }
    for (var i = 0; i < n - 1; i++) {
      if (slope[i].abs() < 1e-12) {
        m[i] = 0;
        m[i + 1] = 0;
        continue;
      }
      final a = m[i] / slope[i];
      final b = m[i + 1] / slope[i];
      final h = math.sqrt(a * a + b * b);
      if (h > 3) {
        m[i] = 3 * a / h * slope[i];
        m[i + 1] = 3 * b / h * slope[i];
      }
    }
    for (var i = 0; i < n - 1; i++) {
      final d = dx[i] / 3;
      path.cubicTo(
        points[i].dx + d,
        points[i].dy + m[i] * d,
        points[i + 1].dx - d,
        points[i + 1].dy - m[i + 1] * d,
        points[i + 1].dx,
        points[i + 1].dy,
      );
    }
  }

  static String formatAxis(double value) =>
      value.abs() >= 100 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);

  void _text(Canvas canvas, String text, Offset offset, TextStyle style) =>
      _textPainter(text, style).paint(canvas, offset);

  TextPainter _textPainter(String text, TextStyle style) => TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout();

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) => true;
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
