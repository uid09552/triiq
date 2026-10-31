import 'dart:math' as math;

import '../data/models/local_activity.dart';
import '../data/models/local_event.dart';
import 'intensity.dart';
import 'session_evaluator.dart';

/// What a best effort measures.
enum BestEffortKind { power, pace, time, other }

/// One best effort Intervals.icu flagged on an activity — its own figure,
/// never computed here.
class BestEffort {
  const BestEffort({
    required this.kind,
    required this.value,
    this.seconds,
    this.distance,
    this.previous,
    this.label,
  });

  final BestEffortKind kind;

  /// Watts for power; seconds for a time over a distance; metres/second or
  /// seconds/km for pace as Intervals.icu reports it.
  final double value;

  /// Duration the effort is over (power bests), in seconds.
  final int? seconds;

  /// Distance the effort is over (time bests), in metres.
  final double? distance;

  /// The best before this one, when reported.
  final double? previous;

  /// Intervals.icu's own wording, when it gives one.
  final String? label;
}

/// Best efforts from an activity's `icu_achievements`. The payload's shape
/// isn't part of our API spec, so this reads it defensively: a list of maps
/// with a type and a value plus a duration or distance; anything it doesn't
/// recognise is skipped, never thrown.
List<BestEffort> personalBests(Map<String, dynamic> raw) {
  final list = raw['icu_achievements'];
  if (list is! List) return const [];
  final result = <BestEffort>[];
  for (final item in list) {
    if (item is! Map) continue;
    final type = '${item['type'] ?? item['kind'] ?? ''}'.toUpperCase();
    final value = _num(item['value'] ?? item['watts'] ?? item['secs_value']);
    if (value == null) continue;
    final seconds = _num(item['secs'] ?? item['duration'])?.toInt();
    final distance = _num(item['distance'] ?? item['meters']);
    final kind = type.contains('POWER')
        ? BestEffortKind.power
        : type.contains('PACE')
        ? BestEffortKind.pace
        : type.contains('TIME') || (distance != null && seconds == null)
        ? BestEffortKind.time
        : BestEffortKind.other;
    if (kind == BestEffortKind.power && seconds == null) continue;
    result.add(
      BestEffort(
        kind: kind,
        value: value,
        seconds: seconds,
        distance: distance,
        previous: _num(item['previous'] ?? item['prev_value'] ?? item['prev']),
        label: item['message'] as String? ?? item['label'] as String?,
      ),
    );
  }
  return result;
}

double? _num(Object? v) => v is num ? v.toDouble() : null;

/// An easy session's efficiency factor against recent easy sessions.
class EfficiencyTrend {
  const EfficiencyTrend({
    required this.value,
    required this.median,
    required this.sessions,
  });

  /// This session's efficiency factor (power or speed per heart rate).
  final double value;

  /// Median of the earlier easy sessions; `null` when there were too few.
  final double? median;

  /// How many earlier easy sessions went into [median].
  final int sessions;

  /// Change against the median, as a fraction.
  double? get change => median == null || median == 0 ? null : value / median! - 1;
}

/// Is [a] an easy session — planned easy, or mostly at low intensity?
bool isEasySession(LocalActivity a, {LocalEvent? planned}) {
  if (planned != null) {
    final intent = SessionEvaluator.intentOf(planned);
    if (intent == SessionIntent.easy) return true;
    if (intent == SessionIntent.hard) return false;
  }
  return (intensityOf(a.raw)?.lowShare ?? 0) >= 0.8;
}

const efficiencyWindowDays = 42;
const efficiencyMinSessions = 4;

double? efficiencyFactorOf(LocalActivity a) =>
    _num(a.raw['icu_efficiency_factor']);

