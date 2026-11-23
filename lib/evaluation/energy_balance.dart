import '../data/models/local_activity.dart';
import '../data/models/local_wellness.dart';
import '../util/dates.dart';

/// One day's energy as Intervals.icu holds it: what was eaten (wellness:
/// `kcalConsumed` and macros, usually from a connected food app) and what
/// training burned (activity `calories`; carbs used and taken in during a
/// session). Resting burn is not included: Intervals.icu does not record
/// it, and TriIQ does not estimate it.
class EnergyDay {
  const EnergyDay({
    required this.date,
    this.eatenKcal,
    this.carbsG,
    this.proteinG,
    this.fatG,
    this.trainingKcal = 0,
    this.carbsUsedG = 0,
    this.carbsTakenG = 0,
    this.sessions = 0,
  });

  final DateTime date;
  final int? eatenKcal;
  final double? carbsG, proteinG, fatG;
  final int trainingKcal;
  final int carbsUsedG;
  final int carbsTakenG;
  final int sessions;

  bool get hasIntake => eatenKcal != null && eatenKcal! > 0;
}

int? _int(Object? v) => v is num ? v.round() : null;
double? _double(Object? v) => v is num ? v.toDouble() : null;

/// Every day from [from] to [to] (inclusive), oldest first.
List<EnergyDay> energyDays(
  DateTime from,
  DateTime to,
  Iterable<LocalWellness> wellness,
  Iterable<LocalActivity> activities,
) {
  final byDay = {for (final w in wellness) w.date: w.raw};
  final acts = <String, List<Map<String, dynamic>>>{};
  for (final a in activities) {
    acts.putIfAbsent(a.date.substring(0, 10), () => []).add(a.raw);
  }
  final days = <EnergyDay>[];
  for (
    var d = dateOnly(from);
    !d.isAfter(dateOnly(to));
    d = DateTime(d.year, d.month, d.day + 1)
  ) {
    final key = isoDate(d);
    final w = byDay[key] ?? const <String, dynamic>{};
    final a = acts[key] ?? const [];
    days.add(
      EnergyDay(
        date: d,
        eatenKcal: _int(w['kcalConsumed']),
        carbsG: _double(w['carbohydrates']),
        proteinG: _double(w['protein']),
        fatG: _double(w['fatTotal']),
        trainingKcal: a.fold(0, (s, r) => s + (_int(r['calories']) ?? 0)),
        carbsUsedG: a.fold(0, (s, r) => s + (_int(r['carbs_used']) ?? 0)),
        carbsTakenG: a.fold(0, (s, r) => s + (_int(r['carbs_ingested']) ?? 0)),
        sessions: a.length,
      ),
    );
  }
  return days;
}

/// Averages over a run of [EnergyDay]s. Intake averages count only the
/// days something was logged, so a forgotten day does not read as fasting.
class EnergySummary {
  EnergySummary(this.days);

  final List<EnergyDay> days;

  Iterable<EnergyDay> get _logged => days.where((d) => d.hasIntake);

  int get loggedDays => _logged.length;
  int get trainingDays => days.where((d) => d.sessions > 0).length;

  double? _avg(Iterable<num> xs) {
    final l = xs.toList();
    return l.isEmpty ? null : l.reduce((a, b) => a + b) / l.length;
  }

  double? get avgEatenKcal => _avg(_logged.map((d) => d.eatenKcal!));
  double? get avgCarbsG =>
      _avg(_logged.where((d) => d.carbsG != null).map((d) => d.carbsG!));
  double? get avgProteinG =>
      _avg(_logged.where((d) => d.proteinG != null).map((d) => d.proteinG!));

  /// Training burn per day over the whole range (rest days count as 0).
  double? get avgTrainingKcal =>
      days.isEmpty ? null : _avg(days.map((d) => d.trainingKcal));

  int get totalTrainingKcal => days.fold(0, (s, d) => s + d.trainingKcal);
  int get totalCarbsUsedG => days.fold(0, (s, d) => s + d.carbsUsedG);
  int get totalCarbsTakenG => days.fold(0, (s, d) => s + d.carbsTakenG);

  /// Logged days where training burned more than half of what was eaten:
  /// worth a look, not a diagnosis.
  int get heavyBurnDays => _logged
      .where((d) => d.trainingKcal > 0 && d.trainingKcal > d.eatenKcal! / 2)
      .length;

  bool get isEmpty => loggedDays == 0 && totalTrainingKcal == 0;
}
