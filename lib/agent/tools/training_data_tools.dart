import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:langchain_core/tools.dart';

import '../../data/intervals_session.dart';
import '../../data/models/local_activity.dart';
import '../../data/models/local_event.dart';
import '../../data/models/local_wellness.dart';
import '../../data/planned_items.dart';
import '../../data/repositories/activities_repository.dart';
import '../../data/repositories/events_repository.dart';
import '../../data/repositories/plans_repository.dart';
import '../../data/repositories/knowledge_library_repository.dart';
import '../../data/repositories/sync_state_repository.dart';
import '../../data/threshold_suggestions_service.dart';
import '../../data/repositories/wellness_repository.dart';
import '../../evaluation/readiness.dart';
import '../../evaluation/readiness_service.dart';
import '../../season/race_predictor.dart' show RaceSpec;
import '../../plan/adaptation_service.dart';
import '../../data/sync/sync_service.dart';
import '../../evaluation/intensity.dart';
import '../../evaluation/performance_curves.dart';
import '../../plan/knowledge.dart';
import '../../plan/plan_engine.dart';
import '../../plan/plan_inputs.dart';
import '../../plan/plan_models.dart';
import '../../plan/plan_service.dart';
import '../../util/dates.dart';
import '../knowledge_sections.dart';
import '../plan_proposals.dart';
import '../agent_memory.dart';
import 'plan_assistant_tools.dart';
import 'season_tools.dart';

/// The tools the training agent can call.
///
/// Every read goes through the local SQLite cache rather than Intervals.icu,
/// so a question costs no API calls and works offline; `sync_from_intervals`
/// goes out to the network when the agent decides the cache is missing what
/// it needs, and `get_performance_curve` fetches curves only when none are
/// cached or a newer activity made them stale.
///
/// Tool results are JSON strings. Nulls and empty collections are stripped
/// (see [_compact]) — with ~180 possible fields per activity, sending the
/// empty ones would cost more context than the data itself.
class TrainingDataTools {
  TrainingDataTools({
    IntervalsSession? session,
    WellnessRepository? wellnessRepository,
    ActivitiesRepository? activitiesRepository,
    EventsRepository? eventsRepository,
    PlansRepository? plansRepository,
    SyncStateRepository? syncStateRepository,
    SyncService? syncService,
    DateTime Function()? clock,
    Future<String> Function()? loadTrainingGuidance,
    KnowledgeLibraryRepository? knowledgeLibraryRepository,
    KnowledgeRepository? knowledgeRepository,
    GoalStore? goalStore,
    PlanInputsLoader? planInputs,
    PlanProposals? proposals,
    PerformanceCurvesRepository? performanceCurves,
    ReadinessService? readinessService,
    ThresholdSuggestionsService? thresholdSuggestions,
    AgentMemoryStore? memory,
  }) : _memory = memory ?? AgentMemoryStore.instance,
       _readinessOverride = readinessService,
       _thresholdSuggestions =
           thresholdSuggestions ?? ThresholdSuggestionsService(),
       _performanceCurves = performanceCurves ?? PerformanceCurvesRepository(),
       _knowledge = knowledgeRepository ?? KnowledgeRepository(),
       _goalStore = goalStore ?? GoalStore(),
       _planInputs =
           planInputs ??
           PlanInputsLoader(
             activities: activitiesRepository,
             wellness: wellnessRepository,
             syncState: syncStateRepository,
           ),
       _session = session ?? IntervalsSession.instance,
       _wellnessRepository = wellnessRepository ?? WellnessRepository(),
       _activitiesRepository = activitiesRepository ?? ActivitiesRepository(),
       _eventsRepository = PlannedItemsRepository(
         events: eventsRepository ?? EventsRepository(),
         plans: plansRepository ?? PlansRepository(),
       ),
       _plans = plansRepository ?? PlansRepository(),
       _proposals = proposals ?? PlanProposals.instance,
       _syncStateRepository = syncStateRepository ?? SyncStateRepository(),
       _syncService = syncService ?? SyncService(),
       _clock = clock ?? DateTime.now,
       _loadTrainingGuidance =
           loadTrainingGuidance ?? _loadTrainingGuidanceAsset,
       _knowledgeLibrary =
           knowledgeLibraryRepository ?? KnowledgeLibraryRepository();

  final AgentMemoryStore _memory;
  final IntervalsSession _session;
  final PerformanceCurvesRepository _performanceCurves;
  final WellnessRepository _wellnessRepository;
  final ActivitiesRepository _activitiesRepository;

  /// Planned items: the TriIQ plan plus, when copied, Intervals.icu events.
  final PlannedItemsRepository _eventsRepository;
  final SyncStateRepository _syncStateRepository;
  final SyncService _syncService;
  final DateTime Function() _clock;
  final Future<String> Function() _loadTrainingGuidance;
  final KnowledgeLibraryRepository _knowledgeLibrary;
  final ThresholdSuggestionsService _thresholdSuggestions;
  final KnowledgeRepository _knowledge;
  final GoalStore _goalStore;
  final PlanInputsLoader _planInputs;
  final PlansRepository _plans;
  final PlanProposals _proposals;
  final ReadinessService? _readinessOverride;

  /// Today's readiness by the same rules as the Today tile.
  late final ReadinessService _readiness =
      _readinessOverride ??
      ReadinessService(
        wellness: _wellnessRepository,
        knowledge: _knowledge,
        clock: _clock,
      );

  late final PlanService _planService = PlanService(
    knowledge: _knowledge,
    inputs: _planInputs,
    plans: _plans,
    activities: _activitiesRepository,
    goals: _goalStore,
  );

  /// Fitness forecast, race calendar, illness mode, race predictor, bricks.
  late final SeasonTools _seasonTools = SeasonTools(
    activities: _activitiesRepository,
  );

  /// Reading the plan and making proposals on it (no writes).
  late final PlanAssistantTools _planTools = PlanAssistantTools(
    service: _planService,
    proposals: _proposals,
    clock: _clock,
  );

  /// The same adaptation rules Today runs, registering the same keyed
  /// proposals — so a card in the chat and on Today is one card.
  late final AdaptationService _adaptation = AdaptationService(
    plans: _plans,
    goals: _goalStore,
    activities: _activitiesRepository,
    readiness: _readiness,
    planService: _planService,
    proposals: _proposals,
    clock: _clock,
  );

  /// Scopes tracked by `SyncStateRepository`, in the order they're reported.
  static const _syncScopes = ['activities', 'wellness', 'events'];

  /// Guardrails on how much a single tool call can pull back. They exist to
  /// protect the context window, not the database: a year of activities is
  /// a trivial query and a ruinous prompt.
  static const _maxMetricDays = 400;
  static const _maxActivityDays = 400;
  static const _maxSummaryDays = 1500;
  static const _defaultActivityLimit = 50;
  static const _maxActivityLimit = 200;

  /// How zone times are folded into the three-domain model the training
  /// reference uses. Reported alongside any intensity figure so the model
  /// can qualify an answer built on it.
  static const intensityModelNote =
      'Zone times are folded into three domains: low = the two easiest '
      'zones (below the first threshold), moderate = the next two '
      '(threshold domain), high = everything above. Power zone times are '
      'preferred, then heart-rate, then pace.';

