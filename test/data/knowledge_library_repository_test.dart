import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/repositories/knowledge_library_repository.dart';

void main() {
  late Directory dir;

  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dir = await Directory.systemTemp.createTemp('triiq_knowledge');
  });

  tearDown(() => dir.delete(recursive: true));

  group('schema', () {
    test('a fresh database creates the knowledge tables empty', () async {
      final database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
      addTearDown(database.close);
      final db = await database.database;

      expect(await db.getVersion(), 8);
      expect(await db.query('knowledge_docs'), isEmpty);
      expect(await db.query('knowledge_sections'), isEmpty);
    });

    test('a v5 cache upgrades to v6 with empty knowledge tables', () async {
      final path = p.join(dir.path, 'triiq.db');
      final old = await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 5,
          onCreate: (db, _) async {
            await db.execute(
              'CREATE TABLE activities (id TEXT PRIMARY KEY, date TEXT)',
            );
            // A real v5 database already has plan_sessions (added at v3);
            // the v7 migration below alters it, so the fixture needs it too.
            await db.execute('''
              CREATE TABLE plan_sessions (
                id INTEGER PRIMARY KEY AUTOINCREMENT, plan_id INTEGER NOT NULL,
                week_index INTEGER NOT NULL, date TEXT NOT NULL,
                slot TEXT NOT NULL, template_id TEXT NOT NULL,
                name TEXT NOT NULL, sport TEXT NOT NULL,
                minutes INTEGER NOT NULL, load INTEGER NOT NULL,
                low_minutes REAL NOT NULL, description TEXT NOT NULL,
                intervals_event_id TEXT, calendar_event_id TEXT,
                status TEXT NOT NULL)
            ''');
          },
        ),
      );
      await old.close();

      final database = AppDatabase.atPath(path);
      addTearDown(database.close);
      final db = await database.database;

      expect(await db.getVersion(), 8);
      expect(await db.query('knowledge_docs'), isEmpty);
      expect(await db.query('knowledge_sections'), isEmpty);
    });
  });

  group('KnowledgeLibraryRepository', () {
    late AppDatabase database;
    late KnowledgeLibraryRepository repo;

    setUp(() {
      database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
      repo = KnowledgeLibraryRepository(database: database);
    });

    tearDown(() => database.close());

    List<int> bytesOf(String text) => utf8.encode(text);

    test('imports a multi-section file and lists it', () async {
      final result = await repo.import(
        fileName: 'swim-css.md',
        bytes: bytesOf(
          '# CSS test\n\nBody one.\n\n'
          '# Threshold sets\n\nBody two.\n\n'
          '# Drills\n\nBody three.\n',
        ),
      );

      expect(result.document.title, 'CSS test');
      expect(result.document.sectionCount, 3);
      expect(result.ignoredBlocks, 0);

      final docs = await repo.list();
      expect(docs, hasLength(1));
      expect(docs.single.fileName, 'swim-css.md');
      expect(docs.single.sectionCount, 3);
      expect(docs.single.enabled, isTrue);
    });

    test(
      'a file with no heading is stored as one section named after it',
      () async {
        final result = await repo.import(
          fileName: 'taper-notes.txt',
          bytes: bytesOf('Just plain notes about tapering.'),
        );

        expect(result.document.title, 'taper-notes');
        expect(result.document.sectionCount, 1);
      },
    );

    test('an okf-template block is stripped and counted', () async {
      final result = await repo.import(
        fileName: 'with-block.md',
        bytes: bytesOf('''
# Notes

Some prose.

```okf-template
{"id": "x"}
```
'''),
      );

      expect(result.ignoredBlocks, 1);
      final sections = await repo.enabledSections();
      expect(sections, hasLength(1));
      expect(sections.single.section.body, isNot(contains('okf-template')));
    });

    test(
      'rejects a file over the size cap, leaving the library unchanged',
      () async {
        final big = List.filled(KnowledgeLibraryRepository.maxBytes + 1, 97);
        await expectLater(
          () => repo.import(fileName: 'big.md', bytes: big),
          throwsA(isA<KnowledgeRejectedImport>()),
        );
        expect(await repo.list(), isEmpty);
      },
    );

    test('rejects invalid UTF-8', () async {
      await expectLater(
        () => repo.import(fileName: 'bad.md', bytes: [0xFF, 0xFE, 0x00]),
        throwsA(isA<KnowledgeRejectedImport>()),
      );
      expect(await repo.list(), isEmpty);
    });

    test('rejects an empty file', () async {
      await expectLater(
        () => repo.import(fileName: 'empty.md', bytes: bytesOf('   \n\n')),
        throwsA(isA<KnowledgeRejectedImport>()),
      );
      expect(await repo.list(), isEmpty);
    });

    test(
      're-importing the same file name without a choice is rejected',
      () async {
        await repo.import(fileName: 'notes.md', bytes: bytesOf('# A\n\nBody.'));

        await expectLater(
          () =>
              repo.import(fileName: 'notes.md', bytes: bytesOf('# B\n\nBody.')),
          throwsA(isA<KnowledgeRejectedImport>()),
        );
        expect(await repo.list(), hasLength(1));
      },
    );

    test('replace swaps the document out', () async {
      await repo.import(fileName: 'notes.md', bytes: bytesOf('# A\n\nBody.'));
      final second = await repo.import(
        fileName: 'notes.md',
        bytes: bytesOf('# B\n\nBody.'),
        duplicateAction: KnowledgeDuplicateAction.replace,
      );

      final docs = await repo.list();
      expect(docs, hasLength(1));
      expect(docs.single.id, second.document.id);
      expect(docs.single.title, 'B');
    });

    test('keep both suffixes the new title with the import date', () async {
      await repo.import(fileName: 'notes.md', bytes: bytesOf('# A\n\nBody.'));
      final second = await repo.import(
        fileName: 'notes.md',
        bytes: bytesOf('# A\n\nOther body.'),
        duplicateAction: KnowledgeDuplicateAction.keepBoth,
      );

      final docs = await repo.list();
      expect(docs, hasLength(2));
      expect(second.document.title, startsWith('A ('));
    });

    test('disabling a document removes it from enabled sections', () async {
      final result = await repo.import(
        fileName: 'notes.md',
        bytes: bytesOf('# A\n\nBody.'),
      );

      await repo.setEnabled(result.document.id, false);
      expect(await repo.enabledSections(), isEmpty);

      await repo.setEnabled(result.document.id, true);
      expect(await repo.enabledSections(), hasLength(1));
    });

    test('deleting removes the document and its sections', () async {
      final result = await repo.import(
        fileName: 'notes.md',
        bytes: bytesOf('# A\n\nBody.'),
      );

      await repo.delete(result.document.id);

      expect(await repo.list(), isEmpty);
      expect(await repo.enabledSections(), isEmpty);
    });
  });
}
