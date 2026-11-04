import 'package:flutter/foundation.dart';

import '../data/models/local_event.dart';
import '../data/models/local_wellness.dart';
import '../data/planned_items.dart';
import '../data/repositories/wellness_repository.dart';
import '../evaluation/performance_curves.dart';
import '../plan/plan_models.dart';
import '../util/dates.dart';
import 'fitness_forecast.dart';
import 'illness_mode.dart';
import 'race_predictor.dart';
import 'season_timeline.dart';

/// Everything the Season screen shows, computed from the local cache.
class SeasonSnapshot {
  const SeasonSnapshot({
    required this.today,
    required this.startCtl,
    required this.startAtl,
    required this.forecast,
    required this.races,
    required this.blocks,
    required this.conflicts,
    required this.health,
    required this.healthChanges,
    required this.horizon,
    this.assumedFrom,
  });

  final DateTime today;

  /// Fitness at the last day with data; null when nothing is synced.
  final double? startCtl;
  final double? startAtl;
  final List<ForecastDay> forecast;
  final List<SeasonRace> races;
  final List<SeasonBlock> blocks;
  final List<SeasonConflict> conflicts;
  final ({HealthIssue issue, HealthPhase phase})? health;
  final List<ReturnChange> healthChanges;
  final DateTime horizon;

  /// First day with no planned load: from here the forecast assumes the
  /// athlete keeps training at their current fitness level. Null when the
  /// plan covers the whole horizon.
  final DateTime? assumedFrom;

  bool get hasFitness => startCtl != null && startAtl != null;

  /// Projected form on the day of [race].
  ForecastDay? onRaceDay(SeasonRace race) => forecastOn(forecast, race.date);
}

typedef PlannedLoader = Future<List<LocalEvent>> Function(
  String oldest,
  String newest,
);

/// Reads the cache and runs the season / forecast / illness rules.
class SeasonService {
  SeasonService({
    PlannedLoader? planned,
    WellnessRepository? wellness,
    GoalStore? goals,
    DateTime Function()? clock,
  }) : _planned = planned ?? PlannedItemsRepository().getRange,
       _wellness = wellness ?? WellnessRepository(),
       _goals = goals ?? GoalStore(),
       _clock = clock ?? DateTime.now;

  final PlannedLoader _planned;
  final WellnessRepository _wellness;
  final GoalStore _goals;
  final DateTime Function() _clock;

  /// How far ahead the forecast and the timeline look by default.
  static const defaultHorizonDays = 240;

  Future<SeasonSnapshot> load({int horizonDays = defaultHorizonDays}) async {
    final today = dateOnly(_clock());
    final horizon = today.add(Duration(days: horizonDays));

    final wellness = await _wellness.getRange(
      isoDate(today.subtract(const Duration(days: 30))),
      isoDate(today),
    );
    LocalWellness? last;
    for (final w in wellness) {
      if (w.ctl != null && w.atl != null &&
          (last == null || w.date.compareTo(last.date) > 0)) {
        last = w;
      }
    }

    final events = await _planned(
      isoDate(today.subtract(const Duration(days: 60))),
      isoDate(horizon),
    );

    final loadByDate = <String, double>{};
    DateTime? planEnd;
    final upcoming = <LocalEvent>[];
    for (final e in events) {
      final day = DateTime.tryParse(e.date);
      if (day == null) continue;
      if (e.isTraining && !dateOnly(day).isBefore(today)) {
        upcoming.add(e);
        // Races count at their planned load when they have one; a session
        // with a duration but no load counts as easy aerobic work.
        final secs = e.plannedTime ?? 0;
        final load =
            e.plannedLoad ?? (secs > 0 ? (secs / 3600 * easyLoadPerHour).round() : null);
        if (load != null) {
          loadByDate.update(e.date, (v) => v + load, ifAbsent: () => load.toDouble());
          if (planEnd == null || day.isAfter(planEnd)) planEnd = dateOnly(day);
        }
      }
    }

    final races = <SeasonRace>[];
    for (final e in events) {
      final r = raceFromEvent(
        category: e.category, date: e.date, name: e.name, type: e.type,
      );
      if (r != null) races.add(r);
    }
    try {
      final goal = await _goals.load();
      final d = goal?.eventDate;
      if (d != null && !dateOnly(d).isBefore(today) &&
          !races.any((r) => isoDate(r.date) == isoDate(d))) {
        races.add(
          SeasonRace(
            date: dateOnly(d),
            name: goal!.targetType,
            priority: 'A',
            sport: goal.sport,
          ),
        );
      }
    } catch (e) {
      debugPrint('SeasonService: no goal: $e');
    }
    races.sort((a, b) => a.date.compareTo(b.date));

    final health = currentHealthIssue(events, today);
    final windows = <({DateTime start, DateTime end})>[
      for (final e in events)
        if (e.category == 'SICK' || e.category == 'INJURED')
          if (DateTime.tryParse(e.date) case final s?)
            (
              start: dateOnly(s),
              end: DateTime.tryParse(e.raw['end_date_local'] as String? ?? '') ??
                  today,
            ),
    ];

    // Beyond the last planned load, assume the athlete holds their current
    // fitness (daily load = CTL) rather than resting for months.
    final assumeFrom = planEnd == null
        ? today
        : planEnd.add(const Duration(days: 1));
    final forecast = last == null
        ? const <ForecastDay>[]
        : forecastFitness(
            startCtl: last.ctl!,
            startAtl: last.atl!,
            lastKnownDay: DateTime.parse(last.date),
            until: horizon,
            loadByDate: loadByDate,
            assumeFrom: assumeFrom,
            assumedLoad: last.ctl!,
          );

    return SeasonSnapshot(
      today: today,
      startCtl: last?.ctl,
      startAtl: last?.atl,
      forecast: forecast,
      races: races,
      blocks: buildSeason(races, today),
      conflicts: findConflicts(
        [for (final r in races) if (!r.date.isBefore(today)) r],
        illness: windows,
      ),
      health: health,
      healthChanges: health == null
          ? const []
          : returnToTraining(
              issue: health.issue,
              planned: upcoming,
              today: today,
            ),
      horizon: horizon,
      assumedFrom: assumeFrom.isAfter(horizon) ? null : assumeFrom,
    );
  }
}

