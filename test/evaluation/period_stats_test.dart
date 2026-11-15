import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/evaluation/period_stats.dart';

StatRow row(
  String id,
  String date,
  StatSport sport, {
  int minutes = 60,
  double km = 20,
  int tss = 50,
}) => StatRow(
  id: id,
  date: date,
  sport: sport,
  seconds: minutes * 60,
  meters: km * 1000,
  tss: tss,
);

void main() {
  group('statSportOf', () {
    test('folds types like the calendar filter', () {
      expect(statSportOf('Swim'), StatSport.swim);
      expect(statSportOf('OpenWaterSwim'), StatSport.swim);
      expect(statSportOf('VirtualRide'), StatSport.ride);
      expect(statSportOf('GravelRide'), StatSport.ride);
      expect(statSportOf('TrailRun'), StatSport.run);
      expect(statSportOf('WeightTraining'), StatSport.strength);
      expect(statSportOf('Yoga'), StatSport.strength);
      expect(statSportOf('Pilates'), StatSport.strength);
      expect(statSportOf('Rowing'), StatSport.other);
      expect(statSportOf(null), StatSport.other);
    });
  });

  group('totalsBySport', () {
    test('sums per sport inside the inclusive range only', () {
      final rows = [
        row('a', '2026-11-01', StatSport.run, minutes: 30, km: 5, tss: 30),
        row('b', '2026-11-30', StatSport.run, minutes: 90, km: 15, tss: 80),
        row('c', '2026-10-31', StatSport.run),
        row('d', '2026-12-01', StatSport.ride),
        row('e', '2026-11-15', StatSport.swim, minutes: 45, km: 2, tss: 40),
      ];
      final t = totalsBySport(rows, from: '2026-11-01', to: '2026-11-30');
      expect(t.keys.toSet(), {StatSport.run, StatSport.swim});
      expect(t[StatSport.run]!.sessions, 2);
      expect(t[StatSport.run]!.hours, 2);
      expect(t[StatSport.run]!.km, 20);
      expect(t[StatSport.run]!.tss, 110);
      expect(t[StatSport.swim]!.sessions, 1);
    });

    test(
      'strength counts as sessions and time but not in the endurance total',
      () {
        final t = totalsBySport(
          [
            row('a', '2026-03-01', StatSport.ride, km: 40),
            row(
              'b',
              '2026-03-02',
              StatSport.strength,
              minutes: 45,
              km: 0,
              tss: 20,
            ),
          ],
          from: '2026-01-01',
          to: '2026-12-31',
        );
        expect(t[StatSport.strength]!.sessions, 1);
        expect(t[StatSport.strength]!.hours, 0.75);
        final total = enduranceTotal(t);
        expect(total.sessions, 1);
        expect(total.km, 40);
        expect(total.tss, 50);
      },
    );

    test('missing distance, time and load count as zero', () {
      final t = totalsBySport(
        [const StatRow(id: 'x', date: '2026-05-05', sport: StatSport.other)],
        from: '2026-05-05',
        to: '2026-05-05',
      );
      expect(t[StatSport.other], const SportTotals(sessions: 1));
    });
  });

  test('changePercent never invents a figure from zero', () {
    expect(changePercent(110, 100), closeTo(10, 1e-9));
    expect(changePercent(50, 100), closeTo(-50, 1e-9));
    expect(changePercent(10, 0), isNull);
    expect(changePercent(0, 0), isNull);
  });

  group('sameDayInYear', () {
    test('29 February falls back to the 28th', () {
      expect(sameDayInYear(2027, 2, 29), DateTime(2027, 2, 28));
      expect(sameDayInYear(2028, 2, 29), DateTime(2028, 2, 29));
      expect(sameDayInYear(2025, 3, 31), DateTime(2025, 3, 31));
    });
  });

  group('computeYearStats', () {
    const full = SyncCoverage(oldest: '2000-01-01', newest: '2026-11-15');
    final rows = [
      // this year
      row('a', '2026-01-01', StatSport.run, minutes: 60, km: 10),
      row('b', '2026-11-15', StatSport.run, minutes: 60, km: 10),
      row('c', '2026-11-16', StatSport.run, minutes: 60, km: 10), // future
      row('s', '2026-06-01', StatSport.strength, minutes: 30, km: 0),
      // last year
      row('d', '2025-01-01', StatSport.run, minutes: 60, km: 8),
      row('e', '2025-11-15', StatSport.run, minutes: 120, km: 20),
      row('f', '2025-11-16', StatSport.run, minutes: 600, km: 100),
      row('g', '2025-12-31', StatSport.ride, minutes: 60, km: 30),
    ];

    test('year to date and the same period last year', () {
      final y = computeYearStats(
        rows,
        year: 2026,
        today: DateTime(2026, 11, 15, 23, 59),
        coverage: full,
      );
      expect(y.from, '2026-01-01');
      expect(y.to, '2026-11-15');
      expect(y.of(StatSport.run).sessions, 2);
      expect(y.of(StatSport.run).km, 20);
      expect(y.lastYearTo, '2025-11-15');
      // 16 November onwards of last year is not part of the comparison.
      expect(y.lastOf(StatSport.run)!.sessions, 2);
      expect(y.lastOf(StatSport.run)!.hours, 3);
      expect(y.lastOf(StatSport.ride)!.isEmpty, isTrue);
      expect(y.isPartial, isFalse);
      expect(y.total.sessions, 2);
      expect(y.lastTotal!.sessions, 2);
      expect(y.sports, [StatSport.run, StatSport.strength]);
    });

    test(
      'a past year is the whole year, compared with the whole year before',
      () {
        final y = computeYearStats(
          rows,
          year: 2025,
          today: DateTime(2026, 11, 15),
          coverage: full,
        );
        expect(y.to, '2025-12-31');
        expect(y.of(StatSport.run).sessions, 3);
        expect(y.of(StatSport.ride).km, 30);
        expect(y.lastYearTo, '2024-12-31');
        expect(y.lastOf(StatSport.run)!.isEmpty, isTrue);
      },
    );

    test('leap day: 29 Feb compares with 28 Feb of a normal year', () {
      final y = computeYearStats(
        [
          row('a', '2027-02-28', StatSport.run),
          row('b', '2027-03-01', StatSport.run),
          row('c', '2028-02-29', StatSport.run),
        ],
        year: 2028,
        today: DateTime(2028, 2, 29),
        coverage: const SyncCoverage(oldest: '2020-01-01'),
      );
      expect(y.lastYearTo, '2027-02-28');
      expect(y.of(StatSport.run).sessions, 1);
      expect(y.lastOf(StatSport.run)!.sessions, 1);
    });

    test('1 January: the year so far is a single day', () {
      final y = computeYearStats(
        [
          row('a', '2026-01-01', StatSport.ride),
          row('b', '2025-01-01', StatSport.ride),
        ],
        year: 2026,
        today: DateTime(2026, 1, 1),
        coverage: full,
      );
      expect(y.to, '2026-01-01');
      expect(y.of(StatSport.ride).sessions, 1);
      expect(y.lastOf(StatSport.ride)!.sessions, 1);
    });

    test('a cache that starts after 1 January is flagged partial and not '
        'compared', () {
      final y = computeYearStats(
        rows,
        year: 2026,
        today: DateTime(2026, 11, 15),
        coverage: const SyncCoverage(oldest: '2026-09-01'),
      );
      expect(y.isPartial, isTrue);
      expect(y.partialSince, '2026-09-01');
      expect(y.lastYear, isNull);
      expect(y.lastTotal, isNull);
    });

    test('last year not synced: this year is complete, no comparison', () {
      final y = computeYearStats(
        rows,
        year: 2026,
        today: DateTime(2026, 11, 15),
        coverage: const SyncCoverage(oldest: '2026-01-01'),
      );
      expect(y.isPartial, isFalse);
      expect(y.lastYear, isNull);
    });

    test('unknown coverage makes no claims', () {
      final y = computeYearStats(
        rows,
        year: 2026,
        today: DateTime(2026, 11, 15),
      );
      expect(y.isPartial, isFalse);
      expect(y.lastYear, isNull);
      expect(y.of(StatSport.run).sessions, 2);
    });

    test('a future year is empty', () {
      final y = computeYearStats(
        rows,
        year: 2027,
        today: DateTime(2026, 11, 15),
        coverage: full,
      );
      expect(y.isEmpty, isTrue);
      expect(y.sports, isEmpty);
    });

    test('dates are plain days: a late evening session stays on its day', () {
      // StatRow.date is the cache's local day; no time zone can move it.
      final y = computeYearStats(
        [row('late', '2026-12-31', StatSport.run)],
        year: 2026,
        today: DateTime.utc(2027, 1, 1, 0, 30).toLocal(),
        coverage: full,
      );
      expect(y.of(StatSport.run).sessions, 1);
    });
  });

  group('sessionYearContext', () {
    final stats = computeYearStats(
      [
        row('a', '2026-02-01', StatSport.ride, km: 100, tss: 150),
        row('b', '2026-03-01', StatSport.ride, km: 60, tss: 80),
        row('c', '2026-04-01', StatSport.ride, km: 40, tss: 60),
        row('d', '2026-05-01', StatSport.ride, km: 80, tss: 100),
        row('r', '2026-05-02', StatSport.run, km: 10),
      ],
      year: 2026,
      today: DateTime(2026, 11, 15),
      coverage: const SyncCoverage(oldest: '2000-01-01'),
    );
    final rows = [
      row('a', '2026-02-01', StatSport.ride, km: 100, tss: 150),
      row('b', '2026-03-01', StatSport.ride, km: 60, tss: 80),
      row('c', '2026-04-01', StatSport.ride, km: 40, tss: 60),
      row('d', '2026-05-01', StatSport.ride, km: 80, tss: 100),
      row('r', '2026-05-02', StatSport.run, km: 10),
    ];

    test('share of the sport total and rank by distance', () {
      final ctx = sessionYearContext(rows[3], stats, rows)!;
      expect(ctx.sport, StatSport.ride);
      expect(ctx.total.km, 280);
      expect(ctx.shareByDistance, isTrue);
      expect(ctx.sharePercent, closeTo(80 / 280 * 100, 1e-9));
      expect(ctx.rank, 2);
      expect(ctx.rankOf, 4);
      expect(ctx.rankByDistance, isTrue);
    });

    test('the longest is number one', () {
      expect(sessionYearContext(rows[0], stats, rows)!.rank, 1);
    });

    test('without distance the share is of the time and rank is by TSS', () {
      final r = row('x', '2026-06-01', StatSport.ride, km: 0, tss: 90);
      final withX = [...rows, r];
      final s = computeYearStats(
        withX,
        year: 2026,
        today: DateTime(2026, 11, 15),
        coverage: const SyncCoverage(oldest: '2000-01-01'),
      );
      final ctx = sessionYearContext(r, s, withX)!;
      expect(ctx.shareByDistance, isFalse);
      expect(ctx.sharePercent, closeTo(60 / (5 * 60) * 100, 1e-9));
      expect(ctx.rankByDistance, isFalse);
      expect(ctx.rank, 3); // TSS 150, 100, then 90
    });

    test('strength: share of time, no rank', () {
      final r = row('y', '2026-06-02', StatSport.strength, km: 0);
      final withY = [...rows, r];
      final s = computeYearStats(
        withY,
        year: 2026,
        today: DateTime(2026, 11, 15),
        coverage: const SyncCoverage(oldest: '2000-01-01'),
      );
      final ctx = sessionYearContext(r, s, withY)!;
      expect(ctx.rank, isNull);
      expect(ctx.sharePercent, 100);
    });

    test('a session outside the period has no context', () {
      expect(
        sessionYearContext(row('z', '2026-12-24', StatSport.ride), stats, rows),
        isNull,
      );
    });

    test('hoursChange compares with last year when it is covered', () {
      final s = computeYearStats(
        [
          row('a', '2026-02-01', StatSport.ride, minutes: 120),
          row('p', '2025-02-01', StatSport.ride, minutes: 60),
        ],
        year: 2026,
        today: DateTime(2026, 11, 15),
        coverage: const SyncCoverage(oldest: '2000-01-01'),
      );
      final ctx = sessionYearContext(
        row('a', '2026-02-01', StatSport.ride, minutes: 120),
        s,
        const [],
      )!;
      expect(ctx.hoursChange, closeTo(100, 1e-9));
    });
  });
}
