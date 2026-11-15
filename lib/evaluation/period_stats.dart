import '../data/models/local_activity.dart';
import '../util/dates.dart';
import 'session_evaluator.dart' show sportFamily;

/// Pure maths behind the period statistics peek (Calendar header) and the
/// "this year" lines on session screens: totals per sport over a month or a
/// year, the same period of the year before, how complete the cache is, and
/// where one session ranks in its year. No I/O — [YearStatsService] feeds it
/// the cache.
///
/// Everything is keyed by the cache's `yyyy-MM-dd` local day strings, so a
/// session recorded at 23:50 local time stays on its own day whatever the
/// device's time zone.

/// The sport buckets the statistics use: the three triathlon sports, strength
/// & mobility (WeightTraining, Yoga, Pilates — counted by sessions and time
/// but kept out of the endurance total, as in the weekly review) and the rest.
enum StatSport { swim, ride, run, other, strength }

/// The order the sports are listed in.
const statSportOrder = [
  StatSport.swim,
  StatSport.ride,
  StatSport.run,
  StatSport.other,
  StatSport.strength,
];

/// Folds an Intervals.icu activity `type` into a [StatSport], the same family
/// the Calendar's sport filter uses.
StatSport statSportOf(String? type) => switch (sportFamily(type)) {
  'swim' => StatSport.swim,
  'ride' => StatSport.ride,
  'run' => StatSport.run,
  'strength' => StatSport.strength,
  _ => StatSport.other,
};

/// Whether [sport] counts towards the endurance total.
bool inEnduranceTotal(StatSport sport) => sport != StatSport.strength;

/// What the statistics need of one cached activity (the cache keeps a lot
/// more, which would only bloat an in-memory copy).
class StatRow {
  const StatRow({
    required this.id,
    required this.date,
    required this.sport,
    this.seconds = 0,
    this.meters = 0,
    this.tss = 0,
  });

  factory StatRow.of(LocalActivity a) => StatRow(
    id: a.id,
    date: a.date.length > 10 ? a.date.substring(0, 10) : a.date,
    sport: statSportOf(a.type),
    seconds: a.movingTime ?? 0,
    meters: a.distance ?? 0,
    tss: a.trainingLoad ?? 0,
  );

  final String id;

  /// `yyyy-MM-dd`.
  final String date;
  final StatSport sport;
  final int seconds;
  final double meters;
  final int tss;
}

List<StatRow> statRows(Iterable<LocalActivity> activities) => [
  for (final a in activities) StatRow.of(a),
];

/// Sessions, time, distance and load summed over some activities.
class SportTotals {
  const SportTotals({
    this.sessions = 0,
    this.seconds = 0,
    this.meters = 0,
    this.tss = 0,
  });

  static const empty = SportTotals();

  final int sessions;
  final int seconds;
  final double meters;
  final int tss;

  bool get isEmpty => sessions == 0;
  double get hours => seconds / 3600;
  double get km => meters / 1000;

  SportTotals plus(SportTotals o) => SportTotals(
    sessions: sessions + o.sessions,
    seconds: seconds + o.seconds,
    meters: meters + o.meters,
    tss: tss + o.tss,
  );

  SportTotals plusRow(StatRow r) => SportTotals(
    sessions: sessions + 1,
    seconds: seconds + r.seconds,
    meters: meters + r.meters,
    tss: tss + r.tss,
  );

  @override
  bool operator ==(Object other) =>
      other is SportTotals &&
      other.sessions == sessions &&
      other.seconds == seconds &&
      other.meters == meters &&
      other.tss == tss;

  @override
  int get hashCode => Object.hash(sessions, seconds, meters, tss);

  @override
  String toString() =>
      'SportTotals($sessions sessions, ${seconds}s, ${meters}m, $tss TSS)';
}

