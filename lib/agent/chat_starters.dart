import '../data/models/local_activity.dart';
import '../data/models/local_event.dart';
import '../data/models/local_wellness.dart';
import '../data/repositories/activities_repository.dart';
import '../data/repositories/events_repository.dart';
import '../data/repositories/wellness_repository.dart';

/// What the empty chat can say about the athlete's right now.
class StarterFacts {
  const StarterFacts({this.missedDate, this.form});

  /// The latest planned session in the past week with nothing done that day.
  final DateTime? missedDate;

  /// CTL − ATL, when known.
  final double? form;

  /// Form this low is worth asking about.
  static const lowForm = -25.0;

  bool get formIsLow => form != null && form! <= lowForm;
}

String _iso(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// The most recent past-week planned session without any activity that
/// day; `null` if none. Pure, for tests.
DateTime? missedSessionDate(
  DateTime today,
  List<LocalEvent> events,
  List<LocalActivity> activities,
) {
  final done = {for (final a in activities) a.date.substring(0, 10)};
  final todayIso = _iso(today);
  DateTime? best;
  for (final e in events) {
    if (!e.isTraining) continue;
    final day = e.date.substring(0, 10);
    if (day.compareTo(todayIso) >= 0 || done.contains(day)) continue;
    final d = DateTime.parse(day);
    if (best == null || d.isAfter(best)) best = d;
  }
  return best;
}

double? formOf(LocalWellness? w) =>
    w?.ctl != null && w?.atl != null ? w!.ctl! - w.atl! : null;

/// Reads the local cache; never throws.
Future<StarterFacts> loadStarterFacts({
  DateTime? now,
  EventsRepository? events,
  ActivitiesRepository? activities,
  WellnessRepository? wellness,
}) async {
  try {
    final today = DateTime(
      (now ?? DateTime.now()).year,
      (now ?? DateTime.now()).month,
      (now ?? DateTime.now()).day,
    );
    final from = _iso(today.subtract(const Duration(days: 7)));
    final to = _iso(today);
    final e = await (events ?? EventsRepository()).getRange(from, to);
    final a = await (activities ?? ActivitiesRepository()).getRange(from, to);
    final w = wellness ?? WellnessRepository();
    final latest =
        await w.getByDate(to) ??
        await w.getByDate(_iso(today.subtract(const Duration(days: 1))));
    return StarterFacts(
      missedDate: missedSessionDate(today, e, a),
      form: formOf(latest),
    );
  } catch (_) {
    return const StarterFacts();
  }
}
