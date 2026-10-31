import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../plan/knowledge.dart';
import '../../plan/plan_models.dart';
import '../../plan/plan_service.dart';
import '../activities/activity_icons.dart';
import 'plan_labels.dart';

/// Edits the training goal: what the block is for, which days are free and
/// how much time there is. Pops the saved [Goal], or nothing on back.
class GoalEditorScreen extends StatefulWidget {
  const GoalEditorScreen({
    super.key,
    required this.knowledge,
    this.initial,
    this.defaults = const PlanRules(
      weekPhases: [],
      weekMultipliers: [],
      maxWeeklyIncrease: 0.10,
      maxCtlRamp: 7,
      lowIntensityTarget: 0.8,
      lowIntensityTolerance: 0.05,
      minHistoryWeeks: 4,
    ),
  });

  final TrainingKnowledge knowledge;
  final Goal? initial;

  /// Shown as hints in the limit fields when the goal has no override.
  final PlanRules defaults;

  @override
  State<GoalEditorScreen> createState() => _GoalEditorScreenState();
}

class _GoalEditorScreenState extends State<GoalEditorScreen> {
  late String _target;
  late String _sport;
  late Set<int> _days;
  late double _hours;
  DateTime? _eventDate;

  /// `null` until the athlete moves the slider: the plan then follows the
  /// default (8 weeks or the weeks until the event).
  int? _weeks;
  late Map<String, int> _mix;
  final _baseline = TextEditingController();
  final _increase = TextEditingController();
  final _ramp = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    final goal = widget.initial;
    _target = goal?.targetType ?? widget.knowledge.goals.keys.first;
    _sport = goal?.sport ?? 'Run';
    _days = {...?goal?.weekdays};
    if (goal == null) _days = {2, 4, 6};
    _hours = goal?.weeklyHours ?? 6;
    _eventDate = goal?.eventDate;
    _weeks = goal?.weeks;
    _mix = {...?goal?.sportMix};
    if (_mix.isEmpty) _mix = {...Goal.defaultSportMix};
    if (goal?.baselineWeeklyLoad != null) {
      _baseline.text = goal!.baselineWeeklyLoad!.round().toString();
    }
    if (goal?.maxWeeklyIncrease != null) {
      _increase.text = (goal!.maxWeeklyIncrease! * 100).round().toString();
    }
    if (goal?.maxCtlRamp != null) _ramp.text = goal!.maxCtlRamp.toString();
  }

  @override
  void dispose() {
    _baseline.dispose();
    _increase.dispose();
    _ramp.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? now.add(const Duration(days: 84)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _eventDate = picked);
  }

  void _save() {
    final increase = double.tryParse(_increase.text.replaceAll(',', '.'));
    final goal = Goal(
      targetType: _target,
      sport: _sport,
      weekdays: _days,
      weeklyHours: _hours,
      eventDate: _eventDate,
      baselineWeeklyLoad: double.tryParse(_baseline.text.replaceAll(',', '.')),
      maxWeeklyIncrease: increase == null ? null : increase / 100,
      maxCtlRamp: double.tryParse(_ramp.text.replaceAll(',', '.')),
      weeks: _weeks,
      sportMix: _mix,
      // The load graph's shape survives a goal edit; extra weeks start at
      // 100% and dropped weeks are cut off when the plan is drawn.
      loadFactors: widget.initial?.loadFactors ?? const [],
    );
    final problem = goal.validate(today: DateTime.now());
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    Navigator.of(context).pop(goal);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final monday = DateTime(2024, 1, 1);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.planGoalTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.planGoalTarget, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _target,
            items: [
              for (final goal in widget.knowledge.goals.values)
                DropdownMenuItem(value: goal.id, child: Text(goal.label)),
            ],
            onChanged: (value) => setState(() => _target = value ?? _target),
          ),
          const SizedBox(height: 20),
          Text(l10n.planGoalSport, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: [
              for (final sport in Goal.sports)
                ButtonSegment(value: sport, label: Text(sportLabel(l10n, sport))),
            ],
            selected: {_sport},
            onSelectionChanged: (s) => setState(() => _sport = s.first),
          ),
          if (_sport == Goal.triathlon) ...[
            const SizedBox(height: 20),
            _mixEditor(l10n, theme),
          ],
          const SizedBox(height: 20),
          Text(l10n.planGoalDays, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var day = 1; day <= 7; day++)
                FilterChip(
                  label: Text(
                    DateFormat.E(locale).format(
                      monday.add(Duration(days: day - 1)),
                    ),
                  ),
                  selected: _days.contains(day),
                  onSelected: (on) => setState(
                    () => on ? _days.add(day) : _days.remove(day),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            l10n.planGoalHours(_hours.toStringAsFixed(1)),
            style: theme.textTheme.titleSmall,
          ),
          Slider(
            value: _hours,
            min: 2,
            max: 20,
            divisions: 36,
            label: _hours.toStringAsFixed(1),
            onChanged: (value) => setState(() => _hours = value),
          ),
          const SizedBox(height: 12),
          Text(l10n.planGoalEventDate, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.event_outlined),
                label: Text(
                  _eventDate == null
                      ? l10n.planGoalEventDate
                      : MaterialLocalizations.of(context).formatMediumDate(
                          _eventDate!,
                        ),
                ),
              ),
              if (_eventDate != null)
                IconButton(
                  tooltip: l10n.planGoalClearDate,
                  onPressed: () => setState(() => _eventDate = null),
                  icon: const Icon(Icons.close),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _weeksEditor(l10n, theme),
          const SizedBox(height: 20),
          TextField(
            controller: _baseline,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.planGoalBaseline,
              helperText: l10n.planGoalBaselineHelp,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n.planGoalLimitsTitle, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _increase,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.planGoalMaxIncrease,
              hintText: '${(widget.defaults.maxWeeklyIncrease * 100).round()}',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ramp,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.planGoalMaxRamp,
              hintText: '${widget.defaults.maxCtlRamp}',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.planGoalLimitsNote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ],
          const SizedBox(height: 20),
          FilledButton(onPressed: _save, child: Text(l10n.planSaveButton)),
        ],
      ),
    );
  }

  Widget _weeksEditor(AppLocalizations l10n, ThemeData theme) {
    final shown =
        _weeks ??
        Goal(
          targetType: _target,
          weekdays: _days,
          weeklyHours: _hours,
          eventDate: _eventDate,
        ).planWeeks(PlanService.defaultStart(DateTime.now()));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.planGoalWeeks(shown),
                style: theme.textTheme.titleSmall,
              ),
            ),
            if (_weeks != null)
              TextButton(
                onPressed: () => setState(() => _weeks = null),
                child: Text(l10n.planGoalWeeksAuto),
              ),
          ],
        ),
        Slider(
          key: const ValueKey('goal-weeks'),
          value: shown.toDouble(),
          min: Goal.minWeeks.toDouble(),
          max: Goal.maxWeeks.toDouble(),
          divisions: Goal.maxWeeks - Goal.minWeeks,
          label: '$shown',
          onChanged: (value) => setState(() => _weeks = value.round()),
        ),
        if (_weeks == null)
          Text(
            l10n.planGoalWeeksDefault,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  Widget _mixEditor(AppLocalizations l10n, ThemeData theme) {
    final scheme = theme.colorScheme;
    final total = Goal.triathlonSports.fold<int>(
      0,
      (sum, s) => sum + (_mix[s] ?? 0),
    );
    final ok = total == 100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.planGoalMixTitle,
                style: theme.textTheme.titleSmall,
              ),
            ),
            Text(
              l10n.planGoalMixTotal(total),
              key: const ValueKey('goal-mix-total'),
              style: theme.textTheme.titleSmall?.copyWith(
                color: ok ? scheme.primary : scheme.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        for (final sport in Goal.triathlonSports)
          Row(
            children: [
              Icon(activityTypeIcon(sport), color: sportColor(sport, scheme)),
              const SizedBox(width: 8),
              SizedBox(
                width: 96,
                child: Text(
                  l10n.planGoalMixShare(
                    sportLabel(l10n, sport),
                    _mix[sport] ?? 0,
                  ),
                ),
              ),
              Expanded(
                child: Slider(
                  key: ValueKey('goal-mix-$sport'),
                  value: (_mix[sport] ?? 0).toDouble(),
                  max: 100,
                  divisions: 20,
                  activeColor: sportColor(sport, scheme),
                  label: '${_mix[sport] ?? 0}%',
                  onChanged: (value) =>
                      setState(() => _mix[sport] = value.round()),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
