import 'strength.dart' show strengthSport;

/// Bodyweight-only strength sessions, aimed at the sports the athlete picks:
/// no weights, bands or machines — the floor, a wall and a chair or step
/// are all it needs. Used by the calendar's "Add strength training" (the
/// deterministic content below) and by Train now's strength option (the
/// prompt the training agent gets).

/// Which endurance sport a strength session should carry over to.
enum StrengthTarget { swim, ride, run }

/// One bodyweight exercise.
class BodyweightExercise {
  const BodyweightExercise(this.name, this.reps, this.cue);

  final String name;

  /// Reps (or time) per set; the number of sets comes from the session
  /// length.
  final String reps;

  /// What it does / how to do it, in one line.
  final String cue;
}

const _warmUp = BodyweightExercise(
  'Warm-up',
  '4 min: jumping jacks, arm circles, leg swings, cat-cow',
  'Gets the joints moving and the heart rate up before loading.',
);

/// Per sport, most important first: the session takes them in turn.
const Map<StrengthTarget, List<BodyweightExercise>> _bySport = {
  StrengthTarget.swim: [
    BodyweightExercise(
      'Push-ups',
      '8-12 (from the knees if needed)',
      'Chest, shoulders and triceps for the pull and push phase.',
    ),
    BodyweightExercise(
      'Prone Y-T-W raises',
      '8 each letter',
      'Lying face down, thumbs up: upper back and rotator cuff for a stable '
          'shoulder.',
    ),
    BodyweightExercise(
      'Superman hold',
      '20-30 s',
      'Lower back and glutes for a high body position in the water.',
    ),
    BodyweightExercise(
      'Plank shoulder taps',
      '10 each side',
      'Anti-rotation core with loaded shoulders, as in the catch.',
    ),
    BodyweightExercise(
      'Kneeling push-up to downward dog',
      '8',
      'Shoulder strength and overhead mobility in one move.',
    ),
    BodyweightExercise(
      'Hollow body hold with flutter kick',
      '20-30 s',
      'Streamline core tension and a steady kick.',
    ),
  ],
  StrengthTarget.ride: [
    BodyweightExercise(
      'Bodyweight squat',
      '15-20, 3 s down',
      'Hip and knee extensors that push the pedals.',
    ),
    BodyweightExercise(
      'Single-leg glute bridge',
      '10 each leg',
      'Glute drive and hip extension without the quads taking over.',
    ),
    BodyweightExercise(
      'Wall sit',
      '30-45 s',
      'Static quad endurance like a long seated climb.',
    ),
    BodyweightExercise(
      'Reverse lunge',
      '10 each leg',
      'Single-leg strength; evens out left-right imbalances.',
    ),
    BodyweightExercise(
      'Tall-kneeling hip hinge',
      '12',
      'Kneeling upright, sit back to the heels and drive the hips forward: '
          'glutes and hip extension, gentle on the knees.',
    ),
    BodyweightExercise(
      'Side plank',
      '30 s each side',
      'Lateral trunk strength for a quiet upper body on the bike.',
    ),
  ],
  StrengthTarget.run: [
    BodyweightExercise(
      'Single-leg calf raise',
      '12-15 each leg, slow lowering',
      'Calf and Achilles load tolerance.',
    ),
    BodyweightExercise(
      'Bulgarian split squat (rear foot on a chair)',
      '8-10 each leg',
      'Single-leg strength for stance and push-off.',
    ),
    BodyweightExercise(
      'Single-leg Romanian deadlift',
      '8 each leg',
      'Hamstrings and hip stability on one leg, as in running.',
    ),
    BodyweightExercise(
      'Pogo hops',
      '20',
      'Quick, stiff ankles: springiness and running economy.',
    ),
    BodyweightExercise(
      'Half-kneeling hip flexor lift',
      '8 each side',
      'From half-kneeling, lift the front knee: hip flexors that drive the '
          'knee forward.',
    ),
    BodyweightExercise(
      'Side plank with top-leg lift',
      '8 each side',
      'Hip abductors against pelvic drop.',
    ),
  ],
};

const _core = BodyweightExercise(
  'Dead bug',
  '8 each side',
  'Core control with a neutral spine — the finisher for every sport.',
);

