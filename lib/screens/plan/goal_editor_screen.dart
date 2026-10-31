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

  /// Session mix in %; [_slotsTouched] tells a chosen mix from the template
  /// shown as a starting point (which stays `null` in the goal).
  late Map<String, int> _slots;
  bool _slotsTouched = false;
  late Map<String, int> _longDays;
  late Set<int> _intervalDays;
  int? _perDay;
  final _baseline = TextEditingController();
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
    final custom = goal?.slotShares;
    _slotsTouched = custom != null;
    _slots = custom != null ? {...custom} : _templateSlots(_target);
    _longDays = {...?goal?.longDays};
    _intervalDays = {...?goal?.intervalDays};
    _perDay = goal?.maxSessionsPerDay;
    if (goal?.baselineWeeklyLoad != null) {
      _baseline.text = goal!.baselineWeeklyLoad!.round().toString();
    }
    if (goal?.maxCtlRamp != null) _ramp.text = goal!.maxCtlRamp.toString();
  }

  @override
  void dispose() {
    _baseline.dispose();
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

  /// The goal type's template shares, in % on the 5% grid.
  Map<String, int> _templateSlots(String target) {
    final profile = widget.knowledge.goals[target];
    final result = {
      for (final k in Goal.slotKeys)
        k: ((profile?.slots[SessionSlot.values.byName(k)]?.share ?? 0) * 20)
                .round() *
            5,
    };
    // Rounding may leave the total off 100: give the difference to Z2.
    final total = result.values.fold(0, (a, b) => a + b);
    result['z2'] = result['z2']! + 100 - total;
    return result;
  }

  void _toggleDay(int day, bool on) {
    setState(() {
      if (on) {
        _days.add(day);
      } else {
        _days.remove(day);
        // A preference on a day that is no longer trained goes with it.
        _longDays.removeWhere((_, d) => d == day);
        _intervalDays.remove(day);
      }
    });
  }

  void _save() {
    final goal = Goal(
      targetType: _target,
      sport: _sport,
      weekdays: _days,
      weeklyHours: _hours,
      eventDate: _eventDate,
      baselineWeeklyLoad: double.tryParse(_baseline.text.replaceAll(',', '.')),
      // Set with the ramp slider on the Weekly load card.
      maxWeeklyIncrease: widget.initial?.maxWeeklyIncrease,
      maxCtlRamp: double.tryParse(_ramp.text.replaceAll(',', '.')),
      weeks: _weeks,
      sportMix: _mix,
      // The load graph's shape survives a goal edit; extra weeks start at
      // 100% and dropped weeks are cut off when the plan is drawn.
      loadFactors: widget.initial?.loadFactors ?? const [],
      holdEvery4th: widget.initial?.holdEvery4th ?? true,
      slotShares: _slotsTouched ? _slots : null,
      longDays: _longDays,
      intervalDays: _intervalDays,
      maxSessionsPerDay: _perDay,
    ).withoutStalePreferences();
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
            onChanged: (value) => setState(() {
              _target = value ?? _target;
              // A new goal type brings its template mix unless one was chosen.
              if (!_slotsTouched) _slots = _templateSlots(_target);
            }),
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
                  onSelected: (on) => _toggleDay(day, on),
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
          _slotsEditor(l10n, theme),
          const SizedBox(height: 20),
          _preferencesEditor(l10n, theme),
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

  Widget _slotsEditor(AppLocalizations l10n, ThemeData theme) {
    final scheme = theme.colorScheme;
    final total = Goal.slotKeys.fold<int>(0, (s, k) => s + (_slots[k] ?? 0));
    String label(String k) => switch (k) {
      'z2' => l10n.slotZ2,
      'intervals' => l10n.slotIntervals,
      _ => l10n.slotLong,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.planGoalSlotsTitle,
                style: theme.textTheme.titleSmall,
              ),
            ),
            Text(
              l10n.planGoalMixTotal(total),
              key: const ValueKey('goal-slots-total'),
              style: theme.textTheme.titleSmall?.copyWith(
                color: total == 100 ? scheme.primary : scheme.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        for (final k in Goal.slotKeys)
          Row(
            children: [
              SizedBox(
                width: 130,
                child: Text('${label(k)}: ${_slots[k] ?? 0}%'),
              ),
              Expanded(
                child: Slider(
                  key: ValueKey('goal-slot-$k'),
                  value: (_slots[k] ?? 0).toDouble(),
                  max: 100,
                  divisions: 20,
                  label: '${_slots[k] ?? 0}%',
                  onChanged: (v) => setState(() {
                    _slots[k] = v.round();
                    _slotsTouched = true;
                  }),
                ),
              ),
            ],
          ),
        if (_slotsTouched)
          TextButton(
            onPressed: () => setState(() {
              _slots = _templateSlots(_target);
              _slotsTouched = false;
            }),
            child: Text(l10n.planGoalSlotsReset),
          ),
      ],
    );
  }

  Widget _preferencesEditor(AppLocalizations l10n, ThemeData theme) {
    final locale = Localizations.localeOf(context).toString();
    final monday = DateTime(2024, 1, 1);
    String dayName(int d) =>
        DateFormat.E(locale).format(monday.add(Duration(days: d - 1)));
    final days = _days.toList()..sort();
    final longSports = _sport == Goal.triathlon
        ? const ['Ride', 'Run']
        : [_sport];
    final perDay =
        _perDay ?? (_sport == Goal.triathlon ? 2 : 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.planGoalPrefsTitle, style: theme.textTheme.titleSmall),
        for (final sport in longSports) ...[
          const SizedBox(height: 8),
          Text(l10n.planGoalLongDay(sportLabel(l10n, sport))),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ChoiceChip(
                label: Text(l10n.planGoalAnyDay),
                selected: _longDays[sport] == null,
                onSelected: (_) => setState(() => _longDays.remove(sport)),
              ),
              for (final d in days)
                ChoiceChip(
                  key: ValueKey('long-day-$sport-$d'),
                  label: Text(dayName(d)),
                  selected: _longDays[sport] == d,
                  onSelected: (_) => setState(() => _longDays[sport] = d),
                ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        Text(l10n.planGoalIntervalDays),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final d in days)
              FilterChip(
                key: ValueKey('interval-day-$d'),
                label: Text(dayName(d)),
                selected: _intervalDays.contains(d),
                onSelected: (on) => setState(
                  () => on ? _intervalDays.add(d) : _intervalDays.remove(d),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(l10n.planGoalPerDay),
        const SizedBox(height: 4),
        SegmentedButton<int>(
          key: const ValueKey('per-day'),
          segments: const [
            ButtonSegment(value: 1, label: Text('1')),
            ButtonSegment(value: 2, label: Text('2')),
          ],
          selected: {perDay},
          onSelectionChanged: (s) => setState(() => _perDay = s.first),
        ),
      ],
    );
  }
}
