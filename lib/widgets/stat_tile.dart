import 'package:flutter/material.dart';

import 'hover_preview.dart';

/// Which way a metric is heading, for the arrow beside a tile's sparkline.
enum StatTrend { up, down, flat }

/// A compact, colour-accented metric tile (e.g. TSS, CTL, ATL, distance).
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    this.icon,
    this.color,
    this.onTap,
    this.onLongPress,
    this.compact = false,
    this.hoverPreview,
    this.sparkValues,
    this.trend,
  });

  final String label;
  final String value;

  /// Recent values drawn as a tiny chart inside a [compact] tile, with
  /// [trend] as an arrow beside it. Both must be given to show either.
  final List<double>? sparkValues;
  final StatTrend? trend;

  /// An optional second line under the label — a comparison the number
  /// alone doesn't carry ("of 420 planned", "+3.1 in 7 days").
  final String? subtitle;

  final IconData? icon;

  /// Accent colour for the icon badge; defaults to the theme's primary.
  final Color? color;

  /// Makes the tile tappable, e.g. to drill into a detail/history view.
  final VoidCallback? onTap;

  /// Long-press action, e.g. offering to open the same figure on
  /// intervals.icu.
  final VoidCallback? onLongPress;

  /// A smaller, horizontal layout with soft animations — for dense grids
  /// such as Today's load tiles.
  final bool compact;

  /// Content shown in a floating card when a mouse rests on the tile.
  final WidgetBuilder? hoverPreview;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = color ?? colorScheme.primary;

    if (compact) {
      final tile = _CompactStatTile(
        label: label,
        value: value,
        subtitle: subtitle,
        icon: icon,
        accent: accent,
        onTap: onTap,
        onLongPress: onLongPress,
        sparkValues: sparkValues,
        trend: trend,
      );
      final preview = hoverPreview;
      return preview == null
          ? tile
          : HoverPreview(preview: preview, child: tile);
    }

    return Card(
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
          child: Column(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: accent),
                ),
                const SizedBox(height: 10),
              ],
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactStatTile extends StatefulWidget {
  const _CompactStatTile({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
    required this.onLongPress,
    this.sparkValues,
    this.trend,
  });

  final List<double>? sparkValues;
  final StatTrend? trend;
  final String label;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color accent;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  State<_CompactStatTile> createState() => _CompactStatTileState();
}

class _CompactStatTileState extends State<_CompactStatTile> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = widget.accent;
    const radius = BorderRadius.all(Radius.circular(16));

    return AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: _hovered
              ? Color.alphaBlend(
                  accent.withValues(alpha: 0.06),
                  scheme.surfaceContainerLow,
                )
              : scheme.surfaceContainerLow,
          borderRadius: radius,
          border: Border.all(
            color: accent.withValues(alpha: _hovered ? 0.45 : 0.14),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hovered ? 0.10 : 0.03),
              blurRadius: _hovered ? 10 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            onHover: (v) => setState(() => _hovered = v),
            onHighlightChanged: (v) => setState(() => _pressed = v),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(widget.icon, size: 16, color: accent),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          switchInCurve: Curves.easeOutCubic,
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween(
                                    begin: const Offset(0, 0.3),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              ),
                          layoutBuilder: (current, previous) => Stack(
                            alignment: Alignment.centerLeft,
                            children: [...previous, ?current],
                          ),
                          child: FittedBox(
                            key: ValueKey(widget.value),
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.value,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ),
                        if (widget.subtitle != null)
                          Text(
                            widget.subtitle!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  if (widget.sparkValues != null &&
                      widget.sparkValues!.length >= 2 &&
                      widget.trend != null) ...[
                    const SizedBox(width: 6),
                    _TileSpark(
                      key: const ValueKey('tile-spark'),
                      values: widget.sparkValues!,
                      trend: widget.trend!,
                      color: accent,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A 44×18 line with its last point marked, and a small arrow for the
/// trend above it.
class _TileSpark extends StatelessWidget {
  const _TileSpark({
    super.key,
    required this.values,
    required this.trend,
    required this.color,
  });

  final List<double> values;
  final StatTrend trend;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final icon = switch (trend) {
      StatTrend.up => Icons.arrow_upward_rounded,
      StatTrend.down => Icons.arrow_downward_rounded,
      StatTrend.flat => Icons.arrow_forward_rounded,
    };
    return Semantics(
      label: switch (trend) {
        StatTrend.up => 'trend rising',
        StatTrend.down => 'trend falling',
        StatTrend.flat => 'trend steady',
      },
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(icon, key: ValueKey('tile-trend-${trend.name}'), size: 13, color: color),
          const SizedBox(height: 2),
          SizedBox(
            width: 44,
            height: 18,
            child: CustomPaint(painter: _SparkPainter(values, color)),
          ),
        ],
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.values, this.color);

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    var lo = values.reduce((a, b) => a < b ? a : b);
    var hi = values.reduce((a, b) => a > b ? a : b);
    if (hi - lo < 1e-9) {
      lo -= 1;
      hi += 1;
    }
    const pad = 2.0;
    Offset at(int i) => Offset(
      pad + (size.width - 2 * pad) * i / (values.length - 1),
      pad + (size.height - 2 * pad) * (1 - (values[i] - lo) / (hi - lo)),
    );
    final path = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < values.length; i++) {
      path.lineTo(at(i).dx, at(i).dy);
    }
    final fill = Path.from(path)
      ..lineTo(at(values.length - 1).dx, size.height)
      ..lineTo(at(0).dx, size.height)
      ..close();
    canvas.drawPath(fill, Paint()..color = color.withValues(alpha: 0.12));
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(at(values.length - 1), 2.2, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SparkPainter old) =>
      old.color != color || !_same(old.values, values);

  static bool _same(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
