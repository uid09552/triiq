import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/calendar/agenda_view.dart';
import 'package:triiq/screens/calendar/calendar_day_marker.dart';
import 'package:triiq/widgets/workout_steps.dart';

Widget wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: Scaffold(body: child),
);

LocalEvent ev(String id, String date, {bool plan = false}) => LocalEvent(
  id: id,
  date: date,
  category: 'WORKOUT',
  type: 'Run',
  name: 'Easy run $id',
  description: null,
  plannedLoad: 50,
  plannedTime: 3600,
  plannedDistance: null,
  indoor: false,
  raw: {if (plan) LocalEvent.planSessionKey: 1},
  syncedAt: DateTime(2026),
);

LocalActivity act(String date) => LocalActivity(
  id: 'a$date',
  date: date,
  type: 'Ride',
  name: 'Morning ride',
  movingTime: 3600,
  distance: null,
  trainingLoad: 50,
  raw: const {},
  syncedAt: DateTime(2026),
);

BoxDecoration decorationOf(WidgetTester t, MarkerKind kind) {
  final c = t.widget<Container>(
    find
        .descendant(
          of: find.byKey(ValueKey('m-${kind.name}')),
          matching: find.byType(Container),
        )
        .first,
  );
  return c.decoration! as BoxDecoration;
}

void main() {
  testWidgets('done, planned and TriIQ plan differ in shape, not only colour', (
    t,
  ) async {
    await t.pumpWidget(
      wrap(
        Row(
          children: [
            for (final k in MarkerKind.values)
              KeyedSubtree(
                key: ValueKey('m-${k.name}'),
                child: CalendarDayMarker(
                  type: 'Run',
                  color: Colors.blue,
                  kind: k,
                ),
              ),
          ],
        ),
      ),
    );
    final done = decorationOf(t, MarkerKind.completed);
    final planned = decorationOf(t, MarkerKind.planned);
    final triiq = decorationOf(t, MarkerKind.triiqPlan);
    expect(done.color, isNotNull);
    expect(planned.color, isNull);
    expect(planned.border, isNotNull);
    expect(planned.shape, BoxShape.circle);
    expect(triiq.shape, BoxShape.rectangle);
    expect(triiq.border, isNotNull);
  });

  testWidgets('the agenda lists only days with sessions', (t) async {
    final tapped = <DateTime>[];
    await t.pumpWidget(
      wrap(
        AgendaView(
          month: DateTime(2026, 11),
          eventsByDate: {
            '2026-11-03': [ev('1', '2026-11-03')],
            '2026-11-10': [ev('2', '2026-11-10', plan: true)],
          },
          activitiesByDate: {
            '2026-11-10': [act('2026-11-10')],
            '2026-11-12': [act('2026-11-12')],
          },
          onSelect: tapped.add,
        ),
      ),
    );
    expect(find.byKey(const ValueKey('agenda-2026-11-03')), findsOneWidget);
    expect(find.byKey(const ValueKey('agenda-2026-11-10')), findsOneWidget);
    expect(find.byKey(const ValueKey('agenda-2026-11-12')), findsOneWidget);
    expect(find.byKey(const ValueKey('agenda-2026-11-04')), findsNothing);
    expect(find.text('Morning ride'), findsNWidgets(2));
    await t.tap(find.byKey(const ValueKey('agenda-2026-11-12')));
    expect(tapped, [DateTime(2026, 11, 12)]);
  });

  testWidgets('an empty month says so', (t) async {
    await t.pumpWidget(
      wrap(
        AgendaView(
          month: DateTime(2026, 11),
          eventsByDate: const {},
          activitiesByDate: const {},
          onSelect: (_) {},
        ),
      ),
    );
    expect(find.text('No sessions this month.'), findsOneWidget);
  });

  group('workout steps that did not parse', () {
    test('counts number-bearing notes after the first step only', () {
      final lines = parseWorkoutText(
        'Aerobic base.\n- 10m 60%\nthen 3x5min hard\n- 5m 50%\nSmooth.',
      );
      expect(unparsedStepLines(lines), 1);
    });
    test('clean text has none; pure notes have none', () {
      expect(unparsedStepLines(parseWorkoutText('- 10m 60%\n- 5m 50%')), 0);
      expect(unparsedStepLines(parseWorkoutText('Easy 30min spin')), 0);
    });
    testWidgets('the preview warns', (t) async {
      await t.pumpWidget(
        wrap(const WorkoutDescription(text: '- 10m 60%\nthen 3x5min hard')),
      );
      expect(find.byKey(const ValueKey('workout-parse-warning')), findsOneWidget);
      expect(find.textContaining('1 line was not read as a step'), findsOneWidget);
    });
  });
}
