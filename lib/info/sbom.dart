import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

/// The bundled SBOM: `tool/pubspec_lock_to_cdx.py` writes it from
/// `pubspec.lock`, CI and `test/info/sbom_sync_test.dart` keep it in sync.
const sbomAssetPath = 'assets/sbom/triiq.cdx.json';

/// How a package got into the build.
enum SbomKind { direct, dev, transitive }

/// One package of the SBOM.
class SbomPackage {
  const SbomPackage({
    required this.name,
    required this.version,
    required this.kind,
    required this.source,
    required this.scope,
    this.purl,
    this.sha256,
  });

  final String name;
  final String version;
  final SbomKind kind;

  /// hosted, sdk, git, path.
  final String source;

  /// CycloneDX scope: required or optional (dev dependencies).
  final String scope;
  final String? purl;
  final String? sha256;

  /// Where a hosted package has its page; null for the SDK ones.
  Uri? get pubDevUrl =>
      source == 'hosted' ? Uri.parse('https://pub.dev/packages/$name') : null;

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q) ||
        version.toLowerCase().contains(q) ||
        source.toLowerCase().contains(q) ||
        kind.name.contains(q);
  }
}

/// A parsed CycloneDX SBOM.
class Sbom {
  const Sbom({
    required this.format,
    required this.specVersion,
    required this.appName,
    required this.appVersion,
    required this.packages,
    required this.raw,
  });

  final String format;
  final String specVersion;
  final String appName;

  /// The app version the SBOM was generated for ("0.9.5+1").
  final String appVersion;
  final List<SbomPackage> packages;

  /// The JSON text as bundled — what Export hands out.
  final String raw;

  int count(SbomKind kind) => packages.where((p) => p.kind == kind).length;

  List<SbomPackage> search(String query) => [
    for (final p in packages)
      if (p.matches(query)) p,
  ];

  /// Throws [FormatException] when [text] is not a CycloneDX document.
  factory Sbom.parse(String text) {
    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      throw const FormatException('Not valid JSON.');
    }
    if (decoded is! Map<String, dynamic> ||
        decoded['bomFormat'] != 'CycloneDX') {
      throw const FormatException('Not a CycloneDX document.');
    }
    final app = (decoded['metadata'] as Map?)?['component'] as Map?;
    final components = decoded['components'];
    if (components is! List) {
      throw const FormatException('The SBOM has no components.');
    }
    final packages = <SbomPackage>[];
    for (final c in components) {
      if (c is! Map) continue;
      final name = c['name'];
      if (name is! String) continue;
      final props = <String, String>{
        for (final p in (c['properties'] as List? ?? const []))
          if (p is Map && p['name'] is String && p['value'] is String)
            p['name'] as String: p['value'] as String,
      };
      final scope = c['scope'] as String? ?? 'required';
      final kind = switch (props['triiq:dependency']) {
        'direct' => SbomKind.direct,
        'dev' => SbomKind.dev,
        'transitive' => SbomKind.transitive,
        _ => scope == 'optional' ? SbomKind.dev : SbomKind.transitive,
      };
      final hashes = c['hashes'] as List? ?? const [];
      packages.add(
        SbomPackage(
          name: name,
          version: '${c['version'] ?? ''}',
          kind: kind,
          source: props['triiq:source'] ?? 'unknown',
          scope: scope,
          purl: c['purl'] as String?,
          sha256: hashes.isEmpty
              ? null
              : (hashes.first as Map)['content'] as String?,
        ),
      );
    }
    packages.sort((a, b) => a.name.compareTo(b.name));
    return Sbom(
      format: 'CycloneDX',
      specVersion: '${decoded['specVersion'] ?? ''}',
      appName: '${app?['name'] ?? 'triiq'}',
      appVersion: '${app?['version'] ?? ''}',
      packages: packages,
      raw: text,
    );
  }

  /// Reads and parses the bundled asset. Throws when it is missing or
  /// broken; the screen shows that instead of crashing.
  static Future<Sbom> load({AssetBundle? bundle}) async =>
      Sbom.parse(await (bundle ?? rootBundle).loadString(sbomAssetPath));
}
