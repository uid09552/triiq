import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/season/fitness_forecast.dart';
import 'package:triiq/season/season_timeline.dart';

void main() {
  group('forecastFitness', () {
    test('rest days decay CTL slowly and ATL fast', () {
      final days = forecastFitness(
        startCtl: 60, startAtl: 80,
        lastKnownDay: DateTime(2026, 5, 1),
        until: DateTime(2026, 5, 8),
        loadByDate: const {},
      );
      expect(days, hasLength(7));
      expect(days.last.ctl, closeTo(60 * 0.847, 1.5)); // e^(-7/42)
      expect(days.last.atl, closeTo(80 * 0.368, 1.5)); // e^(-1)
      expect(days.last.form, greaterThan(0));
    });

    test('planned load pushes ATL up faster than CTL', () {
      final days = forecastFitness(
        startCtl: 50, startAtl: 50,
        lastKnownDay: DateTime(2026, 5, 1),
        until: DateTime(2026, 5, 4),
        loadByDate: const {'2026-05-02': 150, '2026-05-03': 150},
      );
      expect(days[1].atl - 50, greaterThan(days[1].ctl - 50));
      expect(days[1].form, lessThan(0));
      expect(days.first.load, 150);
    });

    test('beyond the plan the load is assumed, so CTL does not decay to zero', () {
      final days = forecastFitness(
        startCtl: 60, startAtl: 60,
        lastKnownDay: DateTime(2026, 5, 1),
        until: DateTime(2026, 10, 1),
        loadByDate: const {'2026-05-02': 80},
        assumeFrom: DateTime(2026, 5, 3),
        assumedLoad: 60,
      );
      expect(days.first.assumed, isFalse);
      expect(days[1].assumed, isTrue);
      expect(days.last.ctl, closeTo(60, 3));
      expect(days.last.form.abs(), lessThan(3));
    });

    test('forecastOn and peakForm find the day', () {
      final days = forecastFitness(
        startCtl: 70, startAtl: 90,
        lastKnownDay: DateTime(2026, 5, 1),
        until: DateTime(2026, 5, 20),
        loadByDate: const {},
      );
      expect(forecastOn(days, DateTime(2026, 5, 10))!.date.day, 10);
      expect(forecastOn(days, DateTime(2026, 6, 1)), isNull);
      final peak = peakForm(days, DateTime(2026, 5, 2), DateTime(2026, 5, 20))!;
      expect(days.every((d) => d.form <= peak.form), isTrue);
      expect(peak.form, greaterThan(0));
      expect(peakForm(days, DateTime(2026, 7, 1), DateTime(2026, 7, 2)), isNull);
    });

    test('form bands', () {
      expect(formBand(-20), FormBand.loaded);
      expect(formBand(0), FormBand.neutral);
      expect(formBand(12), FormBand.fresh);
      expect(formBand(40), FormBand.detrained);
    });
  });

  group('season', () {
    final a = SeasonRace(
      date: DateTime(2026, 9, 20), name: 'Ironman', priority: 'A',
    );
    final b = SeasonRace(
      date: DateTime(2026, 7, 5), name: 'Half', priority: 'B',
    );

    test('blocks run build → taper → race → recovery per race', () {
      final blocks = buildSeason([a, b], DateTime(2026, 6, 1));
      final kinds = [for (final x in blocks) x.kind];
      expect(kinds, [
        BlockKind.build, BlockKind.taper, BlockKind.race, BlockKind.recovery,
        BlockKind.build, BlockKind.taper, BlockKind.race, BlockKind.recovery,
      ]);
      expect(blocks[1].days, 7); // B taper
      expect(blocks[5].days, 14); // A taper
      expect(blocks[2].start, DateTime(2026, 7, 5));
      // No overlaps.
      for (var i = 1; i < blocks.length; i++) {
        expect(blocks[i].start.isAfter(blocks[i - 1].end), isTrue);
      }
    });

    test('past races are ignored and base is added when asked', () {
      final blocks = buildSeason(
        [a, SeasonRace(date: DateTime(2026, 1, 1), name: 'x', priority: 'C')],
        DateTime(2026, 5, 1),
        baseWeeksBeforeFirstBuild: 4,
      );
      expect(blocks.first.kind, BlockKind.base);
      expect(blocks.first.days, 28);
      expect(blocks.where((x) => x.kind == BlockKind.race), hasLength(1));
    });

    test('conflicts: two close A races, a C inside an A taper, same day', () {
      final a2 = SeasonRace(
        date: DateTime(2026, 10, 18), name: 'Marathon', priority: 'A',
      );
      final c = SeasonRace(
        date: DateTime(2026, 9, 10), name: 'Fun run', priority: 'C',
      );
      final dup = SeasonRace(date: a.date, name: 'Other', priority: 'B');
      final kinds = [
        for (final x in findConflicts([a, a2, c, dup])) x.kind,
      ];
      expect(kinds, contains(ConflictKind.tooCloseA));
      expect(kinds, contains(ConflictKind.insideTaper));
      expect(kinds, contains(ConflictKind.sameDay));
    });

    test('a race after a B race is inside its recovery', () {
      final c = SeasonRace(
        date: DateTime(2026, 7, 8), name: 'Fun', priority: 'C',
      );
      expect(
        [for (final x in findConflicts([b, c])) x.kind],
        [ConflictKind.insideRecovery],
      );
    });

    test('far-apart races and races outside illness do not conflict', () {
      expect(findConflicts([a, b]), isEmpty);
      expect(
        findConflicts(
          [a],
          illness: [(start: DateTime(2026, 9, 1), end: DateTime(2026, 9, 5))],
        ),
        isEmpty,
      );
      expect(
        findConflicts(
          [a],
          illness: [(start: DateTime(2026, 9, 18), end: DateTime(2026, 9, 25))],
        ).single.kind,
        ConflictKind.duringIllness,
      );
    });

    test('raceFromEvent reads the category', () {
      final r = raceFromEvent(
        category: 'RACE_B', date: '2026-07-05', name: null, type: 'Run',
      );
      expect(r!.priority, 'B');
      expect(r.name, 'Race B');
      expect(
        raceFromEvent(category: 'NOTE', date: '2026-07-05', name: 'x', type: null),
        isNull,
      );
    });
  });
}
