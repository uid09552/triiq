import '../season/illness_mode.dart';
import '../util/dates.dart';
import 'plan_adaptation.dart' show isHardSlot;
import 'plan_models.dart';

/// Limits on what the trainer may *propose*, enforced here in code rather
/// than left to whichever model the athlete chose: a model can be wrong or
/// too eager, and the cards it produces are one tap from changing the plan.
///
/// They are conservative guard rails on top of the plan engine's own rules
/// (weekly ramp cap, CTL ramp, recovery weeks), not training advice.

/// Why a session may not be moved to [target], or `null` when it may.
///
/// - A **hard** session (intervals or long) is never put on the same day as
///   another hard one, nor the day before or after one.
/// - It is never put on a day the athlete is logged **sick or injured**
///   (nor in the return-to-training ramp after it).
String? sessionMoveRefusal({
  required PlanSession session,
  required DateTime target,
  required Iterable<PlanSession> plan,
  ({HealthIssue issue, HealthPhase phase})? health,
}) {
  if (!isHardSlot(session.slot)) return null;
  final day = dateOnly(target);
  if (health != null) {
    final what = health.issue.kind == HealthKind.sick ? 'sick' : 'injured';
    final phase = health.phase == HealthPhase.returning
        ? 'in the return-to-training ramp after being $what'
        : 'logged as $what';
    return 'The athlete is $phase on ${isoDate(day)}: a hard session cannot '
        'be proposed there. Suggest rest or an easy session instead, and '
        'say why.';
  }
  for (final other in plan) {
    if (other.id == session.id || !isHardSlot(other.slot)) continue;
    final gap = dateOnly(other.date).difference(day).inDays.abs();
    if (gap <= 1) {
      return '${isoDate(day)} would put ${session.name} ${gap == 0 ? 'on '
                    'the same day as' : 'next to'} ${other.name} '
          '(${isoDate(other.date)}): two hard sessions back to back. '
          'Pick a day with at least one easy or rest day between them.';
    }
  }
  return null;
}

/// A week the athlete (or the trainer) asked to be heavier or lighter than
/// the plan's limits allow, and what it was limited to.
class RampClamp {
  const RampClamp({
    required this.week,
    required this.asked,
    required this.limited,
  });

  /// 1-based week number.
  final int week;

  /// TSS asked for, and TSS it was limited to.
  final int asked;
  final int limited;

  bool get raised => asked > limited;

  Map<String, dynamic> toJson() => {
    'week': week,
    'asked': asked,
    'limited': limited,
  };

  static RampClamp? fromJson(Object? json) {
    if (json is! Map) return null;
    final w = json['week'], a = json['asked'], l = json['limited'];
    if (w is! num || a is! num || l is! num) return null;
    return RampClamp(week: w.toInt(), asked: a.toInt(), limited: l.toInt());
  }
}

/// Signs in an athlete's own words that call for a doctor, not a training
/// tip. Deliberately narrow: it is a safety net for the clearest cases, in
/// English and German, never a diagnosis. Everything else is left to the
/// trainer and its instructions.
enum RedFlag {
  chestPain,
  fainting,
  breathing,
  palpitations,
  disorderedEating,
  pregnancy,
  severePain,
}

