import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../evaluation/period_stats.dart';
import '../l10n/app_localizations.dart';
import '../screens/activities/activity_icons.dart';

/// Number and sport formatting shared by everything that shows period or
/// year statistics (the Calendar header peek, the session year card and the
/// "this year" context lines), so they print the same figures the same way.

String statSportLabel(AppLocalizations l10n, StatSport sport) =>
    switch (sport) {
      StatSport.swim => l10n.sportSwim,
      StatSport.ride => l10n.sportRide,
      StatSport.run => l10n.sportRun,
      StatSport.strength => l10n.sportStrength,
      StatSport.other => l10n.calSportOther,
    };

/// A representative Intervals.icu type for [sport]: its icon and colour.
String statSportType(StatSport sport) => switch (sport) {
  StatSport.swim => 'Swim',
  StatSport.ride => 'Ride',
  StatSport.run => 'Run',
  StatSport.strength => 'WeightTraining',
  StatSport.other => 'Other',
};

IconData statSportIcon(StatSport sport) =>
    activityTypeIcon(statSportType(sport));

Color statSportColor(StatSport sport, ColorScheme scheme) =>
    sportColor(statSportType(sport), scheme);

/// Locale-aware figure formatting.
class StatFormat {
  StatFormat(String locale)
    : _int = NumberFormat('#,##0', locale),
      _one = NumberFormat('#,##0.0', locale),
      _locale = locale;

  factory StatFormat.of(BuildContext context) =>
      StatFormat(Localizations.localeOf(context).toString());

  final NumberFormat _int;
  final NumberFormat _one;
  final String _locale;

  String integer(num n) => _int.format(n);
  String hours(double h) => _one.format(h);
  String km(double km) => _int.format(km);
  String percent(double p) => _int.format(p.round().abs());

  /// "↑ 12 %", "↓ 4 %", "→ 0 %".
  String change(double pct) {
    final r = pct.round();
    if (r == 0) return '→ 0 %';
    return '${r > 0 ? '↑' : '↓'} ${_int.format(r.abs())} %';
  }

  String date(DateTime d) => DateFormat.yMMMd(_locale).format(d);
}

/// The "Based on synced data since …" note for [YearStats.partialSince].
String partialNote(AppLocalizations l10n, StatFormat f, String since) {
  final d = DateTime.tryParse(since);
  return l10n.psPartialNote(d == null ? since : f.date(d));
}

/// "3 sessions · 12.5 h · 142 km · 410 TSS"; distance and TSS only when
/// there are some.
String totalsLine(
  AppLocalizations l10n,
  StatFormat f,
  SportTotals t, {
  bool distance = true,
  bool tss = true,
}) => [
  l10n.sessionsCount(t.sessions),
  '${f.hours(t.hours)} h',
  if (distance && t.meters > 0) '${f.km(t.km)} km',
  if (tss && t.tss > 0) '${f.integer(t.tss)} TSS',
].join(' · ');
