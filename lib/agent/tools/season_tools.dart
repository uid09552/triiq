import '../../data/repositories/activities_repository.dart';
import '../../evaluation/session_streams.dart';
import '../../season/brick_analysis.dart';
import '../../season/fitness_forecast.dart';
import '../../season/race_predictor.dart';
import '../../season/season_service.dart';
import '../../season/season_timeline.dart';
import '../../util/dates.dart';

/// Read-only season tools for the chat agent: the same fitness forecast,
/// race calendar, illness mode and race predictor the Season screen shows.
/// None of them writes anything.
class SeasonTools {
  SeasonTools({
    SeasonService? season,
    RaceInputsLoader? raceInputs,
    ActivitiesRepository? activities,
    ActivityStreamsRepository? streams,
  }) : _season = season ?? SeasonService(),
       _raceInputs = raceInputs ?? RaceInputsLoader(season: season),
       _activities = activities ?? ActivitiesRepository(),
       _streams = streams ?? ActivityStreamsRepository();

  final SeasonService _season;
  final RaceInputsLoader _raceInputs;
  final ActivitiesRepository _activities;
  final ActivityStreamsRepository _streams;

  Map<String, dynamic> _race(SeasonRace r, SeasonSnapshot s) {
    final day = s.onRaceDay(r);
    return {
      'name': r.name,
      'priority': r.priority,
      'date': isoDate(r.date),
      'weeks_to_go': weeksTo(s.today, r.date),
      if (day != null) ...{
        'forecast_ctl': double.parse(day.ctl.toStringAsFixed(1)),
        'forecast_form': double.parse(day.form.toStringAsFixed(1)),
        'form_reading': formBand(day.form).name,
      },
    };
  }

  /// CTL / ATL / form projected from the planned sessions, the race
  /// calendar with form on each race day, the block timeline and any
  /// conflicts.
  Future<Map<String, dynamic>> fitnessForecast() async {
    final s = await _season.load();
    if (!s.hasFitness) {
      return {'error': 'No fitness data cached yet; sync first.'};
    }
    final weekly = <Map<String, dynamic>>[];
    for (var i = 6; i < s.forecast.length && weekly.length < 26; i += 7) {
      weekly.add(s.forecast[i].toJson());
    }
    return {
      'today': isoDate(s.today),
      'current_ctl': s.startCtl,
      'current_atl': s.startAtl,
      'method':
          'Standard 42-day CTL / 7-day ATL model run over the planned '
          'sessions (days inside the plan with nothing planned count as rest; '
          'from assumed_from on, where nothing is planned, the athlete is '
          'assumed to hold their current fitness). Estimate only.',
      'assumed_from': s.assumedFrom == null ? null : isoDate(s.assumedFrom!),
      'weekly': weekly,
      'races': [for (final r in s.races) _race(r, s)],
      'blocks': [
        for (final b in s.blocks)
          {
            'kind': b.kind.name,
            'start': isoDate(b.start),
            'end': isoDate(b.end),
            if (b.race != null) 'race': b.race!.name,
          },
      ],
      'conflicts': [
        for (final c in s.conflicts)
          {
            'kind': c.kind.name,
            'race': c.first.name,
            if (c.second != null) 'other_race': c.second!.name,
          },
      ],
    };
  }

  /// Illness / injury mode: what is logged and the changes proposed (which
  /// the athlete applies on the Season screen — never here).
  Future<Map<String, dynamic>> healthStatus() async {
    final s = await _season.load(horizonDays: 60);
    final h = s.health;
    if (h == null) return {'status': 'healthy', 'logged': false};
    return {
      'status': h.phase.name,
      'kind': h.issue.kind.name,
      'since': isoDate(h.issue.start),
      'until': h.issue.end == null ? null : isoDate(h.issue.end!),
      'back_to_normal': h.issue.backToNormal(s.today) == null
          ? null
          : isoDate(h.issue.backToNormal(s.today)!),
      'proposed_changes': [
        for (final c in s.healthChanges)
          {
            'date': c.session.date,
            'session': c.session.name,
            'sport': c.session.type,
            'action': c.action.name,
            'reason': c.reason.name,
            if (c.toSport != null) 'instead': c.toSport,
            if (c.minutes != null) 'minutes': c.minutes,
            if (c.load != null) 'tss': c.load,
          },
      ],
      'note':
          'These are proposals; the athlete applies them from the Season '
          'screen. You cannot apply them.',
    };
  }

  /// Predicted finish time, pacing and fuelling for [args]`['race']`.
  Future<Map<String, dynamic>> racePrediction(Map<String, dynamic> args) async {
    final spec = RaceSpec.byId('${args['race'] ?? ''}');
    if (spec == null) {
      return {
        'error':
            'Unknown race. Use one of: '
            '${RaceSpec.presets.map((p) => p.id).join(', ')}',
      };
    }
    final day = DateTime.tryParse('${args['race_date'] ?? ''}');
    final inputs = await _raceInputs.load(
      raceDay: day,
      hot: args['hot'] == true,
    );
    final p = predictRace(spec, inputs);
    return {
      'race': spec.id,
      'complete': p.complete,
      'missing_legs': p.missing,
      if (p.legs.isNotEmpty) 'total_seconds': p.totalSeconds.round(),
      'slowdown_factor': double.parse(p.slowdown.toStringAsFixed(3)),
      'legs': [
        for (final l in p.legs)
          {
            'sport': l.sport,
            'seconds': l.seconds.round(),
            if (l.watts != null) 'target_watts': l.watts,
            if (l.sport == 'Run') 'pace_s_per_km': l.paceSecPerKm.round(),
            if (l.sport == 'Swim') 'pace_s_per_100m': l.pacePer100m.round(),
          },
      ],
      'fuelling': {
        'carbs_g_per_hour': p.fueling.carbsPerHour,
        'fluid_ml_per_hour': p.fueling.fluidPerHour,
        'sodium_mg_per_hour': p.fueling.sodiumPerHour,
        'total_carbs_g': p.fueling.totalCarbsG,
        'day_before_carbs_g': p.fueling.dayBeforeCarbsG,
      },
      'basis':
          'Riegel (exponent 1.06) from the best efforts on the pace curves; '
          'bike speed from the power curve with a race-intensity fraction '
          'and a physics model (default CdA 0.32); a CTL / race-day-form '
          'allowance on long races. A model estimate, not a promise.',
    };
  }

  /// Bricks (bike→run, swim→bike) in the last 60 days (or [args] `days`),
  /// with the transition and — when the run's stream is cached — how the
  /// legs settled. Never fetches streams.
  Future<Map<String, dynamic>> bricks(Map<String, dynamic> args) async {
    final days = ((args['days'] as num?)?.toInt() ?? 60).clamp(1, 365);
    final today = dateOnly(DateTime.now());
    final list = await _activities.getRange(
      isoDate(today.subtract(Duration(days: days))),
      isoDate(today),
    );
    final analyses = <BrickAnalysis>[];
    for (final b in findBricks(list)) {
      SessionStreams? streams;
      if (b.kind == BrickKind.bikeRun) {
        streams = await _streams.cached(b.second.id);
      }
      analyses.add(analyseBrick(b, streams));
    }
    final m = medians(analyses);
    return {
      'count': analyses.length,
      'median_settle_s': m.settle,
      'median_transition_s': m.transition,
      'bricks': [
        for (final a in analyses)
          {
            'date': a.brick.second.date,
            'first': a.brick.first.name,
            'second': a.brick.second.name,
            ...a.toJson(),
          },
      ],
    };
  }
}
