import 'package:flutter/material.dart';

/// One line of an Intervals.icu workout description.
sealed class WorkoutLine {
  const WorkoutLine(this.level);

  /// Nesting under a repeat block: 0 at the top, 1 inside one, …
  final int level;
}

/// Plain text: the session's purpose, a heading, a note.
class WorkoutNote extends WorkoutLine {
  const WorkoutNote(this.text, super.level);
  final String text;
}

/// `3x`, the header of a repeat block.
class WorkoutRepeat extends WorkoutLine {
  const WorkoutRepeat(this.count, super.level);
  final int count;
}

/// `- 8m 100% threshold: raises sustainable power`.
class WorkoutStep extends WorkoutLine {
  const WorkoutStep({
    required this.amount,
    required this.target,
    required this.text,
    required int level,
  }) : super(level);

  /// The time or distance, as written (`8m`, `300mtr`, `4x50mtr`).
  final String amount;

  /// The target, as written (`100%`, `85-90%`, `1:45/100m`, `Z2`), or null.
  final String? target;

  /// What follows: the exercise and its cue.
  final String text;

  /// The target as a percentage (the midpoint of a range), for the colour.
  double? get percent {
    final t = target;
    if (t == null) return null;
    final m = RegExp(r'^(\d+(?:\.\d+)?)(?:-(\d+(?:\.\d+)?))?%').firstMatch(t);
    if (m == null) return null;
    final a = double.parse(m.group(1)!);
    final b = m.group(2) == null ? a : double.parse(m.group(2)!);
    return (a + b) / 2;
  }
}

final _repeatLine = RegExp(r'^(\d+)\s*x\s*$', caseSensitive: false);
final _stepLine = RegExp(r'^[-*]\s+(.*)$');
final _targetToken = RegExp(
  r'^(?:\d+(?:\.\d+)?(?:-\d+(?:\.\d+)?)?%|\d+:\d{2}(?:/\d+\w*)?|Z\d|\d+w|RPE\d+)$',
  caseSensitive: false,
);

/// Reads Intervals.icu workout text into lines. Indentation of two spaces
/// is one level. Anything that is not a step or a repeat is a note.
List<WorkoutLine> parseWorkoutText(String text) {
  final lines = <WorkoutLine>[];
  for (final raw in text.split('\n')) {
    if (raw.trim().isEmpty) continue;
    final indent = raw.length - raw.trimLeft().length;
    final level = (indent / 2).floor();
    final line = raw.trim();

    final repeat = _repeatLine.firstMatch(line);
    if (repeat != null) {
      lines.add(WorkoutRepeat(int.parse(repeat.group(1)!), level));
      continue;
    }
    final step = _stepLine.firstMatch(line);
    if (step != null) {
      final parts = step.group(1)!.trim().split(RegExp(r'\s+'));
      final amount = parts.first;
      var rest = parts.skip(1).toList();
      String? target;
      if (rest.isNotEmpty && _targetToken.hasMatch(rest.first)) {
        target = rest.removeAt(0);
        // "95% Pace" / "70% HR": the unit word belongs to the target.
        if (rest.isNotEmpty &&
            RegExp(
              r'^(pace|hr|lthr|ftp|power)$',
              caseSensitive: false,
            ).hasMatch(rest.first)) {
          target = '$target ${rest.removeAt(0)}';
        }
      }
      lines.add(
        WorkoutStep(
          amount: amount,
          target: target,
          text: rest.join(' '),
          level: level,
        ),
      );
      continue;
    }
    lines.add(WorkoutNote(line, level));
  }
  return lines;
}

/// Whether [lines] hold any structure worth drawing as steps.
bool hasWorkoutSteps(List<WorkoutLine> lines) =>
    lines.any((l) => l is WorkoutStep || l is WorkoutRepeat);

/// The colour of a step by intensity, like power zones: grey-blue for
/// recovery, green for endurance, then yellow, orange, red, purple.
Color intensityColor(double? percent, ColorScheme scheme) {
  if (percent == null) return scheme.outline;
  if (percent < 56) return const Color(0xFF7C8DA6);
  if (percent < 76) return const Color(0xFF3FA66B);
  if (percent < 91) return const Color(0xFFD6A400);
  if (percent < 106) return const Color(0xFFEF8A17);
  if (percent < 121) return const Color(0xFFE5484D);
  return const Color(0xFF8E4EC6);
}

/// An Intervals.icu workout text as a structured session: the purpose as an
/// italic lead-in, each step with its duration, a target chip and the
/// exercise and cue, repeat blocks bracketed under their "3 ×" header, and
/// a colour bar per step by intensity. Text that holds no steps (a coach's
/// note) is shown as it is.
class WorkoutDescription extends StatelessWidget {
  const WorkoutDescription({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final lines = parseWorkoutText(text);
    final theme = Theme.of(context);
    if (!hasWorkoutSteps(lines)) {
      return SelectableText(text.trim(), style: theme.textTheme.bodyMedium);
    }

    return Column(
      key: const ValueKey('workout-steps'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final line in lines)
          switch (line) {
            WorkoutNote() => _note(theme, line),
            WorkoutRepeat() => _repeat(theme, line),
            WorkoutStep() => _step(theme, line),
          },
      ],
    );
  }

  static const _indent = 16.0;

  Widget _note(ThemeData theme, WorkoutNote note) => Padding(
    padding: EdgeInsets.only(left: note.level * _indent, top: 2, bottom: 8),
    child: SelectableText(
      note.text,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontStyle: FontStyle.italic,
        color: theme.colorScheme.onSurfaceVariant,
        height: 1.4,
      ),
    ),
  );

  Widget _repeat(ThemeData theme, WorkoutRepeat repeat) {
    final scheme = theme.colorScheme;
    return Padding(
      padding: EdgeInsets.only(left: repeat.level * _indent, top: 6, bottom: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          key: ValueKey('repeat-${repeat.count}'),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${repeat.count} ×',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.onPrimaryContainer,
            ),
          ),
        ),
      ),
    );
  }

  Widget _step(ThemeData theme, WorkoutStep step) {
    final scheme = theme.colorScheme;
    final color = intensityColor(step.percent, scheme);
    return Padding(
      padding: EdgeInsets.only(left: step.level * _indent, bottom: 4),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      step.amount,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (step.target != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          step.target!,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.brightness == Brightness.dark
                                ? color
                                : Color.alphaBlend(
                                    Colors.black.withValues(alpha: 0.35),
                                    color,
                                  ),
                          ),
                        ),
                      ),
                    if (step.text.isNotEmpty)
                      Text(
                        step.text,
                        style: theme.textTheme.bodySmall?.copyWith(
                          height: 1.35,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
