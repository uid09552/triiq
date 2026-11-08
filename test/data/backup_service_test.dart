import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/data/backup/backup_service.dart';
import 'package:triiq/data/db/app_database.dart';

void main() {
  late Directory dir;
  late AppDatabase source;
  late AppDatabase target;

  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    SharedPreferences.setMockInitialValues({});
    dir = await Directory.systemTemp.createTemp('triiq_backup');
    source = AppDatabase.atPath(p.join(dir.path, 'a.db'));
    target = AppDatabase.atPath(p.join(dir.path, 'b.db'));
  });

  tearDown(() async {
    await source.close();
    await target.close();
    await dir.delete(recursive: true);
  });

  Future<void> seed(AppDatabase d) async {
    final db = await d.database;
    await db.insert('activities', {
      'id': 'i1',
      'date': '2026-05-01',
      'type': 'Run',
      'name': 'Easy',
      'moving_time': 3600,
      'distance': 10000.0,
      'training_load': 50,
      'raw': '{"x":1}',
      'synced_at': 1,
    });
    await db.insert('wellness', {
      'date': '2026-05-01',
      'ctl': 50.5,
      'atl': 60.0,
      'ctl_load': null,
      'atl_load': null,
      'ramp_rate': null,
      'raw': '{}',
      'synced_at': 1,
    });
    final planId = await db.insert('plans', {
      'goal_type': 'x',
      'sport': 'Run',
      'start_date': '2026-05-04',
      'baseline_load': 300.0,
      'status': 'active',
      'meta': '{}',
      'created_at': 1,
    });
    await db.insert('plan_sessions', {
      'plan_id': planId,
      'week_index': 0,
      'date': '2026-05-05',
      'slot': 'z2',
      'template_id': 't',
      'name': 'Easy run',
      'sport': 'Run',
      'minutes': 45,
      'load': 40,
      'low_minutes': 45.0,
      'description': '- 45m Z2',
      'status': 'planned',
    });
    await db.insert('activity_streams', {
      'activity_id': 'i1',
      'data': '{}',
      'fetched_at': 1,
    });
  }

  test(
    'export → restore on another device reproduces data and settings',
    () async {
      await seed(source);
      SharedPreferences.setMockInitialValues({
        'plan.goal': '{"a":1}',
        'targets.run_hours': 3.5,
        'notifications.enabled': true,
        'agent.memory': '[]',
        'sync.auto_interval_minutes': 15,
        'sync.background_last_run': 5,
        'llm.some_api_key': 'secret',
      });
      final json = jsonDecode(
        BackupService(
          database: source,
        ).encode(await BackupService(database: source).export()),
      );
      expect(json['format'], 'triiq-backup');
      expect(json['tables'].containsKey('activity_streams'), isFalse);
      expect(json['settings'].containsKey('llm.some_api_key'), isFalse);
      expect(json['settings'].containsKey('sync.background_last_run'), isFalse);

      SharedPreferences.setMockInitialValues({'targets.run_hours': 1.0});
      final summary = await BackupService(database: target).restore(json);
      expect(summary.activities, 1);
      expect(summary.plans, 1);
      expect(summary.hasCaches, isFalse);

      final db = await target.database;
      expect((await db.query('activities')).single['name'], 'Easy');
      expect((await db.query('wellness')).single['ctl'], 50.5);
      final s = (await db.query('plan_sessions')).single;
      expect(s['plan_id'], (await db.query('plans')).single['id']);
      expect(s['description'], '- 45m Z2');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getDouble('targets.run_hours'), 3.5);
      expect(prefs.getBool('notifications.enabled'), isTrue);
      expect(prefs.getInt('sync.auto_interval_minutes'), 15);
      expect(prefs.getString('plan.goal'), '{"a":1}');
    },
  );

  test('restore replaces what was there', () async {
    await seed(source);
    await seed(target);
    final tdb = await target.database;
    await tdb.insert('activities', {
      'id': 'old',
      'date': '2026-04-01',
      'type': 'Ride',
      'name': 'Old',
      'moving_time': 1,
      'distance': 1.0,
      'training_load': 1,
      'raw': '{}',
      'synced_at': 1,
    });
    final json = jsonDecode(
      jsonEncode(await BackupService(database: source).export()),
    );
    await BackupService(database: target).restore(json);
    expect((await tdb.query('activities')).map((r) => r['id']), ['i1']);
    expect(await tdb.query('activity_streams'), hasLength(1)); // untouched
  });

  test(
    'chart caches are only exported when asked and replace on restore',
    () async {
      await seed(source);
      final json = jsonDecode(
        jsonEncode(
          await BackupService(database: source).export(includeCaches: true),
        ),
      );
      expect(json['tables']['activity_streams'], hasLength(1));
      final summary = await BackupService(database: target).restore(json);
      expect(summary.hasCaches, isTrue);
      expect(
        await (await target.database).query('activity_streams'),
        hasLength(1),
      );
    },
  );

  test('a bad row rolls the whole restore back', () async {
    await seed(target);
    final json = jsonDecode(
      jsonEncode(await BackupService(database: target).export()),
    );
    // activities.raw is NOT NULL; null violates it after wellness is replaced.
    json['tables']['wellness'][0]['ctl'] = 99.0;
    json['tables']['activities'][0]['raw'] = null;
    await expectLater(
      BackupService(database: target).restore(json),
      throwsA(anything),
    );
    final db = await target.database;
    expect((await db.query('wellness')).single['ctl'], 50.5);
    expect(await db.query('activities'), hasLength(1));
  });

  test('rejects non-backups, newer versions and missing tables', () {
    final s = BackupService(database: source);
    expect(
      () => s.inspect({'hello': 1}),
      throwsA(isA<BackupFormatException>()),
    );
    expect(() => s.inspect([]), throwsA(isA<BackupFormatException>()));
    expect(
      () => s.inspect({'format': 'triiq-backup', 'version': 99, 'tables': {}}),
      throwsA(
        isA<BackupFormatException>().having(
          (e) => e.message,
          'message',
          contains('newer'),
        ),
      ),
    );
    expect(
      () => s.inspect({
        'format': 'triiq-backup',
        'version': 1,
        'tables': {'wellness': []},
      }),
      throwsA(isA<BackupFormatException>()),
    );
  });

  test('unsupported values and unknown columns are handled', () async {
    await seed(source);
    final good = jsonDecode(
      jsonEncode(await BackupService(database: source).export()),
    );
    final nested = jsonDecode(jsonEncode(good));
    nested['tables']['activities'][0]['name'] = {
      'evil': [1],
    };
    await expectLater(
      BackupService(database: target).restore(nested),
      throwsA(isA<BackupFormatException>()),
    );
    // An unknown column (from a newer schema) is skipped, not fatal.
    good['tables']['activities'][0]['future_column'] = 'x';
    await BackupService(database: target).restore(good);
    expect(await (await target.database).query('activities'), hasLength(1));
  });
}
