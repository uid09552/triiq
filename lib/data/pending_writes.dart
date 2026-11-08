import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../client/intervalls/intervalls_client.dart';
import '../plan/plan_models.dart';
import '../util/dates.dart';
import 'db/app_database.dart';
import 'intervals_session.dart';
import 'intervals_workout_service.dart';
import 'repositories/events_repository.dart';
import 'repositories/plans_repository.dart';

/// Whether [error] means "could not reach Intervals.icu" (no network, DNS,
/// timeout, or no connection set up) — the case the queue exists for — as
/// opposed to the server rejecting the request.
bool isOfflineError(Object error) {
  if (error is SocketException) return true;
  if (error is DioException) {
    return switch (error.type) {
      DioExceptionType.connectionError ||
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => true,
      DioExceptionType.unknown => error.error is SocketException,
      _ => false,
    };
  }
  return error is StateError && '${error.message}'.startsWith('Not connected');
}

/// Thrown by [QueuedWorkoutWriter.createPlannedWorkout] when the create was
/// stored for later instead of sent. The caller must not treat the session
/// as created or failed.
class QueuedOfflineException implements Exception {
  const QueuedOfflineException();

  @override
  String toString() =>
      'Saved offline; it will be sent when you are back online.';
}

enum PendingKind { createWorkout, deleteEvent, moveEvent, replaceWorkout }

class PendingWrite {
  const PendingWrite({
    required this.id,
    required this.kind,
    required this.payload,
    required this.createdAt,
    required this.attempts,
    required this.lastError,
    required this.failed,
  });

  final int id;
  final PendingKind kind;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int attempts;
  final String? lastError;
  final bool failed;
}

