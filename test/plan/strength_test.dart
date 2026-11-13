import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:langchain_core/chat_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/agent/llm_settings.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/evaluation/session_evaluator.dart';
import 'package:triiq/evaluation/weekly_review.dart';
import 'package:triiq/plan/knowledge.dart';
import 'package:triiq/plan/plan_adaptation.dart';
import 'package:triiq/plan/plan_engine.dart';
import 'package:triiq/plan/plan_models.dart';
import 'package:triiq/plan/session_content.dart';
import 'package:triiq/plan/strength.dart';
import 'package:triiq/util/dates.dart';

void main() {
  final knowledge = TrainingKnowledge.parse(
    File('docs/okf.md').readAsStringSync(),
  );
  final engine = PlanEngine(knowledge);
  final monday = DateTime(2026, 8, 31);
  final today = DateTime(2026, 8, 26);
  const history = [300.0, 320.0, 280.0, 300.0];

  Goal goal({
    int strength = 0,
    Set<int> days = const {2, 4, 6, 7},
    Set<int> strengthDays = const {},
    String sport = 'Run',
    DateTime? event,
    List<double> factors = const [],
  }) => Goal(
    targetType: 'long_distance',
    weekdays: days,
    weeklyHours: 40,
    sport: sport,
    baselineWeeklyLoad: 300,
    eventDate: event,
    loadFactors: factors,
    strengthPerWeek: strength,
    strengthDays: strengthDays,
  );

  TrainingPlan plan(Goal g) {
    final result = engine.generate(
      goal: g,
      startDate: monday,
      recentWeeklyLoads: history,
      currentCtl: 40,
      today: today,
    );
    expect(result.failure?.message, isNull);
    return result.plan!;
  }

  DateTime plusDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);

  /// The placement rules every strength session keeps.
  void expectPlacementRules(TrainingPlan p, Goal g) {
    final hard = {
      for (final s in p.sessions)
        if (s.slot == SessionSlot.intervals || s.slot == SessionSlot.long)
          s.date,
    };
    final strength = p.sessions.where((s) => s.isStrength).toList();
    for (final s in strength) {
      expect(g.weekdays, contains(s.date.weekday), reason: '${s.date}');
      expect(
        hard.contains(plusDays(s.date, 1)),
        isFalse,
        reason: 'strength on ${s.date} is the day before a key session',
      );
      final sameDay = p.sessions.where(
        (o) => o.date == s.date && !o.isStrength,
      );
      expect(sameDay.length, lessThan(2));
      expect(
        strength.where(
          (o) => o != s && (o.date.difference(s.date).inDays.abs() <= 1),
        ),
        isEmpty,
        reason: 'strength on consecutive days around ${s.date}',
      );
      expect(s.sport, strengthSport);
    }
  }

  group('goal', () {
    test('a saved goal without the option loads with no strength', () {
      final json = goal(strength: 2).toJson()
        ..remove('strengthPerWeek')
        ..remove('strengthDays');
      final back = Goal.fromJson(json);
      expect(back.strengthPerWeek, 0);
      expect(back.strengthDays, isEmpty);
    });

    test('round-trips through JSON', () {
      final g = goal(strength: 2, strengthDays: {2, 6});
      final back = Goal.fromJson(jsonDecode(jsonEncode(g.toJson())));
      expect(back.strengthPerWeek, 2);
      expect(back.strengthDays, {2, 6});
    });

    test('validation: 0-2 a week, on training days', () {
      expect(goal(strength: 3).validate(today: today), isNotNull);
      expect(
        goal(strength: 1, strengthDays: {1}).validate(today: today),
        isNotNull,
      );
      expect(
        goal(strength: 1, strengthDays: {2}).validate(today: today),
        isNull,
      );
      expect(
        goal(
          strength: 1,
          strengthDays: {2},
        ).copyWith(weekdays: {4, 6, 7}).withoutStalePreferences().strengthDays,
        isEmpty,
      );
    });
  });

  group('engine', () {
    test('no strength asked for: no strength sessions', () {
      expect(plan(goal()).sessions.where((s) => s.isStrength), isEmpty);
    });

    test('build weeks: up to two heavy sessions, placement rules kept', () {
      final g = goal(strength: 2);
      final p = plan(g);
      for (final w in p.weeks) {
        final s = w.strengthSessions.toList();
        expect(s, hasLength(2), reason: 'week ${w.index}');
        expect(
          s.map((x) => strengthFocusOf(x.templateId)),
          everyElement(StrengthFocus.heavy),
        );
        expect(s.first.minutes, inInclusiveRange(30, 45));
      }
      expectPlacementRules(p, g);
    });

    test('strength never moves or changes the endurance sessions', () {
      final without = plan(goal());
      final withStrength = plan(goal(strength: 2));
      for (var i = 0; i < without.weeks.length; i++) {
        final a = without.weeks[i];
        final b = withStrength.weeks[i];
        expect(
          b.enduranceSessions.map((s) => (s.date, s.slot, s.minutes, s.load)),
          a.sessions.map((s) => (s.date, s.slot, s.minutes, s.load)),
        );
        // Counted apart: target, planned load, 80/20 and CTL are unchanged.
        expect(b.plannedLoad, a.plannedLoad);
        expect(b.totalMinutes, a.totalMinutes);
        expect(b.lowShare, a.lowShare);
        expect(b.loadBySport, a.loadBySport);
        expect(b.projectedCtlEnd, a.projectedCtlEnd);
        expect(b.strengthLoad, greaterThan(0));
      }
    });

    test('phases: heavy, maintenance before the taper, mobility in the '
        'taper, none in race week', () {
      // Seven weeks: build x5, taper, race.
      final g = goal(strength: 2, event: DateTime(2026, 10, 18));
      final p = plan(g);
      expect(p.weeks.map((w) => w.phase).toList().sublist(4), [
        'build',
        'taper',
        'race',
      ]);
      StrengthFocus? focus(int i) => p.weeks[i].strengthSessions.isEmpty
          ? null
          : strengthFocusOf(p.weeks[i].strengthSessions.first.templateId);
      for (final i in [0, 1, 2]) {
        expect(focus(i), StrengthFocus.heavy, reason: 'week $i');
      }
      for (final i in [3, 4]) {
        expect(p.weeks[i].strengthSessions, hasLength(1), reason: 'week $i');
        expect(focus(i), StrengthFocus.maintenance, reason: 'week $i');
      }
      expect(p.weeks[5].strengthSessions, hasLength(1));
      expect(focus(5), StrengthFocus.mobility);
      expect(p.weeks[6].strengthSessions, isEmpty);
      // Never on a taper week's key-session day.
      final taper = p.weeks[5];
      for (final s in taper.strengthSessions) {
        expect(
          taper.sessions.where(
            (o) =>
                o.date == s.date &&
                (o.slot == SessionSlot.intervals || o.slot == SessionSlot.long),
          ),
          isEmpty,
        );
      }
      expectPlacementRules(p, g);
    });

    test('a recovery week gets mobility only', () {
      final g = goal(strength: 2, factors: [1.0, 1.0, 0.8]);
      final p = plan(g);
      expect(p.weeks[2].phase, 'recovery');
      final s = p.weeks[2].strengthSessions.toList();
      expect(s, hasLength(1));
      expect(strengthFocusOf(s.single.templateId), StrengthFocus.mobility);
      expect(s.single.load, lessThan(10));
    });

    test('a preferred strength day is used when it keeps the rules', () {
      final g = goal(strength: 1, strengthDays: {4});
      final p = plan(g);
      // Thursday holds the interval run in this layout; Friday is free, so
      // the preferred day keeps the rules and wins over an easy day.
      final days = p.sessions.where((s) => s.isStrength).map((s) => s.date);
      expect(days.map((d) => d.weekday), everyElement(4));
      expectPlacementRules(p, g);
    });

    test('triathlon: rules hold with two sessions a day', () {
      final g = goal(
        strength: 2,
        sport: Goal.triathlon,
        days: {1, 2, 3, 4, 6, 7},
      );
      final p = plan(g);
      expect(p.sessions.where((s) => s.isStrength), isNotEmpty);
      expectPlacementRules(p, g);
    });

    test('a week short of its dose says so in a note', () {
      final g = goal(strength: 2, days: {5, 6, 7});
      final p = plan(g);
      for (final w in p.weeks) {
        expect(
          w.notes.contains(PlanEngine.noteStrength),
          w.strengthSessions.length < 2,
          reason: 'week ${w.index}',
        );
      }
      expectPlacementRules(p, g);
    });
  });

  group('content', () {
    test('default exercises per focus', () {
      final heavy = strengthDescription(StrengthFocus.heavy);
      expect(heavy, contains('squat'));
      expect(heavy, contains('Romanian deadlift'));
      expect(heavy, contains('Purpose'));
      final b = strengthDescription(StrengthFocus.heavy, variant: 1);
      expect(b, contains('Step-ups'));
      final mobility = strengthDescription(StrengthFocus.mobility);
      expect(mobility, contains('hip flexor'));
      expect(mobility, isNot(contains('heavy')));
      // Plain text: no step-syntax lines Intervals.icu would read as steps.
      for (final text in [heavy, b, mobility]) {
        expect(text.split('\n').where((l) => l.startsWith('- ')), isEmpty);
      }
      for (final f in StrengthFocus.values) {
        for (final e in strengthExercises(f)) {
          expect(e.purpose, isNotEmpty);
        }
      }
    });

    test('dose by phase', () {
      expect(strengthDoseFor('build', 2)!.focus, StrengthFocus.heavy);
      expect(strengthDoseFor('build', 2)!.count, 2);
      expect(strengthDoseFor('build', 2, peak: true)!.count, 1);
      expect(strengthDoseFor('recovery', 2)!.focus, StrengthFocus.mobility);
      expect(strengthDoseFor('taper', 1)!.focus, StrengthFocus.mobility);
      expect(strengthDoseFor('race', 2), isNull);
      expect(strengthDoseFor('build', 0), isNull);
    });

    test('the LLM gets strength sessions with their focus', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      final settings = LlmSettings.forTesting();
      await settings.load();
      await settings.setClaudeApiKey('sk-ant-test');
      List<ChatMessage>? sent;
      final g = SessionContentGenerator(
        settings: settings,
        chatCall: (s, messages) async {
          sent = messages;
          return AIChatMessage.text('[]');
        },
      );
      final p = plan(goal(strength: 1, days: {2, 4, 6}).copyWith(weeks: 2));
      await g.enrich(p);
      final system = sent!.first.contentAsString;
      expect(system, contains('"strength_focus"'));
      final facts = jsonDecode(sent!.last.contentAsString) as List;
      expect(
        facts.where((f) => f['slot'] == 'strength'),
        everyElement(containsPair('strength_focus', 'heavy')),
      );
      expect(facts.where((f) => f['slot'] == 'strength'), isNotEmpty);
    });
  });

  group('tracking', () {
    LocalActivity done(String date, String type, {int minutes = 40}) =>
        LocalActivity(
          id: '$date$type',
          date: date,
          type: type,
          name: type,
          movingTime: minutes * 60,
          distance: null,
          trainingLoad: 30,
          raw: const {},
          syncedAt: DateTime(2026),
        );
    LocalEvent planned(String date, String type, {String? slot}) => LocalEvent(
      id: '$date$type',
      date: date,
      category: 'WORKOUT',
      type: type,
      name: type,
      description: null,
      plannedLoad: 25,
      plannedTime: 2400,
      plannedDistance: null,
      indoor: false,
      raw: {LocalEvent.planSlotKey: ?slot},
      syncedAt: DateTime(2026),
    );

    test('a WeightTraining activity fulfils a planned strength session', () {
      final p = planned('2026-11-03', strengthSport, slot: 'strength');
      expect(matchPlanned(done('2026-11-03', 'WeightTraining'), [p]), p);
      expect(matchPlanned(done('2026-11-03', 'Run'), [p]), isNull);
      // Judged on duration only, never as too hard by its HR load.
      final eval = const SessionEvaluator().evaluate(
        done('2026-11-03', 'WeightTraining'),
        planned: p,
      );
      expect(eval.verdict, Verdict.onTarget);
      expect(eval.intent, SessionIntent.unknown);
    });

    test('weekly review counts strength done of planned', () {
      final r = buildWeeklyReview(
        weekStart: DateTime(2026, 11, 2),
        activities: [done('2026-11-03', 'WeightTraining')],
        planned: [
          planned('2026-11-03', strengthSport),
          planned('2026-11-06', strengthSport),
          planned('2026-11-05', 'Run'),
        ],
        wellness: const [],
        previousWeekLoads: const [],
      );
      expect(r.strengthPlanned, 2);
      expect(r.strengthDone, 1);
      expect(r.days[1].missed, isEmpty);
      expect(r.days[4].missed, hasLength(1));
    });

    group('adaptation', () {
      final w0 = DateTime(2026, 11, 2);
      DateTime d(int weekday) => plusDays(w0, weekday - 1);
      var id = 1;
      PlanSession s(DateTime date, SessionSlot slot, {String? sport}) =>
          PlanSession(
            id: id++,
            weekIndex: 0,
            date: date,
            slot: slot,
            templateId: slot == SessionSlot.strength ? 'strength.heavy' : 't',
            name: slot.name,
            sport:
                sport ?? (slot == SessionSlot.strength ? strengthSport : 'Run'),
            minutes: 40,
            load: 25,
            lowMinutes: 40,
            description: '',
          );
      TrainingPlan planOf(List<PlanSession> sessions) => TrainingPlan(
        id: 1,
        goalType: 'long_distance',
        sport: 'Run',
        startDate: w0,
        baselineLoad: 300,
        status: PlanStatus.active,
        weeks: [
          PlanWeek(
            index: 0,
            phase: 'build',
            startDate: w0,
            targetLoad: 300,
            requestedLoad: 300,
            limit: WeekLimit.none,
            projectedCtlEnd: null,
            sessions: sessions,
            lowIntensityTarget: 0.8,
            lowIntensityTolerance: 0.05,
          ),
        ],
      );
      const g = Goal(
        targetType: 'long_distance',
        weekdays: {1, 2, 3, 4, 5, 6, 7},
        weeklyHours: 8,
        strengthPerWeek: 1,
      );
      List<Adaptation> adapt(
        TrainingPlan p,
        DateTime day, [
        List<LocalActivity> acts = const [],
      ]) => adaptPlan(
        plan: p,
        goal: g,
        activities: acts,
        today: day,
        rampCap: 0.1,
      );

      test('done when a strength activity is on the day', () {
        final st = s(d(2), SessionSlot.strength);
        expect(
          adapt(planOf([st]), d(4), [done(isoDate(d(2)), 'WeightTraining')]),
          isEmpty,
        );
        expect(
          adapt(planOf([st]), d(4), [done(isoDate(d(2)), 'Run')]),
          hasLength(1),
        );
      });

      test('a missed strength session is not stacked onto a hard day or '
          'the day before one', () {
        final st = s(d(1), SessionSlot.strength);
        // Wed intervals, Fri long: Wed and Fri are hard, Thu is the day
        // before Fri's long run: Saturday is the first fit after Tuesday.
        final p = planOf([
          st,
          s(d(3), SessionSlot.intervals),
          s(d(5), SessionSlot.long),
        ]);
        final m = adapt(p, d(2)).single as MissedSession;
        expect(m.session.id, st.id);
        expect(m.to, d(6));
      });

      test('a moved key session does not land the day after strength', () {
        final iv = s(d(1), SessionSlot.intervals);
        // Today's (Tuesday's) strength session: Wednesday is the day after.
        final p = planOf([iv, s(d(2), SessionSlot.strength)]);
        final m = adapt(p, d(2)).single as MissedSession;
        expect(m.session.id, iv.id);
        expect(m.to, d(4));
      });

      test('strength and mobility activity types', () {
        expect(isStrengthType('WeightTraining'), isTrue);
        expect(isStrengthType('Yoga'), isTrue);
        expect(isStrengthType('Run'), isFalse);
      });
    });
  });
}
