import 'dart:convert';

import '../data/intervals_workout_service.dart';

/// The instruction handed to the agent to turn the session it just proposed
/// into something the Intervals.icu API can take.
///
/// Deliberately a second turn rather than part of the original prompt: the
/// athlete reads the prose proposal first and only pays for this when they
/// decide to keep it, and the model gets to do one job at a time.
const workoutStructuringPrompt = '''
Convert the session you just proposed into one JSON object. Reply with the
JSON and nothing else — no explanation, no code fence.

{
  "name": "short session title",
  "sport": "Ride" | "Run" | "Swim" | the Intervals.icu type you proposed,
  "indoor": true or false,
  "duration_minutes": total minutes as a number,
  "load": estimated TSS as a number,
  "description": "the workout in Intervals.icu step syntax"
}

The description must use Intervals.icu's native workout syntax: one step per
line, each starting with "- ", a duration or distance, and a target — every
step needs its own concrete number, never a bare word on its own.
"- 20m 95% Pace" is a valid step; "- 20m Pace" or "- 20m Easy" is not — turn
"easy"/"steady"/"hard" into the % or pace band you meant. Repeats are a line
"Nx" followed by the steps to repeat, indented by two spaces. Structure the
session as warm-up / main set / cool-down (drop whichever the session you
proposed doesn't have).

Ride: minutes and % of FTP.
Run: minutes and % of threshold pace, or % of FTP if it was a power session.

- 15m 60%
3x
  - 8m 100%
  - 4m 55%
- 10m 55%

Swim: distances in metres with a pace (e.g. "1:45/100m") or an explicit
effort band, plus the stroke/drill and any equipment as trailing text on the
same line — "- 4x50m Catch-up drill" or "- 200m w/ paddles, 1:35/100m", not
just "- 200m Swim". If the session you proposed named specific gear
(paddles, pull buoy, fins) or a drill, carry those words into the matching
step rather than dropping them:

- 300m Warm up, easy
4x
  - 50m Catch-up drill
  - 50m w/ paddles, moderate
2x
  - 100m w/ pull buoy, steady
  - 50m w/ fins, kick only
- 200m Cool down, easy

Keep the prescription identical to what you proposed — this is a format
change, not a new session, so don't invent equipment or drills that weren't
in the proposal.
''';

/// Pulls the JSON object out of a model reply and turns it into a draft.
///
/// Models wrap JSON in prose or a code fence more often than not, so the
/// object is located rather than assumed to be the whole reply. Returns
/// `null` when there is nothing usable — the caller shows the athlete an
/// error instead of writing a guess to their calendar.
PlannedWorkoutDraft? parseWorkoutDraft(
  String reply, {
  required DateTime date,
  required String fallbackSport,
  required String fallbackName,
}) {
  final json = _extractObject(reply);
  if (json == null) return null;

  final description = _string(json['description']);
  if (description == null || description.trim().isEmpty) return null;

  final minutes = _int(json['duration_minutes'] ?? json['duration']);

  return PlannedWorkoutDraft(
    name: _string(json['name'])?.trim().isNotEmpty == true
        ? _string(json['name'])!.trim()
        : fallbackName,
    sport: _string(json['sport'])?.trim().isNotEmpty == true
        ? _string(json['sport'])!.trim()
        : fallbackSport,
    description: description.trim(),
    date: date,
    durationSeconds: minutes == null ? null : minutes * 60,
    load: _int(json['load'] ?? json['tss']),
    indoor: json['indoor'] == true,
  );
}

/// The outermost `{…}` in [reply], decoded. Scans for the first `{` and
/// tracks brace depth (ignoring braces inside strings) so trailing prose
/// after the object doesn't break the parse.
Map<String, dynamic>? _extractObject(String reply) {
  final start = reply.indexOf('{');
  if (start < 0) return null;

  var depth = 0;
  var inString = false;
  var escaped = false;
  for (var i = start; i < reply.length; i++) {
    final char = reply[i];
    if (inString) {
      if (escaped) {
        escaped = false;
      } else if (char == r'\') {
        escaped = true;
      } else if (char == '"') {
        inString = false;
      }
      continue;
    }
    if (char == '"') {
      inString = true;
    } else if (char == '{') {
      depth++;
    } else if (char == '}') {
      depth--;
      if (depth == 0) {
        try {
          final decoded = jsonDecode(reply.substring(start, i + 1));
          return decoded is Map<String, dynamic> ? decoded : null;
        } catch (_) {
          return null;
        }
      }
    }
  }
  return null;
}

String? _string(Object? value) => value is String ? value : null;

int? _int(Object? value) => switch (value) {
  final int value => value,
  final double value => value.round(),
  final String value => int.tryParse(value.trim()),
  _ => null,
};
