import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/info/sbom.dart';

/// name -> (version, dependency) of every package in pubspec.lock.
Map<String, (String, String)> _lockPackages() {
  final result = <String, (String, String)>{};
  String? name, dependency;
  var inPackages = false;
  for (final line in File('pubspec.lock').readAsLinesSync()) {
    if (RegExp(r'^packages:\s*$').hasMatch(line)) {
      inPackages = true;
    } else if (RegExp(r'^\S').hasMatch(line)) {
      inPackages = false;
    } else if (inPackages) {
      final n = RegExp(r'^  ([^\s:][^:]*):\s*$').firstMatch(line);
      if (n != null) {
        name = n.group(1)!.replaceAll('"', '');
        continue;
      }
      final d = RegExp(r'^    dependency:\s*"?([^"]+)"?\s*$').firstMatch(line);
      if (d != null) dependency = d.group(1);
      final v = RegExp(r'^    version:\s*"?([^"]+)"?\s*$').firstMatch(line);
      if (v != null && name != null) {
        result[name] = (v.group(1)!, dependency ?? '');
      }
    }
  }
  return result;
}

String _kindOf(String dependency) => switch (dependency) {
  'direct main' || 'direct overridden' => 'direct',
  'direct dev' => 'dev',
  _ => 'transitive',
};

const _fix =
    'The bundled SBOM is out of date. Regenerate it and commit the result:\n'
    '  python3 tool/pubspec_lock_to_cdx.py pubspec.lock pubspec.yaml '
    '> assets/sbom/triiq.cdx.json';

bool get _hasPython {
  try {
    return Process.runSync('python3', ['--version']).exitCode == 0;
  } catch (_) {
    return false;
  }
}

void main() {
  late Sbom sbom;
  setUpAll(() {
    sbom = Sbom.parse(File('assets/sbom/triiq.cdx.json').readAsStringSync());
  });

  test('the bundled SBOM lists exactly the packages and versions of '
      'pubspec.lock', () {
    final lock = _lockPackages();
    final bundled = {for (final p in sbom.packages) p.name: p.version};
    expect(lock, isNotEmpty);
    expect(
      bundled.keys.toSet().difference(lock.keys.toSet()),
      isEmpty,
      reason: _fix,
    );
    expect(
      lock.keys.toSet().difference(bundled.keys.toSet()),
      isEmpty,
      reason: _fix,
    );
    for (final e in lock.entries) {
      expect(bundled[e.key], e.value.$1, reason: '${e.key}. $_fix');
    }
    expect(sbom.packages.length, lock.length, reason: _fix);
  });

  test('direct, dev and transitive follow the lockfile', () {
    final lock = _lockPackages();
    for (final p in sbom.packages) {
      expect(p.kind.name, _kindOf(lock[p.name]!.$2), reason: p.name);
    }
    expect(sbom.count(SbomKind.direct), greaterThan(0));
    expect(sbom.count(SbomKind.dev), greaterThan(0));
  });

  test('the SBOM is generated for the version in pubspec.yaml', () {
    final version = RegExp(
      r'^version:\s*(\S+)',
      multiLine: true,
    ).firstMatch(File('pubspec.yaml').readAsStringSync())!.group(1);
    expect(sbom.appVersion, version, reason: _fix);
  });

  test('is CycloneDX 1.5 and has nothing that changes on every run', () {
    final json = jsonDecode(sbom.raw) as Map<String, dynamic>;
    expect(json['bomFormat'], 'CycloneDX');
    expect(json['specVersion'], '1.5');
    expect(json.containsKey('serialNumber'), isFalse);
    expect((json['metadata'] as Map).containsKey('timestamp'), isFalse);
  });

  test(
    'regenerating gives byte-identical output, twice',
    () {
      String run() {
        final r = Process.runSync('python3', [
          'tool/pubspec_lock_to_cdx.py',
          'pubspec.lock',
          'pubspec.yaml',
        ]);
        expect(r.exitCode, 0, reason: '${r.stderr}');
        return r.stdout as String;
      }

      final first = run();
      expect(run(), first);
      expect(first, sbom.raw, reason: _fix);
    },
    skip: _hasPython ? false : 'python3 is not available',
  );
}
