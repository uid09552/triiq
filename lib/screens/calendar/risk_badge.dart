import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../plan/risk_forecast.dart';

/// A planned day ahead flagged by the load forecast: a triangle for
/// caution, a filled circle with "!" for high — shape as well as colour,
/// so it reads in greyscale.
class RiskBadge extends StatelessWidget {
  const RiskBadge({super.key, required this.info, this.size = 10});

  final DayRiskInfo info;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final high = info.level == DayRisk.high;
    return Semantics(
      label: riskLabel(AppLocalizations.of(context)!, info),
      child: Icon(
        high ? Icons.error : Icons.warning_amber_rounded,
        key: ValueKey('risk-${info.level.name}'),
        size: size,
        color: high ? scheme.error : scheme.tertiary,
      ),
    );
  }
}

/// Why the day is flagged, in words.
String riskLabel(AppLocalizations l10n, DayRiskInfo info) {
  final reasons = [
    if (info.highRiskForm) l10n.riskFormLow(info.form.round().toString()),
    if (info.hardStreak >= 2) l10n.riskHardStreak(info.hardStreak),
  ];
  return '${info.level == DayRisk.high ? l10n.riskHigh : l10n.riskCaution}: '
      '${reasons.join('; ')}';
}
