/// Where today's form sits, as a word: the zones Intervals.icu colours its
/// Form chart with, applied to form as a percentage of fitness
/// (`(CTL − ATL) / CTL`), so they also fit an athlete with a low CTL.
///
/// A rough reading of recent load against what you have built up, not a
/// diagnosis — "high risk" asks for care, it does not say anything is wrong.
enum FormZone {
  /// Well above +20 %: much less recent load than usual (a long rest).
  transition,

  /// +5 to +20 %: rested.
  fresh,

  /// −10 to +5 %: neither fresh nor loaded.
  grey,

  /// −30 to −10 %: where fitness is usually built.
  optimal,

  /// Below −30 %: heavy recent load against your base.
  highRisk,
}

/// The state for [ctl] and [atl], or `null` without a usable CTL.
FormZone? formZoneOf(double? ctl, double? atl) {
  if (ctl == null || atl == null || ctl <= 0) return null;
  final percent = (ctl - atl) / ctl * 100;
  if (percent > 20) return FormZone.transition;
  if (percent > 5) return FormZone.fresh;
  if (percent > -10) return FormZone.grey;
  if (percent > -30) return FormZone.optimal;
  return FormZone.highRisk;
}
