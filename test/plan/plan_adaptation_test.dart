import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/models/local_wellness.dart';
import 'package:triiq/evaluation/readiness.dart';
import 'package:triiq/plan/knowledge.dart';
import 'package:triiq/plan/plan_adaptation.dart';
import 'package:triiq/plan/plan_models.dart';
import 'package:triiq/util/dates.dart';

/// Week 0 starts Monday 2 Nov 2026, week 1 on Monday 9 Nov.
final _w0 = DateTime(2026, 11, 2);
final _w1 = DateTime(2026, 11, 9);
DateTime _d(DateTime monday, int weekday) =>
    DateTime(monday.year, monday.month, monday.day + weekday - 1);

var _nextId = 1;
PlanSession _s(
  DateTime date,
  SessionSlot slot, {
  String sport = 'Run',
  int week = 0,
}) => PlanSession(
  id: _nextId++,
  weekIndex: week,
  date: date,
  slot: slot,
  templateId: 't',
  name: '${slot.name} $sport',
  sport: sport,
  minutes: 60,
  load: 60,
  lowMinutes: 50,
  description: '',
);

PlanWeek _week(
  int index,
  List<PlanSession> sessions, {
  double target = 500,
  double requested = 500,
  double factor = 1.0,
  String phase = 'build',
}) => PlanWeek(
  index: index,
  phase: phase,
  startDate: index == 0 ? _w0 : _w1,
  targetLoad: target,
  requestedLoad: requested,
  limit: WeekLimit.none,
  projectedCtlEnd: null,
  sessions: sessions,
  lowIntensityTarget: 0.8,
  lowIntensityTolerance: 0.05,
  factor: factor,
);

TrainingPlan _plan(List<PlanWeek> weeks) => TrainingPlan(
  id: 1,
  goalType: 'long_distance',
  sport: 'Run',
  startDate: _w0,
  baselineLoad: 400,
  weeks: weeks,
  status: PlanStatus.active,
);

const _goal = Goal(
  targetType: 'long_distance',
  weekdays: {1, 2, 3, 4, 5, 6, 7},
  weeklyHours: 8,
);

LocalActivity _done(DateTime date, String type, {int load = 60}) =>
    LocalActivity(
      id: 'a${date.day}$type',
      date: isoDate(date),
      type: type,
      name: type,
      movingTime: 3600,
      distance: null,
      trainingLoad: load,
      raw: const {},
      syncedAt: DateTime(2026),
    );

List<Adaptation> _adapt(
  TrainingPlan plan,
  DateTime today, {
  List<LocalActivity> activities = const [],
  Readiness? readiness,
  Set<String> dismissed = const {},
}) => adaptPlan(
  plan: plan,
  goal: _goal,
  activities: activities,
  today: today,
  rampCap: 0.10,
  readiness: readiness,
  dismissed: dismissed,
);

Readiness _readiness(ReadinessLevel level) => Readiness(
  level: level,
  signals: const [],
  dataState: ReadinessDataState.complete,
);