final _redFlags = <RedFlag, RegExp>{
  RedFlag.chestPain: RegExp(
    r'chest (pain|pressure|tightness)|pain in (my )?chest|'
    r'brustschmerz|schmerz(en)? in der brust|druck (in|auf) der brust|'
    r'brustenge',
    caseSensitive: false,
  ),
  RedFlag.fainting: RegExp(
    r'\b(fainted|passed out|blacked out|faint(ing)?|collapsed)\b|'
    r'ohnmacht|kollabiert|bewusstlos|umgekippt',
    caseSensitive: false,
  ),
  RedFlag.breathing: RegExp(
    r"can'?t breathe|cannot breathe|struggling to breathe|"
    r'short(ness)? of breath at rest|'
    r'keine luft|atemnot|schwer(e)? atmen',
    caseSensitive: false,
  ),
  RedFlag.palpitations: RegExp(
    r'palpitations|heart (racing|skipping|fluttering) (at rest|for)|'
    r'irregular heart|herzrasen|herzstolpern|herzrhythmus',
    caseSensitive: false,
  ),
  RedFlag.disorderedEating: RegExp(
    r'\b(purg(e|ed|ing)|binge|binging|bingeing|make myself (throw up|vomit|sick)|'
    r'laxatives?|starv(e|ing) myself|not eating (at all|for days))\b|'
    r'erbrechen nach dem essen|mich übergeben|abführmittel|essanfall|'
    r'fressattacke|hungere|nichts (mehr )?essen',
    caseSensitive: false,
  ),
  RedFlag.pregnancy: RegExp(
    r"\b(i'?m pregnant|i am pregnant|pregnancy|pregnant)\b|"
    r'schwanger|schwangerschaft',
    caseSensitive: false,
  ),
  RedFlag.severePain: RegExp(
    r'(severe|sharp|stabbing|unbearable) pain|pain (keeps getting|getting) worse|'
    r"can'?t (put weight|walk) on|swollen and (hot|red)|"
    r'starke(n)? schmerzen|stechende(n)? schmerzen|kann nicht (mehr )?auftreten|'
    r'schmerz wird schlimmer',
    caseSensitive: false,
  ),
};

/// The red flags [message] mentions, if any.
List<RedFlag> redFlagsIn(String message) => [
  for (final e in _redFlags.entries)
    if (e.value.hasMatch(message)) e.key,
];

/// What a trainer reply must not set: calorie or weight targets, deficits,
/// fasting. Fuelling for training (carbs per hour, race fuelling) is fine.
/// The check is on the finished reply, in code, because a small model can
/// ignore the same rule in its prompt.
enum DietConcern { calorieTarget, deficit, weightLoss, fasting }

final _dietConcerns = <DietConcern, RegExp>{
  DietConcern.calorieTarget: RegExp(
    r'\b\d[\d.,]{2,5}\s*(kcal|calories|kalorien|cal)\b[^.\n]{0,24}'
    r'(per day|a day|each day|daily|/\s*day|pro tag|am tag|täglich|/\s*tag)|'
    r'(eat|consume|limit (yourself )?to|stay under|aim for|iss|nimm) '
    r'[^.\n]{0,20}\d[\d.,]{2,5}\s*(kcal|calories|kalorien)',
    caseSensitive: false,
  ),
  DietConcern.deficit: RegExp(
    r'calori(e|c) deficit|energy deficit|kaloriendefizit|energiedefizit|'
    r'\bdeficit of \d',
    caseSensitive: false,
  ),
  DietConcern.weightLoss: RegExp(
    r'\blose \d+([.,]\d+)?\s*(kg|kilos?|lbs?|pounds)|'
    r'\d+([.,]\d+)?\s*(kg|lbs?|pounds) (per|a|each|/) ?week|'
    r'weight[- ]loss (target|goal|plan)|race weight target|'
    r'\d+([.,]\d+)?\s*kg (abnehmen|verlieren|pro woche)|'
    r'abnehmziel|wettkampfgewicht (erreichen|ziel)',
    caseSensitive: false,
  ),
  DietConcern.fasting: RegExp(
    r'intermittent fasting|\bfast(ed)? (for|until|training sessions?)|'
    r'skip (breakfast|meals?|dinner)|'
    r'intervallfasten|nüchterntraining|mahlzeiten (auslassen|weglassen)|'
    r'frühstück (auslassen|weglassen)',
    caseSensitive: false,
  ),
};

/// The diet concerns [reply] raises, if any.
List<DietConcern> dietConcernsIn(String reply) => [
  for (final e in _dietConcerns.entries)
    if (e.value.hasMatch(reply)) e.key,
];
