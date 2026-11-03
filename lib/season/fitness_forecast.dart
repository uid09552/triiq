import 'dart:math' as math;

import '../util/dates.dart';

/// One projected day of the fitness model.
class ForecastDay {
  const ForecastDay({
    required this.date,
    required this.load,
    required this.ctl,
    required this.atl,
  });

  final DateTime date;

  /// Planned TSS assumed for the day (0 for a rest day).
  final double load;
  final double ctl;
  final double atl;

  /// Form (TSB) as the app shows it everywhere: fitness minus fatigue.
  double get form => ctl - atl;

  Map<String, dynamic> toJson() => {
    'date': isoDate(date),
    'planned_load': load.round(),
    'ctl': double.parse(ctl.toStringAsFixed(1)),
    'atl': double.parse(atl.toStringAsFixed(1)),
    'form': double.parse(form.toStringAsFixed(1)),
  };
}

/// The standard exponentially weighted CTL (42 d) / ATL (7 d) model that
/// Intervals.icu uses, run forward over planned load.
///
/// [startCtl] / [startAtl] are the values at the end of [lastKnownDay]; the
/// projection begins the next day. [loadByDate] maps ISO dates to planned
/// TSS; days without an entry count as rest.
List<ForecastDay> forecastFitness({
  required double startCtl,
  required double startAtl,
  required DateTime lastKnownDay,
  required DateTime until,
  required Map<String, double> loadByDate,
  double scale = 1.0,
  int ctlDays = 42,
  int atlDays = 7,
}) {
  final ctlK = math.exp(-1 / ctlDays);
  final atlK = math.exp(-1 / atlDays);
  var ctl = startCtl;
  var atl = startAtl;
  final days = <ForecastDay>[];
  var day = dateOnly(lastKnownDay).add(const Duration(days: 1));
  final end = dateOnly(until);
  while (!day.isAfter(end)) {
    final load = (loadByDate[isoDate(day)] ?? 0) * scale;
    ctl = ctl * ctlK + load * (1 - ctlK);
    atl = atl * atlK + load * (1 - atlK);
    days.add(ForecastDay(date: day, load: load, ctl: ctl, atl: atl));
    day = day.add(const Duration(days: 1));
  }
  return days;
}

/// What the forecast says about one date.
ForecastDay? forecastOn(List<ForecastDay> days, DateTime date) {
  final key = isoDate(date);
  for (final d in days) {
    if (isoDate(d.date) == key) return d;
  }
  return null;
}

/// Plain-language reading of a race-day form value, with the usual
/// TSB bands: very negative is still loaded, around zero to +15 is fresh,
/// well above that means fitness has started to drop away.
enum FormBand { loaded, neutral, fresh, detrained }

FormBand formBand(double form) {
  if (form < -10) return FormBand.loaded;
  if (form < 5) return FormBand.neutral;
  if (form <= 25) return FormBand.fresh;
  return FormBand.detrained;
}

/// The day within [from]..[to] on which form peaks, or null when the range
/// has no projected days.
ForecastDay? peakForm(List<ForecastDay> days, DateTime from, DateTime to) {
  ForecastDay? best;
  for (final d in days) {
    if (d.date.isBefore(dateOnly(from)) || d.date.isAfter(dateOnly(to))) {
      continue;
    }
    if (best == null || d.form > best.form) best = d;
  }
  return best;
}
