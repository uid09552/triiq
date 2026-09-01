import 'package:flutter/material.dart';

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
  });

  final String label;
  final String value;

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = color ?? colorScheme.primary;

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
