import '../data/models/local_event.dart';
import '../evaluation/form_zone.dart';
import '../screens/calendar/day_events.dart' show isRaceCategory;
import '../season/fitness_forecast.dart';
import '../util/dates.dart';

/// How a planned day ahead looks before it happens (TrainerRoad's "Red
/// Light Green Light" idea, built from TriIQ's own forecast). Not a
/// readiness score: it flags load, not how the athlete will feel.
enum DayRisk {
  /// Two hard days in a row: worth a look.
  caution,

  /// Projected form in the high-risk zone, or three hard days in a row.
  high,
}

/// Why a day is flagged.
class DayRiskInfo {
  const DayRiskInfo({
    required this.level,
    required this.form,
    required this.hardStreak,
    required this.highRiskForm,
  });

  final DayRisk level;

  /// Projected CTL − ATL for the day.
  final double form;

  /// Hard days in a row ending on this day (0 when the day is not hard).
  final int hardStreak;

  /// The projected form is in the high-risk zone.
  final bool highRiskForm;
}

/// A planned session hard enough to count: a race, or roughly IF ≥ 0.84
/// (70 TSS per hour and up).
bool isHardEvent(LocalEvent e) {
  if (!e.isTraining) return false;
  if (isRaceCategory(e.category)) return true;
  final load = e.plannedLoad ?? 0;
  final secs = e.plannedTime ?? 0;
  if (load <= 0 || secs <= 0) return false;
  return load / (secs / 3600) >= 70;
}

/// Flags for every day after [today] up to [until], from the fitness model
/// run over the planned load ([plannedByDate], ISO dates). [ctl] / [atl]
/// are today's values. Days without a flag are left out.
Map<String, DayRiskInfo> forecastRisk({
  required double ctl,
  required double atl,
  required DateTime today,
  required DateTime until,
  required Map<String, List<LocalEvent>> plannedByDate,
}) {
  final loads = <String, double>{
    for (final e in plannedByDate.entries)
      e.key: e.value
          .where((x) => x.isTraining)
          .fold<double>(0, (s, x) => s + (x.plannedLoad ?? 0)),
  };
  bool hardOn(DateTime d) =>
      (plannedByDate[isoDate(d)] ?? const []).any(isHardEvent);

  final days = forecastFitness(
    startCtl: ctl,
    startAtl: atl,
    lastKnownDay: dateOnly(today),
    until: until,
    loadByDate: loads,
  );
  final out = <String, DayRiskInfo>{};
  for (final f in days) {
    var streak = 0;
    for (var d = f.date; streak < 7 && hardOn(d); streak++) {
      d = DateTime(d.year, d.month, d.day - 1);
    }
    final zone = formZoneOf(f.ctl, f.atl);
    final highForm =
        zone == FormZone.highRisk && loads[isoDate(f.date)] != null;
    final level = highForm || streak >= 3
        ? DayRisk.high
        : streak == 2
        ? DayRisk.caution
        : null;
    if (level != null) {
      out[isoDate(f.date)] = DayRiskInfo(
        level: level,
        form: f.form,
        hardStreak: streak,
        highRiskForm: highForm,
      );
    }
  }
  return out;
}
