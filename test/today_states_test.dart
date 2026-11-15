import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/data/models/local_wellness.dart';
import 'package:triiq/data/planned_items.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/data/repositories/events_repository.dart';
import 'package:triiq/data/repositories/plans_repository.dart';
import 'package:triiq/data/repositories/wellness_repository.dart';
import 'package:triiq/data/threshold_suggestions_service.dart';
import 'package:triiq/evaluation/fatigue_warning_service.dart';
import 'package:triiq/evaluation/readiness_service.dart';
import 'package:triiq/evaluation/threshold_suggestions.dart';
import 'package:triiq/plan/knowledge.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/plan/plan_models.dart';
import 'package:triiq/screens/calendar/calendar_moves.dart';
import 'package:triiq/screens/settings/weekly_targets_settings.dart';
import 'package:triiq/screens/settings/year_goals_settings.dart';
import 'package:triiq/screens/today/today_screen.dart';
import 'package:triiq/util/dates.dart';
import 'package:triiq/widgets/hold_preview.dart';
import 'package:triiq/widgets/peekable.dart';

class _FakeMover extends CalendarMover {
  final moves = <(String, String, DateTime)>[];

  @override
  Future<void> move(LocalEvent event, DateTime target) async =>
      moves.add((event.id, event.date, target));
}

class _NoThresholds extends ThresholdSuggestionsService {
  @override
  Future<List<ThresholdSuggestion>> load() async => const [];
}

LocalEvent _event(
  String id,
  String date, {
  String category = 'WORKOUT',
  String type = 'Ride',
  String name = 'Tempo ride',
  int minutes = 65,
}) => LocalEvent(
  id: id,
  date: date,
  category: category,
  type: type,
  name: name,
  description: null,
  plannedLoad: category == 'WORKOUT' ? 78 : null,
  plannedTime: category == 'WORKOUT' ? minutes * 60 : null,
  plannedDistance: null,
  indoor: false,
  raw: const {},
  syncedAt: DateTime.now(),
);