/// Builds [RaceInputs] from the cached curves and fitness for the Race
/// predictor screen.
class RaceInputsLoader {
  RaceInputsLoader({PerformanceCurvesRepository? curves, SeasonService? season})
    : _curves = curves ?? PerformanceCurvesRepository(),
      _season = season ?? SeasonService();

  final PerformanceCurvesRepository _curves;
  final SeasonService _season;

  Future<RaceInputs> load({DateTime? raceDay, bool hot = false}) async {
    Future<PerformanceCurves?> get(CurveSport s, CurveMetric m) async {
      try {
        return await _curves.load(s, m);
      } catch (e) {
        debugPrint('RaceInputsLoader: ${s.name}/${m.name}: $e');
        return _curves.cached(s, m);
      }
    }

    // Prefer the last 42 days (current form), then this season.
    CurvePeriod? best(PerformanceCurves? c) {
      if (c == null) return null;
      for (final id in const ['42d', 's0']) {
        final p = c.period(id);
        if (p != null && !p.isEmpty) return p;
      }
      return null;
    }

    List<({double metres, double seconds})> bests(PerformanceCurves? c) {
      final out = <({double metres, double seconds})>[];
      final seen = <double, double>{};
      for (final id in const ['s0', '42d']) {
        final p = c?.period(id);
        if (p == null) continue;
        for (final pt in p.points) {
          final cur = seen[pt.x];
          if (cur == null || pt.value < cur) seen[pt.x] = pt.value;
        }
      }
      seen.forEach((m, s) => out.add((metres: m, seconds: s)));
      return out;
    }

    final run = await get(CurveSport.run, CurveMetric.pace);
    final swim = await get(CurveSport.swim, CurveMetric.pace);
    final power = await get(CurveSport.ride, CurveMetric.power);
    final powerPeriod = best(power);
    final snapshot = await _season.load();
    double? form;
    if (raceDay != null && snapshot.forecast.isNotEmpty) {
      form = forecastOn(snapshot.forecast, raceDay)?.form;
    }
    final ftp = power?.period('s0')?.model?.ftp ?? powerPeriod?.model?.ftp;
    return RaceInputs(
      runBests: bests(run),
      swimBests: bests(swim),
      powerCurve: [
        if (powerPeriod != null)
          for (final p in _merge(power))
            (seconds: p.x, watts: p.value),
      ],
      ftp: ftp,
      ctl: snapshot.startCtl,
      raceDayForm: form,
      hot: hot,
    );
  }

  /// The best watts per duration across this season and the last 42 days.
  Iterable<CurvePoint> _merge(PerformanceCurves? c) sync* {
    final best = <double, CurvePoint>{};
    for (final id in const ['s0', '42d']) {
      for (final p in c?.period(id)?.points ?? const <CurvePoint>[]) {
        final cur = best[p.x];
        if (cur == null || p.value > cur.value) best[p.x] = p;
      }
    }
    yield* best.values;
  }
}
