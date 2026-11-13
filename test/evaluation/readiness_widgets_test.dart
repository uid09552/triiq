import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/agent/chat_handoff.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/data/models/local_wellness.dart';
import 'package:triiq/data/planned_items.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/data/repositories/events_repository.dart';
import 'package:triiq/data/repositories/plans_repository.dart';
import 'package:triiq/data/repositories/wellness_repository.dart';
import 'package:triiq/evaluation/readiness.dart';
import 'package:triiq/evaluation/readiness_service.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/plan/knowledge.dart';
import 'package:triiq/screens/today/readiness_card.dart';
import 'package:triiq/screens/today/readiness_peek.dart';
import 'package:triiq/screens/today/readiness_screen.dart';
import 'package:triiq/screens/today/today_screen.dart';
import 'package:triiq/util/dates.dart';
import 'package:triiq/widgets/main_navigation.dart';

final _today = dateOnly(DateTime.now());

LocalWellness _day(
  int daysAgo, {
  num? hrv,
  num? rhr,
  num? sleepSecs,
  double ctl = 60,
  double atl = 60,
  double? atlLoad,
  num? readiness,
  int? fatigue,
}) {
  final date = isoDate(
    DateTime(_today.year, _today.month, _today.day - daysAgo),
  );
  return LocalWellness(
    date: date,
    ctl: ctl,
    atl: atl,
    ctlLoad: null,
    atlLoad: atlLoad,
    rampRate: null,
    raw: {
      'id': date,
      'hrv': ?hrv,
      'restingHR': ?rhr,
      'sleepSecs': ?sleepSecs,
      'readiness': ?readiness,
      'fatigue': ?fatigue,
    },
    syncedAt: DateTime(2026),
  );
}

/// 40 days of HRV 62 ± 4 (median 62, MADσ ≈ 5.9) and resting HR 48,
/// starting [from] days ago.
List<LocalWellness> _baseline({int from = 1}) => [
  for (var i = from; i < from + 40; i++)
    _day(i, hrv: 62 + (i.isEven ? 4 : -4), rhr: 48, sleepSecs: 8 * 3600),
];

/// The baseline, then the two days before today at [hrv] / [rhr]: HRV and
/// resting HR are rated by their 3-day median, so a change has to last.
List<LocalWellness> _sustained({num hrv = 62, num rhr = 48}) => [
  ..._baseline(from: 3),
  for (final d in [2, 1]) _day(d, hrv: hrv, rhr: rhr, sleepSecs: 8 * 3600),
];

ReadinessReport _report(List<LocalWellness> records) =>
    ReadinessReport(evaluateReadiness(records, _today), records);

LocalEvent _planned(String name, String slot) => LocalEvent(
  id: 'plan-$slot',
  date: isoDate(_today),
  category: 'WORKOUT',
  type: 'Run',
  name: name,
  description: null,
  plannedLoad: 80,
  plannedTime: 3600,
  plannedDistance: null,
  indoor: false,
  raw: {LocalEvent.planSessionKey: 1, LocalEvent.planSlotKey: slot},
  syncedAt: DateTime(2026),
);

Widget _app(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: Scaffold(body: child),
);

