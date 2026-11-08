import 'workout_draft_parser.dart';

/// How much a proposed session spells out.
///
/// *Short* is the compact table: one row per segment. *Detailed* adds the
/// exercises themselves (drills, strides, cadence work, strength and
/// mobility where they fit) and a full set description for each: sets and
/// reps, rest, the target, the equipment and a coaching cue.
enum TrainingDetail { short, detailed }

/// Sport-specific exercises the detailed proposal draws from, so a "run" is
/// more than "20 minutes steady" and a swim names its drills.
String exerciseMenu(String sport) => switch (sport) {
  'Run' =>
    'Warm-up drills (leg swings, A-skips, high knees, butt kicks), strides '
        '(4-6 x 15-20s relaxed fast with a walk back), the main set, and, '
        'when time allows, a 5-8 minute strength or mobility finisher '
        '(single-leg calf raises, glute bridges, walking lunges, hip '
        'openers).',
  'Ride' =>
    'Cadence and technique work (spin-ups, single-leg pedalling, '
        'high-cadence and low-cadence/big-gear blocks, seated and standing '
        'efforts), the main set, and, when time allows, a short core or '
        'hip-mobility finisher (plank, side plank, hip flexor stretch).',
  'Swim' =>
    'Named drills (catch-up, fingertip drag, fist drill, bilateral '
        'breathing, 6-kick switch), kick sets (with fins or a board), pull '
        'sets (pull buoy, paddles), the main set, and an easy cool-down.',
  _ =>
    'Warm-up drills, the main set, and a short mobility or strength '
        'finisher when time allows.',
};

/// The part of the Train-now request that says what the reply should look
/// like.
String sessionFormatInstruction(TrainingDetail detail, String sport) {
  switch (detail) {
    case TrainingDetail.short:
      return 'Reply with the '
          'session as a markdown table, one row per segment (warm-up, each '
          'interval or set, cool-down), with exactly these two columns and '
          'nothing else — more columns make the table unreadable on a '
          'phone: "Duration" (the segment name plus its time or distance, '
          'e.g. "Warm-up — 10m" or "3x8min"), "Session" (everything else '
          'about that segment in one cell — the concrete target: % of FTP, % '
          'of threshold pace, or for swimming a pace per 100m or explicit '
          'effort; any equipment, e.g. paddles, pull buoy, fins; and any '
          'other note worth flagging). After the table, add one line with '
          'the estimated total TSS and a one-line rationale citing the data '
          'you found.';
    case TrainingDetail.detailed:
      return 'Reply with a detailed, coach-written session in markdown, in '
          'this order. 1) One italic line stating what the session trains '
          'and why it suits me today. 2) One section per block, each a '
          '"## " heading (## Warm-up, ## Main set, ## Cool-down; add '
          '## Drills or ## Strength & mobility when exercises deserve their '
          'own block; leave out a block the session does not have), each '
          'followed by a markdown table with exactly these two columns and '
          'nothing else — more columns make the table unreadable on a '
          'phone: "Exercise" (the exercise, drill or interval type in bold, '
          'then its sets and reps or time/distance and the rest between, '
          'e.g. "**Catch-up drill** — 4 x 50mtr, 20s rest" or '
          '"**Threshold interval** — 3 x 8min, 3min easy between") and '
          '"How" (the concrete target — % of FTP, % of threshold pace, a '
          'pace per 100m or an RPE; cadence or stroke rate where it '
          'matters; any equipment; and one short coaching cue saying how it '
          'should feel or what to focus on). Name real exercises: '
          '${exerciseMenu(sport)} Give every row its own numbers; the '
          'blocks together must add up to the requested duration. 3) A '
          'final line "**Load:** about N TSS" and one "**Why:**" line citing '
          'the data you found.';
  }
}

/// The second-turn request that turns the proposal into Intervals.icu step
/// syntax: the compact format for a short proposal, and for a detailed one
/// the same format with the exercises and their coaching cues carried over.
String workoutStructuringPromptFor(TrainingDetail detail) {
  if (detail == TrainingDetail.short) return workoutStructuringPrompt;
  return '$workoutStructuringPrompt\n$_detailedStructuringNote';
}

const _detailedStructuringNote = '''
This was a detailed session, so keep all of its detail in the description:
- The first line of the description is plain text (no "- "): the session's
  purpose in one sentence. Intervals.icu keeps it as a note.
- Every exercise, drill and set from the proposal gets its own step — don't
  merge them. Each step still needs its own duration or distance and
  target, so give a drill or exercise you proposed by reps (A-skips, calf
  raises, a 6-kick switch) a realistic duration, and write the reps in the
  trailing text: "- 2m 60% A-skips 3x20m, tall posture, quick ground contact".
- End every step line with the exercise name (if it isn't already there)
  and its coaching cue, after the target.
- Write the rest between repeats as its own step ("- 3m 55% easy spin"),
  inside the repeat block, so the structure shows the work-to-rest ratio.
- Keep the durations adding up to the proposal's total duration.
''';
