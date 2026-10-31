import '../client/intervalls/intervalls_client.dart';
import '../util/dates.dart';
import 'intervals_session.dart';

/// A planned session about to be written to the athlete's Intervals.icu
/// calendar — the agent's proposal, reduced to the fields the API takes.
class PlannedWorkoutDraft {
  const PlannedWorkoutDraft({
    required this.name,
    required this.sport,
    required this.description,
    required this.date,
    this.durationSeconds,
    this.load,
    this.indoor = false,
    this.tags,
    this.externalId,
  });

  final String name;

  /// Intervals.icu activity type: `Ride`, `Run`, `Swim`, …
  final String sport;

  /// The workout itself, in Intervals.icu's native step syntax (`- 10m
  /// 60%`, `3x`, …). Intervals.icu parses this server-side; anything it
  /// can't parse it keeps as the session's description, so a slightly odd
  /// line degrades to a note rather than failing the request.
  final String description;

  final DateTime date;
  final int? durationSeconds;
  final int? load;
  final bool indoor;

  /// Intervals.icu tags, e.g. the plan a session belongs to, so it can be
  /// found again.
  final List<String>? tags;

  /// The creator's own id for the entry (a plan session), kept by
  /// Intervals.icu alongside it.
  final String? externalId;
}

/// What the plan code needs from Intervals.icu — an interface so plan writing
/// can be tested without a network.
abstract class PlannedWorkoutWriter {
  Future<Event> createPlannedWorkout(PlannedWorkoutDraft draft);
  Future<void> deletePlannedWorkout(String eventId);

  /// Moves the planned entry with [eventId] to [date], leaving everything
  /// else about it as it is.
  Future<void> updatePlannedWorkoutDate(String eventId, DateTime date);
}

/// Writes planned workouts to Intervals.icu.
///
/// The one place in the app that *creates* something upstream rather than
/// reading: everything else syncs down into the local cache. Kept separate
/// from [SyncService] for that reason.
class IntervalsWorkoutService implements PlannedWorkoutWriter {
  IntervalsWorkoutService({IntervalsSession? session})
    : _session = session ?? IntervalsSession.instance;

  final IntervalsSession _session;

  /// Creates [draft] on the athlete's calendar and returns the event
  /// Intervals.icu made of it — including the load and duration it computed
  /// from the structure, which may differ from what was asked for.
  @override
  Future<Event> createPlannedWorkout(PlannedWorkoutDraft draft) async {
    final client = _session.client;
    final athleteId = _session.athleteId;
    if (client == null || athleteId == null) {
      throw StateError('Not connected to Intervals.icu.');
    }

    final response = await client.getVeranstaltungenApi().createEvent(
      id: athleteId,
      // Always a new entry: nothing here has a uid to match against.
      upsertOnUid: false,
      eventEx: EventEx(
        category: EventExCategoryEnum.WORKOUT,
        // Intervals.icu wants a local date-time; a planned session has no
        // time of day, so midnight local is the convention it uses too.
        startDateLocal: '${isoDate(draft.date)}T00:00:00',
        type: draft.sport,
        name: draft.name,
        description: draft.description,
        indoor: draft.indoor,
        movingTime: draft.durationSeconds,
        icuTrainingLoad: draft.load,
        tags: draft.tags,
        externalId: draft.externalId,
      ),
    );

    final event = response.data;
    if (event == null) {
      throw StateError('Intervals.icu did not return the created event.');
    }
    return event;
  }

  /// Removes the planned entry with [eventId] from the athlete's
  /// Intervals.icu calendar.
  ///
  /// `others: false` — Intervals.icu can delete everything added in the same
  /// batch (a whole plan week) along with the entry, which is never what
  /// picking one session and confirming a deletion means here.
  @override
  Future<void> deletePlannedWorkout(String eventId) async {
    final client = _session.client;
    final athleteId = _session.athleteId;
    if (client == null || athleteId == null) {
      throw StateError('Not connected to Intervals.icu.');
    }

    // Intervals.icu event ids are numeric; the cache keeps them as strings.
    final numericId = int.tryParse(eventId);
    if (numericId == null) {
      throw StateError('“$eventId” is not an Intervals.icu event id.');
    }

    await client.getVeranstaltungenApi().deleteEvent(
      id: athleteId,
      eventId: numericId,
      others: false,
    );
  }

  /// Moves the planned entry [eventId] to [date]. Only the date is sent:
  /// the client omits null fields, so the workout's steps, load and name
  /// stay as Intervals.icu has them.
  @override
  Future<void> updatePlannedWorkoutDate(String eventId, DateTime date) async {
    final client = _session.client;
    final athleteId = _session.athleteId;
    if (client == null || athleteId == null) {
      throw StateError('Not connected to Intervals.icu.');
    }
    final numericId = int.tryParse(eventId);
    if (numericId == null) {
      throw StateError('“$eventId” is not an Intervals.icu event id.');
    }
    await client.getVeranstaltungenApi().updateEvent(
      id: athleteId,
      eventId: numericId,
      eventEx: EventEx(startDateLocal: '${isoDate(date)}T00:00:00'),
    );
  }
}
