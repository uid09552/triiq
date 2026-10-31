import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/agent/plan_proposals.dart';
import 'package:triiq/agent/tools/training_data_tools.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/data/repositories/events_repository.dart';
import 'package:triiq/data/repositories/plans_repository.dart';
import 'package:triiq/data/repositories/sync_state_repository.dart';
import 'package:triiq/data/repositories/wellness_repository.dart';
import 'package:triiq/plan/knowledge.dart';
import 'package:triiq/plan/plan_engine.dart';
import 'package:triiq/plan/plan_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late AppDatabase database;
  late PlansRepository plans;
  late PlanProposals proposals;
  late TrainingDataTools tools;

  // Saturday: the default plan start is Monday 2026-11-02.
  final now = DateTime(2026, 10, 31, 9);

  const goal = Goal(
    targetType: 'long_distance',
    weekdays: {2, 4, 6},
    weeklyHours: 10,
    baselineWeeklyLoad: 300,
    weeks: 6,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    tempDir = await Directory.systemTemp.createTemp('triiq_plan_assistant');
    database = AppDatabase.atPath(p.join(tempDir.path, 'triiq.db'));
    plans = PlansRepository(database: database);
    proposals = PlanProposals(
      fingerprint: () => PlanProposals.defaultFingerprint(plans: plans),
    );
    tools = TrainingDataTools(
      wellnessRepository: WellnessRepository(database: database),
      activitiesRepository: ActivitiesRepository(database: database),
      eventsRepository: EventsRepository(database: database),
      plansRepository: plans,
      syncStateRepository: SyncStateRepository(database: database),
      clock: () => now,
      loadTrainingGuidance: () async => '# Doc\n\ntext',
      knowledgeRepository: KnowledgeRepository(
        loadAsset: () async => File('docs/okf.md').readAsStringSync(),
      ),
      proposals: proposals,
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

  Future<TrainingPlan> savePlan() async {
    final draft = PlanEngine(
      TrainingKnowledge.parse(File('docs/okf.md').readAsStringSync()),
    ).generate(
      goal: goal.copyWith(weeks: 2),
      startDate: DateTime(2026, 11, 2),
      recentWeeklyLoads: null,
      today: now,
    ).plan!;
    return plans.save(draft.copyWith(status: PlanStatus.active));
  }

  group('get_training_plan', () {
    test('no goal: says so', () async {
      final r = await call('get_training_plan');

      expect(r['goal'], isNull);
      expect(r['note'], contains('No goal'));
      expect(r['plan'], isNull);
    });

    test('goal without a plan: the load graph per week', () async {
      await GoalStore().save(goal);

      final r = await call('get_training_plan');
      final weeks = (r['load_graph']['weeks'] as List)
          .cast<Map<String, dynamic>>();

      expect(r['goal']['plan_weeks'], 6);
      expect(weeks, hasLength(6));
      expect(weeks.first['proposed_tss'], 330);
      expect(weeks.first['share_percent'], 100);
      expect(weeks.first['allowed_tss'], [265, 395]);
      expect(weeks.first['phase'], 'build');
      expect(r['plan'], isNull);
    });

    test('an active plan: weeks and sessions with ids', () async {
      await GoalStore().save(goal);
      final saved = await savePlan();

      final r = await call('get_training_plan');
      final week1 = (r['plan']['weeks'] as List).first as Map;
      final session = (week1['sessions'] as List).first as Map;

      expect(week1['planned_tss'], saved.weeks[0].plannedLoad);
      expect(session['session_id'], saved.weeks[0].sessions.first.id);
      expect(session['date'], startsWith('Tue 2026-11-03'));
      expect(session['sent_to_intervals'], isFalse);
    });
  });

  group('propose_load_curve', () {
    setUp(() => GoalStore().save(goal));

    test('a recovery week drops to the bottom of its band', () async {
      final r = await call('propose_load_curve', {
        'recovery_weeks': [4],
      });

      expect(r['error'], isNull);
      final week4 = (r['load_graph']['weeks'] as List)[3] as Map;
      expect(week4['target_tss'], (week4['allowed_tss'] as List).first);
      expect(week4['phase'], 'recovery');
      expect(week4['changed'], isTrue);
      expect(r['note'], contains('Not applied'));
      final p = proposals[r['proposal_id'] as String]! as CurveProposal;
      expect(p.changedWeeks, {3});
      expect(p.goal.loadFactors[3], lessThan(0.82));
      // Nothing saved.
      expect((await GoalStore().load())!.loadFactors, isEmpty);
    });

    test('TSS and percent are both accepted', () async {
      final r = await call('propose_load_curve', {
        'set_weeks': [
          {'week': 2, 'tss': 380},
          {'week': 3, 'percent': 105},
        ],
      });

      final weeks = (r['load_graph']['weeks'] as List).cast<Map>();
      expect(weeks[1]['target_tss'], 380);
      expect(weeks[2]['target_tss'], 420, reason: '399.3 x 1.05, on 5 TSS');
    });

    test('outside the band is an error naming the range', () async {
      final percent = await call('propose_load_curve', {
        'set_weeks': [
          {'week': 2, 'percent': 140},
        ],
      });
      final tss = await call('propose_load_curve', {
        'set_weeks': [
          {'week': 2, 'tss': 900},
        ],
      });

      expect(percent['error'], contains('295-435 TSS'));
      expect(tss['error'], contains('outside'));
      expect(percent['proposal_id'], isNull);
    });

    test('plan length and sport mix; bad length errors', () async {
      final ok = await call('propose_load_curve', {
        'weeks': 8,
        'sport_mix': {'Swim': 20, 'Ride': 45, 'Run': 35},
      });
      final bad = await call('propose_load_curve', {'weeks': 30});

      expect((ok['load_graph']['weeks'] as List), hasLength(8));
      final p = proposals[ok['proposal_id'] as String]! as CurveProposal;
      expect(p.goal.sport, Goal.triathlon);
      expect(p.goal.sportMix['Swim'], 20);
      expect(bad['error'], contains('2 to 16'));
    });
  });

  group('generate_training_plan', () {
    test('registers a plan proposal and keeps its output', () async {
      await GoalStore().save(goal);

      final r = await call('generate_training_plan');

      expect(r['proposal_id'], isA<String>());
      expect(r['weeks'], hasLength(6));
      final p = proposals[r['proposal_id'] as String];
      expect(p, isA<PlanDraftProposal>());
      expect(p!.summary, contains('6-week'));
    });
  });

  group('propose_session_change', () {
    test('a move inside the plan becomes a proposal', () async {
      await GoalStore().save(goal);
      final saved = await savePlan();
      final s = saved.weeks[0].sessions.first;

      final r = await call('propose_session_change', {
        'session_id': s.id,
        'action': 'move',
        'date': '2026-11-05',
      });

      expect(r['error'], isNull);
      expect(r['summary'], contains('to Thu 2026-11-05'));
      final p = proposals[r['proposal_id'] as String]! as SessionChangeProposal;
      expect(p.to, DateTime(2026, 11, 5));
      expect(p.isRemoval, isFalse);
    });

    test('remove is a proposal too', () async {
      final saved = await savePlan();
      final s = saved.weeks[1].sessions.last;

      final r = await call('propose_session_change', {
        'session_id': s.id,
        'action': 'remove',
      });

      final p = proposals[r['proposal_id'] as String]! as SessionChangeProposal;
      expect(p.isRemoval, isTrue);
    });

    test('unknown id, past date and outside the plan are errors', () async {
      final saved = await savePlan();
      final s = saved.weeks[0].sessions.first;

      final unknown = await call('propose_session_change', {
        'session_id': 9999,
        'action': 'remove',
      });
      final past = await call('propose_session_change', {
        'session_id': s.id,
        'action': 'move',
        'date': '2026-10-30',
      });
      final outside = await call('propose_session_change', {
        'session_id': s.id,
        'action': 'move',
        'date': '2026-12-20',
      });

      expect(unknown['error'], contains('no session 9999'));
      expect(past['error'], contains('past'));
      expect(outside['error'], contains('outside the plan'));
    });
  });

  group('progression settings', () {
    setUp(() => GoalStore().save(goal));

    test('get_training_plan reports ramp, hold, mix and preferences', () async {
      await GoalStore().save(
        goal.copyWith(longDays: {'Run': 6}, intervalDays: {2}),
      );

      final r = await call('get_training_plan');

      expect(r['load_graph']['max_weekly_increase_percent'], 10);
      expect(r['load_graph']['hold_every_4th'], isTrue);
      expect(r['goal']['session_mix_percent'], 'goal type default');
      expect(r['goal']['preferences']['long_session_days'], {'Run': 'Sat'});
      expect(r['goal']['preferences']['interval_days'], ['Tue']);
      expect(r['goal']['preferences']['max_sessions_per_day'], 1);
    });

    test('a 6% ramp is proposed, not saved', () async {
      final r = await call('propose_load_curve', {'ramp_percent': 6});

      expect(r['error'], isNull);
      final weeks = (r['load_graph']['weeks'] as List).cast<Map>();
      expect(weeks[0]['proposed_tss'], 318);
      expect(weeks[3]['proposed_tss'], weeks[2]['proposed_tss'], reason: 'hold');
      expect(r['load_graph']['max_weekly_increase_percent'], 6);
      final p = proposals[r['proposal_id'] as String]! as CurveProposal;
      expect(p.goal.maxWeeklyIncrease, closeTo(0.06, 1e-9));
      expect((await GoalStore().load())!.maxWeeklyIncrease, isNull);
    });

    test('hold off is accepted; 20% or a string is an error', () async {
      final off = await call('propose_load_curve', {'hold_every_4th': false});
      final weeks = (off['load_graph']['weeks'] as List).cast<Map>();
      expect(weeks[3]['proposed_tss'], greaterThan(weeks[2]['proposed_tss']));

      final big = await call('propose_load_curve', {'ramp_percent': 20});
      final bad = await call('propose_load_curve', {'hold_every_4th': 'yes'});
      expect(big['error'], contains('0 to 15'));
      expect(bad['error'], contains('true or false'));
    });
  });
}
