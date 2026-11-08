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
    atlLoad: null,
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

List<LocalWellness> _baseline() => [
  for (var i = 1; i <= 40; i++)
    _day(i, hrv: 62 + (i.isEven ? 6 : -6), rhr: 48, sleepSecs: 8 * 3600),
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
              ..._baseline(),
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
              ..._baseline(),
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
              ..._baseline(),
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
      ..._baseline(),
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
        ..._baseline(),
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
          ..._baseline(),
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
      // One verdict: the header above no longer says "Ready to train".
      expect(find.text('Take it easy today'), findsOneWidget);
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
          ..._baseline(),
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
