import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/data/repositories/events_repository.dart';
import 'package:triiq/evaluation/readiness.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/navigation/app_destinations.dart';
import 'package:triiq/navigation/okf_index.dart';
import 'package:triiq/screens/activities/activities_screen.dart';
import 'package:triiq/screens/events/events_screen.dart';
import 'package:triiq/screens/more/more_screen.dart';
import 'package:triiq/screens/today/week_ribbon.dart';
import 'package:triiq/widgets/day_peek.dart';
import 'package:triiq/widgets/main_navigation.dart';
import 'package:triiq/widgets/peek_cards.dart';
import 'package:triiq/widgets/peekable.dart';

// A Wednesday; its week runs Mon 2026-11-02 .. Sun 2026-11-08.
final _today = DateTime(2026, 11, 4);

LocalEvent _planned(
  String id,
  String date, {
  String name = 'Tempo ride',
  String type = 'Ride',
  int minutes = 65,
  int load = 78,
  String category = 'WORKOUT',
  String? description,
}) => LocalEvent(
  id: id,
  date: date,
  category: category,
  type: type,
  name: name,
  description: description,
  plannedLoad: load,
  plannedTime: minutes * 60,
  plannedDistance: null,
  indoor: false,
  raw: const {},
  syncedAt: DateTime(2026, 11, 1),
);

LocalActivity _done(
  String id,
  String date, {
  String name = 'Morning run',
  String type = 'Run',
  int minutes = 45,
  int load = 50,
}) => LocalActivity(
  id: id,
  date: date,
  type: type,
  name: name,
  movingTime: minutes * 60,
  distance: 9000,
  trainingLoad: load,
  raw: {'id': id, 'average_heartrate': 148, 'icu_average_watts': 210},
  syncedAt: DateTime(2026, 11, 1),
);

Widget _app(Widget child, {Locale locale = const Locale('en')}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: locale,
  home: Scaffold(body: child),
);

Future<TestGesture> _hold(
  WidgetTester tester,
  Finder target, {
  int ms = 700,
}) async {
  final g = await tester.startGesture(tester.getCenter(target));
  await tester.pump(Duration(milliseconds: ms));
  await tester.pump(const Duration(milliseconds: 300));
  return g;
}

