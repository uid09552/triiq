import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/calendar/calendar_day_detail.dart';
import 'package:triiq/screens/calendar/day_events.dart';
import 'package:triiq/screens/calendar/monthly_calendar_view.dart';
import 'package:triiq/screens/events/event_editor_screen.dart';

LocalEvent ev(
  String id,
  String date,
  String category, {
  String? end,
  String? name,
}) => LocalEvent(
  id: id,
  date: date,
  category: category,
  type: null,
  name: name,
  description: null,
  plannedLoad: null,
  plannedTime: null,
  plannedDistance: null,
  indoor: false,
  raw: {if (end != null) 'end_date_local': '${end}T00:00:00'},
  syncedAt: DateTime(2026),
);

Widget wrap(Widget w) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: Scaffold(body: SingleChildScrollView(child: w)),
);

void main() {
  group('expandDayEvents', () {
    test('a multi-day entry covers every day through its last (inclusive)', () {
      final m = expandDayEvents(
        [ev('s', '2026-11-03', 'SICK', end: '2026-11-05')],
        '2026-11-01',
        '2026-11-30',
      );
      expect(m.keys, ['2026-11-03', '2026-11-04', '2026-11-05']);
    });

    test('an entry that started before the range still shows inside it', () {
      final m = expandDayEvents(
        [ev('h', '2026-10-28', 'HOLIDAY', end: '2026-11-02')],
        '2026-11-01',
        '2026-11-30',
      );
      expect(m.keys, ['2026-11-01', '2026-11-02']);
    });

    test('single-day notes and races; workouts are not day events', () {
      final m = expandDayEvents(
        [
          ev('n', '2026-11-10', 'NOTE'),
          ev('r', '2026-11-15', 'RACE_A'),
          ev('w', '2026-11-10', 'WORKOUT'),
        ],
        '2026-11-01',
        '2026-11-30',
      );
      expect(m['2026-11-10']!.map((e) => e.id), ['n']);
      expect(m['2026-11-15']!.single.id, 'r');
    });
  });

  testWidgets('the month grid shows the event icon on every covered day', (
    t,
  ) async {
    final sick = ev('s', '2026-11-03', 'SICK', end: '2026-11-04');
    await t.pumpWidget(
      wrap(
        MonthlyCalendarView(
          month: DateTime(2026, 11, 1),
          selectedDate: DateTime(2026, 11, 20),
          eventsByDate: const {},
          activitiesByDate: const {},
          onSelect: (_) {},
          dayEventsByDate: expandDayEvents([sick], '2026-10-26', '2026-12-06'),
        ),
      ),
    );
    expect(find.byKey(const ValueKey('day-event-s')), findsNWidgets(2));
    expect(find.byIcon(Icons.sick_outlined), findsNWidgets(2));
  });

  testWidgets('the day card lists the event with its kind and span', (t) async {
    final sick = ev('s', '2026-11-03', 'SICK', end: '2026-11-05', name: 'Flu');
    await t.pumpWidget(
      wrap(
        CalendarDayDetail(
          date: DateTime(2026, 11, 4),
          events: const [],
          activities: const [],
          dayEvents: [sick],
          today: () => DateTime(2026, 11, 10),
        ),
      ),
    );
    expect(find.byKey(const ValueKey('day-event-row-s')), findsOneWidget);
    expect(find.text('Flu'), findsOneWidget);
    expect(find.textContaining('Nov 3–Nov 5'), findsOneWidget);
    expect(find.text('Nothing planned or logged this day.'), findsNothing);
  });

  testWidgets('the event editor opens on the preset day and kind', (t) async {
    await t.pumpWidget(
      wrap(
        SizedBox(
          height: 800,
          child: EventEditorScreen(
            initialDate: DateTime(2026, 11, 3),
            initialCategory: 'SICK',
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('2026-11-03'), findsOneWidget);
    expect(find.text('Sick'), findsWidgets);
  });
}
