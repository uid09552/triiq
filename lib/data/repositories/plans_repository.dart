import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../plan/knowledge.dart';
import '../../plan/plan_models.dart';
import '../../util/dates.dart';
import '../db/app_database.dart';

/// Reads and writes training plans and their sessions.
class PlansRepository {
  PlansRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  /// Stores [plan] and its sessions; returns the plan with database ids.
  Future<TrainingPlan> save(TrainingPlan plan) async {
    final db = await _database.database;
    return db.transaction((txn) async {
      final planId = await txn.insert('plans', {
        'goal_type': plan.goalType,
        'sport': plan.sport,
        'start_date': isoDate(plan.startDate),
        'baseline_load': plan.baselineLoad,
        'status': plan.status.name,
        'meta': jsonEncode({
          'weeks': [for (final w in plan.weeks) _weekToJson(w)],
          'sportMix': plan.sportMix,
        }),
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
      final weeks = <PlanWeek>[];
      for (final week in plan.weeks) {
        final sessions = <PlanSession>[];
        for (final session in week.sessions) {
          final id = await txn.insert(
            'plan_sessions',
            _sessionToMap(session, planId),
          );
          sessions.add(session.copyWith(id: id));
        }
        weeks.add(week.withSessions(sessions));
      }
      return plan.copyWith(id: planId, weeks: weeks);
    });
  }

  /// The newest plan that isn't removed, or `null`.
  Future<TrainingPlan?> getCurrent() async {
    final db = await _database.database;
    final rows = await db.query(
      'plans',
      where: 'status != ?',
      whereArgs: [PlanStatus.removed.name],
      orderBy: 'id DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _load(db, rows.first);
  }

  Future<TrainingPlan?> getById(int id) async {
    final db = await _database.database;
    final rows = await db.query('plans', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : _load(db, rows.first);
  }

  Future<void> setStatus(int planId, PlanStatus status) async {
    final db = await _database.database;
    await db.update(
      'plans',
      {'status': status.name},
      where: 'id = ?',
      whereArgs: [planId],
    );
  }

  Future<void> updateSession(PlanSession session) async {
    final id = session.id;
    if (id == null) throw ArgumentError('Session has not been saved yet.');
    final db = await _database.database;
    await db.update(
      'plan_sessions',
      {
        'date': isoDate(session.date),
        'description': session.description,
        'intervals_event_id': session.intervalsEventId,
        'calendar_event_id': session.calendarEventId,
        'status': session.status.name,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Swaps what session [id] *is* — sport, name, duration, load, steps —
  /// keeping its plan, week, slot and date. What "replace today's session
  /// with an alternative" needs; [intervalsEventId] and [status] describe
  /// where the new content lives.
  Future<void> replaceSessionContent(
    int id, {
    required String sport,
    required String name,
    required int minutes,
    required int load,
    required double lowMinutes,
    required String description,
    required String? intervalsEventId,
    required PlanSessionStatus status,
  }) async {
    final db = await _database.database;
    await db.update(
      'plan_sessions',
      {
        'sport': sport,
        'name': name,
        'minutes': minutes,
        'load': load,
        'low_minutes': lowMinutes,
        'description': description,
        'intervals_event_id': intervalsEventId,
        'status': status.name,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int?> planIdOfSession(int sessionId) async {
    final db = await _database.database;
    final rows = await db.query(
      'plan_sessions',
      columns: ['plan_id'],
      where: 'id = ?',
      whereArgs: [sessionId],
    );
    return rows.isEmpty ? null : rows.first['plan_id'] as int;
  }

  Future<PlanSession?> getSession(int id) async {
    final db = await _database.database;
    final rows = await db.query(
      'plan_sessions',
      where: 'id = ?',
      whereArgs: [id],
    );
    return rows.isEmpty ? null : _sessionFromMap(rows.first);
  }

  Future<void> deleteSession(int id) async {
    final db = await _database.database;
    await db.delete('plan_sessions', where: 'id = ?', whereArgs: [id]);
  }

  Future<TrainingPlan> _load(Database db, Map<String, Object?> row) async {
    final planId = row['id'] as int;
    final sessionRows = await db.query(
      'plan_sessions',
      where: 'plan_id = ?',
      whereArgs: [planId],
      orderBy: 'date ASC, id ASC',
    );
    final sessions = sessionRows.map(_sessionFromMap).toList();
    // Plans saved before the load curve stored a bare list of weeks.
    final decoded = jsonDecode(row['meta'] as String);
    final meta = decoded is Map<String, dynamic> ? decoded : {'weeks': decoded};
    final weekMeta = (meta['weeks'] as List).cast<Map<String, dynamic>>();
    final weeks = [
      for (final w in weekMeta)
        _weekFromJson(
          w,
          sessions.where((s) => s.weekIndex == w['index']).toList(),
        ),
    ];
    return TrainingPlan(
      id: planId,
      goalType: row['goal_type'] as String,
      sport: row['sport'] as String,
      startDate: DateTime.parse(row['start_date'] as String),
      baselineLoad: (row['baseline_load'] as num).toDouble(),
      weeks: weeks,
      status: PlanStatus.values.byName(row['status'] as String),
      sportMix: {
        for (final e
            in (meta['sportMix'] as Map<String, dynamic>? ?? const {}).entries)
          e.key: (e.value as num).toInt(),
      },
    );
  }

  Map<String, Object?> _sessionToMap(PlanSession s, int planId) => {
    'plan_id': planId,
    'week_index': s.weekIndex,
    'date': isoDate(s.date),
    'slot': s.slot.name,
    'template_id': s.templateId,
    'name': s.name,
    'sport': s.sport,
    'minutes': s.minutes,
    'load': s.load,
    'low_minutes': s.lowMinutes,
    'description': s.description,
    'intervals_event_id': s.intervalsEventId,
    'calendar_event_id': s.calendarEventId,
    'status': s.status.name,
  };

  PlanSession _sessionFromMap(Map<String, Object?> row) => PlanSession(
    id: row['id'] as int,
    weekIndex: row['week_index'] as int,
    date: DateTime.parse(row['date'] as String),
    slot: SessionSlot.values.byName(row['slot'] as String),
    templateId: row['template_id'] as String,
    name: row['name'] as String,
    sport: row['sport'] as String,
    minutes: row['minutes'] as int,
    load: row['load'] as int,
    lowMinutes: (row['low_minutes'] as num).toDouble(),
    description: row['description'] as String,
    intervalsEventId: row['intervals_event_id'] as String?,
    calendarEventId: row['calendar_event_id'] as String?,
    status: PlanSessionStatus.values.byName(row['status'] as String),
  );

  Map<String, dynamic> _weekToJson(PlanWeek w) => {
    'index': w.index,
    'phase': w.phase,
    'startDate': isoDate(w.startDate),
    'targetLoad': w.targetLoad,
    'requestedLoad': w.requestedLoad,
    'limit': w.limit.name,
    'projectedCtlEnd': w.projectedCtlEnd,
    'lowIntensityTarget': w.lowIntensityTarget,
    'lowIntensityTolerance': w.lowIntensityTolerance,
    'factor': w.factor,
    'warnings': [for (final l in w.warnings) l.name],
    'notes': w.notes,
  };

  PlanWeek _weekFromJson(Map<String, dynamic> j, List<PlanSession> sessions) =>
      PlanWeek(
        index: j['index'] as int,
        phase: j['phase'] as String,
        startDate: DateTime.parse(j['startDate'] as String),
        targetLoad: (j['targetLoad'] as num).toDouble(),
        requestedLoad: (j['requestedLoad'] as num).toDouble(),
        limit: WeekLimit.values.byName(j['limit'] as String),
        projectedCtlEnd: (j['projectedCtlEnd'] as num?)?.toDouble(),
        sessions: sessions,
        lowIntensityTarget: (j['lowIntensityTarget'] as num).toDouble(),
        lowIntensityTolerance: (j['lowIntensityTolerance'] as num).toDouble(),
        factor: (j['factor'] as num?)?.toDouble() ?? 1.0,
        warnings: {
          for (final name in j['warnings'] as List? ?? const [])
            WeekLimit.values.byName(name as String),
        },
        notes: [
          for (final n in j['notes'] as List? ?? const []) n as String,
        ],
      );
}
