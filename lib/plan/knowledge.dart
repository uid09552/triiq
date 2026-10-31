import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../evaluation/insights.dart';

/// Where the knowledge lives: section 5 of the app spec, bundled as an asset.
const knowledgeAssetPath = 'docs/okf.md';

/// The numbers that shape a plan (`okf-rules` block).
class PlanRules {
  const PlanRules({
    required this.weekPhases,
    required this.weekMultipliers,
    required this.maxWeeklyIncrease,
    required this.maxCtlRamp,
    required this.lowIntensityTarget,
    required this.lowIntensityTolerance,
    required this.minHistoryWeeks,
    this.recoveryThreshold = 0.9,
    this.holdEveryWeeks = 4,
    this.recovery = const RecoveryRules(),
  });

  /// The classic 4-week shape. The load curve no longer uses it; kept so
  /// `get_session_template` can still explain phases.
  final List<String> weekPhases;
  final List<double> weekMultipliers;

  /// Largest week-over-week load increase, as a fraction (0.10 = +10%).
  final double maxWeeklyIncrease;

  /// The proposal holds every this-many-th week flat (when the goal keeps
  /// the hold on).
  final int holdEveryWeeks;

  /// How long a session takes to recover from (an estimate shown after a
  /// session; not used by the plan engine).
  final RecoveryRules recovery;

  /// A week below this fraction of the week before it is a recovery week.
  final double recoveryThreshold;

  /// Largest projected CTL gain per week.
  final double maxCtlRamp;

  /// The 80/20 share of time at low intensity, and how far below it a week
  /// may fall before it is flagged.
  final double lowIntensityTarget;
  final double lowIntensityTolerance;

  final int minHistoryWeeks;

  /// Built-in fallback, identical to the shipped `okf-rules` block.
  static const defaults = PlanRules(
    weekPhases: ['build', 'build_plus', 'peak', 'recovery'],
    weekMultipliers: [1.0, 1.08, 1.15, 0.6],
    maxWeeklyIncrease: 0.10,
    maxCtlRamp: 7.0,
    lowIntensityTarget: 0.8,
    lowIntensityTolerance: 0.05,
    minHistoryWeeks: 4,
  );

  factory PlanRules.fromJson(Map<String, dynamic> json) {
    final phases = (json['weekPhases'] as List).cast<String>();
    final multipliers = [
      for (final m in json['weekMultipliers'] as List) (m as num).toDouble(),
    ];
    if (phases.length != multipliers.length || phases.isEmpty) {
      throw const FormatException(
        'weekPhases and weekMultipliers must be the same non-zero length.',
      );
    }
    return PlanRules(
      weekPhases: phases,
      weekMultipliers: multipliers,
      maxWeeklyIncrease: (json['maxWeeklyIncrease'] as num).toDouble(),
      maxCtlRamp: (json['maxCtlRamp'] as num).toDouble(),
      lowIntensityTarget: (json['lowIntensityTarget'] as num).toDouble(),
      lowIntensityTolerance: (json['lowIntensityTolerance'] as num).toDouble(),
      minHistoryWeeks: (json['minHistoryWeeks'] as num).toInt(),
      recoveryThreshold:
          (json['recoveryThreshold'] as num?)?.toDouble() ?? 0.9,
      holdEveryWeeks: (json['holdEveryWeeks'] as num?)?.toInt() ?? 4,
      recovery: _recoveryRules(json),
    );
  }
}

/// `recoveryHours` as `[[maxTss, hours], ..., [null, hours]]`, plus
/// `recoveryFormPenaltyBelow`; the defaults when absent.
RecoveryRules _recoveryRules(Map<String, dynamic> json) {
  const fallback = RecoveryRules();
  final raw = json['recoveryHours'];
  final bands = <RecoveryBand>[];
  if (raw is List) {
    for (final b in raw) {
      if (b is List && b.length == 2 && b[1] is num) {
        bands.add(RecoveryBand((b[0] as num?)?.toInt(), (b[1] as num).toInt()));
      }
    }
  }
  return RecoveryRules(
    bands: bands.isEmpty ? fallback.bands : bands,
    formPenaltyBelow:
        (json['recoveryFormPenaltyBelow'] as num?)?.toDouble() ??
        fallback.formPenaltyBelow,
  );
}

