import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';

/// The visible slice of a chart's x-axis, in data-index space, with the
/// zoom and pan arithmetic every zoomable chart shares.
class ChartViewport extends ChangeNotifier {
  ChartViewport({int length = 0}) {
    _length = length;
    _hi = math.max(0, length - 1).toDouble();
  }

  int _length = 0;
  double _lo = 0;
  double _hi = 0;

  /// Fewest points a zoomed window may span.
  static const minPoints = 6;

  int get length => _length;
  double get lo => _lo;
  double get hi => _hi;
  double get span => _hi - _lo;
  double get fullSpan => math.max(0, _length - 1).toDouble();
  bool get isZoomed => span < fullSpan - 1e-9;

  /// Adopts a new data length; a changed length shows everything again.
  void setLength(int length) {
    if (length == _length) return;
    _length = length;
    _lo = 0;
    _hi = fullSpan;
    notifyListeners();
  }

  void reset() {
    if (!isZoomed) return;
    _lo = 0;
    _hi = fullSpan;
    notifyListeners();
  }

  /// Zooms by [factor] (>1 in) keeping the point at [fraction] (0..1 across
  /// the plot) where it is.
  void zoomAt(double factor, double fraction) {
    if (_length < 2 || factor <= 0) return;
    final minSpan = math.min(fullSpan, (minPoints - 1).toDouble());
    final newSpan = (span / factor).clamp(minSpan, fullSpan).toDouble();
    final anchor = _lo + fraction.clamp(0.0, 1.0) * span;
    _set(anchor - fraction.clamp(0.0, 1.0) * newSpan, newSpan);
  }

  /// Moves the window by [fraction] of its width (positive drags content
  /// right, so the window moves left).
  void panByFraction(double fraction) {
    if (!isZoomed) return;
    _set(_lo - fraction * span, span);
  }

  /// Shows exactly [from]..[to] (data indices), e.g. one interval.
  void setRange(double from, double to) {
    if (_length < 2) return;
    final minSpan = math.min(fullSpan, (minPoints - 1).toDouble());
    final newSpan = math
        .max(minSpan, to - from)
        .clamp(minSpan, fullSpan)
        .toDouble();
    final centre = (from + to) / 2;
    _set(centre - newSpan / 2, newSpan);
  }

  /// Moves the window so [index] is in its middle, keeping its width.
  void centerOn(double index) => _set(index - span / 2, span);

  /// Data index under [fraction] across the plot.
  double indexAt(double fraction) => _lo + fraction.clamp(0.0, 1.0) * span;

  void _set(double lo, double newSpan) {
    final double start = lo
        .clamp(0.0, math.max(0.0, fullSpan - newSpan))
        .toDouble();
    final end = start + newSpan;
    if ((start - _lo).abs() < 1e-12 && (end - _hi).abs() < 1e-12) return;
    _lo = start;
    _hi = end;
    notifyListeners();
  }
}

/// Touch, mouse and keyboard-modifier handling for a zoomable chart:
/// pinch to zoom, one finger to scrub (or pan once zoomed), double tap to
/// zoom in or back out, Ctrl + mouse wheel to zoom.
///
/// Uses a scale recognizer only, whose pan slop is larger than a vertical
/// scroll's, so a page scroll that starts on the chart still scrolls the
/// page.
class ChartInteraction extends StatefulWidget {
  const ChartInteraction({
    super.key,
    required this.viewport,
    required this.plotLeft,
    this.plotRight = 0,
    required this.child,
    this.onSelectAt,
    this.hoverSelects = false,
    this.zoomable = true,
  });

  final ChartViewport viewport;

  /// Pixels left of the plot (the y-axis labels).
  final double plotLeft;

  /// Pixels right of the plot (a second y-axis).
  final double plotRight;

  /// Called with the data index under the finger.
  final ValueChanged<int>? onSelectAt;

  /// A mouse moving over the chart selects like a tap does (desktop).
  final bool hoverSelects;
  final bool zoomable;
  final Widget child;

  @override
  State<ChartInteraction> createState() => _ChartInteractionState();
}

class _ChartInteractionState extends State<ChartInteraction> {
  double _lastScale = 1;
  Offset _doubleTapAt = Offset.zero;

  double _fraction(double dx, double width) {
    final plot = width - widget.plotLeft - widget.plotRight;
    return plot <= 0
        ? 0.0
        : ((dx - widget.plotLeft) / plot).clamp(0.0, 1.0).toDouble();
  }

