import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Press and hold [child] to peek: [preview] appears in a floating card
/// over a dimmed screen, and goes away again the moment the press ends —
/// by lifting the finger or the mouse button, or if the touch turns into a
/// scroll. A short tap still reaches [child] as usual, so a tile can open
/// its screen on tap and show a peek on hold.
///
/// The card sits above the child when there is room (a finger rests below),
/// else under it, and is kept inside the screen. It ignores pointer events,
/// so it can never take the press away from the finger holding it.
///
/// [HoverPreview] is the mouse-hover counterpart; this one is for the long
/// press, which touch has and hover does not.
class HoldPreview extends StatefulWidget {
  const HoldPreview({
    super.key,
    required this.child,
    required this.preview,
    this.width = 340,
    this.estimatedHeight = 240,
  });

  final Widget child;
  final WidgetBuilder preview;

  /// The card's width, at most (it keeps a 12 px margin on a narrow screen).
  final double width;

  /// About how tall the card gets, to decide whether it fits above [child].
  final double estimatedHeight;

  @override
  State<HoldPreview> createState() => _HoldPreviewState();
}

class _HoldPreviewState extends State<HoldPreview> {
  final _controller = OverlayPortalController();
  Rect _anchor = Rect.zero;
  Size _screen = Size.zero;

  void _show() {
    final box = context.findRenderObject() as RenderBox?;
    final overlay = Overlay.maybeOf(context)?.context.findRenderObject();
    if (box == null || !box.hasSize || overlay is! RenderBox) return;
    HapticFeedback.selectionClick();
    setState(() {
      _anchor = box.localToGlobal(Offset.zero, ancestor: overlay) & box.size;
      _screen = overlay.size;
    });
    _controller.show();
  }

  void _hide() {
    if (_controller.isShowing) _controller.hide();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPressStart: (_) => _show(),
      onLongPressEnd: (_) => _hide(),
      onLongPressCancel: _hide,
      child: OverlayPortal(
        controller: _controller,
        overlayChildBuilder: _overlay,
        child: widget.child,
      ),
    );
  }

  Widget _overlay(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final top = MediaQuery.paddingOf(context).top;
    final width = math.min(widget.width, _screen.width - 24);
    final left = (_anchor.center.dx - width / 2)
        .clamp(12.0, math.max(12.0, _screen.width - width - 12))
        .toDouble();
    final fitsAbove = _anchor.top - top - 8 >= widget.estimatedHeight;

    return Stack(
      key: const ValueKey('hold-preview'),
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: ColoredBox(color: Colors.black.withValues(alpha: 0.32)),
          ),
        ),
        Positioned(
          left: left,
          width: width,
          top: fitsAbove ? null : _anchor.bottom + 8,
          bottom: fitsAbove ? _screen.height - _anchor.top + 8 : null,
          child: IgnorePointer(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutCubic,
              builder: (context, t, child) => Opacity(
                opacity: t,
                child: Transform.scale(
                  scale: 0.94 + 0.06 * t,
                  alignment: fitsAbove
                      ? Alignment.bottomCenter
                      : Alignment.topCenter,
                  child: child,
                ),
              ),
              child: Material(
                elevation: 14,
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(20),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: widget.preview(context),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
