import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/navigation/app_destinations.dart';
import 'package:triiq/navigation/app_search.dart';
import 'package:triiq/navigation/okf_index.dart';

void main() {
  final okf = OkfIndex.parse(File('docs/okf.md').readAsStringSync());

  String? top(String query, {OkfIndex? index}) {
    final results = searchDestinations(query, okf: index ?? okf);
    return results.isEmpty ? null : results.first.id;
  }

  group('ranking', () {
    final cases = <String, String>{
      // English titles
      'durability': 'insights.durability',
      'weekly review notification': 'settings.notifications.weekly-review',
      'load heatmap': 'insights.heatmap',
      // German titles
      'Ermüdungsresistenz': 'insights.durability',
      'Wochenrückblick Benachrichtigung':
          'settings.notifications.weekly-review',
      'Sprache': 'settings.language',
      // Synonyms / keywords
      'dark mode': 'settings.appearance',
      'dunkel': 'settings.appearance',
      'Ruhepuls': 'insights.wellness',
      'hrv': 'insights.wellness',
      'ftp': 'insights.curves',
      'api key intervals': 'profile',
      // Typos and folded umlauts
      'durabilty': 'insights.durability',
      'heatmpa': 'insights.heatmap',
      'mudigkeit': 'settings.feel',
      'wochenruckblick': 'insights.weekly-review',
      // Question filler
      'where is the heatmap': 'insights.heatmap',
      'wo finde ich die Bestleistungen': 'insights.best-efforts',
      'how do I change the language': 'settings.language',
    };
    for (final entry in cases.entries) {
      test('"${entry.key}" → ${entry.value}', () {
        expect(top(entry.key), entry.value);
      });
    }
  });

  test('works before the okf text has loaded', () {
    expect(searchDestinations('durability').first.id, 'insights.durability');
  });

  test('a blank query or gibberish finds nothing', () {
    expect(searchDestinations('  '), isEmpty);
    expect(searchDestinations('xyzzyqq'), isEmpty);
  });

  test('normalization folds case, umlauts and punctuation', () {
    expect(normalizeSearchText('Müdigkeit & SCHLAF!'), 'mudigkeit schlaf');
    expect(searchTerms('where is the heatmap?'), ['heatmap']);
    expect(searchTerms('wo ist die Sprache'), ['sprache']);
  });

  test('a title hit outranks a description-only hit', () {
    final doc1 = SearchDocument(titles: ['Sleep']);
    final doc2 = SearchDocument(titles: ['Other'], descriptions: ['sleep']);
    expect(doc1.score('sleep'), greaterThan(doc2.score('sleep')));
  });
}
