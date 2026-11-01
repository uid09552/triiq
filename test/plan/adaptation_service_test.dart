import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/agent/plan_proposals.dart';
import 'package:triiq/agent/system_prompt.dart';
import 'package:triiq/agent/tools/training_data_tools.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/data/repositories/events_repository.dart';
import 'package:triiq/data/repositories/sync_state_repository.dart';
import 'package:triiq/data/repositories/plans_repository.dart';
import 'package:triiq/data/repositories/wellness_repository.dart';
import 'package:triiq/evaluation/readiness_service.dart';
import 'package:triiq/plan/adaptation_service.dart';
import 'package:triiq/plan/knowledge.dart';
import 'package:triiq/plan/plan_adaptation.dart';
import 'package:triiq/plan/plan_engine.dart';
import 'package:triiq/plan/plan_models.dart';
import 'package:triiq/plan/plan_service.dart';
import 'package:triiq/util/dates.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late AppDatabase database;
  late PlansRepository plans;
  late ActivitiesRepository activities;
  late TrainingPlan saved;

  /// Wednesday of the plan's first week: Tuesday's session is in the past.
  final now = DateTime(2026, 11, 4, 8);
  const goal = Goal(
    targetType: 'long_distance',
    weekdays: {2, 4, 6},
    weeklyHours: 6,
    baselineWeeklyLoad: 250,
    weeks: 2,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dir = await Directory.systemTemp.createTemp('triiq_adaptation');
    database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));
    plans = PlansRepository(database: database);
    activities = ActivitiesRepository(database: database);
    await GoalStore().save(goal);
    final draft =
        PlanEngine(
              TrainingKnowledge.parse(File('docs/okf.md').readAsStringSync()),
            )
            .generate(
              goal: goal,
              startDate: DateTime(2026, 11, 2),
              recentWeeklyLoads: null,
              today: DateTime(2026, 10, 31),
            )
            .plan!;
    saved = await plans.save(draft.copyWith(status: PlanStatus.active));
  });

  tearDown(() async {
    await database.close();
    await dir.delete(recursive: true);
  });

  AdaptationService service(PlanProposals proposals) => AdaptationService(
    plans: plans,
    goals: GoalStore(),
    activities: activities,
    readiness: ReadinessService(
      wellness: WellnessRepository(database: database),
      clock: () => now,
    ),
    planService: PlanService(plans: plans, activities: activities),
    proposals: proposals,
    clock: () => now,
  );

  PlanProposals freshProposals() =>
      PlanProposals(fingerprint: () async => 'v1');

  PlanSession tuesday() =>
      saved.sessions.firstWhere((s) => s.date == DateTime(2026, 11, 3));

  test('a missed session becomes one keyed proposal', () async {
    final proposals = freshProposals();

    final result = await service(proposals).refresh();

    expect(result, hasLength(1));
    final p = result.single as SessionChangeProposal;
    expect(p.sessionId, tuesday().id);
    expect(p.missed, isTrue);
    expect(p.adaptation, isA<MissedSession>());
    // Running again returns the same proposal, not a second card.
    final again = await service(proposals).refresh();
    expect(identical(again.single, p), isTrue);
  });

  test('a late-synced activity removes the suggestion', () async {
    final proposals = freshProposals();
    final first = (await service(proposals).refresh()).single;

    await activities.upsertAll([
      LocalActivity(
        id: 'late',
        date: isoDate(tuesday().date),
        type: tuesday().sport,
        name: 'Late upload',
        movingTime: 3600,
        distance: null,
        trainingLoad: 60,
        raw: const {},
        syncedAt: now,
      ),
    ]);
    final second = await service(proposals).refresh();

    expect(second, isEmpty);
    expect(first.canApply, isFalse);
  });

  test('a dismissal survives a restart', () async {
    final before = freshProposals();
    final p = (await service(before).refresh()).single;
    before.dismiss(p.id);
    // Let the shared-preferences write land.
    await Future<void>.delayed(Duration.zero);

    final afterRestart = freshProposals();
    expect(await service(afterRestart).refresh(), isEmpty);
    expect(
      await DismissedAdaptations().load(),
      contains('missed:${tuesday().id}'),
    );
  });

  test('no active plan: nothing, and old cards retire', () async {
    final proposals = freshProposals();
    final p = (await service(proposals).refresh()).single;
    await plans.setStatus(saved.id!, PlanStatus.removed);

    expect(await service(proposals).refresh(), isEmpty);
    expect(p.canApply, isFalse);
  });

  test('get_plan_adjustments offers the same proposals Today shows', () async {
    final proposals = freshProposals();
    final today = await service(proposals).refresh();
    final tools = TrainingDataTools(
      wellnessRepository: WellnessRepository(database: database),
      activitiesRepository: activities,
      eventsRepository: EventsRepository(database: database),
      plansRepository: plans,
      syncStateRepository: SyncStateRepository(database: database),
      goalStore: GoalStore(),
      proposals: proposals,
      clock: () => now,
    );
    final tool = tools.build().firstWhere(
      (t) => t.name == 'get_plan_adjustments',
    );

    final out =
        jsonDecode(await tool.invoke(tool.getInputFromJson(const {})) as String)
            as Map<String, dynamic>;

    expect(out['proposal_ids'], [today.single.id]);
    expect((out['adjustments'] as List).single['kind'], 'missed');
    expect(today.single.state, ProposalState.pending);
    expect(trainingAgentSystemPrompt, contains('get_plan_adjustments'));
    // Reading only: no tool the agent has applies a proposal.
    expect(
      tools.build().map((t) => t.name).where((n) => n.contains('apply')),
      isEmpty,
    );
  });
}
