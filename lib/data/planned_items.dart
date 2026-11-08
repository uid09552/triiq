import 'pending_deletes.dart';
import '../plan/plan_models.dart';
import '../util/dates.dart';
import 'models/local_event.dart';
import 'repositories/events_repository.dart';
import 'repositories/plans_repository.dart';
import 'sync/sync_settings.dart';

/// Everything planned, from one place: the current TriIQ plan's sessions
/// plus — when Settings → Calendar copies them — Intervals.icu's planned
/// events. Calendar, Today and Statistics read this instead of the events
/// table so they always agree.
///
/// A plan session that was sent to Intervals.icu shows once: as the synced
/// event when events are copied (so a move made in Intervals.icu shows),
/// otherwise from the plan. Plan sessions come back as [LocalEvent]s marked
/// with [LocalEvent.isPlanSession], so every reader keeps its one type.
class PlannedItemsRepository {
  PlannedItemsRepository({
    EventsRepository? events,
    PlansRepository? plans,
    Future<bool> Function()? copyEvents,
    this.hidePendingDeletes = true,
  }) : _events = events ?? EventsRepository(),
       _plans = plans ?? PlansRepository(),
       _copyEvents = copyEvents ?? _copyEventsSetting;

  final EventsRepository _events;
  final PlansRepository _plans;
  final Future<bool> Function() _copyEvents;

  /// Whether entries inside their undo window are left out — yes for the
  /// screens, no for what leaves the app (home widget, morning briefing):
  /// until the delete really happens the session is still planned.
  final bool hidePendingDeletes;

  static Future<bool> _copyEventsSetting() async {
    final settings = SyncSettings.instance;
    return settings.isLoaded
        ? settings.copyIntervalsEvents
        : SyncSettings.readCopyIntervalsEvents();
  }

  /// Planned items dated [oldest]..[newest] (ISO dates, inclusive), events
  /// first in their stored order, then plan sessions by date.
  Future<List<LocalEvent>> getRange(String oldest, String newest) async {
    final copy = await _copyEvents();
    final events = copy
        ? await _events.getRange(oldest, newest)
        : const <LocalEvent>[];
    final all = [
      ...events,
      ...await _planSessions(oldest, newest, events, copy),
    ];
    // Entries just deleted and still inside their undo window.
    final pending = PendingDeletes.instance;
    return !hidePendingDeletes || pending.isEmpty
        ? all
        : [
            for (final e in all)
              if (!pending.isHidden(e.id)) e,
          ];
  }

  Future<List<LocalEvent>> getByDate(String date) => getRange(date, date);

  Future<List<LocalEvent>> _planSessions(
    String oldest,
    String newest,
    List<LocalEvent> events,
    bool copy,
  ) async {
    final plan = await _plans.getCurrent();
    if (plan == null) return const [];
    // Sent sessions whose event is cached anywhere — not just in this
    // range: a session moved in Intervals.icu to another week must not
    // also show on its old plan date.
    final cachedIds = copy ? await _cachedEventIds(plan) : const <String>{};
    final result = <LocalEvent>[];
    for (final s in plan.sessions) {
      final day = isoDate(s.date);
      if (day.compareTo(oldest) < 0 || day.compareTo(newest) > 0) continue;
      final eventId = s.intervalsEventId;
      if (eventId != null && cachedIds.contains(eventId)) continue;
      result.add(toLocalEvent(s));
    }
    return result;
  }

  Future<Set<String>> _cachedEventIds(TrainingPlan plan) async {
    final ids = {
      for (final s in plan.sessions)
        if (s.intervalsEventId != null) s.intervalsEventId!,
    };
    if (ids.isEmpty) return const {};
    return _events.existingIds(ids);
  }

  /// A plan session in the shape the calendar screens read.
  static LocalEvent toLocalEvent(PlanSession s) => LocalEvent(
    id: 'plan:${s.id}',
    date: isoDate(s.date),
    category: 'WORKOUT',
    type: s.sport,
    name: s.name,
    description: s.description,
    plannedLoad: s.load,
    plannedTime: s.minutes * 60,
    plannedDistance: null,
    indoor: false,
    raw: {
      LocalEvent.planSessionKey: s.id,
      LocalEvent.planSentKey: s.status == PlanSessionStatus.created,
      LocalEvent.planSlotKey: s.slot.name,
    },
    syncedAt: DateTime.now(),
  );
}
