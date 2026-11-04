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

/// A trailing-and-leading rolling mean of [values] over [window] samples
/// (gaps stay gaps) — power at 1 Hz is too jagged to read, 30 s is not.
List<double?> rollingMean(List<double?> values, int window) {
  if (window <= 1 || values.isEmpty) return values;
  final n = values.length;
  final sum = List<double>.filled(n + 1, 0);
  final count = List<int>.filled(n + 1, 0);
  for (var i = 0; i < n; i++) {
    final v = values[i];
    sum[i + 1] = sum[i] + (v ?? 0);
    count[i + 1] = count[i] + (v == null ? 0 : 1);
  }
  final half = window ~/ 2;
  return [
    for (var i = 0; i < n; i++)
      if (values[i] == null)
        null
      else
        (sum[math.min(n, i + half + 1)] - sum[math.max(0, i - half)]) /
            (count[math.min(n, i + half + 1)] - count[math.max(0, i - half)]),
  ];
}

/// Seconds at (fractional) sample [index], from the `time` stream, or the
/// index itself when there is none.
double timeAtIndex(List<double?>? time, double index) {
  if (time == null || time.isEmpty) return index;
  final i = index.floor().clamp(0, time.length - 1);
  final a = time[i] ?? i.toDouble();
  final b = time[math.min(i + 1, time.length - 1)] ?? a;
  return a + (b - a) * (index - i);
}

/// The (fractional) sample index at [seconds] — the inverse of
/// [timeAtIndex], by binary search.
double indexAtTime(List<double?>? time, double seconds) {
  if (time == null || time.isEmpty) return seconds;
  double t(int i) => time[i] ?? i.toDouble();
  var lo = 0;
  var hi = time.length - 1;
  while (lo < hi) {
    final mid = (lo + hi) ~/ 2;
    if (t(mid) < seconds) {
      lo = mid + 1;
    } else {
      hi = mid;
    }
  }
  if (lo == 0) return 0;
  final a = t(lo - 1);
  final b = t(lo);
  return b == a ? lo.toDouble() : lo - 1 + (seconds - a) / (b - a);
}

String clockLabel(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;
  String two(int v) => v.toString().padLeft(2, '0');
  return h > 0 ? '$h:${two(m)}:${two(s)}' : '$m:${two(s)}';
}

/// Time series of one session: each selected stream on its own scale (watts
/// and bpm don't share an axis) with labelled axes — the first stream on the
/// left, the second on the right — a time axis, work intervals as shaded
/// bands, dashed averages, a peak marker, and a press/drag crosshair.
///
/// Pinch, double tap, Ctrl + wheel or the + / − buttons zoom the time axis;
/// one finger pans once zoomed, and an overview strip under the chart shows
/// and moves the window. Painted by hand like the app's other charts,
/// downsampled before painting.
class StreamChart extends StatefulWidget {
  const StreamChart({
    super.key,
    required this.streams,
    required this.visible,
    required this.format,
    this.height = 240,
    this.smoothSeconds = 0,
    this.viewport,
    this.onCursorSeconds,
  });

  final SessionStreams streams;

  /// Told the elapsed seconds under the pointer (tap, drag or mouse hover),
  /// e.g. to mark the same moment on a map.
  final ValueChanged<double>? onCursorSeconds;

  /// Stream types to draw, in [SessionStreams.drawable] order.
  final Set<String> visible;

  /// A stream's value at the readout, formatted with its unit.
  final String Function(String type, double value) format;
  final double height;

  /// Rolling-mean window applied to what is drawn (0 = raw). Averages and
  /// the readout always use the raw samples.
  final int smoothSeconds;

  /// Share the zoom window with the surrounding screen (e.g. to zoom to an
  /// interval); the chart makes its own when null.
  final ChartViewport? viewport;

  /// Points per drawn series, roughly; see [downsample].
  static const buckets = 600;

  /// Streams smoothing makes sense for (altitude is already smooth).
  static const smoothable = {'watts', 'heartrate', 'velocity_smooth', 'cadence'};

  @override
  State<StreamChart> createState() => _StreamChartState();
}

class _StreamChartState extends State<StreamChart> {
  static const _axisWidth = 54.0;