void main() {
  group('missed sessions', () {
    test('an interval session with nothing done is missed', () {
      final tue = _s(_d(_w0, 2), SessionSlot.intervals);
      final result = _adapt(
        _plan([
          _week(0, [tue]),
        ]),
        _d(_w0, 4),
      );

      expect(result.single, isA<MissedSession>());
      expect((result.single as MissedSession).session.id, tue.id);
      expect(result.single.key, 'missed:${tue.id}');
    });

    test('a ride on the day does not count for a planned run', () {
      final tue = _s(_d(_w0, 2), SessionSlot.intervals);
      final result = _adapt(
        _plan([
          _week(0, [tue]),
        ]),
        _d(_w0, 4),
        activities: [_done(_d(_w0, 2), 'Ride')],
      );

      expect(result.whereType<MissedSession>(), hasLength(1));
    });

    test('a run that day (or a trail run) means it was done', () {
      final tue = _s(_d(_w0, 2), SessionSlot.intervals);
      final result = _adapt(
        _plan([
          _week(0, [tue]),
        ]),
        _d(_w0, 4),
        activities: [_done(_d(_w0, 2), 'TrailRun')],
      );

      expect(result.whereType<MissedSession>(), isEmpty);
    });

    test('sessions from last week are not reported', () {
      final lastWeek = _s(_d(_w0, 3), SessionSlot.intervals);
      final result = _adapt(
        _plan([
          _week(0, [lastWeek]),
          _week(1, const []),
        ]),
        _d(_w1, 2),
        activities: [_done(_d(_w0, 1), 'Run', load: 500)],
      );

      expect(result.whereType<MissedSession>(), isEmpty);
    });

    test('today and later are never missed', () {
      final today = _s(_d(_w0, 4), SessionSlot.intervals);
      expect(
        _adapt(
          _plan([
            _week(0, [today]),
          ]),
          _d(_w0, 4),
        ),
        isEmpty,
      );
    });

    test('a dismissed key is filtered out', () {
      final tue = _s(_d(_w0, 2), SessionSlot.intervals);
      expect(
        _adapt(
          _plan([
            _week(0, [tue]),
          ]),
          _d(_w0, 4),
          dismissed: {'missed:${tue.id}'},
        ),
        isEmpty,
      );
    });
  });

  group('rescheduling', () {
    test('free day available: the earliest fitting day after today', () {
      final tue = _s(_d(_w0, 2), SessionSlot.intervals);
      final sat = _s(_d(_w0, 6), SessionSlot.long);
      // Wednesday is today; Thursday is free and two days from Saturday.
      final m =
          _adapt(
                _plan([
                  _week(0, [tue, sat]),
                ]),
                _d(_w0, 3),
              ).single
              as MissedSession;

      expect(m.to, _d(_w0, 4));
    });

    test('no day fits: let it go', () {
      final tue = _s(_d(_w0, 2), SessionSlot.intervals);
      // Thursday is today; Friday and Sunday sit next to Saturday's long
      // run, and Saturday itself is hard.
      final sat = _s(_d(_w0, 6), SessionSlot.long);
      final m =
          _adapt(
                _plan([
                  _week(0, [tue, sat]),
                ]),
                _d(_w0, 4),
              ).single
              as MissedSession;

      expect(m.to, isNull);
    });

    test('a full day is skipped', () {
      final tue = _s(_d(_w0, 2), SessionSlot.intervals);
      final thu = _s(_d(_w0, 4), SessionSlot.z2);
      final m =
          _adapt(
                _plan([
                  _week(0, [tue, thu]),
                ]),
                _d(_w0, 3),
              ).single
              as MissedSession;

      // Max one session a day for a run goal: Thursday is full.
      expect(m.to, _d(_w0, 5));
    });

    test('a missed Z2 session is let go, never moved', () {
      final mon = _s(_d(_w0, 1), SessionSlot.z2);
      final m =
          _adapt(
                _plan([
                  _week(0, [mon]),
                ]),
                _d(_w0, 3),
              ).single
              as MissedSession;

      expect(m.to, isNull);
    });
  });

  group('week load', () {
    test('sick week: next week to the 80 % floor, and says so', () {
      final result = _adapt(
        _plan([
          _week(0, const [], target: 500),
          _week(1, const [], target: 550, requested: 550),
        ]),
        _d(_w1, 2),
        activities: [_done(_d(_w0, 3), 'Run', load: 250)],
      );

      final load = result.single as WeekLoadOffTarget;
      expect(load.key, 'load:0');
      expect(load.factor, 0.8);
      expect(load.newLoad, 440);
      expect(load.floorLimited, isTrue);
      expect(load.uncappedLoad, closeTo(275, 1e-9));
    });

    test('overreaching week: next week capped at the ended week target', () {
      final load =
          _adapt(
                _plan([
                  _week(0, const [], target: 500),
                  _week(1, const [], target: 550, requested: 550),
                ]),
                _d(_w1, 2),
                activities: [_done(_d(_w0, 3), 'Run', load: 650)],
              ).single
              as WeekLoadOffTarget;

      expect(load.factor, 0.91);
      expect(load.under, isFalse);
    });

    test('on target: nothing', () {
      expect(
        _adapt(
          _plan([_week(0, const [], target: 500), _week(1, const [])]),
          _d(_w1, 2),
          activities: [_done(_d(_w0, 3), 'Run', load: 475)],
        ),
        isEmpty,
      );
    });

    test('next week already low enough: nothing', () {
      expect(
        _adapt(
          _plan([
            _week(0, const [], target: 500),
            _week(1, const [], requested: 550, factor: 0.8),
          ]),
          _d(_w1, 2),
          activities: [_done(_d(_w0, 3), 'Run', load: 250)],
        ),
        isEmpty,
      );
    });

    test('a taper week is never adjusted', () {
      expect(
        _adapt(
          _plan([
            _week(0, const [], target: 500),
            _week(1, const [], phase: 'taper'),
          ]),
          _d(_w1, 2),
        ),
        isEmpty,
      );
    });
  });

  group('readiness', () {
    test('back off: swap today\'s intervals with tomorrow\'s Z2', () {
      final today = _s(_d(_w0, 3), SessionSlot.intervals);
      final tomorrow = _s(_d(_w0, 4), SessionSlot.z2);
      final c =
          _adapt(
                _plan([
                  _week(0, [today, tomorrow]),
                ]),
                _d(_w0, 3),
                readiness: _readiness(ReadinessLevel.backOff),
              ).single
              as ReadinessConflict;

      expect(c.session.id, today.id);
      expect(c.swapWith?.id, tomorrow.id);
      expect(c.to, isNull);
    });

    test('no Z2 later: move by the rescheduling rule', () {
      final today = _s(_d(_w0, 2), SessionSlot.intervals);
      final c =
          _adapt(
                _plan([
                  _week(0, [today]),
                ]),
                _d(_w0, 2),
                readiness: _readiness(ReadinessLevel.caution),
              ).single
              as ReadinessConflict;

      expect(c.swapWith, isNull);
      expect(c.to, _d(_w0, 3));
    });

    test('readiness unavailable or ready: nothing', () {
      final plan = _plan([
        _week(0, [_s(_d(_w0, 3), SessionSlot.intervals)]),
      ]);
      expect(_adapt(plan, _d(_w0, 3)), isEmpty);
      expect(
        _adapt(plan, _d(_w0, 3), readiness: _readiness(ReadinessLevel.ready)),
        isEmpty,
      );
    });

    test('rated from real wellness data too', () {
      final records = [
        for (var i = 1; i <= 30; i++)
          LocalWellness(
            date: isoDate(DateTime(2026, 11, 4 - i)),
            ctl: 60,
            atl: 60,
            ctlLoad: null,
            atlLoad: null,
            rampRate: null,
            raw: {'restingHR': 48},
            syncedAt: DateTime(2026),
          ),
        LocalWellness(
          date: '2026-11-04',
          ctl: 60,
          atl: 60,
          ctlLoad: null,
          atlLoad: null,
          rampRate: null,
          raw: const {'restingHR': 60},
          syncedAt: DateTime(2026),
        ),
      ];
      final readiness = evaluateReadiness(records, _d(_w0, 3));
      final today = _s(_d(_w0, 3), SessionSlot.long);

      expect(
        _adapt(
          _plan([
            _week(0, [today]),
          ]),
          _d(_w0, 3),
          readiness: readiness,
        ),
        hasLength(1),
      );
    });
  });
}
