import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'weekly_targets_settings.dart';

/// Settings → Weekly targets: a weekly training-time goal (hours) per
/// sport, independent of any training plan, and whether its rings show on
/// Today. A field left blank means no target for that sport.
class WeeklyTargetsSection extends StatefulWidget {
  WeeklyTargetsSection({super.key, WeeklyTargetsSettings? settings})
    : settings = settings ?? WeeklyTargetsSettings.instance;

  final WeeklyTargetsSettings settings;

  @override
  State<WeeklyTargetsSection> createState() => _WeeklyTargetsSectionState();
}

class _WeeklyTargetsSectionState extends State<WeeklyTargetsSection> {
  late final TextEditingController _swim;
  late final TextEditingController _cycle;
  late final TextEditingController _run;
  bool _adoptedStoredValues = false;

  WeeklyTargetsSettings get _settings => widget.settings;

  @override
  void initState() {
    super.initState();
    _swim = TextEditingController();
    _cycle = TextEditingController();
    _run = TextEditingController();
    // The screen can open before the initial load resolves, so pick the
    // stored values up when they land — mirrors SettingsScreen's own
    // Claude/Ollama fields.
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
    if (!mounted || _adoptedStoredValues || !_settings.isLoaded) return;
    _adoptedStoredValues = true;
    setState(() {
      _swim.text = _settings.swimHours?.toString() ?? '';
      _cycle.text = _settings.cycleHours?.toString() ?? '';
      _run.text = _settings.runHours?.toString() ?? '';
    });
  }

  double? _parse(String text) {
    final trimmed = text.trim().replaceAll(',', '.');
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.weeklyTargetsSectionHelp,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          _hoursField(
            key: const ValueKey('weekly-target-swim'),
            controller: _swim,
            label: l10n.weeklyTargetHoursLabel(l10n.sportSwim),
            hint: l10n.noTargetSet,
            onChanged: (text) => _settings.setSwimHours(_parse(text)),
          ),
          const SizedBox(height: 12),
          _hoursField(
            key: const ValueKey('weekly-target-cycle'),
            controller: _cycle,
            label: l10n.weeklyTargetHoursLabel(l10n.sportRide),
            hint: l10n.noTargetSet,
            onChanged: (text) => _settings.setCycleHours(_parse(text)),
          ),
          const SizedBox(height: 12),
          _hoursField(
            key: const ValueKey('weekly-target-run'),
            controller: _run,
            label: l10n.weeklyTargetHoursLabel(l10n.sportRun),
            hint: l10n.noTargetSet,
            onChanged: (text) => _settings.setRunHours(_parse(text)),
          ),
          const SizedBox(height: 4),
          SwitchListTile(
            key: const ValueKey('weekly-target-show-on-today'),
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.weeklyTargetShowOnToday),
            subtitle: Text(l10n.weeklyTargetShowOnTodayHelp),
            value: _settings.showOnToday,
            onChanged: _settings.setShowOnToday,
          ),
        ],
      ),
    );
  }

  Widget _hoursField({
    required Key key,
    required TextEditingController controller,
    required String label,
    required String hint,
    required void Function(String) onChanged,
  }) => TextField(
    key: key,
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(labelText: label, hintText: hint),
    onChanged: onChanged,
  );
}
