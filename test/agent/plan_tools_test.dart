import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/agent/tools/training_data_tools.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/data/repositories/sync_state_repository.dart';
import 'package:triiq/data/repositories/wellness_repository.dart';
import 'package:triiq/plan/knowledge.dart';
import 'package:triiq/plan/plan_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late AppDatabase database;
  late ActivitiesRepository activities;
  late SyncStateRepository syncState;
  late TrainingDataTools tools;

  // Wednesday: the default plan start is the following Monday, 2026-08-31.
  final now = DateTime(2026, 8, 26, 9);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    tempDir = await Directory.systemTemp.createTemp('triiq_plan_tools');
    database = AppDatabase.atPath(p.join(tempDir.path, 'triiq.db'));
    activities = ActivitiesRepository(database: database);
    syncState = SyncStateRepository(database: database);
    tools = TrainingDataTools(
      wellnessRepository: WellnessRepository(database: database),
      activitiesRepository: activities,
      syncStateRepository: syncState,
      clock: () => now,
      loadTrainingGuidance: () async => '# Doc\n\ntext',
      knowledgeRepository: KnowledgeRepository(
        loadAsset: () async => File('docs/okf.md').readAsStringSync(),
      ),
    );
  });

  tearDown(() async {
    await database.close();
    await tempDir.delete(recursive: true);
  });

  Future<Map<String, dynamic>> call(
    String name, [
    Map<String, dynamic> args = const {},
  ]) async {
    final tool = tools.build().firstWhere((t) => t.name == name);
    final output = await tool.invoke(tool.getInputFromJson(args));
    return jsonDecode(output as String) as Map<String, dynamic>;
  }

  Future<void> cacheFourWeeks() async {
    // One 300-TSS activity in each of the four weeks before 2026-08-31.
    await activities.upsertAll([
      for (var i = 0; i < 4; i++)
        LocalActivity(
          id: 'a$i',
          date: '2026-08-${(3 + 7 * i).toString().padLeft(2, '0')}',
          type: 'Run',
          name: 'Run $i',
          movingTime: 3600,
          distance: 10000,
          trainingLoad: 300,
          raw: const {},
          syncedAt: DateTime(2026, 8, 26),
        ),
    ]);
    await syncState.recordSync(
      'activities',
      oldest: '2026-08-01',
      newest: '2026-08-26',
    );
  }

  const args = {
    'goal_type': 'long_distance',
    'weekdays': [1, 2, 4, 6],
    'weekly_hours': 12,
    'sport': 'Run',
  };

  test('generate_training_plan returns engine numbers per week', () async {
    await cacheFourWeeks();

    final result = await call('generate_training_plan', args);

    expect(result['error'], isNull);
    expect(result['start_date'], '2026-08-31');
    expect(result['baseline_weekly_load'], 300);
    final weeks = (result['weeks'] as List).cast<Map<String, dynamic>>();
    expect(weeks, hasLength(8));
    expect(weeks.every((w) => w['phase'] == 'build'), isTrue);
    expect(weeks[0]['proposed_load'], 330);
    expect(weeks[0]['load_factor'], 1.0);
    expect((weeks[0]['sessions'] as List), hasLength(4));
    expect(weeks[0]['outside_80_20'], isFalse);
  });

  test('weeks, load factors and a triathlon mix pass through', () async {
    await cacheFourWeeks();

    final result = await call('generate_training_plan', {
      ...args,
      'sport': 'Triathlon',
      'weekdays': [1, 2, 3, 4, 5, 6],
      'weeks': 4,
      'load_factors': [1, 1, 1.2, 0.8],
      'sport_mix': {'Swim': 20, 'Ride': 45, 'Run': 35},
    });

    expect(result['error'], isNull);
    expect(result['sport_mix'], {'Swim': 20, 'Ride': 45, 'Run': 35});
    final weeks = (result['weeks'] as List).cast<Map<String, dynamic>>();
    expect(weeks, hasLength(4));
    expect(weeks[2]['above_limits'], contains('weeklyIncrease'));
    expect(weeks[3]['phase'], 'recovery');
    expect(
      (weeks[0]['planned_load_by_sport'] as Map).keys,
      containsAll(['Swim', 'Ride', 'Run']),
    );
    final sports = {
      for (final s in weeks[0]['sessions'] as List) (s as Map)['sport'],
    };
    expect(sports, {'Swim', 'Ride', 'Run'});
  });

  test('bad curve arguments come back as error strings', () async {
    await cacheFourWeeks();
    Future<Object?> error(Map<String, Object?> extra) async =>
        (await call('generate_training_plan', {...args, ...extra}))['error'];

    expect(await error({'weeks': 'eight'}), contains('weeks'));
    expect(await error({'weeks': 30}), contains('2 to 16'));
    expect(
      await error({
        'load_factors': [1.5],
      }),
      contains('80%'),
    );
    expect(await error({'load_factors': 'flat'}), contains('load_factors'));
    expect(
      await error({
        'sport': 'Triathlon',
        'sport_mix': {'Swim': 50, 'Ride': 50, 'Run': 50},
      }),
      contains('150%'),
    );
    expect(
      await error({
        'sport_mix': {'Bike': 100},
      }),
      contains('sport_mix'),
    );
  });

  test('without enough cached history it asks for a baseline', () async {
    final result = await call('generate_training_plan', args);

    expect(result['reason'], 'needsBaseline');
    expect(result['error'], contains('weekly load'));
  });

  test('a baseline from the model replaces missing history', () async {
    final result = await call('generate_training_plan', {
      ...args,
      'baseline_weekly_load': 250,
    });

    expect(result['error'], isNull);
    expect(result['baseline_weekly_load'], 250);
  });

  test('with no arguments and no saved goal it says what is missing', () async {
    final result = await call('generate_training_plan');

    expect(result['error'], contains('goal_type'));
    expect(result['known_goals'], contains('long_distance'));
  });

  test('falls back to the saved goal', () async {
    await cacheFourWeeks();
    await GoalStore().save(
      const Goal(
        targetType: 'short_event',
        weekdays: {2, 4, 6},
        weeklyHours: 8,
      ),
    );

    final result = await call('generate_training_plan');

    expect(result['goal_type'], 'short_event');
    final first = (result['weeks'] as List).first as Map<String, dynamic>;
    expect(first['sessions'], hasLength(3));
  });

  test(
    'bad arguments come back as an error string, not an exception',
    () async {
      final result = await call('generate_training_plan', {
        ...args,
        'weekdays': [2, 6],
      });

      expect(result['reason'], 'invalidGoal');
    },
  );

  test('get_session_template explains one session', () async {
    final result = await call('get_session_template', {
      'goal_type': 'long_distance',
      'slot': 'intervals',
      'phase': 'peak',
    });

    expect(result['id'], 'long_distance.intervals.peak');
    expect(result['structure'], isNotEmpty);
    expect((result['rules'] as Map)['low_intensity_target'], 0.8);
  });

  test('get_session_template lists options with no arguments', () async {
    final result = await call('get_session_template');

    expect(result['goals'], containsAll(['long_distance', 'short_event']));
    expect(result['phases'], contains('recovery'));
  });

  test('get_session_template reports a missing template by name', () async {
    final result = await call('get_session_template', {
      'goal_type': 'triathlon',
      'slot': 'long',
      'phase': 'peak',
    });

    expect(result['error'], allOf(contains('triathlon'), contains('peak')));
  });
}
