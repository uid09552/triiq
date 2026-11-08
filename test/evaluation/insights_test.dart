import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/evaluation/insights.dart';
import 'package:triiq/plan/knowledge.dart';

LocalActivity act(
  String id,
  String date, {
  String type = 'Ride',
  double? ef,
  List<int> hrZones = const [1800, 1800, 0, 0, 0],
  Map<String, dynamic> extra = const {},
}) => LocalActivity(
  id: id,
  date: date,
  type: type,
  name: id,
  movingTime: 3600,
  distance: null,
  trainingLoad: 50,
  raw: {'icu_hr_zone_times': hrZones, 'icu_efficiency_factor': ?ef, ...extra},
  syncedAt: DateTime(2026, 11, 3),
);

LocalEvent event(String name, {String date = '2026-11-04'}) => LocalEvent(
  id: name,
  date: date,
  category: 'WORKOUT',
  type: 'Ride',
  name: name,
  description: null,
  plannedLoad: 80,
  plannedTime: 3600,
  plannedDistance: null,
  indoor: false,
  raw: const {},
  syncedAt: DateTime(2026, 11, 1),
);

void main() {
  group('personalBests', () {
    test('power and distance bests, with the previous best', () {
      final bests = personalBests({
        'icu_achievements': [
          {'type': 'BEST_POWER', 'secs': 300, 'value': 310, 'previous': 298},
          {'type': 'BEST_TIME', 'distance': 5000, 'value': 1260},
        ],
      });

      expect(bests, hasLength(2));
      expect(bests[0].kind, BestEffortKind.power);
      expect(
        (bests[0].seconds, bests[0].value, bests[0].previous),
        (300, 310.0, 298.0),
      );
      expect(bests[1].kind, BestEffortKind.time);
      expect(bests[1].distance, 5000);
    });

    test('unknown shapes are skipped, never thrown', () {
      expect(personalBests({}), isEmpty);
      expect(personalBests({'icu_achievements': 'x'}), isEmpty);
      expect(
        personalBests({
          'icu_achievements': [
            1,
            {'type': 'BEST_POWER'},
            {'type': 'BEST_POWER', 'value': 300},
          ],
        }),
        isEmpty,
        reason: 'no value, or a power best without a duration',
      );
    });
  });

  group('efficiencyTrend', () {
    final history = [
      for (var i = 0; i < 5; i++)
        act(
          'h$i',
          '2026-10-${(10 + i * 3).toString().padLeft(2, '0')}',
          ef: 1.48 + i * 0.01,
        ),
    ];

    test('an easy session against the 6-week median', () {
      final t = efficiencyTrend(act('now', '2026-11-03', ef: 1.56), history)!;

      expect(t.sessions, 5);
      expect(t.median, closeTo(1.50, 1e-9));
      expect(t.change, closeTo(0.04, 1e-9));
    });

    test('too few earlier easy sessions: no median', () {
      final t = efficiencyTrend(
        act('now', '2026-11-03', ef: 1.56),
        history.take(2),
      )!;
      expect(t.median, isNull);
      expect(t.sessions, 2);
    });

    test('hard or other-sport sessions are not compared', () {
      final hard = act(
        'now',
        '2026-11-03',
        ef: 1.56,
        hrZones: [600, 600, 1200, 1200, 0],
      );
      expect(efficiencyTrend(hard, history), isNull);

      final run = efficiencyTrend(
        act('r', '2026-11-03', type: 'Run', ef: 1.2),
        history,
      )!;
      expect(run.median, isNull, reason: 'the rides are not runs');
    });
  });

  group('recoveryHint', () {
    final evening = DateTime(2026, 11, 3, 18);

    test('an easy session: 12 hours, nothing about tomorrow', () {
      final h = recoveryHint(
        tss: 40,
        form: 5,
        endedAt: evening,
        tomorrow: [event('Threshold intervals')],
      );
      expect(h.hours, 12);
      expect(h.conflict, isNull);
      expect(h.penalised, isFalse);
    });

    test('a big day on low form runs into tomorrow\'s intervals', () {
      final h = recoveryHint(
        tss: 180,
        form: -25,
        endedAt: evening,
        tomorrow: [event('Z2 endurance'), event('Threshold intervals')],
      );
      expect(h.hours, 48);
      expect(h.penalised, isTrue);
      expect(h.conflict!.name, 'Threshold intervals');
    });

    test('the rule comes from the shipped knowledge', () {
      final rules = TrainingKnowledge.parse(
        File('docs/okf.md').readAsStringSync(),
      ).rules.recovery;
      expect(rules.bands.map((b) => b.hours), [12, 24, 36, 48]);
      expect(rules.formPenaltyBelow, -20);
    });
  });
}