const _overlay = ValueKey('hold-preview');

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    MainNavigation.instance.debugReset();
  });

  void phone(WidgetTester tester, {Size size = const Size(360, 800)}) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('DayPeek content', () {
    Future<void> pumpPeek(WidgetTester tester, DayPeekData data) async {
      phone(tester);
      await tester.pumpWidget(
        _app(
          Padding(
            padding: const EdgeInsets.all(16),
            child: DayPeek(data: data, showTrend: false),
          ),
        ),
      );
    }

    testWidgets('planned only: sessions, planned TSS, no progress yet', (
      tester,
    ) async {
      await pumpPeek(
        tester,
        DayPeekData(day: _today, planned: [_planned('1', '2026-11-04')]),
      );
      expect(find.text('Wed, Nov 4'), findsOneWidget);
      expect(find.text('PLANNED'), findsOneWidget);
      expect(find.text('Tempo ride'), findsOneWidget);
      expect(find.text('65 min · 78 TSS'), findsOneWidget);
      expect(find.text('COMPLETED'), findsNothing);
      expect(find.text('0 of 78 TSS'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('completed only: activities and the TSS done', (tester) async {
      await pumpPeek(
        tester,
        DayPeekData(day: _today, activities: [_done('a', '2026-11-04')]),
      );
      expect(find.text('COMPLETED'), findsOneWidget);
      expect(find.text('Morning run'), findsOneWidget);
      expect(find.text('45m · 50 TSS'), findsOneWidget);
      expect(find.text('PLANNED'), findsNothing);
      expect(find.text('50 TSS done'), findsOneWidget);
      // Nothing was planned, so there is no bar to fill.
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('empty day says rest', (tester) async {
      await pumpPeek(tester, DayPeekData(day: _today));
      expect(find.textContaining('Empty day'), findsOneWidget);
      expect(find.textContaining('Rest'), findsOneWidget);
      expect(find.byKey(const ValueKey('day-peek-load')), findsNothing);
    });

    testWidgets('mixed: both lists and done-versus-planned', (tester) async {
      await pumpPeek(
        tester,
        DayPeekData(
          day: _today,
          planned: [
            _planned('1', '2026-11-04', load: 100),
            _planned('2', '2026-11-04', name: 'Swim', type: 'Swim', load: 20),
          ],
          activities: [_done('a', '2026-11-04', load: 60)],
        ),
      );
      expect(find.text('PLANNED'), findsOneWidget);
      expect(find.text('COMPLETED'), findsOneWidget);
      expect(find.text('60 of 120 TSS'), findsOneWidget);
      final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bar.value, 0.5);
    });

    testWidgets('long lists are capped with "+N more"', (tester) async {
      await pumpPeek(
        tester,
        DayPeekData(
          day: _today,
          planned: [
            for (var i = 0; i < 5; i++)
              _planned('p$i', '2026-11-04', name: 'S$i'),
          ],
        ),
      );
      expect(find.text('S2'), findsOneWidget);
      expect(find.text('S3'), findsNothing);
      expect(find.text('+2 more'), findsOneWidget);
    });

    testWidgets('readiness shows when the day has it, never blocks', (
      tester,
    ) async {
      phone(tester);
      await tester.pumpWidget(
        _app(
          DayPeek(
            data: DayPeekData(day: _today),
            showTrend: false,
            readinessLoader: () async => const Readiness(
              level: ReadinessLevel.caution,
              signals: [],
              dataState: ReadinessDataState.complete,
            ),
          ),
        ),
      );
      expect(find.byKey(const ValueKey('day-peek-readiness')), findsNothing);
      await tester.pump();
      expect(find.byKey(const ValueKey('day-peek-readiness')), findsOneWidget);
      expect(find.text('Readiness: Caution'), findsOneWidget);
    });

    testWidgets('German', (tester) async {
      phone(tester);
      await tester.pumpWidget(
        _app(
          DayPeek(data: DayPeekData(day: _today), showTrend: false),
          locale: const Locale('de'),
        ),
      );
      expect(find.textContaining('Leerer Tag'), findsOneWidget);
    });
  });

  group('week ribbon peek', () {
    final events = [
      _planned('1', '2026-11-04'),
      _planned('2', '2026-11-05', name: 'Long ride', minutes: 180, load: 150),
      _planned('n', '2026-11-04', name: 'Holiday', category: 'HOLIDAY'),
    ];
    final acts = [_done('a', '2026-11-03')];

    Future<void> pumpRibbon(
      WidgetTester tester, {
      Size size = const Size(360, 800),
    }) async {
      phone(tester, size: size);
      await tester.pumpWidget(
        _app(
          ListView(
            children: [
              const SizedBox(height: 200),
              WeekRibbon(
                today: _today,
                activities: acts,
                events: events,
                readinessFor: (_) async => null,
              ),
              const SizedBox(height: 900),
            ],
          ),
        ),
      );
    }

    final wed = find.byKey(const ValueKey('ribbon-2026-11-04'));

    testWidgets('holding a day peeks, letting go hides it', (tester) async {
      await pumpRibbon(tester);
      expect(find.byKey(_overlay), findsNothing);

      final g = await _hold(tester, wed);
      expect(find.byKey(_overlay), findsOneWidget);
      expect(find.byKey(const ValueKey('day-peek-2026-11-04')), findsOneWidget);
      expect(find.text('Wed, Nov 4'), findsOneWidget);
      expect(find.text('Tempo ride'), findsOneWidget);
      // Notes and holidays are not sessions.
      expect(find.text('Holiday'), findsNothing);

      await g.up();
      await tester.pump();
      expect(find.byKey(_overlay), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a completed day lists its activities', (tester) async {
      await pumpRibbon(tester);
      final g = await _hold(
        tester,
        find.byKey(const ValueKey('ribbon-2026-11-03')),
      );
      expect(find.text('Morning run'), findsOneWidget);
      await g.up();
      await tester.pump();
    });

    testWidgets('a rest day shows the empty state', (tester) async {
      await pumpRibbon(tester);
      final g = await _hold(
        tester,
        find.byKey(const ValueKey('ribbon-2026-11-07')),
      );
      expect(find.textContaining('Empty day'), findsOneWidget);
      await g.up();
      await tester.pump();
    });

    testWidgets('a tap still opens the calendar on that day, no peek', (
      tester,
    ) async {
      await pumpRibbon(tester);
      await tester.tap(wed);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byKey(_overlay), findsNothing);
      expect(MainNavigation.instance.calendarFocus?.date, _today);
    });

    testWidgets('a touch that becomes a scroll never peeks', (tester) async {
      await pumpRibbon(tester);
      final g = await tester.startGesture(tester.getCenter(wed));
      await tester.pump(const Duration(milliseconds: 100));
      await g.moveBy(const Offset(0, -80));
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.byKey(_overlay), findsNothing);
      await g.up();
      await tester.pump();
      expect(find.byKey(_overlay), findsNothing);
    });

    testWidgets('screen readers get a "Show preview" action', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpRibbon(tester);
      final node = tester.getSemantics(wed);
      final ids = node.getSemanticsData().customSemanticsActionIds ?? [];
      final labels = [
        for (final id in ids) CustomSemanticsAction.getAction(id)!.label,
      ];
      expect(labels, contains('Show preview'));
      // The label still reads as the day's status.
      expect(node.label, contains('Open in the calendar'));

      final showId = ids.firstWhere(
        (id) => CustomSemanticsAction.getAction(id)!.label == 'Show preview',
      );
      node.owner!.performAction(node.id, SemanticsAction.customAction, showId);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('peek-dialog')), findsOneWidget);
      expect(find.byKey(const ValueKey('day-peek-2026-11-04')), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('peek-dialog')), findsNothing);
      handle.dispose();
    });

    testWidgets('360 dp at 2x text: no overflow, card stays on screen', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      phone(tester);
      await tester.pumpWidget(
        _app(
          ListView(
            children: [
              const SizedBox(height: 120),
              WeekRibbon(
                today: _today,
                activities: [
                  for (var i = 0; i < 5; i++)
                    _done(
                      'a$i',
                      '2026-11-04',
                      name: 'A very long activity name number $i that wraps',
                    ),
                ],
                events: [
                  for (var i = 0; i < 5; i++)
                    _planned(
                      'p$i',
                      '2026-11-04',
                      name: 'A very long planned session name number $i',
                    ),
                ],
                readinessFor: (_) async => const Readiness(
                  level: ReadinessLevel.ready,
                  signals: [],
                  dataState: ReadinessDataState.complete,
                ),
              ),
            ],
          ),
        ),
      );
      final g = await _hold(tester, wed);
      expect(find.byKey(_overlay), findsOneWidget);
      final card = tester.getRect(
        find
            .descendant(
              of: find.byKey(_overlay),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(card.left, greaterThanOrEqualTo(0));
      expect(card.right, lessThanOrEqualTo(360));
      expect(card.bottom, lessThanOrEqualTo(800));
      await g.up();
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('reduced motion shows the card at once', (tester) async {
      await pumpRibbon(tester);
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await tester.pump();
      final g = await tester.startGesture(tester.getCenter(wed));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 20));
      final opacity = tester.widget<Opacity>(
        find
            .descendant(
              of: find.byKey(_overlay),
              matching: find.byType(Opacity),
            )
            .first,
      );
      expect(opacity.opacity, 1);
      await g.up();
      await tester.pump();
    });

    testWidgets('dark theme', (tester) async {
      phone(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: ListView(
              children: [
                const SizedBox(height: 200),
                WeekRibbon(
                  today: _today,
                  activities: acts,
                  events: events,
                  readinessFor: (_) async => null,
                ),
              ],
            ),
          ),
        ),
      );
      final g = await _hold(tester, wed);
      expect(find.byKey(_overlay), findsOneWidget);
      await g.up();
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('other peeks', () {
    testWidgets('search result: hold shows the okf passage', (tester) async {
      phone(tester, size: const Size(400, 900));
      final okf = OkfIndex.parse(File('docs/okf.md').readAsStringSync());
      final d = searchDestinations('calendar', okf: okf).first;
      await tester.pumpWidget(
        _app(
          Align(
            alignment: Alignment.center,
            child: DestinationTile(destination: d, okf: okf),
          ),
        ),
      );
      final g = await _hold(
        tester,
        find.byKey(ValueKey('search-result-${d.id}')),
      );
      expect(find.byKey(_overlay), findsOneWidget);
      expect(find.byKey(const ValueKey('text-peek')), findsOneWidget);
      await g.up();
      await tester.pump();
      expect(find.byKey(_overlay), findsNothing);
      // Tap is unchanged: the tile is still an ordinary ListTile.
      expect(find.byType(Peekable), findsOneWidget);
    });

    testWidgets('activities list row: hold shows key figures', (tester) async {
      phone(tester, size: const Size(400, 900));
      await tester.runAsync(
        () => ActivitiesRepository().upsertAll([
          _done('77', '2026-11-03', name: 'Hilly run'),
        ]),
      );
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const ActivitiesScreen(),
        ),
      );
      for (var i = 0; i < 8; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 40)),
        );
        await tester.pump();
      }
      final row = find.byKey(const ValueKey('activity-row-77'));
      expect(row, findsOneWidget);
      final g = await _hold(tester, row);
      expect(find.byKey(_overlay), findsOneWidget);
      expect(find.byKey(const ValueKey('activity-peek-77')), findsOneWidget);
      expect(find.text('148'), findsOneWidget); // avg HR
      await g.up();
      await tester.pump();
      expect(find.byKey(_overlay), findsNothing);
    });

    testWidgets('events list: hold shows the event, delete stays a button', (
      tester,
    ) async {
      phone(tester, size: const Size(400, 900));
      await tester.runAsync(
        () => EventsRepository().upsert(
          _planned(
            'race1',
            '2026-12-06',
            name: 'City marathon',
            type: 'Run',
            category: 'RACE_A',
            description: 'A goal race. Start 09:00.',
          ),
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const EventsScreen(),
        ),
      );
      for (var i = 0; i < 8; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 40)),
        );
        await tester.pump();
      }
      final tile = find.byKey(const ValueKey('event-tile-race1'));
      expect(tile, findsOneWidget);
      final g = await _hold(tester, tile);
      expect(find.byKey(const ValueKey('event-peek-race1')), findsOneWidget);
      expect(find.text('A goal race. Start 09:00.'), findsOneWidget);
      await g.up();
      await tester.pump();
      expect(find.byKey(_overlay), findsNothing);
    });

    testWidgets('EventPeek and ActivityPeek fit 360 dp at 2x text', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      phone(tester);
      await tester.pumpWidget(
        _app(
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ActivityPeek(activity: _done('x', '2026-11-03')),
                  EventPeek(
                    event: _planned(
                      'e',
                      '2026-12-06',
                      name: 'A race with a really rather long name indeed',
                      category: 'RACE_A',
                      description: 'Long\n' * 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('exclusions: a long press that already does something', () {
    // Peeks must never sit on an item whose long press means something else
    // (menus, sheets, drag). These files own such long presses, so they
    // must not use HoldPreview or Peekable at all. today_screen.dart is
    // listed apart: its activity rows peek, its load tiles do not (the hero card
    // is allowed to peek, but only on its session icons) (that is
    // asserted on the rendered screen in test/today_states_test.dart).
    const excluded = [
      'lib/screens/calendar/calendar_screen.dart',
      'lib/screens/calendar/monthly_calendar_view.dart',
      'lib/screens/calendar/weekly_calendar_view.dart',
      'lib/screens/calendar/day_calendar_view.dart',
      'lib/screens/calendar/calendar_drag.dart',
      'lib/screens/calendar/calendar_day_detail.dart',
      'lib/screens/calendar/day_cell_parts.dart',
      'lib/screens/today/this_week_card.dart',
      'lib/screens/today/weekly_targets_row.dart',
      'lib/screens/today/customize_today_sheet.dart',
      'lib/screens/customize_navigation_sheet.dart',
      'lib/widgets/main_shell.dart',
      'lib/widgets/section_card.dart',
      'lib/widgets/stat_tile.dart',
    ];

    test('excluded files do not use a peek', () {
      for (final path in excluded) {
        final file = File(path);
        if (!file.existsSync()) continue;
        final source = file.readAsStringSync();
        expect(
          source.contains('Peekable(') || source.contains('HoldPreview('),
          isFalse,
          reason: '$path has its own long-press behaviour',
        );
      }
    });

    test('only the documented places use a peek', () {
      const allowed = {
        'lib/widgets/peekable.dart',
        'lib/widgets/hold_preview.dart',
        'lib/screens/statistics/insights_grid.dart',
        'lib/screens/today/readiness_card.dart',
        // Only the icons of today's sessions: the card's long press is gone.
        'lib/screens/today/today_hero_card.dart',
        'lib/screens/today/week_ribbon.dart',
        'lib/screens/today/today_screen.dart',
        'lib/screens/activities/activities_screen.dart',
        'lib/screens/plan/plan_screen.dart',
        'lib/screens/events/events_screen.dart',
        'lib/screens/more/more_screen.dart',
      };
      final users = <String>{};
      for (final f in Directory('lib').listSync(recursive: true)) {
        if (f is! File || !f.path.endsWith('.dart')) continue;
        final s = f.readAsStringSync();
        if (s.contains('Peekable(') || s.contains('HoldPreview(')) {
          users.add(f.path.replaceAll(r'\', '/'));
        }
      }
      expect(users, allowed);
    });
  });
}
