import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/data/pending_deletes.dart';
import 'package:triiq/evaluation/readiness.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/calendar/calendar_data.dart';
import 'package:triiq/screens/calendar/calendar_level.dart';
import 'package:triiq/screens/calendar/calendar_moves.dart';
import 'package:triiq/screens/calendar/calendar_screen.dart';
import 'package:triiq/screens/calendar/monthly_calendar_view.dart';

final today = DateTime(2026, 11, 13, 9); // Friday, ISO week 46

LocalEvent workout(
  String id,
  String date, {
  String name = 'Easy run',
  String type = 'Run',
  int load = 50,
  int secs = 3600,
  int? planSession,
}) => LocalEvent(
  id: id,
  date: date,
  category: 'WORKOUT',
  type: type,
  name: name,
  description: null,
  plannedLoad: load,
  plannedTime: secs,
  plannedDistance: null,
  indoor: false,
  raw: {LocalEvent.planSessionKey: ?planSession},
  syncedAt: DateTime(2026),
);

LocalActivity activity(
  String id,
  String date, {
  String type = 'Run',
  int load = 50,
  int secs = 3600,
}) => LocalActivity(
  id: id,
  date: date,
  type: type,
  name: 'Morning $type',
  movingTime: secs,
  distance: null,
  trainingLoad: load,
  raw: const {},
  syncedAt: DateTime(2026),
);

class FakeLoader extends CalendarLoader {
  FakeLoader(this.events, {this.activities = const []});

  final List<LocalEvent> events;
  final List<LocalActivity> activities;

  @override
  Future<void> sync(DateTime a, DateTime b, CalendarFreshness f) async {}

  @override
  Future<CalendarData> read(DateTime oldest, DateTime newest) async {
    final e = <String, List<LocalEvent>>{};
    for (final x in events) {
      e.putIfAbsent(x.date, () => []).add(x);
    }
    final a = <String, List<LocalActivity>>{};
    for (final x in activities) {
      a.putIfAbsent(x.date, () => []).add(x);
    }
    return CalendarData(eventsByDate: e, activitiesByDate: a);
  }
}

class FakeMover extends CalendarMover {
  FakeMover() : super(clock: () => today);

  final moves = <(String, String, DateTime)>[];

  @override
  Future<void> move(LocalEvent event, DateTime target) async =>
      moves.add((event.id, event.date, target));
}

Widget app(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: Scaffold(body: child),
);

Future<void> pumpCalendar(
  WidgetTester t, {
  List<LocalEvent> events = const [],
  List<LocalActivity> activities = const [],
  FakeMover? mover,
}) async {
  t.view.physicalSize = const Size(1080, 2400);
  t.view.devicePixelRatio = 2.7; // 400 x 889 dp
  addTearDown(t.view.reset);
  await t.pumpWidget(
    app(
      CalendarScreen(
        loader: FakeLoader(events, activities: activities),
        mover: mover ?? FakeMover(),
        today: () => today,
      ),
    ),
  );
  await t.pumpAndSettle();
}

