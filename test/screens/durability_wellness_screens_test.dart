import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/models/local_wellness.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/data/repositories/wellness_repository.dart';
import 'package:triiq/evaluation/durability.dart';
import 'package:triiq/evaluation/performance_curves.dart';
import 'package:triiq/evaluation/session_streams.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/statistics/durability_screen.dart';
import 'package:triiq/screens/statistics/wellness_trends_screen.dart';
import 'package:triiq/util/dates.dart';

Widget _app(Widget home) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: home,
);

Future<void> _settle(WidgetTester tester, {int rounds = 20}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 60));
  }
}

void main() {
  final now = DateTime(2026, 11, 7);

  group('durability screen', () {
    LocalActivity ride(String id, String date) => LocalActivity(
      id: id,
      date: date,
      type: 'Ride',
      name: id,
      movingTime: 14400,
      distance: 100000,
      trainingLoad: 200,
      raw: {'icu_joules': 2.5e6},
      syncedAt: now,
    );
    SessionStreams streams(double w) => SessionStreams(
      series: {
        'time': [for (var i = 0; i < 10800; i++) i.toDouble()],
        'watts': List<double?>.filled(10800, w),
      },
    );

    DurabilityLoader loader({required bool curves}) => DurabilityLoader(
      activities: ActivitiesRepository(),
      streams: ActivityStreamsRepository(fetch: (id) async => streams(250)),
      curves: PerformanceCurvesRepository(
        fetch: (sport, metric) async => curves
            ? {
                'list': [
                  {
                    'id': 's0',
                    'secs': [5, 60, 300, 1200, 3600],
                    'values': [900, 500, 380, 310, 270],
                  },
                ],
              }
            : throw StateError('offline'),
      ),
      clock: () => now,
    );

    testWidgets('shows fresh vs fatigued power and what is kept', (
      tester,
    ) async {
      await tester.runAsync(
        () => ActivitiesRepository().upsertAll([ride('a', '2026-10-20')]),
      );
      await tester.binding.setSurfaceSize(const Size(420, 1800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _app(DurabilityScreen(loader: loader(curves: true))),
      );
      await _settle(tester);

      expect(find.text('Durability'), findsWidgets);
      expect(find.text('After 1000 kJ'), findsOneWidget); // legend
      expect(find.text('After 2000 kJ'), findsOneWidget);
      expect(find.text('After 3000 kJ'), findsNothing); // never reached
      expect(find.text('Season best'), findsWidgets);
      // 1-minute row: 250 W against 500 W fresh = 50 %.
      expect(find.textContaining('250 W 50%'), findsWidgets);
      expect(
        find.textContaining('Based on 1 of 1 long sessions'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('works without the season curve (offline): no fresh column', (
      tester,
    ) async {
      await tester.runAsync(
        () => ActivitiesRepository().upsertAll([ride('a', '2026-10-20')]),
      );
      await tester.binding.setSurfaceSize(const Size(420, 1800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _app(DurabilityScreen(loader: loader(curves: false))),
      );
      await _settle(tester);

      expect(find.text('After 1000 kJ'), findsOneWidget);
      expect(find.textContaining('W 50%'), findsNothing); // nothing to compare
      expect(tester.takeException(), isNull);
    });

    testWidgets('no long sessions: says so', (tester) async {
      await tester.runAsync(() async {
        // A fresh DB per test file run: only a short ride on record.
      });
      final empty = DurabilityLoader(
        activities: _NoActivities(),
        streams: ActivityStreamsRepository(fetch: (id) async => streams(200)),
        curves: PerformanceCurvesRepository(
          fetch: (s, m) async => {'list': []},
        ),
        clock: () => now,
      );
      await tester.pumpWidget(_app(DurabilityScreen(loader: empty)));
      await _settle(tester);
      expect(
        find.textContaining('No rides with at least 1,000 kJ'),
        findsOneWidget,
      );
    });
  });

  group('wellness trends screen', () {
    LocalWellness day(int ago, {num? hrv, num? sleep, num? weight}) {
      final date = isoDate(DateTime(now.year, now.month, now.day - ago));
      return LocalWellness(
        date: date,
        ctl: null,
        atl: null,
        ctlLoad: null,
        atlLoad: null,
        rampRate: null,
        raw: {'id': date, 'hrv': ?hrv, 'sleepSecs': ?sleep, 'weight': ?weight},
        syncedAt: now,
      );
    }

    testWidgets('a card per metric with data, 7-day average and a band', (
      tester,
    ) async {
      await tester.runAsync(
        () => WellnessRepository().upsertAll([
          for (var i = 0; i < 40; i++)
            day(
              i,
              hrv: 60 + (i.isEven ? 5 : -5),
              sleep: 7.5 * 3600,
              weight: 71.0,
            ),
        ]),
      );
      await tester.binding.setSurfaceSize(const Size(420, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_app(WellnessTrendsScreen(today: now)));
      await _settle(tester);

      expect(find.byKey(const ValueKey('wt-hrv')), findsOneWidget);
      expect(find.byKey(const ValueKey('wt-sleep')), findsOneWidget);
      expect(find.byKey(const ValueKey('wt-weight')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('wt-restingHr')),
        findsNothing,
      ); // none recorded
      expect(find.text('7:30 h'), findsWidgets); // latest sleep
      expect(find.text('71.0 kg'), findsWidgets);
      expect(find.textContaining('Shaded band'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('options choose the range and hide a metric', (tester) async {
      await tester.runAsync(
        () => WellnessRepository().upsertAll([
          for (var i = 0; i < 40; i++) day(i, hrv: 60, weight: 70),
        ]),
      );
      await tester.binding.setSurfaceSize(const Size(420, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_app(WellnessTrendsScreen(today: now)));
      await _settle(tester);

      await tester.tap(find.byKey(const ValueKey('chart-options')));
      await _settle(tester, rounds: 8);
      await tester.tap(find.byKey(const ValueKey('wt-metric-weight')));
      await _settle(tester, rounds: 3);
      await tester.tapAt(const Offset(5, 5));
      await _settle(tester, rounds: 5);

      expect(find.byKey(const ValueKey('wt-weight')), findsNothing);
      expect(find.byKey(const ValueKey('wt-hrv')), findsOneWidget);
    });

    testWidgets('empty cache: says there is no data', (tester) async {
      await tester.pumpWidget(
        _app(WellnessTrendsScreen(repository: _NoWellness(), today: now)),
      );
      await _settle(tester, rounds: 5);
      expect(find.text('No data in this range.'), findsOneWidget);
    });
  });
}

class _NoActivities extends ActivitiesRepository {
  @override
  Future<List<LocalActivity>> getRange(String oldest, String newest) async =>
      const [];
}

class _NoWellness extends WellnessRepository {
  @override
  Future<List<LocalWellness>> getRange(String oldest, String newest) async =>
      const [];
}
