import 'package:sqflite/sqflite.dart';

import '../db/app_database.dart';
import '../models/local_wellness.dart';

/// Reads/writes cached [LocalWellness] rows.
class WellnessRepository {
  WellnessRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<void> upsertAll(Iterable<LocalWellness> records) async {
    final db = await _database.database;
    final batch = db.batch();
    for (final record in records) {
      batch.insert(
        'wellness',
        record.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<LocalWellness?> getByDate(String date) async {
    final db = await _database.database;
    final rows = await db.query(
      'wellness',
      where: 'date = ?',
      whereArgs: [date],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return LocalWellness.fromMap(rows.first);
  }

  Future<List<LocalWellness>> getRange(String oldest, String newest) async {
    final db = await _database.database;
    final rows = await db.query(
      'wellness',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [oldest, newest],
      orderBy: 'date ASC',
    );
    return rows.map(LocalWellness.fromMap).toList();
  }
}
