import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/data/db/app_database.dart';

/// Registers a `setUp`/`tearDown` that points the shared
/// [AppDatabase.instance] at a fresh temp file, with the FFI SQLite factory
/// the desktop test VM needs. Call it at the top of `main()` in any test whose
/// code reaches the database through repository defaults, so it neither fails
/// where no factory is set up nor leaves state in (or reads state from) a
/// `triiq.db` in the working directory.
void useTempAppDatabase() {
  late Directory dir;

  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dir = await Directory.systemTemp.createTemp('triiq_test_db');
    await AppDatabase.instance.useTestPath(p.join(dir.path, 'triiq.db'));
  });

  tearDown(() async {
    await AppDatabase.instance.resetTestPath();
    await dir.delete(recursive: true);
  });
}
