import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Keeps widgets on the design tokens (Design.md, CLAUDE.md "Design"):
/// fails when a hex colour, a decorative gradient, an unbundled font
/// weight, the generic monospace font or an off-token radius appears in
/// `lib/` outside the theme, the generated client and the developer
/// (terminal) theme in `lib/app.dart`.
void main() {
  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where(
        (f) =>
            !f.path.contains('lib/theme/') &&
            !f.path.contains('lib/client/') &&
            !f.path.contains('lib/l10n/') &&
            !f.path.endsWith('lib/app.dart'),
      )
      .toList();

  List<String> hits(RegExp pattern, {Set<String> allow = const {}}) => [
    for (final f in files)
      if (!allow.any(f.path.endsWith))
        for (final (i, line) in f.readAsLinesSync().indexed)
          if (pattern.hasMatch(line) && !line.trimLeft().startsWith('//'))
            '${f.path}:${i + 1}: ${line.trim()}',
  ];

  test('no hex colour literals in widgets', () {
    expect(hits(RegExp(r'Color\(0x')), isEmpty);
  });

  test('no decorative gradients (chart area fills are data)', () {
    expect(
      hits(
        RegExp(r'(Linear|Radial|Sweep)Gradient\('),
        allow: {
          'widgets/charts/line_chart.dart',
          'widgets/charts/stream_chart.dart',
          'widgets/gauge_ring.dart',
        },
      ),
      isEmpty,
    );
  });

  test('only bundled font weights (400, 500, 700)', () {
    expect(
      hits(RegExp(r'FontWeight\.w(1|2|3|6|8|9)00|FontWeight\.bold')),
      isEmpty,
    );
  });

  test('code text uses JetBrains Mono, not the generic monospace', () {
    expect(hits(RegExp(r"fontFamily: 'monospace'")), isEmpty);
  });

  test('radii from the token set', () {
    final allowed = {'1.5', '2', '4', '6', '8', '12'};
    final bad = [
      for (final h in hits(RegExp(r'Radius\.circular\(')))
        for (final m in RegExp(r'Radius\.circular\(([\d.]+)\)').allMatches(h))
          if (!allowed.contains(m.group(1))) h,
    ];
    expect(bad, isEmpty);
  });
}
