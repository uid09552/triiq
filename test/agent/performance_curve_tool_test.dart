import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/agent/tools/training_data_tools.dart';
import 'package:triiq/evaluation/performance_curves.dart';

class _FakeCurves implements PerformanceCurvesRepository {
  _FakeCurves(this.json);

  final Map<String, dynamic> json;
  bool fail = false;
  bool hasCache = true;
  int loads = 0;

  @override
  Future<PerformanceCurves?> cached(
    CurveSport sport,
    CurveMetric metric,
  ) async => hasCache ? PerformanceCurves.fromJson(sport, metric, json) : null;

  @override
  Future<bool> isStale(CurveSport sport, CurveMetric metric) async => false;

  @override
  Future<PerformanceCurves> load(
    CurveSport sport,
    CurveMetric metric, {
    bool force = false,
  }) async {
    loads++;
    if (fail) throw Exception('offline');
    return PerformanceCurves.fromJson(sport, metric, json);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final ride = {
    'list': [
      {
        'id': 's0',
        'secs': [5, 300, 1200],
        'values': [880, 312, 268],
        'activity_id': ['i1', 'i3', 'i3'],
        'powerModels': [
          {'ftp': 262},
        ],
      },
      {
        'id': 's1',
        'secs': [5, 300, 1200],
        'values': [905, 298, 259],
      },
    ],
    'activities': {
      'i3': {
        'id': 'i3',
        'start_date_local': '2026-10-12T07:00:00',
        'name': 'VO2',
      },
    },
  };

  Future<Map<String, dynamic>> call(
    TrainingDataTools tools,
    Map<String, dynamic> args,
  ) async {
    final tool = tools.build().firstWhere(
      (t) => t.name == 'get_performance_curve',
    );
    final output = await tool.invoke(tool.getInputFromJson(args));
    return jsonDecode(output as String) as Map<String, dynamic>;
  }

  test('returns key points per period with the source session', () async {
    final tools = TrainingDataTools(performanceCurves: _FakeCurves(ride));
    final result = await call(tools, {'sport': 'Ride', 'metric': 'power'});

    expect(result['unit'], 'W');
    final periods = result['periods'] as List;
    expect(periods.map((p) => p['period']), ['s0', 's1']);
    final s0 = periods.first as Map<String, dynamic>;
    final fiveMin = (s0['key_points'] as List).firstWhere(
      (k) => k['duration_s'] == 300,
    );
    expect(fiveMin['value'], 312);
    expect(fiveMin['activity_id'], 'i3');
    expect(fiveMin['date'], '2026-10-12');
    expect((s0['model'] as Map)['ftp'], 262);
  });

  test('pace points carry time and formatted pace', () async {
    final tools = TrainingDataTools(
      performanceCurves: _FakeCurves({
        'list': [
          {
            'id': 's0',
            'distance': [1000, 5000],
            'values': [210, 1150],
          },
        ],
      }),
    );
    final result = await call(tools, {'sport': 'Run', 'metric': 'pace'});
    final point =
        ((result['periods'] as List).first['key_points'] as List).first
            as Map<String, dynamic>;
    expect(point['distance_m'], 1000);
    expect(point['time_s'], 210);
    expect(point['pace'], '3:30');
  });

  test('falls back to the cache when a fetch fails', () async {
    final repo = _FakeCurves(ride)..fail = true;
    final result = await call(TrainingDataTools(performanceCurves: repo), {
      'sport': 'Ride',
      'metric': 'power',
    });
    expect(result['note'], contains('cached'));
    expect(result['periods'], isNotEmpty);

    repo.hasCache = false;
    final none = await call(TrainingDataTools(performanceCurves: repo), {
      'sport': 'Ride',
      'metric': 'power',
    });
    expect(none['error'], contains('Could not fetch'));
  });

  test('rejects unknown sport or metric', () async {
    final result = await call(
      TrainingDataTools(performanceCurves: _FakeCurves(ride)),
      {'sport': 'Rowing', 'metric': 'power'},
    );
    expect(result['error'], isNotNull);
  });
}
