import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/home_widget_data.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/data/models/local_wellness.dart';

LocalEvent ev(String name, {int? load, int? secs, String category = 'WORKOUT'}) =>
    LocalEvent(
      id: name, date: '2026-05-10', category: category, type: 'Run', name: name,
      description: null, plannedLoad: load, plannedTime: secs,
      plannedDistance: null, indoor: false, raw: const {}, syncedAt: DateTime(2026),
    );

LocalWellness well(double ctl, double atl) => LocalWellness(
  date: '2026-05-10', ctl: ctl, atl: atl, ctlLoad: null, atlLoad: null,
  rampRate: null, raw: const {}, syncedAt: DateTime(2026),
);

void main() {
  final now = DateTime(2026, 5, 10, 7, 5);

  test('lists two sessions, counts the rest, shows form', () {
    final d = buildHomeWidgetData(
      planned: [
        ev('Easy run', load: 40, secs: 2700),
        ev('Strength', secs: 1800),
        ev('Swim', load: 30),
        ev('Note', category: 'NOTE'),
      ],
      done: const [],
      latest: well(62.4, 70.2),
      now: now,
    );
    final e = d.toEntries();
    expect(e['w_session1'], 'Easy run · 45 min · 40 TSS');
    expect(e['w_session2'], 'Strength · 30 min');
    expect(e['w_extra'], '+1');
    expect(e['w_form'], '-8');
    expect(e['w_fitness'], 'CTL 62 · ATL 70');
    expect(e['w_updated'], '07:05');
    expect(e['w_done'], '');
  });

  test('nothing planned or no fitness leaves the entries empty', () {
    final e = buildHomeWidgetData(
      planned: const [], done: const [], latest: null, now: now,
    ).toEntries();
    expect(e['w_session1'], '');
    expect(e['w_form'], '');
    expect(e['w_fitness'], '');
  });

  test('completed load is shown', () {
    final a = LocalActivity(
      id: 'a', date: '2026-05-10', type: 'Run', name: 'x', movingTime: 1,
      distance: null, trainingLoad: 55, raw: const {}, syncedAt: DateTime(2026),
    );
    final e = buildHomeWidgetData(
      planned: const [], done: [a, a], latest: well(50, 40), now: now,
    ).toEntries();
    expect(e['w_done'], '110 TSS');
    expect(e['w_form'], '+10');
  });

  group('weekly target rings', () {
    LocalActivity act(String type, int secs) => LocalActivity(
      id: type + secs.toString(), date: '2026-05-10', type: type, name: 'x',
      movingTime: secs, distance: null, trainingLoad: null, raw: const {},
      syncedAt: DateTime(2026),
    );

    test('only sports with a target, with percent and hours', () {
      final rings = buildWidgetRings(
        {'swim': null, 'cycle': 6.0, 'run': 4.0},
        [
          act('Ride', 3 * 3600),
          act('VirtualRide', 1800),
          act('Run', 5400),
          act('Hike', 7200), // not a target sport
        ],
      );
      expect(rings.map((r) => r.sport), ['cycle', 'run']);
      expect(rings[0].percent, 58); // 3.5 / 6
      final e = buildHomeWidgetData(
        planned: const [], done: const [], latest: null, now: now, rings: rings,
      ).toEntries();
      expect(e['w_swim_pct'], '');
      expect(e['w_cycle_pct'], '58');
      expect(e['w_cycle_val'], '3.5 / 6.0 h');
      expect(e['w_run_pct'], '38');
      expect(e['w_run_val'], '1.5 / 4.0 h');
    });

    test('over target is not capped in the data (the ring caps itself)', () {
      final r = buildWidgetRings({'run': 2.0}, [act('Run', 3 * 3600)]);
      expect(r.single.percent, 150);
    });

    test('no targets at all gives no rings', () {
      expect(buildWidgetRings({'swim': null, 'cycle': 0.0, 'run': null}, const []), isEmpty);
    });
  });
}
