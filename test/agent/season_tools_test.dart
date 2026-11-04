import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/agent/tools/season_tools.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/data/models/local_wellness.dart';
import 'package:triiq/data/repositories/wellness_repository.dart';
import 'package:triiq/plan/plan_models.dart';
import 'package:triiq/season/race_predictor.dart';
import 'package:triiq/season/season_service.dart';

class _Wellness implements WellnessRepository {
  @override
  Future<List<LocalWellness>> getRange(String a, String b) async => [
    LocalWellness(
      date: '2026-05-09', ctl: 60, atl: 70, ctlLoad: null, atlLoad: null,
      rampRate: null, raw: const {}, syncedAt: DateTime(2026),
    ),
  ];

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _NoGoal extends GoalStore {
  @override
  Future<Goal?> load() async => null;
}

LocalEvent ev(String id, String date, String category,
        {String? end, int load = 60}) =>
    LocalEvent(
      id: id, date: date, category: category, type: 'Run', name: id,
      description: null, plannedLoad: load, plannedTime: 3600,
      plannedDistance: null, indoor: false,
      raw: {if (end != null) 'end_date_local': end}, syncedAt: DateTime(2026),
    );

void main() {
  late List<LocalEvent> events;
  late SeasonService service;

  setUp(() {
    events = [];
    service = SeasonService(
      planned: (a, b) async => events,
      wellness: _Wellness(),
      goals: _NoGoal(),
      clock: () => DateTime(2026, 5, 10),
    );
  });

  test('forecast tool reports form on the race day', () async {
    events = [ev('r', '2026-06-14', 'RACE_A')];
    final out = await SeasonTools(season: service).fitnessForecast();
    final race = (out['races'] as List).single as Map;
    expect(race['name'], 'r');
    expect(race['forecast_form'], isA<double>());
    expect(race['weeks_to_go'], 5);
    expect(out['weekly'], isNotEmpty);
    // Nothing planned after the race: fitness is held, not decayed to 0.
    final last = (out['weekly'] as List).last as Map;
    expect(last['ctl'], greaterThan(45));
    expect(out['assumed_from'], isNotNull);
    expect((out['blocks'] as List).map((b) => (b as Map)['kind']),
        contains('taper'));
  });

  test('health tool lists proposals and says it cannot apply', () async {
    events = [
      ev('s', '2026-05-08', 'SICK'),
      ev('w', '2026-05-11', 'WORKOUT'),
    ];
    final out = await SeasonTools(season: service).healthStatus();
    expect(out['status'], 'affected');
    expect((out['proposed_changes'] as List).single['action'], 'rest');
    expect(out['note'], contains('cannot apply'));
    events = [];
    expect((await SeasonTools(season: service).healthStatus())['status'], 'healthy');
  });

  test('race tool rejects an unknown race and names ids', () async {
    final out = await SeasonTools(season: service).racePrediction({'race': 'x'});
    expect(out['error'], contains('half70'));
  });

  test('race tool predicts from injected inputs', () async {
    final loader = _Loader();
    final out = await SeasonTools(season: service, raceInputs: loader)
        .racePrediction({'race': 'run10k'});
    expect(out['complete'], isTrue);
    expect(out['total_seconds'], closeTo(2500, 5));
  });
}

class _Loader implements RaceInputsLoader {
  @override
  Future<RaceInputs> load({DateTime? raceDay, bool hot = false}) async =>
      const RaceInputs(runBests: [(metres: 10000.0, seconds: 2500.0)], ctl: 60);

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}
