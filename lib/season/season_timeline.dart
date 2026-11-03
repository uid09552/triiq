import '../util/dates.dart';

/// A race on the calendar. [priority] is `A`, `B` or `C` (Intervals.icu's
/// `RACE_A/B/C`).
class SeasonRace {
  const SeasonRace({
    required this.date,
    required this.name,
    required this.priority,
    this.sport,
  });

  final DateTime date;
  final String name;
  final String priority;
  final String? sport;

  bool get isA => priority == 'A';

  /// Days of reduced load before the race.
  int get taperDays => switch (priority) {
    'A' => 14,
    'B' => 7,
    _ => 2,
  };

  /// Days of easy training after it before the next build.
  int get recoveryDays => switch (priority) {
    'A' => 10,
    'B' => 5,
    _ => 2,
  };
}

enum BlockKind { base, build, taper, race, recovery }

class SeasonBlock {
  const SeasonBlock({
    required this.kind,
    required this.start,
    required this.end,
    this.race,
  });

  final BlockKind kind;

  /// First and last day, inclusive.
  final DateTime start;
  final DateTime end;

  /// The race a taper / race / recovery block belongs to.
  final SeasonRace? race;

  int get days => end.difference(start).inDays + 1;
}

enum ConflictKind {
  /// Two A races too close to peak for both.
  tooCloseA,

  /// A race inside the taper window of a more important race.
  insideTaper,

  /// Two races on the same day.
  sameDay,

  /// A race inside the recovery window of a previous A/B race.
  insideRecovery,

  /// A race that falls in an illness / injury period.
  duringIllness,
}

class SeasonConflict {
  const SeasonConflict(this.kind, this.first, [this.second]);

  final ConflictKind kind;
  final SeasonRace first;
  final SeasonRace? second;
}

/// Minimum days between two A races for each to get its own taper.
const minDaysBetweenA = 42;

/// Lays out the season from [from] to the last race: for each race a taper
/// before it, the race day and a recovery after it, with build (or base,
/// before the first race when it is far off) in between. Races in the past
/// (before [from]) are ignored. Overlapping windows are clipped, never
/// duplicated.
List<SeasonBlock> buildSeason(
  List<SeasonRace> races,
  DateTime from, {
  int baseWeeksBeforeFirstBuild = 0,
}) {
  final start = dateOnly(from);
  final upcoming = [
    for (final r in races)
      if (!dateOnly(r.date).isBefore(start)) r,
  ]..sort((a, b) => a.date.compareTo(b.date));
  final blocks = <SeasonBlock>[];
  var cursor = start;

  void add(BlockKind kind, DateTime s, DateTime e, [SeasonRace? race]) {
    if (e.isBefore(s)) return;
    blocks.add(SeasonBlock(kind: kind, start: s, end: e, race: race));
  }

  for (final race in upcoming) {
    final day = dateOnly(race.date);
    if (day.isBefore(cursor)) continue; // swallowed by an earlier block
    var taperStart = day.subtract(Duration(days: race.taperDays));
    if (taperStart.isBefore(cursor)) taperStart = cursor;
    final buildEnd = taperStart.subtract(const Duration(days: 1));
    if (blocks.isEmpty && baseWeeksBeforeFirstBuild > 0) {
      final baseEnd = cursor.add(Duration(days: baseWeeksBeforeFirstBuild * 7 - 1));
      if (baseEnd.isBefore(buildEnd)) {
        add(BlockKind.base, cursor, baseEnd);
        cursor = baseEnd.add(const Duration(days: 1));
      }
    }
    add(BlockKind.build, cursor, buildEnd);
    add(BlockKind.taper, taperStart, day.subtract(const Duration(days: 1)), race);
    add(BlockKind.race, day, day, race);
    final recoveryEnd = day.add(Duration(days: race.recoveryDays));
    add(BlockKind.recovery, day.add(const Duration(days: 1)), recoveryEnd, race);
    cursor = recoveryEnd.add(const Duration(days: 1));
  }
  return blocks;
}

/// Problems with the race calendar: clashes the athlete should resolve by
/// moving or demoting a race. Optional [illness] windows (inclusive
/// first/last day) flag races that fall inside one.
List<SeasonConflict> findConflicts(
  List<SeasonRace> races, {
  List<({DateTime start, DateTime end})> illness = const [],
}) {
  final sorted = [...races]..sort((a, b) => a.date.compareTo(b.date));
  final out = <SeasonConflict>[];
  for (var i = 0; i < sorted.length; i++) {
    final a = sorted[i];
    for (var j = i + 1; j < sorted.length; j++) {
      final b = sorted[j];
      final gap = dateOnly(b.date).difference(dateOnly(a.date)).inDays;
      if (gap == 0) {
        out.add(SeasonConflict(ConflictKind.sameDay, a, b));
      } else if (a.isA && b.isA && gap < minDaysBetweenA) {
        out.add(SeasonConflict(ConflictKind.tooCloseA, a, b));
      } else if (a.priority != 'C' && gap <= a.recoveryDays) {
        // b falls in a's recovery window.
        out.add(SeasonConflict(ConflictKind.insideRecovery, a, b));
      } else if (b.priority != 'C' &&
          b.priority.compareTo(a.priority) <= 0 &&
          gap <= b.taperDays) {
        // a is no more important than b and sits in b's taper.
        out.add(SeasonConflict(ConflictKind.insideTaper, b, a));
      }
    }
    for (final w in illness) {
      final d = dateOnly(a.date);
      if (!d.isBefore(dateOnly(w.start)) && !d.isAfter(dateOnly(w.end))) {
        out.add(SeasonConflict(ConflictKind.duringIllness, a));
      }
    }
  }
  return out;
}

/// Weeks (rounded up) between [from] and the race, for "N weeks to go".
int weeksTo(DateTime from, DateTime race) =>
    (dateOnly(race).difference(dateOnly(from)).inDays / 7).ceil();

/// Convenience used by the services: races from `RACE_A/B/C` events.
SeasonRace? raceFromEvent({
  required String? category,
  required String date,
  required String? name,
  required String? type,
}) {
  final priority = switch (category) {
    'RACE_A' => 'A',
    'RACE_B' => 'B',
    'RACE_C' => 'C',
    _ => null,
  };
  final day = DateTime.tryParse(date);
  if (priority == null || day == null) return null;
  return SeasonRace(
    date: dateOnly(day),
    name: (name == null || name.isEmpty) ? 'Race $priority' : name,
    priority: priority,
    sport: type,
  );
}
