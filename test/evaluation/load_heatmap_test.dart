import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/evaluation/load_heatmap.dart';
import 'package:triiq/evaluation/training_analytics.dart';

LocalActivity act(String date, int tss, {String type = 'Ride'}) =>
    LocalActivity(
      id: '$date$type$tss',
      date: date,
      type: type,
      name: null,
      movingTime: 3600,
      distance: null,
      trainingLoad: tss,
      raw: const {},
      syncedAt: DateTime(2026),
    );

void main() {
  // 2026-10-05 is a Monday.
  final from = DateTime(2026, 10, 7); // a Wednesday
  final to = DateTime(2026, 10, 20); // a Tuesday

  test('grid: Monday-first weeks, padding days outside the period', () {
    final h = buildLoadHeatmap(const [], from: from, to: to);
    expect(h.weeks, hasLength(3)); // weeks of Oct 5, 12, 19
    expect(h.weeks.first.first.date, DateTime(2026, 10, 5));
    expect(h.weeks.first.first.inRange, isFalse); // Mon Oct 5 before the period
    expect(h.weeks.first[2].inRange, isTrue); // Wed Oct 7
    expect(h.weeks.last.last.inRange, isFalse); // Sun Oct 25 after
    expect(h.weeks.every((w) => w.length == 7), isTrue);
  });

  test('sums the day, counts sessions, ignores outside the period', () {
    final h = buildLoadHeatmap(
      [
        act('2026-10-08', 50),
        act('2026-10-08', 30, type: 'Run'),
        act('2026-10-01', 99), // before
        act('2026-10-21', 99), // after
      ],
      from: from,
      to: to,
    );
    final d = h.dayOn(DateTime(2026, 10, 8))!;
    expect(d.tss, 80);
    expect(d.sessions, 2);
    expect(h.totalTss, 80);
    expect(h.dayOn(DateTime(2026, 10, 5)), isNull); // padding
  });

  test('sport filter keeps one sport', () {
    final acts = [act('2026-10-08', 50), act('2026-10-09', 30, type: 'Run')];
    final h = buildLoadHeatmap(acts, from: from, to: to, sport: LoadSport.run);
    expect(h.totalTss, 30);
    expect(h.activeDays, 1);
  });

  test('levels scale to the 90th percentile of training days', () {
    final h = buildLoadHeatmap(
      [for (var i = 0; i < 10; i++) act('2026-10-${8 + i}', 10 * (i + 1))],
      from: from,
      to: to,
    );
    // Loads 10..100; the 90th percentile index (9 * .9 = 8.1 -> 8) is 90.
    expect(h.reference, 90);
    expect(h.levelOf(0), 0);
    expect(h.levelOf(10), 1);
    expect(h.levelOf(30), 2);
    expect(h.levelOf(60), 3);
    expect(h.levelOf(100), 4);
  });

  test('streak, active days and busiest week', () {
    final h = buildLoadHeatmap(
      [
        act('2026-10-08', 40),
        act('2026-10-09', 40),
        act('2026-10-10', 40),
        act('2026-10-14', 100),
        act('2026-10-15', 100),
      ],
      from: from,
      to: to,
    );
    expect(h.activeDays, 5);
    expect(h.longestStreak, 3);
    expect(h.busiestWeekStart, DateTime(2026, 10, 12));
    expect(h.busiestWeekTss, 200);
  });

  test('empty period: nothing to colour', () {
    final h = buildLoadHeatmap(const [], from: from, to: to);
    expect(h.totalTss, 0);
    expect(h.reference, 1);
    expect(h.busiestWeekStart, isNull);
    expect(h.levelOf(0), 0);
  });
}
