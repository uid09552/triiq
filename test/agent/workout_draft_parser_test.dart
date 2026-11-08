import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/agent/workout_draft_parser.dart';
import 'package:triiq/data/intervals_workout_service.dart';

/// Turning a model's reply into something that gets written to the
/// athlete's Intervals.icu calendar: the parse has to be strict about what
/// it accepts (a wrong workout is worse than none) and forgiving about how
/// the JSON is wrapped, because models wrap it differently every time.
void main() {
  final date = DateTime(2026, 8, 31);

  PlannedWorkoutDraft? parse(String reply) => parseWorkoutDraft(
    reply,
    date: date,
    fallbackSport: 'Ride',
    fallbackName: 'Endurance ride',
  );

  test('reads a bare JSON object', () {
    final draft = parse('''
{"name": "Sweet spot", "sport": "Ride", "indoor": true,
 "duration_minutes": 60, "load": 65, "description": "- 15m 60%\\n- 30m 90%"}
''')!;

    expect(draft.name, 'Sweet spot');
    expect(draft.sport, 'Ride');
    expect(draft.indoor, isTrue);
    expect(draft.durationSeconds, 3600);
    expect(draft.load, 65);
    expect(draft.description, '- 15m 60%\n- 30m 90%');
    expect(draft.date, date);
  });

  test('finds the object inside a code fence and surrounding prose', () {
    final draft = parse('''
Here you go:

```json
{"name": "Threshold run", "sport": "Run", "duration_minutes": 45,
 "description": "- 10m 70% Pace"}
```

Let me know if you want it easier.
''')!;

    expect(draft.name, 'Threshold run');
    expect(draft.sport, 'Run');
    expect(draft.load, isNull);
  });

  test('is not confused by braces inside strings', () {
    final draft = parse(
      '{"name": "3x{8m}", "description": "- 8m 100%", "sport": "Ride"}',
    )!;

    expect(draft.name, '3x{8m}');
  });

  test('falls back to the requested sport and name when they are missing', () {
    final draft = parse('{"description": "- 40m 65%"}')!;

    expect(draft.sport, 'Ride');
    expect(draft.name, 'Endurance ride');
  });

  test('accepts numbers sent as strings or decimals', () {
    final draft = parse(
      '{"description": "- 40m 65%", "duration_minutes": "40", "load": 55.6}',
    )!;

    expect(draft.durationSeconds, 2400);
    expect(draft.load, 56);
  });

  test('rejects a reply with no workout in it', () {
    expect(parse('I could not build that session.'), isNull);
    expect(parse('{"name": "Ride"}'), isNull);
    expect(parse('{"description": "   "}'), isNull);
    expect(parse('{"description": broken'), isNull);
  });

  group('swim distances', () {
    String reply(String sport, String description, int minutes) =>
        '{"name":"Swim","sport":"$sport","duration_minutes":$minutes,'
        '"load":30,"description":${jsonEncode(description)}}';

    test('a swim whose distances use "m" is rewritten to mtr (was ~19 h)', () {
      final draft = parseWorkoutDraft(
        reply(
          'Swim',
          '- 300m Warm up, easy\n4x\n  - 50m Catch-up drill\n- 200m Cool down',
          30,
        ),
        date: DateTime(2026, 11, 5),
        fallbackSport: 'Swim',
        fallbackName: 'x',
      )!;
      expect(draft.description, contains('- 300mtr Warm up, easy'));
      expect(draft.description, contains('  - 50mtr Catch-up drill'));
      expect(draft.description, isNot(contains('300m ')));
      expect(draft.durationSeconds, 30 * 60);
    });

    test('a swim written in minutes, and other sports, are left alone', () {
      const swim = '- 10m 75%\n4x\n  - 3m 98%\n  - 1m 70%\n- 5m 72%';
      final a = parseWorkoutDraft(
        reply('Swim', swim, 31),
        date: DateTime(2026, 11, 5),
        fallbackSport: 'Swim',
        fallbackName: 'x',
      )!;
      expect(a.description, swim);
      const ride = '- 300m 60%';
      final b = parseWorkoutDraft(
        reply('Ride', ride, 300),
        date: DateTime(2026, 11, 5),
        fallbackSport: 'Ride',
        fallbackName: 'x',
      )!;
      expect(b.description, ride);
    });

    test('the structuring prompt teaches mtr for metres', () {
      expect(workoutStructuringPrompt, contains('mtr'));
      expect(workoutStructuringPrompt, isNot(contains('- 300m Warm up')));
    });
  });
}
