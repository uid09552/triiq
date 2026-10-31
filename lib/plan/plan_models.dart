import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'knowledge.dart';

/// What the athlete is training for. Persisted locally; the next plan
/// generation reads it.
class Goal {
  const Goal({
    required this.targetType,
    required this.weekdays,
    required this.weeklyHours,
    this.sport = 'Run',
    this.eventDate,
    this.baselineWeeklyLoad,
    this.maxWeeklyIncrease,
    this.maxCtlRamp,
    this.weeks,
    this.sportMix = defaultSportMix,
    this.loadFactors = const [],
  });

  /// A `GoalProfile.id` from the knowledge, e.g. `long_distance`.
  final String targetType;

  /// Days available for training, Monday = 1 .. Sunday = 7.
  final Set<int> weekdays;

  /// The weekly time budget; a week is scaled down to fit it.
  final double weeklyHours;

  /// Intervals.icu activity type the sessions are written for.
  final String sport;

  final DateTime? eventDate;

  /// Weekly load to build from when there is too little history to derive
  /// one. Also overrides the derived baseline when set.
  final double? baselineWeeklyLoad;

  /// Per-athlete overrides of the knowledge's ramp limits.
  final double? maxWeeklyIncrease;
  final double? maxCtlRamp;

  /// Plan length chosen by the athlete; `null` means [planWeeks] decides.
  final int? weeks;

  /// Triathlon only: percentage of weekly load per Intervals.icu sport
  /// (`Swim`, `Ride`, `Run`), in 5% steps, summing to 100.
  final Map<String, int> sportMix;

  /// Per-week share of the proposed load the athlete set in the load graph,
  /// 0.80..1.20; weeks beyond the list are at 1.0.
  final List<double> loadFactors;

  static const triathlon = 'Triathlon';
  static const sports = ['Run', 'Ride', triathlon];
  static const triathlonSports = ['Swim', 'Ride', 'Run'];
  static const defaultSportMix = {'Swim': 15, 'Ride': 50, 'Run': 35};

  static const minWeeks = 2;
  static const maxWeeks = 16;
  static const defaultWeeks = 8;
  static const minFactor = 0.8;
  static const maxFactor = 1.2;
  static const factorStep = 0.05;

  bool get isTriathlon => sport == triathlon;

  /// The share of weekly load per Intervals.icu sport, 0..1. A single-sport
  /// goal is that sport at 100%; sports at 0% are left out.
  Map<String, double> get sportShares => isTriathlon
      ? {
          for (final s in triathlonSports)
            if ((sportMix[s] ?? 0) > 0) s: sportMix[s]! / 100,
        }
      : {sport: 1.0};

  /// The plan length for a block starting on [startMonday]: the athlete's
  /// choice, else the whole weeks until the event when that is in range,
  /// else [defaultWeeks].
  int planWeeks(DateTime startMonday) {
    final chosen = weeks;
    if (chosen != null) return chosen;
    final event = eventDate;
    if (event != null) {
      // UTC so a clock change in between doesn't eat a day.
      final untilEvent =
          DateTime.utc(event.year, event.month, event.day)
              .difference(
                DateTime.utc(
                  startMonday.year,
                  startMonday.month,
                  startMonday.day,
                ),
              )
              .inDays ~/
          7;
      if (untilEvent >= minWeeks && untilEvent <= maxWeeks) return untilEvent;
    }
    return defaultWeeks;
  }

  /// The load-graph factor for week [index].
  double factorFor(int index) =>
      index < loadFactors.length ? loadFactors[index] : 1.0;

  /// [loadFactors] trimmed or padded to [count] weeks.
  List<double> factorsFor(int count) => [
    for (var i = 0; i < count; i++) factorFor(i),
  ];

  /// Why this goal can't be used, or `null` when it can. [today] is the
  /// reference for "event date in the past".
  String? validate({required DateTime today}) {
    if (weekdays.length < 3) return 'Pick at least three training days.';
    if (weeklyHours <= 0) return 'Weekly hours must be above zero.';
    if (!sports.contains(sport)) return 'Unsupported sport "$sport".';
    final chosen = weeks;
    if (chosen != null && (chosen < minWeeks || chosen > maxWeeks)) {
      return 'A plan has $minWeeks to $maxWeeks weeks.';
    }
    if (isTriathlon) {
      final total = triathlonSports.fold<int>(
        0,
        (sum, s) => sum + (sportMix[s] ?? 0),
      );
      if (total != 100) return 'The sport mix adds up to $total%, not 100%.';
      final bad = sportMix.entries.where(
        (e) =>
            !triathlonSports.contains(e.key) || e.value < 0 || e.value % 5 != 0,
      );
      if (bad.isNotEmpty) return 'Sport shares are 0-100% in 5% steps.';
    }
    for (final f in loadFactors) {
      if (f < minFactor - 1e-9 || f > maxFactor + 1e-9) {
        return 'Week load is 80% to 120% of the proposal.';
      }
    }
    final event = eventDate;
    if (event != null &&
        DateTime(event.year, event.month, event.day).isBefore(
          DateTime(today.year, today.month, today.day),
        )) {
      return 'The event date is in the past.';
    }
    return null;
  }

