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
      version: 3,
      onUpgrade: (db, oldVersion, newVersion) async {
        // v2 added planned calendar entries. Existing caches only held what
        // already happened, so the table is simply created empty and filled
        // by the next sync.
        if (oldVersion < 2) {
          await db.execute(_createEventsTable);
          await db.execute(_createEventsDateIndex);
        }
        // v3 added training plans. Nothing to migrate: the tables start empty.
        if (oldVersion < 3) {
          await db.execute(_createPlansTable);
          await db.execute(_createPlanSessionsTable);
          await db.execute(_createPlanSessionsPlanIndex);
        }
      },
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
        await db.execute(_createEventsTable);
        await db.execute(_createEventsDateIndex);
        await db.execute(_createPlansTable);
        await db.execute(_createPlanSessionsTable);
        await db.execute(_createPlanSessionsPlanIndex);
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

  /// Planned calendar entries (workouts, races, notes). Kept as SQL
  /// constants so [_open]'s `onCreate` and `onUpgrade` cannot drift apart.
  static const _createEventsTable = '''
    CREATE TABLE events (
      id TEXT PRIMARY KEY,
      date TEXT NOT NULL,
      category TEXT,
      type TEXT,
      name TEXT,
      description TEXT,
      planned_load INTEGER,
      planned_time INTEGER,
      planned_distance REAL,
      indoor INTEGER NOT NULL DEFAULT 0,
      raw TEXT NOT NULL,
      synced_at INTEGER NOT NULL
    )
  ''';

  static const _createEventsDateIndex =
      'CREATE INDEX idx_events_date ON events(date)';

  /// A generated training plan. `meta` holds the per-week targets and limits
  /// as JSON — they are only ever read back whole.
  static const _createPlansTable = '''
    CREATE TABLE plans (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      goal_type TEXT NOT NULL,
      sport TEXT NOT NULL,
      start_date TEXT NOT NULL,
      baseline_load REAL NOT NULL,
      status TEXT NOT NULL,
      meta TEXT NOT NULL,
      created_at INTEGER NOT NULL
    )
  ''';

  /// One session of a plan, with the ids of the Intervals.icu event and
  /// device-calendar event it was written to (if it was).
  static const _createPlanSessionsTable = '''
    CREATE TABLE plan_sessions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      plan_id INTEGER NOT NULL,
      week_index INTEGER NOT NULL,
      date TEXT NOT NULL,
      slot TEXT NOT NULL,
      template_id TEXT NOT NULL,
      name TEXT NOT NULL,
      sport TEXT NOT NULL,
      minutes INTEGER NOT NULL,
      load INTEGER NOT NULL,
      low_minutes REAL NOT NULL,
      description TEXT NOT NULL,
      intervals_event_id TEXT,
      calendar_event_id TEXT,
      status TEXT NOT NULL
    )
  ''';

  static const _createPlanSessionsPlanIndex =
      'CREATE INDEX idx_plan_sessions_plan ON plan_sessions(plan_id)';

  Future<String> _resolvePath() async {
    if (_overridePath != null) return _overridePath;
    if (Platform.isAndroid || Platform.isIOS) {
      final dir = await getApplicationDocumentsDirectory();
      return p.join(dir.path, 'triiq.db');
    }
    return p.join(Directory.current.path, 'triiq.db');
  }
}
