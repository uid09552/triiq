import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Local SQLite cache of data fetched from Intervals.icu.
///
/// Storage location: on Windows the database file lives at `./triiq.db`,
/// relative to the process's current working directory, so it's easy to
/// find/inspect during development. Android has no meaningful "current
/// directory", so it falls back to the app's documents directory instead.
/// Web isn't supported — sqflite needs a separate wasm-backed
/// implementation there.
class AppDatabase {
  AppDatabase._({String? path}) : _overridePath = path;

  /// The database the app uses.
  static final AppDatabase instance = AppDatabase._();

  /// A database at an explicit [path], for tests and tooling that must not
  /// touch the real cache. Each call is an independent handle.
  factory AppDatabase.atPath(String path) => AppDatabase._(path: path);

  final String? _overridePath;

  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  /// Releases the underlying handle. Mainly for tests, so a temp database
  /// file can be deleted afterwards.
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  Future<Database> _open() async {
    if (kIsWeb) {
      throw UnsupportedError(
        'Local SQLite storage is not supported on web yet.',
      );
    }

    // Desktop has no sqflite implementation of its own; the FFI factory
    // backed by the bundled sqlite3 native library (sqlite3_flutter_libs)
    // provides one. Android ships its own and must not be overridden.
    if (Platform.isWindows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final path = await _resolvePath();

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE wellness (
            date TEXT PRIMARY KEY,
            ctl REAL,
            atl REAL,
            ctl_load REAL,
            atl_load REAL,
            ramp_rate REAL,
            raw TEXT NOT NULL,
            synced_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE activities (
            id TEXT PRIMARY KEY,
            date TEXT NOT NULL,
            type TEXT,
            name TEXT,
            moving_time INTEGER,
            distance REAL,
            training_load INTEGER,
            raw TEXT NOT NULL,
            synced_at INTEGER NOT NULL
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_activities_date ON activities(date)',
        );
        await db.execute('''
          CREATE TABLE sync_state (
            scope TEXT PRIMARY KEY,
            oldest_synced TEXT NOT NULL,
            newest_synced TEXT NOT NULL,
            last_synced_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<String> _resolvePath() async {
    if (_overridePath != null) return _overridePath;
    if (Platform.isAndroid || Platform.isIOS) {
      final dir = await getApplicationDocumentsDirectory();
      return p.join(dir.path, 'triiq.db');
    }
    return p.join(Directory.current.path, 'triiq.db');
  }
}
