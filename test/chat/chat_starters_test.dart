import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/agent/agent_memory.dart';
import 'package:triiq/agent/chat_starters.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/models/local_event.dart';

LocalEvent ev(String date, {String cat = 'WORKOUT'}) => LocalEvent(
  id: date + cat,
  date: date,
  category: cat,
  type: 'Run',
  name: 'x',
  description: null,
  plannedLoad: 50,
  plannedTime: 3600,
  plannedDistance: null,
  indoor: false,
  raw: const {},
  syncedAt: DateTime(2026),
);

LocalActivity act(String date) => LocalActivity(
  id: date,
  date: date,
  type: 'Run',
  name: 'x',
  movingTime: 3600,
  distance: null,
  trainingLoad: 50,
  raw: const {},
  syncedAt: DateTime(2026),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('missed session', () {
    final today = DateTime(2026, 11, 21);
    test('the latest planned day without an activity', () {
      final d = missedSessionDate(
        today,
        [ev('2026-11-17'), ev('2026-11-19'), ev('2026-11-20')],
        [act('2026-11-20')],
      );
      expect(d, DateTime(2026, 11, 19));
    });
    test('today, notes and done days do not count', () {
      expect(
        missedSessionDate(
          today,
          [ev('2026-11-21'), ev('2026-11-18', cat: 'NOTE'), ev('2026-11-19')],
          [act('2026-11-19')],
        ),
        isNull,
      );
    });
  });

  test('low form starts at -25', () {
    expect(const StarterFacts(form: -24).formIsLow, isFalse);
    expect(const StarterFacts(form: -25).formIsLow, isTrue);
    expect(const StarterFacts().formIsLow, isFalse);
  });

  group('trainer memory', () {
    test('items can be edited in place', () async {
      final store = AgentMemoryStore();
      final item = (await store.add('No hard rides on Friday'))!;
      expect(await store.edit(item.id, '  No hard rides on Thursday '), isTrue);
      final back = (await store.load()).single;
      expect(back.id, item.id);
      expect(back.text, 'No hard rides on Thursday');
      expect(await store.edit(item.id, '   '), isFalse);
      expect(await store.edit('nope', 'x'), isFalse);
    });

    test('switched off, the trainer gets nothing; the items stay', () async {
      final store = AgentMemoryStore();
      await store.add('Mornings only');
      expect(await store.promptBlock(), contains('Mornings only'));
      await store.setEnabled(false);
      expect(await store.promptBlock(), isNull);
      expect(await store.load(), hasLength(1));
      await store.setEnabled(true);
      expect(await store.promptBlock(), isNotNull);
    });
  });

  group('tone and check-in presets', () {
    test('defaults add nothing', () async {
      expect(await TrainerStyle().promptBlock(), isNull);
    });
    test('are stored and reach the prompt', () async {
      final style = TrainerStyle();
      await style.setTone(TrainerTone.direct);
      await style.setCadence(CheckInCadence.weekly);
      expect(await style.tone(), TrainerTone.direct);
      final block = (await TrainerStyle().promptBlock())!;
      expect(block, contains('direct and brief'));
      expect(block, contains('weekly review'));
      expect(block, contains('never change your rules'));
    });
  });
}
