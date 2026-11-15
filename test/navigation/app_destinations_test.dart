import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/navigation/app_destinations.dart';
import 'package:triiq/navigation/navigation_layout.dart';
import 'package:triiq/navigation/okf_index.dart';
import 'package:triiq/screens/more/more_screen.dart';
import 'package:triiq/screens/settings/settings_screen.dart';
import 'package:triiq/screens/statistics/insights_grid.dart';

void main() {
  final okf = OkfIndex.parse(File('docs/okf.md').readAsStringSync());
  final ids = {for (final d in appDestinations) d.id};

  test('ids are unique', () {
    expect(ids, hasLength(appDestinations.length));
  });

  test('every okf anchor points at an existing okf passage', () {
    for (final d in appDestinations) {
      expect(okf.resolve(d.okfAnchor), isNotNull, reason: d.okfAnchor);
      expect(okf.excerpt(d.okfAnchor), isNotEmpty, reason: d.okfAnchor);
    }
  });

  test('excerpts carry no developer references', () {
    for (final d in appDestinations) {
      final text = okf.excerpt(d.okfAnchor, maxChars: 5000);
      expect(text, isNot(contains('lib/')), reason: d.id);
      expect(text, isNot(contains('.dart')), reason: d.id);
      expect(text, isNot(contains('**')), reason: d.id);
    }
  });

  test('only the user-facing parts of okf are indexed', () {
    // Architecture (section 2) and training knowledge (section 5) headings.
    expect(okf.resolve('Navigation'), isNull);
    expect(okf.resolve('The training agent'), isNull);
    expect(okf.resolve('5.1 Block rules'), isNull);
    expect(okf.resolve('Search the app'), isNotNull);
    expect(okf.resolve('Ask the trainer where something is'), isNotNull);
  });

  test('the catalogue covers every tab, Insights tile, More entry and '
      'Settings group and section', () {
    for (final tab in ['today', 'calendar', 'chat', 'insights', 'more']) {
      expect(ids, contains('tab.$tab'));
    }
    for (final d in insightsDestinations) {
      expect(ids, contains('insights.${d.id}'), reason: d.id);
    }
    for (final e in moreEntries) {
      expect(ids, contains('more.${e.id}'), reason: e.id);
    }
    for (final g in SettingsGroup.values) {
      expect(ids, contains('settings.group.${g.name}'), reason: g.name);
    }
    for (final s in SettingsSection.values) {
      expect(ids, contains('settings.${s.name}'), reason: s.name);
    }
    expect(ids, containsAll(['profile', 'settings']));
  });

  test('every destination has a title and breadcrumb in English and German, '
      'and lowercase keywords', () {
    for (final locale in const [Locale('en'), Locale('de')]) {
      final l10n = lookupAppLocalizations(locale);
      for (final d in appDestinations) {
        expect(d.title(l10n), isNotEmpty, reason: d.id);
        expect(d.path(l10n), endsWith(d.title(l10n)), reason: d.id);
        expect(d.describe(l10n, okf), isNotEmpty, reason: d.id);
      }
    }
    for (final d in appDestinations) {
      for (final k in d.keywords) {
        expect(k, k.toLowerCase(), reason: d.id);
      }
    }
  });

  test('breadcrumbs read like the app', () {
    final en = lookupAppLocalizations(const Locale('en'));
    expect(
      destinationById('insights.durability')!.path(en),
      'Insights › Durability',
    );
    expect(
      destinationById('settings.notifications.weekly-review')!.path(en),
      'Settings › App › Notifications › Weekly review',
    );
    final de = lookupAppLocalizations(const Locale('de'));
    expect(
      destinationById('insights.durability')!.path(de),
      'Einblicke › Ermüdungsresistenz',
    );
  });

  test('Info is found by version, sbom and licence words, in both languages '
      'and is a More entry that can be pinned to the bar', () {
    for (final q in const [
      'version',
      'sbom',
      'bill of materials',
      'licenses',
      'build',
      'open source',
      'about',
      'lizenzen',
      'stückliste',
    ]) {
      expect(
        searchDestinations(q, okf: okf).map((d) => d.id),
        contains('more.info'),
        reason: q,
      );
    }
    expect(NavigationLayout.defaultKnown(), contains('info'));
    expect(
      destinationById('more.info')!.path(
        lookupAppLocalizations(const Locale('en')),
      ),
      'More › Info',
    );
  });

  test('userText strips code references and emphasis', () {
    expect(
      OkfIndex.userText(
        '✅ Implemented — **Bold** text (`lib/x.dart`) and `test/a.dart` '
        'with *emphasis*.',
      ),
      'Bold text and with emphasis.',
    );
  });
}
