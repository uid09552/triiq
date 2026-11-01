import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/agent/knowledge_sections.dart';

void main() {
  group('splitGuidanceSections', () {
    test('splits on level-1 headings', () {
      final sections = splitGuidanceSections(
        '# CSS test\n\nSwim CSS body.\n\n'
        '# Threshold sets\n\nThreshold body.\n\n'
        '# Drills\n\nDrills body.\n',
        fallbackTitle: 'swim-css',
      );

      expect(sections.map((s) => s.title), [
        'CSS test',
        'Threshold sets',
        'Drills',
      ]);
      expect(sections[0].body, 'Swim CSS body.');
    });

    test('no heading falls back to one section titled after the file', () {
      final sections = splitGuidanceSections(
        'Just plain notes about tapering, no heading at all.',
        fallbackTitle: 'taper-notes',
      );

      expect(sections, hasLength(1));
      expect(sections.single.title, 'taper-notes');
      expect(
        sections.single.body,
        'Just plain notes about tapering, no heading at all.',
      );
    });

    test('an empty document has no sections, not a fallback one', () {
      expect(splitGuidanceSections('   \n\n', fallbackTitle: 'empty'), isEmpty);
      expect(splitGuidanceSections('', fallbackTitle: 'empty'), isEmpty);
    });
  });

  group('stripOkfFences', () {
    test('strips a single okf-template block and counts it', () {
      final result = stripOkfFences('''
Some prose before.

```okf-template
{"id": "x"}
```

Some prose after.
''');

      expect(result.ignoredBlocks, 1);
      expect(result.text, isNot(contains('okf-template')));
      expect(result.text, contains('Some prose before.'));
      expect(result.text, contains('Some prose after.'));
    });

    test('strips several blocks of different okf- kinds', () {
      final result = stripOkfFences('''
```okf-rules
{"a": 1}
```

```okf-goal
{"b": 2}
```
''');

      expect(result.ignoredBlocks, 2);
      expect(result.text, isNot(contains('okf-')));
    });

    test('leaves non-okf fences untouched', () {
      const input = '''
```dart
print('hi');
```
''';
      final result = stripOkfFences(input);

      expect(result.ignoredBlocks, 0);
      expect(result.text, input);
    });

    test('an unterminated okf- fence is left as plain text', () {
      const input = '''
```okf-template
{"id": "x"}
no closing fence here
''';
      final result = stripOkfFences(input);

      expect(result.ignoredBlocks, 0);
      expect(result.text, input);
    });
  });
}
