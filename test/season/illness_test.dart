import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/season/illness_mode.dart';

LocalEvent ev(
  String id,
  String date, {
  String category = 'WORKOUT',
  String type = 'Run',
  int minutes = 60,
  int load = 50,
  String? end,
}) => LocalEvent(
  id: id,
  date: date,
  category: category,
  type: type,
  name: id,
  description: null,
  plannedLoad: load,
  plannedTime: minutes * 60,
  plannedDistance: null,
  indoor: false,
  raw: {if (end != null) 'end_date_local': end},
  syncedAt: DateTime(2026),
);

void main() {
  final today = DateTime(2026, 5, 10);

  group('currentHealthIssue', () {
    test('an ongoing SICK event is affected', () {
      final c = currentHealthIssue([
        ev('s', '2026-05-08', category: 'SICK'),
      ], today)!;
      expect(c.phase, HealthPhase.affected);
      expect(c.issue.kind, HealthKind.sick);
      expect(c.issue.ongoing, isTrue);
      expect(c.issue.daysUntil(today), 3);
    });

    test('after the end it is returning for the ramp, then gone', () {
      final s = ev(
        's',
        '2026-05-01',
        category: 'SICK',
        end: '2026-05-03',
      ); // 3 days
      expect(
        currentHealthIssue([s], DateTime(2026, 5, 5))!.phase,
        HealthPhase.returning,
      );
      // ramp 3 days: normal from May 7
      expect(currentHealthIssue([s], DateTime(2026, 5, 7)), isNull);
    });

    test('injury ramp is longer', () {
      final i = ev('i', '2026-05-01', category: 'INJURED', end: '2026-05-03');
      final c = currentHealthIssue([i], DateTime(2026, 5, 7))!;
      expect(c.phase, HealthPhase.returning); // 3×1.5 = 5 days
      expect(c.issue.rampDays(today), 5);
    });

    test('future and unrelated events are ignored', () {
      expect(
        currentHealthIssue([ev('s', '2026-05-20', category: 'SICK')], today),
        isNull,
      );
      expect(
        currentHealthIssue([ev('n', '2026-05-08', category: 'NOTE')], today),
        isNull,
      );
    });
  });

  group('returnToTraining', () {
    final sick = HealthIssue(
      kind: HealthKind.sick,
      start: DateTime(2026, 5, 8),
      end: DateTime(2026, 5, 12),
    );

    test(
      'sick: sessions during the illness are dropped, past ones untouched',
      () {
        final changes = returnToTraining(
          issue: sick,
          planned: [
            ev('past', '2026-05-09'),
            ev('d1', '2026-05-10'),
            ev('d2', '2026-05-12'),
          ],
          today: today,
        );
        expect([for (final c in changes) c.session.id], ['d1', 'd2']);
        expect(changes.every((c) => c.action == ReturnAction.rest), isTrue);
      },
    );

    test('return ramp scales load up and makes hard sessions easy early', () {
      // 5 days sick → ramp 7 days. Day 1 after: 0.5; hard session → easy.
      final changes = returnToTraining(
        issue: sick,
        planned: [
          ev('hard', '2026-05-13', load: 90, minutes: 60),
          ev('easy', '2026-05-18', load: 40, minutes: 60),
          ev('normal', '2026-05-25', load: 90),
        ],
        today: today,
      );
      final hard = changes.firstWhere((c) => c.session.id == 'hard');
      expect(hard.action, ReturnAction.easier);
      expect(hard.minutes, 30);
      expect(hard.load, closeTo(30 / 60 * easyLoadPerHour, 1));
      final late = changes.firstWhere((c) => c.session.id == 'easy');
      expect(late.minutes, greaterThan(40));
      expect(changes.any((c) => c.session.id == 'normal'), isFalse);
    });

    test('very short ramp results become rest', () {
      final changes = returnToTraining(
        issue: sick,
        planned: [ev('tiny', '2026-05-13', minutes: 15)],
        today: today,
      );
      expect(changes.single.action, ReturnAction.rest);
    });

    test('injury: run sessions become cross-training, others stay', () {
      final injured = HealthIssue(
        kind: HealthKind.injured,
        start: DateTime(2026, 5, 8),
        end: DateTime(2026, 5, 20),
        sport: 'run',
      );
      final changes = returnToTraining(
        issue: injured,
        planned: [
          ev('run', '2026-05-11', type: 'Run', minutes: 60, load: 80),
          ev('ride', '2026-05-12', type: 'Ride', minutes: 90),
        ],
        today: today,
      );
      expect(changes, hasLength(1));
      expect(changes.single.action, ReturnAction.crossTrain);
      expect(changes.single.toSport, 'Ride');
      expect(changes.single.load, 45);
      expect(changes.single.reason, ReturnReason.injury);
    });

    test('races and notes are never touched', () {
      final changes = returnToTraining(
        issue: sick,
        planned: [
          ev('r', '2026-05-11', category: 'RACE_A'),
          ev('n', '2026-05-11', category: 'NOTE'),
        ],
        today: today,
      );
      expect(changes, isEmpty);
    });
  });
}
