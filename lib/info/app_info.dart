import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../l10n/app_localizations.dart';
import '../theme_controller.dart';

/// Where the project lives; the Info screen links to these.
final githubUrl = Uri.parse('https://github.com/uid09552/triiq');
final releasesUrl = Uri.parse('https://github.com/uid09552/triiq/releases');
final licenseUrl = Uri.parse(
  'https://github.com/uid09552/triiq/blob/main/LICENSE',
);

/// The running app's version and build number, read from the platform
/// (`version: 0.9.5+1` in `pubspec.yaml` → "0.9.5" and "1"). Tests set
/// `PackageInfo.setMockInitialValues`.
class AppInfo {
  const AppInfo({required this.version, required this.build});

  final String version;
  final String build;

  /// The installed app's info; null when the platform cannot say.
  static Future<AppInfo?> load() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return AppInfo(version: info.version, build: info.buildNumber);
    } catch (error) {
      debugPrint('AppInfo: cannot read the package info: $error');
      return null;
    }
  }

  /// "TriIQ 0.9.5 (build 1)".
  String versionLine(AppLocalizations l10n) =>
      l10n.infoVersionLine(version, build);

  /// "TriIQ 0.9.5 (build 1) · Android" — the line Settings shows.
  String footerLine(AppLocalizations l10n) =>
      '${versionLine(l10n)} · $platformName';
}

/// The version line of [info], or a note that it is unavailable.
String versionLineOf(AppInfo? info, AppLocalizations l10n) =>
    info == null ? l10n.infoVersionUnavailable : info.versionLine(l10n);

/// "Android", "Windows", … — what the app runs on.
String get platformName {
  if (kIsWeb) return 'Web';
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => 'Android',
    TargetPlatform.iOS => 'iOS',
    TargetPlatform.windows => 'Windows',
    TargetPlatform.linux => 'Linux',
    TargetPlatform.macOS => 'macOS',
    TargetPlatform.fuchsia => 'Fuchsia',
  };
}

/// The operating system's own description (kernel / build); null on web.
String? get osDescription {
  if (kIsWeb) return null;
  try {
    return Platform.operatingSystemVersion;
  } catch (_) {
    return null;
  }
}

/// The Dart runtime's version ("3.11.5"); null on web.
String? get dartVersion {
  if (kIsWeb) return null;
  try {
    return Platform.version.split(' ').first;
  } catch (_) {
    return null;
  }
}

/// What "Copy version info" puts on the clipboard, for a bug report: the
/// version, build, platform, OS, language and theme — nothing about the
/// athlete, the account or the data. English labels on purpose, so a
/// report reads the same whatever language it came from.
String versionInfoText({
  required AppInfo? info,
  required Locale locale,
  required AppThemeChoice theme,
}) {
  final os = osDescription;
  final dart = dartVersion;
  return [
    'TriIQ ${info?.version ?? 'unknown'}',
    'Build: ${info?.build ?? 'unknown'}',
    'Platform: $platformName',
    if (os != null) 'OS: $os',
    'Locale: $locale',
    'Theme: ${theme.name}',
    if (dart != null) 'Dart: $dart',
  ].join('\n');
}