/// Exercises a session of [minutes] has room for (warm-up and finisher
/// excluded).
int _mainExercises(int minutes) => minutes <= 20
    ? 4
    : minutes <= 30
    ? 6
    : 8;

/// Sets per exercise for [minutes].
int bodyweightSets(int minutes) => minutes <= 20 ? 2 : 3;

/// The exercises for [targets] (all three when empty) in a session of
/// [minutes]: a warm-up, the sports' exercises in turn, a core finisher.
List<BodyweightExercise> bodyweightExercises(
  Set<StrengthTarget> targets, {
  int minutes = 30,
}) {
  final sports = [
    for (final t in StrengthTarget.values)
      if (targets.isEmpty || targets.contains(t)) t,
  ];
  final count = _mainExercises(minutes);
  final main = <BodyweightExercise>[];
  for (var round = 0; main.length < count; round++) {
    var added = false;
    for (final s in sports) {
      final list = _bySport[s]!;
      if (round < list.length && main.length < count) {
        main.add(list[round]);
        added = true;
      }
    }
    if (!added) break;
  }
  return [_warmUp, ...main, _core];
}

String _sportWord(StrengthTarget t) => switch (t) {
  StrengthTarget.swim => 'Swim',
  StrengthTarget.ride => 'Ride',
  StrengthTarget.run => 'Run',
};

/// "Bodyweight strength · Swim + Run" (all sports: no suffix).
String bodyweightStrengthName(Set<StrengthTarget> targets) {
  if (targets.isEmpty || targets.length == StrengthTarget.values.length) {
    return 'Bodyweight strength';
  }
  final sports = [
    for (final t in StrengthTarget.values)
      if (targets.contains(t)) _sportWord(t),
  ];
  return 'Bodyweight strength · ${sports.join(' + ')}';
}

/// The session's description: a purpose line, then one exercise per line.
/// Plain text, like the plan's strength sessions — Intervals.icu keeps it as
/// the WeightTraining event's notes.
String bodyweightStrengthDescription(
  Set<StrengthTarget> targets, {
  int minutes = 30,
}) {
  final sets = bodyweightSets(minutes);
  final exercises = bodyweightExercises(targets, minutes: minutes);
  return [
    'Purpose: bodyweight strength for '
        '${_targetsPhrase(targets)} — no equipment. $sets rounds, about '
        '60 s rest between rounds; stop 2-3 reps short of failure.',
    for (final e in exercises)
      e == _warmUp || e == _core
          ? '${e.name}: ${e.reps}. ${e.cue}'
          : '${e.name}: $sets x ${e.reps}. ${e.cue}',
  ].join('\n');
}

String _targetsPhrase(Set<StrengthTarget> targets) {
  final words = [
    for (final t in StrengthTarget.values)
      if (targets.isEmpty || targets.contains(t))
        switch (t) {
          StrengthTarget.swim => 'swimming',
          StrengthTarget.ride => 'cycling',
          StrengthTarget.run => 'running',
        },
  ];
  if (words.length == 1) return words.single;
  return '${words.sublist(0, words.length - 1).join(', ')} and ${words.last}';
}

/// A small fixed TSS estimate, like the plan's strength sessions (counted
/// apart from the endurance load there too).
int bodyweightStrengthLoad(int minutes) => (minutes * 0.5).round();

/// The Intervals.icu type these sessions are written as.
const bodyweightStrengthSport = strengthSport;

/// What Train now asks the training agent for when the athlete picks
/// strength: bodyweight only, aimed at [targets], about [minutes] long.
String bodyweightStrengthRequest(Set<StrengthTarget> targets, int minutes) {
  final examples = [
    for (final t in StrengthTarget.values)
      if (targets.isEmpty || targets.contains(t))
        '${_sportWord(t).toLowerCase()}: '
            '${_bySport[t]!.take(4).map((e) => e.name.toLowerCase()).join(', ')}',
  ].join('; ');
  return 'Propose a bodyweight-only strength session (Intervals.icu type '
      '$strengthSport) lasting about $minutes minutes, specific to '
      '${_targetsPhrase(targets)}. Use no equipment at all — no weights, '
      'kettlebells, bands or machines; the floor, a wall and a chair or '
      'step are fine. Kneeling, half-kneeling and floor variations count. '
      'Pick exercises that carry over to the chosen sport(s), for example '
      '$examples. Give sets, reps or time, rest, and one form cue for each.';
}