  void _select(double dx, double width) {
    final select = widget.onSelectAt;
    final vp = widget.viewport;
    if (select == null || vp.length == 0) return;
    select(vp.indexAt(_fraction(dx, width)).round().clamp(0, vp.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final vp = widget.viewport;
        return MouseRegion(
          onHover: widget.hoverSelects
              ? (e) => _select(e.localPosition.dx, width)
              : null,
          child: Listener(
            // Select on touch-down rather than as a tap: a tap has to wait
            // out the double-tap (zoom) window first, which made every quick
            // tap on a chart lag by ~300 ms.
            onPointerDown: (e) {
              if (e.kind == PointerDeviceKind.mouse &&
                  e.buttons != kPrimaryMouseButton) {
                return;
              }
              _select(e.localPosition.dx, width);
            },
            onPointerSignal: (event) {
              if (!widget.zoomable ||
                  event is! PointerScrollEvent ||
                  !HardwareKeyboard.instance.isControlPressed) {
                return;
              }
              GestureBinding.instance.pointerSignalResolver.register(event, (
                e,
              ) {
                final scroll = e as PointerScrollEvent;
                vp.zoomAt(
                  math.exp(-scroll.scrollDelta.dy / 300),
                  _fraction(scroll.localPosition.dx, width),
                );
              });
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onDoubleTapDown: (d) => _doubleTapAt = d.localPosition,
              onDoubleTap: widget.zoomable
                  ? () => vp.isZoomed
                        ? vp.reset()
                        : vp.zoomAt(3, _fraction(_doubleTapAt.dx, width))
                  : null,
              onScaleStart: (_) => _lastScale = 1,
              onScaleUpdate: (d) {
                if (widget.zoomable && d.pointerCount >= 2) {
                  final factor = d.scale / _lastScale;
                  _lastScale = d.scale;
                  vp.zoomAt(factor, _fraction(d.localFocalPoint.dx, width));
                  vp.panByFraction(
                    d.focalPointDelta.dx /
                        math.max(1, width - widget.plotLeft - widget.plotRight),
                  );
                } else if (widget.zoomable && vp.isZoomed) {
                  vp.panByFraction(
                    d.focalPointDelta.dx /
                        math.max(1, width - widget.plotLeft - widget.plotRight),
                  );
                } else {
                  _select(d.localFocalPoint.dx, width);
                }
              },
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

/// Zoom in / out / reset buttons to float over a chart, for mouse users and
/// anyone who doesn't find the pinch.
class ZoomControls extends StatelessWidget {
  const ZoomControls({super.key, required this.viewport});

  final ChartViewport viewport;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    Widget button(IconData icon, String tooltip, VoidCallback? onTap) =>
        Tooltip(
          message: tooltip,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Icon(
                icon,
                size: 18,
                color: onTap == null
                    ? scheme.outlineVariant
                    : scheme.onSurfaceVariant,
              ),
            ),
          ),
        );
    return ListenableBuilder(
      listenable: viewport,
      builder: (context, _) => Material(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.85),
        shape: const StadiumBorder(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            button(
              Icons.add,
              l10n?.chartZoomIn ?? 'Zoom in',
              () => viewport.zoomAt(2, 0.5),
            ),
            button(
              Icons.remove,
              l10n?.chartZoomOut ?? 'Zoom out',
              viewport.isZoomed ? () => viewport.zoomAt(0.5, 0.5) : null,
            ),
            button(
              Icons.zoom_out_map,
              l10n?.chartZoomReset ?? 'Show all',
              viewport.isZoomed ? viewport.reset : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// A small "reset zoom" button to float over a zoomed chart.
class ZoomResetButton extends StatelessWidget {
  const ZoomResetButton({super.key, required this.viewport});

  final ChartViewport viewport;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewport,
      builder: (context, _) {
        if (!viewport.isZoomed) return const SizedBox.shrink();
        final scheme = Theme.of(context).colorScheme;
        return Material(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.9),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: viewport.reset,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.zoom_out_map,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Paints [from]→[to] as a dashed line.
void drawDashedLine(
  Canvas canvas,
  Offset from,
  Offset to,
  Paint paint, {
  double dash = 6,
  double gap = 4,
}) {
  final total = (to - from).distance;
  if (total <= 0) return;
  final dir = (to - from) / total;
  var travelled = 0.0;
  while (travelled < total) {
    final end = math.min(total, travelled + dash);
    canvas.drawLine(from + dir * travelled, from + dir * end, paint);
    travelled += dash + gap;
  }
}
