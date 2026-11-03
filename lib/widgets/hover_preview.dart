import 'dart:async';

import 'package:flutter/material.dart';

/// Shows [preview] in a floating card next to [child] once a mouse pointer
/// has rested on it for [delay], and hides it when the pointer leaves.
///
/// Mouse and stylus only — a finger never "hovers" — so touch devices get
/// the same content from the long-press sheet instead. The card ignores
/// pointer events, so it can never steal the hover that keeps it open.
class HoverPreview extends StatefulWidget {
  const HoverPreview({
    super.key,
    required this.child,
    required this.preview,
    this.delay = const Duration(milliseconds: 350),
    this.width = 280,
  });

  final Widget child;
  final WidgetBuilder preview;
  final Duration delay;
  final double width;

  @override
  State<HoverPreview> createState() => _HoverPreviewState();
}

class _HoverPreviewState extends State<HoverPreview> {
  final _controller = OverlayPortalController();
  final _link = LayerLink();
  Timer? _timer;
  bool _alignRight = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _enter() {
    _timer?.cancel();
    _timer = Timer(widget.delay, () {
      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      final screenWidth = MediaQuery.sizeOf(context).width;
      if (box != null && box.hasSize) {
        final centre = box.localToGlobal(box.size.center(Offset.zero)).dx;
        _alignRight = centre > screenWidth / 2;
      }
      _controller.show();
    });
  }

  void _exit() {
    _timer?.cancel();
    if (_controller.isShowing) _controller.hide();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _enter(),
      onExit: (_) => _exit(),
      child: CompositedTransformTarget(
        link: _link,
        child: OverlayPortal(
          controller: _controller,
          overlayChildBuilder: (context) {
            final scheme = Theme.of(context).colorScheme;
            return Align(
              alignment: Alignment.topLeft,
              child: CompositedTransformFollower(
                link: _link,
                showWhenUnlinked: false,
                targetAnchor: _alignRight
                    ? Alignment.bottomRight
                    : Alignment.bottomLeft,
                followerAnchor: _alignRight
                    ? Alignment.topRight
                    : Alignment.topLeft,
                offset: const Offset(0, 6),
                child: IgnorePointer(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOutCubic,
                    builder: (context, t, child) => Opacity(
                      opacity: t,
                      child: Transform.translate(
                        offset: Offset(0, (1 - t) * -4),
                        child: child,
                      ),
                    ),
                    child: Material(
                      elevation: 8,
                      color: scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                      clipBehavior: Clip.antiAlias,
                      child: SizedBox(
                        width: widget.width,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: widget.preview(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}
