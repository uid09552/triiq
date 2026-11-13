import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'chart_theme.dart';
import 'line_chart.dart' show chartL10n;

/// Marker drawn on each vertex, so a series differs by more than colour.
enum RadarMarker { circle, square, triangle, diamond }

/// One polygon of a [RadarChart].
class RadarSeries {
  const RadarSeries({
    required this.label,
    required this.color,
    required this.values,
    this.marker = RadarMarker.circle,
    this.dash,
  });

  final String label;
  final Color color;

  /// One entry per axis, 0..1 of the outer ring; null = no data (a gap,
  /// never drawn as 0). Values above 1 are drawn on the outer ring.
  final List<double?> values;
  final RadarMarker marker;

  /// On/off lengths of the outline dashes; null = solid.
  final List<double>? dash;
}

/// What is selected on the chart: an axis, and optionally one series.
class RadarSelection {
  const RadarSelection(this.axis, [this.series]);
  final int axis;
  final int? series;

  @override
  bool operator ==(Object other) =>
      other is RadarSelection && other.axis == axis && other.series == series;
  @override
  int get hashCode => Object.hash(axis, series);
}

/// A custom-painted spider chart: one spoke per axis, rings at 25/50/75/100 %,
/// one semi-transparent polygon per series. Missing values leave a gap in the
/// outline and the axis is marked "no data" when no visible series has any.
/// Tapping or hovering a vertex (or a spoke) reports a [RadarSelection].
class RadarChart extends StatefulWidget {
  const RadarChart({
    super.key,
    required this.axes,
    required this.series,
    this.hidden = const {},
    this.selection,
    this.onSelect,
    this.semanticsLabel,
    this.size = 280,
  });

  final List<String> axes;
  final List<RadarSeries> series;

  /// Labels of the series not drawn.
  final Set<String> hidden;
  final RadarSelection? selection;
  final ValueChanged<RadarSelection?>? onSelect;
  final String? semanticsLabel;

  /// Height of the drawing; the width follows the available space.
  final double size;

  @override
  State<RadarChart> createState() => _RadarChartState();
}

