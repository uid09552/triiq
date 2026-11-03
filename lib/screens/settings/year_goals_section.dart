import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'year_goals_progress.dart';
import 'year_goals_settings.dart';

/// Settings → Year goals: a yearly distance goal (km) per sport, whether its
/// progress card shows on Today, and — right under the fields — how far
/// along each goal is. A field left blank means no goal for that sport.
class YearGoalsSection extends StatefulWidget {
  YearGoalsSection({super.key, YearGoalsSettings? settings})
    : settings = settings ?? YearGoalsSettings.instance;

  final YearGoalsSettings settings;

  @override
  State<YearGoalsSection> createState() => _YearGoalsSectionState();
}

class _YearGoalsSectionState extends State<YearGoalsSection> {
  final _swim = TextEditingController();
  final _cycle = TextEditingController();
  final _run = TextEditingController();
  bool _adopted = false;

  YearGoalsSettings get _settings => widget.settings;

  @override
  void initState() {
    super.initState();
    _settings.addListener(_adoptStoredValues);
    _adoptStoredValues();
  }

  @override
  void dispose() {
    _settings.removeListener(_adoptStoredValues);
    _swim.dispose();
    _cycle.dispose();
    _run.dispose();
    super.dispose();
  }

  void _adoptStoredValues() {
    if (!mounted || _adopted || !_settings.isLoaded) return;
    _adopted = true;
    setState(() {
      _swim.text = _fmt(_settings.swimKm);
      _cycle.text = _fmt(_settings.cycleKm);
      _run.text = _fmt(_settings.runKm);
    });
  }

  static String _fmt(double? km) => km == null
      ? ''
      : (km == km.roundToDouble() ? km.round().toString() : km.toString());

  double? _parse(String text) {
    final trimmed = text.trim().replaceAll(',', '.');
    return trimmed.isEmpty ? null : double.tryParse(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.yearGoalsHelp,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          _field(
            const ValueKey('year-goal-swim-field'),
            _swim,
            l10n.yearGoalKmLabel(l10n.sportSwim),
            l10n.noTargetSet,
            (t) => _settings.setSwimKm(_parse(t)),
          ),
          const SizedBox(height: 12),
          _field(
            const ValueKey('year-goal-cycle-field'),
            _cycle,
            l10n.yearGoalKmLabel(l10n.sportRide),
            l10n.noTargetSet,
            (t) => _settings.setCycleKm(_parse(t)),
          ),
          const SizedBox(height: 12),
          _field(
            const ValueKey('year-goal-run-field'),
            _run,
            l10n.yearGoalKmLabel(l10n.sportRun),
            l10n.noTargetSet,
            (t) => _settings.setRunKm(_parse(t)),
          ),
          if (_settings.hasAnyGoal) ...[
            const SizedBox(height: 16),
            YearGoalsProgress(settings: _settings),
          ],
          const SizedBox(height: 4),
          SwitchListTile(
            key: const ValueKey('year-goal-show-on-today'),
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.yearGoalShowOnToday),
            subtitle: Text(l10n.yearGoalShowOnTodayHelp),
            value: _settings.showOnToday,
            onChanged: _settings.setShowOnToday,
          ),
        ],
      ),
    );
  }

  Widget _field(
    Key key,
    TextEditingController controller,
    String label,
    String hint,
    void Function(String) onChanged,
  ) => TextField(
    key: key,
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(labelText: label, hintText: hint),
    onChanged: onChanged,
  );
}
