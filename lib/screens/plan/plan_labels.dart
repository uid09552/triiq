import '../../l10n/app_localizations.dart';
import '../../plan/plan_models.dart';

String phaseLabel(AppLocalizations l10n, String phase) => switch (phase) {
  'build' => l10n.planPhaseBuild,
  'build_plus' => l10n.planPhaseBuildPlus,
  'peak' => l10n.planPhasePeak,
  'recovery' => l10n.planPhaseRecovery,
  _ => phase,
};

String? limitLabel(AppLocalizations l10n, WeekLimit limit) => switch (limit) {
  WeekLimit.none => null,
  WeekLimit.weeklyIncrease => l10n.planLimitedIncrease,
  WeekLimit.ctlRamp => l10n.planLimitedCtl,
  WeekLimit.hours => l10n.planLimitedHours,
};

String sportLabel(AppLocalizations l10n, String sport) => switch (sport) {
  'Run' => l10n.sportRun,
  'Ride' => l10n.sportRide,
  'Swim' => l10n.sportSwim,
  'Triathlon' => l10n.sportTriathlon,
  _ => sport,
};
