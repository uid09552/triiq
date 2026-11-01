import 'dart:convert';

/// A titled section of a coaching reference document — a level-1 (`#`)
/// heading as [title], everything until the next one (or the end of the
/// document) as [body]. Shared by the bundled reference loader and the
/// knowledge-library importer, so both split on the same rule.
class GuidanceSection {
  const GuidanceSection(this.title, this.body);

  final String title;
  final String body;

  /// Heading matches count for more than body matches: a section titled
  /// "Recovery Weeks" is a better answer to "recovery week" than one that
  /// merely mentions the phrase.
  int score(List<String> terms) {
    final lowerTitle = title.toLowerCase();
    final lowerBody = body.toLowerCase();
    var total = 0;
    for (final term in terms) {
      if (lowerTitle.contains(term)) total += 5;
      total += term.allMatches(lowerBody).length.clamp(0, 5);
    }
    return total;
  }
}

/// Splits [document] into sections at level-1 `#` headings. A document with
/// no `#` heading at all becomes a single section titled [fallbackTitle],
/// unless it has no usable text either, in which case there are no
/// sections.
List<GuidanceSection> splitGuidanceSections(
  String document, {
  required String fallbackTitle,
}) {
  final sections = <GuidanceSection>[];
  String? title;
  final body = StringBuffer();

  void flush() {
    final current = title;
    if (current != null && body.isNotEmpty) {
      sections.add(GuidanceSection(current, body.toString().trim()));
    }
    body.clear();
  }

  for (final line in const LineSplitter().convert(document)) {
    if (line.startsWith('# ')) {
      flush();
      title = line.substring(2).trim();
    } else if (title != null) {
      body.writeln(line);
    }
  }
  flush();

  if (sections.isEmpty) {
    final whole = document.trim();
    if (whole.isNotEmpty) {
      sections.add(GuidanceSection(fallbackTitle, whole));
    }
  }
  return sections;
}

/// Strips fenced blocks whose info string starts with `okf-` (plan rules,
/// goals, session templates) out of imported text. Imported documents are
/// agent-only — these blocks must never reach the plan engine. Returns the
/// cleaned text and how many blocks were dropped. A fence that never closes
/// is left as plain text rather than guessed at.
({String text, int ignoredBlocks}) stripOkfFences(String input) {
  final normalized = input.replaceAll('\r\n', '\n');
  final fence = RegExp(
    r'^```okf-[^\n`]*[ \t]*\n.*?\n```[ \t]*$',
    multiLine: true,
    dotAll: true,
  );
  var count = 0;
  final cleaned = normalized.replaceAllMapped(fence, (match) {
    count++;
    return '';
  });
  return (text: cleaned, ignoredBlocks: count);
}
