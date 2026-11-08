import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:triiq/agent/ollama_connection.dart';
import 'package:triiq/data/backup/backup_service.dart';
import 'package:triiq/data/db/app_database.dart';

void main() {
  group('Ollama key goes only to Ollama Cloud over https', () {
    test('isOllamaCloudUrl', () {
      expect(isOllamaCloudUrl('https://ollama.com'), isTrue);
      expect(isOllamaCloudUrl(' https://OLLAMA.com/ '), isTrue);
      expect(isOllamaCloudUrl('http://ollama.com'), isFalse);
      expect(isOllamaCloudUrl('http://192.168.1.20:11434'), isFalse);
      expect(isOllamaCloudUrl('https://my-ollama.example.org'), isFalse);
      expect(isOllamaCloudUrl('https://ollama.com.evil.example'), isFalse);
      expect(isOllamaCloudUrl('not a url'), isFalse);
    });
  });

  group('plain http for a self-hosted Ollama', () {
    test('isPlainHttpUrl flags http only', () {
      expect(isPlainHttpUrl('http://192.168.1.20:11434'), isTrue);
      expect(isPlainHttpUrl('HTTP://localhost:11434'), isTrue);
      expect(isPlainHttpUrl('https://ollama.com'), isFalse);
      expect(isPlainHttpUrl(''), isFalse);
    });

    test('Android allows cleartext only outside the services TriIQ uses', () {
      final manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();
      expect(
        manifest,
        contains(
          'android:networkSecurityConfig="@xml/network_security_config"',
        ),
      );
      final config = File(
        'android/app/src/main/res/xml/network_security_config.xml',
      ).readAsStringSync();
      expect(
        config,
        contains('<domain-config cleartextTrafficPermitted="false">'),
      );
      for (final d in [
        'intervals.icu',
        'anthropic.com',
        'ollama.com',
        'openstreetmap.org',
      ]) {
        expect(config, contains('>$d<'), reason: d);
      }
    });
  });

  group('backup never carries LLM connection settings', () {
    test('llm.* keys are excluded on export and restore', () {
      expect(BackupService.excludedPref('llm.ollama_base_url'), isTrue);
      expect(BackupService.excludedPref('llm.provider'), isTrue);
      expect(BackupService.excludedPref('plan.goal'), isFalse);
      expect(BackupService.excludedPref('agent.memory'), isFalse);
    });
  });

  group('desktop database moves out of the working directory', () {
    late Directory dir;

    setUp(() async => dir = await Directory.systemTemp.createTemp('triiq_mig'));
    tearDown(() async => dir.delete(recursive: true));

    test('an old database (and its WAL) is moved once', () async {
      final from = p.join(dir.path, 'old', 'triiq.db');
      final to = p.join(dir.path, 'new', 'triiq.db');
      await Directory(p.dirname(from)).create();
      await Directory(p.dirname(to)).create();
      await File(from).writeAsString('db');
      await File('$from-wal').writeAsString('wal');

      await AppDatabase.migrateLegacyDatabase(from: from, to: to);

      expect(await File(to).readAsString(), 'db');
      expect(await File('$to-wal').readAsString(), 'wal');
      expect(await File(from).exists(), isFalse);
      expect(await File('$from-wal').exists(), isFalse);
    });

    test(
      'an existing database at the new place is never overwritten',
      () async {
        final from = p.join(dir.path, 'a.db');
        final to = p.join(dir.path, 'b.db');
        await File(from).writeAsString('old');
        await File(to).writeAsString('current');

        await AppDatabase.migrateLegacyDatabase(from: from, to: to);

        expect(await File(to).readAsString(), 'current');
        expect(await File(from).readAsString(), 'old');
      },
    );

    test('nothing to move is a no-op', () async {
      final to = p.join(dir.path, 'b.db');
      await AppDatabase.migrateLegacyDatabase(
        from: p.join(dir.path, 'missing.db'),
        to: to,
      );
      expect(await File(to).exists(), isFalse);
    });
  });
}
