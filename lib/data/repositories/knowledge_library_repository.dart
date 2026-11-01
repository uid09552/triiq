import 'dart:convert';

import '../../agent/knowledge_sections.dart';
import '../../util/dates.dart';
import '../db/app_database.dart';

/// What to do when an import's file name matches an existing document.
enum KnowledgeDuplicateAction { replace, keepBoth }

/// A file the athlete picked that couldn't be imported — too large, not
/// UTF-8 text, or empty once `okf-*` fences are stripped. [message] is
/// shown to the athlete as-is.
class KnowledgeRejectedImport implements Exception {
  const KnowledgeRejectedImport(this.message);

  final String message;

  @override
  String toString() => message;
}

/// An imported coaching document — agent-only reference material, never
/// read by the plan engine.
class KnowledgeDocument {
  const KnowledgeDocument({
    required this.id,
    required this.title,
    required this.fileName,
    required this.importedAt,
    required this.enabled,
    required this.byteSize,
    required this.sectionCount,
  });

  final int id;
  final String title;
  final String fileName;
  final DateTime importedAt;
  final bool enabled;
  final int byteSize;
  final int sectionCount;
}

/// One section plus the title of the document it came from — what the
/// agent's guidance search merges with the bundled reference.
class KnowledgeMatchSection {
  const KnowledgeMatchSection({required this.document, required this.section});

  final String document;
  final GuidanceSection section;
}

class KnowledgeImportResult {
  const KnowledgeImportResult({
    required this.document,
    required this.ignoredBlocks,
  });

  final KnowledgeDocument document;

  /// How many `okf-*` fenced blocks were dropped from the imported text.
  final int ignoredBlocks;
}

/// Imports, lists, enables/disables and deletes athlete-supplied coaching
/// documents. Splitting happens once at import time (see
/// `splitGuidanceSections`), so search over them stays cheap; `okf-*`
/// fences are always stripped first (`stripOkfFences`) so imported text can
/// never reach the plan engine.
class KnowledgeLibraryRepository {
  KnowledgeLibraryRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  /// 512 KB — large enough for a long guide, small enough that one
  /// document can't dominate search.
  static const maxBytes = 512 * 1024;

  Future<List<KnowledgeDocument>> list() async {
    final db = await _database.database;
    final rows = await db.rawQuery('''
      SELECT d.id, d.title, d.file_name, d.imported_at, d.enabled, d.byte_size,
             COUNT(s.id) AS section_count
      FROM knowledge_docs d
      LEFT JOIN knowledge_sections s ON s.doc_id = d.id
      GROUP BY d.id
      ORDER BY d.imported_at DESC
    ''');
    return rows.map(_documentFromMap).toList();
  }

  /// The most recently imported document with this exact file name, or
  /// `null`. The UI calls this before [import] to decide whether to ask
  /// replace-or-keep-both.
  Future<KnowledgeDocument?> findByFileName(String fileName) async {
    final db = await _database.database;
    final rows = await db.rawQuery(
      '''
      SELECT d.id, d.title, d.file_name, d.imported_at, d.enabled, d.byte_size,
             COUNT(s.id) AS section_count
      FROM knowledge_docs d
      LEFT JOIN knowledge_sections s ON s.doc_id = d.id
      WHERE d.file_name = ?
      GROUP BY d.id
      ORDER BY d.imported_at DESC
      LIMIT 1
      ''',
      [fileName],
    );
    return rows.isEmpty ? null : _documentFromMap(rows.first);
  }