  Goal copyWith({
    String? targetType,
    Set<int>? weekdays,
    double? weeklyHours,
    String? sport,
    DateTime? eventDate,
    bool clearEventDate = false,
    double? baselineWeeklyLoad,
    double? maxWeeklyIncrease,
    double? maxCtlRamp,
    int? weeks,
    bool clearWeeks = false,
    Map<String, int>? sportMix,
    List<double>? loadFactors,
  }) => Goal(
    targetType: targetType ?? this.targetType,
    weekdays: weekdays ?? this.weekdays,
    weeklyHours: weeklyHours ?? this.weeklyHours,
    sport: sport ?? this.sport,
    eventDate: clearEventDate ? null : eventDate ?? this.eventDate,
    baselineWeeklyLoad: baselineWeeklyLoad ?? this.baselineWeeklyLoad,
    maxWeeklyIncrease: maxWeeklyIncrease ?? this.maxWeeklyIncrease,
    maxCtlRamp: maxCtlRamp ?? this.maxCtlRamp,
    weeks: clearWeeks ? null : weeks ?? this.weeks,
    sportMix: sportMix ?? this.sportMix,
    loadFactors: loadFactors ?? this.loadFactors,
  );

  Map<String, dynamic> toJson() => {
    'targetType': targetType,
    'weekdays': weekdays.toList()..sort(),
    'weeklyHours': weeklyHours,
    'sport': sport,
    'eventDate': eventDate?.toIso8601String(),
    'baselineWeeklyLoad': baselineWeeklyLoad,
    'maxWeeklyIncrease': maxWeeklyIncrease,
    'maxCtlRamp': maxCtlRamp,
    'weeks': weeks,
    'sportMix': sportMix,
    'loadFactors': loadFactors,
  };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
    targetType: json['targetType'] as String,
    weekdays: {for (final d in json['weekdays'] as List) (d as num).toInt()},
    weeklyHours: (json['weeklyHours'] as num).toDouble(),
    sport: json['sport'] as String? ?? 'Run',
    eventDate: json['eventDate'] == null
        ? null
        : DateTime.parse(json['eventDate'] as String),
    baselineWeeklyLoad: (json['baselineWeeklyLoad'] as num?)?.toDouble(),
    maxWeeklyIncrease: (json['maxWeeklyIncrease'] as num?)?.toDouble(),
    maxCtlRamp: (json['maxCtlRamp'] as num?)?.toDouble(),
    weeks: (json['weeks'] as num?)?.toInt(),
    sportMix: json['sportMix'] == null
        ? defaultSportMix
        : {
            for (final e in (json['sportMix'] as Map<String, dynamic>).entries)
              e.key: (e.value as num).toInt(),
          },
    loadFactors: [
      for (final f in json['loadFactors'] as List? ?? const [])
        (f as num).toDouble(),
    ],
  );
}

/// Persists the single [Goal] in shared preferences — nothing secret, same
/// shape as the app's other settings.
class GoalStore {
  GoalStore();

  static const _key = 'plan.goal';

  Future<Goal?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return null;
      return Goal.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (error) {
      debugPrint('GoalStore: cannot read goal: $error');
      return null;
    }
  }

  Future<void> save(Goal goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(goal.toJson()));
  }
}

/// A limit on weekly load: what held a proposed week down, or what an
/// athlete-set week goes beyond.
enum WeekLimit { none, weeklyIncrease, ctlRamp, hours }

/// One session slot of a generated plan.
class PlanSession {
  const PlanSession({
    this.id,
    required this.weekIndex,
    required this.date,
    required this.slot,
    required this.templateId,
    required this.name,
    required this.sport,
    required this.minutes,
    required this.load,
    required this.lowMinutes,
    required this.description,
    this.intervalsEventId,
    this.calendarEventId,
    this.status = PlanSessionStatus.planned,
  });

  final int? id;
  final int weekIndex;
  final DateTime date;
  final SessionSlot slot;
  final String templateId;
  final String name;
  final String sport;
  final int minutes;

  /// Estimated TSS for the session as built.
  final int load;

  /// Minutes of [minutes] at low intensity (the 80/20 numerator).
  final double lowMinutes;

  /// The workout in Intervals.icu step syntax.
  final String description;

  final String? intervalsEventId;
  final String? calendarEventId;
  final PlanSessionStatus status;

