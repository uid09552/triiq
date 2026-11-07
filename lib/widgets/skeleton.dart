import 'package:flutter/material.dart';

/// A grey placeholder block that pulses softly — what a screen shows in the
/// shape of its content while the data loads, instead of a lone spinner. Steady
/// (no pulse) when the system asks for reduced motion.
class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    this.width,
    this.height = 14,
    this.radius = 8,
    this.circle = false,
  });

  final double? width;
  final double height;
  final double radius;

  /// A round placeholder (an avatar or a ring); [height] is its diameter.
  final bool circle;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  bool _animating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce && _animating) {
      _controller.stop();
      _animating = false;
    } else if (!reduce && !_animating) {
      _controller.repeat(reverse: true);
      _animating = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return Semantics(
      label: 'loading',
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          // 8 % to 16 % of the text colour: a quiet shape in light and dark.
          final alpha =
              0.08 + 0.08 * Curves.easeInOut.transform(_controller.value);
          return Container(
            key: const ValueKey('skeleton'),
            width: widget.circle ? widget.height : widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: color.withValues(alpha: alpha),
              borderRadius: widget.circle
                  ? null
                  : BorderRadius.circular(widget.radius),
              shape: widget.circle ? BoxShape.circle : BoxShape.rectangle,
            ),
          );
        },
      ),
    );
  }
}

/// A card-shaped placeholder: a title line and a block, like a chart card.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.height = 150, this.lines = 0});

  /// Height of the content block under the title.
  final double height;

  /// Extra text lines under the block.
  final int lines;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Skeleton(height: 30, circle: true),
                SizedBox(width: 10),
                Skeleton(width: 140, height: 16),
              ],
            ),
            const SizedBox(height: 14),
            Skeleton(height: height, radius: 12),
            for (var i = 0; i < lines; i++) ...[
              const SizedBox(height: 10),
              Skeleton(width: i.isEven ? 220 : 160, height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

/// A whole loading screen: [cards] card placeholders in a column, in the
/// padding the real screens use.
class SkeletonScreen extends StatelessWidget {
  const SkeletonScreen({super.key, this.cards = 3, this.cardHeight = 150});

  final int cards;
  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('skeleton-screen'),
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (var i = 0; i < cards; i++) ...[
          SkeletonCard(height: cardHeight),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

/// List-row placeholders (an avatar, two lines), for list screens.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.rows = 8});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('skeleton-list'),
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (var i = 0; i < rows; i++)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Skeleton(height: 40, circle: true),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Skeleton(width: 180, height: 14),
                      SizedBox(height: 8),
                      Skeleton(width: 120, height: 11),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
