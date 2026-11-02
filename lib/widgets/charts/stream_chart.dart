import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../evaluation/session_streams.dart';
import 'chart_viewport.dart';

/// Min-max downsampling: [values] split into [buckets] runs, each kept as
/// its lowest and highest sample (in time order) so spikes survive. Returns
/// `(index, value)` pairs, at most `2 * buckets` of them, nulls skipped. A
/// six-hour ride (21,600 samples) paints as ~1,200 points instead.
List<(int, double)> downsample(List<double?> values, int buckets) {
  final out = <(int, double)>[];
  if (values.isEmpty || buckets <= 0) return out;
  if (values.length <= buckets * 2) {
    for (var i = 0; i < values.length; i++) {
      final v = values[i];
      if (v != null) out.add((i, v));
    }
    return out;
  }
  final size = values.length / buckets;
  for (var b = 0; b < buckets; b++) {
    final from = (b * size).floor();
    final to = math.min(values.length, ((b + 1) * size).floor());
    int? minI, maxI;
    for (var i = from; i < to; i++) {
      final v = values[i];
      if (v == null) continue;
      if (minI == null || v < values[minI]!) minI = i;
      if (maxI == null || v > values[maxI]!) maxI = i;
    }
    if (minI == null || maxI == null) continue;
    if (minI == maxI) {
      out.add((minI, values[minI]!));
    } else {
      final (a, c) = minI < maxI ? (minI, maxI) : (maxI, minI);
      out
        ..add((a, values[a]!))
        ..add((c, values[c]!));
    }
  }
  return out;
}

/// A colour per stream type, readable in light and dark.
Color streamColor(String type, ColorScheme scheme) => switch (type) {
  'watts' => scheme.brightness == Brightness.dark
      ? const Color(0xFFFFB74D)
      : const Color(0xFFE65100),
  'heartrate' => scheme.brightness == Brightness.dark
      ? const Color(0xFFEF9A9A)
      : const Color(0xFFC62828),
  'velocity_smooth' => scheme.brightness == Brightness.dark
      ? const Color(0xFF81C784)
      : const Color(0xFF2E7D32),
  'cadence' => scheme.tertiary,
  'altitude' => scheme.outline,
  _ => scheme.secondary,
};

/// Time series of one session: each selected stream on its own scale (watts
/// and bpm don't share an axis), work intervals as shaded bands, and a
/// press/drag readout of every stream at that moment. Painted by hand like
/// the app's other charts, downsampled before painting.
class StreamChart extends StatefulWidget {
  const StreamChart({
    super.key,
    required this.streams,
    required this.visible,
    required this.format,
    this.height = 220,
  });

  final SessionStreams streams;

  /// Stream types to draw, in [SessionStreams.drawable] order.
  final Set<String> visible;

  /// A stream's value at the readout, formatted with its unit.
  final String Function(String type, double value) format;
  final double height;

  /// Points per drawn series, roughly; see [downsample].
  static const buckets = 600;

  @override
  State<StreamChart> createState() => _StreamChartState();
}

class _StreamChartState extends State<StreamChart> {
  int? _readout;
  final _viewport = ChartViewport();

  @override
  void initState() {
    super.initState();
    _viewport.setLength(_length);
  }

  @override
  void didUpdateWidget(StreamChart old) {
    super.didUpdateWidget(old);
    _viewport.setLength(_length);
  }

  @override
  void dispose() {
    _viewport.dispose();
    super.dispose();
  }

  int get _length {
    var n = 0;
    for (final s in widget.streams.series.values) {
      n = math.max(n, s.length);
    }
    return n;
  }

