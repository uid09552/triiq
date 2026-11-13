import 'load_curve.dart';

/// Strength & mobility sessions: what a plan week gets, and their default
/// content. Deterministic — the engine picks the dose, never the language
/// model, which may only reword the content (see `session_content.dart`).
///
/// Load accounting: a strength session carries a small fixed TSS estimate
/// ([StrengthDose.load]) so the calendar and Intervals.icu show something,
/// but it is counted **separately**: it is not part of the week's endurance
/// target, the planned-vs-target figure, the load graph, the projected CTL,
/// the weekly-hours budget or the 80/20 share (see `PlanWeek`).

/// The Intervals.icu activity type strength sessions are written as.
const strengthSport = 'WeightTraining';

/// What a strength session is for.
enum StrengthFocus {
  /// Base/build: max strength and plyometrics.
  heavy,

  /// Peak: keep the strength gained with less volume.
  maintenance,

  /// Recovery and taper weeks: mobility and activation only.
  mobility,
}

/// One week's strength prescription.
class StrengthDose {
  const StrengthDose(this.focus, this.count);

  final StrengthFocus focus;

  /// Sessions this week.
  final int count;

  int get minutes => minutesFor(focus);
  int get load => loadFor(focus);

  static int minutesFor(StrengthFocus focus) => switch (focus) {
    StrengthFocus.heavy => 40,
    StrengthFocus.maintenance => 30,
    StrengthFocus.mobility => 20,
  };

  /// Estimated TSS — small, fixed, and outside the endurance load.
  static int loadFor(StrengthFocus focus) => switch (focus) {
    StrengthFocus.heavy => 25,
    StrengthFocus.maintenance => 15,
    StrengthFocus.mobility => 5,
  };
}

/// How many build weeks right before a taper are "peak" (maintenance
/// strength only).
const strengthPeakWeeks = 2;

/// The dose for a week in [phase] when the goal asks for [perWeek]
/// sessions; [peak] marks a build week just before the taper. `null` means
/// no strength that week (race week, or none asked for).
StrengthDose? strengthDoseFor(String phase, int perWeek, {bool peak = false}) {
  if (perWeek <= 0) return null;
  if (phase == racePhase) return null;
  if (phase == taperPhase || phase == recoveryPhase) {
    return const StrengthDose(StrengthFocus.mobility, 1);
  }
  if (peak || phase == 'peak') {
    return const StrengthDose(StrengthFocus.maintenance, 1);
  }
  return StrengthDose(StrengthFocus.heavy, perWeek.clamp(1, 2));
}

/// The focus a plan template phase name stands for (for the agent's
/// `get_session_template`); `null` for the race week.
StrengthFocus? strengthFocusForPhase(String phase) =>
    strengthDoseFor(phase, 1)?.focus;

String strengthTemplateId(StrengthFocus focus) => 'strength.${focus.name}';

/// The focus a plan session's `templateId` names, or `null` for a session
/// that isn't strength.
StrengthFocus? strengthFocusOf(String templateId) {
  if (!templateId.startsWith('strength.')) return null;
  return StrengthFocus.values.asNameMap()[templateId.substring(9)];
}

String strengthName(StrengthFocus focus) => switch (focus) {
  StrengthFocus.heavy => 'Strength',
  StrengthFocus.maintenance => 'Strength maintenance',
  StrengthFocus.mobility => 'Mobility',
};

/// One exercise of a strength session.
class StrengthExercise {
  const StrengthExercise(this.name, this.dose, this.purpose);

  final String name;

  /// Sets x reps (or time), with rest.
  final String dose;

  /// What it does for an endurance athlete.
  final String purpose;

  String get line => '$name: $dose. $purpose';
}

const _warmUp = StrengthExercise(
  'Warm-up',
  '5 min: leg swings, hip circles, glute bridges x 10, band walks x 10',
  'Raises tissue temperature and wakes up the glutes before loading.',
);

const _heavyA = [
  _warmUp,
  StrengthExercise(
    'Back squat or goblet squat',
    '4 x 5 heavy (RPE 7-8), 2-3 min rest',
    'Max strength for hip and knee extensors: more force per pedal stroke '
        'and stride.',
  ),
  StrengthExercise(
    'Romanian deadlift',
    '3 x 6, 2 min rest',
    'Posterior chain strength; hamstring resilience.',
  ),
  StrengthExercise(
    'Bulgarian split squat',
    '3 x 6 each leg, 90 s rest',
    'Single-leg strength; evens out left-right imbalances.',
  ),
  StrengthExercise(
    'Box jumps or pogo hops',
    '3 x 5, full recovery',
    'Plyometric: faster force production, better running economy.',
  ),
  StrengthExercise(
    'Standing calf raise',
    '3 x 10, slow lowering',
    'Calf and Achilles load tolerance.',
  ),
  StrengthExercise(
    'Pallof press',
    '3 x 10 each side',
    'Anti-rotation core: a stable pelvis late in a session.',
  ),
];

