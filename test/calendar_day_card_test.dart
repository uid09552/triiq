import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/calendar/calendar_day_detail.dart';

LocalEvent planned(String name, String type, {int? load = 60, int? secs = 3600}) =>
    LocalEvent(
      id: name, date: '2026-11-04', category: 'WORKOUT', type: type, name: name,
      description: null, plannedLoad: load, plannedTime: secs,
      plannedDistance: null, indoor: false, raw: const {}, syncedAt: DateTime(2026),
    );

LocalActivity done(String type, {int load = 40, int secs = 2400}) => LocalActivity(
  id: '$type$load', date: '2026-11-04', type: type, name: 'Morning $type',
  movingTime: secs, distance: null, trainingLoad: load, raw: const {},
  syncedAt: DateTime(2026),
);

void main() {
  Widget wrap(Widget w) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: SingleChildScrollView(child: w)),
  );

  final day = DateTime(2026, 11, 4);

  testWidgets('date on one line, Today pill, done vs planned load with a bar',
      (t) async {
    await t.pumpWidget(wrap(CalendarDayDetail(
      date: day, today: () => DateTime(2026, 11, 4, 9),
      events: [planned('Easy run', 'Run', load: 80), planned('Strength', 'WeightTraining', load: 20)],
      activities: [done('Run', load: 55)],
    )));
    expect(find.text('Wed, Nov 4'), findsOneWidget);
    expect(find.byKey(const ValueKey('day-today-pill')), findsOneWidget);
    expect(find.text('55 / 100 TSS'), findsOneWidget);
    final bar = t.widget<LinearProgressIndicator>(find.byKey(const ValueKey('day-progress')));
    expect(bar.value, closeTo(0.55, 0.001));
  });

  testWidgets('a planned run covered by a completed run gets a check; strength does not',
      (t) async {
    await t.pumpWidget(wrap(CalendarDayDetail(
      date: day, today: () => DateTime(2026, 11, 10),
      events: [planned('Easy run', 'Run'), planned('Strength', 'WeightTraining')],
      activities: [done('Run')],
    )));
    expect(find.byKey(const ValueKey('day-today-pill')), findsNothing);
    expect(find.byKey(const ValueKey('planned-done')), findsOneWidget);
  });

  testWidgets('rows show duration and load, completed ones too', (t) async {
    await t.pumpWidget(wrap(CalendarDayDetail(
      date: day, today: () => DateTime(2026, 11, 10),
      events: [planned('Tempo', 'Ride', load: 70, secs: 5400)],
      activities: [done('Run', load: 42, secs: 2700)],
    )));
    expect(find.text('Planned · 90 min · 70 TSS'), findsOneWidget);
    expect(find.text('Completed · 45 min · 42 TSS'), findsOneWidget);
  });

  testWidgets('only completed work: just the TSS, no progress bar', (t) async {
    await t.pumpWidget(wrap(CalendarDayDetail(
      date: day, today: () => DateTime(2026, 11, 10),
      events: const [], activities: [done('Run', load: 33)],
    )));
    expect(find.text('33 TSS'), findsWidgets);
    expect(find.byKey(const ValueKey('day-progress')), findsNothing);
  });

  testWidgets('an empty day is a single quiet line', (t) async {
    await t.pumpWidget(wrap(CalendarDayDetail(
      date: day, today: () => DateTime(2026, 11, 10), events: const [], activities: const [],
    )));
    expect(find.text('Nothing planned or logged this day.'), findsOneWidget);
    expect(find.byKey(const ValueKey('day-load')), findsNothing);
  });
}
