import 'package:flutter/material.dart';

/// One labelled figure in a peek card ("66" over "CTL").
class PeekFigure {
  const PeekFigure(this.label, this.value);

  final String label;
  final String value;
}

/// A row of small labelled figures, wrapping on a narrow card.
class PeekFigures extends StatelessWidget {
  const PeekFigures(this.figures, {super.key});

  final List<PeekFigure> figures;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 18,
      runSpacing: 6,
      children: [
        for (final f in figures)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                f.value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                f.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// A line of muted, italic text where a peek has nothing to draw.
class PeekHint extends StatelessWidget {
  const PeekHint(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontStyle: FontStyle.italic,
      ),
    ),
  );
}
