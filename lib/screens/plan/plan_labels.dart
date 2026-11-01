import '../../l10n/app_localizations.dart';
import '../../plan/plan_actions.dart';
import '../../plan/plan_engine.dart';
import '../../plan/plan_models.dart';

String phaseLabel(AppLocalizations l10n, String phase) => switch (phase) {
  'build' => l10n.planPhaseBuild,
  'build_plus' => l10n.planPhaseBuildPlus,
  'peak' => l10n.planPhasePeak,
  'recovery' => l10n.planPhaseRecovery,
  'taper' => l10n.planPhaseTaper,
  'race' => l10n.planPhaseRace,
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

/// Why a plan change was refused, in words.
String refusalLabel(AppLocalizations l10n, ReplaceRefusedException e) =>
    switch (e.reason) {
      ReplaceRefusal.sentButCannotSend => l10n.replaceRefusedSent,
      ReplaceRefusal.notConnected => l10n.replaceRefusedOffline,
      ReplaceRefusal.missing => l10n.planChangeMissing,
      ReplaceRefusal.past => l10n.planChangePast,
      ReplaceRefusal.outsidePlan => l10n.planChangeOutsidePlan,
      ReplaceRefusal.invalid => e.detail ?? l10n.planChangeInvalid,
    };

/// A `PlanWeek.notes` code (from `PlanEngine`) in words.
String planNoteLabel(AppLocalizations l10n, String note) {
  if (note == PlanEngine.noteIntervalDay) return l10n.planNoteIntervalDay;
  if (note.startsWith('${PlanEngine.noteLongDay}:')) {
    final sport = note.substring(PlanEngine.noteLongDay.length + 1);
    return l10n.planNoteLongDay(sportLabel(l10n, sport));
  }
  return note;
}
