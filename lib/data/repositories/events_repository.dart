import 'package:sqflite/sqflite.dart';

import '../db/app_database.dart';
import '../models/local_event.dart';

/// Reads/writes cached [LocalEvent] rows.
class EventsRepository {
  EventsRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  /// Replaces everything cached in [oldest]..[newest] with [records].
  ///
  /// Unlike activities, planned entries are routinely *removed* upstream —
  /// a coach reshuffles the week, the athlete deletes a session. Upserting
  /// alone would leave those ghosts in the cache forever, so the range is
  /// cleared and rewritten in one transaction.
  Future<void> replaceRange(
    String oldest,
    String newest,
    Iterable<LocalEvent> records,
  ) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      await txn.delete(
        'events',
        where: 'date BETWEEN ? AND ?',
        whereArgs: [oldest, newest],
      );
      final batch = txn.batch();
      for (final record in records) {
        batch.insert(
          'events',
          record.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  /// Drops one cached entry — what deleting a session upstream needs, so
  /// the calendar stops showing it before the next sync of that range.
  Future<void> deleteById(String id) async {
    final db = await _database.database;
    await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<LocalEvent>> getByDate(String date) async {
    final db = await _database.database;
    final rows = await db.query(
      'events',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'id ASC',
    );
    return rows.map(LocalEvent.fromMap).toList();
  }

  Future<List<LocalEvent>> getRange(String oldest, String newest) async {
    final db = await _database.database;
    final rows = await db.query(
      'events',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [oldest, newest],
      orderBy: 'date ASC, id ASC',
    );
    return rows.map(LocalEvent.fromMap).toList();
  }
}
