import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/repositories/knowledge_library_repository.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/knowledge/knowledge_library_screen.dart';

/// Stands in for the platform file picker so a test controls exactly which
/// files "the athlete picked" without touching a real OS dialog.
class _FakeFileSelector extends FileSelectorPlatform
    with MockPlatformInterfaceMixin {
  _FakeFileSelector(this.files);

  final List<XFile> files;

  @override
  Future<List<XFile>> openFiles({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async => files;
}

// cross_file's io.dart variant ignores the `name:` parameter (it's there
// only to match the web constructor) and derives `.name` from `.path`'s
// last segment instead — pass [name] as the path too so it round-trips.
XFile _file(String name, String text) => XFile.fromData(
  Uint8List.fromList(text.codeUnits),
  name: name,
  path: name,
);

void main() {
  late Directory dir;
  late AppDatabase database;
  late KnowledgeLibraryRepository repository;
  final defaultPlatform = FileSelectorPlatform.instance;

  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dir = await Directory.systemTemp.createTemp('triiq_knowledge_screen');
    database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
    repository = KnowledgeLibraryRepository(database: database);
  });

  tearDown(() async {
    FileSelectorPlatform.instance = defaultPlatform;
    await database.close();
    await dir.delete(recursive: true);
  });

  // Real SQLite (sqflite_common_ffi) runs genuine async I/O that
  // pumpAndSettle's fake clock cannot wait out — the rest of the test suite
  // works around this the same way (see calendar_settings_section_test.dart,
  // today_plan_items_test.dart): give real wall-clock time between pumps
  // via tester.runAsync instead of pumpAndSettle.
  Future<void> realWait(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }
  }

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: KnowledgeLibraryScreen(repository: repository),
      ),
    );
    await realWait(tester);
  }

  testWidgets('empty state explains what imported knowledge is used for',
      (tester) async {
    await pump(tester);

    expect(find.text('No documents yet'), findsOneWidget);
    expect(find.textContaining('chat agent searches them'), findsOneWidget);
  });

  testWidgets('importing a file lists it with its section count',
      (tester) async {
    FileSelectorPlatform.instance = _FakeFileSelector([
      _file('swim-css.md', '# CSS test\n\nBody one.\n\n# Drills\n\nBody two.\n'),
    ]);
    await pump(tester);

    await tester.tap(
      find.byKey(const ValueKey('knowledge-import-appbar-button')),
    );
    await realWait(tester);

    expect(find.text('CSS test'), findsOneWidget);
    expect(find.text('swim-css.md'), findsOneWidget);
    // Matches both the tile's own line and the just-shown success snackbar;
    // just confirm the tile's line is one of them.
    expect(find.textContaining('2 sections'), findsWidgets);
    expect(find.textContaining('2 sections ·'), findsOneWidget);
  });

  testWidgets('an oversized file is rejected with a message', (tester) async {
    FileSelectorPlatform.instance = _FakeFileSelector([
      _file(
        'huge.md',
        '# A\n\n${'x' * (KnowledgeLibraryRepository.maxBytes + 1)}',
      ),
    ]);
    await pump(tester);

    await tester.tap(
      find.byKey(const ValueKey('knowledge-import-appbar-button')),
    );
    await realWait(tester);

    expect(find.textContaining("Couldn't import"), findsOneWidget);
    final docs = await tester.runAsync(() => repository.list());
    expect(docs, isEmpty);
  });

  testWidgets('disabling a document flips its switch', (tester) async {
    await tester.runAsync(
      () => repository.import(
        fileName: 'notes.md',
        bytes: '# A\n\nBody.'.codeUnits,
      ),
    );
    await pump(tester);

    final switchFinder = find.byType(Switch);
    expect(tester.widget<Switch>(switchFinder).value, isTrue);

    await tester.tap(switchFinder);
    await realWait(tester);

    expect(tester.widget<Switch>(switchFinder).value, isFalse);
    final docs = await tester.runAsync(() => repository.list());
    expect(docs!.single.enabled, isFalse);
  });

  testWidgets('deleting asks for confirmation then removes the document',
      (tester) async {
    await tester.runAsync(
      () => repository.import(
        fileName: 'notes.md',
        bytes: '# A\n\nBody.'.codeUnits,
      ),
    );
    await pump(tester);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();
    expect(find.text('Delete this document?'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await realWait(tester);

    expect(find.text('A'), findsNothing);
    final docs = await tester.runAsync(() => repository.list());
    expect(docs, isEmpty);
  });

  testWidgets(
    're-importing the same file name offers replace or keep both',
    (tester) async {
      await tester.runAsync(
        () => repository.import(
          fileName: 'notes.md',
          bytes: '# A\n\nBody.'.codeUnits,
        ),
      );
      FileSelectorPlatform.instance = _FakeFileSelector([
        _file('notes.md', '# B\n\nOther body.'),
      ]);
      await pump(tester);

      await tester.tap(
        find.byKey(const ValueKey('knowledge-import-appbar-button')),
      );
      await realWait(tester);
      expect(find.text('Already imported'), findsOneWidget);

      await tester.tap(find.text('Replace'));
      await realWait(tester);

      final docs = await tester.runAsync(() => repository.list());
      expect(docs, hasLength(1));
      expect(docs!.single.title, 'B');
    },
  );
}