/// SQLite storage of the not-yet-sent writes.
class PendingWritesRepository {
  PendingWritesRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<int> add(PendingKind kind, Map<String, dynamic> payload) async {
    final db = await _database.database;
    return db.insert('pending_writes', {
      'kind': kind.name,
      'payload': jsonEncode(payload),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<PendingWrite>> all() async {
    final db = await _database.database;
    final rows = await db.query('pending_writes', orderBy: 'id');
    return [
      for (final r in rows)
        if (PendingKind.values.asNameMap()[r['kind']] case final kind?)
          PendingWrite(
            id: r['id'] as int,
            kind: kind,
            payload: jsonDecode(r['payload'] as String) as Map<String, dynamic>,
            createdAt: DateTime.fromMillisecondsSinceEpoch(
              r['created_at'] as int,
            ),
            attempts: r['attempts'] as int,
            lastError: r['last_error'] as String?,
            failed: r['status'] == 'failed',
          ),
    ];
  }

  /// Rewrites a write's payload — a multi-step write records how far it got
  /// so a retry does not repeat a step that already succeeded.
  Future<void> updatePayload(int id, Map<String, dynamic> payload) async {
    final db = await _database.database;
    await db.update(
      'pending_writes',
      {'payload': jsonEncode(payload)},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> remove(int id) async {
    final db = await _database.database;
    await db.delete('pending_writes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> removeFailed() async {
    final db = await _database.database;
    await db.delete('pending_writes', where: "status = 'failed'");
  }

  Future<void> recordFailure(
    int id,
    String error, {
    required bool permanent,
  }) async {
    final db = await _database.database;
    await db.rawUpdate(
      'UPDATE pending_writes SET attempts = attempts + 1, last_error = ?, '
      "status = CASE WHEN ? = 1 THEN 'failed' ELSE status END WHERE id = ?",
      [error, permanent ? 1 : 0, id],
    );
  }

  Future<void> requeueFailed() async {
    final db = await _database.database;
    await db.update('pending_writes', {'status': 'pending', 'attempts': 0});
  }

  /// Event ids with a delete waiting — so a sync that still sees them
  /// upstream does not bring them back into the cache.
  Future<Set<String>> pendingDeleteIds() async {
    final writes = await all();
    return {
      for (final w in writes)
        if (!w.failed && w.kind == PendingKind.deleteEvent)
          '${w.payload['event_id']}'
        else if (!w.failed && w.kind == PendingKind.replaceWorkout)
          '${w.payload['old_event_id']}',
    };
  }
}

/// Wraps the Intervals.icu writer: when a delete or move cannot reach the
/// server it is stored and the caller carries on as if it had worked (the
/// local state is already the truth the athlete sees); the queue replays it
/// later. Creates are only queued when [queueCreates] is set, because their
/// callers need the created event back.
class QueuedWorkoutWriter implements PlannedWorkoutWriter {
  QueuedWorkoutWriter({
    PlannedWorkoutWriter? inner,
    PendingWritesService? queue,
    this.queueCreates = false,
  }) : _inner = inner ?? IntervalsWorkoutService(),
       _queue = queue ?? PendingWritesService.instance;

  final PlannedWorkoutWriter _inner;
  final PendingWritesService _queue;
  final bool queueCreates;

  @override
  Future<Event> createPlannedWorkout(PlannedWorkoutDraft draft) async {
    try {
      return await _inner.createPlannedWorkout(draft);
    } catch (e) {
      if (queueCreates &&
          isOfflineError(e) &&
          await _queue.enqueue(PendingKind.createWorkout, draftToJson(draft))) {
        throw const QueuedOfflineException();
      }
      rethrow;
    }
  }

  @override
  Future<void> deletePlannedWorkout(String eventId) async {
    try {
      await _inner.deletePlannedWorkout(eventId);
    } catch (e) {
      if (!isOfflineError(e)) rethrow;
      if (!await _queue.enqueue(PendingKind.deleteEvent, {
        'event_id': eventId,
      })) {
        rethrow;
      }
    }
  }

  @override
  Future<void> updatePlannedWorkoutDate(String eventId, DateTime date) async {
    try {
      await _inner.updatePlannedWorkoutDate(eventId, date);
    } catch (e) {
      if (!isOfflineError(e)) rethrow;
      final queued = await _queue.enqueue(PendingKind.moveEvent, {
        'event_id': eventId,
        'date': isoDate(date),
      });
      if (!queued) rethrow;
    }
  }

  static Map<String, dynamic> draftToJson(PlannedWorkoutDraft d) => {
    'name': d.name,
    'sport': d.sport,
    'description': d.description,
    'date': isoDate(d.date),
    'duration_s': d.durationSeconds,
    'load': d.load,
    'indoor': d.indoor,
    'tags': d.tags,
    'external_id': d.externalId,
    if (d.startsAt != null) 'starts_at': d.startsAt!.toIso8601String(),
  };

  static PlannedWorkoutDraft draftFromJson(Map<String, dynamic> j) =>
      PlannedWorkoutDraft(
        name: '${j['name']}',
        sport: '${j['sport']}',
        description: '${j['description']}',
        date: DateTime.parse('${j['date']}'),
        durationSeconds: (j['duration_s'] as num?)?.toInt(),
        load: (j['load'] as num?)?.toInt(),
        indoor: j['indoor'] == true,
        tags: (j['tags'] as List?)?.cast<String>(),
        externalId: j['external_id'] as String?,
        startsAt: DateTime.tryParse('${j['starts_at'] ?? ''}'),
      );
}

/// Replays queued writes in order whenever there is a chance of reaching
/// Intervals.icu (before each sync), and exposes the counts for the UI.
class PendingWritesService extends ChangeNotifier {
  PendingWritesService({
    PendingWritesRepository? repository,
    PlannedWorkoutWriter? writer,
    PlansRepository? plans,
    EventsRepository? events,
    Future<String?> Function()? athleteId,
    String? Function()? connectedAthleteId,
    this.maxAttempts = 5,
  }) : _repo = repository ?? PendingWritesRepository(),
       _writer = writer ?? IntervalsWorkoutService(),
       _plans = plans ?? PlansRepository(),
       _events = events ?? EventsRepository(),
       _athleteId = athleteId ?? IntervalsSession.lastKnownAthleteId,
       _connectedAthleteId =
           connectedAthleteId ?? (() => IntervalsSession.instance.athleteId);

  static final PendingWritesService instance = PendingWritesService();

  final PendingWritesRepository _repo;
  final PlannedWorkoutWriter _writer;
  final PlansRepository _plans;
  final EventsRepository _events;

  /// The account a write belongs to: connected now, or last connected.
  final Future<String?> Function() _athleteId;

  /// The account connected right now (null while offline).
  final String? Function() _connectedAthleteId;
  final int maxAttempts;

  int pending = 0;
  int failed = 0;
  bool _flushing = false;

  Future<void> refresh() async {
    try {
      final all = await _repo.all();
      pending = all.where((w) => !w.failed).length;
      failed = all.where((w) => w.failed).length;
      notifyListeners();
    } catch (e) {
      debugPrint('PendingWritesService: cannot read the queue: $e');
    }
  }

  /// Whether a write can be queued: only for a known Intervals.icu account
  /// (one that was connected on this device and not disconnected since).
  Future<bool> canQueue() async => await _athleteId() != null;

  /// Stores a write for later, tagged with its account. Returns false (and
  /// stores nothing) when no account is known — the caller then reports the
  /// original error instead of keeping a write nobody can send.
  Future<bool> enqueue(PendingKind kind, Map<String, dynamic> payload) async {
    final athlete = await _athleteId();
    if (athlete == null) return false;
    await _repo.add(kind, {...payload, 'athlete_id': athlete});
    await refresh();
    return true;
  }

  /// Drops every waiting write — when the athlete disconnects, so nothing
  /// made in one account is ever sent to another.
  Future<void> clearAll() async {
    for (final w in await _repo.all()) {
      await _repo.remove(w.id);
    }
    await refresh();
  }

  Future<List<PendingWrite>> list() => _repo.all();

  Future<Set<String>> pendingDeleteIds() => _repo.pendingDeleteIds();

  /// Sends the waiting writes, oldest first. Stops at the first one that
  /// still can't reach the server (the rest would fail the same way); a
  /// write the server rejects is retried a few times and then parked as
  /// failed. Returns how many were sent. Never throws.
  Future<int> flush() async {
    if (_flushing) return 0;
    _flushing = true;
    var sent = 0;
    try {
      final current = _connectedAthleteId();
      for (final w in await _repo.all()) {
        if (w.failed) continue;
        final owner = w.payload['athlete_id'];
        if (current != null && owner is String && owner != current) {
          // Made in another Intervals.icu account: never send it here.
          debugPrint('PendingWritesService: dropping a write for $owner');
          await _repo.remove(w.id);
          continue;
        }
        try {
          await _send(w);
          await _repo.remove(w.id);
          sent++;
        } catch (e) {
          if (isOfflineError(e)) break;
          final permanent =
              w.attempts + 1 >= maxAttempts ||
              (e is DioException &&
                  (e.response?.statusCode ?? 500) >= 400 &&
                  (e.response?.statusCode ?? 500) < 500 &&
                  e.response?.statusCode != 408 &&
                  e.response?.statusCode != 429);
          await _repo.recordFailure(w.id, '$e', permanent: permanent);
        }
      }
    } catch (e) {
      debugPrint('PendingWritesService: flush failed: $e');
    } finally {
      _flushing = false;
      await refresh();
    }
    return sent;
  }

  Future<void> retryFailed() async {
    await _repo.requeueFailed();
    await flush();
  }

  Future<void> discardFailed() async {
    await _repo.removeFailed();
    await refresh();
  }

  static bool _gone(Object e) =>
      e is DioException && e.response?.statusCode == 404;

  Future<void> _send(PendingWrite w) async {
    switch (w.kind) {
      case PendingKind.deleteEvent:
        try {
          await _writer.deletePlannedWorkout('${w.payload['event_id']}');
        } catch (e) {
          if (!_gone(e)) rethrow; // already gone upstream is what we wanted
        }
        await _events.deleteById('${w.payload['event_id']}');
      case PendingKind.moveEvent:
        try {
          await _writer.updatePlannedWorkoutDate(
            '${w.payload['event_id']}',
            DateTime.parse('${w.payload['date']}'),
          );
        } catch (e) {
          if (!_gone(e)) rethrow;
        }
      case PendingKind.createWorkout:
        await _sendCreate(w);
      case PendingKind.replaceWorkout:
        await _sendReplace(w);
    }
  }

  /// Replace = create the new workout, then delete the old event. The
  /// payload records that the create happened, so a retry after a failed
  /// delete does not create a second copy.
  Future<void> _sendReplace(PendingWrite w) async {
    final payload = Map<String, dynamic>.from(w.payload);
    final oldId = '${payload['old_event_id']}';
    if (payload['created'] != true) {
      var draft = QueuedWorkoutWriter.draftFromJson(
        payload['draft'] as Map<String, dynamic>,
      );
      final sessionId = (payload['plan_session_id'] as num?)?.toInt();
      PlanSession? session;
      var skipCreate = false;
      if (sessionId != null) {
        session = await _plans.getSession(sessionId);
        if (session == null) {
          skipCreate = true; // removed while offline: only clean up
        } else {
          draft = PlannedWorkoutDraft(
            name: session.name,
            sport: session.sport,
            description: session.description,
            date: session.date,
            durationSeconds: session.minutes * 60,
            load: session.load,
            indoor: draft.indoor,
            tags: draft.tags,
            externalId: draft.externalId,
          );
        }
      }
      if (!skipCreate) {
        final event = await _writer.createPlannedWorkout(draft);
        if (session != null) {
          await _plans.updateSession(
            session.copyWith(
              intervalsEventId: event.id?.toString(),
              status: PlanSessionStatus.created,
            ),
          );
        }
      }
      final placeholder = payload['placeholder_id'] as String?;
      if (placeholder != null) await _events.deleteById(placeholder);
      payload['created'] = true;
      await _repo.updatePayload(w.id, payload);
    }
    try {
      await _writer.deletePlannedWorkout(oldId);
    } catch (e) {
      if (!_gone(e)) rethrow;
    }
    await _events.deleteById(oldId);
  }

  static final _sessionIdPattern = RegExp(r'-(\d+)$');

  Future<void> _sendCreate(PendingWrite w) async {
    var draft = QueuedWorkoutWriter.draftFromJson(w.payload);
    final externalId = draft.externalId;
    final sessionId = externalId == null
        ? null
        : int.tryParse(
            _sessionIdPattern.firstMatch(externalId)?.group(1) ?? '',
          );
    PlanSession? session;
    if (sessionId != null) {
      session = await _plans.getSession(sessionId);
      // The session was moved or deleted while offline: send what it is now.
      if (session == null) return; // gone: nothing to create
      if (session.intervalsEventId != null) return; // already sent
      draft = PlannedWorkoutDraft(
        name: session.name,
        sport: session.sport,
        description: session.description,
        date: session.date,
        durationSeconds: session.minutes * 60,
        load: session.load,
        indoor: draft.indoor,
        tags: draft.tags,
        externalId: draft.externalId,
      );
    }
    final event = await _writer.createPlannedWorkout(draft);
    if (session != null) {
      await _plans.updateSession(
        session.copyWith(
          intervalsEventId: event.id?.toString(),
          status: PlanSessionStatus.created,
        ),
      );
    }
  }
}