  /// Builds the tool set. Handed to the chat model as its tool specs and
  /// used by the agent loop to dispatch calls by name.
  List<Tool> build() => [
    _tool(
      name: 'get_athlete_context',
      description:
          'Today\'s date, the athlete identity, which date ranges are cached '
          'locally, and the athlete\'s current thresholds (FTP, LTHR, max HR, '
          'threshold pace, zone boundaries) per sport as recorded on their '
          'most recent activity. Call this first — it is cheap and it stops '
          'you guessing the date or the thresholds.',
      schema: const {'type': 'object', 'properties': <String, dynamic>{}},
      run: (_) => _athleteContext(),
    ),
    _tool(
      name: 'get_daily_metrics',
      description:
          'Day-by-day load and wellness: CTL, ATL, TSB, ramp rate, resting '
          'HR, HRV, sleep, weight and the subjective scores the athlete logs '
          '(fatigue, soreness, stress, mood, motivation). Use for readiness, '
          'recovery and fitness-trend questions. Max '
          '$_maxMetricDays days per call.',
      schema: _rangeSchema(),
      run: (args) => _dailyMetrics(args),
    ),
    _tool(
      name: 'get_plan_adjustments',
      description:
          'Where the athlete has drifted from the saved plan and what the '
          'app suggests: missed sessions this week (move later in the week '
          'or let go), a just-finished week well off its target load (adjust '
          "next week), and today's hard session on a low-readiness day "
          '(swap or move). Each comes back as a **proposal** the athlete '
          'applies or dismisses — the same cards Today shows. Call it when '
          'the athlete says they missed a session or asks what to do about '
          'the rest of the week. Never applies anything.',
      schema: const {'type': 'object', 'properties': <String, dynamic>{}},
      run: (_) => _planAdjustments(),
    ),
    _tool(
      name: 'get_fitness_forecast',
      description:
          'CTL / ATL / form projected forward from the planned sessions '
          '(days with nothing planned count as rest), the race calendar '
          'with the forecast form on each race day, the season blocks '
          '(build, taper, race, recovery) and race-calendar conflicts. Use '
          'for "what will my form be on race day" and season-planning '
          'questions. Read-only; an estimate.',
      schema: const {'type': 'object', 'properties': <String, dynamic>{}},
      run: (_) => _seasonTools.fitnessForecast(),
    ),
    _tool(
      name: 'get_health_status',
      description:
          'Whether the athlete is logged as sick or injured (Intervals.icu '
          'SICK / INJURED events), the return-to-training ramp, and the '
          'changes proposed to the planned sessions (rest, easier, '
          'cross-training). The athlete applies them on the Season screen; '
          'you cannot. Read-only.',
      schema: const {'type': 'object', 'properties': <String, dynamic>{}},
      run: (_) => _seasonTools.healthStatus(),
    ),
    _tool(
      name: 'get_race_prediction',
      description:
          'Predicted finish time, per-leg pacing targets and a fuelling '
          'plan for a race, from the athlete\'s power and pace curves, CTL '
          'and forecast race-day form. race is one of: '
          '${RaceSpec.presets.map((p) => p.id).join(', ')}. Optional '
          'race_date (YYYY-MM-DD) to include the forecast form, hot (bool). '
          'Legs without data come back in missing_legs. A model estimate — '
          'say so. Read-only.',
      schema: {
        'type': 'object',
        'properties': {
          'race': {'type': 'string'},
          'race_date': {'type': 'string'},
          'hot': {'type': 'boolean'},
        },
        'required': ['race'],
      },
      run: (args) => _seasonTools.racePrediction(args),
    ),
    _tool(
      name: 'get_bricks',
      description:
          'Brick sessions (bike then run, swim then bike) from recent '
          'days: the transition time and, where the run stream is cached, '
          'how quickly the legs settled and whether the first 10 minutes '
          'were slower or costlier than the rest. Optional days (default '
          '60). Read-only.',
      schema: {
        'type': 'object',
        'properties': {
          'days': {'type': 'integer'},
        },
      },
      run: (args) => _seasonTools.bricks(args),
    ),
    _tool(
      name: 'remember_preference',
      description:
          'Saves one standing preference or constraint the athlete just '
          'stated or asked you to remember — e.g. "No hard sessions on '
          'Fridays", "Swim only in the mornings", "Right knee: no '
          'downhill running". Call it only when the athlete says so '
          '("remember that…", "I never…", "always…"); never to store '
          'facts you can read from their data or things you guessed. One '
          'short sentence in their words. It is listed under More → '
          'Trainer memory where they can delete it, and you must tell '
          'them you saved it.',
      schema: {
        'type': 'object',
        'properties': {
          'text': {
            'type': 'string',
            'description': 'The preference, one short sentence.',
          },
        },
        'required': ['text'],
      },
      run: (args) async {
        try {
          final item = await _memory.add(
            '${args['text'] ?? ''}',
            fromAgent: true,
          );
          if (item == null) return {'error': 'Nothing to remember.'};
          return {'saved': true, 'id': item.id, 'text': item.text};
        } on MemoryFullException catch (e) {
          return {'error': '$e'};
        }
      },
    ),
    _tool(
      name: 'forget_preference',
      description:
          'Removes a remembered preference by its id (shown in the '
          '"remember" context block). Call it when the athlete says a '
          'preference no longer applies, and tell them you removed it.',
      schema: {
        'type': 'object',
        'properties': {
          'id': {'type': 'string'},
        },
        'required': ['id'],
      },
      run: (args) async {
        final removed = await _memory.remove('${args['id'] ?? ''}');
        return removed
            ? {'removed': true}
            : {'error': 'No remembered preference with that id.'};
      },
    ),
    _tool(
      name: 'get_readiness',
      description:
          "Today's readiness status (ready / caution / back_off), computed "
          "on the device from today's HRV, resting HR, sleep, form and the "
          "logged fatigue/soreness against the athlete's own 60-day "
          'baselines — the same result as the readiness tile on Today. Each '
          'signal comes with its value, baseline and rating, plus whether '
          "today's wearable data has arrived. Check it before advising on a "
          'hard session today. Read-only.',
      schema: const {'type': 'object', 'properties': <String, dynamic>{}},
      run: (_) => _readinessToday(),
    ),
    _tool(
      name: 'get_threshold_suggestions',
      description:
          "Current threshold suggestions: a candidate ride FTP, run or swim "
          "threshold pace derived from the athlete's performance curves, "
          'each with the current and candidate value, percent change, '
          'direction and the data it came from. Read-only — this tool never '
          "writes a threshold. When the athlete asks about one, explain it "
          "from these figures and point them to Statistics → Performance to "
          'review and apply it there; you cannot apply or dismiss it '
          'yourself.',
      schema: const {'type': 'object', 'properties': <String, dynamic>{}},
      run: (_) => _thresholdSuggestionsTool(),
    ),
    _tool(
      name: 'get_activities',
      description:
          'Completed sessions in a date range: sport, duration, distance, '
          'training load, intensity factor, average/max HR, average power, '
          'decoupling, RPE and time in each intensity domain. Use for '
          'questions about specific workouts. For trends or weekly totals '
          'use get_training_summary instead — it is far cheaper.',
      schema: {
        'type': 'object',
        'properties': {
          ..._rangeProperties(),
          'sport': {
            'type': 'string',
            'description':
                'Optional Intervals.icu activity type to filter on, e.g. '
                '"Run", "Ride", "Swim", "VirtualRide". Case-insensitive.',
          },
          'limit': {
            'type': 'integer',
            'description':
                'Maximum activities to return, newest first. Defaults to '
                '$_defaultActivityLimit, capped at $_maxActivityLimit.',
          },
        },
        'required': ['start_date', 'end_date'],
      },
      run: (args) => _activities(args),
    ),
    _tool(
      name: 'get_planned_workouts',
      description:
          'Planned calendar entries in a date range: prescribed workouts, '
          'races, notes, holidays and illness markers, with their target '
          'load, duration and description. This is what the athlete (or '
          'their coach) intends to do, as opposed to what they did.',
      schema: _rangeSchema(),
      run: (args) => _plannedWorkouts(args),
    ),
    _tool(
      name: 'get_training_summary',
      description:
          'Aggregated training over a range, bucketed by week or month: '
          'completed vs planned load, session count, duration and distance, '
          'a breakdown per sport, the low/moderate/high intensity split, and '
          'CTL/ATL/TSB at the end of each bucket. The right tool for "how has '
          'my training been", 80/20 checks and load progression. Max '
          '$_maxSummaryDays days per call.',
      schema: {
        'type': 'object',
        'properties': {
          ..._rangeProperties(),
          'group_by': {
            'type': 'string',
            'enum': ['week', 'month'],
            'description': 'Bucket size. Defaults to "week".',
          },
        },
        'required': ['start_date', 'end_date'],
      },
      run: (args) => _trainingSummary(args),
    ),
    _tool(
      name: 'get_training_guidance',
      description:
          'Searches the athlete\'s own training reference (80/20 intensity '
          'distribution, TSS/CTL/ATL/TSB, thresholds, recovery, tapering, '
          'race pacing) and returns the matching sections verbatim. Consult '
          'it before giving a recommendation. Call with an empty topic to '
          'list the available sections.',
      schema: const {
        'type': 'object',
        'properties': {
          'topic': {
            'type': 'string',
            'description':
                'What to look up, e.g. "ramp rate", "recovery week", '
                '"aerobic decoupling", "taper". Empty lists all sections.',
          },
        },
      },
      run: (args) => _trainingGuidance(args),
    ),
    _tool(
      name: 'generate_training_plan',
      description:
          'Builds a training plan of 2-16 weeks with the plan engine: a '
          'proposed weekly load that ramps steadily from the athlete\'s '
          'recent completed load (default max +10%/week, held by CTL and '
          'hours limits), scaled per week by the load graph\'s factors; the '
          'sessions per weekday (per sport for triathlon) and the 80/20 '
          'check per week. ALL plan numbers come from here — never compute '
          'or adjust them yourself. Omitted arguments fall back to the '
          'athlete\'s saved goal, including the load graph. Nothing is '
          'written anywhere; the athlete confirms a plan on the Plan screen. '
          'Returns an error naming what is missing (for example a baseline '
          'weekly load) or which argument is invalid.',
      schema: const {
        'type': 'object',
        'properties': {
          'goal_type': {
            'type': 'string',
            'description': 'For example long_distance or short_event.',
          },
          'sport': {'type': 'string', 'description': 'Run, Ride or Triathlon.'},
          'weeks': {
            'type': 'integer',
            'description':
                'Plan length, 2-16. Default: 8, or the weeks until the '
                'event date.',
          },
          'sport_mix': {
            'type': 'object',
            'description':
                'Triathlon only: % of weekly load per sport, 5% steps, '
                'total 100, e.g. {"Swim": 15, "Ride": 50, "Run": 35}.',
          },
          'load_factors': {
            'type': 'array',
            'items': {'type': 'number'},
            'description':
                'Per week, 0.8-1.2: share of the proposed load (1.0 = the '
                'proposal). A week >10% below the one before becomes a '
                'recovery week.',
          },
          'weekdays': {
            'type': 'array',
            'items': {'type': 'integer'},
            'description': 'Training days, Monday=1 .. Sunday=7.',
          },
          'weekly_hours': {'type': 'number'},
          'baseline_weekly_load': {
            'type': 'number',
            'description':
                'Typical weekly TSS, only when history is too short.',
          },
          'start_date': {
            'type': 'string',
            'description':
                'YYYY-MM-DD; moved to that week\'s Monday. Default: next '
                'Monday.',
          },
        },
      },
      run: (args) => _generatePlan(args),
    ),
    _tool(
      name: 'get_session_template',
      description:
          'The session recipe behind a plan session: name, intended '
          'intensity mix, the steps, plus the block rules (week multipliers, '
          '80/20 target). Use it to explain why a session looks the way it '
          'does. With no arguments it lists the known goals, slots and '
          'phases.',
      schema: const {
        'type': 'object',
        'properties': {
          'goal_type': {'type': 'string'},
          'slot': {'type': 'string', 'description': 'z2, intervals or long.'},
          'phase': {
            'type': 'string',
            'description': 'build, build_plus, peak or recovery.',
          },
          'sport': {
            'type': 'string',
            'description': 'Run, Ride or Swim (default Run).',
          },
        },
      },
      run: (args) => _sessionTemplate(args),
    ),
    _tool(
      name: 'get_training_plan',
      description:
          'The athlete\'s saved goal, the load graph (per week: proposed '
          'TSS, target TSS, share of the proposal, allowed TSS range, phase, '
          'limits exceeded) and the current plan: weeks with target, planned '
          'and actual TSS, and every session with its session_id, date, '
          'sport, type, minutes, TSS and whether it was sent to '
          'Intervals.icu. Read-only. Call it before proposing any change to '
          'the graph or a session.',
      schema: const {'type': 'object', 'properties': {}},
      run: (_) => _planTools.getTrainingPlan(),
    ),
    _tool(
      name: 'propose_load_curve',
      description:
          'Proposes a change to the load graph — the athlete applies or '
          'dismisses it with a card; nothing is saved by this call. Edits '
          'apply on top of the saved graph: set_weeks (TSS or percent of '
          'the proposal, each week within its allowed range on a 5-TSS '
          'grid), recovery_weeks (each set to the bottom of its range), '
          'weeks (plan length 2-16), sport_mix (triathlon), ramp_percent '
          '(weekly increase 0-15), hold_every_4th, reset. Returns '
          'the resulting graph with phases and warnings, or an error naming '
          'the allowed range.',
      schema: const {
        'type': 'object',
        'properties': {
          'set_weeks': {
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'week': {'type': 'integer', 'description': '1-based.'},
                'tss': {'type': 'number'},
                'percent': {
                  'type': 'number',
                  'description': 'Share of the proposed TSS, 80-120.',
                },
              },
            },
          },
          'recovery_weeks': {
            'type': 'array',
            'items': {'type': 'integer'},
            'description': '1-based weeks to drop to recovery level.',
          },
          'weeks': {'type': 'integer'},
          'sport_mix': {
            'type': 'object',
            'description': '{"Swim": 15, "Ride": 50, "Run": 35}',
          },
          'reset': {'type': 'boolean'},
          'ramp_percent': {
            'type': 'integer',
            'description': 'Weekly increase of the proposal, 0-15.',
          },
          'hold_every_4th': {
            'type': 'boolean',
            'description': 'Hold weeks 4, 8, 12... flat (default on).',
          },
        },
      },
      run: (args) => _planTools.proposeLoadCurve(args),
    ),
    _tool(
      name: 'propose_session_change',
      description:
          'Proposes moving one session of the current plan to another date '
          'inside the plan, or removing it. Only sessions from today on. '
          'The athlete applies or dismisses it with a card; nothing changes '
          'from this call. Use session_id from get_training_plan.',
      schema: const {
        'type': 'object',
        'properties': {
          'session_id': {'type': 'integer'},
          'action': {
            'type': 'string',
            'enum': ['move', 'remove'],
          },
          'date': {'type': 'string', 'description': 'YYYY-MM-DD, for a move.'},
        },
        'required': ['session_id', 'action'],
      },
      run: (args) => _planTools.proposeSessionChange(args),
    ),
    _tool(
      name: 'get_performance_curve',
      description:
          'Best efforts per duration (power, heart rate) or per distance '
          '(pace) for one sport: this season (s0), last season (s1) and the '
          'last 42 days, at fixed key points, with the session that set '
          'each, plus the model Intervals.icu fits (FTP/CP/W\'/Pmax for '
          'power, critical speed/D\' for pace) against the threshold in the '
          'athlete\'s settings. Use for "am I getting faster" questions. '
          'Read-only; fetches from Intervals.icu only when nothing is cached '
          'or a newer activity of the sport arrived.',
      schema: const {
        'type': 'object',
        'properties': {
          'sport': {
            'type': 'string',
            'enum': ['Ride', 'Run', 'Swim'],
          },
          'metric': {
            'type': 'string',
            'enum': ['power', 'pace', 'hr'],
          },
        },
        'required': ['sport', 'metric'],
      },
      run: (args) => _performanceCurve(args),
    ),
    _tool(
      name: 'sync_from_intervals',
      description:
          'Fetches a date range from Intervals.icu into the local cache. The '
          'only tool that syncs date ranges. Use it when get_athlete_context '
          'shows the dates you need are not cached, or when the athlete asks '
          'for fresh data. Sync the range you need, not the whole history.',
      schema: _rangeSchema(),
      run: (args) => _syncFromIntervals(args),
    ),
  ];

  /// The cached range per scope, for the agent's runtime context block.
  Future<Map<String, String>> cachedRanges() async {
    final ranges = <String, String>{};
    for (final scope in _syncScopes) {
      final state = await _syncStateRepository.get(scope);
      if (state != null) {
        ranges[scope] = '${state.oldest} to ${state.newest}';
      }
    }
    return ranges;
  }

  // ---------------------------------------------------------------- tools

  Future<Map<String, dynamic>> _athleteContext() async {
    final now = _clock();
    final recentActivities = await _activitiesRepository.getRange(
      _isoDate(now.subtract(const Duration(days: 365))),
      _isoDate(now),
    );

    // Thresholds aren't cached in their own right, but every activity
    // carries the ones that were in force when it was analysed — so the
    // newest activity per sport is the athlete's current setup for it,
    // without another API call.
    final thresholdsBySport = <String, Map<String, dynamic>>{};
    for (final activity in recentActivities) {
      final sport = activity.type;
      if (sport == null) continue;
      final raw = activity.raw;
      final entry = _compact({
        'sport': sport,
        'as_of': activity.date,
        'ftp': raw['icu_ftp'] ?? raw['icu_pm_ftp'],
        'w_prime': raw['icu_w_prime'],
        'lthr': raw['lthr'],
        'max_hr': raw['athlete_max_hr'],
        'resting_hr': raw['icu_resting_hr'],
        'threshold_pace_m_per_s': raw['threshold_pace'],
        'weight_kg': raw['icu_weight'],
        'power_zones_percent_ftp': raw['icu_power_zones'],
        'hr_zones_bpm': raw['icu_hr_zones'],
        'pace_zones': raw['pace_zones'],
      });
      // getRange is ordered oldest first, so later rows win.
      if (entry.length > 2) thresholdsBySport[sport] = entry;
    }

    return {
      'today': _isoDate(now),
      'weekday': _weekdayName(now.weekday),
      'athlete': _compact({
        'name': _session.athleteName,
        'id': _session.athleteId,
        'intervals_connected': _session.isConnected,
      }),
      'units': {
        'distance': 'metres',
        'duration': 'seconds',
        'speed': 'metres per second',
        'load': 'TSS-equivalent training load',
      },
      'cached_ranges': await cachedRanges(),
      'thresholds': thresholdsBySport.values.toList(),
      'notes': thresholdsBySport.isEmpty
          ? 'No activities cached in the last year, so no thresholds could '
                'be read. Sync before relying on FTP/LTHR/pace.'
          : 'Thresholds are read from the most recent activity per sport '
                'and are only as current as that activity.',
    };
  }

  Future<Map<String, dynamic>> _dailyMetrics(Map<String, dynamic> args) async {
    final range = _readRange(args, maxDays: _maxMetricDays);
    if (range.error != null) return {'error': range.error};

    final records = await _wellnessRepository.getRange(range.start, range.end);
    return {
      'range': {'start_date': range.start, 'end_date': range.end},
      'days': records.map(_dailyMetricsRow).toList(),
      if (records.isEmpty)
        'note':
            'No wellness records cached for this range. Either nothing was '
            'synced or the athlete logged nothing.',
    };
  }

  Map<String, dynamic> _dailyMetricsRow(LocalWellness record) {
    final raw = record.raw;
    final ctl = record.ctl;
    final atl = record.atl;
    return _compact({
      'date': record.date,
      'ctl': _round(ctl),
      'atl': _round(atl),
      'tsb': ctl != null && atl != null ? _round(ctl - atl) : null,
      'ramp_rate': _round(record.rampRate),
      'resting_hr': raw['restingHR'],
      'hrv': _round(_asDouble(raw['hrv'])),
      'hrv_sdnn': _round(_asDouble(raw['hrvSDNN'])),
      'sleep_secs': raw['sleepSecs'],
      'sleep_score': _round(_asDouble(raw['sleepScore'])),
      'sleep_quality': raw['sleepQuality'],
      'avg_sleeping_hr': _round(_asDouble(raw['avgSleepingHR'])),
      'weight_kg': _round(_asDouble(raw['weight'])),
      'readiness': _round(_asDouble(raw['readiness'])),
      'soreness': raw['soreness'],
      'fatigue': raw['fatigue'],
      'stress': raw['stress'],
      'mood': raw['mood'],
      'motivation': raw['motivation'],
      'injury': raw['injury'],
      'spo2': _round(_asDouble(raw['spO2'])),
      'respiration': _round(_asDouble(raw['respiration'])),
      'vo2max': _round(_asDouble(raw['vo2max'])),
      'kcal_consumed': raw['kcalConsumed'],
      'comments': raw['comments'],
    });
  }

  Future<Map<String, dynamic>> _activities(Map<String, dynamic> args) async {
    final range = _readRange(args, maxDays: _maxActivityDays);
    if (range.error != null) return {'error': range.error};

    final sport = (args['sport'] as String?)?.trim().toLowerCase();
    final limit = ((args['limit'] as num?)?.toInt() ?? _defaultActivityLimit)
        .clamp(1, _maxActivityLimit);

    var records = await _activitiesRepository.getRange(range.start, range.end);
    if (sport != null && sport.isNotEmpty) {
      records = records
          .where((a) => (a.type ?? '').toLowerCase() == sport)
          .toList();
    }
    final total = records.length;
    // Newest first, so a truncated answer keeps the most relevant sessions.
    final selected = records.reversed.take(limit).toList();

    return {
      'range': {'start_date': range.start, 'end_date': range.end},
      if (sport != null && sport.isNotEmpty) 'sport_filter': args['sport'],
      'total_matching': total,
      'returned': selected.length,
      if (selected.length < total)
        'note':
            'Truncated to the $limit most recent of $total matching '
            'activities. Narrow the range or use get_training_summary.',
      'intensity_model': intensityModelNote,
      'activities': selected.map(_activityRow).toList(),
    };
  }

  Map<String, dynamic> _activityRow(LocalActivity activity) {
    final raw = activity.raw;
    final intensity = intensityOf(raw);
    return _compact({
      'id': activity.id,
      'date': activity.date,
      'sport': activity.type,
      'name': activity.name,
      'moving_time_s': activity.movingTime,
      'elapsed_time_s': raw['elapsed_time'],
      'distance_m': _round(activity.distance),
      'training_load': activity.trainingLoad,
      'intensity_factor': _round(_asDouble(raw['icu_intensity'])),
      'average_watts': raw['icu_average_watts'],
      'weighted_average_watts': raw['icu_weighted_avg_watts'],
      'average_hr': raw['average_heartrate'],
      'max_hr': raw['max_heartrate'],
      'average_speed_m_per_s': _round(_asDouble(raw['average_speed'])),
      'gap_m_per_s': _round(_asDouble(raw['gap'])),
      'elevation_gain_m': _round(_asDouble(raw['total_elevation_gain'])),
      'decoupling_percent': _round(_asDouble(raw['decoupling'])),
      'efficiency_factor': _round(_asDouble(raw['icu_efficiency_factor'])),
      'polarization_index': _round(_asDouble(raw['polarization_index'])),
      'rpe': raw['icu_rpe'],
      'session_rpe': raw['session_rpe'],
      'feel': raw['feel'],
      'race': raw['race'],
      'indoor': raw['trainer'],
      'compliance_percent': _round(_asDouble(raw['compliance'])),
      'description': _truncate(raw['description'] as String?, 400),
      'intensity_s': intensity == null
          ? null
          : {
              'low': intensity.low,
              'moderate': intensity.moderate,
              'high': intensity.high,
              'source': intensity.source,
            },
    });
  }

  Future<Map<String, dynamic>> _plannedWorkouts(
    Map<String, dynamic> args,
  ) async {
    final range = _readRange(args, maxDays: _maxActivityDays);
    if (range.error != null) return {'error': range.error};

    final records = await _eventsRepository.getRange(range.start, range.end);
    return {
      'range': {'start_date': range.start, 'end_date': range.end},
      'planned': records.map(_plannedRow).toList(),
      if (records.isEmpty)
        'note': 'Nothing planned in this range, or the range was never synced.',
    };
  }

  Map<String, dynamic> _plannedRow(LocalEvent event) => _compact({
    'id': event.id,
    'date': event.date,
    'category': event.category,
    'is_training': event.isTraining,
    'sport': event.type,
    'name': event.name,
    'description': _truncate(event.description, 600),
    'planned_load': event.plannedLoad,
    'planned_time_s': event.plannedTime,
    'planned_distance_m': _round(event.plannedDistance),
    'indoor': event.indoor,
    if (event.isPlanSession) 'source': 'triiq_plan',
    if (event.isPlanSession) 'sent_to_intervals': event.planSessionSent,
  });

  Future<Map<String, dynamic>> _trainingSummary(
    Map<String, dynamic> args,
  ) async {
    final range = _readRange(args, maxDays: _maxSummaryDays);
    if (range.error != null) return {'error': range.error};

    final groupBy = (args['group_by'] as String?)?.trim().toLowerCase();
    if (groupBy != null &&
        groupBy.isNotEmpty &&
        groupBy != 'week' &&
        groupBy != 'month') {
      return {'error': 'group_by must be "week" or "month".'};
    }
    final byMonth = groupBy == 'month';

    final activities = await _activitiesRepository.getRange(
      range.start,
      range.end,
    );
    final events = await _eventsRepository.getRange(range.start, range.end);
    final wellness = await _wellnessRepository.getRange(range.start, range.end);

    final buckets = <String, _Bucket>{};
    _Bucket bucketFor(String date) {
      final key = byMonth ? _monthKey(date) : _weekKey(date);
      return buckets.putIfAbsent(key, () => _Bucket(key));
    }

    for (final activity in activities) {
      final bucket = bucketFor(activity.date)..add(activity, intensityOf);
      bucket.end = _maxIso(bucket.end, activity.date);
    }
    for (final event in events) {
      if (!event.isTraining) continue;
      bucketFor(event.date).plannedLoad += event.plannedLoad ?? 0;
    }
    for (final record in wellness) {
      bucketFor(record.date).addWellness(record);
    }

    final ordered = buckets.values.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return {
      'range': {'start_date': range.start, 'end_date': range.end},
      'group_by': byMonth ? 'month' : 'week',
      'intensity_model': intensityModelNote,
      'buckets': ordered.map((b) => b.toJson()).toList(),
      'totals': {
        'completed_load': ordered.fold<int>(0, (sum, b) => sum + b.load),
        'planned_load': ordered.fold<int>(0, (sum, b) => sum + b.plannedLoad),
        'sessions': ordered.fold<int>(0, (sum, b) => sum + b.sessions),
        'moving_time_s': ordered.fold<int>(0, (sum, b) => sum + b.movingTime),
      },
      if (ordered.isEmpty)
        'note':
            'Nothing cached in this range — sync it before drawing '
            'conclusions.',
    };
  }

  Future<Map<String, dynamic>> _performanceCurve(
    Map<String, dynamic> args,
  ) async {
    final sport = CurveSport.fromName(args['sport'] as String?);
    final metric = CurveMetric.fromName(args['metric'] as String?);
    if (sport == null || metric == null) {
      return {
        'error': 'sport must be Ride, Run or Swim; metric power, pace or hr.',
      };
    }
    PerformanceCurves curves;
    String? note;
    try {
      curves = await _performanceCurves.load(sport, metric);
    } catch (error) {
      final cached = await _performanceCurves.cached(sport, metric);
      if (cached == null) {
        return {'error': 'Could not fetch the curves: $error'};
      }
      curves = cached;
      note = 'Fetching fresh curves failed; these are the cached ones.';
    }
    if (curves.isEmpty) {
      return {
        'sport': sport.apiType,
        'metric': metric.name,
        'note': 'No efforts for this sport and metric.',
      };
    }

    final unitMetres = paceUnitMetres(sport);
    Map<String, dynamic> point(CurvePoint p) {
      final activity = p.activityId == null
          ? null
          : curves.activities[p.activityId];
      return _compact({
        metric.byDistance ? 'distance_m' : 'duration_s': p.x,
        if (metric.byDistance) ...{
          'time_s': p.value,
          'pace': formatPace(p.x / p.value, per: unitMetres),
        } else
          'value': p.value,
        'activity_id': p.activityId,
        'date': activity?.date,
        'name': activity?.name,
      });
    }

    final settings = _session.settingsForSport(sport.apiType);
    final model = curves.period('s0')?.model;
    Map<String, dynamic>? gap;
    if (metric == CurveMetric.power &&
        model?.ftp != null &&
        (settings?.ftp ?? 0) > 0) {
      final ftp = settings!.ftp!;
      gap = {
        'model_ftp': model!.ftp,
        'settings_ftp': ftp,
        'difference_w': model.ftp! - ftp,
        'difference_pct': ((model.ftp! / ftp - 1) * 1000).round() / 10,
      };
    } else if (metric == CurveMetric.pace &&
        model?.criticalSpeed != null &&
        (settings?.thresholdPace ?? 0) > 0) {
      final pace = settings!.thresholdPace!;
      gap = {
        'model_pace': formatPace(model!.criticalSpeed!, per: unitMetres),
        'settings_threshold_pace': formatPace(pace, per: unitMetres),
        'per_metres': unitMetres,
        'speed_difference_pct':
            ((model.criticalSpeed! / pace - 1) * 1000).round() / 10,
      };
    }

    return _compact({
      'sport': sport.apiType,
      'metric': metric.name,
      'unit': switch (metric) {
        CurveMetric.power => 'W',
        CurveMetric.hr => 'bpm',
        CurveMetric.pace => 'time_s over distance_m; pace per $unitMetres m',
      },
      'periods': [
        for (final period in curves.periods)
          _compact({
            'period': period.id,
            'from': period.start,
            'to': period.end,
            'key_points': [
              for (final x in curves.keyPoints) ?period.at(x),
            ].map(point).toList(),
            'model': period.model?.toJson(),
          }),
      ],
      'model_vs_settings': gap,
      'note': note,
    });
  }

  /// One guidance section plus the title of the document it came from.
  static ({String document, GuidanceSection section}) _attributed(
    String document,
    GuidanceSection section,
  ) => (document: document, section: section);

  Future<Map<String, dynamic>> _trainingGuidance(
    Map<String, dynamic> args,
  ) async {
    final topic = (args['topic'] as String?)?.trim() ?? '';

    // Bundled reference first, then every enabled imported document. Either
    // source missing (no asset installed, or no local SQLite on web) just
    // means fewer sections, not an error — the other can still answer.
    final all = <({String document, GuidanceSection section})>[];
    try {
      final document = await _loadTrainingGuidance();
      for (final section in splitGuidanceSections(
        document,
        fallbackTitle: 'training-philosophy',
      )) {
        all.add(_attributed('Training reference', section));
      }
    } catch (_) {
      // No bundled reference installed — imported documents may cover it.
    }
    try {
      for (final match in await _knowledgeLibrary.enabledSections()) {
        all.add(_attributed(match.document, match.section));
      }
    } catch (_) {
      // e.g. web: no local SQLite — bundled reference only.
    }

    if (all.isEmpty) {
      return {
        'error':
            'No training reference is available: nothing bundled and no '
            'coaching documents imported. Answer from the data, and mention '
            'that documents can be imported under More → Knowledge '
            'library.',
      };
    }

    Map<String, dynamic> groupedListing(String note) {
      final byDocument = <String, List<String>>{};
      for (final entry in all) {
        (byDocument[entry.document] ??= []).add(entry.section.title);
      }
      return {
        'documents': [
          for (final e in byDocument.entries)
            {'document': e.key, 'sections': e.value},
        ],
        'note': note,
      };
    }

    if (topic.isEmpty) {
      return groupedListing('Call again with a topic to read one of these.');
    }

    // Unicode-aware so German terms ("Schwelle", "Erholung") are searchable,
    // not just ASCII ones.
    final terms = topic
        .toLowerCase()
        .split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
        .where((t) => t.length > 2)
        .toList();
    if (terms.isEmpty) {
      return groupedListing(
        'The topic had no searchable words; pick a section by name.',
      );
    }

    final scored =
        all
            .map((entry) => (entry: entry, score: entry.section.score(terms)))
            .where((match) => match.score > 0)
            .toList()
          ..sort((a, b) => b.score.compareTo(a.score));

    if (scored.isEmpty) {
      return {
        'topic': topic,
        'matches': <String>[],
        'available_sections': [for (final e in all) e.section.title],
        'note': 'Nothing matched. Pick one of the available sections.',
      };
    }

    return _compact({
      'topic': topic,
      'matches': scored
          .take(3)
          .map(
            (match) => {
              'title': match.entry.section.title,
              'text': _truncate(match.entry.section.body, 4000),
              'document': match.entry.document,
            },
          )
          .toList(),
      'more_matches': scored
          .skip(3)
          .take(10)
          .map(
            (match) => {
              'title': match.entry.section.title,
              'document': match.entry.document,
            },
          )
          .toList(),
    });
  }

  Future<Map<String, dynamic>> _generatePlan(Map<String, dynamic> args) async {
    final knowledge = await _knowledge.load();
    final saved = await _goalStore.load();

    final goalType = (args['goal_type'] as String?) ?? saved?.targetType;
    final weekdays = (args['weekdays'] as List?)
        ?.map((d) => (d as num).toInt())
        .toSet();
    final hours = (args['weekly_hours'] as num?)?.toDouble();
    if (goalType == null ||
        (weekdays ?? saved?.weekdays) == null ||
        (hours ?? saved?.weeklyHours) == null) {
      return {
        'error':
            'No saved goal and not enough arguments. Ask the athlete for '
            'goal_type, weekdays and weekly_hours, then call again.',
        'known_goals': knowledge.goals.keys.toList(),
      };
    }
    final weeksArg = args['weeks'];
    if (weeksArg != null && weeksArg is! num) {
      return {'error': 'weeks must be a whole number from 2 to 16.'};
    }
    Map<String, int>? mix;
    final mixArg = args['sport_mix'];
    if (mixArg != null) {
      if (mixArg is! Map ||
          mixArg.values.any((v) => v is! num) ||
          mixArg.keys.any((k) => !Goal.triathlonSports.contains(k))) {
        return {
          'error':
              'sport_mix must map Swim, Ride and Run to whole percentages, '
              'e.g. {"Swim": 15, "Ride": 50, "Run": 35}.',
        };
      }
      mix = {
        for (final s in Goal.triathlonSports)
          s: ((mixArg[s] as num?) ?? 0).toInt(),
      };
    }
    List<double>? factors;
    final factorsArg = args['load_factors'];
    if (factorsArg != null) {
      if (factorsArg is! List || factorsArg.any((f) => f is! num)) {
        return {
          'error':
              'load_factors must be a list of numbers, one per week, each '
              '0.8 to 1.2 (share of the proposed load).',
        };
      }
      factors = [for (final f in factorsArg) (f as num).toDouble()];
    }

    final goal = Goal(
      targetType: goalType,
      weekdays: weekdays ?? saved!.weekdays,
      weeklyHours: hours ?? saved!.weeklyHours,
      sport: (args['sport'] as String?) ?? saved?.sport ?? 'Run',
      eventDate: saved?.eventDate,
      baselineWeeklyLoad:
          (args['baseline_weekly_load'] as num?)?.toDouble() ??
          saved?.baselineWeeklyLoad,
      maxWeeklyIncrease: saved?.maxWeeklyIncrease,
      maxCtlRamp: saved?.maxCtlRamp,
      weeks: (weeksArg as num?)?.toInt() ?? saved?.weeks,
      sportMix: mix ?? saved?.sportMix ?? Goal.defaultSportMix,
      loadFactors: factors ?? saved?.loadFactors ?? const [],
    );

    final now = _clock();
    final requested = _parseDate(args['start_date']);
    final start = requested != null
        ? startOfWeek(requested)
        : startOfWeek(now).add(const Duration(days: 7));
    final inputs = await _planInputs.load(start);
    final result = PlanEngine(knowledge).generate(
      goal: goal,
      startDate: start,
      recentWeeklyLoads: inputs.weeklyLoads,
      currentCtl: inputs.currentCtl,
      today: now,
    );

    final failure = result.failure;
    if (failure != null) {
      return {'error': failure.message, 'reason': failure.kind.name};
    }
    final plan = result.plan!;
    final proposalId = await _planTools.registerPlanDraft(
      goal,
      'take a ${plan.weeks.length}-week ${plan.sport} plan starting '
      '${_isoDate(plan.startDate)}',
    );
    return {
      'proposal_id': proposalId,
      'goal_type': plan.goalType,
      'sport': plan.sport,
      'start_date': _isoDate(plan.startDate),
      'baseline_weekly_load': plan.baselineLoad.round(),
      if (plan.sportMix.isNotEmpty) 'sport_mix': plan.sportMix,
      'weeks': [
        for (final week in plan.weeks)
          {
            'phase': week.phase,
            'start_date': _isoDate(week.startDate),
            'proposed_load': week.requestedLoad.round(),
            'load_factor': week.factor,
            'target_load': week.targetLoad.round(),
            if (week.limit != WeekLimit.none) 'limited_by': week.limit.name,
            if (week.warnings.isNotEmpty)
              'above_limits': [for (final l in week.warnings) l.name],
            'planned_load': week.plannedLoad,
            if (plan.sportMix.isNotEmpty)
              'planned_load_by_sport': week.loadBySport,
            'planned_minutes': week.totalMinutes,
            'low_intensity_share': week.lowShare == null
                ? null
                : double.parse(week.lowShare!.toStringAsFixed(2)),
            'outside_80_20': week.outsideTolerance,
            if (week.projectedCtlEnd != null)
              'projected_ctl_end': double.parse(
                week.projectedCtlEnd!.toStringAsFixed(1),
              ),
            'sessions': [
              for (final s in week.sessions)
                {
                  'date': _isoDate(s.date),
                  'sport': s.sport,
                  'slot': s.slot.name,
                  'name': s.name,
                  'minutes': s.minutes,
                  'load': s.load,
                },
            ],
          },
      ],
      'note':
          'Engine output. proposed_load is a steady ramp (max weekly '
          'increase) held by the CTL and hours limits; target_load is that '
          'times the athlete\'s load_factor from the load graph. above_limits '
          'lists limits an athlete-set week exceeds (shown, not enforced). '
          'Ramp limits and the 80/20 tolerance are defaults from the '
          'training knowledge, not universal values. Nothing is saved: the '
          'athlete sees a card under your reply; Apply opens the plan '
          'preview, where they take the plan (or open the Plan screen).',
    };
  }

  Future<Map<String, dynamic>> _sessionTemplate(
    Map<String, dynamic> args,
  ) async {
    final knowledge = await _knowledge.load();
    final rules = knowledge.rules;
    final ruleSummary = {
      'phases': rules.weekPhases,
      'week_multipliers': rules.weekMultipliers,
      'low_intensity_target': rules.lowIntensityTarget,
      'low_intensity_tolerance': rules.lowIntensityTolerance,
      'max_weekly_increase': rules.maxWeeklyIncrease,
      'max_ctl_ramp': rules.maxCtlRamp,
      'recovery_threshold': rules.recoveryThreshold,
    };

    final goalType = args['goal_type'] as String?;
    final slotName = args['slot'] as String?;
    final phase = args['phase'] as String?;
    if (goalType == null || slotName == null || phase == null) {
      return {
        'goals': knowledge.goals.keys.toList(),
        'slots': SessionSlot.values.map((s) => s.name).toList(),
        'phases': rules.weekPhases,
        'rules': ruleSummary,
        'note': 'Pass goal_type, slot and phase to get one template.',
      };
    }
    final slot = SessionSlot.values.asNameMap()[slotName];
    if (slot == null) {
      return {'error': 'Unknown slot "$slotName". Use z2, intervals or long.'};
    }
    try {
      final t = knowledge.templateFor(
        goalType,
        slot,
        phase,
        sport: (args['sport'] as String?) ?? 'Run',
      );
      return {
        'id': t.id,
        'name': t.name,
        'goal_type': t.goal,
        'slot': t.slot.name,
        'phase': phase,
        'tss_per_hour_assumed': t.tssPerHour,
        'low_intensity_share_of_time': t.lowShare,
        'structure': [for (final s in t.steps) _describeStep(s)],
        'rules': ruleSummary,
      };
    } on MissingTemplateException catch (error) {
      return {'error': error.toString()};
    }
  }

  static String _describeStep(StepSpec step) => switch (step) {
    FixedStep() => '${step.effort.minutes} min fixed',
    FillStep() => 'remaining time, steady',
    RepeatStep() =>
      '${step.min}-${step.max} x (${step.work.minutes} min hard / '
          '${step.rest.minutes} min easy)',
  };

  Future<Map<String, dynamic>> _syncFromIntervals(
    Map<String, dynamic> args,
  ) async {
    final range = _readRange(args, maxDays: _maxSummaryDays);
    if (range.error != null) return {'error': range.error};
    if (!_session.isConnected) {
      return {
        'error':
            'Not connected to Intervals.icu. The athlete needs to enter '
            'their API key on the Profile screen before anything can sync.',
      };
    }

    try {
      final result = await _syncService.syncRange(
        DateTime.parse(range.start),
        DateTime.parse(range.end),
      );
      return {
        'synced': {'start_date': range.start, 'end_date': range.end},
        'wellness_records': result.wellnessCount,
        'activities': result.activitiesCount,
        'planned_entries': result.eventsCount,
      };
    } catch (error) {
      return {'error': 'Sync failed: $error'};
    }
  }

  Future<Map<String, dynamic>> _planAdjustments() async {
    final proposals = await _adaptation.refresh();
    return {
      'date': _isoDate(_clock()),
      if (proposals.isNotEmpty)
        'proposal_ids': [for (final p in proposals) p.id],
      'adjustments': [
        for (final p in proposals)
          {
            'proposal_id': p.id,
            'kind': p.key!.split(':').first,
            'summary': p.summary,
          },
      ],
      if (proposals.isEmpty)
        'note':
            'Nothing to adjust: no missed sessions, no week far off its '
            'target, no readiness conflict (or the athlete dismissed them).',
      if (proposals.isNotEmpty) 'note': _notAppliedNote,
    };
  }

  static const _notAppliedNote =
      'Not applied: each proposal shows as a card with Apply / Dismiss. '
      'Tell the athlete what it would change; do not claim it is done.';

  Future<Map<String, dynamic>> _thresholdSuggestionsTool() async {
    final suggestions = await _thresholdSuggestions.load();
    return _compact({
      'suggestions': [
        for (final s in suggestions)
          _compact({
            'sport': s.sport.apiType,
            'field': s.field,
            'direction': s.direction.name,
            'current_value': _round(s.currentValue),
            'candidate_value': _round(s.candidateValue),
            'change_percent': _round(s.changeFraction * 100),
            'basis': s.basisKind.name,
            'effort_activity_ids': s.effortActivityIds,
          }),
      ],
      'note': suggestions.isEmpty
          ? 'No threshold suggestions right now.'
          : 'Review and apply in Statistics → Performance; this tool '
                'cannot apply or dismiss one.',
    });
  }

  Future<Map<String, dynamic>> _readinessToday() async {
    final r = (await _readiness.load()).readiness;
    String snake(String name) => name.replaceAllMapped(
      RegExp('[A-Z]'),
      (m) => '_${m[0]!.toLowerCase()}',
    );
    return _compact({
      'date': _isoDate(_clock()),
      'status': snake(r.level.name),
      'reasons': [for (final s in r.reasons) snake(s.kind.name)],
      'data_state': snake(r.dataState.name),
      'last_recorded_date': r.lastRecordedDate,
      'device_readiness': _round(r.deviceReadiness),
      'signals': [
        for (final s in r.signals)
          _compact({
            'signal': snake(s.kind.name),
            'rating': snake(s.rating.name),
            'value': _round(s.value),
            'unit': switch (s.kind) {
              ReadinessSignalKind.hrv => 'ms (rMSSD)',
              ReadinessSignalKind.restingHr => 'bpm',
              ReadinessSignalKind.sleep => 'hours',
              ReadinessSignalKind.form => 'CTL - ATL',
              ReadinessSignalKind.subjective => '1 good .. 4 bad',
            },
            'baseline_mean': _round(s.mean),
            'baseline_sd': _round(s.sd),
            'ok_bound': _round(s.okBound),
            'fatigue': s.fatigue,
            'soreness': s.soreness,
          }),
      ],
      'note':
          'Thresholds are defaults from the training knowledge, not medical '
          'advice. One day means little on its own; look at the trend with '
          'get_daily_metrics before a strong recommendation.',
    });
  }

  // -------------------------------------------------------------- helpers

  Tool _tool({
    required String name,
    required String description,
    required Map<String, dynamic> schema,
    required Future<Map<String, dynamic>> Function(Map<String, dynamic> args)
    run,
  }) => Tool.fromFunction<Map<String, dynamic>, String>(
    name: name,
    description: description,
    inputJsonSchema: schema,
    getInputFromJson: (json) => json,
    func: (args) async => jsonEncode(await run(args)),
  );

  static Map<String, dynamic> _rangeProperties() => const {
    'start_date': {
      'type': 'string',
      'description': 'Inclusive first day, as YYYY-MM-DD.',
    },
    'end_date': {
      'type': 'string',
      'description': 'Inclusive last day, as YYYY-MM-DD.',
    },
  };

  static Map<String, dynamic> _rangeSchema() => {
    'type': 'object',
    'properties': _rangeProperties(),
    'required': ['start_date', 'end_date'],
  };

  /// Validates and normalises a `start_date`/`end_date` pair. Bad input is
  /// returned as an `error` string rather than thrown: the model can read a
  /// sentence and retry, which is cheaper than an exception it never sees.
  _Range _readRange(Map<String, dynamic> args, {required int maxDays}) {
    final start = _parseDate(args['start_date']);
    final end = _parseDate(args['end_date']);
    if (start == null || end == null) {
      return const _Range.invalid(
        'start_date and end_date are required, formatted YYYY-MM-DD.',
      );
    }
    if (end.isBefore(start)) {
      return const _Range.invalid('end_date must not be before start_date.');
    }
    if (end.difference(start).inDays + 1 > maxDays) {
      return _Range.invalid(
        'That range is longer than the $maxDays days this tool returns in '
        'one call. Ask for a shorter range, or use get_training_summary.',
      );
    }
    return _Range(_isoDate(start), _isoDate(end));
  }

  static DateTime? _parseDate(Object? value) {
    if (value is! String) return null;
    final text = value.trim();
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)) return null;
    return DateTime.tryParse(text);
  }

  static Future<String> _loadTrainingGuidanceAsset() =>
      rootBundle.loadString('assets/knowledge/training-philosophy.md');

  /// Drops nulls and empty collections so tool output stays readable.
  static Map<String, dynamic> _compact(Map<String, dynamic> map) {
    final result = <String, dynamic>{};
    for (final entry in map.entries) {
      final value = entry.value;
      if (value == null) continue;
      if (value is Iterable && value.isEmpty) continue;
      if (value is Map && value.isEmpty) continue;
      if (value is String && value.isEmpty) continue;
      result[entry.key] = value;
    }
    return result;
  }

  static double? _asDouble(Object? value) =>
      value is num ? value.toDouble() : null;

  static num? _round(double? value) {
    if (value == null) return null;
    final rounded = (value * 10).roundToDouble() / 10;
    return rounded == rounded.roundToDouble() ? rounded.toInt() : rounded;
  }

  static String? _truncate(String? text, int max) {
    if (text == null || text.isEmpty) return null;
    return text.length <= max ? text : '${text.substring(0, max)}…[truncated]';
  }

  static String _isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static String _weekdayName(int weekday) => const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ][weekday - 1];

  /// The Monday of the week [date] falls in, as an ISO day.
  static String _weekKey(String date) {
    final parsed = DateTime.parse(date);
    return _isoDate(parsed.subtract(Duration(days: parsed.weekday - 1)));
  }

  static String _monthKey(String date) => '${date.substring(0, 7)}-01';

  static String _maxIso(String? a, String b) =>
      a == null || b.compareTo(a) > 0 ? b : a;
}

