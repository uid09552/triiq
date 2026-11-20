import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/evaluation/readiness.dart';
import 'package:triiq/evaluation/readiness_service.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/season/illness_mode.dart';
import 'package:triiq/screens/today/today_hero_card.dart';

LocalEvent _planned(
  String id,
  String name, {
  String type = 'Ride',
  String? slot,
  int minutes = 65,
  int load = 78,
}) => LocalEvent(
  id: id,
  date: '2026-11-04',
  category: 'WORKOUT',
  type: type,
  name: name,
  description: null,
  plannedLoad: load,
  plannedTime: minutes * 60,
  plannedDistance: null,
  indoor: false,
  raw: {LocalEvent.planSlotKey: ?slot},
  syncedAt: DateTime(2026, 11, 4),
);

LocalActivity _done(String id, {String type = 'Ride'}) => LocalActivity(
  id: id,
  date: '2026-11-04',
  type: type,
  name: 'Morning ride',
  movingTime: 3600,
  distance: 30000,
  trainingLoad: 70,
  raw: const {},
  syncedAt: DateTime(2026, 11, 4),
);

ReadinessReport _readiness(
  ReadinessLevel level, {
  ReadinessDataState state = ReadinessDataState.complete,
}) => ReadinessReport(
  Readiness(level: level, signals: const [], dataState: state),
  const [],
);

