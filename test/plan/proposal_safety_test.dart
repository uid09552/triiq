import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/plan/knowledge.dart' show SessionSlot;
import 'package:triiq/plan/plan_models.dart';
import 'package:triiq/plan/proposal_safety.dart';
import 'package:triiq/season/illness_mode.dart';

PlanSession _s(int id, String date, SessionSlot slot, {String name = 'Run'}) =>
    PlanSession(
      id: id,
      weekIndex: 0,
      date: DateTime.parse(date),
      slot: slot,
      templateId: 'x',
      name: name,
      sport: 'Run',
      minutes: 60,
      load: 60,
      lowMinutes: 40,
      description: '',
    );

void main() {
  group('sessionMoveRefusal', () {
    final intervals = _s(
      1,
      '2026-11-03',
      SessionSlot.intervals,
      name: 'Intervals',
    );
    final long = _s(2, '2026-11-07', SessionSlot.long, name: 'Long run');
    final easy = _s(3, '2026-11-05', SessionSlot.z2, name: 'Easy');
    final plan = [intervals, long, easy];

    test('a hard session may not land next to another hard one', () {
      final r = sessionMoveRefusal(
        session: intervals,
        target: DateTime(2026, 11, 6),
        plan: plan,
      );
      expect(r, contains('back to back'));
      expect(r, contains('Long run'));
    });

    test('nor on the same day', () {
      final r = sessionMoveRefusal(
        session: intervals,
        target: DateTime(2026, 11, 7),
        plan: plan,
      );
      expect(r, contains('same day'));
    });

    test('a day between is fine', () {
      expect(
        sessionMoveRefusal(
          session: intervals,
          target: DateTime(2026, 11, 5),
          plan: plan,
        ),
        isNull,
      );
    });

    test('an easy session may go anywhere', () {
      expect(
        sessionMoveRefusal(
          session: easy,
          target: DateTime(2026, 11, 6),
          plan: plan,
        ),
        isNull,
      );
    });

    test('a hard session is never put on a sick or injured day', () {
      final issue = HealthIssue(
        kind: HealthKind.sick,
        start: DateTime(2026, 11, 4),
        end: DateTime(2026, 11, 9),
      );
      final r = sessionMoveRefusal(
        session: intervals,
        target: DateTime(2026, 11, 5),
        plan: plan,
        health: (issue: issue, phase: HealthPhase.affected),
      );
      expect(r, contains('logged as sick'));
      expect(r, contains('rest or an easy session'));
      // An easy one is not blocked by it.
      expect(
        sessionMoveRefusal(
          session: easy,
          target: DateTime(2026, 11, 6),
          plan: plan,
          health: (issue: issue, phase: HealthPhase.affected),
        ),
        isNull,
      );
    });
  });

  group('red flags in the athlete\'s words', () {
    test('clear cases in English and German', () {
      expect(redFlagsIn('I get chest pain when I run'), [RedFlag.chestPain]);
      expect(redFlagsIn('Brustschmerzen beim Laufen'), [RedFlag.chestPain]);
      expect(redFlagsIn('I nearly fainted after intervals'), [
        RedFlag.fainting,
      ]);
      expect(redFlagsIn('Ich bin fast umgekippt'), [RedFlag.fainting]);
      expect(redFlagsIn("I can't breathe properly"), [RedFlag.breathing]);
      expect(redFlagsIn('Ich habe Atemnot'), [RedFlag.breathing]);
      expect(redFlagsIn('heart palpitations at night'), [RedFlag.palpitations]);
      expect(redFlagsIn('Herzrasen in Ruhe'), [RedFlag.palpitations]);
    });

    test('several at once', () {
      expect(
        redFlagsIn('chest pain and I almost passed out'),
        containsAll([RedFlag.chestPain, RedFlag.fainting]),
      );
    });

    test('ordinary training talk is left alone', () {
      for (final text in [
        'How was my week?',
        'My legs feel heavy and my chest is tight from the cold air',
        'Should I do intervals tomorrow?',
        'Wie fühlt sich meine Form an?',
        'I was out of breath on the hill',
        'My heart rate was high today',
      ]) {
        expect(redFlagsIn(text), isEmpty, reason: text);
      }
    });
  });

  test('a clamp survives JSON', () {
    const k = RampClamp(week: 3, asked: 500, limited: 435);
    final back = RampClamp.fromJson(k.toJson())!;
    expect(back.week, 3);
    expect(back.limited, 435);
    expect(back.raised, isTrue);
    expect(RampClamp.fromJson({'week': 'x'}), isNull);
  });
}
