import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

/// Renders agent output as formatted markdown — headings, lists, and
/// GitHub-flavoured tables — instead of showing the raw source, with a
/// table style that reads as a small card rather than bare grid lines.
class MarkdownReply extends StatelessWidget {
  const MarkdownReply({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MarkdownBody(
      data: text,
      selectable: true,
      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
        p: theme.textTheme.bodyMedium,
        code: theme.textTheme.bodySmall?.copyWith(
          fontFamily: 'monospace',
          backgroundColor: colorScheme.surfaceContainerHighest,
        ),
        codeblockDecoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        blockquoteDecoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(color: colorScheme.primary, width: 3),
          ),
        ),
        tableBorder: TableBorder.all(
          color: colorScheme.outlineVariant,
          width: 1,
          borderRadius: BorderRadius.circular(8),
        ),
        tableHead: const TextStyle(fontWeight: FontWeight.w700),
        tableHeadAlign: TextAlign.left,
        tableCellsPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        tableCellsDecoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
        ),
      ),
    );
  }
}