  String _clock(int index) {
    final t = widget.streams.time;
    final secs = (t != null && index < t.length ? t[index] : null)?.round() ??
        index;
    final h = secs ~/ 3600;
    final m = (secs % 3600) ~/ 60;
    final s = secs % 60;
    String two(int v) => v.toString().padLeft(2, '0');
    return h > 0 ? '$h:${two(m)}:${two(s)}' : '$m:${two(s)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final types = [
      for (final t in widget.streams.drawable)
        if (widget.visible.contains(t)) t,
    ];
    final readout = _readout;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListenableBuilder(
          listenable: _viewport,
          builder: (context, _) {
            final start = _viewport.lo.floor();
            final end = _viewport.hi.ceil();
            final averages = <String, double>{
              for (final t in types)
                if (_average(widget.streams.series[t]!, start, end)
                    case final avg?)
                  t: avg,
            };
            return SizedBox(
              height: 36,
              child: Wrap(
                spacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: readout == null
                    ? [
                        for (final t in types)
                          if (averages[t] != null)
                            Text(
                              'Ø ${widget.format(t, averages[t]!)}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: streamColor(t, scheme),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                      ]
                    : [
                        Text(
                          _clock(readout),
                          style: theme.textTheme.labelMedium,
                        ),
                        for (final t in types)
                          if (readout < widget.streams.series[t]!.length &&
                              widget.streams.series[t]![readout] != null)
                            Text(
                              widget.format(
                                t,
                                widget.streams.series[t]![readout]!,
                              ),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: streamColor(t, scheme),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                      ],
              ),
            );
          },
        ),
        ChartInteraction(
          viewport: _viewport,
          plotLeft: 0,
          onSelectAt: (i) => setState(() => _readout = i),
          child: SizedBox(
            height: widget.height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ListenableBuilder(
                  listenable: _viewport,
                  builder: (context, _) {
                    final start = _viewport.lo.floor();
                    final end = math.min(_length - 1, _viewport.hi.ceil());
                    return CustomPaint(
                      key: const ValueKey('stream-chart-paint'),
                      painter: StreamChartPainter(
                        series: {
                          for (final t in types)
                            t: _window(widget.streams.series[t]!, start, end),
                        },
                        averages: {
                          for (final t in types)
                            if (_average(widget.streams.series[t]!, start, end)
                                case final avg?)
                              t: avg,
                        },
                        length: _length,
                        lo: _viewport.lo,
                        hi: _viewport.hi,
                        intervals: widget.streams.intervals,
                        readout: readout,
                        colorOf: (t) => streamColor(t, scheme),
                        band: scheme.primary.withValues(alpha: 0.08),
                        grid: scheme.outlineVariant,
                        cursor: scheme.onSurface,
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: ZoomResetButton(viewport: _viewport),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// The downsampled points of [values] within [start]..[end], keeping
  /// their absolute indices.
  static List<(int, double)> _window(List<double?> values, int start, int end) {
    if (values.isEmpty) return const [];
    final from = start.clamp(0, values.length - 1);
    final to = end.clamp(from, values.length - 1);
    return [
      for (final (i, v)
          in downsample(values.sublist(from, to + 1), StreamChart.buckets))
        (i + from, v),
    ];
  }

  static double? _average(List<double?> values, int start, int end) {
    var sum = 0.0;
    var n = 0;
    for (var i = math.max(0, start); i <= end && i < values.length; i++) {
      final v = values[i];
      if (v == null) continue;
      sum += v;
      n++;
    }
    return n == 0 ? null : sum / n;
  }
}

/// Exposed for tests: how many points a paint used.
class StreamChartPainter extends CustomPainter {
  StreamChartPainter({
    required this.series,
    required this.length,
    this.averages = const {},
    this.lo = 0,
    this.hi = 0,
    required this.intervals,
    required this.readout,
    required this.colorOf,
    required this.band,
    required this.grid,
    required this.cursor,
  });

  final Map<String, List<(int, double)>> series;
  final int length;

  /// Mean of each stream over the visible window, drawn as a dashed line.
  final Map<String, double> averages;

  /// Visible index window; `hi <= lo` means the whole session.
  final double lo;
  final double hi;
  final List<SessionInterval> intervals;
  final int? readout;
  final Color Function(String) colorOf;
  final Color band;
  final Color grid;
  final Color cursor;

  int get pointCount => series.values.fold(0, (n, s) => n + s.length);

  @override
  void paint(Canvas canvas, Size size) {
    if (length < 2) return;
    final from = hi > lo ? lo : 0.0;
    final span = hi > lo ? hi - lo : (length - 1).toDouble();
    double x(num i) => (i - from) / span * size.width;
    canvas.save();
    canvas.clipRect(Offset.zero & size);

    for (final interval in intervals.where((i) => i.isWork)) {
      canvas.drawRect(
        Rect.fromLTRB(x(interval.start), 0, x(interval.end), size.height),
        Paint()..color = band,
      );
    }
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var k = 1; k < 4; k++) {
      final y = size.height * k / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (final entry in series.entries) {
      final points = entry.value;
      if (points.isEmpty) continue;
      var lo = points.first.$2, hi = points.first.$2;
      for (final p in points) {
        lo = math.min(lo, p.$2);
        hi = math.max(hi, p.$2);
      }
      final span = hi - lo == 0 ? 1.0 : hi - lo;
      double y(double v) => size.height - 4 - (v - lo) / span * (size.height - 8);
      final path = Path()..moveTo(x(points.first.$1), y(points.first.$2));
      for (final p in points.skip(1)) {
        path.lineTo(x(p.$1), y(p.$2));
      }
      final color = colorOf(entry.key);
      final fill = Path.from(path)
        ..lineTo(x(points.last.$1), size.height)
        ..lineTo(x(points.first.$1), size.height)
        ..close();
      canvas.drawPath(
        fill,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: 0.14), color.withValues(alpha: 0)],
          ).createShader(Offset.zero & size),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..strokeWidth = 1.6
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke,
      );
      final avg = averages[entry.key];
      if (avg != null) {
        drawDashedLine(
          canvas,
          Offset(0, y(avg)),
          Offset(size.width, y(avg)),
          Paint()
            ..color = color.withValues(alpha: 0.7)
            ..strokeWidth = 1,
        );
      }
    }

    final r = readout;
    if (r != null) {
      canvas.drawLine(
        Offset(x(r), 0),
        Offset(x(r), size.height),
        Paint()
          ..color = cursor
          ..strokeWidth = 1,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(StreamChartPainter old) => true;
}
