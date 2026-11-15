import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/info/sbom.dart';

const _sample = '''
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.5",
  "metadata": {"component": {"name": "triiq", "version": "0.9.5+1"}},
  "components": [
    {"name": "http", "version": "1.6.0", "scope": "required",
     "purl": "pkg:pub/http@1.6.0",
     "hashes": [{"alg": "SHA-256", "content": "abc"}],
     "properties": [
       {"name": "triiq:dependency", "value": "direct"},
       {"name": "triiq:source", "value": "hosted"}]},
    {"name": "flutter_lints", "version": "6.0.0", "scope": "optional",
     "properties": [
       {"name": "triiq:dependency", "value": "dev"},
       {"name": "triiq:source", "value": "hosted"}]},
    {"name": "meta", "version": "1.16.0",
     "properties": [
       {"name": "triiq:dependency", "value": "transitive"},
       {"name": "triiq:source", "value": "sdk"}]}
  ]
}
''';

void main() {
  test('parses packages, kinds, counts and the app version', () {
    final sbom = Sbom.parse(_sample);
    expect(sbom.specVersion, '1.5');
    expect(sbom.appVersion, '0.9.5+1');
    expect(sbom.packages.map((p) => p.name), ['flutter_lints', 'http', 'meta']);
    expect(sbom.count(SbomKind.direct), 1);
    expect(sbom.count(SbomKind.dev), 1);
    expect(sbom.count(SbomKind.transitive), 1);
    final http = sbom.packages.firstWhere((p) => p.name == 'http');
    expect(http.sha256, 'abc');
    expect(http.pubDevUrl.toString(), 'https://pub.dev/packages/http');
    expect(sbom.packages.last.pubDevUrl, isNull);
  });

  test('search matches name, version, source and kind', () {
    final sbom = Sbom.parse(_sample);
    expect(sbom.search('HTT').map((p) => p.name), ['http']);
    expect(sbom.search('1.16').map((p) => p.name), ['meta']);
    expect(sbom.search('sdk').map((p) => p.name), ['meta']);
    expect(sbom.search('dev').map((p) => p.name), ['flutter_lints']);
    expect(sbom.search('  '), hasLength(3));
    expect(sbom.search('zzz'), isEmpty);
  });

  test('anything that is not a CycloneDX document is a FormatException', () {
    expect(() => Sbom.parse('nope'), throwsFormatException);
    expect(() => Sbom.parse('{"bomFormat": "SPDX"}'), throwsFormatException);
    expect(
      () => Sbom.parse('{"bomFormat": "CycloneDX"}'),
      throwsFormatException,
    );
  });

  testWidgets('loads the bundled asset', (tester) async {
    final sbom = await tester.runAsync(Sbom.load);
    expect(sbom!.packages, isNotEmpty);
    expect(sbom.packages.map((p) => p.name), contains('package_info_plus'));
  });

  testWidgets('a missing asset throws', (tester) async {
    await tester.runAsync(() async {
      await expectLater(
        Sbom.load(bundle: _EmptyBundle()),
        throwsA(isA<FlutterError>()),
      );
    });
  });
}

class _EmptyBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) =>
      Future.error(FlutterError('Unable to load asset: $key'));
}
