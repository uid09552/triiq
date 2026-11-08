import 'package:flutter/material.dart';

/// A titled card used to group related content on a screen. Optionally
/// shows a leading icon badge and a trailing widget in the header row.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.trailing,
    this.onLongPress,
    this.collapsed,
    this.onToggleCollapsed,
  });

  final String title;
  final Widget child;
  final IconData? icon;
  final Widget? trailing;

  /// Long-press on the header, e.g. to open the card's chart options.
  final VoidCallback? onLongPress;

  /// Set (with [onToggleCollapsed]) to make the card foldable: a tap on the
  /// header folds it down to the header or opens it again.
  final bool? collapsed;
  final VoidCallback? onToggleCollapsed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foldable = collapsed != null && onToggleCollapsed != null;
    final isCollapsed = foldable && collapsed!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onLongPress: onLongPress,
              onTap: onToggleCollapsed,
              child: Row(
                children: [
                  if (icon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, size: 18, color: colorScheme.primary),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  ?trailing,
                  if (foldable)
                    Semantics(
                      button: true,
                      label: title,
                      expanded: !isCollapsed,
                      child: Icon(
                        isCollapsed ? Icons.expand_more : Icons.expand_less,
                        key: const ValueKey('section-fold'),
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (!isCollapsed) ...[const SizedBox(height: 12), child],
          ],
        ),
      ),
    );
  }
}
