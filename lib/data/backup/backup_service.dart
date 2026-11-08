import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

import '../db/app_database.dart';

class BackupFormatException implements Exception {
  const BackupFormatException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// What a backup file holds, for the confirm dialog.
class BackupSummary {
  const BackupSummary({
    required this.createdAt,
    required this.rows,
    required this.settings,
    required this.hasCaches,
  });

  final DateTime? createdAt;

  /// Row count per table.
  final Map<String, int> rows;
  final int settings;
  final bool hasCaches;

  int get activities => rows['activities'] ?? 0;
  int get plans => rows['plans'] ?? 0;
  int get total => rows.values.fold(0, (a, b) => a + b);
}

/// Exports the local cache, plans, knowledge library and settings as one
/// JSON document and restores such a document, replacing what is on the
/// device. Secrets (the Intervals.icu and LLM keys live in the OS vault) are
/// never exported: after a restore the athlete reconnects Intervals.icu.
class BackupService {
  BackupService({AppDatabase? database, DateTime Function()? clock})
    : _database = database ?? AppDatabase.instance,
      _clock = clock ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _clock;

  static const format = 'triiq-backup';
  static const version = 1;

  /// Tables in insert order (parents before children); deleted in reverse.
  static const coreTables = [
    'wellness',
    'activities',
    'sync_state',
    'events',
    'plans',
    'plan_sessions',
    'knowledge_docs',
    'knowledge_sections',
  ];

  /// Re-fetchable from Intervals.icu; left out unless asked for.
  static const cacheTables = ['activity_streams', 'performance_curves'];

  /// Preferences that describe this device's runtime, not the athlete's
  /// choices, and keys that look like credentials.
  ///
  /// LLM connection settings (`llm.*`: provider, server URL, models) are
  /// device setup, not training data, and a restore must never point the
  /// trainer — and the data it sends — at a server from a backup file.
  static bool excludedPref(String key) =>
      key.startsWith('sync.background_') ||
      key.startsWith('llm.') ||
      RegExp(
        r'(api[_-]?key|token|secret|password)',
        caseSensitive: false,
      ).hasMatch(key);

  Future<Map<String, dynamic>> export({bool includeCaches = false}) async {
    final db = await _database.database;
    final tables = <String, dynamic>{};
    for (final t in [...coreTables, if (includeCaches) ...cacheTables]) {
      final rows = await db.query(t);
      tables[t] = [for (final r in rows) _encodeRow(r)];
    }
    final prefs = await SharedPreferences.getInstance();
    final settings = <String, dynamic>{};
    for (final key in prefs.getKeys()) {
      if (excludedPref(key)) continue;
      final v = prefs.get(key);
      final entry = switch (v) {
        String s => {'t': 's', 'v': s},
        int i => {'t': 'i', 'v': i},
        double d => {'t': 'd', 'v': d},
        bool b => {'t': 'b', 'v': b},
        List<String> l => {'t': 'l', 'v': l},
        _ => null,
      };
      if (entry != null) settings[key] = entry;
    }
    return {
      'format': format,
      'version': version,
      'created_at': _clock().toIso8601String(),
      'tables': tables,
      'settings': settings,
    };
  }

  String encode(Map<String, dynamic> backup) =>
      const JsonEncoder.withIndent(null).convert(backup);

  static Map<String, Object?> _encodeRow(Map<String, Object?> row) => {
    for (final e in row.entries)
      e.key: e.value is Uint8List
          ? {r'$b64': base64Encode(e.value as Uint8List)}
          : e.value,
  };

  static Object? _decodeValue(Object? v) {
    if (v == null || v is num || v is String) return v;
    if (v is Map && v.length == 1 && v[r'$b64'] is String) {
      return base64Decode(v[r'$b64'] as String);
    }
    throw const BackupFormatException('A row holds an unsupported value.');
  }

  /// Checks that [json] is a backup this version can restore and counts its
  /// contents. Throws [BackupFormatException] otherwise.
  BackupSummary inspect(Object? json) {
    if (json is! Map || json['format'] != format) {
      throw const BackupFormatException('This is not a TriIQ backup file.');
    }
    final v = json['version'];
    if (v is! int || v < 1) {
      throw const BackupFormatException('The backup has no valid version.');
    }
    if (v > version) {
      throw BackupFormatException(
        'This backup is from a newer TriIQ (format $v). Update the app first.',
      );
    }
    final tables = json['tables'];
    if (tables is! Map) {
      throw const BackupFormatException('The backup has no data tables.');
    }
    final rows = <String, int>{};
    for (final t in [...coreTables, ...cacheTables]) {
      final list = tables[t];
      if (list == null) continue;
      if (list is! List) {
        throw BackupFormatException('Table $t is malformed.');
      }
      rows[t] = list.length;
    }
    if (!coreTables.every(rows.containsKey)) {
      throw const BackupFormatException('The backup is missing core tables.');
    }
    final settings = json['settings'];
    return BackupSummary(
      createdAt: DateTime.tryParse('${json['created_at']}'),
      rows: rows,
      settings: settings is Map ? settings.length : 0,
      hasCaches: cacheTables.any(rows.containsKey),
    );
  }

  /// Replaces the local cache, plans, knowledge library (and chart caches
  /// when the backup has them) and the exported settings with [json].
  /// All-or-nothing for the database: a bad row rolls everything back.
  /// Settings are applied after; running screens keep their old values until
  /// the app restarts.
  Future<BackupSummary> restore(Object? json) async {
    final summary = inspect(json);
    final map = json as Map;
    final tables = map['tables'] as Map;
    final db = await _database.database;

    // Decode and validate everything before touching the database.
    final decoded = <String, List<Map<String, Object?>>>{};
    for (final t in summary.rows.keys) {
      final rows = <Map<String, Object?>>[];
      for (final r in tables[t] as List) {
        if (r is! Map) throw BackupFormatException('Table $t is malformed.');
        rows.add({
          for (final e in r.entries) '${e.key}': _decodeValue(e.value),
        });
      }
      decoded[t] = rows;
    }

    await db.transaction((txn) async {
      final present = [
        ...coreTables,
        ...cacheTables,
      ].where(decoded.containsKey).toList();
      for (final t in present.reversed) {
        await txn.delete(t);
      }
      for (final t in present) {
        final columns = {
          for (final c in await txn.rawQuery('PRAGMA table_info($t)'))
            c['name'] as String,
        };
        final batch = txn.batch();
        for (final row in decoded[t]!) {
          batch.insert(t, {
            for (final e in row.entries)
              if (columns.contains(e.key)) e.key: e.value,
          });
        }
        await batch.commit(noResult: true);
      }
    });

    final settings = map['settings'];
    if (settings is Map) {
      final prefs = await SharedPreferences.getInstance();
      for (final e in settings.entries) {
        final key = '${e.key}';
        final entry = e.value;
        if (excludedPref(key) || entry is! Map) continue;
        final value = entry['v'];
        switch (entry['t']) {
          case 's' when value is String:
            await prefs.setString(key, value);
          case 'i' when value is int:
            await prefs.setInt(key, value);
          case 'd' when value is num:
            await prefs.setDouble(key, value.toDouble());
          case 'b' when value is bool:
            await prefs.setBool(key, value);
          case 'l' when value is List:
            await prefs.setStringList(key, [for (final x in value) '$x']);
        }
      }
    }
    return summary;
  }
}