/// [activity]'s efficiency factor against the median of the same sport's
/// easy sessions in the [efficiencyWindowDays] before it — only for an easy
/// session with a factor; the median only with at least
/// [efficiencyMinSessions] of them. [history] may include anything; it is
/// filtered here.
EfficiencyTrend? efficiencyTrend(
  LocalActivity activity,
  Iterable<LocalActivity> history, {
  LocalEvent? planned,
}) {
  final value = efficiencyFactorOf(activity);
  if (value == null || !isEasySession(activity, planned: planned)) return null;
  final day = DateTime.tryParse(activity.date);
  if (day == null) return null;
  final from = day.subtract(const Duration(days: efficiencyWindowDays));
  final family = sportFamily(activity.type);
  final values = <double>[];
  for (final h in history) {
    if (h.id == activity.id || sportFamily(h.type) != family) continue;
    final d = DateTime.tryParse(h.date);
    if (d == null || d.isBefore(from) || !d.isBefore(day)) continue;
    final ef = efficiencyFactorOf(h);
    if (ef == null || !isEasySession(h)) continue;
    values.add(ef);
  }
  if (values.length < efficiencyMinSessions) {
    return EfficiencyTrend(value: value, median: null, sessions: values.length);
  }
  values.sort();
  final mid = values.length ~/ 2;
  final median = values.length.isOdd
      ? values[mid]
      : (values[mid - 1] + values[mid]) / 2;
  return EfficiencyTrend(value: value, median: median, sessions: values.length);
}

/// One band of the recovery rule: sessions up to [maxTss] need [hours]
/// (`null` [maxTss] = everything above the last band).
class RecoveryBand {
  const RecoveryBand(this.maxTss, this.hours);
  final int? maxTss;
  final int hours;
}

/// The recovery rule from the training knowledge (`okf-rules`).
class RecoveryRules {
  const RecoveryRules({
    this.bands = const [
      RecoveryBand(50, 12),
      RecoveryBand(100, 24),
      RecoveryBand(200, 36),
      RecoveryBand(null, 48),
    ],
    this.formPenaltyBelow = -20,
    this.formPenaltyHours = 12,
    this.maxHours = 72,
  });

  final List<RecoveryBand> bands;

  /// Form (CTL − ATL) below which [formPenaltyHours] are added.
  final double formPenaltyBelow;
  final int formPenaltyHours;
  final int maxHours;
}

/// An estimate of how long a session takes to recover from, and whether
/// that runs into a hard session planned for tomorrow.
class RecoveryHint {
  const RecoveryHint({
    required this.hours,
    required this.tss,
    required this.form,
    required this.penalised,
    this.conflict,
  });

  final int hours;
  final int tss;
  final double? form;

  /// Whether low form added hours.
  final bool penalised;

  /// Tomorrow's hard session the recovery runs into, if any.
  final LocalEvent? conflict;
}

/// Tomorrow's day starts mattering at this hour.
const _tomorrowStartsHour = 10;

/// [tss] done, ending at [endedAt], with [form] now: how long to recover,
/// and does it reach into a hard session in [tomorrow]'s plan?
RecoveryHint recoveryHint({
  required int tss,
  required double? form,
  required DateTime endedAt,
  Iterable<LocalEvent> tomorrow = const [],
  RecoveryRules rules = const RecoveryRules(),
}) {
  var hours = rules.bands.last.hours;
  for (final band in rules.bands) {
    if (band.maxTss == null || tss <= band.maxTss!) {
      hours = band.hours;
      break;
    }
  }
  final penalised = form != null && form < rules.formPenaltyBelow;
  if (penalised) hours += rules.formPenaltyHours;
  hours = math.min(hours, rules.maxHours);

  final nextDay = DateTime(endedAt.year, endedAt.month, endedAt.day + 1);
  final busyUntil = endedAt.add(Duration(hours: hours));
  LocalEvent? conflict;
  if (busyUntil.isAfter(nextDay.add(const Duration(hours: _tomorrowStartsHour)))) {
    for (final e in tomorrow) {
      if (e.isTraining && SessionEvaluator.intentOf(e) == SessionIntent.hard) {
        conflict = e;
        break;
      }
    }
  }
  return RecoveryHint(
    hours: hours,
    tss: tss,
    form: form,
    penalised: penalised,
    conflict: conflict,
  );
}
