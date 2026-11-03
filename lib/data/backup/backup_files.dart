import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'backup_service.dart';

/// Moves a backup between the app and the file system: share sheet on
/// phones (so it can go to Drive, Files or a mail), save dialog on desktop.
class BackupFiles {
  BackupFiles({BackupService? service}) : _service = service ?? BackupService();

  final BackupService _service;

  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  static String fileName(DateTime now) {
    String two(int v) => v.toString().padLeft(2, '0');
    return 'triiq-backup-${now.year}${two(now.month)}${two(now.day)}-'
        '${two(now.hour)}${two(now.minute)}.json';
  }

  /// Writes the backup and hands it to the athlete. Returns the saved path
  /// (desktop), or null when they cancelled or it went to the share sheet.
  Future<String?> export({bool includeCaches = false}) async {
    final text = _service.encode(
      await _service.export(includeCaches: includeCaches),
    );
    final name = fileName(DateTime.now());
    if (isMobile) {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$name');
      await file.writeAsString(text, flush: true);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path, mimeType: 'application/json')]),
      );
      return null;
    }
    final location = await getSaveLocation(
      suggestedName: name,
      acceptedTypeGroups: const [
        XTypeGroup(label: 'JSON', extensions: ['json']),
      ],
    );
    if (location == null) return null;
    await File(location.path).writeAsString(text, flush: true);
    return location.path;
  }

  /// Lets the athlete pick a backup file and parses it; null if cancelled.
  /// Throws [BackupFormatException] when it is not a usable backup.
  Future<Map<String, dynamic>?> pick() async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'JSON', extensions: ['json']),
      ],
    );
    if (file == null) return null;
    try {
      final decoded = jsonDecode(await file.readAsString());
      _service.inspect(decoded);
      return decoded as Map<String, dynamic>;
    } on FormatException {
      throw const BackupFormatException('This is not a TriIQ backup file.');
    }
  }
}