  int? _readout;
  final _ownViewport = ChartViewport();
  Map<String, List<double?>> _drawn = const {};

  ChartViewport get _vp => widget.viewport ?? _ownViewport;

  int get _length {
    var n = 0;
    for (final s in widget.streams.series.values) {
      n = math.max(n, s.length);
    }
    return n;
  }

  /// Seconds per sample, for turning a smoothing window into samples.
  double get _dt {
    final t = widget.streams.time;
    if (t == null || t.length < 2) return 1;
    final first = t.first, last = t.last;
    if (first == null || last == null || last <= first) return 1;
    return (last - first) / (t.length - 1);
  }

  void _rebuildSmoothed() {
    final window = widget.smoothSeconds <= 0
        ? 0
        : math.max(1, (widget.smoothSeconds / _dt).round());
    _drawn = {
      for (final e in widget.streams.series.entries)
        e.key: StreamChart.smoothable.contains(e.key)
            ? rollingMean(e.value, window)
            : e.value,
    };
  }

  @override
  void initState() {
    super.initState();
    _vp.setLength(_length);
    _rebuildSmoothed();
  }

  @override
  void didUpdateWidget(StreamChart old) {
    super.didUpdateWidget(old);
    _vp.setLength(_length);
    if (old.streams != widget.streams ||
        old.smoothSeconds != widget.smoothSeconds) {
      _rebuildSmoothed();
    }
  }

  @override
  void dispose() {
    _ownViewport.dispose();
    super.dispose();
  }