void main() {
  group('hold a pill to peek', () {
    List<LocalWellness> records() => [
      for (var i = 40; i >= 1; i--)
        _day(
          i,
          hrv: 62 + (i.isEven ? 6 : -6),
          rhr: 48,
          sleepSecs: 8 * 3600,
          atlLoad: 55,
        ),
      _day(
        0,
        hrv: 62,
        rhr: 48,
        sleepSecs: 7.5 * 3600,
        atl: 66,
        atlLoad: 100,
        readiness: 72,
        fatigue: 2,
      ),
    ];

    Future<TestGesture> hold(WidgetTester tester, String key) async {
      final g = await tester.startGesture(
        tester.getCenter(find.byKey(ValueKey(key))),
      );
      await tester.pump(const Duration(milliseconds: 650));
      await tester.pump(const Duration(milliseconds: 300));
      return g;
    }

    Future<void> pumpCard(WidgetTester tester) async {
      tester.view.physicalSize = const Size(420, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app(ReadinessCard(report: _report(records()))));
      await tester.pumpAndSettle();
    }

    testWidgets('holding the HRV pill shows its peek; letting go hides it, '
        'and the card\'s own long press does not fire', (tester) async {
      await pumpCard(tester);
      expect(find.byKey(const ValueKey('hold-preview')), findsNothing);

      final g = await hold(tester, 'pill-hrv');
      expect(find.byKey(const ValueKey('hold-preview')), findsOneWidget);
      expect(find.byKey(const ValueKey('readiness-peek-hrv')), findsOneWidget);
      expect(find.textContaining('Normal from'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
      expect(find.text('Readiness signals'), findsNothing);

      await g.up();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('hold-preview')), findsNothing);
      expect(find.text('Readiness signals'), findsNothing);
    });

    testWidgets('a long press elsewhere on the card still opens the options', (
      tester,
    ) async {
      await pumpCard(tester);
      await tester.longPress(find.byKey(const ValueKey('readiness-score')));
      await tester.pumpAndSettle();
      expect(find.text('Readiness signals'), findsOneWidget);
      expect(find.byKey(const ValueKey('hold-preview')), findsNothing);
    });

    testWidgets('a quick tap on a pill still opens the detail screen', (
      tester,
    ) async {
      await pumpCard(tester);
      await tester.tap(find.byKey(const ValueKey('pill-sleep')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('hold-preview')), findsNothing);
      expect(find.text('Readiness'), findsWidgets);
    });

    testWidgets('every pill has a peek that builds', (tester) async {
      await pumpCard(tester);
      for (final key in [
        'hrv',
        'restingHr',
        'sleep',
        'form',
        'subjective',
        'load',
        'device',
        'fitness',
      ]) {
        expect(find.byKey(ValueKey('pill-$key')), findsOneWidget, reason: key);
        final g = await hold(tester, 'pill-$key');
        expect(
          find.byKey(ValueKey('readiness-peek-$key')),
          findsOneWidget,
          reason: key,
        );
        await g.up();
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('hold-preview')), findsNothing);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('the peeks say what the signal is and today\'s figure', (
      tester,
    ) async {
      await pumpCard(tester);
      var g = await hold(tester, 'pill-sleep');
      expect(find.text('Hours slept last night'), findsOneWidget);
      expect(find.text('7 h 30 min'), findsOneWidget);
      await g.up();
      await tester.pumpAndSettle();

      g = await hold(tester, 'pill-load');
      expect(find.textContaining('100 TSS today'), findsOneWidget);
      expect(find.text('Caution'), findsWidgets);
      await g.up();
      await tester.pumpAndSettle();

      g = await hold(tester, 'pill-device');
      expect(find.text('72'), findsWidgets);
      await g.up();
      await tester.pumpAndSettle();

      g = await hold(tester, 'pill-fitness');
      expect(find.text('CTL'), findsWidgets);
      expect(find.text('vs a week ago'), findsOneWidget);
      await g.up();
    });

    test('valueOn reads each signal from a wellness record', () {
      final w = records().last;
      double? v(ReadinessSignalKind k) => ReadinessPeek.valueOn(k, w);
      expect(v(ReadinessSignalKind.hrv), 62);
      expect(v(ReadinessSignalKind.restingHr), 48);
      expect(v(ReadinessSignalKind.sleep), 7.5);
      expect(v(ReadinessSignalKind.form), -6);
      expect(v(ReadinessSignalKind.subjective), 2);
      expect(v(ReadinessSignalKind.load), 100);
      expect(v(ReadinessSignalKind.device), 72);
      final empty = _day(0);
      expect(ReadinessPeek.valueOn(ReadinessSignalKind.hrv, empty), isNull);
      expect(ReadinessPeek.valueOn(ReadinessSignalKind.device, empty), isNull);
    });
  });

  group('load and device signals', () {
    List<LocalWellness> records({double? atlLoad, num? readiness}) => [
      ..._baseline(),
      _day(
        0,
        hrv: 62,
        rhr: 48,
        sleepSecs: 8 * 3600,
        atl: 66,
        atlLoad: atlLoad,
        readiness: readiness,
      ),
    ];

    testWidgets('a big session today shows on the card: Load pill and a lower '
        'score', (tester) async {
      await tester.pumpWidget(
        _app(ReadinessCard(report: _report(records(atlLoad: 100)))),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('pill-load')), findsOneWidget);
      expect(find.text('Load'), findsOneWidget);
      expect(find.text('Caution'), findsWidgets);
      final score = int.parse(
        tester
            .widget<Text>(find.byKey(const ValueKey('readiness-score')))
            .data!,
      );
      expect(score, lessThan(100));
    });

    testWidgets('the same day without that session reads 100', (tester) async {
      await tester.pumpWidget(
        _app(ReadinessCard(report: _report(records(atlLoad: 40)))),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('readiness-score'))).data,
        '100',
      );
    });

    testWidgets('the Device pill appears only when the watch wrote a figure', (
      tester,
    ) async {
      await tester.pumpWidget(_app(ReadinessCard(report: _report(records()))));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('pill-device')), findsNothing);

      await tester.pumpWidget(
        _app(ReadinessCard(report: _report(records(readiness: 38)))),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('pill-device')), findsOneWidget);
      expect(find.text('38'), findsOneWidget);
    });

    testWidgets('the detail screen lists Load with today\'s TSS', (
      tester,
    ) async {
      final r = records(atlLoad: 100);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: ReadinessScreen(report: _report(r)),
        ),
      );
      await tester.pump();
      expect(find.text('Load'), findsOneWidget);
      expect(find.textContaining('100 TSS today'), findsOneWidget);
      expect(find.textContaining('ATL ÷ CTL'), findsOneWidget);
    });
  });

  group('readiness card', () {
    testWidgets('Ready', (tester) async {
      await tester.pumpWidget(
        _app(
          ReadinessCard(
            report: _report([
              ..._baseline(),
              _day(0, hrv: 63, rhr: 47, sleepSecs: 8 * 3600),
            ]),
          ),
        ),
      );

      expect(find.textContaining('Ready'), findsOneWidget);
      expect(find.text('All signals in your normal range'), findsOneWidget);
    });

    testWidgets('Back off names its reasons', (tester) async {
      await tester.pumpWidget(
        _app(
          ReadinessCard(
            report: _report([
              ..._sustained(hrv: 52),
              _day(0, hrv: 52, rhr: 48, sleepSecs: 5 * 3600),
            ]),
          ),
        ),
      );

      expect(find.textContaining('Back off'), findsOneWidget);
      expect(find.text('Due to HRV, Sleep'), findsOneWidget);
    });

    testWidgets('shows a score ring, a pill per signal and the fitness trend', (
      tester,
    ) async {
      final records = [
        for (var i = 1; i <= 40; i++)
          _day(
            i,
            hrv: 62 + (i.isEven ? 6 : -6),
            rhr: 48,
            sleepSecs: 8 * 3600,
            ctl: i > 7 ? 50 : 56,
          ),
        _day(0, hrv: 63, rhr: 47, sleepSecs: 8 * 3600, ctl: 60),
      ];
      await tester.pumpWidget(_app(ReadinessCard(report: _report(records))));
      await tester.pumpAndSettle();

      expect(
        tester.widget<Text>(find.byKey(const ValueKey('readiness-score'))).data,
        '100',
      );
      for (final kind in ['hrv', 'restingHr', 'sleep', 'form', 'subjective']) {
        expect(
          find.byKey(ValueKey('pill-$kind')),
          findsOneWidget,
          reason: kind,
        );
      }
      expect(find.byKey(const ValueKey('pill-fitness')), findsOneWidget);
      expect(find.text('60 ↗'), findsOneWidget); // CTL 60, 50 a week earlier
      expect(find.text('8.0 h'), findsOneWidget);
    });

    testWidgets('a back-off score is below 100 and pills keep their values', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          ReadinessCard(
            report: _report([
              ..._sustained(hrv: 52),
              _day(0, hrv: 52, rhr: 48, sleepSecs: 5 * 3600),
            ]),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final score = int.parse(
        tester
            .widget<Text>(find.byKey(const ValueKey('readiness-score')))
            .data!,
      );
      expect(score, lessThan(100));
      expect(find.text('52'), findsOneWidget); // HRV pill
      expect(find.text('5.0 h'), findsOneWidget);
    });

    testWidgets('no wellness data: no ring score, no pills', (tester) async {
      await tester.pumpWidget(_app(ReadinessCard(report: _report([_day(0)]))));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('pill-hrv')), findsNothing);
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('readiness-score'))).data,
        '–',
      );
    });

    testWidgets('no wellness data', (tester) async {
      await tester.pumpWidget(_app(ReadinessCard(report: _report([_day(0)]))));

      expect(find.text('No wellness data'), findsOneWidget);
    });

    testWidgets('waiting for today', (tester) async {
      await tester.pumpWidget(
        _app(ReadinessCard(report: _report([..._baseline(), _day(0)]))),
      );

      expect(find.textContaining("Waiting for today's data"), findsOneWidget);
    });
  });

  group('detail screen', () {
    testWidgets('lists every signal with value, range and rating', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: ReadinessScreen(
            report: _report([
              ..._sustained(hrv: 52),
              _day(
                0,
                hrv: 52,
                rhr: 48,
                sleepSecs: 7 * 3600 + 30 * 60,
                readiness: 71,
                fatigue: 2,
              ),
            ]),
          ),
        ),
      );

      for (final label in [
        'HRV',
        'Resting HR',
        'Sleep',
        'Form',
        'Fatigue / soreness',
      ]) {
        expect(find.text(label), findsWidgets, reason: label);
      }
      expect(find.text('52 ms'), findsOneWidget);
      expect(find.text('7 h 30 min'), findsOneWidget);
      expect(
        find.textContaining('Caution · Normal from 56 ms'),
        findsOneWidget,
      );
      expect(find.text('Device readiness 71'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.textContaining('not medical advice'),
        200,
      );
      expect(find.textContaining('not medical advice'), findsOneWidget);
    });
  });

  group('hard-session hint', () {
    final backOff = evaluateReadiness([
      ..._sustained(hrv: 48),
      _day(0, hrv: 48, rhr: 48, sleepSecs: 8 * 3600),
    ], _today);

    testWidgets('Back off with intervals planned: hint and ask the trainer', (
      tester,
    ) async {
      MainNavigation.instance.debugReset();
      ChatHandoff.instance.take();
      await tester.pumpWidget(
        _app(
          ReadinessHint(
            readiness: backOff,
            todaysPlan: [_planned('Threshold intervals', 'intervals')],
          ),
        ),
      );

      expect(find.text('Consider an easier day'), findsOneWidget);
      await tester.tap(find.text('Ask the trainer'));
      final topic = ChatHandoff.instance.take();
      expect(topic, isNotNull);
      expect(topic!.draft, contains('Threshold intervals'));
      expect(topic.draft, contains('Back off'));
      expect(MainNavigation.instance.requestedTab, MainNavigation.chatTab);
    });

    testWidgets('a long session counts as hard', (tester) async {
      expect(
        ReadinessHint.hardSessionFor(backOff, [_planned('Long run', 'long')]),
        isNotNull,
      );
    });

    testWidgets('Caution with only Z2 planned: no hint', (tester) async {
      final caution = evaluateReadiness([
        ..._sustained(hrv: 52),
        _day(0, hrv: 52, rhr: 48, sleepSecs: 8 * 3600),
      ], _today);
      await tester.pumpWidget(
        _app(
          ReadinessHint(
            readiness: caution,
            todaysPlan: [_planned('Z2 run', 'z2')],
          ),
        ),
      );

      expect(find.text('Consider an easier day'), findsNothing);
    });

    testWidgets('Ready: no hint even with intervals', (tester) async {
      final ready = evaluateReadiness([
        ..._baseline(),
        _day(0, hrv: 62, rhr: 48, sleepSecs: 8 * 3600),
      ], _today);

      expect(
        ReadinessHint.hardSessionFor(ready, [
          _planned('Intervals', 'intervals'),
        ]),
        isNull,
      );
    });
  });

  group('Today', () {
    late Directory dir;
    late AppDatabase database;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      dir = await Directory.systemTemp.createTemp('triiq_today_readiness');
      database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
    });

    tearDown(() async {
      await database.close();
      await dir.delete(recursive: true);
    });

    testWidgets('shows the readiness card from the cached wellness', (
      tester,
    ) async {
      final wellness = WellnessRepository(database: database);
      await tester.runAsync(
        () => wellness.upsertAll([
          ..._sustained(rhr: 60),
          _day(0, hrv: 62, rhr: 60, sleepSecs: 8 * 3600),
        ]),
      );

      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _app(
          TodayScreen(
            wellnessRepository: wellness,
            activitiesRepository: ActivitiesRepository(database: database),
            plannedItems: PlannedItemsRepository(
              events: EventsRepository(database: database),
              plans: PlansRepository(database: database),
              copyEvents: () async => true,
            ),
          ),
        ),
      );
      for (var i = 0; i < 20; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump();
      }

      expect(find.byType(ReadinessCard), findsOneWidget);
      expect(find.text('Due to Resting HR'), findsOneWidget);
      // One verdict: the header above no longer says "Ready to train". A
      // high resting HR with HRV and sleep fine is capped at Caution.
      expect(find.text('Train with care'), findsOneWidget);
      expect(find.text('Ready to train'), findsNothing);
    });

    Future<void> pumpToday(
      WidgetTester tester,
      WellnessRepository wellness,
    ) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _app(
          TodayScreen(
            wellnessRepository: wellness,
            readinessService: ReadinessService(
              wellness: wellness,
              knowledge: KnowledgeRepository(
                loadAsset: () async => File('docs/okf.md').readAsStringSync(),
              ),
            ),
            activitiesRepository: ActivitiesRepository(database: database),
            plannedItems: PlannedItemsRepository(
              events: EventsRepository(database: database),
              plans: PlansRepository(database: database),
              copyEvents: () async => true,
            ),
          ),
        ),
      );
      for (var i = 0; i < 20; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump();
      }
    }

    testWidgets('back off: the header says so instead of "Ready to train"', (
      tester,
    ) async {
      final wellness = WellnessRepository(database: database);
      await tester.runAsync(
        () => wellness.upsertAll([
          ..._sustained(hrv: 52),
          _day(0, hrv: 52, rhr: 48, sleepSecs: 5 * 3600),
        ]),
      );
      await pumpToday(tester, wellness);

      expect(find.text('Take it easy today'), findsOneWidget);
      expect(find.text('Ready to train'), findsNothing);
      expect(find.textContaining('Back off'), findsWidgets); // the card
    });

    testWidgets('a ready day still opens with "Ready to train"', (
      tester,
    ) async {
      final wellness = WellnessRepository(database: database);
      await tester.runAsync(
        () => wellness.upsertAll([
          ..._baseline(),
          _day(0, hrv: 63, rhr: 47, sleepSecs: 8 * 3600),
        ]),
      );
      await pumpToday(tester, wellness);

      expect(find.text('Ready to train'), findsOneWidget);
      expect(find.text('Take it easy today'), findsNothing);
    });

    testWidgets('no wellness data: nothing contradicts the header', (
      tester,
    ) async {
      await pumpToday(tester, WellnessRepository(database: database));
      expect(find.text('Ready to train'), findsOneWidget);
    });
  });
}
