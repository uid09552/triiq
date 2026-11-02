import '../client/intervalls/intervalls_client.dart';
import '../util/dates.dart';
import 'intervals_session.dart';
import 'models/local_event.dart';
import 'repositories/events_repository.dart';

/// The calendar categories the Events screen creates and edits. Workouts
/// have their own flow (plans, chat); `PLAN` and the `SET_*` markers are
/// written by Intervals.icu itself.
const editableEventCategories = <String>[
  'RACE_A',
  'RACE_B',
  'RACE_C',
  'NOTE',
  'HOLIDAY',
  'SICK',
  'INJURED',
  'TARGET',
  'SEASON_START',
];

/// Races, which carry a sport.
bool eventCategoryHasSport(String? category) =>
    category == 'RACE_A' || category == 'RACE_B' || category == 'RACE_C';

/// Categories that can span several days.
bool eventCategoryHasEndDate(String? category) =>
    category == 'HOLIDAY' ||
    category == 'SICK' ||
    category == 'INJURED' ||
    category == 'TARGET';

/// What the editor produces: one calendar event, ready to send.
class EventDraft {
  const EventDraft({
    required this.category,
    required this.name,
    required this.date,
    this.endDate,
    this.sport,
    this.description,
  });

  final String category;
  final String name;
  final DateTime date;

  /// Last day, for [eventCategoryHasEndDate] categories; `null` = one day.
  final DateTime? endDate;
  final String? sport;
  final String? description;
}

/// Creates, edits and deletes calendar events (races, notes, holidays, …)
/// in the athlete's Intervals.icu calendar — the source of truth — and
/// mirrors the result into the local cache so the app shows it at once.
class IntervalsEventService {
  IntervalsEventService({
    IntervalsSession? session,
    EventsRepository? repository,
  }) : _session = session ?? IntervalsSession.instance,
       _repository = repository ?? EventsRepository();

  final IntervalsSession _session;
  final EventsRepository _repository;

  Future<LocalEvent> create(EventDraft draft) async {
    final (client, athleteId) = _connection();
    final response = await client.getVeranstaltungenApi().createEvent(
      id: athleteId,
      upsertOnUid: false,
      eventEx: _toEventEx(draft),
    );
    return _store(response.data);
  }

  Future<LocalEvent> update(String eventId, EventDraft draft) async {
    final (client, athleteId) = _connection();
    final response = await client.getVeranstaltungenApi().updateEvent(
      id: athleteId,
      eventId: _numericId(eventId),
      eventEx: _toEventEx(draft),
    );
    return _store(response.data);
  }

  Future<void> delete(String eventId) async {
    final (client, athleteId) = _connection();
    await client.getVeranstaltungenApi().deleteEvent(
      id: athleteId,
      eventId: _numericId(eventId),
      others: false,
    );
    await _repository.deleteById(eventId);
  }

  static EventEx _toEventEx(EventDraft draft) => EventEx(
    category: EventExCategoryEnum.values.firstWhere(
      (c) => c.value == draft.category,
    ),
    startDateLocal: '${isoDate(draft.date)}T00:00:00',
    // Sent as null (omitted) for single-day entries.
    endDateLocal: eventCategoryHasEndDate(draft.category) &&
            draft.endDate != null &&
            draft.endDate!.isAfter(draft.date)
        ? '${isoDate(draft.endDate!)}T00:00:00'
        : null,
    name: draft.name,
    description: draft.description,
    type: eventCategoryHasSport(draft.category) ? draft.sport : null,
  );

  Future<LocalEvent> _store(Event? event) async {
    if (event == null) {
      throw StateError('Intervals.icu did not return the event.');
    }
    final record = LocalEvent.fromApi(event);
    await _repository.upsert(record);
    return record;
  }

  (IntervallsClient, String) _connection() {
    final client = _session.client;
    final athleteId = _session.athleteId;
    if (client == null || athleteId == null) {
      throw StateError('Not connected to Intervals.icu.');
    }
    return (client, athleteId);
  }

  static int _numericId(String eventId) =>
      int.tryParse(eventId) ??
      (throw StateError('“$eventId” is not an Intervals.icu event id.'));
}
