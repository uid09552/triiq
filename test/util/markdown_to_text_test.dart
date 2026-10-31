import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/util/markdown_to_text.dart';

/// Google Calendar's description field doesn't render Markdown, so an
/// agent reply pasted straight in needs this to strip the markup first.
void main() {
  test('strips headings, bold/italic, and inline code', () {
    final text = markdownToPlainText(
      '# Easy run\n\nKeep it **relaxed** and *conversational*, `Zone 2`.',
    );

    expect(text, 'Easy run\n\nKeep it relaxed and conversational, Zone 2.');
  });

  test('turns bullet list markers into bullets', () {
    final text = markdownToPlainText('- Warm up 10m\n- Main set 30m');

    expect(text, '• Warm up 10m\n• Main set 30m');
  });

  test('converts a table to one line per row, cells joined by " · "', () {
    final text = markdownToPlainText('''
| Segment | Duration | Session |
| --- | --- | --- |
| Warm-up | 10m | Easy |
| Main | 3x8min | 100% FTP |
''');

    expect(
      text,
      'Segment · Duration · Session\nWarm-up · 10m · Easy\nMain · 3x8min · 100% FTP',
    );
  });

  test('drops a standalone horizontal rule', () {
    final text = markdownToPlainText('Before\n\n---\n\nAfter');

    expect(text, 'Before\n\nAfter');
  });

  test('turns a link into text plus the URL', () {
    final text = markdownToPlainText('See [the guide](https://example.com).');

    expect(text, 'See the guide (https://example.com).');
  });
}