class _RadarChartState extends State<RadarChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (ChartTheme.of(context).reduceMotion) {
      _anim.value = 1;
    } else {
      _anim.forward();
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  RadarSelection? _hit(Offset p, Size size) {
    final geo = _RadarGeometry(size, widget.axes.length);
    RadarSelection? best;
    var bestDist = 24.0;
    for (var s = 0; s < widget.series.length; s++) {
      final series = widget.series[s];
      if (widget.hidden.contains(series.label)) continue;
      for (var a = 0; a < widget.axes.length; a++) {
        final v = series.values[a];
        if (v == null) continue;
        final d = (geo.point(a, v) - p).distance;
        if (d < bestDist) {
          bestDist = d;
          best = RadarSelection(a, s);
        }
      }
    }
    if (best != null) return best;
    // Otherwise the spoke (or its label) closest in angle.
    final off = p - geo.center;
    if (off.distance < 8) return null;
    var axis = 0;
    var bestAngle = double.infinity;
    for (var a = 0; a < widget.axes.length; a++) {
      final diff =
          (geo.angle(a) - math.atan2(off.dy, off.dx)).abs() % (2 * math.pi);
      final wrapped = math.min(diff, 2 * math.pi - diff);
      if (wrapped < bestAngle) {
        bestAngle = wrapped;
        axis = a;
      }
    }
    return RadarSelection(axis);
  }

  @override
  Widget build(BuildContext context) {
    final chart = ChartTheme.of(context);
    final l10n = chartL10n(context);
    return LayoutBuilder(
      builder: (context, c) {
        final size = Size(
          c.hasBoundedWidth ? c.maxWidth : widget.size,
          widget.size,
        );
        return Semantics(
          container: true,
          label: widget.semanticsLabel,
          child: ExcludeSemantics(
            child: MouseRegion(
              onHover: widget.onSelect == null
                  ? null
                  : (e) => widget.onSelect!(_hit(e.localPosition, size)),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: widget.onSelect == null
                    ? null
                    : (d) => widget.onSelect!(_hit(d.localPosition, size)),
                child: AnimatedBuilder(
                  animation: _anim,
                  builder: (context, _) => CustomPaint(
                    key: const ValueKey('radar-paint'),
                    size: size,
                    painter: _RadarPainter(
                      chart: chart,
                      axes: widget.axes,
                      series: widget.series,
                      hidden: widget.hidden,
                      selection: widget.selection,
                      progress: Curves.easeOutCubic.transform(_anim.value),
                      noData: l10n.durRadarNoData,
                      textScale: MediaQuery.textScalerOf(context),
                      textDirection: Directionality.of(context),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RadarGeometry {
  _RadarGeometry(this.size, this.n)
    : center = Offset(size.width / 2, size.height / 2),
      // Leave room for the labels around the rim.
      radius = math.max(10, math.min(size.width, size.height) / 2 - 44);

  final Size size;
  final int n;
  final Offset center;
  final double radius;

  /// Axis 0 points up, the rest clockwise.
  double angle(int i) => -math.pi / 2 + 2 * math.pi * i / n;

  Offset point(int i, double fraction, [double progress = 1]) {
    final r = radius * fraction.clamp(0.0, 1.0) * progress;
    return center + Offset(math.cos(angle(i)), math.sin(angle(i))) * r;
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({
    required this.chart,
    required this.axes,
    required this.series,
    required this.hidden,
    required this.selection,
    required this.progress,
    required this.noData,
    required this.textScale,
    required this.textDirection,
  });

  final ChartTheme chart;
  final List<String> axes;
  final List<RadarSeries> series;
  final Set<String> hidden;
  final RadarSelection? selection;
  final double progress;
  final String noData;
  final TextScaler textScale;
  final TextDirection textDirection;

  static const _rings = [0.25, 0.5, 0.75, 1.0];

  TextPainter _text(String s, TextStyle style, {double maxWidth = 80}) =>
      TextPainter(
        text: TextSpan(text: s, style: style),
        textAlign: TextAlign.center,
        textDirection: textDirection,
        textScaler: textScale,
        maxLines: 2,
      )..layout(maxWidth: maxWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final n = axes.length;
    if (n < 3) return;
    final geo = _RadarGeometry(size, n);
    final grid = Paint()
      ..color = chart.grid
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final outer = Paint()
      ..color = chart.axis
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Rings (polygons); the outer one (100 % = the fresh reference) stronger.
    for (final f in _rings) {
      final path = Path();
      for (var i = 0; i < n; i++) {
        final p = geo.point(i, f);
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      path.close();
      canvas.drawPath(path, f == 1.0 ? outer : grid);
      final label = _text('${(f * 100).round()}%', chart.labelStyle);
      label.paint(canvas, geo.point(0, f) + Offset(3, -label.height - 1));
    }

    // Spokes and axis labels.
    final visible = [
      for (var s = 0; s < series.length; s++)
        if (!hidden.contains(series[s].label)) s,
    ];
    for (var i = 0; i < n; i++) {
      final selected = selection?.axis == i;
      canvas.drawLine(
        geo.center,
        geo.point(i, 1),
        selected
            ? (Paint()
                ..color = chart.selection
                ..strokeWidth = 1.5)
            : grid,
      );
      final empty =
          visible.isNotEmpty &&
          visible.every((s) => series[s].values[i] == null);
      final style = chart.labelStyle.copyWith(
        color: chart.text,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
        fontSize: 11,
      );
      final tp = _text(empty ? '${axes[i]}\n$noData' : axes[i], style);
      final cosA = math.cos(geo.angle(i)), sinA = math.sin(geo.angle(i));
      final out = geo.point(i, 1) + Offset(cosA, sinA) * 6;
      var dx = out.dx - tp.width / 2 + cosA * tp.width / 2;
      var dy = out.dy - tp.height / 2 + sinA * tp.height / 2;
      dx = dx.clamp(0.0, math.max(0.0, size.width - tp.width));
      dy = dy.clamp(0.0, math.max(0.0, size.height - tp.height));
      tp.paint(canvas, Offset(dx, dy));
    }

    // Polygons, last level underneath so the smaller ones stay visible.
    for (final s in visible.reversed) {
      final sr = series[s];
      final present = [
        for (var i = 0; i < n; i++)
          if (sr.values[i] != null) i,
      ];
      if (present.isEmpty) continue;
      final pts = {
        for (final i in present) i: geo.point(i, sr.values[i]!, progress),
      };
      if (present.length >= 3) {
        final fill = Path();
        for (var k = 0; k < present.length; k++) {
          final p = pts[present[k]]!;
          k == 0 ? fill.moveTo(p.dx, p.dy) : fill.lineTo(p.dx, p.dy);
        }
        fill.close();
        canvas.drawPath(
          fill,
          Paint()
            ..color = sr.color.withValues(alpha: 0.18)
            ..style = PaintingStyle.fill,
        );
      }
      // Outline only between neighbouring axes that both have data.
      final line = Paint()
        ..color = sr.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round;
      for (var i = 0; i < n; i++) {
        final a = pts[i], b = pts[(i + 1) % n];
        if (a == null || b == null) continue;
        _stroke(canvas, a, b, line, sr.dash);
      }
    }
    for (final s in visible) {
      final sr = series[s];
      for (var i = 0; i < n; i++) {
        final v = sr.values[i];
        if (v == null) continue;
        final p = geo.point(i, v, progress);
        final sel = selection?.axis == i && selection?.series == s;
        drawMarker(
          canvas,
          p,
          sr.marker,
          sr.color,
          chart.surface,
          sel ? 6.5 : 4.5,
        );
        if (sel) {
          canvas.drawCircle(
            p,
            10,
            Paint()
              ..color = chart.selection
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5,
          );
        }
      }
    }
  }

  void _stroke(
    Canvas canvas,
    Offset a,
    Offset b,
    Paint paint,
    List<double>? dash,
  ) {
    if (dash == null || dash.length < 2) {
      canvas.drawLine(a, b, paint);
      return;
    }
    final len = (b - a).distance;
    if (len == 0) return;
    final dir = (b - a) / len;
    var d = 0.0;
    var k = 0;
    while (d < len) {
      final end = math.min(len, d + dash[k % dash.length]);
      canvas.drawLine(a + dir * d, a + dir * end, paint);
      d = end + dash[(k + 1) % dash.length];
      k += 2;
    }
  }

  @override
  bool shouldRepaint(_RadarPainter old) => true;
}

/// Paints [m] centred on [c], with a [edge]-coloured hairline.
void drawMarker(
  Canvas canvas,
  Offset c,
  RadarMarker m,
  Color color,
  Color edge,
  double r,
) {
  final fill = Paint()..color = color;
  final line = Paint()
    ..color = edge
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
  switch (m) {
    case RadarMarker.circle:
      canvas.drawCircle(c, r, fill);
      canvas.drawCircle(c, r, line);
    case RadarMarker.square:
      final rect = Rect.fromCenter(center: c, width: r * 1.8, height: r * 1.8);
      canvas.drawRect(rect, fill);
      canvas.drawRect(rect, line);
    case RadarMarker.triangle:
      final path = Path()
        ..moveTo(c.dx, c.dy - r * 1.2)
        ..lineTo(c.dx + r * 1.1, c.dy + r * 0.9)
        ..lineTo(c.dx - r * 1.1, c.dy + r * 0.9)
        ..close();
      canvas.drawPath(path, fill);
      canvas.drawPath(path, line);
    case RadarMarker.diamond:
      final path = Path()
        ..moveTo(c.dx, c.dy - r * 1.3)
        ..lineTo(c.dx + r * 1.3, c.dy)
        ..lineTo(c.dx, c.dy + r * 1.3)
        ..lineTo(c.dx - r * 1.3, c.dy)
        ..close();
      canvas.drawPath(path, fill);
      canvas.drawPath(path, line);
  }
}

/// A legend sample: the dash pattern with the marker on it.
class RadarLegendSwatch extends StatelessWidget {
  const RadarLegendSwatch({super.key, required this.series});
  final RadarSeries series;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size(28, 12),
    painter: _SwatchPainter(series, ChartTheme.of(context).surface),
  );
}

class _SwatchPainter extends CustomPainter {
  _SwatchPainter(this.series, this.edge);
  final RadarSeries series;
  final Color edge;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = series.color
      ..strokeWidth = 2;
    final y = size.height / 2;
    final dash = series.dash;
    if (dash == null) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    } else {
      var x = 0.0;
      var k = 0;
      while (x < size.width) {
        final end = math.min(size.width, x + dash[k % dash.length]);
        canvas.drawLine(Offset(x, y), Offset(end, y), paint);
        x = end + dash[(k + 1) % dash.length];
        k += 2;
      }
    }
    drawMarker(
      canvas,
      Offset(size.width / 2, y),
      series.marker,
      series.color,
      edge,
      3.5,
    );
  }

  @override
  bool shouldRepaint(_SwatchPainter old) =>
      old.series != series || old.edge != edge;
}
