import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/evaluation/best_efforts.dart';
import 'package:triiq/evaluation/performance_curves.dart';
import 'package:triiq/evaluation/session_streams.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/activities/activity_extras_card.dart';
import 'package:triiq/screens/statistics/best_efforts_screen.dart';
import 'package:triiq/screens/statistics/load_heatmap_screen.dart';

Widget _app(Widget home) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: Scaffold(body: SingleChildScrollView(child: home)),
);

Widget _page(Widget home) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: home,
);

Future<void> _settle(WidgetTester tester, {int rounds = 15}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 60));
  }
}

LocalActivity _act(
  String id,
  String date,
  String type,
  int tss, {
  Map<String, dynamic> raw = const {},
}) => LocalActivity(
  id: id,
  date: date,
  type: type,
  name: id,
  movingTime: 3600,
  distance: 30000,
  trainingLoad: tss,
  raw: raw,
  syncedAt: DateTime(2026),
);

void main() {
  final now = DateTime(2026, 11, 7);

  group('effort profile card', () {
    SessionStreams streams() {
      final watts = <double?>[
        ...List<double?>.filled(300, 300),
        ...List<double?>.filled(120, 100),
        ...List<double?>.filled(300, 285),
        ...List<double?>.filled(90, 0),
      ];
      final hr = <double?>[
        ...List<double?>.filled(300, 150),
        ...List<double?>.filled(120, 140),
        ...List<double?>.filled(150, 150),
        ...List<double?>.filled(150, 165),
        ...List<double?>.filled(90, 120),
      ];
      return SessionStreams(
        series: {
          'time': [for (var i = 0; i < watts.length; i++) i.toDouble()],
          'watts': watts,
          'heartrate': hr,
        },
        intervals: const [
          SessionInterval(start: 0, end: 299, type: 'WORK'),
          SessionInterval(start: 300, end: 419, type: 'RECOVERY'),
          SessionInterval(start: 420, end: 719, type: 'WORK'),
        ],
      );
    }

    testWidgets('variability, histogram and interval drift for a ride', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(420, 1800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        _app(
          ActivityExtrasCard(
            activity: _act('r1', '2026-10-20', 'Ride', 80),
            streams: ActivityStreamsRepository(fetch: (_) async => streams()),
          ),
        ),
      );
      await _settle(tester);

      expect(find.byKey(const ValueKey('extras-card')), findsOneWidget);
      expect(find.byKey(const ValueKey('extras-vi')), findsOneWidget);
      expect(find.text('Time at power'), findsOneWidget);
      expect(
        find.textContaining('Not pedalling or stopped: 1.5 min'),
        findsOneWidget,
      );

      // Tapping the histogram names the band.
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('extras-hist-readout')))
            .data,
        'Tap a bar for the details.',
      );
      await tester.tap(find.byKey(const ValueKey('extras-hist')));
      await tester.pump();
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('extras-hist-readout')))
            .data,
        contains(' W: '),
      );

      // Interval table: two work intervals and a recovery.
      expect(find.byKey(const ValueKey('extras-interval-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('extras-interval-3')), findsOneWidget);
      expect(find.text('300 W'), findsOneWidget);
      expect(find.text('285 W'), findsOneWidget);
      expect(find.text('-5%'), findsOneWidget); // fade of the second work
      expect(find.text('+9.1%'), findsOneWidget); // drift inside it
      expect(tester.takeException(), isNull);
    });

    testWidgets('a swim, or a ride without power, draws nothing', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          ActivityExtrasCard(
            activity: _act('s1', '2026-10-20', 'Swim', 30),
            streams: ActivityStreamsRepository(fetch: (_) async => streams()),
          ),
        ),
      );
      await _settle(tester, rounds: 5);
      expect(find.byKey(const ValueKey('extras-card')), findsNothing);

      await tester.pumpWidget(
        _app(
          ActivityExtrasCard(
            activity: _act('r2', '2026-10-21', 'Ride', 50),
            streams: ActivityStreamsRepository(
              fetch: (_) async => const SessionStreams(
                series: {
                  'time': [0, 1],
                  'heartrate': [100, 110],
                },
              ),
            ),
          ),
        ),
      );
      await _settle(tester, rounds: 5);
      expect(find.byKey(const ValueKey('extras-card')), findsNothing);
    });

    testWidgets('a run is read as pace', (tester) async {
      await tester.binding.setSurfaceSize(const Size(420, 1800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        _app(
          ActivityExtrasCard(
            activity: _act('u1', '2026-10-20', 'Run', 60),
            streams: ActivityStreamsRepository(
              fetch: (_) async => SessionStreams(
                series: {
                  'time': [for (var i = 0; i < 600; i++) i.toDouble()],
                  'velocity_smooth': [
                    for (var i = 0; i < 600; i++) i < 300 ? 3.0 : 3.5,
                  ],
                },
              ),
            ),
          ),
        ),
      );
      await _settle(tester);
      expect(find.text('Time at pace'), findsOneWidget);
      expect(find.byKey(const ValueKey('extras-vi')), findsOneWidget);
    });
  });

  group('load heatmap', () {
    testWidgets('cells coloured by load; tap shows the day; sport filter', (
      tester,
    ) async {
      await tester.runAsync(
        () => ActivitiesRepository().upsertAll([
          _act('a', '2026-10-20', 'Ride', 90),
          _act('b', '2026-10-20', 'Run', 40),
          _act('c', '2026-10-22', 'Run', 60),
        ]),
      );
      await tester.binding.setSurfaceSize(const Size(420, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_page(LoadHeatmapScreen(today: now)));
      await _settle(tester);

      expect(find.text('Load heatmap'), findsWidgets);
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('hm-readout'))).data,
        'Tap a day to see its load.',
      );
      await tester.tap(find.byKey(const ValueKey('hm-2026-10-20')));
      await tester.pump();
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('hm-readout'))).data,
        allOf(contains('130 TSS'), contains('2 sessions')),
      );
      expect(find.text('Training days'), findsOneWidget);
      expect(find.textContaining('TSS, week of'), findsOneWidget);

      // Filter to rides: the run-only day has no load any more.
      await tester.tap(find.byKey(const ValueKey('chart-options')));
      await _settle(tester, rounds: 8);
      await tester.tap(find.byKey(const ValueKey('hm-sport-ride')));
      await _settle(tester, rounds: 3);
      await tester.tapAt(const Offset(5, 5));
      await _settle(tester, rounds: 5);
      await tester.tap(find.byKey(const ValueKey('hm-2026-10-22')));
      await tester.pump();
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('hm-readout'))).data,
        contains('no training'),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('no training: says so', (tester) async {
      await tester.pumpWidget(
        _page(LoadHeatmapScreen(repository: _NoActivities(), today: now)),
      );
      await _settle(tester, rounds: 5);
      expect(find.text('No training in this period.'), findsOneWidget);
    });
  });

  group('best efforts', () {
    EffortSession s(String date, List<double?> v) =>
        EffortSession(date, date, v);

    testWidgets('a line per window and last 30 days against the 90 before', (
      tester,
    ) async {
      final repo = BestEffortsRepository(
        fetch: (sport, days) async => [
          s('2026-11-02', [800, 500, 330, 280]),
          s('2026-09-15', [900, 540, 340, 285]),
          s('2026-08-20', [850, 510, 320, 270]),
        ],
      );
      await tester.binding.setSurfaceSize(const Size(420, 1800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        _page(BestEffortsScreen(repository: repo, today: now)),
      );
      await _settle(tester);

      expect(find.text('Best efforts · 1m'), findsOneWidget);
      // 1 min: 500 W now against 540 W before = -7.4 %.
      expect(find.text('500 W'), findsOneWidget);
      expect(find.text('540 W'), findsOneWidget);
      expect(find.text('-7.4%'), findsOneWidget);
      expect(find.byKey(const ValueKey('be-row-3')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('runs: pace, and a quicker time is the improvement', (
      tester,
    ) async {
      final repo = BestEffortsRepository(
        fetch: (sport, days) async => [
          s('2026-11-01', [240, 1250, 2600]),
          s('2026-08-30', [250, 1300, null]),
        ],
      );
      await tester.binding.setSurfaceSize(const Size(420, 1800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        _page(
          BestEffortsScreen(
            sport: CurveSport.run,
            repository: repo,
            today: now,
          ),
        ),
      );
      await _settle(tester);
      expect(find.text('4:00'), findsWidgets); // 1 km in 240 s
      expect(find.text('+4.0%'), findsWidgets);
      expect(find.text('4:10'), findsWidgets); // the earlier 250 s
    });

    testWidgets('no efforts at all says so', (tester) async {
      // Never serve an earlier test's cached efforts for this one.
      final repo = BestEffortsRepository(
        maxAge: Duration.zero,
        fetch: (sport, days) async => const [],
      );
      await tester.pumpWidget(
        _page(BestEffortsScreen(repository: repo, today: now)),
      );
      await _settle(tester, rounds: 15);
      expect(
        find.text('No efforts recorded in the last year.'),
        findsOneWidget,
      );
    });
  });
}

class _NoActivities extends ActivitiesRepository {
  @override
  Future<List<LocalActivity>> getRange(String oldest, String newest) async =>
      const [];
}