/// The session types a week is built from, in the order they are placed.
enum SessionSlot { z2, intervals, long }

/// How a goal divides a week (`okf-goal` block).
class GoalProfile {
  const GoalProfile({
    required this.id,
    required this.label,
    required this.slots,
  });

  final String id;
  final String label;
  final Map<SessionSlot, SlotShare> slots;

  factory GoalProfile.fromJson(Map<String, dynamic> json) {
    final slots = <SessionSlot, SlotShare>{};
    for (final entry in (json['slots'] as Map<String, dynamic>).entries) {
      final slot = SessionSlot.values.asNameMap()[entry.key];
      if (slot == null) {
        throw FormatException('Unknown slot "${entry.key}".');
      }
      final value = entry.value as Map<String, dynamic>;
      slots[slot] = SlotShare(
        count: (value['count'] as num).toInt(),
        share: (value['share'] as num).toDouble(),
      );
    }
    final total = slots.values.fold<double>(0, (sum, s) => sum + s.share);
    if ((total - 1).abs() > 0.01) {
      throw FormatException('Slot shares sum to $total, not 1.');
    }
    return GoalProfile(
      id: json['id'] as String,
      label: json['label'] as String,
      slots: slots,
    );
  }
}

class SlotShare {
  const SlotShare({required this.count, required this.share});

  final int count;
  final double share;
}

/// One effort number, per sport when the same effort needs different figures.
class Intensity {
  const Intensity(this._byDefault, this._bySport);

  final double? _byDefault;
  final Map<String, double> _bySport;

  factory Intensity.fromJson(Object? json) {
    if (json is num) return Intensity(json.toDouble(), const {});
    if (json is Map<String, dynamic>) {
      return Intensity(null, {
        for (final e in json.entries) e.key: (e.value as num).toDouble(),
      });
    }
    throw FormatException('Bad intensity: $json');
  }

  /// The figure for [sport]; falls back to any value when the sport has none.
  double forSport(String sport) =>
      _bySport[sport] ?? _byDefault ?? _bySport.values.first;
}

/// A timed effort inside a repeat.
class StepEffort {
  const StepEffort({required this.minutes, required this.intensity});

  final int minutes;
  final Intensity intensity;

  factory StepEffort.fromJson(Map<String, dynamic> json) => StepEffort(
    minutes: (json['minutes'] as num).toInt(),
    intensity: Intensity.fromJson(json['pct']),
  );
}

/// One entry of a template's structure: a fixed step, a "fill the rest"
/// step, or a repeat whose count is derived from the time available.
sealed class StepSpec {
  const StepSpec();

  factory StepSpec.fromJson(Map<String, dynamic> json) {
    switch (json['kind']) {
      case 'fixed':
        return FixedStep(StepEffort.fromJson(json));
      case 'fill':
        return FillStep(Intensity.fromJson(json['pct']));
      case 'repeat':
        return RepeatStep(
          work: StepEffort.fromJson(json['work'] as Map<String, dynamic>),
          rest: StepEffort.fromJson(json['rest'] as Map<String, dynamic>),
          min: (json['min'] as num).toInt(),
          max: (json['max'] as num).toInt(),
        );
    }
    throw FormatException('Unknown step kind "${json['kind']}".');
  }
}

class FixedStep extends StepSpec {
  const FixedStep(this.effort);
  final StepEffort effort;
}

class FillStep extends StepSpec {
  const FillStep(this.intensity);
  final Intensity intensity;
}

class RepeatStep extends StepSpec {
  const RepeatStep({
    required this.work,
    required this.rest,
    required this.min,
    required this.max,
  });

  final StepEffort work;
  final StepEffort rest;
  final int min;
  final int max;
}

