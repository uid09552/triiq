import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/calendar/day_actions.dart';
import 'package:triiq/screens/today/train_now_screen.dart';

LocalEvent ev({bool plan = false}) => LocalEvent(
  id: plan ? 'plan:1' : '501', date: '2026-11-10', category: 'WORKOUT', type: 'Run',
  name: 'Run', description: null, plannedLoad: 40, plannedTime: 3600,
  plannedDistance: null, indoor: false,
  raw: plan ? {LocalEvent.planSessionKey: 1} : const {}, syncedAt: DateTime(2026),
);

void main() {
  final today = DateTime(2026, 11, 4, 9);

  Future<void> open(
    WidgetTester t,
    DateTime date,
    List<LocalEvent> events,
    List<DateTime> opened,
  ) async {
    await t.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onLongPress: () => showDayActions(
                context, date, events,
                today: () => today,
                openTrainNow: (_, day) => opened.add(day),
              ),
              child: const SizedBox(width: 200, height: 200, key: ValueKey('cell')),
            ),
          ),
        ),
      ),
    );
    await t.longPress(find.byKey(const ValueKey('cell')));
    await t.pumpAndSettle();
  }

  testWidgets('a future day offers propose next to delete; propose opens that day',
      (t) async {
    final opened = <DateTime>[];
    await open(t, DateTime(2026, 11, 10), [ev(plan: true)], opened);
    expect(find.byKey(const ValueKey('day-propose')), findsOneWidget);
    expect(find.byKey(const ValueKey('day-delete')), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('day-propose')));
    await t.pumpAndSettle();
    expect(opened, [DateTime(2026, 11, 10)]);
  });

  testWidgets('an empty future day still offers propose, not delete', (t) async {
    await open(t, DateTime(2026, 11, 10), const [], []);
    expect(find.byKey(const ValueKey('day-propose')), findsOneWidget);
    expect(find.byKey(const ValueKey('day-delete')), findsNothing);
  });

  testWidgets('a past day only offers delete, and nothing when nothing is deletable',
      (t) async {
    await open(t, DateTime(2026, 11, 2), [ev(plan: true)], []);
    expect(find.byKey(const ValueKey('day-propose')), findsNothing);
    expect(find.byKey(const ValueKey('day-delete')), findsOneWidget);
  });

  testWidgets('a past day whose sessions cannot be deleted (offline) offers nothing',
      (t) async {
    await open(t, DateTime(2026, 11, 2), [ev()], []);
    expect(find.byType(BottomSheet), findsNothing);
  });

  test('the prompt names the day when it is not today', () {
    final p = TrainNowScreen.buildPrompt(
      intensityWord: 'an easy', sport: 'Run', minutes: 45, dayLabel: '2026-11-10',
    );
    expect(p, contains('on 2026-11-10'));
    expect(p, isNot(contains('right now')));
    expect(
      TrainNowScreen.buildPrompt(intensityWord: 'an easy', sport: 'Run', minutes: 45),
      contains('right now'),
    );
  });
}
