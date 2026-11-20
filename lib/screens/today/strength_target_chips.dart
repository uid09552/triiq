import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../plan/bodyweight_strength.dart';

/// Which sports a strength session should carry over to: one chip per
/// sport, several allowed, never none (the last one can't be switched off).
class StrengthTargetChips extends StatelessWidget {
  const StrengthTargetChips({
    super.key,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  final Set<StrengthTarget> selected;
  final ValueChanged<Set<StrengthTarget>> onChanged;
  final bool enabled;

  static String label(AppLocalizations l10n, StrengthTarget t) => switch (t) {
    StrengthTarget.swim => l10n.sportSwim,
    StrengthTarget.ride => l10n.sportRide,
    StrengthTarget.run => l10n.sportRun,
  };

  static IconData icon(StrengthTarget t) => switch (t) {
    StrengthTarget.swim => Icons.pool_outlined,
    StrengthTarget.ride => Icons.directions_bike_outlined,
    StrengthTarget.run => Icons.directions_run_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final t in StrengthTarget.values)
          FilterChip(
            key: ValueKey('strength-target-${t.name}'),
            avatar: Icon(icon(t), size: 18),
            label: Text(label(l10n, t)),
            selected: selected.contains(t),
            onSelected: !enabled
                ? null
                : (on) {
                    final next = {...selected};
                    if (on) {
                      next.add(t);
                    } else if (next.length > 1) {
                      next.remove(t);
                    } else {
                      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                        SnackBar(content: Text(l10n.strengthPickOne)),
                      );
                      return;
                    }
                    onChanged(next);
                  },
          ),
      ],
    );
  }
}