  PlanSession copyWith({
    int? id,
    String? description,
    DateTime? date,
    String? intervalsEventId,
    String? calendarEventId,
    PlanSessionStatus? status,
  }) => PlanSession(
    id: id ?? this.id,
    weekIndex: weekIndex,
    date: date ?? this.date,
    slot: slot,
    templateId: templateId,
    name: name,
    sport: sport,
    minutes: minutes,
    load: load,
    lowMinutes: lowMinutes,
    description: description ?? this.description,
    intervalsEventId: intervalsEventId ?? this.intervalsEventId,
    calendarEventId: calendarEventId ?? this.calendarEventId,
    status: status ?? this.status,
  );
}

enum PlanSessionStatus { planned, created, failed }

/// One week of a plan: its phase, targets, sessions and 80/20 result.
class PlanWeek {
  const PlanWeek({
    required this.index,
    required this.phase,
    required this.startDate,
    required this.targetLoad,
    required this.requestedLoad,
    required this.limit,
    required this.projectedCtlEnd,
    required this.sessions,
    required this.lowIntensityTarget,
    required this.lowIntensityTolerance,
    this.factor = 1.0,
    this.warnings = const {},
  });

  final int index;
  final String phase;
  final DateTime startDate;

  /// The load the week is built for: the proposal times [factor].
  final double targetLoad;

  /// The proposed load for the week (the load curve's 100%).
  final double requestedLoad;

  /// What held the proposal down, if anything.
  final WeekLimit limit;

  /// The athlete's adjustment in the load graph, 0.80..1.20.
  final double factor;

  /// Limits the athlete-set [targetLoad] goes beyond. Shown, not enforced.
  final Set<WeekLimit> warnings;

  /// Planned load per Intervals.icu sport.
  Map<String, int> get loadBySport {
    final result = <String, int>{};
    for (final s in sessions) {
      result[s.sport] = (result[s.sport] ?? 0) + s.load;
    }
    return result;
  }

  /// CTL at the end of the week if the plan is followed; `null` without a
  /// current CTL to start from.
  final double? projectedCtlEnd;
  final List<PlanSession> sessions;
  final double lowIntensityTarget;
  final double lowIntensityTolerance;

  int get totalMinutes => sessions.fold(0, (sum, s) => sum + s.minutes);
  int get plannedLoad => sessions.fold(0, (sum, s) => sum + s.load);

  /// Share of planned time at low intensity, 0..1; `null` for an empty week.
  double? get lowShare {
    if (totalMinutes == 0) return null;
    final low = sessions.fold<double>(0, (sum, s) => sum + s.lowMinutes);
    return low / totalMinutes;
  }

  /// Flagged when the week has less easy time than the 80/20 target allows.
  /// More easy time than the target is not a problem.
  bool get outsideTolerance {
    final share = lowShare;
    return share != null && share < lowIntensityTarget - lowIntensityTolerance;
  }

  PlanWeek withSessions(List<PlanSession> sessions) => PlanWeek(
    index: index,
    phase: phase,
    startDate: startDate,
    targetLoad: targetLoad,
    requestedLoad: requestedLoad,
    limit: limit,
    projectedCtlEnd: projectedCtlEnd,
    sessions: sessions,
    lowIntensityTarget: lowIntensityTarget,
    lowIntensityTolerance: lowIntensityTolerance,
    factor: factor,
    warnings: warnings,
  );
}

/// A generated block of plan weeks.
class TrainingPlan {
  const TrainingPlan({
    this.id,
    required this.goalType,
    required this.sport,
    required this.startDate,
    required this.baselineLoad,
    required this.weeks,
    this.status = PlanStatus.draft,
    this.sportMix = const {},
  });

  final int? id;
  final String goalType;

  /// `Run`, `Ride` or `Triathlon`; sessions carry their own sport.
  final String sport;

  /// The triathlon mix the plan was built with; empty for one sport.
  final Map<String, int> sportMix;

  /// The Monday the block starts on.
  final DateTime startDate;
  final double baselineLoad;
  final List<PlanWeek> weeks;
  final PlanStatus status;

  Iterable<PlanSession> get sessions => weeks.expand((w) => w.sessions);

  TrainingPlan copyWith({int? id, PlanStatus? status, List<PlanWeek>? weeks}) =>
      TrainingPlan(
        id: id ?? this.id,
        goalType: goalType,
        sport: sport,
        startDate: startDate,
        baselineLoad: baselineLoad,
        weeks: weeks ?? this.weeks,
        status: status ?? this.status,
        sportMix: sportMix,
      );
}

enum PlanStatus { draft, active, removed }

/// Why no plan was generated.
enum PlanFailureKind { needsBaseline, invalidGoal, missingTemplate, notEnoughDays }

class PlanFailure {
  const PlanFailure(this.kind, this.message);

  final PlanFailureKind kind;
  final String message;
}

/// Either a plan or the reason there isn't one.
class PlanResult {
  const PlanResult.plan(TrainingPlan this.plan) : failure = null;
  const PlanResult.failure(PlanFailure this.failure) : plan = null;

  final TrainingPlan? plan;
  final PlanFailure? failure;
}
