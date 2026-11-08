import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/data/models/local_wellness.dart';
import 'package:triiq/data/repositories/wellness_repository.dart';
import 'package:triiq/evaluation/session_streams.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/plan/plan_models.dart';
import 'package:triiq/screens/activities/brick_card.dart';
import 'package:triiq/screens/season/health_card.dart';
import 'package:triiq/screens/season/race_predictor_screen.dart';
import 'package:triiq/screens/season/season_screen.dart';
import 'package:triiq/season/brick_analysis.dart';
import 'package:triiq/season/health_actions.dart';
import 'package:triiq/season/illness_mode.dart';
import 'package:triiq/season/race_predictor.dart';
import 'package:triiq/season/season_service.dart';
import 'package:triiq/season/season_timeline.dart';

Widget wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);

LocalEvent ev(
  String id,
  String date, {
  String category = 'WORKOUT',
  String type = 'Run',
  int minutes = 60,
  int load = 50,
  String? end,
  String? name,
}) => LocalEvent(
  id: id,
  date: date,
  category: category,
  type: type,
  name: name ?? id,
  description: null,
  plannedLoad: load,
  plannedTime: minutes * 60,
  plannedDistance: null,
  indoor: false,
  raw: {if (end != null) 'end_date_local': end},
  syncedAt: DateTime(2026),
);

class _FakeWellness implements WellnessRepository {
  @override
  Future<List<LocalWellness>> getRange(String oldest, String newest) async => [
    LocalWellness(
      date: '2026-05-09',
      ctl: 60,
      atl: 70,
      ctlLoad: null,
      atlLoad: null,
      rampRate: null,
      raw: const {},
      syncedAt: DateTime(2026),
    ),
  ];

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _NoGoal extends GoalStore {
  @override
  Future<Goal?> load() async => null;
}

class _Recorder implements HealthActions {
  final applied = <ReturnChange>[];

  @override
  Future<void> apply(ReturnChange change) async => applied.add(change);

