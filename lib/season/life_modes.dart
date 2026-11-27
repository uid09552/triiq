import '../data/models/local_event.dart';
import '../util/dates.dart';
import 'illness_mode.dart';

/// A stretch of days when life gets in the way (Runna's "Not feeling
/// 100%" and holiday modes): the sessions inside the window are eased,
/// and nothing after [end] is touched — a mode never lowers later weeks.
enum LifeMode {
  /// Sick or a niggle: rest, or easy only.
  unwell,

  /// Away from home: easy and shorter, or rest.
  travel,

  /// Less time than planned: keep the sessions, shorter.
  timeCrunched,
}

/// How much to train inside the window.
enum ModeIntensity {
  /// Drop every session.
  rest,

  /// Keep the sport, easy and shorter.
  easy,

  /// Keep the session, capped at [timeCrunchedMinutes].
  shorter,
}

const timeCrunchedMinutes = 45;

/// What [mode] at [intensity] would change from [start] to [end]
/// (inclusive) among [planned]. Sessions outside the window are never
/// included. Nothing is applied here.
List<ReturnChange> lifeModeChanges({
  required LifeMode mode,
  required ModeIntensity intensity,
  required DateTime start,
  required DateTime end,
  required Iterable<LocalEvent> planned,
}) {
  final from = dateOnly(start), to = dateOnly(end);
  final out = <ReturnChange>[];
  for (final e in planned) {
    if (!e.isTraining) continue;
    final day = DateTime.tryParse(e.date);
    if (day == null) continue;
    final d = dateOnly(day);
    if (d.isBefore(from) || d.isAfter(to)) continue;
    final minutes = ((e.plannedTime ?? 3600) / 60).round();
    switch (intensity) {
      case ModeIntensity.rest:
        out.add(
          ReturnChange(
            session: e,
            action: ReturnAction.rest,
            reason: ReturnReason.lifeMode,
          ),
        );
      case ModeIntensity.easy:
        final m = (minutes * (mode == LifeMode.unwell ? 0.5 : 0.7)).round();
        final capped = m < 20 ? 20 : m;
        out.add(
          ReturnChange(
            session: e,
            action: ReturnAction.easier,
            reason: ReturnReason.lifeMode,
            minutes: capped,
            load: (capped / 60 * easyLoadPerHour).round(),
          ),
        );
      case ModeIntensity.shorter:
        if (minutes <= timeCrunchedMinutes) continue;
        final load = e.plannedLoad ?? 0;
        out.add(
          ReturnChange(
            session: e,
            action: ReturnAction.easier,
            reason: ReturnReason.lifeMode,
            minutes: timeCrunchedMinutes,
            load: (load * timeCrunchedMinutes / minutes).round(),
          ),
        );
    }
  }
  return out;
}

/// The intensities that make sense for [mode], default first.
List<ModeIntensity> intensitiesFor(LifeMode mode) => switch (mode) {
  LifeMode.unwell => const [ModeIntensity.rest, ModeIntensity.easy],
  LifeMode.travel => const [ModeIntensity.easy, ModeIntensity.rest],
  LifeMode.timeCrunched => const [ModeIntensity.shorter, ModeIntensity.easy],
};