/// A session recipe for one goal, slot and set of phases (`okf-template`).
class SessionTemplate {
  const SessionTemplate({
    required this.id,
    required this.goal,
    required this.slot,
    required this.phases,
    required this.name,
    required this.tssPerHour,
    required this.lowShare,
    required this.steps,
    this.sports = landSports,
  });

  /// What a template without a `sports` field is for.
  static const landSports = ['Ride', 'Run'];

  final String id;
  final String goal;
  final SessionSlot slot;
  final List<String> phases;

  /// Intervals.icu sports the template is written for.
  final List<String> sports;
  final String name;

  /// Load per hour the engine assumes when turning load into minutes.
  final double tssPerHour;

  /// Fraction of the session's time at low intensity (feeds the 80/20 check).
  final double lowShare;
  final List<StepSpec> steps;

  factory SessionTemplate.fromJson(Map<String, dynamic> json) {
    final slot = SessionSlot.values.asNameMap()[json['slot']];
    if (slot == null) throw FormatException('Unknown slot "${json['slot']}".');
    final steps = [
      for (final s in json['steps'] as List)
        StepSpec.fromJson(s as Map<String, dynamic>),
    ];
    if (steps.isEmpty) throw const FormatException('A template needs steps.');
    final tssPerHour = (json['tssPerHour'] as num).toDouble();
    if (tssPerHour <= 0) throw const FormatException('tssPerHour must be > 0.');
    return SessionTemplate(
      id: json['id'] as String,
      goal: json['goal'] as String,
      slot: slot,
      phases: (json['phases'] as List).cast<String>(),
      sports: (json['sports'] as List?)?.cast<String>() ?? landSports,
      name: json['name'] as String,
      tssPerHour: tssPerHour,
      lowShare: (json['lowShare'] as num).toDouble(),
      steps: steps,
    );
  }
}

/// Thrown when no template matches — names what was asked for.
class MissingTemplateException implements Exception {
  const MissingTemplateException(
    this.goal,
    this.slot,
    this.phase, [
    this.sport = 'Run',
  ]);

  final String goal;
  final SessionSlot slot;
  final String phase;
  final String sport;

  @override
  String toString() => sport == 'Swim'
      ? 'No ${slot.name} swim template for goal "$goal" in phase "$phase".'
      : 'No ${slot.name} template for goal "$goal" in phase "$phase".';
}

/// Everything the plan engine and the agent read from the spec.
class TrainingKnowledge {
  const TrainingKnowledge({
    required this.rules,
    required this.goals,
    required this.templates,
    this.warnings = const [],
  });

  final PlanRules rules;
  final Map<String, GoalProfile> goals;
  final List<SessionTemplate> templates;

  /// Blocks that could not be read, for the UI to mention.
  final List<String> warnings;

  /// The built-in fallback: the shipped rules and a generic goal, so a plan
  /// can still be generated if the whole file is unreadable.
  static final TrainingKnowledge defaults = _buildDefaults();

  /// Reads the fenced knowledge blocks out of [markdown]. A malformed block
  /// is skipped with a warning; whatever is missing afterwards (no rules, an
  /// unknown goal) is filled from [defaults].
  factory TrainingKnowledge.parse(String markdown) {
    final text = markdown.replaceAll('\r\n', '\n');
    final fence = RegExp(
      r'^```okf-(rules|goal|template)[ \t]*\n(.*?)\n```[ \t]*$',
      multiLine: true,
      dotAll: true,
    );

    PlanRules? rules;
    final goals = <String, GoalProfile>{};
    final templates = <SessionTemplate>[];
    final warnings = <String>[];

    var index = 0;
    for (final match in fence.allMatches(text)) {
      index++;
      final kind = match.group(1)!;
      final label = 'okf-$kind block #$index';
      try {
        final json = jsonDecode(match.group(2)!) as Map<String, dynamic>;
        switch (kind) {
          case 'rules':
            rules = PlanRules.fromJson(json);
          case 'goal':
            final goal = GoalProfile.fromJson(json);
            goals[goal.id] = goal;
          case 'template':
            templates.add(SessionTemplate.fromJson(json));
        }
      } catch (error) {
        warnings.add('$label skipped: $error');
        debugPrint('TrainingKnowledge: $label skipped: $error');
      }
    }

    if (rules == null) {
      warnings.add('No usable okf-rules block; using built-in defaults.');
    }
    final fallback = defaults;
    if (goals.isEmpty) {
      // Nothing usable at all: take the built-in goals and their templates
      // together so a goal never ends up with templates it doesn't match.
      goals.addAll(fallback.goals);
      templates.addAll(fallback.templates);
      warnings.add('No usable okf-goal block; using built-in defaults.');
    }
    return TrainingKnowledge(
      rules: rules ?? PlanRules.defaults,
      goals: goals,
      templates: templates,
      warnings: warnings,
    );
  }

