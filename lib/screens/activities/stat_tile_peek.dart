import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../evaluation/session_streams.dart';
import '../../l10n/app_localizations.dart';
import 'activity_icons.dart';

/// Which stream an activity tile's peek is drawn from.
enum StatStream { heartrate, power, speed }

/// Time spent in each bin of a stream, and its time-weighted summary.
class StreamHistogram {
  const StreamHistogram({
    required this.binStart,
    required this.binWidth,
    required this.seconds,
    required this.min,
    required this.avg,
    required this.max,
  });

  /// Lower edge of the first bin; bin i covers
  /// [binStart + i·binWidth, binStart + (i+1)·binWidth).
  final double binStart;
  final double binWidth;
  final List<double> seconds;
  final double min;
  final double avg;
  final double max;

  double get totalSeconds => seconds.fold(0, (a, b) => a + b);

  /// Index of the bin with the most time.
  int get peak {
    var best = 0;
    for (var i = 1; i < seconds.length; i++) {
      if (seconds[i] > seconds[best]) best = i;
    }
    return best;
  }
}

/// Longest gap between two samples that still counts as time spent at the
/// value (a pause or a dropout beyond this is left out).
const _maxSampleGap = 10.0;

/// Time-weighted histogram of [values] in bins of [binWidth]. Each sample
/// counts for the time until the next one ([time], seconds; one second per
/// sample without it), capped so pauses don't count. Samples that are null,
/// or at or below [floor] when one is given, are left out. `null` when no
/// sample is left.
StreamHistogram? streamHistogram(
  List<double?> values, {
  List<double?>? time,
  required double binWidth,
  double? floor,
}) {
  final pairs = <(double, double)>[];
  for (var i = 0; i < values.length; i++) {
    final v = values[i];
    if (v == null || v.isNaN || (floor != null && v <= floor)) continue;
    var dt = 1.0;
    if (time != null && i + 1 < time.length && i < time.length) {
      final a = time[i], b = time[i + 1];
      if (a != null && b != null) dt = (b - a).clamp(0, _maxSampleGap);
    }
    if (dt <= 0) continue;
    pairs.add((v, dt));
  }
  if (pairs.isEmpty) return null;
  var lo = double.infinity, hi = -double.infinity, sum = 0.0, weight = 0.0;
  for (final (v, dt) in pairs) {
    lo = math.min(lo, v);
    hi = math.max(hi, v);
    sum += v * dt;
    weight += dt;
  }
  final start = (lo / binWidth).floor() * binWidth;
  final count = ((hi - start) / binWidth).floor() + 1;
  final seconds = List<double>.filled(count, 0);
  for (final (v, dt) in pairs) {
    final i = ((v - start) / binWidth).floor().clamp(0, count - 1);
    seconds[i] += dt;
  }
  return StreamHistogram(
    binStart: start,
    binWidth: binWidth,
    seconds: seconds,
    min: lo,
    avg: sum / weight,
    max: hi,
  );
}

/// How a stream is binned and labelled.
class _StreamSpec {
  const _StreamSpec(this.key, this.binWidth, this.floor, this.format);

  final String key;
  final double binWidth;
  final double? floor;
  final String Function(double value) format;
}

_StreamSpec _spec(StatStream stream, {required bool pace}) => switch (stream) {
  StatStream.heartrate => _StreamSpec(
    'heartrate',
    5,
    0,
    (v) => '${v.round()} bpm',
  ),
  StatStream.power => _StreamSpec('watts', 25, null, (v) => '${v.round()} W'),
  // Speed in km/h, or pace in min/km for a run (the stream is m/s).
  StatStream.speed =>
    pace
        ? _StreamSpec('velocity_smooth', 0.25, 0.5, (v) {
            final secsPerKm = 1000 / v;
            final m = secsPerKm ~/ 60;
            final s = (secsPerKm % 60).round().toString().padLeft(2, '0');
            return '$m:$s /km';
          })
        : _StreamSpec(
            'velocity_smooth',
            5 / 3.6,
            0.5,
            (v) => '${(v * 3.6).round()} km/h',
          ),
};

/// What holding a tile on the activity page shows: the stream behind the
/// number as a histogram of time per bin, with min / avg / max, and the
/// most common range.
///
/// Reads the streams cached on the device, or loads them once (the Charts
/// tab stores them the same way).
class StatTilePeek extends StatefulWidget {
  const StatTilePeek({
    super.key,
    required this.title,
    required this.activityId,
    required this.stream,
    required this.streams,
    required this.color,
    this.pace = false,
  });

