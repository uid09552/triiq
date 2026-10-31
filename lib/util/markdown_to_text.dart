/// Converts a subset of Markdown (headings, bold/italic, inline code,
/// links, bullet lists, blockquotes, and GFM tables) to plain text.
///
/// Google Calendar's "add event" description field has no Markdown
/// renderer — an agent reply pasted straight in shows up with literal
/// `**`, `#`, `|` and `---`. This strips that markup down to something a
/// calendar description actually reads well as; a table row becomes one
/// line with its cells joined by " · ".
String markdownToPlainText(String markdown) {
  final out = <String>[];

  for (final rawLine in markdown.split('\n')) {
    final trimmed = rawLine.trim();

    if (_isTableSeparatorRow(trimmed) || _horizontalRule.hasMatch(trimmed)) {
      continue;
    }

    if (trimmed.startsWith('|') && trimmed.endsWith('|') && trimmed.length > 1) {
      final cells = trimmed
          .substring(1, trimmed.length - 1)
          .split('|')
          .map((cell) => _stripInline(cell.trim()))
          .where((cell) => cell.isNotEmpty)
          .toList();
      if (cells.isNotEmpty) out.add(cells.join(' · '));
      continue;
    }

    var line = rawLine.replaceFirst(_heading, '');
    line = line.replaceFirst(_blockquote, '');
    line = line.replaceFirst(_bullet, '• ');
    out.add(_stripInline(line));
  }

  // Collapse runs of blank lines the row/heading removal above can leave
  // behind, so the description isn't padded with empty gaps.
  return out
      .join('\n')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
}

bool _isTableSeparatorRow(String trimmedLine) =>
    trimmedLine.isNotEmpty &&
    trimmedLine.contains('-') &&
    RegExp(r'^[\s\-:|]+$').hasMatch(trimmedLine);

final _horizontalRule = RegExp(r'^(-{3,}|\*{3,}|_{3,})$');
final _heading = RegExp(r'^#{1,6}\s+');
final _blockquote = RegExp(r'^>\s?');
final _bullet = RegExp(r'^[-*+]\s+');

/// Strips inline emphasis, inline code, and link syntax from one line —
/// what's left of Markdown once block-level structure (tables, headings,
/// lists) has already been handled.
String _stripInline(String text) => text
    .replaceAllMapped(RegExp(r'\*\*(.+?)\*\*'), (m) => m[1]!)
    .replaceAllMapped(RegExp(r'__(.+?)__'), (m) => m[1]!)
    .replaceAllMapped(RegExp(r'(?<!\*)\*(?!\*)(.+?)(?<!\*)\*(?!\*)'), (m) => m[1]!)
    .replaceAllMapped(RegExp(r'(?<!_)_(?!_)(.+?)(?<!_)_(?!_)'), (m) => m[1]!)
    .replaceAllMapped(RegExp(r'`([^`]+)`'), (m) => m[1]!)
    .replaceAllMapped(
      RegExp(r'\[([^\]]+)\]\(([^)]+)\)'),
      (m) => '${m[1]} (${m[2]})',
    );
