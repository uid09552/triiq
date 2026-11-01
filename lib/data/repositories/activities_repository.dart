import 'package:sqflite/sqflite.dart';

import '../db/app_database.dart';
import '../models/local_activity.dart';

/// Reads/writes cached [LocalActivity] rows.
class ActivitiesRepository {
  ActivitiesRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<void> upsertAll(Iterable<LocalActivity> records) async {
    final db = await _database.database;
    final batch = db.batch();
    for (final record in records) {
      batch.insert(
        'activities',
        record.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<LocalActivity>> getByDate(String date) async {
    final db = await _database.database;
    final rows = await db.query(
      'activities',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'date ASC',
    );
    return rows.map(LocalActivity.fromMap).toList();
  }

  /// One cached activity, or null when it isn't in the cache.
  Future<LocalActivity?> getById(String id) async {
    final db = await _database.database;
    final rows = await db.query(
      'activities',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : LocalActivity.fromMap(rows.first);
  }

  /// All cached activities, most recent first — for the Activities list.
  Future<List<LocalActivity>> getAll() async {
    final db = await _database.database;
    final rows = await db.query('activities', orderBy: 'date DESC, id DESC');
    return rows.map(LocalActivity.fromMap).toList();
  }

  Future<List<LocalActivity>> getRange(String oldest, String newest) async {
    final db = await _database.database;
    final rows = await db.query(
      'activities',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [oldest, newest],
      orderBy: 'date ASC',
    );
    return rows.map(LocalActivity.fromMap).toList();
  }
}
