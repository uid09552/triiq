import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Hands the SBOM to the athlete the way a backup is: the share sheet on
/// phones (Drive, Files, mail), a save dialog on desktop.
class SbomFiles {
  const SbomFiles();

  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// "triiq-0.9.5+1.cdx.json".
  static String fileName(String appVersion) => 'triiq-$appVersion.cdx.json';

  /// Returns the saved path (desktop), or null when the athlete cancelled
  /// or it went to the share sheet.
  Future<String?> export(String json, {required String appVersion}) async {
    final name = fileName(appVersion);
    if (kIsWeb) {
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              utf8.encode(json),
              mimeType: 'application/json',
              name: name,
            ),
          ],
          fileNameOverrides: [name],
        ),
      );
      return null;
    }
    if (isMobile) {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$name');
      await file.writeAsString(json, flush: true);
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
    await File(location.path).writeAsString(json, flush: true);
    return location.path;
  }
}