  /// Imports [bytes] as [fileName]. Throws [KnowledgeRejectedImport] for a
  /// file over [maxBytes], not valid UTF-8, or with no usable text once
  /// `okf-*` fences are stripped — the library is left unchanged in every
  /// rejection case.
  ///
  /// [duplicateAction] decides what happens when a document with the same
  /// [fileName] already exists: required in that case (passing `null`
  /// rejects the import instead of guessing), ignored otherwise.
  Future<KnowledgeImportResult> import({
    required String fileName,
    required List<int> bytes,
    KnowledgeDuplicateAction? duplicateAction,
  }) async {
    if (bytes.length > maxBytes) {
      throw KnowledgeRejectedImport(
        'File is larger than the ${maxBytes ~/ 1024} KB limit.',
      );
    }
    final String decoded;
    try {
      decoded = utf8.decode(bytes, allowMalformed: false);
    } on FormatException {
      throw const KnowledgeRejectedImport('File is not valid UTF-8 text.');
    }

    final stripped = stripOkfFences(decoded);
    final sections = splitGuidanceSections(
      stripped.text,
      fallbackTitle: _baseName(fileName),
    );
    if (sections.isEmpty) {
      throw const KnowledgeRejectedImport('File has no usable text.');
    }

    final existing = await findByFileName(fileName);
    var title = sections.first.title;
    final now = DateTime.now();

    final db = await _database.database;
    final docId = await db.transaction((txn) async {
      if (existing != null) {
        switch (duplicateAction) {
          case KnowledgeDuplicateAction.replace:
            await txn.delete(
              'knowledge_sections',
              where: 'doc_id = ?',
              whereArgs: [existing.id],
            );
            await txn.delete(
              'knowledge_docs',
              where: 'id = ?',
              whereArgs: [existing.id],
            );
          case KnowledgeDuplicateAction.keepBoth:
            title = '$title (${isoDate(now)})';
          case null:
            throw const KnowledgeRejectedImport(
              'A document with this file name already exists.',
            );
        }
      }

      final id = await txn.insert('knowledge_docs', {
        'title': title,
        'file_name': fileName,
        'imported_at': now.millisecondsSinceEpoch,
        'enabled': 1,
        'byte_size': bytes.length,
      });
      for (var i = 0; i < sections.length; i++) {
        await txn.insert('knowledge_sections', {
          'doc_id': id,
          'position': i,
          'title': sections[i].title,
          'body': sections[i].body,
        });
      }
      return id;
    });

    return KnowledgeImportResult(
      document: KnowledgeDocument(
        id: docId,
        title: title,
        fileName: fileName,
        importedAt: now,
        enabled: true,
        byteSize: bytes.length,
        sectionCount: sections.length,
      ),
      ignoredBlocks: stripped.ignoredBlocks,
    );
  }

  Future<void> setEnabled(int id, bool enabled) async {
    final db = await _database.database;
    await db.update(
      'knowledge_docs',
      {'enabled': enabled ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      await txn.delete(
        'knowledge_sections',
        where: 'doc_id = ?',
        whereArgs: [id],
      );
      await txn.delete('knowledge_docs', where: 'id = ?', whereArgs: [id]);
    });
  }

  /// Every section of every enabled document, each carrying its document's
  /// title — merged with the bundled reference by the agent's guidance
  /// search.
  Future<List<KnowledgeMatchSection>> enabledSections() async {
    final db = await _database.database;
    final rows = await db.rawQuery('''
      SELECT d.title AS doc_title, s.title AS sec_title, s.body
      FROM knowledge_sections s
      JOIN knowledge_docs d ON d.id = s.doc_id
      WHERE d.enabled = 1
      ORDER BY d.id, s.position
    ''');
    return [
      for (final row in rows)
        KnowledgeMatchSection(
          document: row['doc_title'] as String,
          section: GuidanceSection(
            row['sec_title'] as String,
            row['body'] as String,
          ),
        ),
    ];
  }

  KnowledgeDocument _documentFromMap(Map<String, Object?> row) =>
      KnowledgeDocument(
        id: row['id'] as int,
        title: row['title'] as String,
        fileName: row['file_name'] as String,
        importedAt: DateTime.fromMillisecondsSinceEpoch(
          row['imported_at'] as int,
        ),
        enabled: (row['enabled'] as int) != 0,
        byteSize: row['byte_size'] as int,
        sectionCount: (row['section_count'] as int?) ?? 0,
      );

  /// The file name without its directory or extension, for the
  /// no-heading-fallback section/document title.
  static String _baseName(String fileName) {
    final slash = fileName.lastIndexOf(RegExp(r'[\\/]'));
    final name = slash >= 0 ? fileName.substring(slash + 1) : fileName;
    final dot = name.lastIndexOf('.');
    return dot > 0 ? name.substring(0, dot) : name;
  }
}
