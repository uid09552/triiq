import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/plan/knowledge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final shipped = File('docs/okf.md').readAsStringSync();

  group('shipped docs/okf.md', () {
    test('every knowledge block parses with no warnings', () {
      final knowledge = TrainingKnowledge.parse(shipped);

      expect(knowledge.warnings, isEmpty);
      expect(knowledge.goals.keys, containsAll(['long_distance', 'short_event']));
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

    test('every goal has swim z2 and interval templates for every phase', () {
      final knowledge = TrainingKnowledge.parse(shipped);

      for (final goal in knowledge.goals.values) {
        for (final slot in [SessionSlot.z2, SessionSlot.intervals]) {
          for (final phase in knowledge.rules.weekPhases) {
            final t = knowledge.templateFor(goal.id, slot, phase, sport: 'Swim');
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
      expect(knowledge.rules.weekMultipliers, PlanRules.defaults.weekMultipliers);
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