void main() {
  late Directory dir;
  late AppDatabase database;
  late EventsRepository events;
  late PlansRepository plans;
  final today = dateOnly(DateTime.now());
  final todayIso = isoDate(today);
  final tomorrow = today.add(const Duration(days: 1));

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dir = await Directory.systemTemp.createTemp('triiq_today_states');
    database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
    events = EventsRepository(database: database);
    plans = PlansRepository(database: database);
  });

  tearDown(() async {
    await database.close();
    await dir.delete(recursive: true);
  });

  Future<void> settle(WidgetTester t) async {
    for (var i = 0; i < 200; i++) {
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await t.pump();
      if (i > 10 && find.byType(CircularProgressIndicator).evaluate().isEmpty) {
        break;
      }
      if (i == 199) debugPrint('settle: still loading');
    }
  }

  Future<void> pumpToday(
    WidgetTester t, {
    Size size = const Size(360, 1600),
    String lang = 'en',
    CalendarMover? mover,
    WellnessRepository? wellness,
  }) async {
    final wellnessRepo = wellness ?? WellnessRepository(database: database);
    // The bundled knowledge asset only loads once per test file; read the
    // rules from the file like the other Today tests.
    final knowledge = KnowledgeRepository(
      loadAsset: () async => File('docs/okf.md').readAsStringSync(),
    );
    t.view.physicalSize = size * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale(lang),
        home: Scaffold(
          body: TodayScreen(
            wellnessRepository: wellnessRepo,
            readinessService: ReadinessService(
              wellness: wellnessRepo,
              knowledge: knowledge,
            ),
            fatigueWarningService: FatigueWarningService(
              wellness: wellnessRepo,
              knowledge: knowledge,
            ),
            activitiesRepository: ActivitiesRepository(database: database),
            plannedItems: PlannedItemsRepository(
              events: events,
              plans: plans,
              copyEvents: () async => true,
            ),
            goalStore: GoalStore(),
            plansRepository: plans,
            mover: mover,
            thresholdService: _NoThresholds(),
          ),
        ),
      ),
    );
    await settle(t);
  }

  Future<void> planToday() =>
      events.replaceRange(isoDate(startOfWeek(today)), isoDate(tomorrow), [
        _event('501', todayIso),
        _event('502', isoDate(tomorrow), name: 'Long ride', minutes: 180),
      ]);

  for (final lang in ['en', 'de']) {
    testWidgets('hero and This week need no scroll on a phone ($lang)', (
      t,
    ) async {
      // A full This week card: targets for all three sports, year goals.
      final targets = WeeklyTargetsSettings.instance;
      final goals = YearGoalsSettings.instance;
      await t.runAsync(() async {
        await planToday();
        await targets.setSwimHours(2);
        await targets.setCycleHours(5);
        await targets.setRunHours(3);
        await goals.setRunKm(1500);
        await goals.setCycleKm(6000);
      });
      addTearDown(() async {
        await targets.setSwimHours(null);
        await targets.setCycleHours(null);
        await targets.setRunHours(null);
        await goals.setRunKm(null);
        await goals.setCycleKm(null);
      });
      await pumpToday(t, lang: lang);
      expect(find.byKey(const ValueKey('year-goals-line')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('weekly-target-ring-cycle')),
        findsOneWidget,
      );

      // A 360 x 780 dp phone, minus ~80 dp app bar and 68 dp nav bar. The
      // setup banner (only before connecting) is left out: measured from
      // the hero's top, plus the list's top padding.
      const visible = 780.0 - 80 - 68;
      final heroTop = t.getTopLeft(find.byKey(const ValueKey('today-hero'))).dy;
      final weekBottom = t
          .getBottomLeft(find.byKey(const ValueKey('this-week-card')))
          .dy;
      debugPrint('fit ($lang): ${weekBottom - heroTop + 4} of $visible dp');
      expect(weekBottom - heroTop + 4, lessThanOrEqualTo(visible));
      expect(t.getSize(find.byKey(const ValueKey('today-hero'))).width, 328);
      expect(t.takeException(), isNull);
    });
  }

  testWidgets('360 dp at 2x text: nothing overflows', (t) async {
    t.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
    final targets = WeeklyTargetsSettings.instance;
    await t.runAsync(() async {
      await planToday();
      await targets.setCycleHours(5);
      await targets.setRunHours(3);
    });
    addTearDown(() async {
      await targets.setCycleHours(null);
      await targets.setRunHours(null);
    });
    final errors = <String>[];
    final previous = FlutterError.onError;
    FlutterError.onError = (d) => errors.add(d.toString());
    try {
      await pumpToday(t, size: const Size(360, 3000), lang: 'de');
    } finally {
      FlutterError.onError = previous;
    }
    expect(errors, isEmpty);
  });

  testWidgets('load tiles: three by default, all six behind More metrics', (
    t,
  ) async {
    await pumpToday(t);
    expect(find.text('TSS today'), findsNothing);
    await t.tap(find.byKey(const ValueKey('more-metrics')));
    await t.pump();
    expect(find.text('TSS today'), findsOneWidget);
  });

  testWidgets('race week: its header replaces the load tiles', (t) async {
    await t.runAsync(() async {
      await GoalStore().save(
        Goal(
          targetType: 'long_distance',
          weekdays: const {2, 4, 6},
          weeklyHours: 6,
          eventDate: today.add(const Duration(days: 3)),
        ),
      );
      await plans.save(
        TrainingPlan(
          goalType: 'long_distance',
          sport: 'Run',
          startDate: startOfWeek(today),
          baselineLoad: 300,
          status: PlanStatus.active,
          weeks: [
            PlanWeek(
              index: 0,
              phase: 'taper',
              startDate: startOfWeek(today),
              targetLoad: 200,
              requestedLoad: 200,
              limit: WeekLimit.none,
              projectedCtlEnd: null,
              sessions: const [],
              lowIntensityTarget: 0.8,
              lowIntensityTolerance: 0.05,
            ),
          ],
        ),
      );
    });
    await pumpToday(t);

    expect(find.byKey(const ValueKey('race-week-header')), findsOneWidget);
    expect(find.text('Race in 3 days'), findsOneWidget);
    expect(find.textContaining('Taper'), findsOneWidget);
    expect(find.byKey(const ValueKey('load-tiles')), findsNothing);
  });

  testWidgets('sick: training cards give way to the return plan', (t) async {
    await t.runAsync(
      () =>
          events.replaceRange(isoDate(startOfWeek(today)), isoDate(tomorrow), [
            _event('501', todayIso),
            _event('900', todayIso, category: 'SICK', name: 'Flu'),
          ]),
    );
    await pumpToday(t);

    expect(find.text('You are logged as sick'), findsWidgets);
    expect(find.byKey(const ValueKey('health-card')), findsOneWidget);
    expect(find.byKey(const ValueKey('this-week-card')), findsNothing);
    expect(find.byKey(const ValueKey('week-ribbon')), findsNothing);
    expect(find.byKey(const ValueKey('load-tiles')), findsNothing);
    expect(find.byKey(const ValueKey('hero-primary-logFeel')), findsOneWidget);
  });

  testWidgets("watch data not in yet: a placeholder, not a half score", (
    t,
  ) async {
    final wellness = WellnessRepository(database: database);
    await t.runAsync(
      () => wellness.upsertAll([
        LocalWellness(
          date: isoDate(today.subtract(const Duration(days: 1))),
          ctl: 50,
          atl: 50,
          ctlLoad: null,
          atlLoad: null,
          rampRate: null,
          raw: const {'hrv': 60, 'restingHR': 48, 'sleepSecs': 28800},
          syncedAt: DateTime.now(),
        ),
      ]),
    );
    await pumpToday(t, wellness: wellness);

    expect(find.byKey(const ValueKey('readiness-waiting')), findsOneWidget);
    expect(find.byKey(const ValueKey('hero-readiness')), findsNothing);
  });

  testWidgets('swipe today\'s session to tomorrow, then undo', (t) async {
    await t.runAsync(planToday);
    final mover = _FakeMover();
    await pumpToday(t, mover: mover);

    await t.drag(
      find.descendant(
        of: find.byKey(const ValueKey('today-hero')),
        matching: find.text('Tempo ride'),
      ),
      const Offset(-300, 0),
    );
    await t.pumpAndSettle();
    expect(mover.moves, [('501', todayIso, tomorrow)]);

    await t.tap(find.text('Undo'));
    await t.pumpAndSettle();
    expect(mover.moves.length, 2);
    expect(mover.moves.last.$1, '501');
    expect(mover.moves.last.$2, isoDate(tomorrow));
    expect(mover.moves.last.$3, today);
  });

  group('hold to peek', () {
    const overlay = ValueKey('hold-preview');

    Future<void> seedActivity() =>
        ActivitiesRepository(database: database).upsertAll([
          LocalActivity(
            id: 'act1',
            date: todayIso,
            type: 'Run',
            name: 'Easy run',
            movingTime: 2700,
            distance: 8000,
            trainingLoad: 42,
            raw: const {'id': 'act1', 'average_heartrate': 141},
            syncedAt: DateTime.now(),
          ),
        ]);

    Future<TestGesture> hold(WidgetTester t, Finder f) async {
      final g = await t.startGesture(t.getCenter(f));
      await t.pump(const Duration(milliseconds: 700));
      await t.pump(const Duration(milliseconds: 300));
      return g;
    }

    testWidgets('the week ribbon day peeks with its plan and activities', (
      t,
    ) async {
      await t.runAsync(() async {
        await planToday();
        await seedActivity();
      });
      await pumpToday(t);

      final day = find.byKey(ValueKey('ribbon-$todayIso'));
      expect(day, findsOneWidget);
      final g = await hold(t, day);
      expect(find.byKey(overlay), findsOneWidget);
      expect(find.byKey(ValueKey('day-peek-$todayIso')), findsOneWidget);
      expect(find.text('Easy run'), findsWidgets);
      expect(find.text('Tempo ride'), findsWidgets);
      await g.up();
      await t.pump();
      expect(find.byKey(overlay), findsNothing);
      expect(t.takeException(), isNull);
    });

    testWidgets('today\'s activity rows peek, a tap is unchanged', (t) async {
      await t.runAsync(seedActivity);
      await pumpToday(t);

      final row = find.byKey(const ValueKey('today-activity-act1'));
      await t.ensureVisible(row);
      await t.pump();
      final g = await hold(t, row);
      expect(find.byKey(overlay), findsOneWidget);
      expect(find.byKey(const ValueKey('activity-peek-act1')), findsOneWidget);
      // The peek's "this year" line reads the cache; let that finish.
      for (var i = 0; i < 4; i++) {
        await t.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 40)),
        );
        await t.pump();
      }
      await g.up();
      await t.pump();
      expect(find.byKey(overlay), findsNothing);
    });

    testWidgets('places whose long press does something have no peek', (
      t,
    ) async {
      await t.runAsync(() async {
        await planToday();
        await seedActivity();
      });
      await pumpToday(t);

      // Load tiles and This week: details sheets. (The hero peeks only on
      // its session icons, and the readiness card inside it has its own
      // pill peeks; the hero card itself has no long press — see
      // test/today_hero_card_test.dart.)
      for (final key in const ['load-tiles', 'this-week-card']) {
        final area = find.byKey(ValueKey(key));
        expect(area, findsOneWidget);
        expect(
          find.descendant(of: area, matching: find.byType(Peekable)),
          findsNothing,
        );
        expect(
          find.descendant(of: area, matching: find.byType(HoldPreview)),
          findsNothing,
        );
      }
    });
  });
}