  /// The single template for [goal]/[slot]/[phase] and [sport], or throws
  /// [MissingTemplateException]. More than one match is a knowledge bug and
  /// reported as such rather than resolved by picking the first.
  SessionTemplate templateFor(
    String goal,
    SessionSlot slot,
    String phase, {
    String sport = 'Run',
  }) {
    final matches = templates
        .where(
          (t) =>
              t.goal == goal &&
              t.slot == slot &&
              t.phases.contains(phase) &&
              t.sports.contains(sport),
        )
        .toList();
    if (matches.isEmpty) {
      throw MissingTemplateException(goal, slot, phase, sport);
    }
    if (matches.length > 1) {
      throw StateError(
        'Several ${slot.name} templates for goal "$goal" in phase "$phase": '
        '${matches.map((t) => t.id).join(', ')}.',
      );
    }
    return matches.single;
  }

  static TrainingKnowledge _buildDefaults() {
    const phases = ['build', 'build_plus', 'peak', 'recovery'];
    SessionTemplate easy(SessionSlot slot, String name, double tss, double low) =>
        SessionTemplate(
          id: 'general.${slot.name}',
          goal: 'general',
          slot: slot,
          phases: phases,
          name: name,
          tssPerHour: tss,
          lowShare: low,
          steps: const [
            FixedStep(StepEffort(minutes: 10, intensity: Intensity(60, {}))),
            FillStep(Intensity(70, {})),
            FixedStep(StepEffort(minutes: 5, intensity: Intensity(55, {}))),
          ],
        );
    return TrainingKnowledge(
      rules: PlanRules.defaults,
      goals: {
        'general': GoalProfile(
          id: 'general',
          label: 'General fitness',
          slots: const {
            SessionSlot.z2: SlotShare(count: 2, share: 0.4),
            SessionSlot.intervals: SlotShare(count: 1, share: 0.3),
            SessionSlot.long: SlotShare(count: 1, share: 0.3),
          },
        ),
      },
      templates: [
        easy(SessionSlot.z2, 'Z2 endurance', 50, 1.0),
        easy(SessionSlot.intervals, 'Steady endurance', 60, 0.8),
        easy(SessionSlot.long, 'Long endurance', 58, 0.85),
      ],
    );
  }
}

/// Loads the knowledge from the bundled spec.
class KnowledgeRepository {
  KnowledgeRepository({Future<String> Function()? loadAsset})
    : _loadAsset = loadAsset ?? (() => rootBundle.loadString(knowledgeAssetPath));

  final Future<String> Function() _loadAsset;
  TrainingKnowledge? _cached;

  /// Never throws: an unreadable asset yields [TrainingKnowledge.defaults]
  /// with a warning saying so.
  Future<TrainingKnowledge> load() async {
    final cached = _cached;
    if (cached != null) return cached;
    try {
      return _cached = TrainingKnowledge.parse(await _loadAsset());
    } catch (error) {
      debugPrint('KnowledgeRepository: cannot read $knowledgeAssetPath: $error');
      final base = TrainingKnowledge.defaults;
      return _cached = TrainingKnowledge(
        rules: base.rules,
        goals: base.goals,
        templates: base.templates,
        warnings: ['Knowledge file could not be read; using built-in defaults.'],
      );
    }
  }
}