  String _clock(int index) =>
      clockLabel(timeAtIndex(widget.streams.time, index.toDouble()).round());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final vp = _vp;
    final types = [
      for (final t in widget.streams.drawable)
        if (widget.visible.contains(t)) t,
    ];
    final readout = _readout;
    final leftW = types.isEmpty ? 0.0 : _axisWidth;
    final rightW = types.length >= 2 ? _axisWidth : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListenableBuilder(
          listenable: vp,
          builder: (context, _) {
            final start = vp.lo.floor();
            final end = vp.hi.ceil();
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
                        if (vp.isZoomed)
                          Text(
                            '${clockLabel(timeAtIndex(widget.streams.time, vp.lo).round())}'
                            ' – '
                            '${clockLabel(timeAtIndex(widget.streams.time, vp.hi).round())}',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
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
          viewport: vp,
          plotLeft: leftW,
          plotRight: rightW,
          hoverSelects: true,
          onSelectAt: (i) {
            setState(() => _readout = i);
            final cb = widget.onCursorSeconds;
            final time = widget.streams.time;
            if (cb != null && time != null && i < time.length) {
              final t = time[i];
              if (t != null) cb(t);
            }
          },
          child: SizedBox(
            height: widget.height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ListenableBuilder(
                  listenable: vp,
                  builder: (context, _) {
                    final start = vp.lo.floor();
                    final end = math.min(_length - 1, vp.hi.ceil());
                    return CustomPaint(
                      key: const ValueKey('stream-chart-paint'),
                      painter: StreamChartPainter(
                        series: {
                          for (final t in types)
                            t: _window(_drawn[t]!, start, end),
                        },
                        averages: {
                          for (final t in types)
                            if (_average(widget.streams.series[t]!, start, end)
                                case final avg?)
                              t: avg,
                        },
                        readoutValues: {
                          if (readout != null)
                            for (final t in types)
                              if (readout < widget.streams.series[t]!.length)
                                t: widget.streams.series[t]![readout],
                        },
                        readoutLabel: readout == null ? null : _clock(readout),
                        length: _length,
                        lo: vp.lo,
                        hi: vp.hi,
                        time: widget.streams.time,
                        intervals: widget.streams.intervals,
                        readout: readout,
                        colorOf: (t) => streamColor(t, scheme),
                        format: widget.format,
                        leftAxis: leftW,
                        rightAxis: rightW,
                        band: scheme.primary.withValues(alpha: 0.09),
                        grid: scheme.outlineVariant,
                        cursor: scheme.onSurface,
                        surface: scheme.surface,
                        labelStyle: TextStyle(
                          fontSize: 10,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 2,
                  left: leftW + 4,
                  child: ZoomControls(viewport: vp),
                ),
              ],
            ),
          ),
        ),
        ListenableBuilder(
          listenable: vp,
          builder: (context, _) => vp.isZoomed && types.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.fromLTRB(leftW, 6, rightW, 0),
                  child: _Overview(
                    viewport: vp,
                    points: downsample(_drawn[types.first]!, 240),
                    color: streamColor(types.first, scheme),
                    track: scheme.surfaceContainerHighest,
                    window: scheme.primary,
                  ),
                )
              : const SizedBox.shrink(),
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

/// The whole session as a thin strip with the zoom window highlighted;
/// tap or drag to move the window.
class _Overview extends StatelessWidget {
  const _Overview({
    required this.viewport,
    required this.points,
    required this.color,
    required this.track,
    required this.window,
  });

  final ChartViewport viewport;
  final List<(int, double)> points;
  final Color color;
  final Color track;
  final Color window;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        void move(double dx) {
          if (width <= 0) return;
          viewport.centerOn(
            (dx / width).clamp(0.0, 1.0).toDouble() * viewport.fullSpan,
          );
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => move(d.localPosition.dx),
          onHorizontalDragUpdate: (d) => move(d.localPosition.dx),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CustomPaint(
              size: Size(width, 34),
              painter: _OverviewPainter(
                points: points,
                length: viewport.length,
                lo: viewport.lo,
                hi: viewport.hi,
                color: color,
                track: track,
                window: window,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OverviewPainter extends CustomPainter {
  _OverviewPainter({
    required this.points,
    required this.length,
    required this.lo,
    required this.hi,
    required this.color,
    required this.track,
    required this.window,
  });

  final List<(int, double)> points;
  final int length;
  final double lo;
  final double hi;
  final Color color;
  final Color track;
  final Color window;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = track);
    if (length < 2 || points.length < 2) return;
    var min = points.first.$2, max = points.first.$2;
    for (final p in points) {
      min = math.min(min, p.$2);
      max = math.max(max, p.$2);
    }
    final span = max - min == 0 ? 1.0 : max - min;
    double x(num i) => i / (length - 1) * size.width;
    double y(double v) => size.height - 4 - (v - min) / span * (size.height - 8);
    final path = Path()..moveTo(x(points.first.$1), y(points.first.$2));
    for (final p in points.skip(1)) {
      path.lineTo(x(p.$1), y(p.$2));
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.8)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );
    final rect = Rect.fromLTRB(x(lo), 0, x(hi), size.height);
    canvas.drawRect(rect, Paint()..color = window.withValues(alpha: 0.16));
    canvas.drawRect(
      rect.deflate(0.75),
      Paint()
        ..color = window
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_OverviewPainter old) => true;
}

class _Scale {
  const _Scale(this.min, this.max, this.step);
  final double min;
  final double max;
  final double step;

  /// A scale over [lo]..[hi] on round numbers, about four steps.
  factory _Scale.nice(double lo, double hi) {
    if ((hi - lo).abs() < 1e-9) {
      lo -= 1;
      hi += 1;
    }
    final raw = (hi - lo) / 4;
    final mag = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
    final norm = raw / mag;
    final step =
        (norm <= 1 ? 1 : norm <= 2 ? 2 : norm <= 5 ? 5 : 10) * mag;
    return _Scale((lo / step).floor() * step, (hi / step).ceil() * step, step);
  }

  Iterable<double> get ticks sync* {
    for (var v = min; v <= max + step / 2; v += step) {
      yield v;
    }
  }
}

/// Exposed for tests: how many points a paint used.
class StreamChartPainter extends CustomPainter {
  StreamChartPainter({
    required this.series,
    required this.length,
    this.averages = const {},
    this.readoutValues = const {},
    this.readoutLabel,
    this.lo = 0,
    this.hi = 0,
    this.time,
    required this.intervals,
    required this.readout,
    required this.colorOf,
    required this.format,
    this.leftAxis = 0,
    this.rightAxis = 0,
    required this.band,
    required this.grid,
    required this.cursor,
    required this.surface,
    required this.labelStyle,
  });

  /// Downsampled points per drawn stream; the first is the primary one
  /// (left axis, filled, peak-marked), the second gets the right axis.
  final Map<String, List<(int, double)>> series;
  final int length;

  /// Mean of each stream over the visible window, drawn as a dashed line.
  final Map<String, double> averages;
  final Map<String, double?> readoutValues;
  final String? readoutLabel;

  /// Visible index window; `hi <= lo` means the whole session.
  final double lo;
  final double hi;
  final List<double?>? time;
  final List<SessionInterval> intervals;
  final int? readout;
  final Color Function(String) colorOf;
  final String Function(String type, double value) format;
  final double leftAxis;
  final double rightAxis;
  final Color band;
  final Color grid;
  final Color cursor;
  final Color surface;
  final TextStyle labelStyle;

  int get pointCount => series.values.fold(0, (n, s) => n + s.length);

  static const _timeSteps = [10, 30, 60, 120, 300, 600, 900, 1800, 3600, 7200];

  @override
  void paint(Canvas canvas, Size size) {
    if (length < 2) return;
    final plot = Rect.fromLTRB(
      leftAxis,
      8,
      size.width - rightAxis,
      size.height - 20,
    );
    if (plot.width <= 0 || plot.height <= 0) return;
    final from = hi > lo ? lo : 0.0;
    final span = hi > lo ? hi - lo : (length - 1).toDouble();
    double x(num i) => plot.left + (i - from) / span * plot.width;

    final entries = series.entries.where((e) => e.value.isNotEmpty).toList();
    final scales = <String, _Scale>{};
    for (final e in entries) {
      var min = e.value.first.$2, max = e.value.first.$2;
      for (final p in e.value) {
        min = math.min(min, p.$2);
        max = math.max(max, p.$2);
      }
      scales[e.key] = _Scale.nice(min, max);
    }
    double y(String type, double v) {
      final s = scales[type]!;
      return plot.bottom - (v - s.min) / (s.max - s.min) * plot.height;
    }

    // Primary gridlines and the left axis.
    final gridPaint = Paint()
      ..color = grid.withValues(alpha: 0.55)
      ..strokeWidth = 1;
    if (entries.isNotEmpty) {
      final type = entries.first.key;
      for (final tick in scales[type]!.ticks) {
        final ty = y(type, tick);
        canvas.drawLine(Offset(plot.left, ty), Offset(plot.right, ty), gridPaint);
        _axisLabel(
          canvas,
          format(type, tick),
          Offset(plot.left - 6, ty),
          colorOf(type),
          alignRight: true,
        );
      }
    }
    if (entries.length >= 2) {
      final type = entries[1].key;
      for (final tick in scales[type]!.ticks) {
        final ty = y(type, tick);
        canvas.drawLine(
          Offset(plot.right, ty),
          Offset(plot.right + 3, ty),
          Paint()
            ..color = colorOf(type)
            ..strokeWidth = 1,
        );
        _axisLabel(
          canvas,
          format(type, tick),
          Offset(plot.right + 6, ty),
          colorOf(type),
          alignRight: false,
        );
      }
    }

    canvas.save();
    canvas.clipRect(plot.inflate(0.5));

    for (final interval in intervals.where((i) => i.isWork)) {
      final r = Rect.fromLTRB(x(interval.start), plot.top, x(interval.end), plot.bottom);
      canvas.drawRect(r, Paint()..color = band);
    }

    for (final (n, e) in entries.indexed) {
      final points = e.value;
      final color = colorOf(e.key);
      final path = Path()..moveTo(x(points.first.$1), y(e.key, points.first.$2));
      for (final p in points.skip(1)) {
        path.lineTo(x(p.$1), y(e.key, p.$2));
      }
      if (n == 0) {
        final fill = Path.from(path)
          ..lineTo(x(points.last.$1), plot.bottom)
          ..lineTo(x(points.first.$1), plot.bottom)
          ..close();
        canvas.drawPath(
          fill,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0.22),
                color.withValues(alpha: 0.0),
              ],
            ).createShader(plot),
        );
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..strokeWidth = 1.6
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
      final avg = averages[e.key];
      if (avg != null && scales[e.key]!.max > avg && scales[e.key]!.min < avg) {
        drawDashedLine(
          canvas,
          Offset(plot.left, y(e.key, avg)),
          Offset(plot.right, y(e.key, avg)),
          Paint()
            ..color = color.withValues(alpha: 0.75)
            ..strokeWidth = 1,
        );
      }
    }
    canvas.restore();

    // Peak of the primary stream in view.
    if (entries.isNotEmpty) {
      final e = entries.first;
      var peak = e.value.first;
      for (final p in e.value) {
        if (p.$2 > peak.$2) peak = p;
      }
      final px = x(peak.$1);
      if (px >= plot.left && px <= plot.right) {
        final py = y(e.key, peak.$2);
        canvas.drawCircle(Offset(px, py), 3.5, Paint()..color = colorOf(e.key));
        canvas.drawCircle(
          Offset(px, py),
          3.5,
          Paint()
            ..color = surface
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
        final tp = _tp(
          format(e.key, peak.$2),
          labelStyle.copyWith(
            color: colorOf(e.key),
            fontWeight: FontWeight.w700,
          ),
        );
        tp.paint(
          canvas,
          Offset(
            (px - tp.width / 2).clamp(plot.left, plot.right - tp.width).toDouble(),
            math.max(0.0, py - tp.height - 5),
          ),
        );
      }
    }

    // Time axis.
    final t0 = timeAtIndex(time, from);
    final t1 = timeAtIndex(time, from + span);
    final target = math.max(1, plot.width / 76);
    final step = _timeSteps.firstWhere(
      (s) => (t1 - t0) / s <= target,
      orElse: () => _timeSteps.last,
    );
    final tickPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var t = (t0 / step).ceil() * step; t <= t1; t += step) {
      final tx = x(indexAtTime(time, t.toDouble()));
      if (tx < plot.left || tx > plot.right) continue;
      canvas.drawLine(Offset(tx, plot.bottom), Offset(tx, plot.bottom + 3), tickPaint);
      final tp = _tp(_tickLabel(t, step), labelStyle);
      tp.paint(
        canvas,
        Offset(
          (tx - tp.width / 2).clamp(plot.left, size.width - tp.width).toDouble(),
          plot.bottom + 4,
        ),
      );
    }

    // Crosshair, markers and the time chip.
    final r = readout;
    if (r != null) {
      final rx = x(r);
      if (rx >= plot.left && rx <= plot.right) {
        canvas.drawLine(
          Offset(rx, plot.top),
          Offset(rx, plot.bottom),
          Paint()
            ..color = cursor.withValues(alpha: 0.55)
            ..strokeWidth = 1,
        );
        for (final e in entries) {
          final v = readoutValues[e.key];
          if (v == null) continue;
          canvas.drawCircle(Offset(rx, y(e.key, v)), 4.5, Paint()..color = surface);
          canvas.drawCircle(Offset(rx, y(e.key, v)), 3, Paint()..color = colorOf(e.key));
        }
        final label = readoutLabel;
        if (label != null) {
          final tp = _tp(
            label,
            labelStyle.copyWith(
              color: surface,
              fontWeight: FontWeight.w700,
            ),
          );
          final chip = RRect.fromRectAndRadius(
            Rect.fromLTWH(
              (rx - tp.width / 2 - 5)
                  .clamp(0.0, size.width - tp.width - 10)
                  .toDouble(),
              plot.bottom + 2,
              tp.width + 10,
              tp.height + 3,
            ),
            const Radius.circular(8),
          );
          canvas.drawRRect(chip, Paint()..color = cursor);
          tp.paint(canvas, chip.outerRect.topLeft + const Offset(5, 1.5));
        }
      }
    }
  }

  static String _tickLabel(int seconds, int step) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    String two(int v) => v.toString().padLeft(2, '0');
    if (seconds >= 3600) return '$h:${two(m)}';
    return step < 60 ? '$m:${two(s)}' : '${seconds ~/ 60} min';
  }

  void _axisLabel(
    Canvas canvas,
    String text,
    Offset anchor,
    Color color, {
    required bool alignRight,
  }) {
    final tp = _tp(text, labelStyle.copyWith(color: color));
    tp.paint(
      canvas,
      Offset(
        alignRight ? anchor.dx - tp.width : anchor.dx,
        anchor.dy - tp.height / 2,
      ),
    );
  }

  TextPainter _tp(String text, TextStyle style) => TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout();

  @override
  bool shouldRepaint(StreamChartPainter old) => true;
}