  @override
  Future<({int done, Object? error})> applyAll(
    Iterable<ReturnChange> changes,
  ) async {
    applied.addAll(changes);
    return (done: changes.length, error: null);
  }
}

void tall(WidgetTester t) {
  t.view.physicalSize = const Size(900, 3200);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}

void main() {
  final now = DateTime(2026, 5, 10, 9);

  SeasonService service(List<LocalEvent> events) => SeasonService(
    planned: (a, b) async => events,
    wellness: _FakeWellness(),
    goals: _NoGoal(),
    clock: () => now,
  );

  group('SeasonScreen', () {
    testWidgets('shows form on race day, timeline and a conflict', (t) async {
      tall(t);
      final events = [
        ev('w1', '2026-05-12', load: 80),
        ev('a1', '2026-07-05', category: 'RACE_A', name: 'Ironman'),
        ev('a2', '2026-08-01', category: 'RACE_A', name: 'Marathon'),
      ];
      await t.pumpWidget(wrap(SeasonScreen(service: service(events))));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('race-form-Ironman')), findsOneWidget);
      expect(find.byKey(const ValueKey('race-form-Marathon')), findsOneWidget);
      expect(find.byKey(const ValueKey('season-bar')), findsOneWidget);
      expect(find.byKey(const ValueKey('season-conflict')), findsOneWidget);
      expect(find.textContaining('Peaking twice'), findsOneWidget);
    });

    testWidgets('no races: explains where to add one', (t) async {
      tall(t);
      await t.pumpWidget(wrap(SeasonScreen(service: service(const []))));
      await t.pumpAndSettle();
      expect(find.textContaining('No races yet'), findsOneWidget);
    });
  });

  group('HealthCard', () {
    testWidgets('sick: lists the sessions and applies after confirming', (
      t,
    ) async {
      final events = [
        ev('s', '2026-05-08', category: 'SICK'),
        ev('w1', '2026-05-11', load: 80),
        ev('w2', '2026-05-12', load: 60),
      ];
      final snap = await service(events).load(horizonDays: 30);
      expect(snap.health!.issue.kind, HealthKind.sick);
      expect(snap.healthChanges, hasLength(2));
      final rec = _Recorder();
      await t.pumpWidget(
        wrap(
          Scaffold(
            body: HealthCard(
              status: snap.health,
              changes: snap.healthChanges,
              today: snap.today,
              actions: rec,
            ),
          ),
        ),
      );
      expect(find.text('You are logged as sick'), findsOneWidget);
      expect(find.text('Apply 2 changes'), findsOneWidget);
      await t.tap(find.byKey(const ValueKey('health-apply')));
      await t.pumpAndSettle();
      expect(rec.applied, isEmpty); // not before confirming
      await t.tap(find.byKey(const ValueKey('health-confirm')));
      await t.pumpAndSettle();
      expect(rec.applied, hasLength(2));
      expect(find.text('2 sessions updated.'), findsOneWidget);
    });

    testWidgets('nothing logged: offers to log it, shows no card', (t) async {
      await t.pumpWidget(
        wrap(
          Scaffold(
            body: HealthCard(
              status: null,
              changes: const [],
              today: now,
              showLogButton: true,
            ),
          ),
        ),
      );
      expect(find.byKey(const ValueKey('health-log')), findsOneWidget);
      expect(find.byKey(const ValueKey('health-card')), findsNothing);
    });
  });

  group('RacePredictorScreen', () {
    const runBests = [(metres: 5000.0, seconds: 1200.0)];
    testWidgets('shows total, pacing and fuelling', (t) async {
      tall(t);
      await t.pumpWidget(
        wrap(
          RacePredictorScreen(
            initial: RaceSpec.halfMarathon,
            inputs: ({raceDay, hot = false}) async =>
                const RaceInputs(runBests: runBests, ctl: 80),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('race-total')), findsOneWidget);
      expect(find.text('Pacing plan'), findsOneWidget);
      expect(find.text('Fuelling plan'), findsOneWidget);
      expect(find.byKey(const ValueKey('fuel-carbs')), findsOneWidget);
    });

    testWidgets('missing curves are named, not guessed', (t) async {
      await t.pumpWidget(
        wrap(
          RacePredictorScreen(
            initial: RaceSpec.olympic,
            inputs: ({raceDay, hot = false}) async =>
                const RaceInputs(runBests: runBests),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('race-missing')), findsOneWidget);
      expect(find.textContaining('Swim, Ride'), findsOneWidget);
    });
  });

  group('BrickCard', () {
    LocalActivity act(String id, String type, String start, int secs) =>
        LocalActivity(
          id: id,
          date: '2026-05-10',
          type: type,
          name: id,
          movingTime: secs,
          distance: null,
          trainingLoad: null,
          raw: {'start_date_local': start, 'elapsed_time': secs},
          syncedAt: DateTime(2026),
        );

    testWidgets('renders the verdict for a brick', (t) async {
      final bike = act('b', 'Ride', '2026-05-10T08:00:00', 3600);
      final run = act('r', 'Run', '2026-05-10T09:04:00', 1800);
      final brick = findBricks([bike, run]).single;
      final loader = _FakeBrickLoader(analyseBrick(brick, null));
      await t.pumpWidget(
        wrap(
          Scaffold(
            body: BrickCard(activity: run, loader: loader),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(find.text('Brick: bike → run'), findsOneWidget);
      expect(find.text('Transition only'), findsOneWidget);
      expect(find.textContaining('Transition: 4:00'), findsOneWidget);
    });

    testWidgets('no brick: nothing is drawn', (t) async {
      final run = act('r', 'Run', '2026-05-10T09:04:00', 1800);
      await t.pumpWidget(
        wrap(
          Scaffold(
            body: BrickCard(activity: run, loader: _FakeBrickLoader(null)),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('brick-card')), findsNothing);
    });
  });
}

class _FakeBrickLoader implements BrickLoader {
  _FakeBrickLoader(this.result);

  final BrickAnalysis? result;

  @override
  Future<BrickAnalysis?> load(LocalActivity activity) async => result;

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}