  final String title;
  final String activityId;
  final StatStream stream;
  final ActivityStreamsRepository streams;
  final Color color;

  /// Speed as pace (min/km), for runs.
  final bool pace;

  @override
  State<StatTilePeek> createState() => _StatTilePeekState();
}

class _StatTilePeekState extends State<StatTilePeek> {
  late final Future<SessionStreams?> _future = _load();

  Future<SessionStreams?> _load() async {
    try {
      return await widget.streams.cached(widget.activityId) ??
          await widget.streams.load(widget.activityId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final spec = _spec(widget.stream, pace: widget.pace);

    return FutureBuilder<SessionStreams?>(
      future: _future,
      builder: (context, snap) {
        final header = Text(
          widget.title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        );
        if (snap.connectionState != ConnectionState.done) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
          );
        }
        final streams = snap.data;
        final values = streams?.series[spec.key];
        final hist = values == null
            ? null
            : streamHistogram(
                values,
                time: streams!.time,
                binWidth: spec.binWidth,
                floor: spec.floor,
              );
        if (hist == null) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: 8),
              Text(
                l10n.statPeekNoStream,
                key: const ValueKey('stat-peek-empty'),
                style: theme.textTheme.bodySmall,
              ),
            ],
          );
        }
        final peak = hist.peak;
        final lo = hist.binStart + peak * hist.binWidth;
        // Pace runs the other way: the faster edge reads first.
        final range = widget.pace
            ? '${spec.format(lo + hist.binWidth)} – ${spec.format(lo)}'
            : '${spec.format(lo)} – ${spec.format(lo + hist.binWidth)}';
        final share = (hist.seconds[peak] / hist.totalSeconds * 100).round();
        final minMax = widget.pace
            ? (spec.format(hist.max), spec.format(hist.min))
            : (spec.format(hist.min), spec.format(hist.max));

        return Column(
          key: const ValueKey('stat-peek'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            const SizedBox(height: 8),
            Wrap(
              spacing: 14,
              runSpacing: 4,
              children: [
                _Figure(label: l10n.statPeekMin, value: minMax.$1),
                _Figure(label: l10n.statPeekAvg, value: spec.format(hist.avg)),
                _Figure(label: l10n.statPeekMax, value: minMax.$2),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 90,
              child: CustomPaint(
                key: const ValueKey('stat-peek-histogram'),
                size: Size.infinite,
                painter: _HistogramPainter(
                  seconds: hist.seconds,
                  peak: peak,
                  color: widget.color,
                  baseline: scheme.outlineVariant,
                  reversed: widget.pace,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  widget.pace
                      ? spec.format(
                          hist.binStart + hist.seconds.length * hist.binWidth,
                        )
                      : spec.format(hist.binStart),
                  style: theme.textTheme.labelSmall,
                ),
                const Spacer(),
                Text(
                  widget.pace
                      ? spec.format(hist.binStart)
                      : spec.format(
                          hist.binStart + hist.seconds.length * hist.binWidth,
                        ),
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.statPeekMostTime(range, share),
              key: const ValueKey('stat-peek-peak'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            Text(
              l10n.statPeekRecorded(
                formatDurationSecs(hist.totalSeconds.round()),
              ),
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          TextSpan(
            text: value,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bars of time per bin, the most common one at full colour.
class _HistogramPainter extends CustomPainter {
  _HistogramPainter({
    required this.seconds,
    required this.peak,
    required this.color,
    required this.baseline,
    this.reversed = false,
  });

  final List<double> seconds;
  final int peak;
  final Color color;
  final Color baseline;

  /// Drawn right to left: for pace, the fastest bins sit on the left.
  final bool reversed;

  @override
  void paint(Canvas canvas, Size size) {
    final n = seconds.length;
    final top = seconds.reduce(math.max);
    if (n == 0 || top <= 0) return;
    final gap = n > 30 ? 1.0 : 2.0;
    final w = (size.width - gap * (n - 1)) / n;
    final paint = Paint();
    for (var i = 0; i < n; i++) {
      final slot = reversed ? n - 1 - i : i;
      final h = size.height * seconds[i] / top;
      final x = slot * (w + gap);
      paint.color = i == peak ? color : color.withValues(alpha: 0.45);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(x, size.height - h, w, h),
          topLeft: const Radius.circular(2),
          topRight: const Radius.circular(2),
        ),
        paint,
      );
    }
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      Paint()
        ..color = baseline
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_HistogramPainter old) =>
      old.seconds != seconds || old.peak != peak || old.color != color;
}
