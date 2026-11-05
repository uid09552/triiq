/// Helpers for Intervals.icu's workout step syntax.
///
/// In that syntax a bare `m` after a number is **minutes** (`10m` = ten
/// minutes); metres are `mtr` (`300mtr`). A swim written as `- 300m Warm up`
/// is therefore read as five hours, and a whole session adds up to a day.
library;

final _timeToken = RegExp(r'(\d+(?:\.\d+)?)\s*(h|min|m|s)(?![a-z])');
final _repeatLine = RegExp(r'^(\s*)(\d+)x\s*$');
final _inlineRepeat = RegExp(r'^(\s*)-\s*(\d+)x\s*(?=\d)');

/// How many minutes the steps of [description] add up to, reading every
/// `m` as minutes (what Intervals.icu does), with `Nx` repeat blocks and
/// inline `- 4x50m` repeats multiplied out. Distances (`mtr`, `km`, `yd`)
/// count for nothing, and steps without a duration are skipped, so this is a
/// plausibility check, not Intervals.icu's own number.
double estimateStepMinutes(String description) {
  final lines = description.split('\n');
  // Open repeat blocks: (indent of the "Nx" line, repeat count).
  final stack = <(int, int)>[];
  var total = 0.0;

  int indentOf(String line) => line.length - line.trimLeft().length;

  for (final line in lines) {
    if (line.trim().isEmpty) continue;
    final indent = indentOf(line);
    while (stack.isNotEmpty && indent <= stack.last.$1) {
      stack.removeLast();
    }
    final repeat = _repeatLine.firstMatch(line);
    if (repeat != null) {
      stack.add((indent, int.parse(repeat.group(2)!)));
      continue;
    }
    if (!line.trimLeft().startsWith('-')) continue;
    var times = 1;
    for (final (_, n) in stack) {
      times *= n;
    }
    var text = line.trimLeft().substring(1);
    final inline = _inlineRepeat.firstMatch(line);
    if (inline != null) {
      times *= int.parse(inline.group(2)!);
      text = line.substring(inline.end);
    }
    // Only the step's own leading duration, not numbers in trailing text.
    final m = _timeToken.firstMatch(text.trimLeft());
    if (m == null || m.start != 0) continue;
    final value = double.parse(m.group(1)!);
    total += times *
        switch (m.group(2)!) {
          'h' => value * 60,
          's' => value / 60,
          _ => value, // m, min
        };
  }
  return total;
}

/// For a swim: rewrites step distances written as `300m` into `300mtr`
/// when reading them as minutes would make the session far longer than
/// [durationMinutes] — the sign they were metres. Without a duration it
/// converts when any single step would be 100 minutes or more, which no swim
/// has. A description whose minutes already add up is returned unchanged,
/// and `mtr` is never touched twice.
String fixSwimDistanceUnits(String description, {int? durationMinutes}) {
  final minutes = estimateStepMinutes(description);
  final suspicious = durationMinutes != null && durationMinutes > 0
      ? minutes > durationMinutes * 2 + 15
      : RegExp(r'(?<![\d.:/])\d{3,}\s*m(?![a-z])').hasMatch(description);
  if (!suspicious) return description;
  // `300m` / `4x50m` → mtr; not a pace like `1:45/100m`, not `10min`/`5ms`.
  return description.replaceAllMapped(
    RegExp(r'(?<![\d.:/])(\d+)m(?![a-z])'),
    (m) => '${m.group(1)}mtr',
  );
}