/// A validated date range, or the reason it isn't one.
class _Range {
  const _Range(this.start, this.end) : error = null;
  const _Range.invalid(this.error) : start = '', end = '';

  final String start;
  final String end;
  final String? error;
}

/// One week or month of aggregated training.
class _Bucket {
  _Bucket(this.key);

  final String key;
  String? end;

  int load = 0;
  int plannedLoad = 0;
  int sessions = 0;
  int movingTime = 0;
  double distance = 0;
  int lowSeconds = 0;
  int moderateSeconds = 0;
  int highSeconds = 0;
  int sessionsWithoutZones = 0;

  final Map<String, _SportTotals> bySport = {};

  double? ctlStart;
  double? ctlEnd;
  double? atlEnd;

  void add(
    LocalActivity activity,
    IntensitySplit? Function(Map<String, dynamic> raw) intensityOf,
  ) {
    sessions++;
    load += activity.trainingLoad ?? 0;
    movingTime += activity.movingTime ?? 0;
    distance += activity.distance ?? 0;

    final sport = bySport.putIfAbsent(
      activity.type ?? 'Other',
      _SportTotals.new,
    );
    sport.sessions++;
    sport.load += activity.trainingLoad ?? 0;
    sport.movingTime += activity.movingTime ?? 0;
    sport.distance += activity.distance ?? 0;

    final intensity = intensityOf(activity.raw);
    if (intensity == null) {
      sessionsWithoutZones++;
    } else {
      lowSeconds += intensity.low;
      moderateSeconds += intensity.moderate;
      highSeconds += intensity.high;
    }
  }