const _heavyB = [
  _warmUp,
  StrengthExercise(
    'Trap-bar deadlift',
    '4 x 5 heavy (RPE 7-8), 2-3 min rest',
    'Whole-body max strength through the hips.',
  ),
  StrengthExercise(
    'Step-ups',
    '3 x 8 each leg, 90 s rest',
    'Single-leg drive that carries over to climbing.',
  ),
  StrengthExercise(
    'Single-leg Romanian deadlift',
    '3 x 8 each leg',
    'Hip stability and hamstring strength on one leg, as in running.',
  ),
  StrengthExercise(
    'Pull-ups or band pulldowns',
    '3 x 6',
    'Lats and upper back for the swim pull and an upright posture.',
  ),
  StrengthExercise(
    'Single-leg calf raise',
    '3 x 12 each leg',
    'Calf endurance and ankle stiffness for running.',
  ),
  StrengthExercise(
    'Side plank',
    '3 x 30 s each side',
    'Lateral trunk and hip strength against pelvic drop.',
  ),
];

const _maintenance = [
  _warmUp,
  StrengthExercise(
    'Back squat or goblet squat',
    '2 x 4 heavy (RPE 7), 2 min rest',
    'Keeps the strength gained with little fatigue.',
  ),
  StrengthExercise(
    'Romanian deadlift',
    '2 x 5',
    'Maintains posterior chain strength.',
  ),
  StrengthExercise(
    'Split squat',
    '2 x 5 each leg',
    'Keeps single-leg strength.',
  ),
  StrengthExercise(
    'Pogo hops',
    '2 x 10, full recovery',
    'Keeps the springiness of the calves and tendons.',
  ),
  StrengthExercise(
    'Calf raise',
    '2 x 10',
    'Maintains calf and Achilles load tolerance.',
  ),
  StrengthExercise(
    'Dead bug',
    '2 x 8 each side',
    'Core control without soreness.',
  ),
];

const _mobility = [
  StrengthExercise(
    'Cat-cow',
    '1 min',
    'Mobilises the spine after time in the aero position or on the run.',
  ),
  StrengthExercise(
    "World's greatest stretch",
    '5 each side',
    'Opens hips, hamstrings and thoracic spine in one move.',
  ),
  StrengthExercise(
    'Half-kneeling hip flexor stretch',
    '2 x 45 s each side',
    'Counters tight hip flexors from cycling.',
  ),
  StrengthExercise(
    '90/90 hip switches',
    '2 x 8',
    'Hip rotation range for a free stride.',
  ),
  StrengthExercise(
    'Glute bridge',
    '2 x 12',
    'Glute activation without fatigue.',
  ),
  StrengthExercise(
    'Thoracic rotations',
    '8 each side',
    'Upper-back rotation for swim breathing and posture.',
  ),
  StrengthExercise(
    'Ankle rocks and calf stretch',
    '2 x 10 each side',
    'Ankle dorsiflexion for running mechanics.',
  ),
  StrengthExercise(
    'Band monster walks',
    '2 x 10 steps each way',
    'Lateral hip activation: knee tracking and pelvic stability.',
  ),
];

/// The default exercises for [focus]; [variant] alternates the two heavy
/// sessions of a week (A/B).
List<StrengthExercise> strengthExercises(
  StrengthFocus focus, {
  int variant = 0,
}) => switch (focus) {
  StrengthFocus.heavy => variant.isEven ? _heavyA : _heavyB,
  StrengthFocus.maintenance => _maintenance,
  StrengthFocus.mobility => _mobility,
};

/// The default description: a purpose line, then one exercise per line.
/// Plain text, not step syntax — Intervals.icu keeps it as the
/// WeightTraining event's notes.
String strengthDescription(StrengthFocus focus, {int variant = 0}) {
  final purpose = switch (focus) {
    StrengthFocus.heavy =>
      'Purpose: build max strength and stiffness (heavy, low reps, full '
          'rest) for economy and injury resilience. Stop 2-3 reps short of '
          'failure.',
    StrengthFocus.maintenance =>
      'Purpose: keep the strength built in the base and build weeks with '
          'low volume, so it costs no freshness before key sessions.',
    StrengthFocus.mobility =>
      'Purpose: mobility and activation only. Easy, no load, leaves you '
          'fresher than before.',
  };
  return [
    purpose,
    for (final e in strengthExercises(focus, variant: variant)) e.line,
  ].join('\n');
}
