import '../client/intervalls/intervalls_client.dart';
import '../util/dates.dart';
import 'intervals_session.dart';
import 'intervals_steps.dart';
import 'models/local_event.dart';

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
    this.startsAt,
  });

  /// The original draft of a planned entry, as complete as the cache knows
  /// it: steps, duration, load, tags, the external id and the time of day.
  /// What "undo replace" puts back.
  factory PlannedWorkoutDraft.fromEvent(LocalEvent e) {
    final tags = e.raw['tags'];
    final externalId = e.raw['external_id'];
    return PlannedWorkoutDraft(
      name: e.name ?? e.type ?? 'Workout',
      sport: e.type ?? 'Workout',
      description: e.description ?? '',
      date: DateTime.tryParse(e.date) ?? DateTime.now(),
      durationSeconds: e.plannedTime,
      load: e.plannedLoad,
      indoor: e.indoor,
      tags: tags is List ? [for (final t in tags) '$t'] : null,
      externalId: externalId is String && externalId.isNotEmpty
          ? externalId
          : null,
      startsAt: e.hasTimeOfDay ? e.startsAt : null,
    );
  }

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

  /// A time of day for the entry; null means "some time on [date]" (sent as
  /// midnight, the convention Intervals.icu uses for that).
  final DateTime? startsAt;

  /// The `start_date_local` to send.
  String get startDateLocal {
    final t = startsAt;
    String two(int v) => v.toString().padLeft(2, '0');
    return t == null
        ? '${isoDate(date)}T00:00:00'
        : '${isoDate(date)}T${two(t.hour)}:${two(t.minute)}:00';
  }
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
        startDateLocal: draft.startDateLocal,
        type: draft.sport,
        name: draft.name,
        // Whatever wrote a swim's steps (the AI trainer, the plan's session
        // content), "300m" would be read here as 300 minutes.
        description: draft.sport.toLowerCase().contains('swim')
            ? fixSwimDistanceUnits(
                draft.description,
                durationMinutes: draft.durationSeconds == null
                    ? null
                    : (draft.durationSeconds! / 60).round(),
              )
            : draft.description,
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