/// Totals per sport over [rows] dated [from]..[to] (ISO days, inclusive).
/// Sports without a session are left out.
Map<StatSport, SportTotals> totalsBySport(
  Iterable<StatRow> rows, {
  required String from,
  required String to,
}) {
  final out = <StatSport, SportTotals>{};
  for (final r in rows) {
    if (r.date.compareTo(from) < 0 || r.date.compareTo(to) > 0) continue;
    out[r.sport] = (out[r.sport] ?? SportTotals.empty).plusRow(r);
  }
  return out;
}

/// The endurance total: every sport but strength & mobility.
SportTotals enduranceTotal(Map<StatSport, SportTotals> bySport) {
  var total = SportTotals.empty;
  for (final e in bySport.entries) {
    if (inEnduranceTotal(e.key)) total = total.plus(e.value);
  }
  return total;
}

/// How much [now] changed against [before], in percent; null when there is
/// nothing to compare with (never an invented 100 % from zero).
double? changePercent(num now, num before) =>
    before <= 0 ? null : (now - before) / before * 100;

/// The day in [year] that corresponds to month [month] / day [day] —
/// 29 February falls back to 28 February in a year without one.
DateTime sameDayInYear(int year, int month, int day) {
  final lastOfMonth = DateTime(year, month + 1, 0).day;
  return DateTime(year, month, day > lastOfMonth ? lastOfMonth : day);
}

/// What the sync state says is in the cache: the oldest and newest day
/// fetched so far (`SyncStateRepository`, scope `activities`).
class SyncCoverage {
  const SyncCoverage({this.oldest, this.newest});

  /// `yyyy-MM-dd`; null when nothing was ever synced.
  final String? oldest;
  final String? newest;

  bool get isKnown => oldest != null;

  /// Whether the cache reaches back to [day].
  bool coversFrom(String day) => oldest != null && oldest!.compareTo(day) <= 0;
}

/// A year per sport, up to a cut-off day, and the same period of the year
/// before.
class YearStats {
  const YearStats({
    required this.year,
    required this.from,
    required this.to,
    required this.totals,
    this.lastYear,
    this.lastYearFrom,
    this.lastYearTo,
    this.partialSince,
  });

  final int year;

  /// The period the totals cover (`yyyy-MM-dd`): 1 January to today for the
  /// current year, the whole year for a past one. Empty for a future year.
  final String from;
  final String to;
  final Map<StatSport, SportTotals> totals;

  /// The same period one year earlier. Null when the cache does not reach
  /// back that far (or nothing is known about it): the comparison is then
  /// left out rather than made against a misleadingly low figure.
  final Map<StatSport, SportTotals>? lastYear;
  final String? lastYearFrom;
  final String? lastYearTo;

  /// Set when the cache starts after 1 January: the day it starts on. The
  /// totals are then only "since" that day.
  final String? partialSince;

  bool get isPartial => partialSince != null;
  bool get isEmpty => totals.values.every((t) => t.isEmpty);

  SportTotals of(StatSport sport) => totals[sport] ?? SportTotals.empty;
  SportTotals get total => enduranceTotal(totals);

  SportTotals? lastOf(StatSport sport) =>
      lastYear == null ? null : (lastYear![sport] ?? SportTotals.empty);
  SportTotals? get lastTotal =>
      lastYear == null ? null : enduranceTotal(lastYear!);

  /// Sports with a session this year or last, in display order.
  List<StatSport> get sports => [
    for (final s in statSportOrder)
      if (!of(s).isEmpty || !(lastOf(s)?.isEmpty ?? true)) s,
  ];
}

