import '../data/models/local_event.dart';
import '../evaluation/session_evaluator.dart' show sportFamily;
import '../util/dates.dart';

enum HealthKind { sick, injured }

/// A logged illness or injury: an Intervals.icu `SICK` / `INJURED` event.
class HealthIssue {
  const HealthIssue({
    required this.kind,
    required this.start,
    this.end,
    this.sport,
    this.name,
  });

  final HealthKind kind;
  final DateTime start;

  /// Last day of the issue; null while it is ongoing.
  final DateTime? end;

  /// For an injury: the sport family it affects (`run`, `ride`, `swim`),
  /// null when the event doesn't say (then everything is affected).
  final String? sport;
  final String? name;

  bool get ongoing => end == null;

  /// Days lost so far, or in total when [end] is known.
  int daysUntil(DateTime today) {
    final last = end ?? dateOnly(today);
    final n = dateOnly(last).difference(dateOnly(start)).inDays + 1;
    return n < 1 ? 1 : n;
  }

  /// Days of graded return after the issue ends: longer after a longer
  /// layoff, and 1.5× for an injury, which needs tissue to adapt.
  int rampDays(DateTime today) {
    final d = daysUntil(today);
    final base = d <= 3 ? 3 : (d <= 7 ? 7 : (d <= 14 ? 14 : 21));
    return kind == HealthKind.injured ? (base * 1.5).round() : base;
  }

  /// First day of normal training.
  DateTime? backToNormal(DateTime today) => end == null
      ? null
      : dateOnly(end!).add(Duration(days: rampDays(today) + 1));
}

enum HealthPhase { affected, returning }

/// The issue that matters on [today] — still on, or in its return ramp.
({HealthIssue issue, HealthPhase phase})? currentHealthIssue(
  Iterable<LocalEvent> events,
  DateTime today,
) {
  final day = dateOnly(today);
  ({HealthIssue issue, HealthPhase phase})? best;
  for (final e in events) {
    final kind = switch (e.category) {
      'SICK' => HealthKind.sick,
      'INJURED' => HealthKind.injured,
      _ => null,
    };
    final start = DateTime.tryParse(e.date);
    if (kind == null || start == null) continue;
    final end = DateTime.tryParse(e.raw['end_date_local'] as String? ?? '');
    final issue = HealthIssue(
      kind: kind,
      start: dateOnly(start),
      end: end == null ? null : dateOnly(end),
      sport: e.type == null ? null : sportFamily(e.type),
      name: e.name,
    );
    if (day.isBefore(issue.start)) continue;
    HealthPhase? phase;
    if (issue.end == null || !day.isAfter(issue.end!)) {
      phase = HealthPhase.affected;
    } else if (day.isBefore(issue.backToNormal(day)!)) {
      phase = HealthPhase.returning;
    }
    if (phase == null) continue;
    // Prefer an issue still on over one in its ramp, then the later start.
    if (best == null ||
        (phase == HealthPhase.affected &&
            best.phase == HealthPhase.returning) ||
        (phase == best.phase && issue.start.isAfter(best.issue.start))) {
      best = (issue: issue, phase: phase);
    }
  }
  return best;
}

enum ReturnAction {
  /// Drop the session.
  rest,

  /// Keep the sport, but shorter and easy.
  easier,

  /// Replace with an easy session in another sport.
  crossTrain,
}

enum ReturnReason { illness, injury, returnRamp }

/// One proposed change to a planned session. Nothing is applied here.
class ReturnChange {
  const ReturnChange({
    required this.session,
    required this.action,
    required this.reason,
    this.toSport,
    this.minutes,
    this.load,
  });

  final LocalEvent session;
  final ReturnAction action;
  final ReturnReason reason;

  /// For [ReturnAction.crossTrain]: the Intervals.icu type to do instead.
  final String? toSport;

  /// New duration and load for [easier] / [crossTrain].
  final int? minutes;
  final int? load;

  String get key => 'health:${session.id}';
}

/// TSS per hour of an easy aerobic session, for sizing replacements.
const easyLoadPerHour = 45.0;

