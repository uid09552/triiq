import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/data/repositories/sync_state_repository.dart';
import 'package:triiq/evaluation/year_stats_service.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/activities/planned_workout_detail_screen.dart';
import 'package:triiq/screens/activities/year_sport_widgets.dart';
import 'package:triiq/screens/plan/plan_session_sheet.dart';
import 'package:triiq/widgets/peek_cards.dart';

final _today = DateTime(2026, 11, 13, 9);
final _thisYear = DateTime.now().year;

LocalActivity _act(
  String id,
  String date,
  String type, {
  int minutes = 60,
  double km = 20,
  int tss = 50,
}) => LocalActivity(
  id: id,
  date: date,
  type: type,
  name: '$type $id',
  movingTime: minutes * 60,
  distance: km * 1000,
  trainingLoad: tss,
  raw: {'id': id, 'average_heartrate': 140},
  syncedAt: DateTime(2026, 11, 1),
);

Widget _app(Widget child, {Locale locale = const Locale('en')}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: locale,
  home: Scaffold(body: child),
);

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 40)),
    );
    await tester.pump();
  }
}

Future<YearStatsService> _service(
  WidgetTester tester,
  List<LocalActivity> acts, {
  String oldest = '2000-01-01',
}) async {
  await tester.runAsync(() async {
    await ActivitiesRepository().upsertAll(acts);
    await SyncStateRepository().recordSync(
      'activities',
      oldest: oldest,
      newest: '2026-11-13',
    );
  });
  final service = YearStatsService(clock: () => _today);
  addTearDown(service.dispose);
  return service;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    YearStatsService.instance.invalidate();
  });

  void phone(WidgetTester tester, {Size size = const Size(360, 800)}) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('YearSportCard', () {
    final acts = [
      _act('a', '2026-02-01', 'Ride', minutes: 120, km: 100, tss: 150),
      _act('b', '2026-03-01', 'Ride', minutes: 90, km: 60, tss: 80),
      _act('c', '2026-04-01', 'VirtualRide', minutes: 60, km: 40, tss: 60),
      _act('d', '2026-05-01', 'Ride', minutes: 150, km: 80, tss: 100),
      _act('r', '2026-05-02', 'Run', minutes: 60, km: 10),
      _act('p', '2025-03-01', 'Ride', minutes: 120, km: 80, tss: 90),
      _act('q', '2025-12-24', 'Ride', minutes: 600, km: 300, tss: 500),
    ];

    testWidgets('values, share, rank and the change since last year', (
      tester,
    ) async {
      phone(tester);
      final service = await _service(tester, acts);
      await tester.pumpWidget(
        _app(YearSportCard(activity: acts[3], service: service)),
      );
      await _settle(tester);

      expect(find.text('This year · Ride'), findsOneWidget);
      // Rides and virtual rides: 4 sessions, 7 h 0 min, 280 km, 390 TSS.
      expect(
        find.text('4 sessions · 7.0 h · 280 km · 390 TSS'),
        findsOneWidget,
      );
      expect(find.text('This session is 29 % of your 280 km'), findsOneWidget);
      expect(find.text('No. 2 of 4 by distance this year'), findsOneWidget);
      // 7 h against 2 h at the same date last year (24 Dec is not in it).
      expect(
        find.text('↑ 250 % in time vs. the same date in 2025'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('year-card-note')), findsNothing);
    });

    testWidgets('a year that is only partly synced says so, no comparison', (
      tester,
    ) async {
      phone(tester);
      final service = await _service(tester, acts, oldest: '2026-01-15');
      await tester.pumpWidget(
        _app(YearSportCard(activity: acts[3], service: service)),
      );
      await _settle(tester);

      final note = tester.widget<Text>(
        find.byKey(const ValueKey('year-card-note')),
      );
      expect(note.data, contains('Based on synced data since Jan 15, 2026'));
      expect(find.textContaining('vs. the same date'), findsNothing);
    });

    testWidgets('nothing for the sport this year: no card', (tester) async {
      phone(tester);
      final service = await _service(tester, acts);
      await tester.pumpWidget(
        _app(
          YearSportCard(
            activity: _act('s', '2026-06-01', 'Swim', km: 2),
            service: service,
          ),
        ),
      );
      await _settle(tester);
      expect(find.byKey(const ValueKey('year-sport-card')), findsNothing);
    });

    testWidgets('strength: time and sessions only, no distance or rank', (
      tester,
    ) async {
      phone(tester);
      final lift = _act('w', '2026-06-01', 'WeightTraining', km: 0, tss: 20);
      final service = await _service(tester, [...acts, lift]);
      await tester.pumpWidget(
        _app(YearSportCard(activity: lift, service: service)),
      );
      await _settle(tester);
      expect(find.text('This year · Strength & mobility'), findsOneWidget);
      expect(find.text('1 session · 1.0 h'), findsOneWidget);
      expect(find.textContaining('by distance'), findsNothing);
      expect(find.textContaining('by TSS'), findsNothing);
    });

    testWidgets('360 dp at 2x text, German: no overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      phone(tester);
      final service = await _service(tester, acts, oldest: '2026-01-15');
      await tester.pumpWidget(
        _app(
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: YearSportCard(activity: acts[3], service: service),
          ),
          locale: const Locale('de'),
        ),
      );
      await _settle(tester);
      expect(find.byKey(const ValueKey('year-sport-card')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('reloads when the cache changes', (tester) async {
      phone(tester);
      final service = await _service(tester, acts);
      await tester.pumpWidget(
        _app(YearSportCard(activity: acts[3], service: service)),
      );
      await _settle(tester);
      expect(find.textContaining('4 sessions'), findsOneWidget);

      await tester.runAsync(
        () => ActivitiesRepository().upsertAll([
          _act('e', '2026-06-06', 'Ride', minutes: 30, km: 10, tss: 20),
        ]),
      );
      service.invalidate();
      await _settle(tester);
      expect(find.textContaining('5 sessions'), findsOneWidget);
    });
  });

  group('YearContextLine', () {
    final acts = [
      _act('a', '2026-02-01', 'Run', minutes: 3600, km: 800, tss: 0),
      _act('b', '2026-03-01', 'Run', minutes: 1320, km: 234, tss: 0),
      _act('w', '2026-03-02', 'Yoga', minutes: 30, km: 0),
    ];

    testWidgets('one line for the sport and year', (tester) async {
      phone(tester);
      final service = await _service(tester, acts);
      await tester.pumpWidget(
        _app(
          YearContextLine(
            type: 'TrailRun',
            date: '2026-12-01',
            service: service,
          ),
        ),
      );
      await _settle(tester);
      expect(find.text('Run this year: 82.0 h · 1,034 km'), findsOneWidget);
    });

    testWidgets('strength has no distance', (tester) async {
      phone(tester);
      final service = await _service(tester, acts);
      await tester.pumpWidget(
        _app(
          YearContextLine(type: 'Yoga', date: '2026-12-01', service: service),
        ),
      );
      await _settle(tester);
      expect(find.text('Strength & mobility this year: 0.5 h'), findsOneWidget);
    });

    testWidgets('German', (tester) async {
      phone(tester);
      final service = await _service(tester, acts);
      await tester.pumpWidget(
        _app(
          YearContextLine(type: 'Run', date: '2026-12-01', service: service),
          locale: const Locale('de'),
        ),
      );
      await _settle(tester);
      expect(
        find.text('Laufen dieses Jahr: 82,0 h · 1.034 km'),
        findsOneWidget,
      );
    });

    testWidgets('nothing for a sport without sessions', (tester) async {
      phone(tester);
      final service = await _service(tester, acts);
      await tester.pumpWidget(
        _app(
          YearContextLine(type: 'Swim', date: '2026-12-01', service: service),
        ),
      );
      await _settle(tester);
      expect(find.byKey(const ValueKey('year-context-line')), findsNothing);
    });

    testWidgets('partial year: the line carries the caveat, a peek hides it', (
      tester,
    ) async {
      phone(tester);
      final service = await _service(tester, acts, oldest: '2026-02-10');
      await tester.pumpWidget(
        _app(
          Column(
            children: [
              YearContextLine(
                type: 'Run',
                date: '2026-12-01',
                service: service,
              ),
              YearContextLine(
                key: const ValueKey('compact'),
                type: 'Run',
                date: '2026-12-01',
                hideWhenPartial: true,
                service: service,
              ),
            ],
          ),
        ),
      );
      await _settle(tester);
      expect(find.byKey(const ValueKey('year-context-line')), findsOneWidget);
      expect(find.byKey(const ValueKey('year-context-note')), findsOneWidget);
    });
  });

  group('where the line shows up', () {
    final runs = [
      _act('a', '$_thisYear-01-01', 'Run', minutes: 120, km: 24),
      _act('b', '$_thisYear-01-01', 'Run', minutes: 60, km: 12),
    ];

    testWidgets('ActivityPeek: one extra line, no overflow at 2x text', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      phone(tester);
      await tester.runAsync(() async {
        await ActivitiesRepository().upsertAll(runs);
        await SyncStateRepository().recordSync(
          'activities',
          oldest: '2000-01-01',
          newest: '$_thisYear-12-31',
        );
      });
      await tester.pumpWidget(
        _app(
          Padding(
            padding: const EdgeInsets.all(16),
            child: ActivityPeek(activity: runs.first),
          ),
        ),
      );
      await _settle(tester);
      expect(
        find.textContaining('Run this year: 3.0 h · 36 km'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('planned workout detail shows the line', (tester) async {
      phone(tester, size: const Size(800, 1400));
      await tester.runAsync(() async {
        await ActivitiesRepository().upsertAll(runs);
        await SyncStateRepository().recordSync(
          'activities',
          oldest: '2000-01-01',
          newest: '$_thisYear-12-31',
        );
      });
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: PlannedWorkoutDetailScreen(
            event: LocalEvent(
              id: 'e1',
              date: '$_thisYear-06-01',
              category: 'WORKOUT',
              type: 'Run',
              name: 'Tempo',
              description: null,
              plannedLoad: 60,
              plannedTime: 3600,
              plannedDistance: null,
              indoor: false,
              raw: const {},
              syncedAt: DateTime(2026, 11, 1),
            ),
            activities: ActivitiesRepository(),
          ),
        ),
      );
      await _settle(tester);
      expect(find.text('Run this year: 3.0 h · 36 km'), findsOneWidget);
    });

    testWidgets('plan session sheet shows the line', (tester) async {
      phone(tester);
      await tester.runAsync(() async {
        await ActivitiesRepository().upsertAll(runs);
        await SyncStateRepository().recordSync(
          'activities',
          oldest: '2000-01-01',
          newest: '$_thisYear-12-31',
        );
      });
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showPlanSessionSheet(
                context,
                name: 'Easy run',
                sport: 'Run',
                date: DateTime(_thisYear, 6, 1),
                minutes: 45,
                load: 40,
                description: '- 45m Z2',
                sent: false,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump(const Duration(milliseconds: 400));
      await _settle(tester);
      expect(find.text('Run this year: 3.0 h · 36 km'), findsOneWidget);
    });
  });
}