  void addWellness(LocalWellness record) {
    ctlStart ??= record.ctl;
    if (record.ctl != null) ctlEnd = record.ctl;
    if (record.atl != null) atlEnd = record.atl;
  }

  Map<String, dynamic> toJson() {
    final classified = lowSeconds + moderateSeconds + highSeconds;
    final ctl = ctlEnd;
    final atl = atlEnd;
    final startCtl = ctlStart;
    return TrainingDataTools._compact({
      'start_date': key,
      'end_date': end,
      'completed_load': load,
      'planned_load': plannedLoad,
      'sessions': sessions,
      'moving_time_s': movingTime,
      'distance_m': TrainingDataTools._round(distance),
      'by_sport': {
        for (final entry in bySport.entries) entry.key: entry.value.toJson(),
      },
      'intensity_s': classified == 0
          ? null
          : {
              'low': lowSeconds,
              'moderate': moderateSeconds,
              'high': highSeconds,
              'low_percent': ((lowSeconds / classified) * 100).round(),
              'sessions_without_zone_data': sessionsWithoutZones,
            },
      if (classified == 0 && sessions > 0)
        'intensity_note':
            'No session in this bucket had zone times, so the intensity '
            'distribution cannot be checked.',
      'ctl_start': TrainingDataTools._round(startCtl),
      'ctl_end': TrainingDataTools._round(ctl),
      'atl_end': TrainingDataTools._round(atl),
      'tsb_end': ctl != null && atl != null
          ? TrainingDataTools._round(ctl - atl)
          : null,
      'ctl_change': startCtl != null && ctl != null
          ? TrainingDataTools._round(ctl - startCtl)
          : null,
    });
  }
}

class _SportTotals {
  int sessions = 0;
  int load = 0;
  int movingTime = 0;
  double distance = 0;

  Map<String, dynamic> toJson() => {
    'sessions': sessions,
    'load': load,
    'moving_time_s': movingTime,
    'distance_m': TrainingDataTools._round(distance),
  };
}
