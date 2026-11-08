import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

/// Renders agent output as formatted markdown with the app's own look:
///
///  * `##` headings get an accent bar, `###` headings become small
///    letter-spaced eyebrow labels, `#` a heavier title with a rule under it;
///  * bullets are small accent diamonds, numbered lists get round badges;
///  * tables read as one rounded card — an accent header row over softly
///    tinted rows;
///  * quotes are callouts, rules fade out at both ends, inline code is a
///    pill.
///
/// Used for the agent's chat replies, Train-now proposals and the weekly
/// review, so all of them share one typographic voice.
class MarkdownReply extends StatelessWidget {
  const MarkdownReply({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final body = textTheme.bodyMedium?.copyWith(height: 1.5);

    return MarkdownBody(
      data: text,
      selectable: true,
      // A single newline is a line break: the agent writes "**Load:** …"
      // and "**Why:** …" on separate lines.
      softLineBreak: true,
      extensionSet: md.ExtensionSet.gitHubFlavored,
      builders: {
        'h1': _HeadingBuilder(_HeadingLevel.title),
        'h2': _HeadingBuilder(_HeadingLevel.section),
        'h3': _HeadingBuilder(_HeadingLevel.eyebrow),
      },
      bulletBuilder: (parameters) => _Bullet(parameters),
      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
        p: body,
        pPadding: const EdgeInsets.only(bottom: 2),
        strong: body?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        em: body?.copyWith(
          fontStyle: FontStyle.italic,
          color: scheme.onSurfaceVariant,
        ),
        a: body?.copyWith(
          color: scheme.primary,
          decoration: TextDecoration.underline,
          decorationColor: scheme.primary.withValues(alpha: 0.4),
        ),
        listBulletPadding: const EdgeInsets.only(right: 8),
        listIndent: 22,
        blockSpacing: 12,
        code: textTheme.bodySmall?.copyWith(
          fontFamily: 'monospace',
          color: scheme.onSecondaryContainer,
          backgroundColor: scheme.secondaryContainer.withValues(alpha: 0.6),
        ),
        codeblockPadding: const EdgeInsets.all(12),
        codeblockDecoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outlineVariant),
        ),
        blockquotePadding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
        blockquoteDecoration: BoxDecoration(
          color: scheme.primaryContainer.withValues(alpha: 0.45),
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(12),
          ),
          border: Border(left: BorderSide(color: scheme.primary, width: 4)),
        ),
        horizontalRuleDecoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              scheme.outlineVariant.withValues(alpha: 0),
              scheme.outlineVariant,
              scheme.outlineVariant.withValues(alpha: 0),
            ],
          ),
        ),
        tableBorder: TableBorder.all(
          color: scheme.outlineVariant.withValues(alpha: 0.7),
          width: 1,
          borderRadius: BorderRadius.circular(12),
        ),
        tableHead: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: scheme.primary,
        ),
        tableHeadAlign: TextAlign.left,
        tableBody: textTheme.bodySmall?.copyWith(height: 1.4),
        tableColumnWidth: const FlexColumnWidth(),
        tableCellsPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 9,
        ),
        tableCellsDecoration: BoxDecoration(color: scheme.surfaceContainerLow),
        tableVerticalAlignment: TableCellVerticalAlignment.top,
      ),
    );
  }
}

enum _HeadingLevel { title, section, eyebrow }

/// `#`, `##` and `###` as the app's own heading shapes. Headings hold plain
/// text, so the element's text is enough.
class _HeadingBuilder extends MarkdownElementBuilder {
  _HeadingBuilder(this.level);

  final _HeadingLevel level;

  @override
  bool isBlockElement() => true;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = element.textContent.trim();

    switch (level) {
      case _HeadingLevel.title:
        return Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                text,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 44,
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [scheme.primary, scheme.tertiary],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        );
      case _HeadingLevel.section:
        return Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [scheme.primary, scheme.tertiary],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SelectableText(
                  text,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
        );
      case _HeadingLevel.eyebrow:
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: SelectableText(
            text.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.3,
              color: scheme.primary,
            ),
          ),
        );
    }
  }
}

/// A list marker: a small accent diamond (lighter when nested), or the
/// number in a round badge.
class _Bullet extends StatelessWidget {
  const _Bullet(this.parameters);

  final MarkdownBulletParameters parameters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (parameters.style == BulletStyle.orderedList) {
      return Align(
        alignment: Alignment.topLeft,
        child: Container(
          width: 22,
          height: 22,
          margin: const EdgeInsets.only(top: 1),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Text(
            '${parameters.index + 1}',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.onPrimaryContainer,
              height: 1,
            ),
          ),
        ),
      );
    }

    final nested = parameters.nestLevel > 0;
    final size = nested ? 5.0 : 7.0;
    // Align loosens the tight width the list gives its marker column, so
    // the diamond keeps its own size.
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, left: 5),
        child: Transform.rotate(
          angle: 0.785398,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: nested ? scheme.tertiary : scheme.primary,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ),
      ),
    );
  }
}