/// Sessions at or above this TSS/h count as hard.
const hardLoadPerHour = 65.0;

bool isHardSession(LocalEvent e) {
  final secs = e.plannedTime ?? 0;
  final load = e.plannedLoad ?? 0;
  if (secs < 600) return false;
  return load / (secs / 3600) >= hardLoadPerHour;
}

String _alternative(String sport, String? avoid) {
  final options = switch (sportFamily(sport)) {
    'run' => ['Ride', 'Swim'],
    'ride' => ['Swim', 'Run'],
    'swim' => ['Ride', 'Run'],
    _ => ['Ride', 'Swim'],
  };
  for (final o in options) {
    if (sportFamily(o) != avoid) return o;
  }
  return options.first;
}

/// The planned sessions from [today] on that [issue] should change, and
/// how. Rules:
///
/// * **Sick, still on:** every training session is dropped (races are left
///   for the athlete to decide).
/// * **Injured, still on:** sessions in the affected sport (all sport if the
///   event names none) become easy cross-training in another sport, same
///   duration, load ≈ 45 TSS/h.
/// * **Return ramp:** after the issue ends, load climbs linearly from 50 %
///   to 100 % over [HealthIssue.rampDays]; hard sessions in the first half
///   become easy; an injury ramp only touches the affected sport.
List<ReturnChange> returnToTraining({
  required HealthIssue issue,
  required Iterable<LocalEvent> planned,
  required DateTime today,
}) {
  final day = dateOnly(today);
  final changes = <ReturnChange>[];
  final ramp = issue.rampDays(day);
  final affectedEnd = issue.end;

  for (final e in planned) {
    if (!e.isTraining || e.category != 'WORKOUT') continue;
    final d = DateTime.tryParse(e.date);
    if (d == null) continue;
    final sessionDay = dateOnly(d);
    if (sessionDay.isBefore(day) || sessionDay.isBefore(issue.start)) continue;
    final family = sportFamily(e.type);
    final affectsSport =
        issue.kind == HealthKind.sick ||
        issue.sport == null ||
        issue.sport == family;
    final minutes = ((e.plannedTime ?? 0) / 60).round();
    final load = e.plannedLoad ?? 0;

    final during = affectedEnd == null || !sessionDay.isAfter(affectedEnd);
    if (during) {
      if (issue.kind == HealthKind.sick) {
        changes.add(
          ReturnChange(
            session: e,
            action: ReturnAction.rest,
            reason: ReturnReason.illness,
          ),
        );
      } else if (affectsSport) {
        final to = _alternative(e.type ?? 'Run', issue.sport);
        changes.add(
          ReturnChange(
            session: e,
            action: minutes > 0 ? ReturnAction.crossTrain : ReturnAction.rest,
            reason: ReturnReason.injury,
            toSport: to,
            minutes: minutes,
            load: (minutes / 60 * easyLoadPerHour).round(),
          ),
        );
      }
      continue;
    }

    // Return ramp.
    if (!affectsSport) continue;
    final into = sessionDay.difference(dateOnly(affectedEnd)).inDays; // 1..
    if (into > ramp) continue;
    final factor = 0.5 + 0.5 * ((into - 1) / ramp);
    final hard = isHardSession(e);
    final easy = hard && into <= ramp / 2;
    final newMinutes = (minutes * factor).round();
    if (newMinutes < 10) {
      changes.add(
        ReturnChange(
          session: e,
          action: ReturnAction.rest,
          reason: ReturnReason.returnRamp,
        ),
      );
      continue;
    }
    // Skip a session that already fits the ramp (easy and short enough).
    if (!easy && factor >= 0.97) continue;
    changes.add(
      ReturnChange(
        session: e,
        action: ReturnAction.easier,
        reason: ReturnReason.returnRamp,
        minutes: newMinutes,
        load: easy
            ? (newMinutes / 60 * easyLoadPerHour).round()
            : (load * factor).round(),
      ),
    );
  }
  changes.sort((a, b) => a.session.date.compareTo(b.session.date));
  return changes;
}
