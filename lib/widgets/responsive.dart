import 'package:flutter/material.dart';

/// Lays [children] out one under the other on a phone, and two side by
/// side from [twoColumnWidth] — charts on Insights, for instance, so a wide
/// Windows window isn't one stretched column.
class ResponsiveColumns extends StatelessWidget {
  const ResponsiveColumns({
    super.key,
    required this.children,
    this.twoColumnWidth = 900,
    this.spacing = 16,
  });

  final List<Widget> children;
  final double twoColumnWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < twoColumnWidth) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) SizedBox(height: spacing),
              children[i],
            ],
          ],
        );
      }
      return Column(
        key: const ValueKey('responsive-two-columns'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i += 2) ...[
            if (i > 0) SizedBox(height: spacing),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: children[i]),
                SizedBox(width: spacing),
                Expanded(
                  child: i + 1 < children.length
                      ? children[i + 1]
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ],
        ],
      );
    },
  );
}

/// Caps the width of a screen's content and centres it, so lines stay
/// readable on a wide window. Phones are narrower than the cap: no change.
class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child, this.maxWidth = 1000});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}
