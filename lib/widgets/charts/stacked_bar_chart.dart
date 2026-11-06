import 'package:flutter/material.dart';

/// One column of a [StackedBarChart]: segment values, bottom to top, in the
/// order of the chart's colours.
class StackedBar {
  const StackedBar({required this.label, required this.values});

  final String label;
  final List<double> values;

  double get total => values.fold(0, (a, b) => a + b);
}

/// A tappable stacked bar chart. With [normalize] every bar fills the full
/// height and shows shares (intensity split); without, heights are absolute
/// against the tallest bar (load per week).
///
/// Built from plain boxes rather than a painter: the segments are few and the
/// tap target is the whole column, which is what a finger wants on a phone.
class StackedBarChart extends StatelessWidget {
  const StackedBarChart({
    super.key,
    required this.bars,
    required this.colors,
    this.normalize = false,
    this.selectedIndex,
    this.onSelect,
    this.labelEvery = 1,
    this.height = 180,
  });

  final List<StackedBar> bars;
  final List<Color> colors;
  final bool normalize;
  final int? selectedIndex;
  final ValueChanged<int>? onSelect;
  final int labelEvery;
  final double height;

  static const _labelHeight = 18.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxTotal = bars.fold<double>(0, (m, b) => b.total > m ? b.total : m);
    final plotHeight = height - _labelHeight;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < bars.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onSelect == null ? null : () => onSelect!(i),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: bars.length > 40 ? 0.5 : 1.5,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: plotHeight,
                        child: _Column(
                          bar: bars[i],
                          colors: colors,
                          scale: normalize
                              ? (bars[i].total == 0
                                    ? 0
                                    : plotHeight / bars[i].total)
                              : (maxTotal == 0 ? 0 : plotHeight / maxTotal),
                          selected: selectedIndex == i,
                          dimmed: selectedIndex != null && selectedIndex != i,
                        ),
                      ),
                      SizedBox(
                        height: _labelHeight,
                        child: i % labelEvery == 0
                            ? OverflowBox(
                                maxWidth: 60,
                                child: Text(
                                  bars[i].label,
                                  maxLines: 1,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Column extends StatelessWidget {
  const _Column({
    required this.bar,
    required this.colors,
    required this.scale,
    required this.selected,
    required this.dimmed,
  });

  final StackedBar bar;
  final List<Color> colors;
  final double scale;
  final bool selected;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Opacity(
        opacity: dimmed ? 0.45 : 1,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.up,
            children: [
              for (var s = 0; s < bar.values.length; s++)
                if (bar.values[s] > 0)
                  Container(
                    height: bar.values[s] * scale,
                    color: colors[s % colors.length],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dot-and-label legend for a stacked chart.
class StackedLegend extends StatelessWidget {
  const StackedLegend({super.key, required this.labels, required this.colors});

  final List<String> labels;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        for (var i = 0; i < labels.length; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: colors[i],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(labels[i], style: style),
            ],
          ),
      ],
    );
  }
}
