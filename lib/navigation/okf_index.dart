import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../plan/knowledge.dart' show knowledgeAssetPath;

/// The user-facing part of `docs/okf.md`, split into passages a destination
/// can point at (see `AppDestination.okfAnchor`).
///
/// okf.md is already bundled as an asset (the plan engine reads its section
/// 5), so this reads the same file at runtime — no derived copy to keep in
/// sync. Only two parts of it are indexed, the ones written for athletes:
///
/// - the **status matrix** of section 1 (`| Area | Status |`), one passage
///   per row — anchor `status:<area prefix>`;
/// - **section 3, "User documentation"**, one passage per `###` / `####`
///   heading — anchor `<heading>` — and, inside a heading, one passage per
///   paragraph or bullet that opens with a bold term — anchor
///   `<heading>#<bold term>`.
///
/// Architecture (section 2), known gaps (4) and training knowledge (5) are
/// developer or plan-engine material and are never indexed. What is indexed
/// still mentions source files now and then; [userText] strips those.
class OkfIndex {
  OkfIndex._(this._headings, this._blocks, this._status);

  /// Heading text → its body (everything up to the next heading).
  final Map<String, String> _headings;

  /// Heading text → its bold-led paragraphs and bullets.
  final Map<String, List<String>> _blocks;

  /// Status-matrix area cell → status cell.
  final Map<String, String> _status;

  static Future<OkfIndex>? _cached;

  /// The bundled okf.md, parsed once per app run.
  static Future<OkfIndex> load() => _cached ??= rootBundle
      .loadString(knowledgeAssetPath)
      .then(OkfIndex.parse)
      .catchError((Object error) {
        _cached = null; // Try again next time.
        throw error;
      });

  /// Every anchor this index can resolve — for tests and the agent's
  /// "nothing matched" hint.
  Iterable<String> get headings => _headings.keys;

  factory OkfIndex.parse(String document) {
    final lines = const LineSplitter().convert(document);
    final headings = <String, String>{};
    final blocks = <String, List<String>>{};
    final status = <String, String>{};

    var inStatus = false;
    var inUserDocs = false;
    String? heading;
    final body = StringBuffer();

    void flush() {
      final h = heading;
      if (h != null) {
        final text = body.toString().trim();
        headings.putIfAbsent(h, () => text);
        blocks.putIfAbsent(h, () => _boldBlocks(text));
      }
      heading = null;
      body.clear();
    }

    for (final line in lines) {
      if (line.startsWith('## ')) {
        flush();
        inUserDocs = line.startsWith('## 3.');
        inStatus = false;
        continue;
      }
      if (line.startsWith('### ') || line.startsWith('#### ')) {
        flush();
        final title = line.replaceFirst(RegExp(r'^#+ '), '').trim();
        inStatus = title == 'Status matrix';
        if (inUserDocs) heading = title;
        continue;
      }
      if (inStatus && line.startsWith('| ')) {
        final cells = line.split('|');
        if (cells.length < 4) continue;
        final area = cells[1].trim();
        if (area == 'Area' || area.startsWith('---')) continue;
        status[area] = cells.sublist(2, cells.length - 1).join('|').trim();
        continue;
      }
      if (heading != null) body.writeln(line);
    }
    flush();
    return OkfIndex._(headings, blocks, status);
  }

  /// Paragraphs and top-level bullets of [text] that open with `**`.
  static List<String> _boldBlocks(String text) {
    final result = <String>[];
    final current = StringBuffer();
    void end() {
      final block = current.toString().trim();
      if (block.startsWith('**')) result.add(block);
      current.clear();
    }

    for (final line in const LineSplitter().convert(text)) {
      if (line.trim().isEmpty) {
        end();
      } else if (line.startsWith('- ')) {
        end();
        current.writeln(line.substring(2));
      } else {
        current.writeln(line);
      }
    }
    end();
    return result;
  }

  /// The raw passage [anchor] points at, or null if it points nowhere.
  String? resolve(String anchor) {
    if (anchor.startsWith('status:')) {
      final prefix = anchor.substring('status:'.length);
      for (final entry in _status.entries) {
        if (entry.key.startsWith(prefix)) {
          return '${entry.key}: ${entry.value}';
        }
      }
      return null;
    }
    final hash = anchor.indexOf('#');
    if (hash < 0) return _headings[anchor];
    final bold = '**${anchor.substring(hash + 1)}';
    for (final block in _blocks[anchor.substring(0, hash)] ?? const []) {
      if (block.startsWith(bold)) return block;
    }
    return null;
  }

  /// [anchor]'s passage as plain text for an athlete: no markdown, no
  /// source-file references, at most [maxChars] (cut at a sentence end
  /// where one is close). Empty when the anchor resolves to nothing.
  String excerpt(String anchor, {int maxChars = 600}) =>
      trimToSentence(userText(resolve(anchor) ?? ''), maxChars);

  /// Strips what only a developer needs: parentheticals and code spans that
  /// name source files, markdown emphasis, the status prefix.
  static String userText(String raw) {
    var text = raw;
    final codeRef = r'`[^`]*(?:lib/|test/|\.dart|\.yml|\.md)[^`]*`';
    text = text.replaceAll(RegExp(r'\s*\([^()]*' + codeRef + r'[^()]*\)'), '');
    text = text.replaceAll(RegExp(r'\s*' + codeRef), '');
    text = text
        .replaceAll('✅ Implemented — ', '')
        .replaceAll('✅ Implemented', '')
        .replaceAll('**', '')
        .replaceAll(RegExp(r'(?<![\w*])\*(?!\s)|(?<!\s)\*(?![\w*])'), '')
        .replaceAll('`', '')
        .replaceAll(RegExp(r'\s+'), ' ');
    return text.trim();
  }

  static String trimToSentence(String text, int maxChars) {
    if (text.length <= maxChars) return text;
    final cut = text.substring(0, maxChars);
    final end = cut.lastIndexOf(RegExp(r'[.!?;] '));
    if (end > maxChars ~/ 2) return cut.substring(0, end + 1);
    final space = cut.lastIndexOf(' ');
    return '${cut.substring(0, space > 0 ? space : maxChars)}…';
  }
}
