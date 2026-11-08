import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/evaluation/readiness.dart';
import 'package:triiq/plan/knowledge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final shipped = File('docs/okf.md').readAsStringSync();

  group('shipped docs/okf.md', () {
    test('every knowledge block parses with no warnings', () {
      final knowledge = TrainingKnowledge.parse(shipped);

      expect(knowledge.warnings, isEmpty);
      expect(
        knowledge.goals.keys,
        containsAll(['long_distance', 'short_event']),
      );
      expect(knowledge.rules.weekMultipliers, [1.0, 1.08, 1.15, 0.6]);
    });

    test('every goal has exactly one template per slot and phase', () {
      final knowledge = TrainingKnowledge.parse(shipped);

      for (final goal in knowledge.goals.values) {
        for (final slot in goal.slots.keys) {
          for (final phase in knowledge.rules.weekPhases) {
            expect(
              () => knowledge.templateFor(goal.id, slot, phase),
              returnsNormally,
              reason: '${goal.id} / ${slot.name} / $phase',
            );
          }
        }
      }
    });

    test('ships the load-curve rules', () {
      final rules = TrainingKnowledge.parse(shipped).rules;

      expect(rules.maxWeeklyIncrease, 0.10);
      expect(rules.recoveryThreshold, 0.9);
    });

    test('ships the taper rules', () {
      final taper = TrainingKnowledge.parse(shipped).rules.taper;

      expect(taper['long_distance'], [0.7, 0.5]);
      expect(taper['short_event'], [0.6]);
    });

    test('every goal has taper templates per slot and sport, and openers', () {
      final knowledge = TrainingKnowledge.parse(shipped);

      for (final goal in knowledge.goals.values) {
        for (final slot in goal.slots.keys) {
          for (final sport in const ['Run', 'Ride', 'Swim']) {
            if (sport == 'Swim' && slot == SessionSlot.long) continue;
            expect(
              () => knowledge.templateFor(goal.id, slot, 'taper', sport: sport),
              returnsNormally,
              reason: '${goal.id} / ${slot.name} / $sport',
            );
          }
        }
        expect(
          knowledge.templateFor(goal.id, SessionSlot.long, 'taper').shareScale,
          lessThan(1),
        );
        for (final sport in const ['Run', 'Ride']) {
          expect(
            knowledge
                .templateFor(
                  goal.id,
                  SessionSlot.intervals,
                  'openers',
                  sport: sport,
                )
                .name,
            'Race openers',
          );
        }
      }
    });

    test('ships the readiness rules, equal to the built-in defaults', () {
      final r = TrainingKnowledge.parse(shipped).rules.readiness;
      const d = ReadinessRules();

      expect(r.hrvSd, d.hrvSd);
      expect(r.restingHrBpm, d.restingHrBpm);
      expect(r.sleepHoursCaution, d.sleepHoursCaution);
      expect(r.form, d.form);
      expect(r.baselineDays, d.baselineDays);
      expect(r.minBaselineDays, d.minBaselineDays);
    });

    test('every goal has swim z2 and interval templates for every phase', () {
      final knowledge = TrainingKnowledge.parse(shipped);

      for (final goal in knowledge.goals.values) {
        for (final slot in [SessionSlot.z2, SessionSlot.intervals]) {
          for (final phase in knowledge.rules.weekPhases) {
            final t = knowledge.templateFor(
              goal.id,
              slot,
              phase,
              sport: 'Swim',
            );
            expect(t.sports, ['Swim'], reason: '${goal.id} / $phase');
          }
        }
        // Swim templates never leak into run or ride lookups, and vice versa.
        expect(
          knowledge.templateFor(goal.id, SessionSlot.z2, 'build').sports,
          SessionTemplate.landSports,
        );
        expect(
          () => knowledge.templateFor(
            goal.id,
            SessionSlot.long,
            'build',
            sport: 'Swim',
          ),
          throwsA(isA<MissingTemplateException>()),
        );
      }
    });

    test('loads through the asset bundle', () async {
      final knowledge = await KnowledgeRepository().load();

      expect(knowledge.warnings, isEmpty);
      expect(knowledge.goals.keys, contains('long_distance'));
    });

    test('is also valid with Windows line endings', () {
      final knowledge = TrainingKnowledge.parse(
        shipped.replaceAll('\r\n', '\n').replaceAll('\n', '\r\n'),
      );

      expect(knowledge.warnings, isEmpty);
    });
  });

  group('malformed knowledge', () {
    test('skips a broken block, keeps the rest, and says so', () {
      const md = '''
```okf-goal
{ not json
```

```okf-goal
{"id":"g","label":"G","slots":{"z2":{"count":1,"share":1.0}}}
```

```okf-template
{"id":"g.z2","goal":"g","slot":"z2","phases":["build"],"name":"n",
 "tssPerHour":50,"lowShare":1.0,"steps":[{"kind":"fill","pct":70}]}
```
''';
      final knowledge = TrainingKnowledge.parse(md);

      expect(knowledge.goals.keys, ['g']);
      expect(knowledge.warnings.first, contains('okf-goal block #1'));
      // No rules block at all: defaults apply, and the athlete is told.
      expect(
        knowledge.rules.weekMultipliers,
        PlanRules.defaults.weekMultipliers,
      );
    });

    test('a rules block without readiness gets the readiness defaults', () {
      final json = {
        'weekPhases': ['build'],
        'weekMultipliers': [1.0],
        'maxWeeklyIncrease': 0.1,
        'maxCtlRamp': 7,
        'lowIntensityTarget': 0.8,
        'lowIntensityTolerance': 0.05,
        'minHistoryWeeks': 4,
      };

      expect(PlanRules.fromJson(json).readiness.hrvSd, [1, 2]);
      expect(
        PlanRules.fromJson({
          ...json,
          'readiness': {'sleepHoursCaution': 7},
        }).readiness.sleepHoursCaution,
        7,
      );
    });

    test(
      'a malformed readiness object skips the rules block with a warning',
      () {
        const md = '''
```okf-rules
{"weekPhases":["build"],"weekMultipliers":[1.0],"maxWeeklyIncrease":0.2,
 "maxCtlRamp":7,"lowIntensityTarget":0.8,"lowIntensityTolerance":0.05,
 "minHistoryWeeks":4,"readiness":{"hrvSd":[1]}}
```
''';
        final knowledge = TrainingKnowledge.parse(md);

        expect(knowledge.warnings.first, contains('readiness.hrvSd'));
        expect(knowledge.rules.maxWeeklyIncrease, 0.10);
        expect(knowledge.rules.readiness.hrvSd, [1, 2]);
      },
    );

    test('taper: missing means none, malformed skips the rules block', () {
      final json = {
        'weekPhases': ['build'],
        'weekMultipliers': [1.0],
        'maxWeeklyIncrease': 0.1,
        'maxCtlRamp': 7,
        'lowIntensityTarget': 0.8,
        'lowIntensityTolerance': 0.05,
        'minHistoryWeeks': 4,
      };

      expect(PlanRules.fromJson(json).taper, isEmpty);
      expect(
        PlanRules.fromJson({
          ...json,
          'taper': {
            'g': [0.8, 0.4],
          },
        }).taper['g'],
        [0.8, 0.4],
      );
      for (final bad in [
        {'g': <double>[]},
        {
          'g': [1.5],
        },
        {
          'g': [0],
        },
        [0.5],
      ]) {
        expect(
          () => PlanRules.fromJson({...json, 'taper': bad}),
          throwsFormatException,
          reason: '$bad',
        );
      }
    });

    test('a template with an unknown phase is rejected', () {
      Map<String, dynamic> template(List<String> phases) => {
        'id': 'x',
        'goal': 'g',
        'slot': 'z2',
        'phases': phases,
        'name': 'n',
        'tssPerHour': 50,
        'lowShare': 1.0,
        'steps': [
          {'kind': 'fill', 'pct': 70},
        ],
      };

      expect(SessionTemplate.fromJson(template(['taper'])).shareScale, 1.0);
      expect(
        SessionTemplate.fromJson({
          ...template(['openers']),
          'shareScale': 0.6,
        }).shareScale,
        0.6,
      );
      expect(
        () => SessionTemplate.fromJson(template(['tapr'])),
        throwsFormatException,
      );
    });

    test('falls back to built-in goals when none survive', () {
      final knowledge = TrainingKnowledge.parse('no blocks here');

      expect(knowledge.goals.keys, ['general']);
      expect(knowledge.warnings, isNotEmpty);
      expect(
        () => knowledge.templateFor('general', SessionSlot.long, 'peak'),
        returnsNormally,
      );
    });

    test('a missing template names the goal, slot and phase', () {
      final knowledge = TrainingKnowledge.parse(shipped);

      expect(
        () => knowledge.templateFor('triathlon', SessionSlot.long, 'peak'),
        throwsA(
          isA<MissingTemplateException>().having(
            (e) => e.toString(),
            'message',
            allOf(contains('triathlon'), contains('long'), contains('peak')),
          ),
        ),
      );
    });

    test('shares that do not sum to 1 reject the goal', () {
      expect(
        () => GoalProfile.fromJson({
          'id': 'x',
          'label': 'X',
          'slots': {
            'z2': {'count': 1, 'share': 0.5},
          },
        }),
        throwsFormatException,
      );
    });

    test('an unreadable asset yields defaults with a warning', () async {
      final repo = KnowledgeRepository(loadAsset: () async => throw 'boom');

      final knowledge = await repo.load();

      expect(knowledge.goals, isNotEmpty);
      expect(knowledge.warnings.single, contains('could not be read'));
    });
  });
}