void main() {
  final calls = <String>[];
  setUp(calls.clear);

  Widget hero({
    List<LocalEvent> plan = const [],
    List<LocalActivity> activities = const [],
    List<LocalEvent> tomorrow = const [],
    ReadinessReport? readiness,
    ({HealthIssue issue, HealthPhase phase})? health,
    bool connected = true,
    int? fatigue,
  }) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TodayHeroCard(
            date: DateTime(2026, 11, 4),
            connected: connected,
            loading: false,
            readiness: readiness,
            todaysPlan: plan,
            activities: activities,
            tomorrowsPlan: tomorrow,
            health: health,
            fatigue: fatigue,
            onRefresh: () => calls.add('refresh'),
            onTrainNow: () => calls.add('train'),
            onSwapEasier: (e) => calls.add('swap:${e.id}'),
            onFeel: () => calls.add('feel'),
            onCustomize: () => calls.add('customize'),
            onOpenPlanned: (e) => calls.add('open:${e.id}'),
            onOpenActivity: (a) => calls.add('activity:${a.id}'),
            onMoveToTomorrow: (e) => calls.add('move:${e.id}'),
            onAskTrainer: () => calls.add('ask'),
            onOpenTomorrow: () => calls.add('tomorrow'),
            onOpenIntervals: connected ? () => calls.add('intervals') : null,
            onExplainReadiness: () => calls.add('explain'),
          ),
        ],
      ),
    ),
  );

  group('primary action', () {
    test('picks start, swap, feel or propose from the day', () {
      final z2 = _planned('1', 'Easy spin', slot: 'z2');
      final long = _planned('2', 'Long ride', slot: 'long');
      expect(
        heroActionFor(remaining: [z2], doneSomething: false),
        HeroAction.start,
      );
      expect(
        heroActionFor(
          remaining: [z2],
          doneSomething: false,
          level: ReadinessLevel.caution,
        ),
        HeroAction.start,
        reason: 'an easy session needs no swap',
      );
      expect(
        heroActionFor(
          remaining: [long],
          doneSomething: false,
          level: ReadinessLevel.backOff,
        ),
        HeroAction.swapEasier,
      );
      expect(
        heroActionFor(remaining: const [], doneSomething: true),
        HeroAction.logFeel,
      );
      expect(
        heroActionFor(remaining: const [], doneSomething: false),
        HeroAction.propose,
      );
      expect(
        heroActionFor(remaining: [long], doneSomething: false, sick: true),
        HeroAction.logFeel,
      );
    });

    testWidgets('planned and ready: Start opens the session', (t) async {
      await t.pumpWidget(
        hero(
          plan: [_planned('7', 'VO2 intervals 5x4')],
          readiness: _readiness(ReadinessLevel.ready),
        ),
      );
      expect(find.text('VO2 intervals 5x4'), findsOneWidget);
      await t.tap(find.byKey(const ValueKey('hero-primary-start')));
      expect(calls, ['open:7']);
    });

    testWidgets('caution with a hard session: Swap for easier', (t) async {
      await t.pumpWidget(
        hero(
          plan: [_planned('8', 'Long ride', slot: 'long')],
          readiness: _readiness(ReadinessLevel.caution),
        ),
      );
      expect(find.text('Train with care'), findsOneWidget);
      await t.tap(find.byKey(const ValueKey('hero-primary-swapEasier')));
      expect(calls, ['swap:8']);
    });

    testWidgets('done: the card flips to the result and asks how it felt', (
      t,
    ) async {
      await t.runAsync(() async {
        await t.pumpWidget(
          hero(
            plan: [_planned('9', 'Endurance ride')],
            activities: [_done('a')],
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await t.pump();
      expect(find.byKey(const ValueKey('hero-result')), findsOneWidget);
      expect(find.text('Endurance ride'), findsNothing);
      expect(find.text('1 activity logged today'), findsOneWidget);
      // Planned against actual.
      expect(find.text('1h 00m of 1h 05m · 70 of 78 TSS'), findsOneWidget);
      expect(find.text('How did it feel? Not logged yet.'), findsOneWidget);
      await t.tap(find.byKey(const ValueKey('hero-primary-logFeel')));
      expect(calls, ['feel']);
    });

    testWidgets('feel already logged: no primary button, refresh stays', (
      t,
    ) async {
      await t.pumpWidget(
        hero(
          plan: [_planned('9', 'Endurance ride')],
          activities: [_done('a')],
          fatigue: 2,
        ),
      );
      expect(find.byKey(const ValueKey('hero-primary-logFeel')), findsNothing);
      expect(find.byKey(const ValueKey('hero-refresh')), findsOneWidget);
      expect(find.byKey(const ValueKey('hero-more')), findsOneWidget);
    });

    testWidgets('nothing planned: Propose training', (t) async {
      await t.pumpWidget(hero());
      expect(find.byKey(const ValueKey('hero-rest')), findsOneWidget);
      await t.tap(find.byKey(const ValueKey('hero-primary-propose')));
      expect(calls, ['train']);
    });
  });

  testWidgets('waiting for watch data: a placeholder with refresh', (t) async {
    await t.pumpWidget(
      hero(
        readiness: _readiness(
          ReadinessLevel.ready,
          state: ReadinessDataState.waitingForToday,
        ),
      ),
    );
    expect(find.byKey(const ValueKey('readiness-waiting')), findsOneWidget);
    expect(find.byKey(const ValueKey('hero-readiness')), findsNothing);
    expect(find.text('Waiting for watch data'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('readiness-waiting-refresh')));
    expect(calls, ['refresh']);
  });

  testWidgets('tapping the ring asks for the explanation', (t) async {
    await t.pumpWidget(hero(readiness: _readiness(ReadinessLevel.ready)));
    await t.tap(find.byKey(const ValueKey('hero-readiness')));
    expect(calls, ['explain']);
  });

  testWidgets('sick: no sessions, no tomorrow, the action is how you feel', (
    t,
  ) async {
    await t.pumpWidget(
      hero(
        plan: [_planned('3', 'Threshold run', type: 'Run')],
        health: (
          issue: HealthIssue(
            kind: HealthKind.sick,
            start: DateTime(2026, 11, 3),
          ),
          phase: HealthPhase.affected,
        ),
      ),
    );
    expect(find.text('You are logged as sick'), findsOneWidget);
    expect(find.text('Threshold run'), findsNothing);
    expect(find.byKey(const ValueKey('hero-tomorrow')), findsNothing);
    expect(find.byKey(const ValueKey('hero-primary-logFeel')), findsOneWidget);
  });

  testWidgets('tomorrow strip, ask the trainer', (t) async {
    await t.pumpWidget(
      hero(tomorrow: [_planned('5', 'Long ride', minutes: 180)]),
    );
    expect(find.text('Tomorrow: Long ride · 3h 00m · 78 TSS'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('hero-tomorrow')));
    await t.tap(find.byKey(const ValueKey('hero-ask-trainer')));
    expect(calls, ['tomorrow', 'ask']);
  });

  testWidgets('swipe right logs the feel, swipe left moves to tomorrow', (
    t,
  ) async {
    await t.pumpWidget(hero(plan: [_planned('11', 'Tempo ride')]));
    await t.drag(find.text('Tempo ride'), const Offset(600, 0));
    await t.pumpAndSettle();
    await t.drag(find.text('Tempo ride'), const Offset(-600, 0));
    await t.pumpAndSettle();
    expect(calls, ['feel', 'move:11']);
    // The session stays on the card: a move re-reads Today.
    expect(find.text('Tempo ride'), findsOneWidget);
  });

  testWidgets('the ⋯ menu has the gesture-free paths', (t) async {
    await t.pumpWidget(hero(plan: [_planned('12', 'Tempo ride')]));
    await t.tap(find.byKey(const ValueKey('hero-more')));
    await t.pumpAndSettle();
    for (final k in [
      'sync',
      'train',
      'feel',
      'move',
      'intervals',
      'customize',
    ]) {
      expect(find.byKey(ValueKey('hero-action-$k')), findsOneWidget, reason: k);
    }
    await t.tap(find.byKey(const ValueKey('hero-action-move')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const ValueKey('hero-more')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const ValueKey('hero-action-sync')));
    await t.pumpAndSettle();
    expect(calls, ['move:12', 'refresh']);

    await t.pumpWidget(hero(connected: false));
    await t.tap(find.byKey(const ValueKey('hero-more')));
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('hero-action-intervals')), findsNothing);
    expect(find.byKey(const ValueKey('hero-action-move')), findsNothing);
  });

  testWidgets('reads as one screen-reader summary', (t) async {
    final handle = t.ensureSemantics();
    await t.pumpWidget(
      hero(
        plan: [_planned('13', 'VO2 intervals')],
        tomorrow: [_planned('14', 'Long ride', minutes: 180)],
      ),
    );
    expect(
      find.bySemanticsLabel(
        RegExp(
          r'^Ready to train\. Today: VO2 intervals · 1h 05m · 78 TSS\. '
          r'Tomorrow: Long ride',
        ),
      ),
      findsOneWidget,
    );
    handle.dispose();
  });

  group('long press and taps on today\'s sessions', () {
    const overlay = ValueKey('hold-preview');

    testWidgets('a long press on the card opens no menu; ⋯ still does', (
      t,
    ) async {
      await t.pumpWidget(hero(plan: [_planned('20', 'Tempo ride')]));
      await t.longPress(find.byKey(const ValueKey('hero-ask-trainer')));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('hero-action-sync')), findsNothing);
      await t.longPressAt(
        t.getTopLeft(find.byKey(const ValueKey('today-hero'))) +
            const Offset(150, 6),
      );
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('hero-action-sync')), findsNothing);

      await t.tap(find.byKey(const ValueKey('hero-more')));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('hero-action-sync')), findsOneWidget);
    });

    testWidgets('holding a planned session\'s icon shows its details', (
      t,
    ) async {
      await t.pumpWidget(hero(plan: [_planned('21', 'Tempo ride')]));
      final icon = find.byKey(const ValueKey('hero-icon-21'));
      final g = await t.startGesture(t.getCenter(icon));
      await t.pump(const Duration(milliseconds: 700));
      expect(find.byKey(overlay), findsOneWidget);
      expect(find.byKey(const ValueKey('event-peek-21')), findsOneWidget);
      await g.up();
      await t.pumpAndSettle();
      expect(find.byKey(overlay), findsNothing);
      // The hold was not a tap: nothing opened.
      expect(calls, isEmpty);
    });

    testWidgets('a tap on a planned session still opens it', (t) async {
      await t.pumpWidget(hero(plan: [_planned('22', 'Tempo ride')]));
      await t.tap(find.text('Tempo ride'));
      await t.pumpAndSettle();
      expect(calls, ['open:22']);
    });

    testWidgets('tapping a completed session opens it', (t) async {
      await t.pumpWidget(hero(activities: [_done('a1')]));
      await t.tap(find.byKey(const ValueKey('hero-result-a1')));
      await t.pumpAndSettle();
      expect(calls, ['activity:a1']);
    });

    testWidgets('holding a completed session\'s icon shows its figures', (
      t,
    ) async {
      await t.pumpWidget(hero(activities: [_done('a2')]));
      final icon = find.byKey(const ValueKey('hero-result-icon-a2'));
      final g = await t.startGesture(t.getCenter(icon));
      await t.pump(const Duration(milliseconds: 700));
      expect(find.byKey(overlay), findsOneWidget);
      expect(find.byKey(const ValueKey('activity-peek-a2')), findsOneWidget);
      await g.up();
      await t.pumpAndSettle();
      expect(find.byKey(overlay), findsNothing);
      expect(calls, isEmpty);
    });
  });
}
