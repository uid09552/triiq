import 'package:flutter/material.dart';

/// One shared pulse for every placeholder below it: a single animation
/// drives all the blocks of a loading screen, instead of a ticker per block.
/// Steady (no pulse) when the system asks for reduced motion.
class SkeletonPulse extends StatefulWidget {
  const SkeletonPulse({super.key, required this.child});

  final Widget child;

  /// The pulse of the nearest [SkeletonPulse], or null when there is none.
  static Animation<double>? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_PulseScope>()?.animation;

  @override
  State<SkeletonPulse> createState() => _SkeletonPulseState();
}

class _SkeletonPulseState extends State<SkeletonPulse>
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
  Widget build(BuildContext context) =>
      _PulseScope(animation: _controller, child: widget.child);
}

class _PulseScope extends InheritedWidget {
  const _PulseScope({required this.animation, required super.child});

  final Animation<double> animation;

  @override
  bool updateShouldNotify(_PulseScope old) => old.animation != animation;
}

/// A grey placeholder block that pulses softly — what a screen shows in the
/// shape of its content while the data loads, instead of a lone spinner. It
/// follows the nearest [SkeletonPulse]; on its own it brings one along.
class Skeleton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final pulse = SkeletonPulse.maybeOf(context);
    if (pulse == null) return SkeletonPulse(child: this);
    final color = Theme.of(context).colorScheme.onSurface;
    return Semantics(
      label: 'loading',
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: pulse,
        builder: (context, _) {
          // 8 % to 16 % of the text colour: a quiet shape in light and dark.
          final alpha = 0.08 + 0.08 * Curves.easeInOut.transform(pulse.value);
          return Container(
            key: const ValueKey('skeleton'),
            width: circle ? height : width,
            height: height,
            decoration: BoxDecoration(
              color: color.withValues(alpha: alpha),
              borderRadius: circle ? null : BorderRadius.circular(radius),
              shape: circle ? BoxShape.circle : BoxShape.rectangle,
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
    return SkeletonPulse(
      child: Card(
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
    return SkeletonPulse(
      child: ListView(
        key: const ValueKey('skeleton-screen'),
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (var i = 0; i < cards; i++) ...[
            SkeletonCard(height: cardHeight),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

/// List-row placeholders (an avatar, two lines), for list screens.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.rows = 8});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: ListView(
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
      ),
    );
  }
}
