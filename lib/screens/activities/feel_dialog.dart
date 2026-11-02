import 'package:flutter/material.dart';

import '../../data/wellness_actions.dart';
import '../../l10n/app_localizations.dart';

/// Lets the athlete set [date]'s fatigue and soreness (1-4, "1 good, 4
/// bad") and writes them to Intervals.icu via [WellnessActions.setFeel] —
/// the one dialog both the manual action and the new-activity prompt open.
Future<void> showFeelDialog(
  BuildContext context, {
  required String date,
  int? initialFatigue,
  int? initialSoreness,
  WellnessActions? actions,
}) => showDialog<void>(
  context: context,
  builder: (context) => _FeelDialog(
    date: date,
    initialFatigue: initialFatigue,
    initialSoreness: initialSoreness,
    actions: actions,
  ),
);

class _FeelDialog extends StatefulWidget {
  const _FeelDialog({
    required this.date,
    this.initialFatigue,
    this.initialSoreness,
    this.actions,
  });

  final String date;
  final int? initialFatigue;
  final int? initialSoreness;
  final WellnessActions? actions;

  @override
  State<_FeelDialog> createState() => _FeelDialogState();
}

class _FeelDialogState extends State<_FeelDialog> {
  late int _fatigue = widget.initialFatigue ?? 1;
  late int _soreness = widget.initialSoreness ?? 1;
  bool _saving = false;
  String? _error;

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await (widget.actions ?? WellnessActions()).setFeel(
        date: widget.date,
        fatigue: _fatigue,
        soreness: _soreness,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(l10n.feelDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.feelScaleHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.feelFatigueLabel),
          const SizedBox(height: 4),
          _ScaleButtons(
            value: _fatigue,
            onChanged: (v) => setState(() => _fatigue = v),
          ),
          const SizedBox(height: 16),
          Text(l10n.feelSorenessLabel),
          const SizedBox(height: 4),
          _ScaleButtons(
            value: _soreness,
            onChanged: (v) => setState(() => _soreness = v),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: scheme.error)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancelButton),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(l10n.feelSaveButton),
        ),
      ],
    );
  }
}

class _ScaleButtons extends StatelessWidget {
  const _ScaleButtons({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<int>(
    segments: const [
      ButtonSegment(value: 1, label: Text('1')),
      ButtonSegment(value: 2, label: Text('2')),
      ButtonSegment(value: 3, label: Text('3')),
      ButtonSegment(value: 4, label: Text('4')),
    ],
    selected: {value},
    onSelectionChanged: (selection) => onChanged(selection.first),
  );
}
