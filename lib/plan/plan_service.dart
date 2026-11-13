import '../data/pending_writes.dart';
import '../data/repositories/activities_repository.dart';
import '../data/repositories/plans_repository.dart';
import '../evaluation/session_evaluator.dart';
import '../util/dates.dart';
import 'knowledge.dart';
import 'load_curve.dart';
import 'plan_engine.dart';
import 'plan_inputs.dart';
import 'plan_models.dart';
import 'plan_changes.dart';
import 'plan_writer.dart';
import 'session_content.dart';

/// Everything the Plan screen does, in one place: generate a block from the
/// cache, store it, write it to Intervals.icu, and take its future part off
/// again. The screen only decides when.
class PlanService {
  PlanService({
    KnowledgeRepository? knowledge,
    PlanInputsLoader? inputs,
    PlansRepository? plans,
    ActivitiesRepository? activities,
    PlanWriter? writer,
    GoalStore? goals,
    SessionContentGenerator? content,
  }) : knowledge = knowledge ?? KnowledgeRepository(),
       _inputs = inputs ?? PlanInputsLoader(),
       plans = plans ?? PlansRepository(),
       _activities = activities ?? ActivitiesRepository(),
       goals = goals ?? GoalStore(),
       _content = content ?? SessionContentGenerator() {
    this.writer =
        writer ??
        PlanWriter(
          workouts: QueuedWorkoutWriter(queueCreates: true),
          plans: this.plans,
        );
  }

  final KnowledgeRepository knowledge;
  final PlansRepository plans;
  final GoalStore goals;
  final PlanInputsLoader _inputs;
  final ActivitiesRepository _activities;
  final SessionContentGenerator _content;
  late final PlanWriter writer;

  /// The Monday a new block should start on: next Monday, or this week's
  /// Monday when [today] is one (a plan made on Monday starts that day).
  static DateTime defaultStart(DateTime today) => Goal.defaultStart(today);

  /// What the load graph is drawn within for [goal]: the baseline, ramp,
  /// CTL and hours limits from the cache — or why there are none yet.
  Future<({CurveLimits? limits, PlanFailure? failure, int weeks})> curve(
    Goal goal, {
    DateTime? start,
    DateTime? today,
  }) async {
    final now = today ?? DateTime.now();
    final monday = start ?? defaultStart(now);
    final loaded = await knowledge.load();
    final inputs = await _inputs.load(monday);
    final found = PlanEngine(loaded).limitsFor(
      goal: goal,
      recentWeeklyLoads: inputs.weeklyLoads,
      currentCtl: inputs.currentCtl,
      today: now,
      start: monday,
    );
    return (
      limits: found.limits,
      failure: found.failure,
      weeks: goal.planWeeks(monday),
    );
  }

  Future<PlanResult> generate(
    Goal goal, {
    DateTime? start,
    DateTime? today,
  }) async {
    final now = today ?? DateTime.now();
    final monday = start ?? defaultStart(now);
    final loaded = await knowledge.load();
    final inputs = await _inputs.load(monday);
    final result = PlanEngine(loaded).generate(
      goal: goal,
      startDate: monday,
      recentWeeklyLoads: inputs.weeklyLoads,
      currentCtl: inputs.currentCtl,
      today: now,
    );
    final plan = result.plan;
    if (plan == null) return result;
    // The deterministic engine already decided every number and which swim
    // sessions are technique-focused; this only rewrites session text, and
    // falls back to what the engine already produced on any failure.
    return PlanResult.plan(await _content.enrich(plan));
  }

  /// Completed endurance load per plan week (TSS), for target-versus-actual. Weeks
  /// that haven't started have no actual yet.
  Future<List<int?>> actualLoads(TrainingPlan plan, {DateTime? today}) async {
    final now = dateOnly(today ?? DateTime.now());
    final result = <int?>[];
    for (final week in plan.weeks) {
      if (week.startDate.isAfter(now)) {
        result.add(null);
        continue;
      }
      final rows = await _activities.getRange(
        isoDate(week.startDate),
        isoDate(week.startDate.add(const Duration(days: 6))),
      );
      // Endurance only, like the week's target and planned load.
      result.add(
        rows
            .where((a) => !isStrengthType(a.type))
            .fold<int>(0, (sum, a) => sum + (a.trainingLoad ?? 0)),
      );
    }
    return result;
  }

  /// Saves [draft] as the current plan and writes it to Intervals.icu. A
  /// previous plan's upcoming sessions are removed first; its past ones stay
  /// as history.
  Future<({TrainingPlan plan, PlanWriteReport report})> confirm(
    TrainingPlan draft, {
    TrainingPlan? replacing,
    DateTime? today,
  }) async {
    if (replacing != null) {
      await removeUpcoming(replacing, today: today);
    }
    final saved = await plans.save(draft);
    final report = await writer.write(saved);
    final current = await plans.getById(saved.id!);
    return (plan: current ?? saved, report: report);
  }

  /// **Take as plan**: stores [draft] as the current plan, locally only. A
  /// previous plan's upcoming sessions are removed first; its past ones
  /// stay as history. The Calendar shows the result straight away; sending
  /// to Intervals.icu is [send], when the athlete has that on.
  Future<TrainingPlan> take(
    TrainingPlan draft, {
    TrainingPlan? replacing,
    DateTime? today,
  }) async {
    if (replacing != null) {
      await removeUpcoming(replacing, today: today);
    }
    final saved = await plans.save(draft.copyWith(status: PlanStatus.active));
    PlanChanges.instance.notify();
    return saved;
  }

  /// Creates [plan]'s sessions that aren't on Intervals.icu yet — from
  /// [from] on, when given. Safe to call again: it retries only what failed.
  Future<({TrainingPlan plan, PlanWriteReport report})> send(
    TrainingPlan plan, {
    DateTime? from,
  }) async {
    try {
      final report = await writer.write(plan, from: from);
      return (plan: (await plans.getById(plan.id!)) ?? plan, report: report);
    } finally {
      PlanChanges.instance.notify();
    }
  }

  /// The current plan's sessions from [today] on that are not on
  /// Intervals.icu — what turning sending on would send.
  Future<({TrainingPlan? plan, int count})> unsentUpcoming({
    DateTime? today,
  }) async {
    final plan = await plans.getCurrent();
    if (plan == null) return (plan: null, count: 0);
    final cutoff = dateOnly(today ?? DateTime.now());
    final count = plan.sessions
        .where(
          (s) =>
              s.status != PlanSessionStatus.created && !s.date.isBefore(cutoff),
        )
        .length;
    return (plan: plan, count: count);
  }

  /// Retries only the sessions that failed to reach Intervals.icu.
  Future<({TrainingPlan plan, PlanWriteReport report})> retry(
    TrainingPlan plan,
  ) async {
    final report = await writer.write(plan);
    return (plan: (await plans.getById(plan.id!)) ?? plan, report: report);
  }

  /// Deletes [plan]'s sessions from today on (upstream and locally). The
  /// plan itself is marked removed when nothing of it is left to keep.
  Future<int> removeUpcoming(TrainingPlan plan, {DateTime? today}) async {
    final removed = await writer.removeFrom(plan, today ?? DateTime.now());
    final remaining = await plans.getById(plan.id!);
    if (remaining == null || remaining.sessions.isEmpty) {
      await plans.setStatus(plan.id!, PlanStatus.removed);
    }
    PlanChanges.instance.notify();
    return removed;
  }
}