/// [YearStats] for [year] from [rows] as of [today].
///
/// [coverage] says how far back the cache reaches: without it nothing is
/// known about completeness, so no comparison is made; with a start after
/// 1 January the result is flagged [YearStats.partialSince].
YearStats computeYearStats(
  Iterable<StatRow> rows, {
  required int year,
  required DateTime today,
  SyncCoverage? coverage,
}) {
  final now = dateOnly(today);
  final from = '${year.toString().padLeft(4, '0')}-01-01';
  if (year > now.year) {
    return YearStats(year: year, from: from, to: from, totals: const {});
  }
  final cutoff = year == now.year ? now : DateTime(year, 12, 31);
  final to = isoDate(cutoff);
  final totals = totalsBySport(rows, from: from, to: to);

  final partial =
      coverage != null &&
      coverage.oldest != null &&
      coverage.oldest!.compareTo(from) > 0;

  final lastFrom = '${(year - 1).toString().padLeft(4, '0')}-01-01';
  final lastTo = isoDate(sameDayInYear(year - 1, cutoff.month, cutoff.day));
  final comparable = coverage != null && coverage.coversFrom(lastFrom);

  return YearStats(
    year: year,
    from: from,
    to: to,
    totals: totals,
    lastYear: comparable
        ? totalsBySport(rows, from: lastFrom, to: lastTo)
        : null,
    lastYearFrom: lastFrom,
    lastYearTo: lastTo,
    partialSince: partial ? coverage.oldest : null,
  );
}

/// What one session adds up to in its year.
class SessionYearContext {
  const SessionYearContext({
    required this.sport,
    required this.year,
    required this.total,
    this.lastYear,
    this.shareByDistance = false,
    this.sharePercent,
    this.rank,
    this.rankOf = 0,
    this.rankByDistance = false,
    this.partialSince,
  });

  final StatSport sport;
  final YearStats year;

  /// The sport's year total (to the cut-off day).
  final SportTotals total;

  /// The same period last year; null when it is not comparable.
  final SportTotals? lastYear;

  /// Whether [sharePercent] is of the distance (else of the time).
  final bool shareByDistance;
  final double? sharePercent;

  /// 1-based place among the year's sessions of the sport, by distance
  /// ([rankByDistance]) or by TSS; null when it cannot be told.
  final int? rank;
  final int rankOf;
  final bool rankByDistance;
  final String? partialSince;

  /// Change in time against the same period last year.
  double? get hoursChange =>
      lastYear == null ? null : changePercent(total.seconds, lastYear!.seconds);
}

/// Where [row] stands in [stats]' year: its share of the sport's total and
/// its rank among the year's sessions of that sport. Null when [row] is
/// outside the period the stats cover. [rows] are the year's rows (anything
/// else is ignored).
SessionYearContext? sessionYearContext(
  StatRow row,
  YearStats stats,
  Iterable<StatRow> rows,
) {
  if (row.date.compareTo(stats.from) < 0 || row.date.compareTo(stats.to) > 0) {
    return null;
  }
  final sport = row.sport;
  final total = stats.of(sport);
  final byDistance = sport != StatSport.strength && row.meters > 0;
  double? share;
  if (byDistance && total.meters > 0) {
    share = row.meters / total.meters * 100;
  } else if (row.seconds > 0 && total.seconds > 0) {
    share = row.seconds / total.seconds * 100;
  }
  if (share != null && share > 100) share = 100;

  int? rank;
  var rankOf = 0;
  var rankByDistance = false;
  if (sport != StatSport.strength) {
    rankByDistance = row.meters > 0;
    double metric(StatRow r) => rankByDistance ? r.meters : r.tss.toDouble();
    if (metric(row) > 0) {
      final mine = metric(row);
      var ahead = 0;
      for (final r in rows) {
        if (r.sport != sport || r.id == row.id) continue;
        if (r.date.compareTo(stats.from) < 0 ||
            r.date.compareTo(stats.to) > 0) {
          continue;
        }
        final m = metric(r);
        if (m <= 0) continue;
        rankOf++;
        if (m > mine) ahead++;
      }
      rankOf++; // the session itself
      rank = ahead + 1;
    }
  }

  return SessionYearContext(
    sport: sport,
    year: stats,
    total: total,
    lastYear: stats.lastOf(sport),
    shareByDistance: byDistance && total.meters > 0,
    sharePercent: share,
    rank: rank,
    rankOf: rankOf,
    rankByDistance: rankByDistance,
    partialSince: stats.partialSince,
  );
}

/// The year of a `yyyy-MM-dd` string, or null.
int? yearOfDay(String day) =>
    day.length >= 4 ? int.tryParse(day.substring(0, 4)) : null;
