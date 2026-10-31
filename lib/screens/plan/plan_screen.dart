import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/intervals_session.dart';
import '../../data/sync/auto_sync_service.dart';
import '../../l10n/app_localizations.dart';
import '../../plan/knowledge.dart';
import '../../plan/load_curve.dart';
import '../../plan/load_curve_controller.dart';
import '../../plan/plan_models.dart';
import '../../plan/plan_service.dart';
import '../../plan/plan_writer.dart';
import '../../util/calendar_export.dart';
import '../../util/dates.dart';
import '../../widgets/charts/load_curve_editor.dart';
import '../activities/activity_icons.dart';
import '../profile/profile_screen.dart';
import 'goal_editor_screen.dart';
import 'plan_labels.dart';
import 'plan_preview_sheet.dart';

/// The training plan: the goal, the load graph, and the current block with
/// each week's target against what was actually done, its 80/20 split and a
/// Monday-Sunday calendar row.
class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key, PlanService? service}) : _service = service;

  final PlanService? _service;

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  late final PlanService _service = widget._service ?? PlanService();

  Goal? _goal;
  TrainingPlan? _plan;
  List<int?> _actuals = const [];
  TrainingKnowledge? _knowledge;
  bool _loading = true;
  bool _busy = false;

  /// The load graph for the current goal; `null` without a goal or while
  /// [_curveFailure] says why it can't be drawn.
  LoadCurveController? _curve;
  PlanFailure? _curveFailure;

  @override
  void initState() {
    super.initState();
    AutoSyncService.instance.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    AutoSyncService.instance.removeListener(_load);
    _curve?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final goal = await _service.goals.load();
    final plan = await _service.plans.getCurrent();
    final knowledge = await _service.knowledge.load();
    final actuals = plan == null
        ? const <int?>[]
        : await _service.actualLoads(plan);
    final curve = goal == null ? null : await _service.curve(goal);
    if (!mounted) return;
    setState(() {
      _goal = goal;
      _plan = plan;
      _knowledge = knowledge;
      _actuals = actuals;
      _loading = false;
      _applyCurve(goal, curve);
    });
  }

  /// Keeps one controller across reloads so a sync re-scales the curve
  /// without losing the athlete's selection or undo history.
  void _applyCurve(
    Goal? goal,
    ({CurveLimits? limits, PlanFailure? failure, int weeks})? curve,
  ) {
    final limits = curve?.limits;
    if (goal == null || limits == null) {
      _curve?.dispose();
      _curve = null;
      _curveFailure = curve?.failure;
      return;
    }
    _curveFailure = null;
    final existing = _curve;
    if (existing == null) {
      _curve = LoadCurveController(
        limits: limits,
        weeks: curve!.weeks,
        factors: goal.loadFactors,
      );
    } else {
      existing.update(limits: limits, weeks: curve!.weeks);
    }
  }

  /// Persists the graph's factors into the goal after each edit.
  Future<void> _saveCurve() async {
    final goal = _goal;
    final curve = _curve;
    if (goal == null || curve == null) return;
    final updated = goal.copyWith(loadFactors: curve.factors);
    _goal = updated;
    await _service.goals.save(updated);
  }

  void _say(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _editGoal() async {
    final knowledge = _knowledge;
    if (knowledge == null) return;
    final goal = await Navigator.of(context).push<Goal>(
      MaterialPageRoute(
        builder: (_) => GoalEditorScreen(
          knowledge: knowledge,
          initial: _goal,
          defaults: knowledge.rules,
        ),
      ),
    );
    if (goal == null) return;
    await _service.goals.save(goal);
    await _load();
  }

  String _failureMessage(AppLocalizations l10n, PlanFailure failure) =>
      failure.kind == PlanFailureKind.notEnoughDays
      ? l10n.planNotEnoughDays
      : failure.message;

  Future<void> _generate() async {
    final l10n = AppLocalizations.of(context)!;
    if (!IntervalsSession.instance.isConnected) {
      _say(l10n.planNotConnected);
      return;
    }
    var goal = _goal;
    if (goal == null) {
      await _editGoal();
      goal = _goal;
      if (goal == null) return;
    }

    // Generate exactly what the graph shows.
    final curve = _curve;
    if (curve != null) goal = goal.copyWith(loadFactors: curve.factors);

    setState(() => _busy = true);
    try {
      var result = await _service.generate(goal);
      if (result.failure?.kind == PlanFailureKind.needsBaseline) {
        if (!mounted) return;
        final baseline = await _askBaseline(result.failure!.message);
        if (baseline == null) return;
        goal = goal.copyWith(baselineWeeklyLoad: baseline);
        await _service.goals.save(goal);
        result = await _service.generate(goal);
      }
      final failure = result.failure;
      if (failure != null) {
        if (mounted) {
          _say(l10n.planGenerateFailed(_failureMessage(l10n, failure)));
        }
        return;
      }
      if (!mounted) return;
      setState(() => _busy = false);
      final confirmed = await showModalBottomSheet<PlanPreviewResult>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => PlanPreviewSheet(plan: result.plan!),
      );
      if (confirmed == null || !mounted) return;

      setState(() => _busy = true);
      final outcome = await _service.confirm(
        confirmed.plan,
        replacing: _plan,
      );
      if (!mounted) return;
      _say(_reportMessage(l10n, outcome.report));
    } catch (error) {
      if (mounted) _say(l10n.planGenerateFailed('$error'));
    } finally {
      if (mounted) setState(() => _busy = false);
      await _load();
    }
  }

  String _reportMessage(AppLocalizations l10n, PlanWriteReport report) =>
      report.allCreated
      ? l10n.planCreatedAll(report.created.length)
      : l10n.planCreatedPartial(report.created.length, report.failed.length);

  Future<double?> _askBaseline(String message) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    return showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.planNeedsBaselineTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.planBaselineDialogField,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(
                controller.text.replaceAll(',', '.'),
              );
              if (value != null && value > 0) {
                Navigator.of(context).pop(value);
              }
            },
            child: Text(l10n.planContinueButton),
          ),
        ],
      ),
    );
  }

  Future<void> _retryFailed() async {
    final plan = _plan;
    if (plan == null) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      final outcome = await _service.retry(plan);
      if (mounted) _say(_reportMessage(l10n, outcome.report));
    } catch (error) {
      if (mounted) _say(l10n.planGenerateFailed('$error'));
    } finally {
      if (mounted) setState(() => _busy = false);
      await _load();
    }
  }

  Future<void> _removeUpcoming() async {
    final plan = _plan;
    if (plan == null) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.planRemoveTitle),
        content: Text(l10n.planRemoveBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.deleteButton),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      final removed = await _service.removeUpcoming(plan);
      if (mounted) _say(l10n.planRemoved(removed));
    } catch (error) {
      if (mounted) _say(l10n.planGenerateFailed('$error'));
    } finally {
      if (mounted) setState(() => _busy = false);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final plan = _plan;
    final knowledge = _knowledge;
    final failedCount =
        plan?.sessions.where((s) => s.status == PlanSessionStatus.failed).length ??
        0;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.trainingPlansTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _GoalCard(
                  goal: _goal,
                  knowledge: knowledge,
                  onEdit: _busy ? null : _editGoal,
                ),
                if (_goal != null) ...[
                  const SizedBox(height: 12),
                  _CurveCard(
                    controller: _curve,
                    failure: _curveFailure,
                    onChanged: _saveCurve,
                    onEditGoal: _busy ? null : _editGoal,
                  ),
                ],
                if (knowledge != null && knowledge.warnings.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.planKnowledgeWarning,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                if (!IntervalsSession.instance.isConnected) ...[
                  Text(l10n.planNotConnected),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    ),
                    child: Text(l10n.openProfileButton),
                  ),
                  const SizedBox(height: 12),
                ],
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: _busy ? null : _generate,
                      icon: _busy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_awesome_outlined),
                      label: Text(
                        plan == null ? l10n.planGenerate : l10n.planRegenerate,
                      ),
                    ),
                    if (failedCount > 0)
                      OutlinedButton(
                        onPressed: _busy ? null : _retryFailed,
                        child: Text(l10n.planRetryFailed(failedCount)),
                      ),
                    if (plan != null)
                      OutlinedButton.icon(
                        onPressed: _busy ? null : _removeUpcoming,
                        icon: const Icon(Icons.delete_outline),
                        label: Text(l10n.planRemoveUpcoming),
                      ),
                  ],
                ),
                if (plan != null)
                  for (final week in plan.weeks)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: _WeekCard(
                        week: week,
                        actual: week.index < _actuals.length
                            ? _actuals[week.index]
                            : null,
                        multiSport: plan.sport == Goal.triathlon,
                        rampCap:
                            _goal?.maxWeeklyIncrease ??
                            knowledge?.rules.maxWeeklyIncrease ??
                            0.10,
                      ),
                    ),
              ],
            ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.knowledge,
    required this.onEdit,
  });

  final Goal? goal;
  final TrainingKnowledge? knowledge;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final goal = this.goal;
    final label = goal == null
        ? null
        : knowledge?.goals[goal.targetType]?.label ?? goal.targetType;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.planGoalTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    goal == null
                        ? l10n.planNoGoal
                        : l10n.planGoalSummary(
                            label!,
                            sportLabel(l10n, goal.sport),
                            goal.weekdays.length,
                            goal.weeklyHours.toStringAsFixed(1),
                          ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onEdit,
              child: Text(goal == null ? l10n.planSetGoal : l10n.planEditGoal),
            ),
          ],
        ),
      ),
    );
  }
}

