import 'package:sqflite/sqflite.dart';

import '../db/app_database.dart';

/// Tracks which date range has already been synced for a given scope (e.g.
/// `activities`, `wellness`), so repeat syncs can be skipped or narrowed.
class SyncStateRepository {
  SyncStateRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<({String oldest, String newest, DateTime lastSyncedAt})?> get(
    String scope,
  ) async {
    final db = await _database.database;
    final rows = await db.query(
      'sync_state',
      where: 'scope = ?',
      whereArgs: [scope],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return (
      oldest: row['oldest_synced'] as String,
      newest: row['newest_synced'] as String,
      lastSyncedAt: DateTime.fromMillisecondsSinceEpoch(
        row['last_synced_at'] as int,
      ),
    );
  }

  /// Records that [scope] now covers [oldest]..[newest], merging with
  /// whatever range was already recorded.
  Future<void> recordSync(
    String scope, {
    required String oldest,
    required String newest,
  }) async {
    final db = await _database.database;
    final existing = await get(scope);

    final mergedOldest = existing == null || oldest.compareTo(existing.oldest) < 0
        ? oldest
        : existing.oldest;
    final mergedNewest = existing == null || newest.compareTo(existing.newest) > 0
        ? newest
        : existing.newest;

    await db.insert('sync_state', {
      'scope': scope,
      'oldest_synced': mergedOldest,
      'newest_synced': mergedNewest,
      'last_synced_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
