import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/data/models/local_wellness.dart';
import 'package:triiq/data/repositories/wellness_repository.dart';
import 'package:triiq/evaluation/readiness.dart';
import 'package:triiq/evaluation/readiness_service.dart';
import 'package:triiq/evaluation/readiness_settings.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/today/readiness_card.dart';
import 'package:triiq/screens/today/readiness_screen.dart';
import 'package:triiq/util/dates.dart';

final _today = dateOnly(DateTime.now());

LocalWellness _day(int daysAgo, {num? hrv, num? rhr, num? sleepSecs}) {
  final date = isoDate(
    DateTime(_today.year, _today.month, _today.day - daysAgo),
  );
  return LocalWellness(
    date: date,
    ctl: 60,
    atl: 60,
    ctlLoad: null,
    atlLoad: null,
    rampRate: null,
    raw: {'id': date, 'hrv': ?hrv, 'restingHR': ?rhr, 'sleepSecs': ?sleepSecs},
    syncedAt: DateTime(2026),
  );
}

/// A normal baseline and a bad night: sleep alone drives "caution".
List<LocalWellness> _records() => [
  for (var i = 1; i <= 40; i++)
    _day(i, hrv: 62 + (i.isEven ? 6 : -6), rhr: 48, sleepSecs: 8 * 3600),
  _day(0, hrv: 63, rhr: 47, sleepSecs: 5 * 3600),
];

Widget _app(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() => ReadinessSettings.instance.reset());

  group('evaluation', () {
    test('a switched-off signal is shown but never counts', () {
      final all = evaluateReadiness(_records(), _today);
      expect(all.level, ReadinessLevel.caution);
      expect(all.reasons.map((s) => s.kind), [ReadinessSignalKind.sleep]);

      final noSleep = evaluateReadiness(
        _records(),
        _today,
        enabled: ReadinessSignalKind.values.toSet()
          ..remove(ReadinessSignalKind.sleep),
      );
      expect(noSleep.level, ReadinessLevel.ready);
      expect(noSleep.reasons, isEmpty);
      final sleep = noSleep.signal(ReadinessSignalKind.sleep);
      expect(sleep.rating, SignalRating.excluded);
      expect(sleep.value, closeTo(5, 1e-9)); // still displayable
      expect(
        noSleep.active.map((s) => s.kind),
        isNot(contains(ReadinessSignalKind.sleep)),
      );
    });

    test('the score only averages the signals that count', () {
      final all = readinessScore(evaluateReadiness(_records(), _today))!;
      final noSleep = readinessScore(
        evaluateReadiness(
          _records(),
          _today,
          enabled: ReadinessSignalKind.values.toSet()
            ..remove(ReadinessSignalKind.sleep),
        ),
      )!;
      expect(all, lessThan(100));
      expect(noSleep, 100);
    });

    test(
      'with no wearable signal on there is no waiting for wearable data',
      () {
        final r = evaluateReadiness(
          [_day(0)],
          _today,
          enabled: {ReadinessSignalKind.form},
        );
        expect(r.dataState, ReadinessDataState.complete);
        expect(r.active.single.kind, ReadinessSignalKind.form);
      },
    );
  });

  group('settings', () {
    test('default is all on; a choice is stored and restored', () async {
      final a = ReadinessSettings.forTesting();
      await a.load();
      expect(a.enabled, ReadinessSignalKind.values.toSet());

      expect(await a.setEnabled(ReadinessSignalKind.hrv, false), isTrue);
      expect(a.isEnabled(ReadinessSignalKind.hrv), isFalse);

      // A fresh instance (an app restart) reads it back.
      final b = ReadinessSettings.forTesting();
      await b.load();
      expect(b.isEnabled(ReadinessSignalKind.hrv), isFalse);
      expect(b.isEnabled(ReadinessSignalKind.sleep), isTrue);
    });

    test('the last signal that counts cannot be switched off', () async {
      final s = ReadinessSettings.forTesting();
      for (final k in ReadinessSignalKind.values.skip(1)) {
        await s.setEnabled(k, false);
      }
      expect(s.enabled, {ReadinessSignalKind.values.first});
      expect(
        await s.setEnabled(ReadinessSignalKind.values.first, false),
        isFalse,
      );
      expect(s.enabled, hasLength(1));
    });

    test('the service rates with the stored selection', () async {
      final repo = WellnessRepository();
      await repo.upsertAll(_records());
      final settings = ReadinessSettings.forTesting();
      final service = ReadinessService(wellness: repo, settings: settings);

      expect((await service.load()).readiness.level, ReadinessLevel.caution);
      await settings.setEnabled(ReadinessSignalKind.sleep, false);
      expect((await service.load()).readiness.level, ReadinessLevel.ready);
    });
  });

  group('screens', () {
    testWidgets('long-press on the card opens the choice; it is stored', (
      tester,
    ) async {
      final report = ReadinessReport(
        evaluateReadiness(_records(), _today),
        _records(),
      );
      await tester.pumpWidget(_app(ReadinessCard(report: report)));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('pill-sleep')), findsOneWidget);

      // On the score ring: a long press on a pill peeks instead.
      await tester.longPress(find.byKey(const ValueKey('readiness-score')));
      await tester.pumpAndSettle();
      expect(find.text('Readiness signals'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('readiness-option-sleep')));
      await tester.pumpAndSettle();
      expect(
        ReadinessSettings.instance.isEnabled(ReadinessSignalKind.sleep),
        isFalse,
      );
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('readiness.disabled_signals'), ['sleep']);
    });

    testWidgets('the sheet picks the HRV / resting-HR smoothing window', (
      tester,
    ) async {
      final report = ReadinessReport(
        evaluateReadiness(_records(), _today),
        _records(),
      );
      await tester.pumpWidget(_app(ReadinessCard(report: report)));
      await tester.pumpAndSettle();
      await tester.longPress(find.byKey(const ValueKey('readiness-score')));
      await tester.pumpAndSettle();
      final five = find.text('5 days');
      await tester.ensureVisible(five);
      await tester.pumpAndSettle();
      await tester.tap(five);
      await tester.pumpAndSettle();
      expect(ReadinessSettings.instance.smoothingDays, 5);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('readiness.smoothing_days'), 5);
      await ReadinessSettings.instance.setSmoothingDays(null);
    });

    testWidgets('the card shows pills only for the signals that count', (
      tester,
    ) async {
      final report = ReadinessReport(
        evaluateReadiness(
          _records(),
          _today,
          enabled: ReadinessSignalKind.values.toSet()
            ..remove(ReadinessSignalKind.sleep),
        ),
        _records(),
      );
      await tester.pumpWidget(_app(ReadinessCard(report: report)));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('pill-sleep')), findsNothing);
      expect(find.byKey(const ValueKey('pill-hrv')), findsOneWidget);
    });

    testWidgets('the detail screen re-rates when the selection changes', (
      tester,
    ) async {
      await tester.runAsync(() => WellnessRepository().upsertAll(_records()));
      final settings = ReadinessSettings.forTesting();
      final records = _records();
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: ReadinessScreen(
            report: ReadinessReport(
              evaluateReadiness(records, _today),
              records,
            ),
            settings: settings,
            service: ReadinessService(
              wellness: WellnessRepository(),
              settings: settings,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Caution'), findsWidgets);
      expect(find.text('Not used'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('chart-options')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('readiness-option-sleep')));
      for (var i = 0; i < 10; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(find.textContaining('Not used'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
    });
  });
}