/// The load graph with its explanation: what 100% means and how to edit.
class _CurveCard extends StatelessWidget {
  const _CurveCard({
    required this.controller,
    required this.failure,
    required this.onChanged,
    required this.onEditGoal,
  });

  final LoadCurveController? controller;
  final PlanFailure? failure;
  final VoidCallback onChanged;
  final VoidCallback? onEditGoal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final c = controller;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                l10n.planCurveTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 4),
            if (c == null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  failure?.kind == PlanFailureKind.needsBaseline
                      ? l10n.planCurveNeedsBaseline
                      : failure?.kind == PlanFailureKind.notEnoughDays
                      ? l10n.planNotEnoughDays
                      : failure?.message ?? '',
                ),
              ),
              if (failure?.kind == PlanFailureKind.needsBaseline)
                TextButton(
                  onPressed: onEditGoal,
                  child: Text(l10n.planEditGoal),
                ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  l10n.planCurveProposal(
                    (c.limits.rampCap * 100).round(),
                    c.limits.baseline.round(),
                  ),
                  style: muted,
                ),
              ),
              const SizedBox(height: 8),
              LoadCurveEditor(controller: c, onChanged: onChanged),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                child: Text(l10n.planCurveHint, style: muted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One plan week: its targets and warnings, then its sessions as a
/// Monday-Sunday calendar row coloured by sport.
class _WeekCard extends StatelessWidget {
  const _WeekCard({
    required this.week,
    required this.actual,
    required this.multiSport,
    required this.rampCap,
  });

  final PlanWeek week;

  /// Completed load so far; `null` for a week that has not started.
  final int? actual;
  final bool multiSport;
  final double rampCap;

  bool get _isCurrent {
    final today = dateOnly(DateTime.now());
    return !today.isBefore(week.startDate) &&
        today.isBefore(week.startDate.add(const Duration(days: 7)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final planned = week.plannedLoad;
    final target = week.targetLoad.round();
    final share = week.lowShare;
    final limit = limitLabel(l10n, week.limit);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return Card(
      shape: _isCurrent
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: scheme.primary, width: 2),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.planWeekLabel(
                      week.index + 1,
                      phaseLabel(l10n, week.phase),
                    ),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (_isCurrent)
                  Chip(
                    label: Text(l10n.planThisWeek),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              actual == null
                  ? l10n.planTargetPlanned(target, planned)
                  : l10n.planTargetVsActual(actual!, planned),
            ),
            if (week.factor != 1.0)
              Text(
                l10n.planCurveFactor((week.factor * 100).round()),
                style: muted,
              ),
            if (actual != null) ...[
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: planned == 0 ? 0 : (actual! / planned).clamp(0.0, 1.0),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
            if (multiSport) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  for (final sport in Goal.triathlonSports)
                    if (week.loadBySport[sport] != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            activityTypeIcon(sport),
                            size: 16,
                            color: sportColor(sport, scheme),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.planWeekBySport(
                              sportLabel(l10n, sport),
                              week.loadBySport[sport]!,
                            ),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                ],
              ),
            ],
            if (share != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(l10n.planEasyShare((share * 100).round()), style: muted),
                  if (week.outsideTolerance) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.warning_amber_rounded,
                        size: 16, color: scheme.error),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        l10n.planOutside8020,
                        style: TextStyle(color: scheme.error),
                      ),
                    ),
                  ],
                ],
              ),
            ],
            for (final flag in week.warnings)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 16, color: scheme.error),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        warningLabel(l10n, flag, rampCap),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (limit != null) ...[
              const SizedBox(height: 4),
              Text(limit, style: muted),
            ],
            const SizedBox(height: 12),
            _WeekGrid(
              week: week,
              onOpen: (session) => _openSession(context, session),
            ),
          ],
        ),
      ),
    );
  }

  void _openSession(BuildContext context, PlanSession session) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(l10n.planSessionMinutes(session.minutes, session.load)),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SelectableText(
                      session.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => launchGoogleCalendarEvent(
                  title: session.name,
                  description: session.description,
                  start: session.date,
                  duration: Duration(minutes: session.minutes),
                  allDay: true,
                ),
                icon: const Icon(Icons.event_outlined),
                label: Text(l10n.planOpenSingle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Seven day columns, Monday first, each with that day's sessions as
/// sport-coloured tiles (icon, minutes, TSS). Tap a tile for its steps.
class _WeekGrid extends StatelessWidget {
  const _WeekGrid({required this.week, required this.onOpen});

  final PlanWeek week;
  final ValueChanged<PlanSession> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final today = dateOnly(DateTime.now());

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var d = 0; d < 7; d++)
          Expanded(
            child: Builder(
              builder: (context) {
                final day = week.startDate.add(Duration(days: d));
                final sessions = week.sessions
                    .where((s) => dateOnly(s.date) == day)
                    .toList();
                final isToday = day == today;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: Column(
                    children: [
                      Text(
                        DateFormat.E(locale).format(day),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isToday
                              ? scheme.primary
                              : scheme.onSurfaceVariant,
                          fontWeight: isToday ? FontWeight.w700 : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                      Text(
                        '${day.day}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isToday ? scheme.primary : scheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (sessions.isEmpty)
                        Container(
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: scheme.outlineVariant),
                          ),
                        ),
                      for (final s in sessions)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: _SessionTile(
                            session: s,
                            label: l10n,
                            onTap: () => onOpen(s),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.session,
    required this.label,
    required this.onTap,
  });

  final PlanSession session;
  final AppLocalizations label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = sportColor(session.sport, scheme);
    final small = theme.textTheme.labelSmall;
    final failed = session.status == PlanSessionStatus.failed;

    return Semantics(
      button: true,
      label:
          '${sportLabel(label, session.sport)}, ${session.name}, '
          '${label.planSessionMinutes(session.minutes, session.load)}',
      excludeSemantics: true,
      child: Material(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: color, width: 3)),
            ),
            padding: const EdgeInsets.fromLTRB(2, 4, 2, 4),
            child: Column(
              children: [
                Icon(
                  failed ? Icons.error_outline : activityTypeIcon(session.sport),
                  size: 16,
                  color: failed ? scheme.error : color,
                ),
                Text(
                  '${session.minutes}′',
                  style: small?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                ),
                Text(
                  '${session.load}',
                  style: small?.copyWith(color: scheme.onSurfaceVariant),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