String crumb(WidgetTester t, String level) {
  final w = t.widget(find.byKey(ValueKey('crumb-$level')));
  if (w is Text) return w.data!;
  return (t.widget(
            find.descendant(
              of: find.byKey(ValueKey('crumb-$level')),
              matching: find.byType(Text),
            ),
          )
          as Text)
      .data!;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('drill down year → month → week → day, and back by breadcrumb', (
    t,
  ) async {
    await pumpCalendar(t);
    expect(crumb(t, 'year'), '2026');
    expect(crumb(t, 'month'), 'November');
    expect(find.byKey(const ValueKey('crumb-week')), findsNothing);

    await t.tap(find.byKey(const ValueKey('level-year')));
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('year-month-3')), findsOneWidget);
    expect(find.byKey(const ValueKey('crumb-month')), findsNothing);

    await t.tap(find.byKey(const ValueKey('year-month-3')));
    await t.pumpAndSettle();
    expect(crumb(t, 'month'), 'March');

    // The week-number column opens the week.
    await t.tap(find.byKey(const ValueKey('week-number-2026-03-02')));
    await t.pumpAndSettle();
    expect(crumb(t, 'week'), 'Week 10');
    expect(find.byKey(const ValueKey('week-summary')), findsOneWidget);

    // First tap selects a day, the second opens it.
    await t.tap(find.byKey(const ValueKey('week-day-2026-03-04')));
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('crumb-day')), findsNothing);
    await t.tap(find.byKey(const ValueKey('week-day-2026-03-04')));
    await t.pumpAndSettle();
    expect(crumb(t, 'day'), 'Wed, Mar 4');

    // Jump back up to the month from the breadcrumb.
    await t.tap(find.byKey(const ValueKey('crumb-month')));
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('crumb-day')), findsNothing);
    expect(find.byKey(const ValueKey('day-cell-2026-03-04')), findsOneWidget);

    // The level and date are remembered.
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(CalendarPrefs.levelKey), 'month');
    expect(prefs.getString(CalendarPrefs.dateKey), '2026-03-04');
  });

  testWidgets('reopens on the remembered level and date', (t) async {
    SharedPreferences.setMockInitialValues({
      CalendarPrefs.levelKey: 'week',
      CalendarPrefs.dateKey: '2026-12-02',
    });
    await pumpCalendar(t);
    expect(crumb(t, 'month'), 'December');
    expect(crumb(t, 'week'), 'Week 49');
  });

  testWidgets('swiping sideways changes the period', (t) async {
    await pumpCalendar(t);
    final area = find.byKey(const ValueKey('day-cell-2026-11-18'));
    await t.fling(area, const Offset(-300, 0), 1000);
    await t.pumpAndSettle();
    expect(crumb(t, 'month'), 'December');
    await t.fling(
      find.byKey(const ValueKey('day-cell-2026-12-16')),
      const Offset(300, 0),
      1000,
    );
    await t.pumpAndSettle();
    await t.fling(
      find.byKey(const ValueKey('day-cell-2026-11-18')),
      const Offset(300, 0),
      1000,
    );
    await t.pumpAndSettle();
    expect(crumb(t, 'month'), 'October');
  });

  testWidgets('drag a planned session to another day: rule warning and undo', (
    t,
  ) async {
    SharedPreferences.setMockInitialValues({
      CalendarPrefs.levelKey: 'week',
      CalendarPrefs.dateKey: '2026-11-13',
    });
    final mover = FakeMover();
    await pumpCalendar(
      t,
      mover: mover,
      events: [
        workout('101', '2026-11-13', name: 'VO2 intervals'),
        workout('102', '2026-11-15', name: 'Threshold run'),
      ],
    );

    final source = find.byKey(const ValueKey('week-planned-101'));
    final target = find.byKey(const ValueKey('week-day-2026-11-14'));
    await t.ensureVisible(target);
    await t.pumpAndSettle();
    final gesture = await t.startGesture(t.getCenter(source));
    await t.pump(kLongPressTimeout + const Duration(milliseconds: 100));
    await gesture.moveTo(t.getCenter(target));
    await t.pump();
    expect(find.byKey(const ValueKey('drop-preview')), findsOneWidget);
    await gesture.up();
    await t.pumpAndSettle();

    expect(mover.moves, [('101', '2026-11-13', DateTime(2026, 11, 14))]);
    expect(find.textContaining('two hard days in a row'), findsOneWidget);

    await t.tap(find.text('Undo'));
    await t.pumpAndSettle();
    expect(mover.moves.last, ('101', '2026-11-14', DateTime(2026, 11, 13)));
  });

  testWidgets('a past session cannot be dragged and says why', (t) async {
    SharedPreferences.setMockInitialValues({
      CalendarPrefs.levelKey: 'week',
      CalendarPrefs.dateKey: '2026-11-11',
    });
    final mover = FakeMover();
    await pumpCalendar(t, mover: mover, events: [workout('90', '2026-11-11')]);
    await t.longPress(find.byKey(const ValueKey('week-planned-90')));
    await t.pumpAndSettle();
    expect(find.textContaining('past'), findsWidgets);
    expect(mover.moves, isEmpty);
  });

  testWidgets('swipe a planned session left: deleted with undo', (t) async {
    SharedPreferences.setMockInitialValues({
      CalendarPrefs.levelKey: 'day',
      CalendarPrefs.dateKey: '2026-11-14',
    });
    await pumpCalendar(
      t,
      events: [workout('plan:5', '2026-11-14', planSession: 5)],
    );
    final row = find.byKey(const ValueKey('plan-session-5'));
    expect(row, findsOneWidget);

    await t.fling(row, const Offset(-400, 0), 1500);
    await t.pumpAndSettle();
    expect(PendingDeletes.instance.isHidden('plan:5'), isTrue);
    expect(row, findsNothing);
    // Not a period swipe: still on the same day.
    expect(crumb(t, 'day'), 'Sat, Nov 14');

    await t.tap(find.text('Undo'));
    await t.pumpAndSettle();
    expect(PendingDeletes.instance.isHidden('plan:5'), isFalse);
    expect(row, findsOneWidget);
  });

  testWidgets('"Move to…" moves without a gesture', (t) async {
    SharedPreferences.setMockInitialValues({
      CalendarPrefs.levelKey: 'day',
      CalendarPrefs.dateKey: '2026-11-14',
    });
    final mover = FakeMover();
    await pumpCalendar(t, mover: mover, events: [workout('201', '2026-11-14')]);
    await t.tap(find.byKey(const ValueKey('move-201')));
    await t.pumpAndSettle();
    await t.tap(find.text('20'));
    await t.tap(find.text('OK'));
    await t.pumpAndSettle();
    expect(mover.moves, [('201', '2026-11-14', DateTime(2026, 11, 20))]);
    expect(find.textContaining('moved to'), findsOneWidget);
  });

  testWidgets('day cells show the load fill, readiness dot and badges', (
    t,
  ) async {
    const ready = Readiness(
      level: ReadinessLevel.ready,
      signals: [],
      dataState: ReadinessDataState.complete,
    );
    await t.pumpWidget(
      app(
        SingleChildScrollView(
          child: MonthlyCalendarView(
            month: DateTime(2026, 11, 1),
            selectedDate: DateTime(2026, 11, 13),
            today: () => today,
            eventsByDate: {
              '2026-11-10': [workout('a', '2026-11-10', load: 60)],
              '2026-11-11': [workout('b', '2026-11-11', load: 100)],
              '2026-11-20': [workout('c', '2026-11-20', name: 'VO2 intervals')],
            },
            activitiesByDate: {
              '2026-11-10': [activity('x', '2026-11-10', load: 62)],
              '2026-11-11': [activity('y', '2026-11-11', load: 30)],
              '2026-11-12': [
                activity('z', '2026-11-12', type: 'WeightTraining'),
              ],
            },
            readinessByDate: const {'2026-11-10': ready, '2026-11-25': ready},
            onSelect: (_) {},
          ),
        ),
      ),
    );
    expect(
      find.byKey(const ValueKey('day-fill-done-2026-11-10')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('day-fill-partial-2026-11-11')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('day-fill-empty-2026-11-20')),
      findsOneWidget,
    );
    // Readiness only for days up to today.
    expect(find.byKey(const ValueKey('readiness-dot-ready')), findsOneWidget);
    expect(find.byKey(const ValueKey('badge-key')), findsOneWidget);
    expect(find.byKey(const ValueKey('badge-strength')), findsOneWidget);
    expect(find.byKey(const ValueKey('sport-bar')), findsNWidgets(4));
    // A screen reader hears the day's summary.
    expect(
      find.bySemanticsLabel(RegExp(r'Tuesday, November 10.*60 / 50 TSS')),
      findsNothing,
    );
    expect(
      find.bySemanticsLabel(RegExp(r'November 10, .*1 planned, 1 done')),
      findsOneWidget,
    );
  });

  for (final dark in [false, true]) {
    testWidgets('every level fits 360 dp at 2x text (dark: $dark)', (t) async {
      t.view.physicalSize = const Size(720, 1480);
      t.view.devicePixelRatio = 2; // 360 x 740 dp
      addTearDown(t.view.reset);
      for (final level in CalendarLevel.values) {
        SharedPreferences.setMockInitialValues({
          CalendarPrefs.levelKey: level.name,
          CalendarPrefs.dateKey: '2026-11-13',
        });
        await t.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('de'),
            theme: ThemeData(
              brightness: dark ? Brightness.dark : Brightness.light,
            ),
            home: MediaQuery.withClampedTextScaling(
              minScaleFactor: 2,
              maxScaleFactor: 2,
              child: Scaffold(
                body: CalendarScreen(
                  key: ValueKey(level),
                  loader: FakeLoader(
                    [
                      workout('1', '2026-11-13', name: 'VO2 intervals'),
                      workout('2', '2026-11-14', type: 'Ride', secs: 7200),
                    ],
                    activities: [activity('a', '2026-11-13')],
                  ),
                  mover: FakeMover(),
                  today: () => today,
                ),
              ),
            ),
          ),
        );
        await t.pumpAndSettle();
        expect(t.takeException(), isNull, reason: level.name);
      }
    });
  }

  test('period helpers', () {
    expect(isoWeekNumber(DateTime(2026, 11, 13)), 46);
    expect(isoWeekNumber(DateTime(2027, 1, 1)), 53);
    expect(
      shiftPeriod(CalendarLevel.month, DateTime(2026, 1, 31), 1),
      DateTime(2026, 2, 28),
    );
    expect(calendarRange(CalendarLevel.week, DateTime(2026, 11, 13)), (
      DateTime(2026, 11, 9),
      DateTime(2026, 11, 15),
    ));
  });

  test('move warnings follow the plan placement rules', () {
    final strength = workout(
      's',
      '2026-11-16',
      name: 'Strength',
      type: 'WeightTraining',
    );
    final hard = workout('h', '2026-11-20', name: 'Threshold intervals');
    final w = moveWarnings(hard, DateTime(2026, 11, 17), {
      '2026-11-16': [strength],
    });
    expect(w, [MoveWarning.hardAfterStrength]);
    expect(
      moveWarnings(strength, DateTime(2026, 11, 19), {
        '2026-11-20': [hard],
      }),
      [MoveWarning.strengthBeforeHard],
    );
    expect(
      moveWarnings(workout('e', '2026-11-18'), DateTime(2026, 11, 17), {
        '2026-11-16': [strength],
      }),
      isEmpty,
    );
  });
}
